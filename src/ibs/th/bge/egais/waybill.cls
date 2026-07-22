/*

$Revision: fe417850d298, 1024, rls $
$Author: ASMorozov $
$Date: Wed Aug 23 16:58:40 2017 +0300 $
$Workfile: WayBill.cls $
$Archive: ibs/th/bge/egais/WayBill.cls $

Библиотека работы с накладной ЕГАИС.

Автор: Морозов Александр Сергеевич
Дата создания: 11/11/15
Author: Alexandr Morozov
Creation date: 11/11/15

*/

using ibs.th.bge.egais.*.
using Ibs.Th.Gbl.ProgressBar.
using Ibs.Th.ref.*.
block-level on error undo, throw.

class ibs.th.bge.egais.WayBill inherits EGAISUTM:

  {cmp/str-glbl.i class}
  {ibs/th/bge/egais/wb-egais.i}
  {ibs/th/bge/egais/tts-egais.i }
  { ref/extclass.i }
  { gbl/color.i }

&scop xml-act-1 '<?xml version="1.0" encoding="UTF-8"?>~
<ns:Documents Version="1.0" ~
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ~
xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01" ~
xmlns:oref="http://fsrar.ru/WEGAIS/ClientRef" ~
xmlns:pref="http://fsrar.ru/WEGAIS/ProductRef" ~
xmlns:wa="http://fsrar.ru/WEGAIS/ActTTNSingle">~
<ns:Owner>~
<ns:FSRAR_ID>&1</ns:FSRAR_ID>~
</ns:Owner>~
<ns:Document>~
<ns:WayBillAct>~
<wa:Header>~
<wa:IsAccept>&2</wa:IsAccept>~
<wa:ACTNUMBER>&3</wa:ACTNUMBER>~
<wa:ActDate>&4</wa:ActDate>~
<wa:WBRegId>&5</wa:WBRegId>~
<wa:Note>&6</wa:Note>~
</wa:Header>~
<wa:Content>'

&scop xml-act-2 '</wa:Content></ns:WayBillAct>~
</ns:Document>~
</ns:Documents>'

&scop xml-act-v2-1 '<?xml version="1.0" encoding="UTF-8"?>~
<ns:Documents Version="1.0" ~
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ~
xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01" ~
xmlns:oref="http://fsrar.ru/WEGAIS/ClientRef" ~
xmlns:pref="http://fsrar.ru/WEGAIS/ProductRef" ~
xmlns:wa="http://fsrar.ru/WEGAIS/ActTTNSingle_v2">~
<ns:Owner>~
<ns:FSRAR_ID>&1</ns:FSRAR_ID>~
</ns:Owner>~
<ns:Document>~
<ns:WayBillAct_v2>~
<wa:Header>~
<wa:IsAccept>&2</wa:IsAccept>~
<wa:ACTNUMBER>&3</wa:ACTNUMBER>~
<wa:ActDate>&4</wa:ActDate>~
<wa:WBRegId>&5</wa:WBRegId>~
<wa:Note>&6</wa:Note>~
</wa:Header>~
<wa:Content>'

&scop xml-act-v2-2 '</wa:Content></ns:WayBillAct_v2>~
</ns:Document>~
</ns:Documents>'

&scop xml-ReqRepealWB '<?xml version="1.0" encoding="UTF-8"?>~
<ns:Documents Version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01" xmlns:qp="http://fsrar.ru/WEGAIS/RequestRepealWB">~
<ns:Owner>~
<ns:FSRAR_ID>&1</ns:FSRAR_ID>~
</ns:Owner>~
<ns:Document>~
<ns:RequestRepealWB>~
<qp:ClientId>&2</qp:ClientId>~
<qp:RequestNumber>&3</qp:RequestNumber>~
<qp:RequestDate>&4</qp:RequestDate>~
<qp:WBRegId>&5</qp:WBRegId>~
</ns:RequestRepealWB>~
</ns:Document>~
</ns:Documents>'

