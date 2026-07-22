block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Морозов Александр Сергеевич
Дата создания: 01/30/15
Author: Alexandr Morozov
Creation date: 01/30/15

*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

using ibs.th.skt.*.
using ibs.th.skt.Adapters.*.
using ibs.th.gbl.env.utd.
using ibs.th.str.marking.handlers.*.
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Создание накладных по УПД".

{ cmp/trg-def.i }
{ cmp/library.i  }
{ ibs/th/str/utd/trn/tt516.i}
{ gbl/getcntxt.i def }
{ str/utd-attr.i}
{ str/utd-err.i}
{ gbl/attr-lib.i}
{ utl/gtin.i }
{ str/utd-typemark.i}
/*define shared variable g#auto-user-id as character no-undo .*/


define temp-table tt-gtin-qnty no-undo
  field gtin as character
  field qnty as integer
  field qntyDoc as integer
  field order as integer
.

define input  parameter  p-db-num as integer no-undo.
define input  parameter  p-doc-id as integer no-undo.
define input  parameter  p-userId as character no-undo.


/*define input  parameter table for  TempTrnDoc.       */
/*define input  parameter table for  TempDocLine.      */
/*define input  parameter userId_ as character no-undo.*/


define variable iDbNum as integer no-undo.

MAIN-BLOCK:
do:
  define variable num-rec-ok as logical no-undo.
  define variable ii         as integer no-undo.
  define variable vMarkUtd   as logical no-undo init no .
  define variable v-par-type as character no-undo.
  define variable v-par-val  as character no-undo.
   
/*  define variable logWrite   as class   LogWrite no-undo.*/
  def buffer buf_utd for ub.utd.
  def buffer buf_utd-attr for ub.utd-attr.
  def buffer buf_utd-lines for ub.utd-lines.
  def buffer buf_utd-marking-lines for ub.utd-marking-lines.
  def buffer buf_utd-marking-lines-attr for ub.utd-marking-lines-attr.
  def buffer buf_mark-lines for ub.marking-lines.
  def buffer buf_marking for ub.marking.
  def buffer buf_bar-code for ub.bar-code.
    
  define variable vGtin as character no-undo .
  define variable vGtinQnty as integer no-undo .
  define variable vGtinList as character no-undo .
  define variable vGtinDocQntyList as character no-undo .
  define variable vGtinFactQntyList as character no-undo .
  define variable vScanGtin as character no-undo .
  define variable vFullQnty as integer no-undo .
  define variable vGT as integer no-undo .
  define variable vGtinSumDocQnty as integer no-undo .
  define variable vOrder as integer no-undo .
  define variable vIsMarkLine as logical no-undo .
  define variable vIsWeight as logical no-undo .
  define variable vMaxDocLevel as integer no-undo .
  
  define variable vunit     as int no-undo.
  define variable vunitCode as character no-undo.
  define variable vCount     as int no-undo.
   
  { gbl/objsrv.i  }
/*  logWrite = new LogWrite().*/
  
  find first buf_utd where buf_utd.db-num = p-db-num and buf_utd.doc-id = p-doc-id no-error.
  if not available (buf_utd)
    then undo, return error "Не найден УТД - " + string(p-db-num) + "," + string(p-doc-id).
  
  