&scop xml-ConfirmRepealWB '<?xml version="1.0" encoding="UTF-8"?>~
<ns:Documents Version="1.0" xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01" xmlns:wt= "http://fsrar.ru/WEGAIS/ConfirmRepealWB">~
<ns:Owner>~
<ns:FSRAR_ID>&1</ns:FSRAR_ID>~
</ns:Owner>~
<ns:Document>~
<ns:ConfirmRepealWB>~
<wt:Header>~
<wt:IsConfirm>&2</wt:IsConfirm>~
<wt:ConfirmNumber>&3</wt:ConfirmNumber>~
<wt:ConfirmDate>&4</wt:ConfirmDate>~
<wt:WBRegId>&5</wt:WBRegId>~
<wt:Note>~
</wt:Note>~
</wt:Header>~
</ns:ConfirmRepealWB>~
</ns:Document>~
</ns:Documents>'

  define stream outstr.
  define stream str-formF1.
  
  define private buffer buf_clob-bind          for ub.clob-bind.
  define private buffer buf_clob-bind-wb-hndls for ub.clob-bind.
  define private buffer buf_clob-bind-temp     for ub.clob-bind.
  define private buffer buf_clob-data          for ub.clob-data.
  define private buffer buf_gds                for ub.goods.
  define private buffer buf_gds-attr           for ub.goods-attr.
  define private buffer buf_trn-doc            for ub.trn-doc.
  define private buffer buf_doc-attr           for ub.doc-attr.
  define private buffer buf_parts              for ub.parts.
  define private buffer buf_doc-line           for ub.doc-line.
  define private buffer buf_doc-line-attr      for ub.doc-line-attr.
  define private buffer buf_clients            for ub.clients.
  define private buffer buf_clients-attr       for ub.clients-attr.
  define private buffer buf_firm               for ub.firm.
  define private buffer buf_shop               for ub.shop.
  define private buffer buf_store              for ub.store.
  define private buffer buf_ext-classif        for ub.ext-classif.
  define private buffer buf_ext-classif-attr   for ub.ext-classif-attr.
  define private buffer X_ext-classif          for ub.ext-classif.
  define private buffer buf_country            for ub.country.
  define private buffer buf_tt-wb-gds-EG       for tt-wb-gds-EG.
  
  define private variable parameters     as character no-undo.
  define private variable inFileName     as character no-undo.
  define private variable inData         as character no-undo.
  define private variable outData        as character no-undo.
  define private variable cmd            as character no-undo.
  define private variable urlResp        as character no-undo.
  define private variable v-uniq-key-rec as character no-undo.
  define private variable nn             as integer   no-undo.
  define private variable nnList         as integer   no-undo.
  define private variable minPrice       as decimal   no-undo.
  define private variable isForceAccept  as logical   no-undo.
  define private variable verPrefXMLNS   as character no-undo.
  define private variable bh-act-tts-header  as handle    no-undo.
      
  define private variable extGdsObj      as class   ExtGds         no-undo.
  define private variable extGdsValueObj as class   ExtGdsValue    no-undo.
  define private variable prgObj         as class   ProgressBar    no-undo .
  define private variable prsXMLDocWB    as class   ParserXMLDocWB no-undo.
  define private variable alcTypeAttrObj as class   AlcTypeAttr    no-undo.
  define private variable egaisTTS       as class   TransferToShop no-undo.

      
  define variable v-FS-RAR   as character no-undo .
  define variable inDocFSRAR as character no-undo .
  define variable v-ext-sys  as integer   no-undo .
  define variable ObjType    as character no-undo .
  define variable ObjCode    as integer   no-undo .
  define variable VerWBXsd   as character no-undo.
  
  define property HndlHeader as handle no-undo
    get.
    private set. 
  
  define property HndlLine as handle no-undo
    get.
    private set.

  define property HndlAnaliz as handle no-undo
    get.
    private set.
    
  define property ActnEGAISAdm as logical no-undo
    get.
    set.

  define property ActnEGAISSts as logical no-undo
    get.
    set.
    
  define property FastDwnl as logical no-undo
    get.
    set.

  define property SettingsTTList as character no-undo
    get.
    set.

  define temp-table tt-wb-hndls no-undo
    field num          as character label "№ накл." format "X(50)"
    field wb-date      as date      label "Дата"
    field obj          as character label "Объект"
    field shippregid   as character label "ID поставщика" format "x(21)"
    field cli          as character label "Контрагент" format "x(30)"
    field cliname      as character label "Название контрагента" format "x(30)"
    field wb-type      as character label "Тип" format "x(20)" 
    field trn-doc-code as character label "№ накл. TH" format "x(20)"
    field status_      as character label "Статус" format "x(20)"
    field EGAISSts     as character label "Статус ЕГАИС" format "x(20)"
    field is-sent      as character label "Отправлена"
    field wbregid      as character label "WBREGID" format "X(18)"
    field tts          as character label "Акт передачи в торг. зал." format "X(30)"
    field tts-status_  as character label "Статус" format "x(10)"
    field Identity     as character format "X(50)"
    field uniq-key-rec as character format "X(50)"
    field DbNUm        as integer   label "БД"
    field isWB         as logical
    index pi
    Identity 
    .

  define private buffer buf_tt-analiz for tt-analiz.

  define temp-table tt-wb-act-hndls no-undo
    field num          as character label "№ акта"
    field act-date     as date      label "Дата"
    field status_      as character label "Статус"
    field wbregid      as character label "ID накл. EGAIS" format "X(21)"
    index pi
    wbregid
    .


  constructor public WayBill (inObjType as char, inObjCode as int, inFSRAR as char, inExtSys as integer):
    
    super (inObjType, inObjCode).
    ObjCode = inObjCode.
    ObjType = inObjType.
    v-FS-RAR = inFSRAR.
    v-ext-sys = inExtSys.
    IsSent.
    extGdsObj = new ExtGds (yes).
    prsXMLDocWB = new ParserXMLDocWB(v-ext-sys).
    alcTypeAttrObj = new AlcTypeAttr ().
    
  end constructor.
  
  destructor WayBill ():
    if valid-object (extGdsObj) 
      then delete object extGdsObj no-error.
    if valid-object (prgObj)
      then delete object prgObj.
    if valid-object (prsXMLDocWB)
      then delete object prsXMLDocWB.
    if valid-object (alcTypeAttrObj)
      then delete object alcTypeAttrObj.
  end. 
  
  method public override handle GetHndlTable(inTableType as int, inWbIdentity as char) :

    define buffer buf_clob-bind-ref for ub.clob-bind.
    define buffer buf_clob-data-ref for ub.clob-data.
    define variable hDoc    as handle  no-undo.
    define variable hDocRef as handle  no-undo.
    define variable ii      as integer no-undo.

    assign
      StatusErr = false
      Msg       = ""
      .
    
    isForceAccept = false.
    
    /*if inWbIdentity = "AllWB"
      then 
    do: 
      GetDocUTM().
      if StatusErr
        then return ?.
      return ?.
    end.*/
    
    case inTableType:
      when {&wb-header} or 
      when {&wb-line} then 
        do:
          if true /*not (available (buf_clob-bind) and inWbIdentity)*/
            then 
          do:
            empty temp-table tt-wb-header.
            empty temp-table tt-wb-gds-EG.
            find first buf_clob-bind no-lock where buf_clob-bind.uniq-key-rec = inWbIdentity and buf_clob-bind.resource-type = {&lob-egais-wb} no-error.
            if not available (buf_clob-bind) then 
            do:
              find first buf_clob-bind no-lock 
                where num-entries (inWbIdentity, {&delim-cmd}) = 4 and 
                  (buf_clob-bind.uniq-key-rec = entry (4, inWbIdentity, {&delim-cmd}) + {&delim-cmd} + entry (3, inWbIdentity, {&delim-cmd})
                  or buf_clob-bind.uniq-key-rec = entry (4, inWbIdentity, {&delim-cmd})) and
                  buf_clob-bind.resource-type = {&lob-egais-wb} 
              no-error.
              if not available (buf_clob-bind) then 
              do:
                Msg = "Не найдена накладная с идентификатором " + inWbIdentity.
                StatusErr = true.
                return ?.
              end.
            end.
            v-uniq-key-rec = buf_clob-bind.uniq-key-rec.
            find first buf_clob-data no-lock where buf_clob-data.db-num = buf_clob-bind.db-num and buf_clob-data.int64-id = buf_clob-bind.int64-id no-error.
            createhDoc(recid (buf_clob-data), "temp.xml", output hDoc).
            
            find first buf_clob-bind-ref no-lock where buf_clob-bind-ref.uniq-key-rec = v-uniq-key-rec and buf_clob-bind-ref.resource-type = {&lob-egais-ref-b} no-error.
            if available (buf_clob-bind-ref) then 
            do:
              find first buf_clob-data-ref no-lock where buf_clob-data-ref.db-num = buf_clob-bind-ref.db-num and buf_clob-data-ref.int64-id = buf_clob-bind-ref.int64-id no-error.
              createhDoc(recid (buf_clob-data-ref), "refbtemp.xml", output hDocRef).
              prsXMLDocWB:ParseRec(hDoc, hDocRef, input-output table tt-wb-header, input-output table tt-wb-gds-EG, input-output table tt-wb-info-client).
            end.
            else do:
              prsXMLDocWB:ParseRec(hDoc, ?, input-output table tt-wb-header, input-output table tt-wb-gds-EG, input-output table tt-wb-info-client).
            end.

            find first tt-wb-header.
            if not available ( tt-wb-header )
            then do:
              message "Неудалось распарсить документ." view-as alert-box.
              return ?.
            end.
            tt-wb-header.TransIdList = buf_clob-bind.field-name_.
            find first buf_ext-classif no-lock where buf_ext-classif.classif-subject = {&table_clients}
              and buf_ext-classif.classif-name = {&extclass_clients_esys}
              and buf_ext-classif.db-num = 0
              and buf_ext-classif.key#_one = v-ext-sys
              and buf_ext-classif.CharKey_Three = tt-wb-header.regID-Ship no-error.
            if available (buf_ext-classif)
              then 
            do:
              find first ub.clients no-lock where 
                ub.clients.obj-type = entry(2, buf_ext-classif.uniq-key-rec, {&delim-key}) and 
                ub.clients.obj-code = integer(entry(3, buf_ext-classif.uniq-key-rec, {&delim-key})).
              
              if available (ub.clients) then 
              do:
                
                find first ub.clients-attr where ub.clients-attr.attr-code = {&attr-main-accholder}
                  and ub.clients-attr.obj-code = ub.clients.obj-code and ub.clients-attr.obj-type = ub.clients.obj-type no-error.
                
                if available (ub.clients-attr)
                then do:
                  assign
                    tt-wb-header.cli-type = entry (1, ub.clients-attr.attr-value, ",")
                    tt-wb-header.cli-code = integer (entry (2, ub.clients-attr.attr-value, ","))
                    tt-wb-header.client   = entry (1, ub.clients-attr.attr-value, ",") + entry (2, ub.clients-attr.attr-value, ",")
                    tt-wb-header.cargo-from = ub.clients.obj-type + string (ub.clients.obj-code)
                    .
                end.
                else do:
                  assign
                    tt-wb-header.cli-type = ub.clients.obj-type
                    tt-wb-header.cli-code = ub.clients.obj-code
                    tt-wb-header.client   = ub.clients.obj-type + string (ub.clients.obj-code)
                    .                  
                end.
              end.
            end.
           
            find first buf_ext-classif no-lock where buf_ext-classif.classif-subject = {&table_clients}
              and buf_ext-classif.classif-name = {&extclass_clients_esys}
              and buf_ext-classif.db-num = 0
              and buf_ext-classif.key#_one = v-ext-sys
              and buf_ext-classif.CharKey_Three = tt-wb-header.regID-Cons and buf_ext-classif.CharKey_Two = entry (9, buf_clob-bind.descr, {&delim-par}) no-error.
            
            if available (buf_ext-classif)
              then 
            do:
              find first ub.clients no-lock where 
                ub.clients.obj-type = entry(2, buf_ext-classif.uniq-key-rec, {&delim-key}) and 
                ub.clients.obj-code = integer(entry(3, buf_ext-classif.uniq-key-rec, {&delim-key})).
              
              if available (ub.clients) then 
              do:
                assign
                  tt-wb-header.obj-type   = ub.clients.obj-type
                  tt-wb-header.obj-code   = ub.clients.obj-code
                  tt-wb-header.clientCons = ub.clients.obj-type + string (ub.clients.obj-code)
                  .
              end.
            end.

            for each tt-wb-gds-EG:
              if tt-wb-gds-EG.alc-code = ? or tt-wb-gds-EG.alc-code = ""
              then do:
                message "Документ распарсен с ошибками." view-as alert-box.
                return ?.
              end.
              extGdsObj:OpenQueryExtGds(0, tt-wb-gds-EG.alc-code).
              if extGdsObj:NumBundles = 1
                then do: 
                  tt-wb-gds-EG.gds-code = extGdsObj:GetExtGdsValue():GdsCode.
                  find first buf_tt-wb-gds-EG where buf_tt-wb-gds-EG.alc-code = tt-wb-gds-EG.alc-code and recid (buf_tt-wb-gds-EG) <> recid (tt-wb-gds-EG) no-error.
                  if available (buf_tt-wb-gds-EG)
                  then do:
                    buf_tt-wb-gds-EG.color-sts = DARK_GREY_COLOR.
                    tt-wb-gds-EG.color-sts = DARK_GREY_COLOR. 
                  end.
                end.
                else do:
                  if extGdsObj:NumBundles > 1
                  then do: 
                    assign tt-wb-gds-EG.gds-code = ?.
                    tt-wb-gds-EG.color-sts = DARK_GREY_COLOR.
                  end.
                  else assign tt-wb-gds-EG.gds-code = 0 tt-wb-gds-EG.color-sts = RED_COLOR.
                end.
            end.

            if available (buf_clob-bind-ref) then 
            do:

              for each tt-wb-gds-EG where tt-wb-gds-EG.gds-code = ? :
                nnList = lookup ( tt-wb-gds-EG.refB, buf_clob-bind-ref.descr).
                if nnList > 0
                then do:
                  extGdsObj:OpenQueryExtGds (integer (entry (nnList - 1, buf_clob-bind-ref.descr)), tt-wb-gds-EG.alc-code).
                  if extGdsObj:NumBundles > 0
                  then do:
                    tt-wb-gds-EG.gds-code = integer (entry (nnList - 1, buf_clob-bind-ref.descr)).
                  end. 
                  else do:
                    tt-wb-gds-EG.color-sts = RED_COLOR.
                  end.
                end.
                else do:
                  tt-wb-gds-EG.color-sts = DARK_GREY_COLOR.
                end.
              end.
            end.
            
          end.
          HndlHeader = buffer tt-wb-header:handle.
          HndlLine = buffer tt-wb-gds-EG:handle.
          if inTableType = {&wb-header} then 
          do:
            return buffer tt-wb-header:handle.
          end.
          else 
          do:
            return buffer tt-wb-gds-EG:handle.
          end.
        end.
      when {&wb-act-header} or 
      when {&wb-act-line} then 
        do:
          if true /*not (available (buf_clob-bind) and inWbIdentity)*/
            then 
          do:
            if inTableType = {&wb-act-header}
              then empty temp-table tt-wb-act-header.
              else empty temp-table tt-wb-act-gds-EG.
            find first buf_clob-bind exclusive-lock where buf_clob-bind.uniq-key-rec = inWbIdentity and buf_clob-bind.resource-type = {&lob-egais-wb-act} no-error.
            if not available (buf_clob-bind) then 
            do:
              Msg = "Не найден акт с идентификатором " + inWbIdentity.
              StatusErr = true.
              return ?.
            end.
            find first buf_clob-data exclusive-lock where buf_clob-data.db-num = buf_clob-bind.db-num and buf_clob-data.int64-id = buf_clob-bind.int64-id no-error.
            
            createhDoc(recid (buf_clob-data), "temp.xml", output hDoc).
            prsXMLDocWB:ParseRec (hDoc, input-output table tt-wb-act-header, input-output table tt-wb-act-gds-EG).
            find first tt-wb-act-header.
            find first buf_doc-attr no-lock where buf_doc-attr.attr-code = {&trdcattr-negais} and buf_doc-attr.attr-value begins tt-wb-act-header.wbregid no-error.
            if available (buf_doc-attr) then do:
              find first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_doc-attr.doc-code.
              
              for each tt-wb-act-gds-EG :
                
                find first buf_parts no-lock where
                 buf_parts.obj-type = buf_trn-doc.obj-type and 
                 buf_parts.obj-code = buf_trn-doc.obj-code and 
                 buf_parts.in-code = buf_trn-doc.doc-code and
                 buf_parts.out-code = buf_trn-doc.doc-code and
                 tt-wb-act-gds-EG.refB = entry (2, buf_parts.alc-ref-ab-path, ",") no-error.
                
                /*if not available (buf_parts)
                  then do:
                    message substitute ("Не найдена партия для товара из акта") view-as alert-box. 
                  end.*/

                if available (buf_parts) then do:
                  find first buf_gds no-lock where buf_gds.artic = buf_parts.artic and buf_gds.prod-code = buf_parts.prod-code and buf_gds.prod-type = buf_parts.prod-type.
                  assign
                    tt-wb-act-gds-EG.doc-qnty = buf_parts.qnty / buf_parts.cli-base-rate
                    tt-wb-act-gds-EG.fact-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
                    tt-wb-act-gds-EG.gds-code = buf_gds.gds-code
                  .
                end.
                else do:
                  assign
                    tt-wb-act-gds-EG.doc-qnty = ?
                    tt-wb-act-gds-EG.fact-qnty = ?
                    tt-wb-act-gds-EG.gds-code = ?
                  .
                end.
              end.
              
            end.
            
          end.
          HndlHeader = buffer tt-wb-header:handle.
          HndlLine = buffer tt-wb-gds-EG:handle.
          if inTableType = {&wb-act-header} then 
          do:
            return buffer tt-wb-act-header:handle.
          end.
          else 
          do:
            return buffer tt-wb-act-gds-EG:handle.
          end.
        end.
      when {&wb-clob} then 
        do: 
          SettingsTTList = "20,yes;;;12,yes;9,yes;20,yes;10,yes;10,yes;6,yes;12,yes;;;30,yes;10,yes;;;;".
                  
          egaisTTS = new TransferToShop (ObjType, ObjCode, v-FS-RAR, v-ext-sys).
          egaisTTS:DbNum =  DbNum.
          egaisTTS:User_Id = User_Id.
          bh-act-tts-header = egaisTTS:GetHndlTable({&awo-clob}, "").

          empty temp-table tt-wb-hndls.
          for each buf_clob-bind-wb-hndls no-lock where buf_clob-bind-wb-hndls.resource-type = {&lob-egais-wb}:
            /*v-info = string (tt-wb-header.wb-date) + {&-par} + tt-wb-header.num + {&-par} + tt-wb-info-client.regID + {&-par} + tt-wb-header.Identity + {&-par} + string (tt-wb-header.wbregid) + {&-par} + "нет" + {&-par} + "нет" + {&-par}.*/
            if entry (9, buf_clob-bind-wb-hndls.descr, {&delim-par}) <> "" and entry (9, buf_clob-bind-wb-hndls.descr, {&delim-par}) <> "0" and entry (9, buf_clob-bind-wb-hndls.descr, {&delim-par}) <> ObjType + string (ObjCode)
              then next.
            create tt-wb-hndls.
            assign
              tt-wb-hndls.wb-date      = date (entry (1, buf_clob-bind-wb-hndls.descr, {&delim-par}))
              tt-wb-hndls.num          = (if buf_clob-bind-wb-hndls.uniq-key-rec matches '*отмена*' or buf_clob-bind-wb-hndls.uniq-key-rec matches '*old*' then "отмена: " else "") + entry (2, buf_clob-bind-wb-hndls.descr, {&delim-par})
              tt-wb-hndls.shippregid   = entry (3, buf_clob-bind-wb-hndls.descr, {&delim-par})
              tt-wb-hndls.Identity     = entry (4, buf_clob-bind-wb-hndls.descr, {&delim-par})
              tt-wb-hndls.trn-doc-code = entry (6, buf_clob-bind-wb-hndls.descr, {&delim-par})
              tt-wb-hndls.is-sent      = entry (7, buf_clob-bind-wb-hndls.descr, {&delim-par})
              tt-wb-hndls.wb-type      = "приход вн."  
                when entry (8, buf_clob-bind-wb-hndls.descr, {&delim-par}) = {&TDEDT_Pri_Vnesh}
              tt-wb-hndls.wb-type      = "возврат вн."  
                when entry (8, buf_clob-bind-wb-hndls.descr, {&delim-par}) = {&TDEDT_Vozvrat_Vnesh}
              tt-wb-hndls.obj          = entry (9, buf_clob-bind-wb-hndls.descr, {&delim-par})
              tt-wb-hndls.EGAISSts     = entry (10, buf_clob-bind-wb-hndls.descr, {&delim-par}) when num-entries (buf_clob-bind-wb-hndls.descr, {&delim-par}) > 9
              tt-wb-hndls.uniq-key-rec = buf_clob-bind-wb-hndls.uniq-key-rec.
              tt-wb-hndls.DbNUm        = buf_clob-bind-wb-hndls.db-num.
            .
            bh-act-tts-header:find-first (substitute ("where tt-act-header.num matches '*&1*'", trn-doc-code), no-lock ) no-error.
            if bh-act-tts-header:available
            then do:
              tt-wb-hndls.tts = bh-act-tts-header:buffer-field ("num"):buffer-value ().
              if num-entries (bh-act-tts-header:buffer-field ("RegID"):buffer-value (), chr(5) ) < 2
              then do:
                if bh-act-tts-header:buffer-field ("is-sent"):buffer-value = true
                then do:
                  tt-wb-hndls.tts-status_ = 'Отправлен'.
                end.
                else do:
                  tt-wb-hndls.tts-status_ = 'Новый'.
                end.
              end.
              else do:
                case entry(2, bh-act-tts-header:buffer-field ("RegID"):buffer-value, chr(5)):
                when "R" then do:
                  tt-wb-hndls.tts-status_ = 'Отклонен'.
                end.
                when "A" then do:
                  tt-wb-hndls.tts-status_ = 'Принят'.
                end.
                end case.
              end.
            end.
            
            find first ub.ext-classif no-lock 
              where ub.ext-classif.classif-subject = {&table_clients}
                and ub.ext-classif.classif-name = {&extclass_clients_esys}
                and ub.ext-classif.db-num = 0
                and ub.ext-classif.key#_one = v-ext-sys
                and ub.ext-classif.CharKey_Three = tt-wb-hndls.shippregid
                no-error.
            if available (ub.ext-classif) then do:
              find first buf_clients where buf_clients.obj-type = entry (2, ub.ext-classif.uniq-key-rec, {&delim-key}) and buf_clients.obj-code = integer (entry (3, ub.ext-classif.uniq-key-rec, {&delim-key})) no-error.
              if available (buf_clients)
                then do: 
                  tt-wb-hndls.cli = buf_clients.obj-type + string (buf_clients.obj-code).
                  tt-wb-hndls.cliname = buf_clients.obj-name.
                end.
            end.
            assign 
              tt-wb-hndls.wbregid = entry (5, buf_clob-bind-wb-hndls.descr, {&delim-par}) no-error.
            if tt-wb-hndls.wbregid = ""
            then do:
              if GetHndlTable({&wb-header}, tt-wb-hndls.uniq-key-rec) <> ?
              then do:
                find first tt-wb-header no-error.
                find first buf_clob-bind-temp where recid (buf_clob-bind-temp) = recid (buf_clob-bind-wb-hndls) exclusive-lock.
                if available (tt-wb-header) 
                  then 
                    assign 
                      tt-wb-hndls.wbregid = tt-wb-header.wbregid
                      entry (5, buf_clob-bind-temp.descr, {&delim-par}) = tt-wb-header.wbregid when available (buf_clob-bind-temp).
                    .
                release buf_clob-bind-temp.
              end.
            end.
            find first buf_trn-doc where buf_trn-doc.doc-code = tt-wb-hndls.trn-doc-code no-error.
            if available (buf_trn-doc)
              then
                assign 
                tt-wb-hndls.status_ = buf_trn-doc.status_ + (if buf_trn-doc.flag_ then "+" else "-")
                tt-wb-hndls.isWB = true.
              else tt-wb-hndls.isWB = false. 
          end.
          if valid-object (egaisTTS)
            then delete object egaisTTS.
          return buffer tt-wb-hndls:handle.
        end.
      when {&wb-clob-act} then 
        do:
          SettingsTTList = "10,yes;;;".
          empty temp-table tt-wb-act-hndls.
          for each buf_clob-bind where buf_clob-bind.resource-type = {&lob-egais-wb-act}:
            /*v-info = string (tt-wb-header.wb-date) + {&-par} + tt-wb-header.num + {&-par} + tt-wb-info-client.regID + {&-par} + tt-wb-header.Identity + {&-par} + string (tt-wb-header.wbregid) + {&-par} + "нет" + {&-par} + "нет" + {&-par}.*/
            create tt-wb-act-hndls.
            assign
              tt-wb-act-hndls.wbregid  = entry (1, buf_clob-bind.descr, {&delim-par})
              tt-wb-act-hndls.act-date = date (entry (2, buf_clob-bind.descr, {&delim-par}))
              tt-wb-act-hndls.num      = entry (3, buf_clob-bind.descr, {&delim-par})
              tt-wb-act-hndls.status_  = entry (4, buf_clob-bind.descr, {&delim-par})
              .
          end.
          return buffer tt-wb-act-hndls:handle.
        end.
      when {&ticket} then 
        do:
          empty temp-table tt-ticket.
          ii = 0.
          find current tt-wb-hndls no-error.
          find first ub.clob-bind where (available (tt-wb-hndls) and ub.clob-bind.resource-type = {&lob-egais-wb} and ub.clob-bind.uniq-key-rec = tt-wb-hndls.uniq-key-rec) no-error.
          
          for each buf_clob-bind where (buf_clob-bind.resource-type = {&lob-egais-ticket} and buf_clob-bind.uniq-key-rec begins inWbIdentity) 
                                      or (available (ub.clob-bind) and not buf_clob-bind.uniq-key-rec begins inWbIdentity and buf_clob-bind.resource-type = {&lob-egais-ticket} and lookup (buf_clob-bind.field-name_, ub.clob-bind.field-name_) > 0)
                                      or can-find (first buf_ext-classif where buf_ext-classif.classif-name = {&extclass_egais-transId}
                                        and buf_ext-classif.db-num = 0
                                        and buf_ext-classif.key#_one = v-ext-sys
                                        and buf_ext-classif.CharKey_One = inWbIdentity
                                        and buf_ext-classif.CharKey_Two = buf_clob-bind.field-name_):
            ii = ii + 1.
            find first buf_clob-data where buf_clob-data.db-num = buf_clob-bind.db-num and buf_clob-data.int64-id = buf_clob-bind.int64-id no-error.
            createhDoc(recid (buf_clob-data), string (ii) + "temp.xml", output hDoc).
            prsXMLDocWB:IsToClearTable = false.
            prsXMLDocWB:ParseRec (hDoc, input-output table tt-ticket).
            prsXMLDocWB:IsToClearTable = true.
          end.
          for each buf_clob-bind where buf_clob-bind.resource-type = {&lob-egais-wb-ticket} and buf_clob-bind.uniq-key-rec begins inWbIdentity :
            ii = ii + 1.
            find first buf_clob-data where buf_clob-data.db-num = buf_clob-bind.db-num and buf_clob-data.int64-id = buf_clob-bind.int64-id no-error.
            createhDoc(recid (buf_clob-data), string (ii) + "temp.xml", output hDoc).
            prsXMLDocWB:IsToClearTable = false.
            prsXMLDocWB:ParseRec (hDoc, input-output table tt-ticket).
            prsXMLDocWB:IsToClearTable = true.
          end.
          return buffer tt-ticket:handle.
        end.
      when {&ticket-ras} then
        do:
          empty temp-table tt-ticket.
          for each buf_clob-bind where 
            ((buf_clob-bind.resource-type = {&lob-egais-ticket} or buf_clob-bind.resource-type = {&lob-egais-wb-ticket}) and buf_clob-bind.uniq-key-rec matches "*" + inWbIdentity + "*") 
            or (can-find (first buf_ext-classif where buf_ext-classif.classif-name = {&extclass_egais-transId}
                  and buf_ext-classif.db-num = 0
                  and buf_ext-classif.key#_one = v-ext-sys
                  and buf_ext-classif.CharKey_One = inWbIdentity
                  and buf_ext-classif.CharKey_Two = buf_clob-bind.field-name_))
            :
            ii = ii + 1.
            find first buf_clob-data where buf_clob-data.db-num = buf_clob-bind.db-num and buf_clob-data.int64-id = buf_clob-bind.int64-id no-error.
            createhDoc(recid (buf_clob-data), string (ii) + "temp.xml", output hDoc).
            prsXMLDocWB:IsToClearTable = false.
            prsXMLDocWB:ParseRec (hDoc, input-output table tt-ticket).
            prsXMLDocWB:IsToClearTable = true.
          end.
          find first tt-ticket where tt-ticket.regid <> "" no-error.
          if available (tt-ticket) then do:
            find first buf_doc-attr no-lock where buf_doc-attr.attr-code = {&trdcattr-negais} and buf_doc-attr.doc-code = inWbIdentity no-error.
            if not available (buf_doc-attr)
            then do:
              create buf_doc-attr.
              assign
                buf_doc-attr.doc-code = inWbIdentity
                buf_doc-attr.attr-value = tt-ticket.regid
                buf_doc-attr.attr-code = {&trdcattr-negais}
              .
            end.
            for each buf_clob-bind where buf_clob-bind.resource-type = {&lob-egais-wb-act} and buf_clob-bind.uniq-key-rec matches "*" + buf_doc-attr.attr-value + "*" :
              find first buf_clob-data where buf_clob-data.db-num = buf_clob-bind.db-num and buf_clob-data.int64-id = buf_clob-bind.int64-id no-error.
              create tt-ticket.
              assign
                tt-ticket.regid = entry (1, buf_clob-bind.descr, {&delim-par})
                tt-ticket.ticket-date = string (iso-date (date (entry (2, buf_clob-bind.descr, {&delim-par}))))
                tt-ticket.doc = entry (3, buf_clob-bind.descr, {&delim-par})
                tt-ticket.status_ = entry (4, buf_clob-bind.descr, {&delim-par}).

              createhDoc(recid (buf_clob-data), "temp.xml", output hDoc).
              prsXMLDocWB:ParseRec (hDoc, input-output table tt-wb-act-header, input-output table tt-wb-act-gds-EG).

              find first tt-wb-act-header no-error.
              if available (tt-wb-act-header)
              then do: 
                tt-ticket.comment = tt-wb-act-header.note.
                find first ub.doc-attr exclusive-lock where ub.doc-attr.doc-code = inWbIdentity and ub.doc-attr.attr-code = {&trdcattr-egais} no-error.
                if not available (ub.doc-attr)
                then do:
                  create ub.doc-attr.
                  assign 
                    ub.doc-attr.doc-code = buf_doc-attr.doc-code
                    ub.doc-attr.attr-code = {&trdcattr-egais}
                  .
                end.
                ub.doc-attr.attr-value = tt-wb-act-header.status_.
                release ub.doc-attr.
                tt-wb-hndls.EGAISSts = tt-wb-act-header.status_.
              end.
            end.
          end.
          return buffer tt-ticket:handle.          
        end.
      when {&wb-fact} then 
        do:
          SettingsTTList = "20,yes;;;12,yes;9,yes;20,yes;10,yes;;6,yes;12,yes;;;30,yes;10,yes;;;;".
          empty temp-table tt-wb-hndls.
          
          egaisTTS = new TransferToShop (ObjType, ObjCode, v-FS-RAR, v-ext-sys).
          egaisTTS:DbNum =  DbNum.
          egaisTTS:User_Id = User_Id.
          bh-act-tts-header = egaisTTS:GetHndlTable({&awo-clob}, "").
          
          for each buf_doc-attr no-lock where buf_doc-attr.attr-code = {&trdcattr-negais}:
            for each buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_doc-attr.doc-code and buf_trn-doc.status_ = {&fact} and lookup (buf_trn-doc.doc-type, {&income_return}) > 0 :
              if ObjCode <> buf_trn-doc.obj-code or ObjType <> buf_trn-doc.obj-type
                then next.

              find first ub.doc-attr no-lock where ub.doc-attr.doc-code = buf_trn-doc.doc-code and ub.doc-attr.attr-code = {&trdcattr-egais} no-error.

              find first buf_clients where buf_clients.obj-code = buf_trn-doc.cli-code and buf_clients.obj-type = buf_trn-doc.cli-type no-lock.
              
              find first ub.ext-classif no-lock 
                where ub.ext-classif.classif-subject = {&table_clients}
                  and ub.ext-classif.classif-name = {&extclass_clients_esys}
                  and ub.ext-classif.db-num = 0
                  and ub.ext-classif.key#_one = v-ext-sys
                  and ub.ext-classif.uniq-key-rec = {&table_clients} + {&delim-key} + buf_trn-doc.cli-type + {&delim-key} + string (buf_trn-doc.cli-code)
                  no-error.

              find first ub.doc-attr no-lock where ub.doc-attr.doc-code = buf_trn-doc.doc-code and ub.doc-attr.attr-code = {&trdcattr-egais} no-error.
              
              create tt-wb-hndls. 
              assign
                tt-wb-hndls.wb-date      = buf_trn-doc.doc-date
                tt-wb-hndls.num          = entry (2, buf_doc-attr.attr-value, {&delim-cmd})
                tt-wb-hndls.trn-doc-code = buf_trn-doc.doc-code
                tt-wb-hndls.cliname = buf_clients.obj-name
                tt-wb-hndls.obj = buf_trn-doc.obj-type + string (buf_trn-doc.obj-code)
                tt-wb-hndls.obj = buf_trn-doc.obj-type + string (buf_trn-doc.obj-code)
                tt-wb-hndls.cli   = buf_trn-doc.cli-type + string (buf_trn-doc.cli-code)
                tt-wb-hndls.uniq-key-rec = buf_doc-attr.attr-value
                tt-wb-hndls.status_      = buf_trn-doc.status_ + (if buf_trn-doc.flag_ then "+" else "-")
                tt-wb-hndls.EGAISSts     = if available (ub.doc-attr) and not ub.doc-attr.attr-value <> "" then ub.doc-attr.attr-value else ""
                tt-wb-hndls.wbregid      = entry (1, buf_doc-attr.attr-value, {&delim-cmd}) no-error.
                
                if tt-wb-hndls.EGAISSts <> "" and tt-wb-hndls.EGAISSts <> "Accepted"
                then do:
                  find first buf_clob-bind where buf_clob-bind.resource-type = {&lob-egais-wb} and buf_clob-bind.descr matches "*" + tt-wb-hndls.wbregid + "*" no-lock no-error.
                  if available (buf_clob-bind) 
                  then do:
                    assign
                      tt-wb-hndls.EGAISSts = entry (10, buf_clob-bind.descr, {&delim-par}) when num-entries (buf_clob-bind.descr, {&delim-par}) > 9.
                    if not available (ub.doc-attr)
                    then do:
                      create ub.doc-attr.
                      assign 
                        ub.doc-attr.doc-code = buf_trn-doc.doc-code
                        ub.doc-attr.attr-code = {&trdcattr-egais}
                      .
                    end.
                    else do:
                      find current ub.doc-attr exclusive-lock.
                    end.
                    if tt-wb-hndls.EGAISSts <> ub.doc-attr.attr-value
                    then do:
                      assign
                        ub.doc-attr.attr-value = entry (10, buf_clob-bind.descr, {&delim-par}) when num-entries (buf_clob-bind.descr, {&delim-par}) > 9 and tt-wb-hndls.EGAISSts = "".
                    end.
                  end.
                  find current ub.doc-attr no-lock.
                end.
                
                if tt-wb-hndls.EGAISSts = ""
                then do:
                  find first buf_clob-bind where buf_clob-bind.resource-type = {&lob-egais-wb} and buf_clob-bind.descr matches "*" + tt-wb-hndls.wbregid + "*" no-lock no-error.
                  if available (buf_clob-bind) 
                  then do:
                    assign
                      tt-wb-hndls.EGAISSts = entry (10, buf_clob-bind.descr, {&delim-par}) when num-entries (buf_clob-bind.descr, {&delim-par}) > 9.
                    if not available (ub.doc-attr)
                    then do:
                      create ub.doc-attr.
                      assign 
                        ub.doc-attr.doc-code = buf_trn-doc.doc-code
                        ub.doc-attr.attr-code = {&trdcattr-egais}
                      .
                    end.
                    else do:
                      find current ub.doc-attr exclusive-lock.
                    end.
                    assign
                      ub.doc-attr.attr-value = entry (10, buf_clob-bind.descr, {&delim-par}) when num-entries (buf_clob-bind.descr, {&delim-par}) > 9.
                    find current ub.doc-attr no-lock.
                  end.
                end.
                assign
                  tt-wb-hndls.wb-type      = {&TDEDT_Pri_Vnesh-full} when buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
                  tt-wb-hndls.wb-type      = {&TDEDT_Vozvrat_Vnesh-full} when buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}
                  tt-wb-hndls.wb-type      = {&TDEDT_Vozvrat_Perem-full} when buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Perem}
                  tt-wb-hndls.wb-type      = {&TDEDT_Pri_Perem-full} when buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem}
                .
                bh-act-tts-header:find-first (substitute ("where tt-act-header.num matches '*&1*'", trn-doc-code), no-lock ) no-error.
                if bh-act-tts-header:available
                then do:
                  tt-wb-hndls.tts = bh-act-tts-header:buffer-field ("num"):buffer-value ().
                  if num-entries (bh-act-tts-header:buffer-field ("RegID"):buffer-value (), chr(5) ) < 2
                  then do:
                    if bh-act-tts-header:buffer-field ("is-sent"):buffer-value = true
                    then do:
                      tt-wb-hndls.tts-status_ = 'Отправлен'.
                    end.
                    else do:
                      tt-wb-hndls.tts-status_ = 'Новый'.
                    end.
                  end.
                  else do:
                    case entry(2, bh-act-tts-header:buffer-field ("RegID"):buffer-value, chr(5)):
                    when "R" then do:
                      tt-wb-hndls.tts-status_ = 'Отклонен'.
                    end.
                    when "A" then do:
                      tt-wb-hndls.tts-status_ = 'Принят'.
                    end.
                    end case.
                  end.
                end.
                tt-wb-hndls.is-sent = if available (ub.doc-attr) then "да" else "".
                entry (1, tt-wb-hndls.uniq-key-rec, {&delim-cmd}) = "".
                tt-wb-hndls.uniq-key-rec = left-trim (tt-wb-hndls.uniq-key-rec, {&delim-cmd}).
                if available (ub.ext-classif)
                  then tt-wb-hndls.shippregid = ub.ext-classif.CharKey_Three.
            end.
          end.
          if valid-object (egaisTTS)
            then delete object egaisTTS.
          return buffer tt-wb-hndls:handle.
        end.
      when {&wb-ras} then 
        do:
          SettingsTTList = "20,no;;;12,yes;9,yes;20,yes;17,yes;10,yes;6,yes;20,yes;;1,no;1,no;1,no;1,no;1,no;1,no;1,no".
          empty temp-table tt-wb-hndls.
            
            for each buf_trn-doc no-lock where buf_trn-doc.obj-code = ObjCode and buf_trn-doc.obj-type = ObjType 
              and (buf_trn-doc.status_ = {&fact} or buf_trn-doc.status_ = {&permitted})
              and (buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem} or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}) :

              find first buf_ext-classif no-lock where buf_ext-classif.classif-subject = {&table_clients}
                and buf_ext-classif.classif-name = {&extclass_clients_esys}
                and buf_ext-classif.db-num = 0
                and buf_ext-classif.key#_one = v-ext-sys 
                and buf_ext-classif.uniq-key-rec = {&table_clients} + {&delim-key} + buf_trn-doc.cli-type + {&delim-key} + string (buf_trn-doc.cli-code)
                no-error.
              if not available (buf_ext-classif) 
                then next.
              
              find first buf_doc-attr no-lock where buf_doc-attr.doc-code = buf_trn-doc.doc-code and buf_doc-attr.attr-code = {&trdcattr-egais}  no-error.
              create tt-wb-hndls.
              assign
                tt-wb-hndls.wb-date      = buf_trn-doc.doc-date
                tt-wb-hndls.trn-doc-code = buf_trn-doc.doc-code
                tt-wb-hndls.obj          = buf_trn-doc.obj-type + string (buf_trn-doc.obj-code)
                tt-wb-hndls.cli          = buf_trn-doc.cli-type + string (buf_trn-doc.cli-code)
                tt-wb-hndls.cliname      = buf_trn-doc.cli-name
                tt-wb-hndls.shippregid   = buf_ext-classif.charkey_three when available (buf_ext-classif)
                tt-wb-hndls.wb-type      = {&TDEDT_Ras_Vnesh_VP-full} when buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
                tt-wb-hndls.wb-type      = {&TDEDT_Ras_Perem-full} when buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem}
                tt-wb-hndls.wb-type      = {&TDEDT_Ras_Vnesh-full} when buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
                tt-wb-hndls.EGAISSts     = if available (buf_doc-attr) and not buf_doc-attr.attr-value = {&egais-wb-send} then buf_doc-attr.attr-value else ""
                tt-wb-hndls.EGAISSts     = {&egais-wb-send-full} when  available (buf_doc-attr) and buf_doc-attr.attr-value = {&egais-wb-send}
                tt-wb-hndls.EGAISSts     = "не отправлена" when not available (buf_doc-attr)
                tt-wb-hndls.wbregid      = buf_doc-attr.attr-value when available (buf_doc-attr)
                tt-wb-hndls.status_      = buf_trn-doc.status_ + (if buf_trn-doc.flag_ then "+" else "-")
              .
            end.

          return buffer tt-wb-hndls:handle.
        end.
      when {&wb-ras-header} or
      when {&wb-ras-line} then
        do:
          
          empty temp-table tt-wb-header.
          empty temp-table tt-wb-gds-EG.
          ii = 0.
          find first buf_trn-doc no-lock where buf_trn-doc.doc-code = inWbIdentity no-error.
          
          if not available (buf_trn-doc)
          then do:
            Msg = "Не найдена накладная" + inWbIdentity.
            StatusErr = true.
            return ?.
          end.

          if buf_trn-doc.fact-date = ?
          then do:
            Msg = "Неизвестная фактическая дата накладной: " + inWbIdentity + ". Установите фактическую дату в накладной.".
            StatusErr = true.
            return ?.
          end.          
          
          create tt-wb-header.
          assign
            tt-wb-header.Identity = buf_trn-doc.doc-code
            tt-wb-header.wb-type = "WBReturnFromMe" when buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
            tt-wb-header.wb-type = "WBInvoiceFromMe" when buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem} or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
            tt-wb-header.wb-date = buf_trn-doc.fact-date 
            tt-wb-header.cli-code = buf_trn-doc.cli-code
            tt-wb-header.cli-type = buf_trn-doc.cli-type
            tt-wb-header.obj-type = buf_trn-doc.obj-type
            tt-wb-header.obj-code = buf_trn-doc.obj-code
          .
          
          find first buf_ext-classif no-lock where buf_ext-classif.classif-subject = {&table_clients}
            and buf_ext-classif.classif-name = {&extclass_clients_esys}
            and buf_ext-classif.db-num = 0
            and buf_ext-classif.key#_one = v-ext-sys
            and buf_ext-classif.CharKey_Two = buf_trn-doc.obj-type + string (buf_trn-doc.obj-code) no-error.
          if not available (buf_ext-classif)
          then do:
            Msg = "Не найден клиент ЕГАИС для объекта " + buf_trn-doc.obj-type + string (buf_trn-doc.obj-code).
            StatusErr = true.
            return ?.
          end.
          tt-wb-header.regID-Ship = buf_ext-classif.CharKey_Three.
          
          find first buf_ext-classif no-lock where buf_ext-classif.classif-subject = {&table_clients}
            and buf_ext-classif.classif-name = {&extclass_clients_esys}
            and buf_ext-classif.db-num = 0
            and buf_ext-classif.key#_one = v-ext-sys
            and buf_ext-classif.uniq-key-rec = {&table_clients} + {&delim-key} + buf_trn-doc.cli-type + {&delim-key} + string (buf_trn-doc.cli-code) no-error.
          if not available (buf_ext-classif)
          then do:
            Msg = "Не найден клиент ЕГАИС для контрагента " + buf_trn-doc.cli-type + string (buf_trn-doc.cli-code).
            StatusErr = true.
            return ?.
          end.
          tt-wb-header.regID-Cons = buf_ext-classif.CharKey_Three.          
          
          for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code: 
            for each buf_parts no-lock where
              buf_parts.obj-type = buf_trn-doc.obj-type and 
              buf_parts.obj-code = buf_trn-doc.obj-code and 
              buf_parts.artic = buf_doc-line.artic and
              buf_parts.prod-type = buf_doc-line.prod-type and
              buf_parts.prod-code = buf_doc-line.prod-code and
              buf_parts.out-code = buf_trn-doc.doc-code: 
              ii = ii + 1.
              find first buf_gds no-lock where buf_gds.artic = buf_parts.artic and buf_gds.prod-code = buf_parts.prod-code and buf_gds.prod-type = buf_parts.prod-type.
              if num-entries (buf_parts.alc-ref-ab-path, ",") < 3
              then do:
                Msg = "В алкогольных атрибутах по партии отсутсвует алкогольный код и код группы для товара - " + string (buf_gds.gds-code) + ".".
                StatusErr = true.
                return ?.
              end.

/*              extGdsObj:OpenQueryExtGds(buf_gds.gds-code, entry (3, buf_parts.alc-ref-ab-path, ",")).*/
              find first ub.gds-dtl where 
                    ub.gds-dtl.doc-code = buf_doc-line.doc-code
                and ub.gds-dtl.artic = buf_parts.artic
                and ub.gds-dtl.prod-type = buf_parts.prod-type
                and ub.gds-dtl.prod-code = buf_parts.prod-code no-error.
              if not available (ub.gds-dtl)
              then do:
                Msg = "Отсутствует gds-dtl - " + string (buf_parts.artic) + ".".
                StatusErr = true.
                return ?.
              end.
              create tt-wb-gds-EG.
              assign
                tt-wb-gds-EG.Identity = string (ii)
/*                tt-wb-gds-EG.gds-name = extGdsObj:GetExtGdsValue():FullNameGds*/
                tt-wb-gds-EG.gds-code = buf_gds.gds-code
                tt-wb-gds-EG.qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate /*buf_parts.cli-qnty*/
                tt-wb-gds-EG.price = buf_parts.price-cli when buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} 
                tt-wb-gds-EG.price = ub.gds-dtl.price-rubl when buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem} or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
                tt-wb-gds-EG.refA = entry (1, buf_parts.alc-ref-ab-path, ",")
                tt-wb-gds-EG.refB = entry (2, buf_parts.alc-ref-ab-path, ",")
                tt-wb-gds-EG.alc-code = entry (3, buf_parts.alc-ref-ab-path, ",")
                tt-wb-gds-EG.alc-type-code = entry (4, buf_parts.alc-ref-ab-path, ",")
              .
              
              if tt-wb-gds-EG.refA = "" or tt-wb-gds-EG.refB = "" or tt-wb-gds-EG.refA = ? or tt-wb-gds-EG.refB = ?
              then do:
                Msg = "Не найдена справка А или Б к партии - " + buf_parts.out-code + ". Товар - " + string (buf_gds.gds-code) + "  " + buf_gds.gds-name.
                StatusErr = true.
                return ?.
              end.
              find first ub.alc-type-gds 
                   where ub.alc-type-gds.gds-code = buf_gds.gds-code
                     and ub.alc-type-gds.create-user-db-num = 0 no-lock no-error.
              
              if not available (ub.alc-type-gds) 
              then do:
                Msg = "Не задана алкогольная группа у товара " + string (buf_gds.gds-code).
                StatusErr = true.
                return ?.
              end.
              
              find first ub.alc-type where ub.alc-type-gds.alc-type-inner-code = ub.alc-type.alc-type-inner-code no-lock no-error.
              if not available (ub.alc-type) 
              then do:
                
                Msg = "Не найдена алкогольная группа у товара" + string (buf_gds.gds-code).
                StatusErr = true.
                return ?.

              end.
              
              alcTypeAttrObj:GetAlcTypeAttr ( input tt-wb-gds-EG.alc-type-code,
                                       input   "alc-min-price",
                                       output  minPrice
                                    ) no-error.
              
              if tt-wb-gds-EG.price < minPrice * buf_gds.cli-base-rate 
              then do:
              Msg = Msg + (if Msg <> "" then {&new-line} else '')
                + substitute ("Для товара &2/&1 &3 цена в накладной &4 меньше допустимой &5 по группе &6.", tt-wb-gds-EG.alc-code, buf_gds.gds-code, tt-wb-gds-EG.gds-name, tt-wb-gds-EG.price / buf_gds.cli-base-rate, minPrice, tt-wb-gds-EG.alc-type-code).
              end.

              assign
                tt-wb-gds-EG.ms-base = buf_gds.ms-base
                tt-wb-gds-EG.proof = buf_gds.proof
                tt-wb-gds-EG.alc-type-code = ub.alc-type.alc-type-code
              .
              if buf_doc-line.unit-cli <> buf_gds.unit-base and buf_doc-line.unit-cli > ""
              then do:
                tt-wb-gds-EG.UnitType = 'Unpacked'.
                if tt-wb-header.UnitType = '' or  tt-wb-header.UnitType = 'Packed' then tt-wb-header.UnitType = 'Unpacked'.
              end.
              else do:
                tt-wb-gds-EG.UnitType = 'Packed'.
                if tt-wb-header.UnitType <> 'Unpacked' then tt-wb-header.UnitType = 'Packed'.
              end. 
              
            end. 
          end.
          
        end. 
    end case.
    
  end.

  method override public logical SendRequestUTM ():
    
    def var ii        as int    no-undo.
    def var xml-cont  as char   no-undo.
    def var verDocXsd as char   no-undo.
    def var respValue as handle no-undo.
    
    assign
      StatusErr = false
      Msg       = ""
      .
    output stream outstr close.
    if IsSent 
      then 
    do:
      Msg = "Запрос уже был отправлен".
      StatusErr = true.
      return no.
    end.
    do trans:
    
      os-delete "RespTTNAct.xml".
      os-delete value (search ("RespTTNAct.xml")).
      assign
        inFileName = "RespTTNAct.xml"
        .
      find first tt-wb-header. 
      find first tt-wb-hndls where tt-wb-header.uniq-key-rec = tt-wb-hndls.uniq-key-rec no-error.
      
      if available (tt-wb-hndls)
        then 
      do:
        if not (tt-wb-hndls.wb-type matches "*расход*" or (tt-wb-hndls.wb-type matches "*возврат*" 
              and not tt-wb-hndls.wb-type matches "*возврат от покупателя*" and not tt-wb-hndls.wb-type matches "*возврат внешний*"
              and not tt-wb-hndls.wb-type matches "*возврат вн.*")) then 
        do:
          output stream outstr to value ("TTNAct.xml") convert target "UTF-8". 
          outData = GetXMLAct() no-error.
          if outData = ? or outData = ""
          then do:
            output stream outstr close.
            return false.
          end.
          
          put stream outstr unformatted outData.
          put stream outstr skip.
          output stream outstr close.

          case tt-wb-header.verXSD:
            when "WayBill" 
              then cmd = substitute ("&1 --connect-timeout 1 -F xml_file=@&2 &3/opt/in/WayBillAct >&4", search ("exe/curl.exe"), search ("TTNAct.xml"), ConPar, inFileName).
            when "WayBill_v2" 
              then cmd = substitute ("&1 --connect-timeout 1 -F xml_file=@&2 &3/opt/in/WayBillAct_v2 >&4", search ("exe/curl.exe"), search ("TTNAct.xml"), ConPar, inFileName).  
          end case.
          
          os-command value (cmd).
    
          file-info:file-name = search (inFileName).
          if search (inFileName) <> ? and file-info:file-size > 0 
            then 
          do:
            respValue = ParseRequest (inFileName).
            if respValue = ? 
              then 
            do:
              assign
                StatusErr = true
                Msg       = "Не удалось разобрать данные от УТМ"
                .
              undo, return false. 
            end.
            if not StatusErr 
              then 
              ReplyId = respValue:node-value.
            else 
            do:
              assign
                StatusErr = true
                Msg       = respValue:node-value
                .
              undo, return false. 
            end.
          end.
          else 
          do:
            assign
              StatusErr = true
              Msg       = "Не удалось отправить акт на накладную в УТМ"
              .
            undo, return false.
          end.
          find current buf_clob-bind exclusive-lock.
          entry (7, buf_clob-bind.descr, {&delim-par}) = "да".
          buf_clob-bind.field-name_ = buf_clob-bind.field-name_ + ',' + ReplyId.
          find current buf_clob-bind no-lock.
          tt-wb-hndls.is-sent = "да".
        end.

        else 
        do:
          inFileName = "TTN.xml".
          
          WriteXMLWB (inFileName).
          
          if StatusErr
          then
          do:
            return false.
          end.
          
          case tt-wb-header.verXSD:
          when 'WayBill' then do:
            cmd = substitute ("&1 --connect-timeout 1 -F xml_file=@&2 &3/opt/in/WayBill >&4", search ("exe/curl.exe"), search (inFileName), ConPar, "RespTTN.xml").
          end.
          when 'WayBill_v2' then do:
            cmd = substitute ("&1 --connect-timeout 1 -F xml_file=@&2 &3/opt/in/WayBill_v2 >&4", search ("exe/curl.exe"), search (inFileName), ConPar, "RespTTN.xml").
          end.
          end case.
          
          os-command value (cmd).
          file-info:file-name = search ("RespTTN.xml").
          if search ("RespTTN.xml") <> ? and file-info:file-size > 0
            then
          do:
            respValue = ParseRequest ("RespTTN.xml").
            if respValue = ?
              then
            do:
              assign
                StatusErr = true
                Msg       = "Не удалось разобрать данные от УТМ"
                .
              undo, return false.
            end.
            if not StatusErr
              then
              ReplyId = respValue:node-value.
            else
            do:
              assign
                StatusErr = true
                Msg       = respValue:node-value
                .
              undo, return false.
            end.
          end.
          else
          do:
            assign
              StatusErr = true
              Msg       = "Не удалось отправить накладную в УТМ"
              .
            undo, return false.
          end.
          find first buf_ext-classif no-lock where 
                buf_ext-classif.classif-name = {&extclass_egais-transId}
            and buf_ext-classif.db-num = 0
            and buf_ext-classif.key#_one = v-ext-sys
            and buf_ext-classif.CharKey_One = tt-wb-header.Identity
            and buf_ext-classif.CharKey_Two = ReplyId no-error.
          if not available (buf_ext-classif)
          then do:
            create buf_ext-classif.
            assign
              buf_ext-classif.classif-name = {&extclass_egais-transId}
              buf_ext-classif.db-num = 0
              buf_ext-classif.key#_one = v-ext-sys
              buf_ext-classif.CharKey_One = tt-wb-header.Identity
              buf_ext-classif.CharKey_Two = ReplyId 
            no-error.
          end.
        end.
      end.
      else do: 
        assign
          StatusErr = true
          Msg       = "Не найдена clob-bind по ключу - " + tt-wb-header.uniq-key-rec
          .
        return false.
      end.
    end.      
  end.
  
  method public logical SendWBActRejUTM (inWbRegId as char):
    
    def var VerXSDShip   as character no-undo.
    def var respValue as handle no-undo.
    
    os-delete "RespTTNAct.xml".
    os-delete value (search ("RespTTNAct.xml")).
    assign
      inFileName = "RespTTNAct.xml"
      .
      
    find first tt-wb-header.
      
    find first buf_ext-classif-attr no-lock where buf_ext-classif-attr.classif-subject = {&table_clients}
      and buf_ext-classif-attr.classif-name = {&extclass_clients_esys}
      and buf_ext-classif-attr.db-num = 0
      and buf_ext-classif-attr.key#_one = v-ext-sys
      and buf_ext-classif-attr.CharKey_Three = tt-wb-header.regID-Ship
      and buf_ext-classif-attr.attr-code = "egais-cli-info" no-error.
    if available (buf_ext-classif-attr)
    then 
      assign 
        VerXSDShip = entry (1, buf_ext-classif-attr.attr-value, chr(4))
      no-error.
    else VerXSDShip = 'WayBill'.
    output stream outstr close.
    output stream outstr to value ("TTNAct.xml") convert target "UTF-8". 

    case tt-wb-header.verXSD:
    when "WayBill_v2"
    then
      outData = substitute ({&xml-act-v2-1}, v-FS-RAR, 'Rejected', time, iso-date (date (now)), inWbRegId, "Отказ") + {&xml-act-v2-2}.
    when "WayBill"
    then
      outData = substitute ({&xml-act-1}, v-FS-RAR, 'Rejected', time, iso-date (date (now)), inWbRegId, "Отказ") + {&xml-act-2}.
    end case.


    if outData = ? or outData = ""
    then do:
      output stream outstr close.
      return false.
    end.
    
    put stream outstr unformatted outData.
    put stream outstr skip.
    output stream outstr close.
  
    case tt-wb-header.verXSD:
      when "WayBill" 
        then cmd = substitute ("&1 --connect-timeout 1 -F xml_file=@&2 &3/opt/in/WayBillAct >&4", search ("exe/curl.exe"), search ("TTNAct.xml"), ConPar, inFileName).
      when "WayBill_v2" 
        then cmd = substitute ("&1 --connect-timeout 1 -F xml_file=@&2 &3/opt/in/WayBillAct_v2 >&4", search ("exe/curl.exe"), search ("TTNAct.xml"), ConPar, inFileName).  
    end case.
    os-command value (cmd).
  
    file-info:file-name = search (inFileName).
    if search (inFileName) <> ? and file-info:file-size > 0 
      then 
    do:
      respValue = ParseRequest (inFileName).
      if respValue = ? 
        then 
      do:
        assign
          StatusErr = true
          Msg       = "Не удалось разобрать данные от УТМ"
          .
        undo, return false. 
      end.
      if not StatusErr 
        then 
        ReplyId = respValue:node-value.
      else 
      do:
        assign
          StatusErr = true
          Msg       = respValue:node-value
          .
        undo, return false. 
      end.
    end.
    else 
    do:
      assign
        StatusErr = true
        Msg       = "Не удалось отправить отказ на накладную в УТМ"
        .
      undo, return false.
    end.

    find first buf_ext-classif no-lock where 
          buf_ext-classif.classif-name = {&extclass_egais-transId}
      and buf_ext-classif.db-num = 0
      and buf_ext-classif.key#_one = v-ext-sys
      and buf_ext-classif.CharKey_One = tt-wb-header.Identity
      and buf_ext-classif.CharKey_Two = ReplyId no-error.
    if not available (buf_ext-classif)
    then do:
      create buf_ext-classif.
      assign
        buf_ext-classif.classif-name = {&extclass_egais-transId}
        buf_ext-classif.db-num = 0
        buf_ext-classif.key#_one = v-ext-sys
        buf_ext-classif.CharKey_One = tt-wb-header.Identity
        buf_ext-classif.CharKey_Two = ReplyId 
      no-error.
    end.   
    
  end.
  
  method public logical SendReqRepealWBUTM (inWbRegId as char):
    
    def var VerXSDShip   as character no-undo.
    def var respValue as handle no-undo.
    
    os-delete "RespRequestRepealWB.xml".
    os-delete value (search ("RespRequestRepealWB.xml")).
    assign
      inFileName = "RespRequestRepealWB.xml"
      .
    output stream outstr close.
    find first tt-wb-header.
      
    output stream outstr to value ("RequestRepealWB.xml") convert target "UTF-8". 

    outData = substitute ({&xml-ReqRepealWB}, v-FS-RAR, v-FS-RAR, tt-wb-header.num + "-" + string (time), iso-date (now), tt-wb-header.wbregid).

    if outData = ? or outData = ""
    then do:
      output stream outstr close.
      return false.
    end.
    
    put stream outstr unformatted outData.
    put stream outstr skip.
    output stream outstr close.
  
    cmd = substitute ("&1 --connect-timeout 1 -F xml_file=@&2 &3/opt/in/RequestRepealWB >&4", search ("exe/curl.exe"), search ("RequestRepealWB.xml"), ConPar, inFileName).
    os-command value (cmd).
  
    file-info:file-name = search (inFileName).
    if search (inFileName) <> ? and file-info:file-size > 0 
      then 
    do:
      respValue = ParseRequest (inFileName).
      if respValue = ? 
        then 
      do:
        assign
          StatusErr = true
          Msg       = "Не удалось разобрать данные от УТМ"
          .
        undo, return false. 
      end.
      if not StatusErr 
        then 
        ReplyId = respValue:node-value.
      else 
      do:
        assign
          StatusErr = true
          Msg       = respValue:node-value
          .
        undo, return false. 
      end.
    end.
    else 
    do:
      assign
        StatusErr = true
        Msg       = "Не удалось отправить запрос в УТМ на отмену проведения накладной"
        .
      undo, return false.
    end.

    find first buf_ext-classif no-lock where 
          buf_ext-classif.classif-name = {&extclass_egais-transId}
      and buf_ext-classif.db-num = 0
      and buf_ext-classif.key#_one = v-ext-sys
      and buf_ext-classif.CharKey_One = tt-wb-header.wbregid
      and buf_ext-classif.CharKey_Two = ReplyId no-error.
    if not available (buf_ext-classif)
    then do:
      create buf_ext-classif.
      assign
        buf_ext-classif.classif-name = {&extclass_egais-transId}
        buf_ext-classif.db-num = 0
        buf_ext-classif.key#_one = v-ext-sys
        buf_ext-classif.CharKey_One = tt-wb-header.wbregid
        buf_ext-classif.CharKey_Two = ReplyId 
      no-error.
    end.   
    
  end.

  method public logical ConfirmRepealWB (inWbRegId as char, inIsConfirm as char):
    
    def var respValue as handle no-undo.
    
    os-delete "RespConfirmRepealWB.xml".
    os-delete value (search ("RespConfirmRepealWB.xml")).
    assign
      inFileName = "RespConfirmRepealWB.xml"
      .
    output stream outstr close.
    find first tt-wb-header.
      
    output stream outstr to value ("ConfirmRepealWB.xml") convert target "UTF-8". 

    outData = substitute ({&xml-ConfirmRepealWB}, v-FS-RAR, inIsConfirm, tt-wb-header.num + "-" + string (time), iso-date (date(now)), inWbRegId).

    if outData = ? or outData = ""
    then do:
      output stream outstr close.
      return false.
    end.
    
    put stream outstr unformatted outData.
    put stream outstr skip.
    output stream outstr close.

    cmd = substitute ("&1 --connect-timeout 1 -F xml_file=@&2 &3/opt/in/ConfirmRepealWB >&4", search ("exe/curl.exe"), search ("ConfirmRepealWB.xml"), ConPar, inFileName).
    os-command value (cmd).
  
    file-info:file-name = search (inFileName).
    if search (inFileName) <> ? and file-info:file-size > 0 
      then 
    do:
      respValue = ParseRequest (inFileName).
      if respValue = ? 
        then 
      do:
        assign
          StatusErr = true
          Msg       = "Не удалось разобрать данные от УТМ"
          .
        undo, return false. 
      end.
      if not StatusErr 
        then 
        ReplyId = respValue:node-value.
      else 
      do:
        assign
          StatusErr = true
          Msg       = respValue:node-value
          .
        undo, return false. 
      end.
    end.
    else 
    do:
      assign
        StatusErr = true
        Msg       = "Не удалось отправить подт./отказ в УТМ на запрос распроведения накладной"
        .
      undo, return false.
    end.

    find first buf_ext-classif no-lock where 
          buf_ext-classif.classif-name = {&extclass_egais-transId}
      and buf_ext-classif.db-num = 0
      and buf_ext-classif.key#_one = v-ext-sys
      and buf_ext-classif.CharKey_One = tt-wb-header.wbregid
      and buf_ext-classif.CharKey_Two = ReplyId no-error.
    if not available (buf_ext-classif)
    then do:
      create buf_ext-classif.
      assign
        buf_ext-classif.classif-name = {&extclass_egais-transId}
        buf_ext-classif.db-num = 0
        buf_ext-classif.key#_one = v-ext-sys
        buf_ext-classif.CharKey_One = tt-wb-header.wbregid
        buf_ext-classif.CharKey_Two = ReplyId 
      no-error.
    end.   
    
  end.

  method override protected logical GetIsSent ():
    def var repId as char no-undo.
    def var glog  as log  no-undo.
    /*glog = CheckCurrentRequest (3, parameters, repId).
    if glog
      then ReplyId = repId.
    return glog.*/
  end.

  method protected handle ParseRequest (inFileName as char):
    
    define variable hRoot as handle  no-undo.
    define variable hDoc  as handle  no-undo.
    define variable hRow  as handle  no-undo.
    define variable hText as handle  no-undo.
    define variable ii    as integer no-undo.
    
    create x-document hDoc.
    create x-noderef  hRoot.
    create x-noderef  hRow.
    create x-noderef htext .
    
    hDoc:load ("file", inFileName, false).
    hDoc:encoding = "UTF-8".
    hDoc:get-document-element(hRoot) .
    
    do ii = 1 to hRoot:num-children:
      hRoot:get-child(hRow,ii).
      case hRow:name:
        when "url" then
          do:
            hRow:get-child (hText, 1) no-error.
            return hText.
          end.
        when "error" then
          do:
            hRow:get-child (hText, 1) no-error.
            StatusErr = true.
            return hText.
          end.
        otherwise 
        do:
          return ?.
        end.
      end case.
    end.


  end.
  
  method public void GetDocUTM ():
    
    output stream str-formF1 close.
    output stream str-formF1 to "loWBgFormF1.txt" append.
    
    GetDocUTMPrivat ().
    
    output stream str-formF1 close.
    
    if valid-object (prgObj)
      then do:
        prgObj:hide-bar().
        delete object prgObj.
      end.
    
  end.
  
  method private void GetDocUTMPrivat ():
    
    define variable hRoot         as handle    no-undo.
    define variable hDoc          as handle    no-undo.
    define variable hRow          as handle    no-undo.
    define variable hText         as handle    no-undo.
    define variable ii            as integer   no-undo.
    define variable jj            as integer   no-undo.
    define variable ListOfQuery   as longchar  no-undo.
    
    define variable v-part-num    as integer   no-undo.
    define variable v-clob-db-num as integer   no-undo.
    define variable v-int64-id    as int64     no-undo.
    define variable v-info        as character no-undo.
    define variable ticketUKR     as character no-undo.
    define variable urlStr        as character no-undo.
    define variable extFormF1Obj  as class     ExtFormF1 no-undo .
    define variable extFormF1ValueObj as class ExtFormF1Value no-undo .
    define variable egaisFormF1 as class FormF1 no-undo.
    create x-document hDoc.
    create x-noderef  hRoot.
    create x-noderef  hRow.
    create x-noderef  hText.

    empty temp-table tt-analiz.
    
    assign
      inFileName = "ReceiptListOfQuery.xml"
      .
    if search ("ReceiptListOfQuery.xml") <> ? then os-delete value (inFileName).
    if search (inFileName) <> ? then os-delete value (inFileName).
    
    
    if FastDwnl then do:
      if search ( v-FS-RAR + '_ReceiptListOfQuery.xml' ) <> ?
      then do:
        copy-lob 
          from  file v-FS-RAR + '_ReceiptListOfQuery.xml'
          to  object ListOfQuery
          no-convert
          no-error .
      end.
    end.
    
    cmd = substitute ("&1 --connect-timeout &2 -X GET &3/opt/out?refresh=true >&4",search ("exe/curl.exe"), TimeOut, ConPar, inFileName).
    os-command value (cmd).
       
    file-info:file-name = search (inFileName).
    if search (inFileName) = ? or file-info:file-size = 0 
      then 
    do:
      assign
        StatusErr = true
        Msg       = "Не удалось получить данные от УТМ"
        .
      return.
    end.
    hDoc:load ("file", inFileName, false).
    hDoc:get-document-element(hRoot) .
    
    prgObj = new ProgressBar (1, integer (hRoot:num-children / 2)).
    prgObj:can-cancel = true.
    prgObj:show-bar().
    
    url_:
    do ii = 1 to hRoot:num-children:
      
      hRoot:get-child(hRow,ii).

      case hRow:name:
        when "url" then
          do:
            
            hRow:get-child (hText, 1) no-error.
            
            urlStr = hText:node-value.

            prgObj:increment( substring (urlStr, if length (urlStr) <= 50 then 1 else length (urlStr) - 50)). 
            if prgObj:is-canceled 
              then return.

            if FastDwnl then 
            do:
              if ListOfQuery <> ? and ListOfQuery <> "" and index (ListOfQuery, urlStr) > 0 
                then next url_.
            end.
       
            case true:
              when urlStr matches ("*opt/out/WayBill/*") or urlStr matches ("*opt/out/WayBill_v2/*") then 
                do:

                  os-delete "WayBill.xml".
                  os-delete value (search ("WayBill.xml")).
                  assign
                    inFileName = "WayBill.xml"
                    .  
                  CmdParseXml(urlStr).
                  if StatusErr
                  then do:
                    message "Ошибка приема файла накланой: " v-info skip urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    Msg = "".
                    next url_.
                  end.
                  create tt-analiz.
                  assign
                    tt-analiz.url_ = urlStr
                    tt-analiz.num = tt-wb-header.num
                    tt-analiz.wb-date = tt-wb-header.wb-date
                    tt-analiz.Identity = tt-wb-header.Identity
                    tt-analiz.wb-type = "накл"
                    tt-analiz.uniq-key-rec = tt-wb-header.num + {&delim-cmd} + string (tt-wb-header.wb-date) + {&delim-cmd} + tt-wb-header.regID-Ship + {&delim-cmd} + tt-wb-header.Identity
                    tt-analiz.nnOrder = ii
                    tt-analiz.resource-type = {&lob-egais-wb}
                  .
                  
                  find first buf_tt-analiz where recid (buf_tt-analiz) <> recid (tt-analiz)
                    and buf_tt-analiz.wb-type = tt-analiz.wb-type
                    and buf_tt-analiz.uniq-key-rec = tt-analiz.uniq-key-rec no-error.
                  if available (buf_tt-analiz)
                  then do:
                    buf_tt-analiz.isMany = true.
                    tt-analiz.isMany = true.
                  end.
                  
                  find first tt-wb-header no-error.
                  if not available (tt-wb-header)
                  then do:
                    message "Ошибка приема файла накланой: " v-info skip urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    Msg = "".
                    next url_.
                  end.
                  find first tt-wb-info-client where tt-wb-info-client.wb-type-client = "Consignee".
                  for each buf_ext-classif no-lock where 
                        buf_ext-classif.classif-subject = {&table_clients}
                    and buf_ext-classif.classif-name = {&extclass_clients_esys}
                    and buf_ext-classif.db-num = 0
                    and buf_ext-classif.key#_one = v-ext-sys
                    and buf_ext-classif.CharKey_Three = tt-wb-info-client.regID:

                    if available (buf_ext-classif) then 
                    do:
                      tt-wb-header.obj-type = entry(2, buf_ext-classif.uniq-key-rec, {&delim-key}).
                      tt-wb-header.obj-code = integer(entry(3, buf_ext-classif.uniq-key-rec, {&delim-key})).
                    end.
                    find first buf_clients no-lock where buf_clients.obj-type = tt-wb-header.obj-type and buf_clients.obj-code = tt-wb-header.obj-code and buf_clients.db-num = DbNum no-error.
                    if available (buf_clients)
                      then leave.
                  end.
                  
                  if not available (buf_clients)
                    then 
                      assign
                        tt-wb-header.obj-type = ""
                        tt-wb-header.obj-code = 0
                      . 
                  
                  find first tt-wb-info-client where tt-wb-info-client.wb-type-client = "Shipper".                
                  v-info = string (tt-wb-header.wb-date) + {&delim-par} + tt-wb-header.num + {&delim-par} + tt-wb-info-client.regID + {&delim-par} + tt-wb-header.Identity + {&delim-par} + tt-wb-header.wbregid + {&delim-par} + "нет" + {&delim-par} + "нет" + {&delim-par} + tt-wb-header.wb-type + {&delim-par} + tt-wb-header.obj-type + if tt-wb-header.obj-code = 0 or tt-wb-header.obj-code = ? then "" else string (tt-wb-header.obj-code).
                  if tt-wb-header.uniq-key-rec = ?
                  then do:
                    message "Ошибка приема файла накладной: " v-info skip urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    Msg = "".
                    next url_.
                  end.
                  v-clob-db-num = ?.
                  v-int64-id = 0.
                  if can-find (first buf_clob-bind where (buf_clob-bind.uniq-key-rec = tt-wb-header.uniq-key-rec or buf_clob-bind.uniq-key-rec = tt-wb-header.Identity + {&delim-cmd} + tt-wb-header.regID-Ship) and buf_clob-bind.resource-type =  {&lob-egais-wb})
                    then next url_.
                  run gbl/file2clb.p ( input {&add-def}
                    ,input ",yes"
                    ,input ? /*p-bh*/
                    ,input tt-wb-header.uniq-key-rec /*p-uniq-key-rec*/
                    ,input {&lob-egais-wb} /*p-field-*/
                    ,input v-info /*p-descr*/
                    ,input-output v-part-num
                    ,input {&lob-egais-wb}
                    ,input-output v-clob-db-num
                    ,input-output v-int64-id
                    ,input search (inFileName)
                    ,input '' /*p-src-encoding*/
                    ) no-error .

                  if error-status:error then 
                  do:
                    Msg = error-status:get-message(1) + {&new-line} + return-value.
                    StatusErr = false.
                    next url_.
                  end.
                  extFormF1Obj = new ExtFormF1 (true).
                  
                  for each tt-wb-gds-EG no-lock where tt-wb-gds-EG.importer-list <> "" and tt-wb-gds-EG.importer-list <> chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5):
                    put stream str-formF1 "----" now "-----" {&new-line}.
                    export stream str-formF1 tt-wb-gds-EG.
                    ExtFormF1Obj:OpenQueryExtFormF1 (tt-wb-gds-EG.refA, tt-wb-gds-EG.alc-code).
                    if extFormF1Obj:NumBundles > 0
                    then do:
                      extFormF1ValueObj = extFormF1Obj:GetExtFormF1Value().
                      if extFormF1ValueObj:INNOrigCli <> ""
                        then next.
                    end.
                    else do:
                      ExtFormF1Obj:CreateExtFormF1(tt-wb-gds-EG.refA, tt-wb-gds-EG.alc-code).
                    end.
                    find first ub.esys-all-attr where ub.esys-all-attr.key2 = 7 and esys-all-attr.key3 = "no" and ub.esys-all-attr.attr-value matches substitute ("*&1*", tt-wb-gds-EG.refA) no-error.
                    if available (ub.esys-all-attr)
                      then next.
                    egaisFormF1 = new FormF1 (ObjType, ObjCode, v-fs-rar, tt-wb-gds-EG.refA).
                    egaisFormF1:DbNum = DbNum.
                    egaisFormF1:User_Id = User_Id.
                    egaisFormF1:SendRequestUTM() .
                    if egaisFormF1:StatusErr then do:
                        put stream str-formF1 unformatted egaisFormF1:Msg {&new-line}.
                    end.
                    delete object egaisFormF1.
                  end.


                end.
              when urlStr matches ("*opt/out/FORMBREGINFO/*") or urlStr matches ("*opt/out/FORM2REGINFO/*") then 
                do:

                  os-delete "FORMBREGINFO.xml".
                  os-delete value (search ("FORMBREGINFO.xml")).
                  assign
                    inFileName = "FORMBREGINFO.xml"
                    .

                  CmdParseXml(urlStr).
                  
                  if StatusErr
                  then do:
                    message "Ошибка приема файла справки Б: " tt-wb-header.wbregid skip urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    Msg = "".
                    next url_.
                  end.
                  find first tt-wb-header no-error.
                  if not available (tt-wb-header)
                  then do:
                    message "Ошибка приема файла справки Б: " tt-wb-header.wbregid skip urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    Msg = "".
                    next url_.
                  end.
                  v-clob-db-num = ?.
                  v-int64-id = 0.
                  
                  create tt-analiz.
                  assign
                    tt-analiz.url_ = urlStr
                    tt-analiz.num = tt-wb-header.num
                    tt-analiz.wb-date = tt-wb-header.wb-date
                    tt-analiz.Identity = tt-wb-header.Identity
                    tt-analiz.wbregid = tt-wb-header.wbregid
                    tt-analiz.wb-type = "спр."
                    tt-analiz.uniq-key-rec = tt-wb-header.num + {&delim-cmd} + string (tt-wb-header.wb-date) + {&delim-cmd} + tt-wb-header.regID-Ship + {&delim-cmd} + tt-wb-header.Identity
                    tt-analiz.nnOrder = ii
                    tt-analiz.resource-type = {&lob-egais-ref-b}
                  .
                  
                  find first buf_tt-analiz where recid (buf_tt-analiz) <> recid (tt-analiz)
                    and buf_tt-analiz.wb-type = tt-analiz.wb-type
                    and buf_tt-analiz.uniq-key-rec = tt-analiz.uniq-key-rec no-error.
                  if available (buf_tt-analiz)
                  then do:
                    buf_tt-analiz.isMany = true.
                    tt-analiz.isMany = true.
                  end.
                  
                  find first ub.clob-bind no-lock where ub.clob-bind.resource-type = {&lob-egais-wb} and ub.clob-bind.uniq-key-rec = tt-wb-header.uniq-key-rec no-error.
                  
                  if available (ub.clob-bind) and num-entries ( ub.clob-bind.descr, {&delim-par}) > 4
                  then do:
                    if entry (5, ub.clob-bind.descr, {&delim-par}) = ? or entry (5, ub.clob-bind.descr, {&delim-par}) = ""
                    then do:
                      if locked (ub.clob-bind)
                      then do:
                        message "Запись заблокирована - " ub.clob-bind.uniq-key-rec  " Пропускается. В следющий раз будет попытка опять загрузить" view-as alert-box.
                        next url_.
                      end.
                      else do:
                        find current ub.clob-bind exclusive-lock no-error.
                        if available (ub.clob-bind)
                        then do:
                          entry (5, ub.clob-bind.descr, {&delim-par}) = tt-wb-header.wbregid.
                        end.
                      end.
                      release ub.clob-bind.
                    end.
                    else do:
                      if entry (5, ub.clob-bind.descr, {&delim-par}) <> tt-wb-header.wbregid and not available (buf_tt-analiz)
                      then do:
                        jj_:
                        do jj = 1 to 100:
                          if not can-find (first buf_clob-bind where ub.clob-bind.uniq-key-rec = tt-wb-header.uniq-key-rec + "#" + string (jj) )
                            then leave jj_.
                        end.
                        if jj = 101 then do:
                          message "Ошибка приема файла справки Б: " tt-wb-header.wbregid skip urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                          StatusErr = false.
                          Msg = "".
                        end.
                        else do:
                          for each ub.clob-bind exclusive-lock where ub.clob-bind.uniq-key-rec = tt-wb-header.uniq-key-rec:
                            ub.clob-bind.uniq-key-rec = ub.clob-bind.uniq-key-rec + "#" + string (jj).
                          end.
                        end.                        
                      end.
                    end.
                  end.
                  
                  if can-find (first buf_clob-bind where (buf_clob-bind.uniq-key-rec = tt-wb-header.uniq-key-rec or buf_clob-bind.uniq-key-rec = tt-wb-header.Identity + {&delim-cmd} + tt-wb-header.regID-Ship) and buf_clob-bind.resource-type =  {&lob-egais-ref-b})
                    then next url_.
                  if tt-wb-header.uniq-key-rec = ?
                  then do:
                    message "Ошибка приема файла справки Б: " tt-wb-header.wbregid skip urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    Msg = "".
                    next url_.
                  end.
                  run gbl/file2clb.p ( input {&add-def}
                    ,input ",yes"
                    ,input ? /*p-bh*/
                    ,input tt-wb-header.uniq-key-rec /*p-uniq-key-rec*/
                    ,input {&lob-egais-ref-b} /*p-field-*/
                    ,input '' /*p-descr*/
                    ,input-output v-part-num
                    ,input {&lob-egais-ref-b}
                    ,input-output v-clob-db-num
                    ,input-output v-int64-id
                    ,input search (inFileName)
                    ,input '' /*p-src-encoding*/
                    ) no-error .
                  if error-status:error then 
                  do:
                    Msg = error-status:get-message(1) + {&new-line} + return-value.
                    StatusErr = false.
                    next url_.
                  end.
  
                end.

              when urlStr matches ("*opt/out/WayBillAct/*") or urlStr matches ("*opt/out/WayBillAct_v2/*") then 
                do:
  
                  os-delete "WayBillAct.xml".
                  os-delete value (search ("WayBillAct.xml")).
                  assign
                    inFileName = "WayBillAct.xml"
                    .
                  CmdParseXml(urlStr).
                  if StatusErr
                  then do:
                    message "Ошибка приема файла акта " skip urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    Msg = "".
                    next url_.
                  end.
                  find first tt-wb-act-header.
                  v-clob-db-num = ?.
                  v-int64-id = 0.
                  v-info = tt-wb-act-header.wbregid + {&delim-par} + string (tt-wb-act-header.act-date) + {&delim-par} + tt-wb-act-header.num + {&delim-par} + tt-wb-act-header.status_ + {&delim-par} + prsXMLDocWB:FromFSRAR.
                  if can-find (first buf_clob-bind where buf_clob-bind.uniq-key-rec = tt-wb-act-header.wbregid and buf_clob-bind.resource-type =  {&lob-egais-wb-act})
                    then next url_.
                  if tt-wb-act-header.wbregid = ?
                  then do:
                    message "Ошибка приема файла акта " skip urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    Msg = "".
                    next url_.
                  end.
                  run gbl/file2clb.p ( input {&add-def}
                    ,input ",yes"
                    ,input ? /*p-bh*/
                    ,input tt-wb-act-header.wbregid /*p-uniq-key-rec*/
                    ,input {&lob-egais-wb-act} /*p-field-*/
                    ,input v-info /*p-descr*/
                    ,input-output v-part-num
                    ,input {&lob-egais-wb-act}
                    ,input-output v-clob-db-num
                    ,input-output v-int64-id
                    ,input search (inFileName)
                    ,input '' /*p-src-encoding*/
                    ) no-error .
                  if error-status:error then 
                  do:
                    Msg = error-status:get-message(1) + {&new-line} + return-value.
                    StatusErr = false.
                    next url_.
                  end.
                  find first ub.doc-attr where ub.doc-attr.attr-code = {&trdcattr-negais} and ub.doc-attr.attr-value = tt-wb-act-header.wbregid no-error.
                  if available (ub.doc-attr)
                  then do:
                    find first buf_doc-attr exclusive-lock where buf_doc-attr.doc-code = ub.doc-attr.doc-code and buf_doc-attr.attr-code = {&trdcattr-egais} no-error.
                    if not available (buf_doc-attr)
                    then do:
                      create buf_doc-attr.
                      assign 
                        buf_doc-attr.doc-code = ub.doc-attr.doc-code
                        buf_doc-attr.attr-code = {&trdcattr-egais}
                      .
                    end.
                    assign
                      buf_doc-attr.attr-value = tt-wb-act-header.status_.
                    release buf_doc-attr.
                  end.
                end.
              when urlStr matches ("*opt/out/WayBillTicket/*") then 
                do:
                  empty temp-table tt-ticket.  
                  os-delete "WayBillTicket.xml".
                  os-delete value (search ("WayBillTicket.xml")).
                  assign
                    inFileName = "WayBillTicket.xml"
                    .
                  CmdParseXml(urlStr).
                  if StatusErr
                  then do:
                    message "Ошибка приема файла квитанции накладной" urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    Msg = "".
                    next url_.
                  end.
                  find first tt-ticket no-error.
                  if not available (tt-ticket)
                  then do:
                    Msg = error-status:get-message(1) + {&new-line} + return-value.
                    message "Ошибка приема файла квитанции накладной" urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    next url_.
                  end.
                  if (tt-ticket.regid = "" or tt-ticket.regid = ?) or tt-ticket.doc <> 'ConfirmTicket' then do:
                    next url_.  
                  end.
                  v-clob-db-num = ?.
                  v-int64-id = 0.
                  ticketUKR = tt-ticket.regid + {&delim-par} + tt-ticket.docId + {&delim-par} + tt-ticket.Identity +  {&delim-par} + tt-ticket.ticket-date.
                  if ticketUKR = ? or StatusErr
                  then do:
                    message "Ошибка приема файла квитанции накладной" ticketUKR skip urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    Msg = "".
                    next url_.
                  end.
                  
                  find first ub.clob-bind where ub.clob-bind.resource-type = {&lob-egais-wb} and ((tt-ticket.regid <> "" and entry (5, ub.clob-bind.descr, {&delim-par}) = tt-ticket.regid) or lookup (tt-ticket.TransId, ub.clob-bind.field-name_) > 0) no-error.
                  if available (ub.clob-bind)
                  then do:
                    if num-entries (ub.clob-bind.descr, {&delim-par}) < 10
                    then do:
                      ub.clob-bind.descr = ub.clob-bind.descr + {&delim-par}.
                    end.
                    if entry (10, ub.clob-bind.descr, {&delim-par}) <> tt-ticket.status_
                    then do:
                      entry (10, ub.clob-bind.descr, {&delim-par})  = tt-ticket.status_.
                    end.
                  end.
                  find first ub.doc-attr where ub.doc-attr.attr-code = {&trdcattr-negais} and ub.doc-attr.attr-value = tt-ticket.regid no-error.
                  if available (ub.doc-attr)
                  then do:
                    find first buf_doc-attr exclusive-lock where buf_doc-attr.doc-code = ub.doc-attr.doc-code and buf_doc-attr.attr-code = {&trdcattr-egais} no-error.
                    if not available (buf_doc-attr)
                    then do:
                      create buf_doc-attr.
                      assign 
                        buf_doc-attr.doc-code = ub.doc-attr.doc-code
                        buf_doc-attr.attr-code = {&trdcattr-egais}
                      .
                    end.
                    assign
                      buf_doc-attr.attr-value = tt-ticket.status_.
                    release buf_doc-attr.
                  end.

                  if can-find (first buf_clob-bind where 
                        (buf_clob-bind.uniq-key-rec = ticketUKR or (buf_clob-bind.uniq-key-rec = tt-ticket.regid + {&delim-par} + tt-ticket.docId and (tt-ticket.Identity = ? or tt-ticket.Identity = ""))) 
                    and buf_clob-bind.resource-type =  {&lob-egais-wb-ticket})
                    then next url_.
                  run gbl/file2clb.p ( input {&add-def}
                    ,input ",yes"
                    ,input ? /*p-bh*/
                    ,input ticketUKR /*p-uniq-key-rec*/
                    ,input {&lob-egais-wb-ticket} /*p-field-*/
                    ,input '' /*p-descr*/
                    ,input-output v-part-num
                    ,input {&lob-egais-wb-ticket}
                    ,input-output v-clob-db-num
                    ,input-output v-int64-id
                    ,input search (inFileName)
                    ,input '' /*p-src-encoding*/
                    ) no-error .
                  if error-status:error then 
                  do:
                    Msg = error-status:get-message(1) + {&new-line} + return-value.
                    StatusErr = false.
                    next url_.
                  end.
  
                end.
              when urlStr matches ("*opt/out/ConfirmRepealWB/*") then 
                do:
                  empty temp-table tt-ticket.  
                  os-delete "ConfirmRepealWB.xml".
                  os-delete value (search ("ConfirmRepealWB.xml")).
                  assign
                    inFileName = "ConfirmRepealWB.xml"
                    .
                  CmdParseXml(urlStr).
                  if StatusErr
                  then do:
                    message "Ошибка приема подтверждения распроведение накладной" urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    Msg = "".
                    next url_.
                  end.
                  find first tt-ticket no-error.
                  if not available (tt-ticket)
                  then do:
                    Msg = error-status:get-message(1) + {&new-line} + return-value.
                    message "Ошибка приема подтверждения распроведение накладной" urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    next url_.
                  end.
                  if (tt-ticket.regid = "" or tt-ticket.regid = ?) or tt-ticket.doc <> 'ConfirmRepealWB' then do:
                    next url_.  
                  end.
                  v-clob-db-num = ?.
                  v-int64-id = 0.
                  ticketUKR = tt-ticket.regid + {&delim-par} + tt-ticket.docId + {&delim-par} + tt-ticket.Identity +  {&delim-par} + tt-ticket.ticket-date.
                  if ticketUKR = ? or StatusErr
                  then do:
                    message "Ошибка приема подтверждения распроведение накладной" ticketUKR skip urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    Msg = "".
                    next url_.
                  end.
                  
                  find first ub.clob-bind where ub.clob-bind.resource-type = {&lob-egais-wb} and ((tt-ticket.regid <> "" and entry (5, ub.clob-bind.descr, {&delim-par}) = tt-ticket.regid) or lookup (tt-ticket.TransId, ub.clob-bind.field-name_) > 0) no-error.
                  if available (ub.clob-bind)
                  then do:
                    if num-entries (ub.clob-bind.descr, {&delim-par}) < 10
                    then do:
                      ub.clob-bind.descr = ub.clob-bind.descr + {&delim-par}.
                    end.
                    if  num-entries (ub.clob-bind.descr, {&delim-par}) > 9
                    then do:
                      assign 
                        entry (10, ub.clob-bind.descr, {&delim-par})  = "Распроведена" when tt-ticket.status_ = "Accepted"
                      .
                    end.
                  end.
                  find first ub.doc-attr where ub.doc-attr.attr-code = {&trdcattr-negais} and ub.doc-attr.attr-value = tt-ticket.regid no-error.
                  if available (ub.doc-attr)
                  then do:
                    find first buf_doc-attr exclusive-lock where buf_doc-attr.doc-code = ub.doc-attr.doc-code and buf_doc-attr.attr-code = {&trdcattr-egais} no-error.
                    if not available (buf_doc-attr)
                    then do:
                      create buf_doc-attr.
                      assign 
                        buf_doc-attr.doc-code = ub.doc-attr.doc-code
                        buf_doc-attr.attr-code = {&trdcattr-egais}
                      .
                    end.
                    assign
                      buf_doc-attr.attr-value = "Распроведена" when tt-ticket.status_ = "Accepted".
                    release buf_doc-attr.
                  end.
                  
                  if can-find (first buf_clob-bind where 
                        (buf_clob-bind.uniq-key-rec = ticketUKR or (buf_clob-bind.uniq-key-rec = tt-ticket.regid + {&delim-par} + tt-ticket.docId and (tt-ticket.Identity = ? or tt-ticket.Identity = ""))) 
                    and buf_clob-bind.resource-type =  {&lob-egais-ticket})
                    then next url_.
                  run gbl/file2clb.p ( input {&add-def}
                    ,input ",yes"
                    ,input ? /*p-bh*/
                    ,input ticketUKR /*p-uniq-key-rec*/
                    ,input {&lob-egais-wb-ticket} /*p-field-*/
                    ,input '' /*p-descr*/
                    ,input-output v-part-num
                    ,input {&lob-egais-wb-ticket}
                    ,input-output v-clob-db-num
                    ,input-output v-int64-id
                    ,input search (inFileName)
                    ,input '' /*p-src-encoding*/
                    ) no-error .
                  if error-status:error then 
                  do:
                    Msg = error-status:get-message(1) + {&new-line} + return-value.
                    StatusErr = false.
                    next url_.
                  end.
  
                end.
              when urlStr matches ("*opt/out/RequestRepealWB/*") then 
                do:
                  empty temp-table tt-ticket.  
                  os-delete "RequestRepealWB.xml".
                  os-delete value (search ("RequestRepealWB.xml")).
                  assign
                    inFileName = "ConfirmRepealWB.xml"
                    .
                  CmdParseXml(urlStr).
                  if StatusErr
                  then do:
                    message "Ошибка приема файла запроса на распроведение накладной" urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    Msg = "".
                    next url_.
                  end.
                  find first tt-ticket no-error.
                  if not available (tt-ticket)
                  then do:
                    Msg = error-status:get-message(1) + {&new-line} + return-value.
                    message "Ошибка приема файла запроса на распроведение накладной" urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    next url_.
                  end.
                  if (tt-ticket.regid = "" or tt-ticket.regid = ?) or tt-ticket.doc <> 'RequestRepealWB' then do:
                    next url_.  
                  end.
                  v-clob-db-num = ?.
                  v-int64-id = 0.
                  ticketUKR = tt-ticket.regid + {&delim-par} + tt-ticket.docId + {&delim-par} + tt-ticket.Identity +  {&delim-par} + tt-ticket.ticket-date.
                  if ticketUKR = ? or StatusErr
                  then do:
                    message "Ошибка приема файла запроса на распроведение накладной" ticketUKR skip urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    Msg = "".
                    next url_.
                  end.
                  
                  find first ub.doc-attr where ub.doc-attr.attr-code = {&trdcattr-negais} and ub.doc-attr.attr-value = tt-ticket.regid no-error.
                  if available (ub.doc-attr)
                  then do:
                    find first buf_doc-attr exclusive-lock where buf_doc-attr.doc-code = ub.doc-attr.doc-code and buf_doc-attr.attr-code = {&trdcattr-egais} no-error.
                    if not available (buf_doc-attr)
                    then do:
                      create buf_doc-attr.
                      assign 
                        buf_doc-attr.doc-code = ub.doc-attr.doc-code
                        buf_doc-attr.attr-code = {&trdcattr-egais}
                      .
                    end.
                    assign
                      buf_doc-attr.attr-value = "Распроведена" when tt-ticket.status_ = "Accepted".
                    release buf_doc-attr.
                  end.

                  if can-find (first buf_clob-bind where 
                        (buf_clob-bind.uniq-key-rec = ticketUKR or (buf_clob-bind.uniq-key-rec = tt-ticket.regid + {&delim-par} + tt-ticket.docId and (tt-ticket.Identity = ? or tt-ticket.Identity = ""))) 
                    and buf_clob-bind.resource-type =  {&lob-egais-ticket})
                    then next url_.
                  run gbl/file2clb.p ( input {&add-def}
                    ,input ",yes"
                    ,input ? /*p-bh*/
                    ,input ticketUKR /*p-uniq-key-rec*/
                    ,input {&lob-egais-wb-ticket} /*p-field-*/
                    ,input '' /*p-descr*/
                    ,input-output v-part-num
                    ,input {&lob-egais-wb-ticket}
                    ,input-output v-clob-db-num
                    ,input-output v-int64-id
                    ,input search (inFileName)
                    ,input '' /*p-src-encoding*/
                    ) no-error .
                  if error-status:error then 
                  do:
                    Msg = error-status:get-message(1) + {&new-line} + return-value.
                    StatusErr = false.
                    next url_.
                  end.
  
                end.
              when urlStr matches ("*opt/out/Ticket/*") then 
                do:
                  empty temp-table tt-ticket. 
                  os-delete "Ticket.xml".
                  os-delete value (search ("Ticket.xml")).
                  assign
                    inFileName = "Ticket.xml"
                    .
                  CmdParseXml(urlStr).
                  if StatusErr
                  then do:
                    message "Ошибка приема файла квитанции " urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    Msg = "".
                    next url_.
                  end.
                  find first tt-ticket no-error.
                  if not available (tt-ticket)
                  then do:
                    Msg = error-status:get-message(1) + {&new-line} + return-value.
                    message "Ошибка приема файла квитанции накладной" urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    next url_.
                  end.
                  
                  v-clob-db-num = ?.
                  v-int64-id = 0.
                  ticketUKR = tt-ticket.regid + {&delim-par} + tt-ticket.docId + {&delim-par} + tt-ticket.Identity +  {&delim-par} + tt-ticket.ticket-date.
                  if ticketUKR = ? or StatusErr
                  then do:
                    message "Ошибка приема файла квитанции " ticketUKR skip urlStr skip Msg skip " Прием документов будет продолжен" view-as alert-box.
                    StatusErr = false.
                    Msg = "".
                    next url_.
                  end.
                  
                  find first ub.clob-bind where 
                        ub.clob-bind.resource-type = {&lob-egais-wb} 
                    and ((tt-ticket.regid <> "" and entry (5, ub.clob-bind.descr, {&delim-par}) = tt-ticket.regid) or lookup (tt-ticket.TransId, ub.clob-bind.field-name_) > 0) no-error.
                  if available (ub.clob-bind)
                  then do:
                    if num-entries (ub.clob-bind.descr, {&delim-par}) < 10
                    then do:
                      ub.clob-bind.descr = ub.clob-bind.descr + {&delim-par}.
                    end.
                    if entry (10, ub.clob-bind.descr, {&delim-par}) <> "Accepted"
                    then do:
                      entry (10, ub.clob-bind.descr, {&delim-par})  = tt-ticket.status_.
                    end.
                  end.
                  if not (can-find (first buf_clob-bind where buf_clob-bind.resource-type = {&lob-egais-wb} and lookup (tt-ticket.TransId, buf_clob-bind.field-name_) > 0) 
                      or can-find (first buf_clob-bind where buf_clob-bind.field-name_ = tt-ticket.TransId)
                      or can-find (first buf_ext-classif where buf_ext-classif.classif-name = {&extclass_egais-transId}
                          and buf_ext-classif.db-num = 0
                          and buf_ext-classif.key#_one = v-ext-sys
                          and buf_ext-classif.CharKey_Two = tt-ticket.TransId))
                  then do:  
                    if (tt-ticket.regid = "" or tt-ticket.regid = ?) or (tt-ticket.doc <> 'WayBillAct' and tt-ticket.doc <> 'WAYBILL')  then do:
                      next url_.
                    end.  
                  end.
                  
                  if can-find (first buf_clob-bind where 
                        ((buf_clob-bind.uniq-key-rec = ticketUKR or (buf_clob-bind.uniq-key-rec = tt-ticket.regid + {&delim-par} + tt-ticket.docId and (tt-ticket.Identity = ? or tt-ticket.Identity = ""))) 
                    and buf_clob-bind.resource-type =  {&lob-egais-ticket}))
                    then next url_.
                  run gbl/file2clb.p ( input {&add-def}
                    ,input ",yes"
                    ,input ? /*p-bh*/
                    ,input ticketUKR /*p-uniq-key-rec*/
                    ,input tt-ticket.TransId /*p-field-*/
                    ,input '' /*p-descr*/
                    ,input-output v-part-num
                    ,input {&lob-egais-ticket}
                    ,input-output v-clob-db-num
                    ,input-output v-int64-id
                    ,input search (inFileName)
                    ,input '' /*p-src-encoding*/
                    ) no-error .
                  if error-status:error then 
                  do:
                    Msg = error-status:get-message(1) + {&new-line} + return-value.
                    StatusErr = false.
                    next url_.
                  end.
 
                  if tt-ticket.regid <> ""
                  then do:
                    find first buf_ext-classif where buf_ext-classif.classif-name = {&extclass_egais-transId}
                            and buf_ext-classif.db-num = 0
                            and buf_ext-classif.key#_one = v-ext-sys
                            and buf_ext-classif.CharKey_Two = tt-ticket.TransId no-error.
                    if available (buf_ext-classif) then do:
                    find first buf_doc-attr no-lock where buf_doc-attr.attr-code = {&trdcattr-negais} and buf_doc-attr.doc-code = buf_ext-classif.CharKey_One no-error.
                      if not available (buf_doc-attr)
                      then do:
                        create buf_doc-attr.
                        assign
                          buf_doc-attr.doc-code = buf_ext-classif.CharKey_One
                          buf_doc-attr.attr-value = tt-ticket.regid
                          buf_doc-attr.attr-code = {&trdcattr-negais}
                        .
                      end.
                    end.
                  end.
  
                end.
            end case.
            
          end.

      end case.
    end.
    
    os-copy value (search ('ReceiptListOfQuery.xml')) value (v-FS-RAR + '_ReceiptListOfQuery.xml').

    HndlAnaliz = buffer tt-analiz:handle.
    
    empty temp-table tt-wb-info-client.
    empty temp-table tt-wb-hndls.
    empty temp-table tt-wb-act-hndls.
    empty temp-table tt-wb-header.
    empty temp-table tt-wb-gds-EG.
    empty temp-table tt-wb-act-header.
    empty temp-table tt-wb-act-gds-EG.

  end.

  method private void createhDoc (inRecCD as recid, inFileName as char, output outhDoc as handle ):
    
    define buffer buf_cd for ub.clob-data.
    
    find first buf_cd where recid (buf_cd) = inRecCD no-lock.
    
    copy-lob
      from  object buf_cd.cdata
      to  file inFileName
      no-convert
      no-error .
    
    create x-document outhDoc.
    outhDoc:encoding = 'utf-8'.
    outhDoc:load("file", search (inFileName), false).
    
    release buf_cd.
    
  end.

  method private void createhDoc (inFileName as char, output outhDoc as handle ):
    
    create x-document outhDoc.
    outhDoc:encoding = 'utf-8'.
    outhDoc:load("file", search (inFileName), false).
    
  end.

  method override public void SaveWB (inWbIdentity as char):
    
    def var trn-doc-code as char no-undo.

    find first buf_clob-bind no-lock where buf_clob-bind.uniq-key-rec = inWbIdentity and buf_clob-bind.resource-type = {&lob-egais-wb} no-error.
    if not available (buf_clob-bind) then 
    do:
      Msg = "Не найдена накладная с идентификатором " + inWbIdentity.
      StatusErr = true.
      return.
    end.
    
    if can-find (first tt-wb-gds-EG where tt-wb-gds-EG.RefA = "" or tt-wb-gds-EG.RefB = "")
      then 
    do:
      Msg = "Не для всех товаров есть сравка A или B ".
      StatusErr = true.
      return.      
    end.
      
    do trans:
      run ibs/th/bge/egais/AdapteeEGAISProcOra-i516.p
        (
        input table tt-wb-header,
        input table tt-wb-gds-EG,
        input User_Id,
        input "",
        input-output trn-doc-code
        ) no-error.
      if error-status:error then 
      do:
        Msg = return-value.
        StatusErr = true.
        return.
      end.
      Msg = return-value.
      if Msg <> "" 
      then do:
        message Msg {&new-line} "Сохранить?" view-as alert-box 
          question buttons yes-no
          title "" update v-choise as logical.
        if not v-choise then do: 
          Msg = "Отменено пользователем".
          StatusErr = true.
          return. 
        end.
      end.
      find current buf_clob-bind exclusive-lock.
      entry (6, buf_clob-bind.descr, {&delim-par}) = trn-doc-code.
      find current buf_clob-bind no-lock.
    end.

    find first tt-wb-hndls where tt-wb-hndls.uniq-key-rec = buf_clob-bind.uniq-key-rec no-error.
    if not available (tt-wb-hndls)
    then do:
      Msg = "Непредвиденная ошибка." + buf_clob-bind.descr.
      StatusErr = true.
      return.
    end.
    release buf_clob-bind.
    find first buf_trn-doc where buf_trn-doc.doc-code = trn-doc-code no-error.
    tt-wb-hndls.trn-doc-code = trn-doc-code.
    if available (buf_trn-doc)
    then do:
      tt-wb-hndls.status_ = buf_trn-doc.status_ + if buf_trn-doc.flag_ then "+" else "-".
      tt-wb-hndls.isWB = true.
    end.
    release buf_trn-doc.
    
  end.

  method override public void RejectWB (inWbIdentity as char):
    
    do trans:
      find first buf_clob-bind exclusive-lock where buf_clob-bind.uniq-key-rec = inWbIdentity and buf_clob-bind.resource-type = {&lob-egais-wb} no-error.
      find current buf_clob-bind exclusive-lock.
      entry (6, buf_clob-bind.descr, {&delim-par}) = 'отказ'.
      find current buf_clob-bind no-lock.
      find first tt-wb-hndls where tt-wb-hndls.uniq-key-rec = buf_clob-bind.uniq-key-rec no-error.
      if not available (tt-wb-hndls)
      then do:
        Msg = "Непредвиденная ошибка. " + {&new-line} + buf_clob-bind.descr.
        StatusErr = true.
        undo, return.
      end.
      if not available (buf_clob-bind) then
      do:
        Msg = "Не найдена накладная с идентификатором " + inWbIdentity.
        StatusErr = true.
        undo, return.
      end.
      if not SendRequestUTM()
      then do:
        Msg = "Не удалось отправить отказ - " + inWbIdentity + {&new-line} + Msg.
        StatusErr = true.
        undo, return.
      end.
    end.
    tt-wb-hndls.trn-doc-code = 'отказ'.
    
  end.

  method override public void ConnWB (inWbIdentity as char, inTrnDoc as char):

    def buffer buf_tt-wb-gds-EG for tt-wb-gds-EG.
        
    def var isErr     as logical no-undo.
    def var isWarning as logical no-undo.
    def var ischoise  as logical no-undo.
    def var jj        as int     no-undo.
    def var ii        as int     no-undo.
    def var THSumm    as decimal no-undo.
    def var EGAISSumm as decimal no-undo.
    
    find first buf_clob-bind exclusive-lock where buf_clob-bind.uniq-key-rec = inWbIdentity and buf_clob-bind.resource-type = {&lob-egais-wb} no-error.
    if not available (buf_clob-bind) then
    do:
      Msg = "Не найдена накладная с идентификатором " + inWbIdentity.
      StatusErr = true.
      return.
    end.
    
    find first buf_trn-doc where buf_trn-doc.doc-code = entry (6, buf_clob-bind.descr, {&delim-par}) no-error.
    
    if entry (6, buf_clob-bind.descr, {&delim-par}) = 'отказ' or available (buf_trn-doc)
    then do:
      Msg = "Накладная уже связана или по ней был отказ.".
      message  Msg + " Вы уверены, что хотите связать накладную?" view-as alert-box question buttons yes-no
        title "" update isChoise.
      if not isChoise then do:
        StatusErr = true.
        return.
      end.
      if not ActnEGAISAdm
      then do:
        Msg = 'Для связывания нужно право "Администрирование запросов в ЕГАИС"'.
        StatusErr = true.
        return.
      end.
    end.
    
    find first buf_trn-doc no-lock where buf_trn-doc.doc-code = inTrnDoc no-error.
          
    if not available (buf_trn-doc)
    then do:
      Msg = "Не найдена накладная" + inTrnDoc.
      StatusErr = true.
      return.
    end.
    
    foreach1_:
    for each tt-wb-gds-EG break by gds-code:
      
      THSumm = 0.
      EGAISSumm = 0.
      ii = 0.
      jj = 0.
      
      
      if not first-of (gds-code) and last-of (gds-code) 
        then next foreach1_.
      
      find first buf_gds no-lock where buf_gds.gds-code = tt-wb-gds-EG.gds-code no-error.
      if not available (buf_gds) 
      then do:
        Msg = Msg + (if Msg <> "" then {&new-line} else '') + substitute ("Товар &1 &2 не имеет связки.", tt-wb-gds-EG.alc-code, tt-wb-gds-EG.gds-name).
        isErr = true.
      end.
      else do:
        for each ub.parts no-lock
          where 
                ub.parts.obj-code  = buf_trn-doc.obj-code
            and ub.parts.obj-type  = buf_trn-doc.obj-type
            and ub.parts.artic     = buf_gds.artic
            and ub.parts.prod-type = buf_gds.prod-type
            and ub.parts.prod-code = buf_gds.prod-code
            and ub.parts.out-code  = inTrnDoc:
          jj = jj + 1.
          THSumm = THSumm + ub.parts.fact-qnty / ub.parts.cli-base-rate.

          alcTypeAttrObj:GetAlcTypeAttr ( input tt-wb-gds-EG.alc-type-code,
                                   input   "alc-min-price",
                                   output  minPrice
                                ).
                                
          if ub.parts.price-rubl < minPrice or tt-wb-gds-EG.price < minPrice * ub.parts.cli-base-rate 
          then do:
          Msg = Msg + (if Msg <> "" then {&new-line} else '')
            + substitute ("Для товара &5/&1 &2 цена в накладной ЕГАИС или TH меньше допустимой &6 (мин. доп. в ед. поставщика &8) по группе &7. В накладной ЕГАИС цена - &3 в накладной TH цена - &4.", tt-wb-gds-EG.alc-code, tt-wb-gds-EG.gds-name, tt-wb-gds-EG.price, ub.parts.price-rubl, buf_gds.gds-code, minPrice, tt-wb-gds-EG.alc-type-code, minPrice * ub.parts.cli-base-rate).
          end.

        end.

        for each buf_tt-wb-gds-EG where buf_tt-wb-gds-EG.gds-code = buf_gds.gds-code:
          ii = ii + 1.
          EGAISSumm = EGAISSumm + buf_tt-wb-gds-EG.qnty.
        end.

        if EGAISSumm <> THSumm
        then do:
          isWarning = true.
          Msg = Msg + (if Msg <> "" then {&new-line} else '')
            + substitute ("Не совпадает документарное кол-во. Для товара &5/&1 &2 в накладной ЕГАИС кол-во по партиям - &3 в накладной TH кол-во по партиям - &4.", tt-wb-gds-EG.alc-code, tt-wb-gds-EG.gds-name, EGAISSumm, THSumm, buf_gds.gds-code).
        end.
        
        if ii <> jj
        then do:
          isWarning = true.
          Msg = Msg + (if Msg <> "" then {&new-line} else '')
            + substitute ("Для товара &5/&1 &2 в накладной ЕГАИС партий - &3 в накладной TH партий - &4.", tt-wb-gds-EG.alc-code, tt-wb-gds-EG.gds-name, ii, jj, buf_gds.gds-code).
          if jj = 0 
            then Msg = Msg + {&new-line}
              + substitute ("Для товара &1/&2 &3 при отправке накладной в ЕГАИС акт будет с расхождение и кол-во 0.", buf_gds.gds-code, tt-wb-gds-EG.alc-code, tt-wb-gds-EG.gds-name).
        end.
      end.
      
    end.

    for each ub.parts no-lock
      where
            ub.parts.out-code = inTrnDoc 
        and ub.parts.obj-code = buf_trn-doc.obj-code
        and ub.parts.obj-type = buf_trn-doc.obj-type
        :
      find first buf_gds no-lock where 
                ub.parts.artic     = buf_gds.artic
            and ub.parts.prod-type = buf_gds.prod-type
            and ub.parts.prod-code = buf_gds.prod-code.
      find first tt-wb-gds-EG no-lock where tt-wb-gds-EG.gds-code = buf_gds.gds-code no-error.
      if not available ( tt-wb-gds-EG ) 
      then do:
        isWarning = true.
        Msg = Msg + (if Msg <> "" then {&new-line} else '')
          + substitute ("Товара &1 &2 в накладной TH отсутствует в накладной ЕГАИС.", buf_gds.gds-code, buf_gds.gds-name).
      end.
    end.

    if isErr
    then do:
      StatusErr = true.
      return.
    end.
    
    output stream outstr close.
    output stream outstr to value ("warWBLog.txt").
    put stream outstr unformatted Msg.
    output stream outstr close.
    
    if isWarning 
    then do:
      message  Msg + {&new-line} + " Вы уверены, что хотите связать накладную?" view-as alert-box question buttons yes-no
        title "" update isChoise.
      if not isChoise then do:
        StatusErr = true.
        return.
      end.
      if not ActnEGAISAdm
      then do:
        Msg = 'Для связывания нужно право "Администрирование запросов в ЕГАИС"'.
        StatusErr = true.
        return.
      end.
    end.
    
    run ibs/th/bge/egais/AdapteeEGAISProcOra-i516.p
      (
      input table tt-wb-header,
      input table tt-wb-gds-EG,
      input User_Id,
      input "conn",
      input-output inTrnDoc
      ) no-error.
    if error-status:error then 
    do:
      Msg = return-value.
      StatusErr = true.
      return.
    end.
    find current buf_clob-bind exclusive-lock.
    entry (6, buf_clob-bind.descr, {&delim-par}) = inTrnDoc.
    find current buf_clob-bind no-lock.
    find first tt-wb-hndls where tt-wb-hndls.uniq-key-rec = buf_clob-bind.uniq-key-rec no-error.
    if not available (tt-wb-hndls)
    then do:
      Msg = "Непредвиденная ошибка." + buf_clob-bind.descr.
      StatusErr = true.
      return.
    end.
    tt-wb-hndls.trn-doc-code = inTrnDoc.
    
  end.

  method public logical SendForceAccept ():
    
    isForceAccept = true.
    if not SendRequestUTM()
    then do:
      StatusErr = true.
      return false.
    end.
    isForceAccept = false.
    return true.

  end.

  method public logical ReleaseTable_ ():
    
    release buf_clob-bind.
    release buf_clob-bind-temp.
    release buf_clob-bind-wb-hndls.
    release buf_clob-data.

  end.

  method private longchar GetXMLAct ():

    def var ii           as integer   no-undo.
    def var xml-cont     as longchar  no-undo.
    def var is-diff      as logical   no-undo.
    def var docCodeList  as character no-undo.
    def var VerXSDShip   as character no-undo.