/*  if (vMarkUtd  and buf_utd.sts ne objSrv:Env:Utd:Sts:TH:Confirmed:KeyIntDB)
     or (not vMarkUtd
         and buf_utd.sts ne objSrv:Env:Utd:Sts:TH:DeliveryCodeMismatch:KeyIntDB
         and buf_utd.sts ne objSrv:Env:Utd:Sts:TH:SignatureRequired:KeyIntDB) */

  if     buf_utd.sts ne objSrv:Env:Utd:Sts:TH:Confirmed           :KeyIntDB
     and buf_utd.sts ne objSrv:Env:Utd:Sts:TH:DeliveryCodeMismatch:KeyIntDB
     and buf_utd.sts ne objSrv:Env:Utd:Sts:TH:SignatureRequired   :KeyIntDB 
  then do:
    undo, return error substitute ("Неверный статус документа УТД &1,&2 - &3&4Накладные можно создать в статусах: &4&5&4&6&4&7",
                                   p-db-num,
                                   p-doc-id,
                                   objSrv:Env:Utd:Sts:TH:GetLabel(buf_utd.sts),
                                   {&new-line},
                                   objSrv:Env:Utd:Sts:TH:Confirmed           :Label_,
                                   objSrv:Env:Utd:Sts:TH:DeliveryCodeMismatch:Label_,
                                   objSrv:Env:Utd:Sts:TH:SignatureRequired   :Label_)
                                   .
  end.

  if buf_utd.EDocType ne objSrv:Env:Utd:EDocType:UTD:KeyIntDB
  then do:
    undo, return error "Неверный тип документа УТД " + string(p-db-num) + "," +  string(p-doc-id) + " - " + objSrv:Env:Utd:EDocType:GetLabel(buf_utd.EDocType).
  end.
  
  if buf_utd.doc-code <> "" and can-find (first ub.trn-doc where ub.trn-doc.doc-code = buf_utd.doc-code)
  then do:
    undo, return "Для документа c вн. номером " + string(p-db-num) + "_" + string(p-doc-id) + " уже создана накладная - " + buf_utd.doc-code.
  end.
  
  

  create temp_trn-doc.
  assign
    temp_trn-doc.line-num      = ii
    temp_trn-doc.utdDocumentExt = buf_utd.DocumentExt
    temp_trn-doc.utdOrganizationExt = buf_utd.OrganizationExt
    temp_trn-doc.db-num = buf_utd.db-num
    temp_trn-doc.doc-id = buf_utd.doc-id
    temp_trn-doc.doc-date      = buf_utd.DocumentDate
    temp_trn-doc.ps            = buf_utd.comment
    temp_trn-doc.doc-code      = buf_utd.DocumentNumber
    temp_trn-doc.ext-doc-type  = "ie"
    temp_trn-doc.cli-type      = buf_utd.cli-type
    temp_trn-doc.cli-code      = buf_utd.cli-code
    temp_trn-doc.obj-type      = buf_utd.obj-type
    temp_trn-doc.obj-code      = buf_utd.obj-code
    temp_trn-doc.exch-code     = 0
    temp_trn-doc.exch-rate     = 1
    temp_trn-doc.exch-scale    = 1
    temp_trn-doc.contract-code = buf_utd.contract-code
    temp_trn-doc.host-code = buf_utd.host-code
    .
  define variable Tree           as class     tree no-undo .
  Tree = ObjSrv:Lib:MarkingTree .
  
  fe_:
  for each buf_utd-lines where buf_utd-lines.db-num = buf_utd.db-num
                           and buf_utd-lines.doc-id = buf_utd.doc-id
                           and buf_utd-lines.sts ne objSrv:Env:Utd:Sts:TH:LoadError:KeyIntDB
  no-lock:
    if buf_utd-lines.gds-code eq ?
      then next fe_.
    def var sum-vat as decimal no-undo.
    def var v-q as decimal no-undo.
    def var v-q-doc as decimal no-undo.
    def var v-q-doc-base  as decimal no-undo.
    v-q = 0.
    
    if buf_utd-lines.TaxRate = -1
    then
      temp_trn-doc.vat-type = {&without-vat}
    .

    &scop proc-name gds-attr-value
    {&run_proc_attr-lib}
    ( buf_utd-lines.gds-code,
     {&attr-mark-type},
     output v-par-val,
     output v-par-type
    ).
     
    assign
      vunitCode = buf_utd-lines.UnitCode when buf_utd-lines.UnitCode ne ? and buf_utd-lines.UnitCode ne ""
      vunit = ?
      vunit = integer (getattrutdlines(buf_utd-lines.db-num,buf_utd-lines.doc-id,buf_utd-lines.LineNum,"unit")) 
    no-error.
    if vunit ne 0 and vunit ne ?
    then do:
        /* только если одназначное соответствие */
      find units where units.OKEI eq vunit no-lock no-error.
      if available units
      then
        vunitCode = units.unit-name.
      
    end.
    
    vIsWeight = WghProdVariable(buf_utd.obj-type, buf_utd.obj-code, buf_utd-lines.gds-code).
    
    if logical (getAttrUtdLinesEx(buf_utd-lines.db-num,buf_utd-lines.doc-id,buf_utd-lines.LineNum,"MarkUtdLine","no"))
    then do :
      vIsMarkLine = yes .      
      if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_utd.obj-type, buf_utd.obj-code):GetIsMarkingForType(v-par-val)
      then do:
        if vIsWeight then do:
           for each buf_utd-marking-lines where buf_utd-marking-lines.db-num = buf_utd-lines.db-num
                and buf_utd-marking-lines.doc-id = buf_utd-lines.doc-id
                and buf_utd-marking-lines.LineNum = buf_utd-lines.LineNum
                and buf_utd-marking-lines.doc-level = 1                
              no-lock:              
              if buf_utd-marking-lines.sts = objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB then     
              v-q = v-q + MarkWeight(buf_utd-marking-lines.mark).              
           end.
        end.   
        else 
        v-q = Tree:GetQntyStsUnit(buf_utd-lines.db-num, buf_utd-lines.doc-id, buf_utd-lines.LineNum,objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB).        
      end.
      else do:
        LABEL_1:
        for each buf_utd-marking-lines where buf_utd-marking-lines.db-num = buf_utd-lines.db-num
          and buf_utd-marking-lines.doc-id = buf_utd-lines.doc-id
          and buf_utd-marking-lines.LineNum = buf_utd-lines.LineNum
          and buf_utd-marking-lines.doc-level = 1
          no-lock:
            if vIsWeight then do:               
               if buf_utd-marking-lines.sts = objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB then 
               v-q = v-q + MarkWeight(buf_utd-marking-lines.mark).               
            end.   
            else do: 
             find first buf_marking where buf_marking.mark = buf_utd-marking-lines.mark no-lock no-error.
             if buf_utd-marking-lines.sts = objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB and
                buf_marking.box-qnty <> ? then
             do:   
               /* Попробум в fact брать из кол-ва по марке, если марка в статусе "Проверен", */
               /* т.к. когда лок. статус марки "Ошибка", а глоб. статус - "Проверен",        */
               /* то она не попадает в fact, хотя считается принятой                         */
               v-q = v-q + buf_marking.box-qnty.
             end.
             else do:
               /* в fact считаем марки из упаковки проверенные, проданные и добавленные в док-т */
               v-q = v-q + Tree:GetQntySts(buf_utd-marking-lines.mark, objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB).
               do vCount = 1 to num-entries(objSrv:Env:Marking:Sts:Mark:Sale_Return_Wait):
                 v-q = v-q + Tree:GetQntySts(buf_utd-marking-lines.mark, int(entry(vCount,objSrv:Env:Marking:Sts:Mark:Sale_Return_Wait))).  
               end.
               do vCount = 1 to num-entries(objSrv:Env:Marking:Sts:Mark:Doc_Status):
                 v-q = v-q + Tree:GetQntySts(buf_utd-marking-lines.mark, int(entry(vCount,objSrv:Env:Marking:Sts:Mark:Doc_Status))).  
               end.
             end.
            end.
        end.      
      end.
      
      v-q-doc-base = buf_utd-lines.Quantity.
      v-q-doc = decimal(GetAttrUtdlinesex(buf_utd-lines.db-num,buf_utd-lines.doc-id,buf_utd-lines.linenum,"Quantity",string(v-q-doc-base))) .
      if v-q-doc = ?
      then do :
        find first buf_bar-code where 
                   buf_bar-code.gds-code = buf_utd-lines.gds-code
               and buf_bar-code.unit-cli = buf_utd-lines.UnitCode
        no-lock no-error.
        v-q-doc = v-q-doc-base / (if avail buf_bar-code then buf_bar-code.cli-base-rate else 1) .
      end .
    end .
    else do :         
      vIsMarkLine = no .              
      find first buf_bar-code where 
                 buf_bar-code.gds-code = buf_utd-lines.gds-code
             and buf_bar-code.unit-cli = vUnitCode
      no-lock no-error.
      v-q = decimal(GetAttrUtdlines(buf_utd-lines.db-num,buf_utd-lines.doc-id,buf_utd-lines.linenum,"QuantityBarCode")).      
                                   
      if v-q = ? then v-q = 0.
      v-q-doc = decimal(GetAttrUtdlinesex(buf_utd-lines.db-num,buf_utd-lines.doc-id,buf_utd-lines.linenum,"Quantity",string(buf_utd-lines.Quantity))) .
      v-q-doc-base = v-q-doc * (if avail buf_bar-code then buf_bar-code.cli-base-rate else 1).
      if v-q-doc = ?
      then do :
        v-q-doc = buf_utd-lines.Quantity.
        v-q-doc-base = v-q-doc * (if avail buf_bar-code then buf_bar-code.cli-base-rate else 1).
      end . 
    end .
    if CheckErrForLine(buffer buf_utd-lines:handle)
    then
      v-q = 0.
    sum-vat = (buf_utd-lines.Total - buf_utd-lines.TotalWithVatExcluded) / v-q-doc.      
    create temp_doc-line.
    assign
      temp_doc-line.line-num   = buf_utd-lines.LineNum
      temp_doc-line.db-num = buf_utd-lines.db-num
      temp_doc-line.doc-id = buf_utd-lines.doc-id
      temp_doc-line.gds-code   = buf_utd-lines.gds-code
      temp_doc-line.fact-qnty  = v-q
      temp_doc-line.doc-qnty   = v-q-doc-base
      temp_doc-line.cli-qnty   = v-q-doc
      temp_doc-line.unit-cli   = vUnitCode 
      temp_doc-line.price-cli  = buf_utd-lines.Total / (if vMarkUtd then buf_utd-lines.Quantity else temp_doc-line.cli-qnty)
      temp_doc-line.price-rubl = buf_utd-lines.Total / (if vMarkUtd then buf_utd-lines.Quantity else temp_doc-line.cli-qnty)
      temp_doc-line.doc-code   = temp_trn-doc.doc-code
      temp_doc-line.vat-pc     = 100 * sum-vat / (buf_utd-lines.TotalWithVatExcluded / temp_doc-line.cli-qnty)
      temp_doc-line.isWeight   = vIsWeight
    .
    
    if buf_utd-lines.TaxRate <> round ( temp_doc-line.vat-pc, 1 )
    and temp_doc-line.price-rubl < 10
    and abs(buf_utd-lines.TaxRate - temp_doc-line.vat-pc) < 1
    then do :
      temp_doc-line.vat-pc = buf_utd-lines.TaxRate .
    end .          
                                     
    if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_utd.obj-type, buf_utd.obj-code):GetIsArticForType(v-par-val)
    or logical(getattrutdlinesex(buf_utd-lines.db-num, buf_utd-lines.doc-id, buf_utd-lines.LineNum, "ArticUtdLine", "no"))    
    then do:
      if vIsWeight then do:
         uml_: 
         for each buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num = buf_utd-lines.db-num
                                                  and buf_utd-marking-lines.doc-id = buf_utd-lines.doc-id
                                                  and buf_utd-marking-lines.LineNum = buf_utd-lines.LineNum,
             first buf_marking no-lock where buf_marking.mark = buf_utd-marking-lines.mark                                                 
         :
             vGtin = getGtinByDM(buf_utd-marking-lines.mark) .
             temp_doc-line.gtinline = vGtin. 
             leave uml_.
         end.               
      end.
      else do:    
      assign
        vGtinList = ""
        vGtinDocQntyList = ""
        vGtinFactQntyList = ""
      .
      
      if vIsMarkLine
      then do :
        vMaxDocLevel = 1 .
        for each buf_utd-marking-lines where buf_utd-marking-lines.db-num = buf_utd-lines.db-num
                                         and buf_utd-marking-lines.doc-id = buf_utd-lines.doc-id
                                         and buf_utd-marking-lines.LineNum = buf_utd-lines.LineNum
        :
          vMaxDocLevel = max(vMaxDocLevel, buf_utd-marking-lines.doc-level) .
        end .
      end .

      utd-marking-lines_ :
      for each buf_utd-marking-lines where buf_utd-marking-lines.db-num = buf_utd-lines.db-num
                                       and buf_utd-marking-lines.doc-id = buf_utd-lines.doc-id
                                       and buf_utd-marking-lines.LineNum = buf_utd-lines.LineNum
      : 
        if vIsMarkLine then
        do:
          if can-find(first buf_marking where buf_marking.mark-parent = buf_utd-marking-lines.mark) then
          do:  /* пропускаем марки, которые имеют "детей" */
            next utd-marking-lines_ .
          end.
          find first buf_marking where buf_marking.mark = buf_utd-marking-lines.mark no-lock no-error.
          if avail buf_marking and 
             not can-do(objSrv:Env:Marking:Sts:Mark:AllChecked, string(buf_marking.sts)) then
          do:  /* пропускаем марку, которая не в статусе Проверен или его аналог (Продан, Списан и т.д.)*/
            next utd-marking-lines_ .
          end.
        end.
        
        vGtin = getGtinByDM(buf_utd-marking-lines.mark) .
        
        if vGtin > ""
        then do :
          vGtinQnty = 0 .
          find first buf_marking where buf_marking.mark = buf_utd-marking-lines.mark