&scop xml-act-cont '<wa:Position>~
<wa:Identity>&1</wa:Identity>~
<wa:InformBRegId>&2</wa:InformBRegId>~
<wa:RealQuantity>&3</wa:RealQuantity>~
</wa:Position>'

&scop xml-act-cont-v2 '<wa:Position>~
<wa:Identity>&1</wa:Identity>~
<wa:InformF2RegId>&2</wa:InformF2RegId>~
<wa:RealQuantity>&3</wa:RealQuantity>~
</wa:Position>'

    
    find first tt-wb-header.

    find first buf_ext-classif-attr no-lock where buf_ext-classif-attr.classif-subject = {&table_clients}
      and buf_ext-classif-attr.classif-name = {&extclass_clients_esys}
      and buf_ext-classif-attr.db-num = 0
      and buf_ext-classif-attr.key#_one = v-ext-sys
      and buf_ext-classif-attr.CharKey_Three = tt-wb-header.regID-Ship
      and buf_ext-classif-attr.attr-code = "egais-cli-info" no-error.
    if available (buf_ext-classif-attr)
    then 
      assign 
        VerXSDShip = entry (1, buf_ext-classif-attr.attr-value, chr(4))
      no-error.
    else VerXSDShip = 'WayBill'.

    if not (available (buf_clob-bind) and entry (6, buf_clob-bind.descr, {&delim-par}) = 'отказ') and not isForceAccept then do:
      
      docCodeList = "".
      for each buf_doc-attr no-lock where buf_doc-attr.attr-code = {&trdcattr-negais} and buf_doc-attr.attr-value begins (tt-wb-header.wbregid) :
        if can-find (first buf_trn-doc where buf_trn-doc.doc-code = buf_doc-attr.doc-code and 
              not (buf_trn-doc.status_ = {&fact}))
          then next.
        docCodeList = docCodeList + "," + buf_doc-attr.doc-code.
      end.
      
      docCodeList = left-trim (docCodeList, ',').

      if num-entries (docCodeList) > 1
      then do:
        Msg = substitute ("Несколько связанных накладных c одной накладной ЕГАИС wbregid - &1/&2. Для исправления пересвяжите накладную", tt-wb-header.wbregid, docCodeList) + {&new-line}.
        for each buf_doc-attr no-lock where buf_doc-attr.attr-code = {&trdcattr-negais} and buf_doc-attr.attr-value begins (tt-wb-header.wbregid):
          Msg = Msg + "Накладаная - " + buf_doc-attr.doc-code + {&new-line}.
        end.
        StatusErr = true.
        return ?.
      end.
      if docCodeList <> ""
      then do:
        find first buf_doc-attr no-lock where buf_doc-attr.attr-code = {&trdcattr-negais} and buf_doc-attr.doc-code = docCodeList no-error.
      end.
      
      if not available (buf_doc-attr)
      then do:
        Msg = substitute ("Не найден атрибут документа с номером ЕГАИС WBRegID - &1, пересвяжите накладную", tt-wb-header.wbregid).
        StatusErr = true.
        return ?. 
      end.
      foreach_:
      for each tt-wb-gds-EG :
        
        release buf_parts.
        release buf_gds.
        release buf_doc-line.
        
        find first buf_gds no-lock where buf_gds.gds-code = tt-wb-gds-EG.gds-code no-error.
        if available (buf_gds) then do:
          find first buf_parts where
            buf_parts.obj-type = tt-wb-header.obj-type and
            buf_parts.obj-code = tt-wb-header.obj-code and
            buf_parts.artic = buf_gds.artic and
            buf_parts.prod-type = buf_gds.prod-type and
            buf_parts.prod-code = buf_gds.prod-code and
            buf_parts.out-code = buf_doc-attr.doc-code and
            buf_parts.alc-ref-ab-path = tt-wb-gds-EG.refA + "," + tt-wb-gds-EG.refB + "," + tt-wb-gds-EG.alc-code + "," + tt-wb-gds-EG.alc-type-code no-lock no-error.
        end.
        
        if not available (buf_parts) then do:
        find first buf_parts where
            buf_parts.out-code = buf_doc-attr.doc-code and
            buf_parts.obj-type = tt-wb-header.obj-type and 
            buf_parts.obj-code = tt-wb-header.obj-code and
            buf_parts.alc-ref-ab-path = tt-wb-gds-EG.refA + "," + tt-wb-gds-EG.refB + "," + tt-wb-gds-EG.alc-code + "," + tt-wb-gds-EG.alc-type-code no-lock no-error.
        end.

        if not available (buf_parts) then do:
          find first buf_doc-line no-lock where available (buf_gds) and buf_doc-line.doc-code = buf_doc-attr.doc-code and
             buf_gds.artic = buf_doc-line.artic and buf_gds.prod-code = buf_doc-line.prod-code and buf_gds.prod-type = buf_doc-line.prod-type no-error.
          if not available (buf_doc-line) then do:
              message "Не найден товар в накладной, который есть в ЕГАИС - " + buf_doc-attr.doc-code + " товар - " + string (tt-wb-gds-EG.gds-code) + " Продолжить с отправкой для данного товара в акте кол-ва 0?" view-as alert-box 
                question buttons yes-no
                title "" update v-choise as logical.
              if not v-choise then do: 
                Msg = "Отменено пользователем".
                StatusErr = true.
                return ?. 
              end.
              is-diff = true.
              xml-cont = xml-cont + substitute ({&xml-act-cont}, string (tt-wb-gds-EG.Identity), tt-wb-gds-EG.refB, 0.0).
              next foreach_.
          end.
          else do:
  
              Msg = "Не найдена партия для товара " + string (tt-wb-gds-EG.gds-code) + "/" + tt-wb-gds-EG.alc-code + " справка А " + tt-wb-gds-EG.refA + " справка Б " + tt-wb-gds-EG.refB + ". Документ - " + buf_doc-attr.doc-code +  "/" + buf_doc-attr.attr-value.
              StatusErr = true.
              return ?.            
  
          end.
        end.
        if tt-wb-gds-EG.qnty <> buf_parts.fact-qnty / buf_parts.cli-base-rate then 
        do:
          is-diff = true. 
        end.
        case tt-wb-header.verXSD:
        when "WayBill_v2"
        then
          xml-cont = xml-cont + substitute ({&xml-act-cont-v2}, string (tt-wb-gds-EG.Identity), tt-wb-gds-EG.refB, string ( buf_parts.fact-qnty / buf_parts.cli-base-rate)).
        when "WayBill"
        then
          xml-cont = xml-cont + substitute ({&xml-act-cont}, string (tt-wb-gds-EG.Identity), tt-wb-gds-EG.refB, string ( buf_parts.fact-qnty / buf_parts.cli-base-rate)).
        end case.

      end /*foeach*/.
      
      case tt-wb-header.verXSD:
      when "WayBill_v2"
      then
        return substitute ({&xml-act-v2-1}, v-FS-RAR, (if is-diff then 'Differences' else 'Accepted'), buf_doc-attr.doc-code, iso-date (date (now)), tt-wb-header.wbregid, "Принимаем продукцию. " + (if is-diff then "Имеются расхождения." else "")) + (if is-diff then xml-cont else "") + {&xml-act-v2-2}.
      when "WayBill"
      then
        return substitute ({&xml-act-1}, v-FS-RAR, 'Accepted', buf_doc-attr.doc-code, iso-date (date (now)), tt-wb-header.wbregid, "Принимаем продукцию. " + (if is-diff then "Имеются расхождения." else "")) + (if is-diff then xml-cont else "") + {&xml-act-2}.
      end case.
    end.
    else do:
      if isForceAccept
      then do:
        find first buf_doc-attr no-lock where buf_doc-attr.attr-code = {&trdcattr-negais} and buf_doc-attr.attr-value begins (tt-wb-header.wbregid) no-error.
        case tt-wb-header.verXSD:
        when "WayBill_v2"
        then
          xml-cont = substitute ({&xml-act-v2-1}, v-FS-RAR, 'Accepted', (if available (buf_doc-attr) then buf_doc-attr.doc-code else string (time)), iso-date (date (now)), tt-wb-header.wbregid, "Принимаем продукцию") + {&xml-act-v2-2}.
        when "WayBill"
        then
          xml-cont = substitute ({&xml-act-1}, v-FS-RAR, 'Accepted', (if available (buf_doc-attr) then buf_doc-attr.doc-code else string (time)), iso-date (date (now)), tt-wb-header.wbregid, "Принимаем продукцию") + {&xml-act-2}.
        end case.
      end.
      else do:
        if tt-wb-header.verXSD = 'WayBill_v2'
        then
          xml-cont = substitute ({&xml-act-v2-1}, v-FS-RAR, 'Rejected', time, iso-date (date (now)), tt-wb-header.wbregid, "Отказ") + {&xml-act-v2-2}.
        else
          xml-cont = substitute ({&xml-act-1}, v-FS-RAR, 'Rejected', time, iso-date (date (now)), tt-wb-header.wbregid, "Отказ") + {&xml-act-2}.
      end.
      return xml-cont.
    end.
    
  end.


  method private void CmdParseXml (inType as char):
    
    define variable hDoc as handle no-undo.
    
    cmd = substitute ("&1 --connect-timeout &2 -X GET &3 >&4", search ("exe/curl.exe"), TimeOut, inType, inFileName).
    os-command silent value (cmd).

    file-info:file-name = search (inFileName).
    if file-info:file-size = 0
    then do:
      Msg = substitute ('По адресу &1 получен пустой файл. Возможно нужно увеличить timeout в настройках INI файда секция EGAIS', inType).
      StatusErr = true.
      return.
    end.
    
    createhDoc(inFileName, output hDoc).
    prsXMLDocWB:ParseRec (hDoc, input-output table tt-wb-header, input-output table tt-wb-act-header, input-output table tt-ticket, input-output table tt-wb-info-client, input-output table tt-wb-gds-EG).
    find first tt-wb-header no-error.
    find first tt-wb-act-header no-error.
    find first tt-ticket no-error.
    if not prsXMLDocWB:glog then 
    do:
      Msg = 'Ошибка обработки xml'.
      StatusErr = true.
      return.
    end.
    
  end.


  method private void WriteXMLWB (inFileName as char):

    def var sw               as handle    no-undo.
    def var VerXSDShip       as character no-undo.
    def var VerXSDCons       as character no-undo.
    def var CliEgaisTypeShip as character no-undo.
    def var CliEgaisTypeCons as character no-undo. 
    def var ii               as integer   no-undo.
    
    find first buf_ext-classif-attr no-lock where buf_ext-classif-attr.classif-subject = {&table_clients}
      and buf_ext-classif-attr.classif-name = {&extclass_clients_esys}
      and buf_ext-classif-attr.db-num = 0
      and buf_ext-classif-attr.key#_one = v-ext-sys
      and buf_ext-classif-attr.CharKey_two = (tt-wb-header.obj-type + string(tt-wb-header.obj-code))
      and buf_ext-classif-attr.CharKey_Three = tt-wb-header.regID-Ship
      and buf_ext-classif-attr.attr-code = "egais-cli-info" no-error.
      
    if available (buf_ext-classif-attr)
    then 
      assign 
        VerXSDShip = entry (1, buf_ext-classif-attr.attr-value, chr(4))
        CliEgaisTypeShip = entry (2, buf_ext-classif-attr.attr-value, chr(4))
      no-error.
    else VerXSDShip = 'WayBill'.
    
    if VerXSDShip = ? or VerXSDShip = "" or VerXSDShip = "WayBill" or VerXSD = "1"
    then do:
      VerWBXsd = "WayBill".
      verPrefXMLNS = "".
    end.
    else do:
      VerWBXsd = "WayBill_v2".
      verPrefXMLNS = "2".
    end.
    
    if VerWBXsd = "WayBill_v2" 
    then do:
      find first buf_ext-classif-attr no-lock where buf_ext-classif-attr.classif-subject = {&table_clients}
        and buf_ext-classif-attr.classif-name = {&extclass_clients_esys}
        and buf_ext-classif-attr.db-num = 0
        and buf_ext-classif-attr.key#_one = v-ext-sys
        and buf_ext-classif-attr.CharKey_two = (tt-wb-header.cli-type + string(tt-wb-header.cli-code))
        and buf_ext-classif-attr.CharKey_Three = tt-wb-header.regID-Cons
        and buf_ext-classif-attr.attr-code = "egais-cli-info" no-error.
      if available (buf_ext-classif-attr)
      then do:
        assign 
          VerXSDCons = entry (1, buf_ext-classif-attr.attr-value, chr(4))
          CliEgaisTypeCons = entry (2, buf_ext-classif-attr.attr-value, chr(4))
        no-error.
        if VerXSDCons = ? or VerXSDCons = ""
        then do:
          VerWBXsd = "WayBill".
          verPrefXMLNS = "".
/*          StatusErr = true.                                                                                                                                                            */
/*          Msg =  substitute ("У клиента ЕГАИС неизвестен тип. Обновите информацию по клиентам. Клиент - &1/&2.", buf_ext-classif-attr.CharKey_two, buf_ext-classif-attr.CharKey_Three).*/
/*          return.                                                                                                                                                                      */
        end.
      end.
      else do:
        VerWBXsd = "WayBill".
        verPrefXMLNS = "".
      end.
    end.
    
    tt-wb-header.verXSD = VerWBXsd.
    
    create sax-writer sw .
  
    sw:formatted = true.
    sw:set-output-destination ("file", inFileName).
    sw:encoding = "UTF-8".
    sw:start-document () .
    sw:start-element ("ns:Documents") .
    sw:insert-attribute ("Version", "1.0") .
    case VerWBXsd:
      when "WayBill" then do:
        sw:insert-attribute ("xmlns:wb", "http://fsrar.ru/WEGAIS/TTNSingle").
        sw:insert-attribute ("xmlns:ns", "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01").
        sw:insert-attribute ("xmlns:oref", "http://fsrar.ru/WEGAIS/ClientRef").
        sw:insert-attribute ("xmlns:pref", "http://fsrar.ru/WEGAIS/ProductRef").
      end.
      when "WayBill_v2" then do:
        sw:insert-attribute ("xmlns:wb2", "http://fsrar.ru/WEGAIS/TTNSingle_v2").
        sw:insert-attribute ("xmlns:ns", "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01").
        sw:insert-attribute ("xmlns:oref2", "http://fsrar.ru/WEGAIS/ClientRef_v2").
        sw:insert-attribute ("xmlns:pref2", "http://fsrar.ru/WEGAIS/ProductRef_v2").        
      end.
    end case.
  
    sw:start-element ("ns:Owner") . 
        sw:write-data-element ("ns:FSRAR_ID", v-fs-rar) .
    sw:end-element ("ns:Owner") . 
  
    sw:start-element ("ns:Document") .
  
      sw:start-element ("ns:" + VerWBXsd) .
        sw:write-data-element ("wb" + verPrefXMLNS + ":Identity", tt-wb-header.Identity) .
        sw:start-element ("wb" + verPrefXMLNS + ":Header") .  
          sw:write-data-element ("wb" + verPrefXMLNS + ":NUMBER", tt-wb-header.Identity).
          sw:write-data-element ("wb" + verPrefXMLNS + ":Date", iso-date (tt-wb-header.wb-date)).
          sw:write-data-element ("wb" + verPrefXMLNS + ":Type", tt-wb-header.wb-type).
          if VerWBXsd = 'WayBill'  
            then sw:write-data-element ("wb" + verPrefXMLNS + ":UnitType", tt-wb-header.UnitType). /*??????*/
          sw:write-data-element ("wb" + verPrefXMLNS + ":ShippingDate", iso-date (tt-wb-header.wb-date)).

          sw:start-element ("wb" + verPrefXMLNS + ":Shipper") .
            if VerWBXsd = 'WayBill_v2'
              then sw:start-element ("oref" + verPrefXMLNS + ":" + CliEgaisTypeShip) . 
            AddClientXML(sw, tt-wb-header.obj-type, tt-wb-header.obj-code, tt-wb-header.regID-Ship, yes).
            if StatusErr
              then return.
            if VerWBXsd = 'WayBill_v2'
              then sw:end-element ("oref" + verPrefXMLNS + ":" + CliEgaisTypeShip) .

          sw:end-element ("wb" + verPrefXMLNS + ":Shipper") .
          sw:start-element ("wb" + verPrefXMLNS + ":Consignee") .
            
            if VerWBXsd = 'WayBill_v2'
              then sw:start-element ("oref" + verPrefXMLNS + ":" + CliEgaisTypeCons) . 
            AddClientXML(sw, tt-wb-header.cli-type, tt-wb-header.cli-code, tt-wb-header.regID-Cons, no).
            if StatusErr
              then return.
            if VerWBXsd = 'WayBill_v2'
              then sw:end-element ("oref" + verPrefXMLNS + ":" + CliEgaisTypeCons) .
          sw:end-element ("wb" + verPrefXMLNS + ":Consignee") .
          sw:start-element ("wb" + verPrefXMLNS + ":Transport") .
          sw:end-element ("wb" + verPrefXMLNS + ":Transport") .
        sw:end-element ("wb" + verPrefXMLNS + ":Header") .
        sw:start-element ("wb" + verPrefXMLNS + ":Content") .
        
        ii = 0.
        for each tt-wb-gds-EG no-lock:
          
          ii = ii + 1.
          
          extGdsObj:OpenQueryExtGds (tt-wb-gds-EG.gds-code, tt-wb-gds-EG.alc-code).
          if extGdsObj:NumBundles = 0
          then do:
            Msg = substitute ("Не найдена связка &1/&2. &3",tt-wb-gds-EG.gds-code, tt-wb-gds-EG.alc-code, extGdsObj:ReturnMsg).
            extGdsObj:OpenQueryExtGds (tt-wb-gds-EG.alc-code).
            if extGdsObj:NumBundles = 0 
            then do:
              StatusErr = true.
              return.
            end.
            else do:
              extGdsValueObj = extGdsObj:GetExtGdsValue().
              message substitute ("&1 Продолжить? (информация по алкокоду будет получена от &2/&3).", Msg + {&new-line}, string (extGdsValueObj:GdsCode), extGdsValueObj:AlcCode) view-as alert-box question buttons yes-no title "Вопрос..." update isChoise as logical.
              if isChoise
              then do:
                Msg = "".
              end.
              else do:
                StatusErr = true.
                return.
              end.
            end.
          end.

          extGdsValueObj = extGdsObj:GetExtGdsValue().
          
          sw:start-element ("wb" + verPrefXMLNS + ":Position") .
            sw:write-data-element ("wb" + verPrefXMLNS + ":Identity", tt-wb-gds-EG.Identity).
            sw:start-element ("wb" + verPrefXMLNS + ":Product") .
              sw:write-data-element ("pref" + verPrefXMLNS + ":FullName", extGdsValueObj:FullNameGds).
              sw:write-data-element ("pref" + verPrefXMLNS + ":AlcCode", tt-wb-gds-EG.alc-code).
              
              if VerWBXsd = 'WayBill_v2'
              then do:
                if tt-wb-gds-EG.UnitType = 'Packed' then sw:write-data-element ("pref" + verPrefXMLNS + ":Capacity", if extGdsValueObj:Capacity <> 0 and extGdsValueObj:Capacity <> ? then string (extGdsValueObj:Capacity) else string (tt-wb-gds-EG.ms-base)).
                sw:write-data-element ("pref" + verPrefXMLNS + ":UnitType", tt-wb-gds-EG.UnitType).
              end.  
              else do:
                if tt-wb-header.UnitType = 'Packed' then sw:write-data-element ("pref" + verPrefXMLNS + ":Capacity", string (tt-wb-gds-EG.ms-base)).
              end.
              
              sw:write-data-element ("pref" + verPrefXMLNS + ":AlcVolume", string (tt-wb-gds-EG.proof)).
              sw:write-data-element ("pref" + verPrefXMLNS + ":ProductVCode", tt-wb-gds-EG.alc-type-code).
              
              if extGdsValueObj:FullNameProd = ""
              then do:
                StatusErr = true.
                Msg = extGdsObj:ReturnMsg + " У товара неизвестен производитель из ЕГАИС - " + string (tt-wb-gds-EG.gds-code) + ". Выполните синхронизацию товаров.".
                return.
              end.
              
              if VerWBXsd = 'WayBill_v2' and (extGdsValueObj:CliEgaisTypeProd = "")
              then do:
                StatusErr = true.
                Msg = Msg + extGdsObj:ReturnMsg + " У товара неизвестен тип производителя из ЕГАИС - " + string (tt-wb-gds-EG.gds-code) + ". Выполните синхронизацию товаров во второй схеме XSD." + {&new-line}.
              end.
                            
              sw:start-element ("pref" + verPrefXMLNS + ":Producer") .
              
                if VerWBXsd = 'WayBill_v2' and not extGdsValueObj:CliEgaisTypeProd = ""
                  then sw:start-element ("oref" + verPrefXMLNS + ":" + extGdsValueObj:CliEgaisTypeProd) .
                if not ( extGdsValueObj:INNProd = "" or extGdsValueObj:KPPProd = "")
                then do:
                  sw:write-data-element ("oref" + verPrefXMLNS + ":INN",  extGdsValueObj:INNProd ).
                  sw:write-data-element ("oref" + verPrefXMLNS + ":KPP", extGdsValueObj:KPPProd ).
                end.
                sw:write-data-element ("oref" + verPrefXMLNS + ":ClientRegId", extGdsValueObj:CliRegIdProd ).
                sw:write-data-element ("oref" + verPrefXMLNS + ":FullName", extGdsValueObj:FullNameProd ).
                sw:start-element ("oref" + verPrefXMLNS + ":address").
                  sw:write-data-element ("oref" + verPrefXMLNS + ":Country", extGdsValueObj:CountryProd ).
                  if VerWBXsd = "WayBill_v2" and extGdsValueObj:RegionProd <> ""
                    then sw:write-data-element ("oref" + verPrefXMLNS + ":RegionCode", extGdsValueObj:RegionProd ). 
                  sw:write-data-element ("oref" + verPrefXMLNS + ":description", extGdsValueObj:DescrProd ).
                sw:end-element ("oref" + verPrefXMLNS + ":address").
                if VerWBXsd = 'WayBill_v2' and not extGdsValueObj:CliEgaisTypeProd = ""
                  then sw:end-element ("oref" + verPrefXMLNS + ":" + extGdsValueObj:CliEgaisTypeProd) .
                  
              sw:end-element ("pref" + verPrefXMLNS + ":Producer") .

              if not extGdsValueObj:FullNameImpor = "" and VerXSD <> '2' then do:
                sw:start-element ("pref" + verPrefXMLNS + ":Importer") .
                  if not ( extGdsValueObj:INNImpor = "" or extGdsValueObj:KPPImpor = "")
                  then do:
                    sw:write-data-element ("oref" + verPrefXMLNS + ":INN",  extGdsValueObj:INNImpor ).
                    sw:write-data-element ("oref" + verPrefXMLNS + ":KPP", extGdsValueObj:KPPImpor ).
                  end.
                  sw:write-data-element ("oref" + verPrefXMLNS + ":ClientRegId", extGdsValueObj:CliRegIdImpor ).
                  sw:write-data-element ("oref" + verPrefXMLNS + ":FullName", extGdsValueObj:FullNameImpor ).
                  sw:start-element ("oref" + verPrefXMLNS + ":address").
                    sw:write-data-element ("oref" + verPrefXMLNS + ":Country", extGdsValueObj:CountryImpor ).
                    sw:write-data-element ("oref" + verPrefXMLNS + ":description", extGdsValueObj:DescrImpor ).
                  sw:end-element ("oref" + verPrefXMLNS + ":address").
                sw:end-element ("pref" + verPrefXMLNS + ":Importer") .
              end.
            sw:end-element ("wb" + verPrefXMLNS + ":Product") .
            sw:write-data-element ("wb" + verPrefXMLNS + ":Quantity", string (tt-wb-gds-EG.qnty)).
            sw:write-data-element ("wb" + verPrefXMLNS + ":Price", string (tt-wb-gds-EG.price)).