/*                                     and (buf_marking.sts = objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB or buf_marking.sts = objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB)*/
                                   and buf_marking.box-qnty > 0
          no-lock no-error.
          if available (buf_marking)
          then do :
            vGtinQnty = buf_marking.box-qnty .
          end .
          else do :
            if vIsMarkLine
            then do :
              next utd-marking-lines_ .
            end .  
            vGtinQnty = getQntyUTDByCodId(buf_utd-marking-lines.mark) .
          end .
          if vGtinQnty > 0
          then do :
            if vGtinList > ""
            and lookup(vGtin, vGtinList) > 0
            then do :
              entry(lookup(vGtin, vGtinList), vGtinDocQntyList) = string(integer(entry(lookup(vGtin, vGtinList), vGtinDocQntyList)) + vGtinQnty) .
              entry(lookup(vGtin, vGtinList), vGtinFactQntyList) = string(integer(entry(lookup(vGtin, vGtinList), vGtinFactQntyList)) + (if temp_doc-line.fact-qnty = 0 then 0 else vGtinQnty)) .
              if temp_doc-line.fact-qnty = 0
              then
                entry(lookup(vGtin, vGtinList), vGtinDocQntyList) = string(integer(temp_doc-line.doc-qnty)) 
              .
            end .
            else do :
              vGtinList = vGtinList + vGtin + "," .
              vGtinDocQntyList = vGtinDocQntyList + string(if temp_doc-line.fact-qnty = 0 then temp_doc-line.doc-qnty else vGtinQnty) + "," .
              vGtinFactQntyList = vGtinFactQntyList + string(if temp_doc-line.fact-qnty = 0 then 0 else vGtinQnty) + "," .
            end .
            if integer(entry(lookup(vGtin, vGtinList), vGtinDocQntyList)) > temp_doc-line.doc-qnty
            then do :
              entry(lookup(vGtin, vGtinList), vGtinDocQntyList) = string(integer(temp_doc-line.doc-qnty)) .
            end .
          end .
        end .
      end .
      
      vGtinList = trim(vGtinList, ",") .
      vGtinDocQntyList = trim(vGtinDocQntyList, ",") .
      vGtinFactQntyList = trim(vGtinFactQntyList, ",") .      
                                                                   
      if temp_doc-line.fact-qnty <> temp_doc-line.doc-qnty
      and temp_doc-line.fact-qnty > 0
      then do : /* Частичная приёмка */
        empty temp-table tt-gtin-qnty .
        vFullQnty = temp_doc-line.fact-qnty .
        vScanGtin = getAttrUtdLinesEx(buf_utd-lines.db-num,buf_utd-lines.doc-id,buf_utd-lines.LineNum,"ScanGtin","") .
        vOrder = 0 .
        if vScanGtin > ""
        then do :
          vOrder = vOrder + 1 .
          create tt-gtin-qnty .
          assign
            tt-gtin-qnty.gtin = vScanGtin
            tt-gtin-qnty.qnty = 0
            tt-gtin-qnty.order = vOrder
          .
        end .
        do vGT = 1 to num-entries(vGtinList) :
          find first tt-gtin-qnty where tt-gtin-qnty.gtin = entry(vGT, vGtinList) no-error .
          if not available tt-gtin-qnty
          then do :
            vOrder = vOrder + 1 .
            create tt-gtin-qnty .
            assign
              tt-gtin-qnty.gtin = entry(vGT, vGtinList)
              tt-gtin-qnty.qnty = 0
              tt-gtin-qnty.qntyDoc = integer(entry(vGT, vGtinDocQntyList))
              tt-gtin-qnty.order = vOrder
            .
          end .
          else do :
            tt-gtin-qnty.qntyDoc = integer(entry(vGT, vGtinDocQntyList)) .
          end .
        end .
        for each tt-gtin-qnty by tt-gtin-qnty.order :
          tt-gtin-qnty.qnty = tt-gtin-qnty.qnty + 1 .
          vFullQnty = vFullQnty - 1 .
          if vFullQnty = 0
          then leave .
        end .
        for each tt-gtin-qnty where tt-gtin-qnty.qnty = 0 :
          delete tt-gtin-qnty .
        end .
        if vFullQnty > 0
        then do :
          for each tt-gtin-qnty by tt-gtin-qnty.order :
            if (tt-gtin-qnty.qntyDoc - 1) >= vFullQnty
            then do :
              tt-gtin-qnty.qnty = tt-gtin-qnty.qnty + vFullQnty .
              vFullQnty = 0 .
              leave .
            end .
            else do :
              tt-gtin-qnty.qnty = tt-gtin-qnty.qntyDoc .
              vFullQnty = vFullQnty - (tt-gtin-qnty.qntyDoc - 1) .
            end .
          end .
        end .
        
        assign
          vGtinList = ""
          vGtinDocQntyList = ""
          vGtinFactQntyList = ""
        .
        for each tt-gtin-qnty by tt-gtin-qnty.order :
          vGtinList = vGtinList + tt-gtin-qnty.gtin + "," .
          vGtinDocQntyList = vGtinDocQntyList + string(tt-gtin-qnty.qntyDoc) + "," .
          vGtinFactQntyList = vGtinFactQntyList + string(tt-gtin-qnty.qnty) + "," .
        end .
        vGtinList = trim(vGtinList, ",") .
        vGtinDocQntyList = trim(vGtinDocQntyList, ",") .
        vGtinFactQntyList = trim(vGtinFactQntyList, ",") .
      end . /* Частичная приёмка */
      
      vGtinSumDocQnty = 0 .
      do vGT = 1 to num-entries(vGtinList) :
        vGtinSumDocQnty = vGtinSumDocQnty + integer(entry(vGT, vGtinDocQntyList)) .
      end .
      
      if vGtinSumDocQnty > temp_doc-line.doc-qnty
      and not CheckErrForLine(buffer buf_utd-lines:handle)
      then do :
        if vGtinSumDocQnty <> temp_doc-line.doc-qnty then
        do: 
          do vGT = 1 to num-entries(vGtinList) :
            if integer(entry(vGT, vGtinFactQntyList)) >= integer(entry(vGT, vGtinDocQntyList)) 
            then
              next .
            entry(vGT, vGtinDocQntyList) = string(integer(entry(vGT, vGtinDocQntyList)) - 1) .
            vGtinSumDocQnty = vGtinSumDocQnty - 1 .
            if vGtinSumDocQnty = temp_doc-line.doc-qnty
            then
              leave .
          end .
          if vGtinSumDocQnty <> temp_doc-line.doc-qnty then
          do:
            undo, return error substitute("По строке &1 общее кол-во &2 по строке не совпадает с общим кол-вом &3 по всем GTIN.",
                                          temp_doc-line.line-num, temp_doc-line.doc-qnty, vGtinSumDocQnty).
          end.
        end .
      end .
      
      assign
        temp_doc-line.gtinList = vGtinList
        temp_doc-line.gtinDocQntyList = vGtinDocQntyList
        temp_doc-line.gtinFactQntyList = vGtinFactQntyList
      .
      
      end .
    end.
  end.
  
  if not can-find (first temp_doc-line no-lock where temp_doc-line.fact-qnty > 0)
  then do:
    return error substitute ("В УПД &1 от &2 нет позиций для включения в приходную накладную", buf_utd.DocumentNumber, buf_utd.DocumentDate).
  end.
  
  { gbl/curdbnum.i
      iDbNum
    }
  def var v-msg as character no-undo.
  def var v-gnews as logical no-undo.
  def var v-gesys as logical no-undo.
  v-gnews = g#news.
  v-gesys = g#esys.
  g#news = false.
  run ibs/th/str/utd/trnutd.p (
    input this-procedure ,
    input this-procedure ,
    input table temp_trn-doc ,
    input table temp_doc-line ,
    input table tt-excisemarks,
    output v-msg,
    output num-rec-ok
    ) no-error .
  if error-status:error 
    then do:
      g#news = v-gnews.
      g#esys = v-gesys. 
      undo, return error (return-value + " " + v-msg).
    end.
  g#news = v-gnews.
  g#esys = v-gesys.
  if iDbNum ne 0
  then do:
    run nws/cmdchgutd.p (buffer buf_utd) no-error.
    if error-status:error
    then do:
      undo, return error return-value.
    end.
  end.
  return v-msg.