/*            sw:write-data-element ("wb" + verPrefXMLNS + ":Pack_ID", "Паллета").*/
/*            sw:write-data-element ("wb" + verPrefXMLNS + ":Party", string (ii)).*/
            
            case VerWBXsd:
            when 'WayBill' then do:
              sw:start-element ("wb" + verPrefXMLNS + ":InformA") .
                sw:write-data-element ("pref" + verPrefXMLNS + ":RegId", tt-wb-gds-EG.refA).
              sw:end-element ("wb" + verPrefXMLNS + ":InformA") .
              sw:start-element ("wb" + verPrefXMLNS + ":InformB") .
                sw:start-element ("pref" + verPrefXMLNS + ":InformBItem") .
                  sw:write-data-element ("pref" + verPrefXMLNS + ":BRegId", tt-wb-gds-EG.refB).
                sw:end-element ("pref" + verPrefXMLNS + ":InformBItem") .
              sw:end-element ("wb" + verPrefXMLNS + ":InformB") .
            end.
            when 'WayBill_v2' then do:
              sw:start-element ("wb" + verPrefXMLNS + ":InformF1") .
                sw:write-data-element ("pref" + verPrefXMLNS + ":RegId", tt-wb-gds-EG.refA).
              sw:end-element ("wb" + verPrefXMLNS + ":InformF1") .
              sw:start-element ("wb" + verPrefXMLNS + ":InformF2") .
                sw:start-element ("pref" + verPrefXMLNS + ":InformF2Item") .
                  sw:write-data-element ("pref" + verPrefXMLNS + ":F2RegId", tt-wb-gds-EG.refB).
                sw:end-element ("pref" + verPrefXMLNS + ":InformF2Item") .
              sw:end-element ("wb" + verPrefXMLNS + ":InformF2") .
            end.
            end case.                    

          sw:end-element ("wb" + verPrefXMLNS + ":Position") .
        
        end. /*for each tt-wb-gds-EG*/
        
        if StatusErr
        then do:
          return.
        end.
        
        sw:end-element ("wb" + verPrefXMLNS + ":Content") .
      sw:end-element ("ns:" + VerWBXsd) .
    sw:end-element ("ns:Document") .
    sw:end-element ("ns:Documents") .


    delete object sw.

  end.
  
  method private void AddClientXML (inSW as handle, inObjType as char, inObjCode as int, inRegID as char, inShipper as log):
    
    find first buf_clients no-lock where buf_clients.obj-type = inObjType and buf_clients.obj-code = inObjCode no-error.
    if available (buf_clients)
    then do:
      if buf_clients.obj-type = {&cmp}
      then do:
        find first buf_firm no-lock where buf_firm.firm-code = buf_clients.obj-code no-error.
      end.
      else do:
        find first buf_firm no-lock where buf_firm.firm-code = buf_clients.host-code no-error.
      end.
      find first buf_clients-attr no-lock where buf_clients-attr.obj-type = inObjType and buf_clients-attr.obj-code = inObjCode
        and buf_clients-attr.attr-code = {&attr-kpp} no-error.
    end.
    else do:
      Msg = "Не найден клиент " + inObjType + string (inObjCode).
      StatusErr = true.
      return.
    end.
    if available (buf_firm) then do:
      inSW:write-data-element ("oref" + verPrefXMLNS + ":INN", if INNObj = "" or INNObj = ? or not inShipper then buf_firm.inn else INNObj).
      if buf_firm.kpp <> "" and (not buf_clients.obj-type = {&shop} and not buf_clients.obj-type = {&stock}) and not available (buf_clients-attr)
        then inSW:write-data-element ("oref" + verPrefXMLNS + ":KPP", buf_firm.kpp).
      if available (buf_clients-attr) and buf_clients-attr.attr-value <> ""
        then inSW:write-data-element ("oref" + verPrefXMLNS + ":KPP", buf_clients-attr.attr-value).
    end.
    else do:
      Msg = "Не найден ИНН организации или объекта " + inObjType + string (inObjCode).
      StatusErr = true.
      return.
    end.
    find first buf_clients-attr no-lock where buf_clients-attr.obj-type = inObjType and buf_clients-attr.obj-code = inObjCode
      and buf_clients-attr.attr-code = {&attr-requisite-alc-decl} no-error.
    inSW:write-data-element ("oref" + verPrefXMLNS + ":ClientRegId", inRegID).
    if available (buf_clients-attr) and num-entries (buf_clients-attr.attr-value, "|") >= 20
    then do:
      inSW:write-data-element ("oref" + verPrefXMLNS + ":FullName", entry (1, attr-value, "|")).
    end.
    else do:
      Msg = "Не заполнены/неполные атрибуты для алкогольной декларации. Заполните и синхронизируйте с ЕГАИС. Клиент - " + inObjType + string (inObjCode).
      StatusErr = true.
      return.
    end.

/*    inSW:write-data-element ("oref" + verPrefXMLNS + ":ShortName", '').*/
    inSW:start-element ("oref" + verPrefXMLNS + ":address").
      if available (buf_clients-attr)
      then do:
        def var descr as char no-undo.
        inSW:write-data-element ("oref" + verPrefXMLNS + ":Country", entry (3, buf_clients-attr.attr-value, "|")).
        if VerWBXsd = "WayBill_v2"
          then inSW:write-data-element ("oref" + verPrefXMLNS + ":RegionCode", entry (5, buf_clients-attr.attr-value, "|") ).
        find first buf_country where buf_country.num-code = integer (entry (3, buf_clients-attr.attr-value, "|")) no-error.
        descr = entry (20, buf_clients-attr.attr-value, "|") no-error.
        descr = replace (descr, {&delim-urt}, "|").
        if descr = ? or descr = ""
        then do: 
          Msg = "Отсутствует андрес ЕГАИС организации " + inObjType + string (inObjCode) + ' ' + buf_clients.obj-name + ". Обновите данные ЕГАИС по организации.".
          StatusErr = true.
          return.
        end.
        inSW:write-data-element ("oref" + verPrefXMLNS + ":description", descr).
      end.
    inSW:end-element ("oref" + verPrefXMLNS + ":address").
    
  end.
 
  method private void GetVerXsd (output outVerDocXsd as char):
    
    define variable CliEgaisTypeShip as character no-undo.
    define variable CliEgaisTypeCons as character no-undo.
    define variable VerXSDShip       as character no-undo. 
    
    find first tt-wb-header no-error.
    
    if not available (tt-wb-header)
    then do:
      Msg = "Ошибка определения версии XSD схемы документа".
      StatusErr = true.
      return.
    end.
    
    find first buf_ext-classif-attr no-lock where buf_ext-classif-attr.classif-subject = {&table_clients}
      and buf_ext-classif-attr.classif-name = {&extclass_clients_esys}
      and buf_ext-classif-attr.db-num = 0
      and buf_ext-classif-attr.key#_one = v-ext-sys
      and buf_ext-classif-attr.CharKey_Three = tt-wb-header.regID-Ship
      and buf_ext-classif-attr.attr-code = "egais-cli-info" no-error.
      
    if available (buf_ext-classif-attr)
    then 
      assign 
        VerXSDShip = entry (1, buf_ext-classif-attr.attr-value, chr(4))
        CliEgaisTypeShip = entry (2, buf_ext-classif-attr.attr-value, chr(4))
      no-error.
    else VerXSDShip = 'WayBill'.
    
    if VerXSDShip = ? or VerXSDShip = "" or VerXSDShip = "WayBill" or VerXSD = "1"
    then do:
      outVerDocXsd = "WayBill".
      verPrefXMLNS = "".
    end.
    else do:
      outVerDocXsd = "WayBill_v2".
      verPrefXMLNS = "2".
    end.
    
    if outVerDocXsd = "WayBill_v2" 
    then do:
      find first buf_ext-classif-attr no-lock where buf_ext-classif-attr.classif-subject = {&table_clients}
        and buf_ext-classif-attr.classif-name = {&extclass_clients_esys}
        and buf_ext-classif-attr.db-num = 0
        and buf_ext-classif-attr.key#_one = v-ext-sys
        and buf_ext-classif-attr.CharKey_Three = tt-wb-header.regID-Cons
        and buf_ext-classif-attr.attr-code = "egais-cli-info" no-error.
      if available (buf_ext-classif-attr)
      then do:
        assign 
          CliEgaisTypeCons = entry (2, buf_ext-classif-attr.attr-value, chr(4))
        no-error.
        if CliEgaisTypeCons = ? or CliEgaisTypeCons = ""
        then do:
          outVerDocXsd = "WayBill".
          verPrefXMLNS = "".
/*          StatusErr = true.                                                                                                                                                            */
/*          Msg =  substitute ("У клиента ЕГАИС неизвестен тип. Обновите информацию по клиентам. Клиент - &1/&2.", buf_ext-classif-attr.CharKey_two, buf_ext-classif-attr.CharKey_Three).*/
/*          return.                                                                                                                                                                      */
        end.
      end.
      else do:
        outVerDocXsd = "WayBill".
        verPrefXMLNS = "".
      end.
    end.
    
  end.

end class.