end.

procedure pcall-log-file:
  
  define input parameter msg as character no-undo.
  
/*  assign                                                 */
/*    LogWrite:LogStr = LogWrite:LogStr + {&new-line} + msg*/
/*    .                                                    */

end.


procedure get-db-num:
  
  define output parameter pDbNum as integer no-undo.
  
  pDbNum = iDbNum.

end.

procedure get-userid:

  define output parameter pUserId as character no-undo.

  find first ub.user-login where ub.user-login.db-num = iDbNum and ub.user-login.user-id = p-userId no-error.
  
  if available ub.user-login
  then 
  do:
    assign
      pUserId  = p-userId
      .
  end.
  else 
  do:
    assign
      pUserId = p-userId
      .
  end.
  
end.

procedure mainmenu_getcntxt :
define output parameter p-cntxt-db-num                as integer   no-undo . /* текущая БД            */
define output parameter p-cntxt-userid                as character no-undo . /* текущий пользователь  */
define output parameter p-cntxt-level                 as character no-undo . /* уровень контекста     */
define output parameter p-cntxt-host-code-obj         as integer   no-undo . /* текущая фирма         */
define output parameter p-cntxt-obj-type              as character no-undo . /* тип текущего объекта  */
define output parameter p-cntxt-obj-code              as integer   no-undo . /* код текущего объекта  */
define output parameter p-cntxt-db-num-obj            as integer   no-undo . /* база текущего объекта */
define output parameter p-cntxt-is-admin              as logical   no-undo . /* база текущего объекта */

  do
  on error undo, return error return-value
  :
  define variable vt-host-code as integer   no-undo .

  find first temp_trn-doc no-error.

  { gbl/objdbnum.i
     temp_trn-doc.obj-type
     temp_trn-doc.obj-code
     p-cntxt-db-num-obj
     }

  { gbl/hostcode.i
     temp_trn-doc.obj-type
     temp_trn-doc.obj-code
     vt-host-code
     }

  assign
    p-cntxt-db-num          =  p-cntxt-db-num-obj
    p-cntxt-userid          =  p-userId
    p-cntxt-level           =  v-cntxt-level
    p-cntxt-host-code-obj   =  vt-host-code
    p-cntxt-obj-type        =  temp_trn-doc.obj-type
    p-cntxt-obj-code        =  temp_trn-doc.obj-code
    p-cntxt-is-admin        =  v-cntxt-is-admin
  .

  end.
end procedure. /* mainmenu_getcntxt */


/* Для str/in-doc.w */
procedure chk-is-addcharges :

  define output parameter p-enable-item as logical   no-undo .

  define variable v-is-add as character no-undo .
  define variable par-type   as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'is-addch':u"
      "'':u"
      "'':u"
      0
      "'':u"
      "'':u"
      "'':u"
      no
      v-is-add
      par-type
      no-error
    }

    if v-is-add = 'yes'
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

end procedure. /* chk-is-addcharges */

procedure get-report-num :
  define output parameter p-report-num as integer no-undo .
   do
   on error undo, return error return-value
   :
    assign
      p-report-num = 1
    .
   end.

end procedure. /* get-report-num */
 