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

using ibs.th.gbl.*.
using ibs.th.skt.Adapters.*.
using ibs.th.str.alcohol.*.
using ibs.th.skt.ControlledClients.*.
using ibs.th.gbl.sys.objth.
using ibs.th.str.utd.handlers.introduce.
using ibs.th.gbl.env.prmtrs.edo.
using ibs.th.gbl.sys.objsrv.
using ibs.th.str.marking.sts.*.
block-level on error undo, throw.

class ibs.th.skt.ControlledClients.TSD inherits objth: 
     define override public property vss-revision    as character no-undo init "$Revision:$":U get .
     define override public property vss-author      as character no-undo init "$Author:$":U get.
     define override public property vss-date        as character no-undo init "$Date:$":U get.
     define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
     define override public property vss-archive     as character no-undo init "$Archive:$":U get.
     define override public property vss-description as character no-undo init "клас для подготовки даныных для ТСД и загрузки из него" get.
    
   
  &scop delimiteFld chr(30)
  &scop delimiterLine chr(31)
  
  { str/marks.i         }
  { cmp/str-glbl.i class}
  { gbl/attr-lib.i class}
  {str/lib-trn.i class}
  { str/utd-attr.i class }
  { str/utd-err.i class }
  { str\utd-typemark.i class }
  {ibs/th/skt/ControlledClients/TSDTT.i}
  {ibs/th/skt/ControlledClients/TSDds.i}
  { str/utd-err.i class }
  {ibs/th/gbl/doc-codeClass.i}
  {ibs/th/gbl/basecodeClass.i}
  {utl/search.i}  
  { ref/gdsoattr.i '' class}
  {str/mark_collect.i}
  define stream str1 .
  define stream str2 .
  define stream logTSD .

  define public property SomeStr as longchar no-undo
    get.
    set.

  define public property ObjCode as integer no-undo
    private get.
    set.
    
  define public property ObjType as character no-undo
    private get.
    set (arg as char):
       ObjType = if arg eq "sho"
                 then
                    "маг"
                 else
                    arg.
    end.

  define public property SN as character no-undo
    private get.
    set.

  define public property ReqType as character no-undo
    get.
    set.
  define public property ResType as character no-undo
    get.
    set.

  define public property CurrDecSeparator as character no-undo init ","
      get.
      set.

  define public property CurrDecSeparatorTH as character no-undo
      get:
        return session:numeric-decimal-point.
      end.

  define public property IsMarkOn as logical no-undo init false
      get.
      set.
      
  define public property CP as character no-undo init "UTF-8"
    get.
    set.

  define private stream tsdstream.
  define private variable logWrite     as class     LogWrite     no-undo.
  define private variable keyrec       as class     keyrec       no-undo.
  define private variable v-keyrec     as character no-undo.

  define         variable v-today  as date      no-undo .
  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  define variable bc-frmt         as character no-undo .
  define variable bc-pfx          as character no-undo .
  define variable dbNum as integer no-undo.
  
  define variable myflagsDoc         as class flagsdoc         no-undo.
  define variable myflagsBarcode     as class flagsbarcode     no-undo.  
  
  constructor public TSD (  ):
    super().
    dbNum = GetDbNumLocal().
    myflagsDoc     = new flagsdoc ().
    myflagsbarcode = new flagsbarcode ().
    define variable v-par-type as character no-undo.
    keyrec = new keyrec ().
    logWrite = new LogWrite().
    if not valid-handle (ibs.th.gbl.gbl-hndllib:g#trdcalib)
    then do:
      run str/trdcalib.p persistent no-error.
    end.
    { str/trdcalib.i class}
    /* нужны для bc-gnrti.i */
    run gbl/conf-rd.p ("bc-pfx", "", "", 0, "", "", "", yes, output bc-pfx, output v-par-type) no-error.
    run gbl/conf-rd.p ("bc-frmt", "", "", 0, "", "", "", yes, output bc-frmt, output v-par-type) no-error.  
    
    os-delete value (search ("MT_documents.txt")) no-error.
    os-delete value (search ("MT_lines.txt")) no-error.
    os-delete value (search ("MT_MarkLines.txt")) no-error.
		
  end constructor.
  method public void clear():
     os-delete value (search ("MT_documents.txt")) no-error.
    os-delete value (search ("MT_lines.txt")) no-error.
    os-delete value (search ("MT_MarkLines.txt")) no-error.
    docClear().
  end.

  
  
  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  method private void tsdstreamopen (streamFile as char):
    
    output stream tsdstream to value (streamFile).

  end method.

  method private void tsdstreamopenapp (streamFile as char):
    
    output stream tsdstream to value (streamFile) append.

  end method.


  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  method private void tsdstreamclose ():
    
    output stream tsdstream close.

  end method.  
  
  
  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  method public longchar getStatusXml (statusOk as logical, statusMsg as longchar):
     return getStatusXml(statusOk,statusMsg,"").
  end.
  
  method public longchar getStatusXml (statusOk as logical, statusMsg as longchar, iDopTag as longchar):
    
    define variable statusOkTag as character no-undo.
    define variable statusMsgTag as character no-undo. 
  
    assign
      statusOkTag = substitute ('<STATUS>&1</STATUS>', if statusOk then "OK" else "ERROR")
      statusMsgTag = if statusOk then '' else substitute ('<STATUS_MESSAGE>&1</STATUS_MESSAGE>', statusMsg)
    .
    return substitute ('<?xml version="1.0" encoding="&1"?><TSD>&2&3&4</TSD>', CP, statusOkTag, statusMsgTag,iDopTag).

  end method.


  method public void getWB ():
    
/*    define variable cHeader    as character no-undo.*/
/*    define variable cLine      as longchar no-undo. */
/*    define variable cMarkLine  as longchar no-undo. */
    define variable dFactSum   as decimal   no-undo.
    define variable priceSale  as dec no-undo.
    define variable docType    as character no-undo.

    define variable hour     as integer no-undo.
    define variable minute   as integer no-undo.
    define variable sec      as integer no-undo.
    define variable timeleft as integer no-undo. 
    define variable decDocQnty as decimal no-undo.
    define variable decFactQnty as decimal no-undo.
    
    define variable jj as integer no-undo.
    define variable jjm as integer no-undo.
    define variable iim as integer no-undo.
    define buffer buf_trn-doc    for ub.trn-doc.
    define buffer buf_doc-line   for ub.doc-line.
    define buffer buf_goods      for ub.goods.
    define buffer buf_bar-code   for ub.bar-code.
    define buffer buf_parts      for ub.parts.
    define buffer buf_gen-attr   for ub.gen-attr.
    define buffer buf_user-login for ub.user-login.
    define buffer inv-doc-attr for ub.inv-doc-attr.
    define buffer goods-attr for ub.goods-attr.
    
    def    var      internal-b-code like ub.bar-code.b-code no-undo .
    def    var      full-b-code     as character init "" no-undo .
    
    define variable myflagsDoc     as class flagsdoc     no-undo.
    define variable myflagsDocLine as class flagsdocline no-undo.
    
    myflagsDoc = new flagsdoc ().
    myflagsDocLine = new flagsdocline ().
    
    block-trn:
    for each buf_trn-doc where 
            buf_trn-doc.obj-type = ObjType 
        and buf_trn-doc.obj-code = ObjCode 
        and ( ((buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} 
              or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem}
              or buf_trn-doc.ext-doc-type = {&TDEDT_Inv})
              and buf_trn-doc.flag_ = true
              and buf_trn-doc.status_ = {&permitted})
            or 
              ((buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} 
              or buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem})
              and buf_trn-doc.flag_ = true
              and buf_trn-doc.status_ = {&wayb})
            ) 
      no-lock:
      
    for each inv-doc-attr no-lock where (inv-doc-attr.doc-code = buf_trn-doc.doc-code 
                                and inv-doc-attr.attr-code = "ItogInv") or ( inv-doc-attr.doc-code = buf_trn-doc.doc-code 
                                  and inv-doc-attr.attr-code = "ItogInvManual" ):
       next block-trn.  
    end.
    find first inv-doc-attr no-lock where inv-doc-attr.doc-code = buf_trn-doc.doc-code and inv-doc-attr.attr-code = "invMultDevice" and inv-doc-attr.attr-value = string(true) no-error .
    if not available (inv-doc-attr) and buf_trn-doc.ext-doc-type = {&TDEDT_Inv} then next .  
    logWrite:WriteDebugLog( "Выгружаем документ " + buf_trn-doc.doc-code).
    
      myflagsDoc:unSetAllFlags().
      case buf_trn-doc.ext-doc-type:
        when {&TDEDT_Ras_Vnesh} then do:
          docType = "ExtSalesWB".
        end.
        when {&TDEDT_Ras_Perem} then do:
          docType = "IntSalesWB".
        end.
        when {&TDEDT_Pri_Vnesh} then do:
          docType = "ExtPurchWB".
        end.
        when {&TDEDT_Pri_Perem} then do:
          docType = "IntPurchWB".
        end.
        when {&TDEDT_Inv} then do:
          docType = "Inv".
        end.
      end case.
      if IsMarkOn and not docType = 'Inv'
      then do:
        for each buf_doc-line where buf_doc-line.doc-code = buf_trn-doc.doc-code no-lock:
          find first buf_goods no-lock where buf_goods.artic = buf_doc-line.artic and buf_goods.prod-code = buf_doc-line.prod-code 
            and buf_goods.prod-type = buf_doc-line.prod-type.                          
          find first goods-attr where goods-attr.gds-code = buf_goods.gds-code
            and goods-attr.attr-code = {&attr-mark} and goods-attr.attr-value = "yes" no-lock no-error.
          if available (goods-attr)
          then do:
            myflagsDoc:isDocMarkOn = true.
            leave.
          end. 
        end.
      end.
      def var pos as int no-undo.
      if not myflagsDoc:isDocMarkOn
      then do:
        pos = 0.
        for each buf_doc-line where buf_doc-line.doc-code = buf_trn-doc.doc-code no-lock:
          find first buf_goods no-lock where buf_goods.artic = buf_doc-line.artic and buf_goods.prod-code = buf_doc-line.prod-code and buf_goods.prod-type = buf_doc-line.prod-type.
          find first buf_bar-code no-lock where buf_bar-code.gds-code = buf_goods.gds-code
            and buf_bar-code.unit-cli = buf_goods.unit-base.
          
          myflagsDocLine:unSetAllFlags().
          internal-b-code = buf_bar-code.b-code.
          { str/bc-gnrti.i "bc" "internal-b-code" "full-b-code"}
          pos = pos + 1.
          decDocQnty = if docType = 'inv' then buf_doc-line.doc-qnty - buf_doc-line.fact-qnty else buf_doc-line.doc-qnty.
          decFactQnty = if docType = 'inv' then buf_doc-line.doc-qnty else buf_doc-line.fact-qnty.
          
          assign
            priceSale   = if buf_doc-line.price-rubl <> ? then buf_doc-line.price-rubl else 0
            .
          
/*          cLine = cLine + substitute ('<line DocName="&1" GoodsID="&2" UnitBC="&3" BC="&4" Price="&5" DocQnty="&6" FactQnty="&7" AlcCode="&8" PartIDTH ="&9" />', buf_doc-line.doc-code, buf_goods.gds-code, buf_goods.unit-base, full-b-code, priceSale, docQnty, factQnty).*/
         jjm = jjm + 1. 
         addDocLine(jjm,
                      buf_trn-doc.doc-code,
                       if docType = 'inv' then pos else buf_doc-line.line-num,
                      buf_goods.gds-code,
                       buf_goods.gds-name ,
                      buf_goods.unit-base,
                      full-b-code,
                       priceSale,
                       decDocQnty,
                       0,
                      "",
                      "",
                       myflagsDocLine:FlagsToInt  ).
/*        tsdstreamopenapp("MT_lines.txt").                */
/*          jjm = jjm + 1.                                 */
/*          put stream tsdstream unformatted               */
/*          substitute ("&2&1&3&1&4&1&5&1&6&1&7&1&8&1&9&1",*/
/*                      {&delimiteFld},                    */
/*                      string (jjm),                      */
/*                      buf_trn-doc.doc-code,              */
/*                      buf_goods.gds-name,                */
/*                      buf_goods.gds-code,                */
/*                      buf_goods.gds-name,                */
/*                      buf_goods.unit-base,               */
/*                      full-b-code,                       */
/*                      priceSale                          */
/*                                                         */
/*                                                         */
/*                     )                                   */
/*                     +                                   */
/*           substitute ("&3&1&4&1&5&1&6&1&7&2",           */
/*                      {&delimiteFld},                    */
/*                      {&delimiterLine},                  */
/*                      docQnty,                           */
/*                      "0",                               */
/*                      "",                                */
/*                      "",                                */
/*                      string (myflagsDocLine:FlagsToInt) */
/*)                                                        */
/*          .                                              */
          
/*        tsdstreamclose().*/
          
/*          dFactSum = buf_doc-line.fact-qnty + dFactSum.*/
        end.
      end.
      else do:
        def var v-alc-code as char no-undo.
        pos = 0.
        for each buf_doc-line where buf_doc-line.doc-code = buf_trn-doc.doc-code no-lock:
          find first buf_goods no-lock where buf_goods.artic = buf_doc-line.artic and buf_goods.prod-code = buf_doc-line.prod-code and buf_goods.prod-type = buf_doc-line.prod-type.
          find first buf_bar-code no-lock where buf_bar-code.gds-code = buf_goods.gds-code.
          
          for each buf_parts no-lock where
            buf_parts.obj-type = buf_trn-doc.obj-type and 
            buf_parts.obj-code = buf_trn-doc.obj-code and 
            buf_parts.artic = buf_doc-line.artic and
            buf_parts.prod-type = buf_doc-line.prod-type and
            buf_parts.prod-code = buf_doc-line.prod-code and
            buf_parts.out-code = buf_trn-doc.doc-code:
          
            internal-b-code = buf_bar-code.b-code.
            { str/bc-gnrti.i "bc" "internal-b-code" "full-b-code"}
            
            myflagsDocLine:unSetAllFlags().
            
            decDocQnty = buf_parts.qnty.
            decFactQnty = buf_parts.fact-qnty.
            assign
              priceSale   = if buf_parts.price-rubl <> ? then buf_parts.price-rubl else 0
              .
            assign
              .
            keyrec:GenKeyRec({&table_parts}, buffer buf_parts:handle, output v-keyrec).
            v-alc-code = if num-entries  (buf_parts.alc-ref-ab-path, ",") < 3 then "" else entry (3, buf_parts.alc-ref-ab-path, ",").
            

            pos = pos + 1.
            iim = 0.
            for each buf_gen-attr no-lock where buf_gen-attr.p-key = v-keyrec and buf_gen-attr.table-name = {&excise-mark}:
              iim = iim + 1.
              jj = jj + 1.
/*              cMarkLine = cMarkLine + substitute ('<MarkLines DocName="&1"  MarkCode="&2" Sts="&3" PartIDTH="&4" />', buf_doc-line.doc-code, buf_gen-attr.attr-code, "TH", v-keyrec).*/
              addDocLineMark(
                    jj,
                      buf_trn-doc.doc-code,
                    pos,
                      buf_gen-attr.attr-code,
                      v-keyrec,
                    "TH",
                    ?,
                    ?,
                    "").
            end.
            
              jjm = jjm + 1.
              if decimal (iim) = buf_parts.qnty
                then myflagsDocLine:isEditManualFullQnty = true.
                else myflagsDocLine:isNotEditManualQnty = true.
             addDocLine(jjm,
                      buf_trn-doc.doc-code,
                       pos,
                       buf_goods.gds-code,
                       buf_goods.gds-name ,
                      buf_goods.unit-base,
                      full-b-code,
                       priceSale,
                       decDocQnty,
                       0,
                      "", /* v-alc-code */
                      v-keyrec,
                       myflagsDocLine:FlagsToInt  ).
            
/*            dFactSum = buf_doc-line.fact-qnty + dFactSum.*/
          end.
        end.      
      end.
      
      if buf_trn-doc.ext-doc-type = {&TDEDT_Inv} then myflagsDoc:isDocMarkOn = yes. /* Было решено сделать флаг 1 всегда для инвентаризаций на АКС от 22.04.2025 */
      
      find first buf_user-login where buf_user-login.user-id = buf_trn-doc.user-name  no-lock no-error.
      addDoc(
           buf_trn-doc.doc-code,
           docType,
           false,
           buf_trn-doc.status_ + string (buf_trn-doc.flag, "+/-"),
           buf_trn-doc.cli-code,
           buf_trn-doc.cli-type,
           buf_trn-doc.obj-code,
           buf_trn-doc.obj-type,
           buf_trn-doc.user-name,
           if available (buf_user-login) then buf_user-login.user-login else "",
           dFactSum,
           datetime-tz (buf_trn-doc.doc-date, buf_trn-doc.real-time-create * 1000),
           myflagsDoc:FlagsToInt
      ).
      
      
/*      SomeStr = SomeStr + cHeader + cLine + cMarkLine.*/
        logWrite:WriteDebugLog( "Выгружен документ " + buf_trn-doc.doc-code).
    
    end.
/*    SomeStr = substitute ('<?xml version="1.0" encoding="&1"?><TSD>', CP) + SomeStr + ('</TSD>').*/
/*    output stream logTSD to value ("logSKTTSD.txt").*/
/*    export stream logTSD SomeStr.                   */
/*    output stream logTSD close.                     */

  end method.

  method public void Check_ ():
    
    define variable confPar   as character no-undo.
    define variable parType   as character no-undo.
    define variable statusOK  as logical   no-undo init false.
    define buffer buf_clients   for ub.clients.
    run gbl/conf-rd.p ("tsd-list", "", "", 0, "", "", "", no, output confPar, output parType) no-error.
    if lookup (SN, confPar, ";") > 0 
      then statusOK = true.
    find first buf_clients no-lock 
      where buf_clients.obj-type = ObjType and buf_clients.obj-code = ObjCode no-error.
    if available (buf_clients) 
      then statusOK = true. 
	  else statusOK = false. 
     
    if true // Зачем неписать сообщение об ошибке если в ответ всеравно отправляется ошибка 
    then do:
       importVersion(). 
       SomeStr = getStatusXml(statusOK, "",getVersion()).
    end. 
    else SomeStr = if lookup (SN, confPar) = 0 then getStatusXml(statusOK, "LIC") else getStatusXml(statusOK, "OBJ").
    
  end method.
  
  method public character createTegLogical (iTeg as char,
                                     iValue as logical):
      if ivalue eq ? then return createTeg(iteg,?).                              
      return createTeg(iteg,trim(string(ivalue,"true/false"))).
  end.
  
  method public character createTeg (iTeg as char,
                                     iValue as char):
      if ivalue eq "" or ivalue eq ? then return "".                              
      return substitute ("<&1>&2</&1>",iteg,ivalue).
  end.
  method public void getSettings ():
    
    define variable confPar   as character no-undo.
    define variable parType   as character no-undo.
    define variable validSN   as logical   no-undo init ?.
    define variable validObj  as logical   no-undo init ?.
    
    define buffer buf_clients   for ub.clients.
    run gbl/conf-rd.p ("tsd-list", "", "", 0, "", "", "", no, output confPar, output parType) no-error.
    if SN ne ? and SN ne ""
    then
       validSN = lookup (SN, confPar, ";") > 0.
    ObjectsClear().
    getCurrentObjects().
    ObjectsPrint("xml").
    SomeStr = substring (SomeStr,index(SomeStr,">") + 1).
    if ObjType ne ? and ObjType ne "" 
    then do:
      find first buf_clients no-lock 
         where buf_clients.obj-type = ObjType and buf_clients.obj-code = ObjCode no-error.
      validObj = available (buf_clients). 
    end.
    importVersion(). 
    SomeStr = getStatusXml(true, "",
    substitute ("&1&2&3&4",
    getVersion(),
    SomeStr,
    createTegLogical("validSN",validSN),
    createTegLogical("validObj",validObj))).
    
  end method.
  method public void setResult (iFile as char):
  
      copy-lob
          from  file search(iFile)
          to object SomeStr
          no-convert
       no-error .
  end.
  
  method public void writeResult (iFile as char):
      writeResult(iFile,?).
  end.
  
  method public void writeResult (iFile as char, iencode as char):
      if(iencode eq ?)
      then do:
         copy-lob
            from object SomeStr 
            to file iFile
            no-convert
         .
       end.
       else do:
          copy-lob
            from object SomeStr 
            to  file iFile
            convert  TARGET CODEPAGE iencode
          .
       end.
  end.
  
  
  method public void WriteUsers (idir as char):
     GetUsers ().
     UsersPrint(ResType, idir + "\TH_users." + if ResType eq ? or ResType eq "" then "txt" else "json" ).
  end.
  
  
  
  method public void usersClear ():
     empty temp-table tt-user.
  end.
  
  method public void GetUsers ():
    define buffer buf_user-login for ub.user-login.
    for each buf_user-login where buf_user-login.status_ = 0 and buf_user-login.db-num = dbNum no-lock:
      create tt-user.
      assign 
         tt-user.user-id = buf_user-login.user-id
         tt-user.user-login = buf_user-login.user-login
         .
    end.
  end. 
  method public void UsersPrint (type as character):
     UsersPrint(type,?).
  end.
  method public void UsersPrint (type as char, file as char):
    if    type eq "xml"
       or type eq "json"
    then do:
       ttprint(type, dataset ds-user :handle).
       if (file ne "" and file ne ?)
       then
          writeResult(file,"utf-8").
    end.
    else do:
       if file eq ?
       then
          file = "temp_tsd.txt".
       tsdstreamopen(file).
       for each tt-user no-lock:
         put stream tsdstream unformatted tt-user.user-id + {&delimiteFld} + tt-user.user-login + {&delimiterLine}.
    end.
    tsdstreamclose().
       if file = "temp_tsd.txt"
       then
          setResult(file).
  end.
  end.
  
  method public void WriteObjects (idir as char):
     getObjects().
     ObjectsPrint(ResType, idir + "\TH_objects." + if ResType eq ? or ResType eq "" then "txt" else "json" ).
  end.
  
  
  
  method public void ObjectsClear ():
     empty temp-table tt-Objects.
  end.
  method public void getObjects ():
    define buffer buf_clients   for ub.clients.
    for each buf_clients where buf_clients.stts = 0 and (buf_clients.obj-type = "маг" or buf_clients.obj-type = "скл") no-lock:
       create tt-Objects.
       assign
          tt-Objects.obj-type = buf_clients.obj-type
          tt-Objects.obj-code = buf_clients.obj-code
          tt-Objects.obj-name = buf_clients.obj-name
       .
       
    end.
    
  end.
  
  method public void getCurrentObjects ():
  define buffer buf_clients for ub.clients .
  for each buf_clients where buf_clients.stts = 0 
                         and buf_clients.db-num eq dbnum no-lock:
       create tt-Objects.
       assign
          tt-Objects.obj-type = buf_clients.obj-type
          tt-Objects.obj-code = buf_clients.obj-code
          tt-Objects.obj-name = buf_clients.obj-name
       .
       
    end.
    
  end.
  method public void ObjectsPrint (type as char):
     ObjectsPrint(type, ?).
  end.
  method public void ObjectsPrint (type as char,file as char):
    define buffer buf_clients   for ub.clients.
    if    type eq "xml"
       or type eq "json"
    then do:
       ttprint(type, dataset ds-Objects :handle).
       if (file ne "" and file ne ?)
       then
          writeResult(file,"utf-8").
    end.
    else do:
       if file eq ""
       then
          file = "temp_tsd.txt".
       tsdstreamopen(file).
       for each tt-Objects no-lock:
     put stream tsdstream unformatted 
         string (tt-Objects.obj-code) + {&delimiteFld} + 
         tt-Objects.obj-type + {&delimiteFld} + 
         tt-Objects.obj-name + 
      {&delimiterLine}.
    end.
    end.
    tsdstreamclose().
       if file = "temp_tsd.txt"
       then
          setResult(file).
  end.
  
  method public void WriteClients (idir as character):
     ClientsClear().
     getClients().
     ClientsPrint(resType, idir + "\TH_clients."  + if ResType eq ? or ResType eq "" then "txt" else "json" ).
  end.
  
  
  method public void ClientsClear ():
     empty temp-table tt-Clients.
  end.
  
  method public void getClients ():
    define buffer buf_clients   for ub.clients.
    for each buf_clients where buf_clients.stts = 0 and (buf_clients.obj-type = "орг" 
      or buf_clients.obj-type = "чел" or buf_clients.obj-type = {&shop} or buf_clients.obj-type = {&stock})
      and not (buf_clients.obj-type = ObjType and buf_clients.obj-code = ObjCode) no-lock:
      create tt-Clients.
       assign
          tt-Clients.obj-type = buf_clients.obj-type
          tt-Clients.obj-code = buf_clients.obj-code
          tt-Clients.obj-name = buf_clients.obj-name
       .
    end.
  end.
  method public void ClientsPrint (type as char):
     ClientsPrint(type,?).
  end.
  method public void ClientsPrint (type as char,file as char):
    if    type eq "xml"
       or type eq "json"
    then do:
       ttprint(type, dataset ds-Clients :handle).
       if (file ne "" and file ne ?)
       then
          writeResult(file,"utf-8").
    end.
    else do:
       if file eq ""
       then
          file = "temp_tsd.txt".
    
    
       tsdstreamopen(file). 
       for each tt-Clients no-lock: 
         put stream tsdstream unformatted string (tt-Clients.obj-code) + {&delimiteFld} + tt-Clients.obj-type + {&delimiteFld} + tt-Clients.obj-name + {&delimiterLine}.
    end.
    tsdstreamclose().
       if file = "temp_tsd.txt"
       then
          setResult(file).
     end.
  end.
  
  method public void GoodsClear ():
     empty temp-table tt-Goods.
  end.
  
  method public void getGoods ():
     getGoodsAndBarcodes(yes,no,?).
  end.   
  method public void getGoodsAndBarcodes (iGoods as logical ,ibarcode as logical, input iprotocol as char):
     define variable factQnty    as dec no-undo.
     define variable freeQnty    as dec no-undo.
     define variable countryName as character no-undo.
     define variable dPriceSale  as decimal   no-undo.
     define variable dVatPc      as decimal   no-undo.
     define variable is-petrol   as logical no-undo.
     define variable is-pieces   as logical no-undo.
     define variable priceSale   as decimal no-undo.
     define variable cliBaseRate as decimal no-undo.  
     define buffer buf_goods     for ub.goods.
     define buffer buf_gds-obj   for ub.gds-obj.
     define buffer buf_bar-code  for ub.bar-code.
     define buffer buf_price-all for ub.price-all.
     define buffer buf_prod-bc   for ub.prod-bc.
     define buffer utd-lines for ub.utd-lines.
     define buffer country for ub.country . 

     define variable vMarkingType   as integer no-undo init 0.
    
     define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
     if ibarcode
     then
        EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(ObjType, ObjCode).
    
     cicle:
     for each buf_goods where buf_goods.stts = 0 
                          and buf_goods.gds-type = 'т' 
     no-lock :
       { str/is-petrl.i
          buf_goods.artic
          buf_goods.prod-type
          buf_goods.prod-code
          is-petrol
          is-pieces
          no-error
       }
       if is-petrol = yes and is-pieces = no then do:
          next cicle.
       end.
      
       find first buf_gds-obj where buf_gds-obj.gds-code = buf_goods.gds-code no-lock no-error.
       if not available (buf_gds-obj)
       then do:
          find first utd-lines where utd-lines.gds-code = buf_goods.gds-code no-lock no-error.
          if not available (utd-lines)
          then next cicle.
       end.
      
       if(igoods)
       then do:
          find first country where country.alpha1 = buf_goods.alpha1 no-lock no-error. 
   
          assign
             factQnty    = if available buf_gds-obj then buf_gds-obj.fact-qnty else 0
             freeQnty    = if available buf_gds-obj then buf_gds-obj.free-qnty else 0
             countryName = if available ub.country then ub.country.long-name else ""
          .
          create tt-goods.  
          assign
             tt-goods.gds-code  = buf_goods.gds-code
             tt-goods.gds-name  = buf_goods.gds-name
             tt-goods.unit-base = buf_goods.unit-base
   /*        tt-goods.priceSale = priceSale*/
   /*        tt-goods.vatPc     = vatPc    */
             tt-goods.countryName = countryName
   /*        tt-goods.struct    = "Состав"*/
             tt-goods.factQnty  = factQnty 
             tt-goods.freeQnty  = freeQnty 
          .
       end.
       if ibarcode
       then do:
          if iprotocol > "" 
          then do:
             define variable v-value as character no-undo.
             define variable v-type  as character no-undo.
             &scop proc-name gds-attr-value
             {&run_proc_attr-lib}
               (input  buf_goods.gds-code
               ,input  {&attr-mark-type}
               ,output v-value
               ,output v-type
               ) no-error .
             if error-status :error
             then do:
                undo, return error return-value .
             end.
             myflagsbarcode:unSetAllFlags().
             myflagsbarcode:isEDO = EDOParSec:GetIsEDOForType(v-value) . /* поэкземплярный учет */
             myflagsbarcode:isArtic = EDOParSec:GetIsArticForType(v-value) . /* объемно-артикульный учет */
             myflagsBarcode:IsTransitional = EDOParSec:GetIsTransitionalForType(v-value) . /* переходный период */

          end.
          for each buf_bar-code where buf_bar-code.in-code = "" 
                                  and buf_bar-code.gds-code = buf_goods.gds-code 
                                  and buf_bar-code.stts_ = 0 
          no-lock use-index prt-parts:
             
             find last buf_price-all where
                buf_price-all.b-code          = buf_bar-code.b-code and
                buf_price-all.gds-code        = buf_goods.gds-code  and
                buf_price-all.obj-code        = ObjCode and
                buf_price-all.obj-type        = ObjType and
                buf_price-all.plt-priority    = 0                   and
                buf_price-all.last-pr         = true
             no-lock no-error.

/*        internal-b-code = buf_bar-code.b-code.                */
/*                                                              */
/*                                                              */
/*        { str/bc-gnrti.i "bc" "internal-b-code" "full-b-code"}*/

             find first ub.gds-obj no-lock where 
                        ub.gds-obj.artic = buf_goods.artic
                    and ub.gds-obj.prod-type = buf_goods.prod-type
                    and ub.gds-obj.prod-code = buf_goods.prod-code no-error.
        
             if available buf_price-all and not buf_price-all.price-sale = ?
             then priceSale = buf_price-all.price-sale.
             else if available (ub.gds-obj) and not ub.gds-obj.price-sale = ?
             then priceSale = ub.gds-obj.price-sale.
             else priceSale = 0.
             if iprotocol eq "1.0" then do:
                if priceSale = 0
                then
                   priceSale =  1 / 100000.  
             end.
             assign
                cliBaseRate = buf_bar-code.cli-base-rate
             .
        
             for each buf_prod-bc where buf_prod-bc.b-code = buf_bar-code.b-code 
                                    and buf_prod-bc.bc-on = yes
             no-lock:
        
                if iprotocol > "" 
                then do:
                   myflagsbarcode:isMark = false .
                   define buffer buf_prod-bc-attr for ub.prod-bc-attr.
                   find first buf_prod-bc-attr where buf_prod-bc-attr.b-code eq buf_prod-bc.b-code
                                                 and buf_prod-bc-attr.b-str eq buf_prod-bc.b-str 
                                                 and buf_prod-bc-attr.attr-code eq {&mark}
                   no-lock no-error.
                end. 
          
                create TempBCode.
              
                assign
                   TempBCode.gds-code = buf_goods.gds-code
                   TempBCode.b-str = buf_prod-bc.b-str            
                   TempBCode.unit-cli = buf_bar-code.unit-cli
                   TempBCode.cliBaseRate = cliBaseRate 
                no-error.

                if error-status:error
                then do:
                   delete TempBCode.
                   logWrite:WriteFileToLog(substitute ( "Ошибка передачи бар-кода &1 в ТСД.", buf_prod-bc.b-str)).
                end.
                if available buf_prod-bc-attr and logical(buf_prod-bc-attr.attr-value) then myflagsbarcode:isMark = true . /* баркод требует маркировку */

                if iprotocol eq "1.0" 
                then
                   TempBCode.priceSale = if (myflagsbarcode:isMark) then (-1 * priceSale ) else priceSale .
                else 
                   TempBCode.priceSale = priceSale .
                   TempBCode.flags = myflagsbarcode:FlagsToInt .
             end.
             
          end.
       end.
    end.
  end.
   
  method public void GoodsPrint (type as char):
    if    type eq "xml"
       or type eq "json"
    then do on error undo, leave:
       define variable hDset as handle no-undo.
       hDset = CreateDsGoods().
          
       ttprint(type, hDset).
       finally:
           delete object hDset no-error.
        end.   
    end.
    else do:
       if type eq ""
       then
          type = "temp_tsd.txt".
    
    
    tsdstreamopen( type).
    cicle:
    for each tt-goods:
            put stream tsdstream unformatted 
        string (tt-goods.gds-code) + {&delimiteFld} + 
        trim (tt-goods.gds-name, chr (9)) + {&delimiteFld} + 
        tt-goods.unit-base + {&delimiteFld} +
        decToString( 0 /*tt-goods.priceSale */) + {&delimiteFld} +
        decToString(0 /*tt-goods.vatPc */) + {&delimiteFld} +
        tt-goods.countryName  + {&delimiteFld} +
                "Состав" /*tt-goods.struct*/ + {&delimiteFld} +
        decToString(tt-goods.factQnty) + {&delimiteFld} + 
        decToString(tt-goods.freeQnty) + {&delimiterLine}.

    end.
    
    tsdstreamclose().
     if type = "temp_tsd.txt"
       then
          setResult(type).
     end.    
  end.

  method public void BarcodesClear ():
     empty temp-table TempBCode.
  end.
  
    
  method public void GoodsAndBarcodesClear ():
     GoodsClear().
     BarcodesClear().
     empty temp-table tt-barcodes. 
  end.
  method public void getGoodsAndBarcodes (input iprotocol as char, idir as char):
     GoodsAndBarcodesClear().
     getGoodsAndBarcodes (yes, yes, iprotocol).
     GoodsAndBarcodesPrint(resType,idir,iprotocol).
  end.
  
  method public void GoodsAndBarcodesPrint (input type as char, idir as character, iprotocol as character):
     if    type eq "xml"
        or type eq "json"
     then do on error undo, leave:
        define variable hDset as handle no-undo.
        hDset = CreateDsGoodsAndBarcodes().
        for each tt-Goods no-lock:
           create tt-barcodes.
           tt-barcodes.gds-code = tt-Goods.gds-code.
        end.
        ttprint(type, hDset).
        if (idir ne "" and idir ne ?)
        then
           writeResult(idir + "\TH_goods." + resType,"utf-8").
        finally:
           delete object hDset no-error.
        end.   
     end.
     else do:
        GoodsPrint(idir + "\TH_goods.txt").
        BarcodesPrint(idir + "\TH_barcodes.txt", iprotocol).
     end.
  end.

  method public void getBarcodes (input iprotocol as char):
    getGoodsAndBarcodes(no,yes,iprotocol).  
  end.
  
  method public void BarcodesPrint (type as char, iprotocol as character):
     if    type eq "xml"
       or type eq "json"
    then do on error undo, leave:
       define variable hDset as handle no-undo.
       hdset = CreateDsBarcodes ().
    
       ttprint(type,hDset).
       finally:
           delete object hDset no-error.
        end.   
    end.
    else do:
       if type eq ""
       then
          type = "temp_tsd.txt".
    
    
       tsdstreamopen(type).

    if iprotocol = "1.0" or iprotocol = ""  then do:
        for each TempBCode:
            put stream tsdstream unformatted
            string (TempBCode.gds-code) + {&delimiteFld} +
            TempBCode.b-str + {&delimiteFld} +
            decToString( TempBCode.priceSale) + {&delimiteFld} +
            TempBCode.unit-cli + {&delimiteFld} +
            decToString(TempBCode.cliBaseRate) + {&delimiterLine} .
        end .
        end.
     else do:
        for each TempBCode:
            put stream tsdstream unformatted
            string (TempBCode.gds-code) + {&delimiteFld} +
            TempBCode.b-str + {&delimiteFld} +
            decToString( TempBCode.priceSale) + {&delimiteFld} +
            TempBCode.unit-cli + {&delimiteFld} +
            decToString(TempBCode.cliBaseRate) + {&delimiteFld} +
            string(TempBCode.flags) + {&delimiterLine} .
        end.         
    end.
    
    tsdstreamclose().
       if type = "temp_tsd.txt"
       then
          setResult(type).
     end.
    
    BarcodesClear().
  end.

  
  method public logical ImpWB (table TempTrnDoc, table TempDocLine, table TempMarkLine, userId_ as char):

    define buffer buf_trn-doc       for ub.trn-doc.
    define buffer buf_doc-line      for ub.doc-line.
    define buffer buf_doc-line-attr for ub.doc-line-attr.
    define buffer gen-attr for ub.gen-attr.
    define buffer goods for ub.goods.
    define variable adapterOra-i516 as class   AdapterOra-i516.
    define variable glog           as logical   no-undo.
    define variable mes            as character no-undo.
    define variable hLibMarks      as handle    no-undo.
    define variable ii             as integer   no-undo.
    define variable varzero-string as logical   no-undo.

    define variable myflagsDoc     as class flagsdoc     no-undo.

    find first TempTrnDoc.
    if TempTrnDoc.ext-doc-code = {&TDEDT_Inv} then TempTrnDoc.Flags_ = 1 .
    myflagsDoc = new flagsdoc ().
    myflagsDoc:setFlagsToInt(TempTrnDoc.Flags_).
    
    find first buf_trn-doc exclusive-lock where buf_trn-doc.doc-code = TempTrnDoc.ext-doc-code
            and
            ( 
              ((buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} 
              or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem}
              or buf_trn-doc.ext-doc-type = {&TDEDT_Inv})
              and buf_trn-doc.flag_ = true
              and buf_trn-doc.status_ = {&permitted})
            or 
              ((buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} 
              or buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem})
              and buf_trn-doc.flag_ = true
              and buf_trn-doc.status_ = {&wayb})
            )  no-error.
    if available buf_trn-doc then 
    do:   
      
/*      output to "marks.txt".                                                                                                                    */
/*      for each gen-attr where num-entries (gen-attr.p-key, {&delim-key}) > 6 and entry (8, gen-attr.p-key, {&delim-key}) = buf_trn-doc.doc-code:*/
/*        export gen-attr.                                                                                                                        */
/*      end.                                                                                                                                      */
/*      put skip "полученные с TSD" skip.                                                                                                         */
/*      for each TempMarkLine:                                                                                                                    */
/*        export TempMarkLine.                                                                                                                    */
/*      end.                                                                                                                                      */
/*      output close.                                                                                                                             */
      
      if myflagsDoc:isDocMarkOn
      then do:
        for each TempDocLine no-lock where not TempDocLine.fact-qnty = 0 break by TempDocLine.gds-code:
          for each TempMarkLine where lookup (TempMarkLine.PartIDTH, TempDocLine.PartIDTH, {&delim-par}) > 0 and TempMarkLine.Sts = "TH" no-lock:
            for each gen-attr where gen-attr.p-key = TempMarkLine.PartIDTH and gen-attr.attr-code = TempMarkLine.MarkCode and gen-attr.table-name = {&excise-mark}:
              delete gen-attr.
            end.
          end.
        end.
        for each TempMarkLine where TempMarkLine.Sts = "crTSD" no-lock:
          create gen-attr.
          gen-attr.p-key = TempMarkLine.PartIDTH.
          gen-attr.attr-code = TempMarkLine.MarkCode.
          gen-attr.table-name = {&excise-mark}.
          gen-attr.whole-send-news = 0.
        end.
      end.
      
      for each TempDocLine no-lock break by TempDocLine.gds-code:
        find first goods where goods.gds-code  = TempDocLine.gds-code
          no-lock no-error .
        find first buf_doc-line exclusive-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code
          and buf_doc-line.artic = goods.artic
          and buf_doc-line.prod-type = goods.prod-type
          and buf_doc-line.prod-code = goods.prod-code
          no-error  .
        if available buf_doc-line then do:
          
        end.
        else do:
          logWrite:WriteFileToLog( substitute ( "В накладной &1 отсутсвует товар с кодом &2.", TempTrnDoc.ext-doc-code, TempDocLine.gds-code )).
          buf_trn-doc.ps = if buf_trn-doc.ps begins "@" then substitute ( "пропущен товар с кодом (штрих-код &3) &1&2.", TempDocLine.gds-code, {&new-line}, TempDocLine.b-code ) else substitute ( "&1&3 пропущен товар с кодом &2.",buf_trn-doc.ps, TempDocLine.gds-code, {&new-line} ).
          delete TempDocLine.
          next.
        end.
      end.
      os-delete value (search ("doctsd.txt")) no-error.
      os-delete value (search ("newdoctsd.txt")) no-error.
      output stream str1 to value ("doctsd.txt").
      output stream str2 to value ("newdoctsd.txt").
      for each TempDocLine where TempDocLine.is-tsd-qnty = true:
        put stream str1 unformatted TempDocLine.b-code "," TempDocLine.fact-qnty skip.
      end.
      for each TempDocLine where TempDocLine.is-tsd-qnty = false:
        put stream str2 unformatted TempDocLine.b-code "," TempDocLine.fact-qnty skip.
      end.
      output stream str1 close.
      output stream str2 close.
      if can-find (first TempDocLine)
      then do: 
        run gbl/filnline.p (input ("doctsd.txt"), output varzero-string).
        if varzero-string 
        then do:
          run str/scantsd.p ( 2, input no , input recid(buf_trn-doc) ,input "doctsd.txt", if myflagsDoc:isDocMarkOn then "rsvmarks" else "" ) no-error.
          if error-status:error then do:
            LogWrite:LogStr = LogWrite:LogStr + {&new-line} + return-value. 
            logWrite:WriteFileToLog(LogWrite:LogStr).
            SomeStr = getStatusXml(false, LogWrite:LogStr).
            os-delete value (search ("doctsd.txt")) no-error.
            os-delete value (search ("newdoctsd.txt")) no-error.
            return false.
          end.
/*          else LogWrite:LogStr = LogWrite:LogStr.*/
        end.
  
        run gbl/filnline.p (input ("newdoctsd.txt"), output varzero-string).
        if varzero-string 
        then do:
          run str/scantsd.p ( 1, input no , input recid(buf_trn-doc) ,input "newdoctsd.txt", if myflagsDoc:isDocMarkOn then "rsvmarks" else "" ) no-error.
          if error-status:error then do:
            LogWrite:LogStr = LogWrite:LogStr + {&new-line} + return-value. 
            logWrite:WriteFileToLog(LogWrite:LogStr).
            SomeStr = getStatusXml(false, LogWrite:LogStr).
            os-delete value (search ("doctsd.txt")) no-error.
            os-delete value (search ("newdoctsd.txt")) no-error.
            return false.
          end.
/*          else LogWrite:LogStr = LogWrite:LogStr.*/
        end.
  
      end.
      os-delete value (search ("doctsd.txt")) no-error.
      os-delete value (search ("newdoctsd.txt")) no-error.
      
      run gbl/calc-trn.p (?, recid(buf_trn-doc)) no-error .
      
      SomeStr = getStatusXml(true, "").
      return true.
      
      
    end.
    else 
    do:
      adapterOra-i516 = new AdapterOra-i516().
      
      adapterOra-i516:SetTempTable(table TempTrnDoc, table TempDocLine, userId_).
      
      adapterOra-i516:WriteDB(output glog).
  
      logWrite:WriteFileToLog(adapterOra-i516:StrLog).
      delete object AdapterOra-i516.
  
      if glog
        then do:
          SomeStr = getStatusXml(true, "").
          return true.
        end.
        else do:
          SomeStr = getStatusXml(false, LogWrite:LogStr).
          return false.
        end.
    end.
    
  end.
 
    method public logical ImpMarksInv (table TempTrnDoc, table TempDocLine, table TempMarkLine):
    
        def    var      v-utd-db-num   as integer   no-undo.
        def    var      v-utd-doc-id   as integer   no-undo.
        def    var      v-ext-doc-code as character no-undo.
        define variable vLineNumWith   as integer   no-undo .
        define variable vLineNum       as integer   no-undo .  
        define variable vError         as logical   no-undo .
        
        define buffer buf_utd-marking-lines for ub.utd-marking-lines.
        define buffer buf_utd               for ub.utd .
        define buffer bf_utd                for ub.utd .
        define buffer buf_utd-attr          for ub.utd-attr .
        define buffer bf_utd-attr           for ub.utd-attr .
        define buffer buf_utd-lines         for ub.utd-lines .
        define buffer bf_utd-lines          for ub.utd-lines .

        define buffer bf_utd-marking-lines  for ub.utd-marking-lines .

        for each TempTrnDoc :
            find first ub.clients no-lock where ub.clients.obj-code = TempTrnDoc.obj-code and
                ub.clients.obj-type = TempTrnDoc.obj-type no-error .
            if error-status:error
                then next.
            create buf_utd .

            assign
                buf_utd.DocumentDate = today
                buf_utd.sts          = ObjSrv:Env:Utd:Sts:TH:NewStatus:KeyIntDB
                buf_utd.obj-code     = ub.clients.obj-code
                buf_utd.obj-type     = ub.clients.obj-type
                buf_utd.host-code    = ub.clients.host-code
                buf_utd.EDocType     = objSrv:Env:Utd:EDocType:Mark_Collect:KeyIntDB
                .

            validate buf_utd .
            assign
                buf_utd.DocumentNumber = string(buf_utd.doc-id) + "-" + string(ub.clients.obj-code) + substring(ub.clients.obj-type,1,1) .
            create buf_utd-attr .
            assign
                buf_utd-attr.db-num     = buf_utd.db-num
                buf_utd-attr.doc-id     = buf_utd.doc-id
                buf_utd-attr.attr-code  = "is-initial-set"
                buf_utd-attr.attr-value = string(true) .
            .
            release buf_utd-attr .

            create bf_utd .
      
            assign
                bf_utd.DocumentDate = today
                bf_utd.sts          = ObjSrv:Env:Utd:Sts:TH:NewStatus:KeyIntDB
                bf_utd.obj-code     = ub.clients.obj-code
                bf_utd.obj-type     = ub.clients.obj-type
                bf_utd.host-code    = ub.clients.host-code
                bf_utd.EDocType     = objSrv:Env:Utd:EDocType:Mark_Collect:KeyIntDB
                .

            validate bf_utd .
            assign 
                bf_utd.DocumentNumber = string(bf_utd.doc-id) + "-" + string(ub.clients.obj-code) + substring(ub.clients.obj-type,1,1) .
            create bf_utd-attr .
            assign
                bf_utd-attr.db-num     = bf_utd.db-num
                bf_utd-attr.doc-id     = bf_utd.doc-id
                bf_utd-attr.attr-code  = "is-initial-set"
                bf_utd-attr.attr-value = string(false) .
            .
            release bf_utd-attr .     
      
            vLineNum = 0 .
            vLineNumWith = 0 .

            for each TempDocLine:
                find first ub.goods no-lock where ub.goods.gds-code = TempDocLine.gds-code no-error . 
                if error-status:error
                    then  
                do:
                    logWrite:WriteFileToLog(substitute ("Товар не найден &1", TempDocLine.gds-code)).
                    vError = true .
                    next .
                end.
                find first ub.gds-obj-attr where ub.gds-obj-attr.gds-code = ub.goods.gds-code and
                    ub.gds-obj-attr.obj-code = ub.clients.obj-code and ub.gds-obj-attr.obj-type = ub.clients.obj-type
                    and ub.gds-obj-attr.attr-code = {&attr-mark-collect-type} no-lock no-error.
                                          
                        tml_:
                        for each TempMarkLine where TempMarkLine.PartIDTH = TempDocLine.PartIDTH and TempMarkLine.MarkCode <> "" :
                               define variable vmes as character no-undo.
                              if not (available ub.gds-obj-attr and (gds-obj-attr.attr-value eq "1" or gds-obj-attr.attr-value eq "2"))
                              then
                              vmes = CrCheckMarkDoc(buf_utd.obj-type, buf_utd.obj-code,
                                          buf_utd.db-num, buf_utd.doc-id,
                                          TempMarkLine.MarkCode,
                                      true).
                              else
                              vmes = CrCheckMarkDoc(bf_utd.obj-type, bf_utd.obj-code,
                                          bf_utd.db-num, bf_utd.doc-id,
                                          TempMarkLine.MarkCode,
                                       false).
                               if vmes ne ? and vmes ne ""
                               then
                                  logWrite:WriteFileToLog(vmes).
                        end. /* tml_: */

            end. /* for each TempDocLine: */

            find first bf_utd-lines no-lock where bf_utd-lines.doc-id = bf_utd.doc-id and
            bf_utd-lines.db-num = bf_utd.db-num no-error .
            if not available (bf_utd-lines) then delete bf_utd .
            find first buf_utd-lines no-lock where buf_utd-lines.doc-id = buf_utd.doc-id and
            buf_utd-lines.db-num = buf_utd.db-num no-error .
            if not available (buf_utd-lines) then delete buf_utd .
            if vError = true then  undo, return false.              
        end. /* for each TempTrnDoc */
    
        
    end.
 
  
  method public logical ImpInventory (table TempTrnDoc, table TempDocLine, userId_ as char):

    define buffer buf_trn-doc       for ub.trn-doc.
    define buffer buf_doc-line      for ub.doc-line.
    define buffer buf_doc-line-attr for ub.doc-line-attr.
    define buffer bfTempDocLine for TempDocLine.  
    define buffer bfTempDocLineTSD  for TempDocLineTSD .
    define buffer bf_inv-doc-attr   for ub.inv-doc-attr .
    define buffer inv-doc-attr for ub.inv-doc-attr.
    define buffer trn-doc for ub.trn-doc.
    define buffer goods for ub.goods. 
    define buffer doc-line for ub.doc-line.
    define buffer prod-bc for ub.prod-bc. 
    define buffer clients for ub.clients.
    define buffer bar-code for ub.bar-code.
    define buffer marking for ub.marking.
            
    define variable adapterOra-i506 as class   AdapterOra-i506.
    define variable varzero-string  as logical no-undo.
    define variable myflagsDoc     as class flagsdoc     no-undo.
    define variable myflagsDocLine as class flagsdocline no-undo.
    define variable invMulti as logical no-undo .
    define variable ii              as integer   no-undo init 0 .
    define variable vardoc-code     like ub.trn-doc.doc-code no-undo.
    define variable v-marking-type  as character no-undo .
    define variable v-type          as character no-undo .
    define variable isManual        as logical   no-undo .
    def    var      Marking         as class     mark            no-undo .

    find first TempTrnDoc.
    myflagsDoc = new flagsdoc ().
    myflagsDocLine = new flagsdocline ().
    myflagsDoc:setFlagsToInt(TempTrnDoc.Flags_).

    find first buf_trn-doc no-lock where buf_trn-doc.doc-code = TempTrnDoc.ext-doc-code
      and buf_trn-doc.status_ = {&permitted} no-error.
    if available buf_trn-doc then 
    do:
      invMulti = false .
      ii = 0 .
      find first inv-doc-attr no-lock where inv-doc-attr.doc-code = TempTrnDoc.ext-doc-code and
        inv-doc-attr.attr-code = 'invMultDevice' and inv-doc-attr.attr-value = string(true) no-error .
      if available (inv-doc-attr) then invMulti = true .
      if invMulti = false then next .  
      if invMulti then 
      do:
        block-trn: 
        for each trn-doc no-lock where  
                                      (trn-doc.doc-code eq TempTrnDoc.ext-doc-code
                                      and trn-doc.status_ = {&inquiry})  
                                   or (trn-doc.doc-code begins TempTrnDoc.ext-doc-code + "/"
                                   and trn-doc.status_ = {&inquiry}) by trn-doc.doc-code desc:
  
          leave block-trn.
        end.                         
        if available (trn-doc) then 
        do:
          ii = integer(entry(2,trn-doc.doc-code,"/")) .
          TempTrnDoc.ext-doc-code = entry(1,trn-doc.doc-code,"/") + "/" + string(ii + 1) .
        end. 
        else TempTrnDoc.ext-doc-code = TempTrnDoc.ext-doc-code + "/" + string(ii + 1) .
        TempTrnDoc.Status_= {&inquiry} .
      end.
      if invMulti then 
      do:
        create trn-doc .
        trn-doc.doc-code = TempTrnDoc.ext-doc-code .
        trn-doc.status_ = {&inquiry} .
        trn-doc.flag_ = no .
        buffer-copy buf_trn-doc except doc-code status_ flag_ to trn-doc .
        find first inv-doc-attr exclusive-lock where inv-doc-attr.doc-code = trn-doc.doc-code
        and inv-doc-attr.attr-code = 'invMultDevice' no-error .
        if not available (inv-doc-attr) then do:
        create inv-doc-attr .
        assign
        inv-doc-attr.doc-code = trn-doc.doc-code
        inv-doc-attr.attr-code = 'invMultDevice' .
        end.
        inv-doc-attr.attr-value = string(true) .
      end.
      
      for each TempDocLine no-lock break by TempDocLine.gds-code:
        find first goods where goods.gds-code  = TempDocLine.gds-code
          no-lock no-error .
        find first buf_doc-line exclusive-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code
          and buf_doc-line.artic = goods.artic
          and buf_doc-line.prod-type = goods.prod-type
          and buf_doc-line.prod-code = goods.prod-code
          no-error  .
        if available buf_doc-line then do:
          if invMulti then do:
          create doc-line .
          doc-line.doc-code = TempTrnDoc.ext-doc-code .
          buffer-copy buf_doc-line except doc-code to doc-line .
          assign
          doc-line.doc-qnty = TempDocLine.fact-qnty .
          doc-line.fact-qnty = TempDocLine.fact-qnty - TempDocLine.doc-qnty .
          end.
/*          else do:                                                               */
/*          assign                                                                 */
/*          buf_doc-line.doc-qnty = TempDocLine.fact-qnty .                        */
/*          buf_doc-line.fact-qnty = TempDocLine.fact-qnty - TempDocLine.doc-qnty .*/
/*          end.                                                                   */
          find first buf_doc-line-attr where buf_doc-line-attr.doc-code = buf_doc-line.doc-code and buf_doc-line-attr.gds-code = goods.gds-code and buf_doc-line-attr.attr-code = "tsd-qnty" no-lock no-error.
          if not available buf_doc-line-attr and first-of (TempDocLine.gds-code)
            then do:
              create buf_doc-line-attr.
              assign
                buf_doc-line-attr.attr-code = "tsd-qnty"
                buf_doc-line-attr.gds-code = goods.gds-code
                buf_doc-line-attr.doc-code = buf_doc-line.doc-code
              .
            end.
            else do:
              TempDocLine.is-tsd-qnty = true.
            end.
            release doc-line .
        end.
        else do:
          logWrite:WriteFileToLog(substitute ( "В инвентаризации &1 отсутсвует товар с кодом &2.", TempTrnDoc.ext-doc-code, TempDocLine.gds-code )).
          buf_trn-doc.ps = if buf_trn-doc.ps begins "@" then substitute ( "пропущен товар с кодом (штрих-код &3) &1&2.", TempDocLine.gds-code, {&new-line}, TempDocLine.b-code ) else substitute ( "&1&3 пропущен товар с кодом &2.",buf_trn-doc.ps, TempDocLine.gds-code, {&new-line} ).
          delete TempDocLine.
          next.
        end.
      end.
    end.
    else 
    do:
      if not (TempTrnDoc.ext-doc-code begins "TSD-") then do:
/*          run gbl/inidebug.p.                                                                    */
/*      LogWrite:LogStr = "Нет инвентаризации в статусе разр+ с кодом: " + TempTrnDoc.ext-doc-code.*/
/*      SomeStr = getStatusXml(true, "Нет инвентаризации в статусе разр+ с кодом: " + TempTrnDoc.ext-doc-code).*/
  
      return true.
      end.
        /* Проверка на создание итогового документа */
    find first bf_inv-doc-attr no-lock where bf_inv-doc-attr.attr-code = "ItogInv" and bf_inv-doc-attr.attr-value = TempTrnDoc.ext-doc-code no-error .
    if available (bf_inv-doc-attr) then leave .       
   
    empty temp-table TempDocLineTSD .
    find first clients no-lock where clients.obj-code = TempTrnDoc.obj-code and
      clients.obj-type = TempTrnDoc.obj-type no-error .
    if available (clients) then 
    do:    
      /*Загрузка инвенаризации с ТСД*/
      /*Проверка товаров*/    
      isManual = true .
      for each TempDocLine:
        find first goods no-lock where string(goods.gds-code) = TempDocLine.b-code no-error .
        if available (goods) then 
        do:
          createTempGoods(buffer goods,1, false) .
        end.
        else 
        do:
          find first prod-bc no-lock where (string(prod-bc.b-code) = TempDocLine.b-code or prod-bc.b-str = TempDocLine.b-code) no-error .
          if available (prod-bc) then 
          do:
            find first bar-code no-lock where bar-code.b-code = prod-bc.b-code .
            find first goods no-lock where goods.gds-code = bar-code.gds-code .
            createTempGoods(buffer goods,bar-code.cli-base-rate,false) .
          end.
          else 
          do:
            find first marking no-lock where marking.mark = TempDocLine.b-code no-error .
            if available (marking) then 
            do:
              find first goods no-lock where goods.gds-code = marking.gds-code .
              createTempGoods(buffer goods,marking.box-qnty,true) .
            end.
            else 
            do:
              createTempGoodsError() .
            end.
          end.
        end.
      end.
       /*проверяем на помарочный учет*/
      for each TempDocLineTSD where not TempDocLineTSD.Flags_error:
        &scop proc-name gds-attr-value
        {&run_proc_attr-lib}
          (input  TempDocLineTSD.gds-code
          ,input  {&attr-mark-type}
          ,output v-marking-type
          ,output v-type
          ) no-error .
        if error-status :error
          then 
        do:
          undo, return error return-value .
        end.
        if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(clients.obj-type, clients.obj-code):GetIsMarkingForType(v-marking-type) 
          then 
        do:
          TempDocLineTSD.mark-type = v-marking-type .
          find first marking no-lock where marking.mark = TempDocLineTSD.mark and marking.sts = Marking:FreeZone:KeyIntDB no-error .
          if not available (marking) then 
          do:
            TempDocLineTSD.Flags_error = true.
          end.
        end.
      end.
      if can-find(TempDocLineTSD where TempDocLineTSD.mark-type <> "") then 
      do:
        if can-find(TempDocLineTSD where TempDocLineTSD.mark-type = "") then 
        do:
          for each TempDocLineTSD where not TempDocLineTSD.Flags_error and TempDocLineTSD.mark-type <> "":
            TempDocLineTSD.Flags_error = true .
          end.
        end.  
      end.  
      find first TempDocLineTSD no-error .
      if available (TempDocLineTSD) then 
      do:
        /*номер документа*/
        vardoc-code = docCode("main", clients.obj-type, clients.obj-code, ?) no-error .
        if error-status:error then 
        do:
          logWrite:WriteFileToLog("Ошибка при генерации номера документа.") .
          SomeStr = getStatusXml(false, "Ошибка при генерации номера документа.").
          return false.
        end.
      end.
      find first TempDocLineTSD where not TempDocLineTSD.Flags_error no-error .
      if available (TempDocLineTSD) then 
      do:
        /*создаем накладную*/
        createTrn( buffer clients ,vardoc-code,userId_).

        createAttrInv(vardoc-code,"isManual",string(true)).
        /*Создаем линии для накладной*/
        for each bfTempDocLineTSD where not bfTempDocLineTSD.Flags_:
          createDocLine(vardoc-code, bfTempDocLineTSD.gds-code, bfTempDocLineTSD.fact-qnty).
        end.
      end.      
      find first TempDocLineTSD where TempDocLineTSD.Flags_error no-error .
      if available (TempDocLineTSD) then 
      do:
        /*создаем ошибочную накладную*/
        createTrn(buffer clients, vardoc-code + "-M",userId_).
        createAttrInv(vardoc-code + "-M","isManualError",string(true)).
        for each bfTempDocLineTSD where bfTempDocLineTSD.Flags_:
          find first goods where goods.gds-code = bfTempDocLineTSD.gds-code no-error .
          if available (goods) then do:
            createDocLine(vardoc-code + "-M", bfTempDocLineTSD.gds-code, bfTempDocLineTSD.fact-qnty).
          end.
          else do:
            createDocLineError(vardoc-code + "-M", bfTempDocLineTSD.artic, bfTempDocLineTSD.prod-code, bfTempDocLineTSD.prod-type, bfTempDocLineTSD.fact-qnty).
          end.
        end.
      end.
    end.      
    end.
    
    if can-find (first TempDocLine where TempDocLine.is-tsd-qnty = true) and
       not invMulti then
    do:
      empty temp-table TempDocLineIsTSD.
    for each TempDocLine where TempDocLine.is-tsd-qnty = true:
        create TempDocLineIsTSD.
        buffer-copy TempDocLine to TempDocLineIsTSD no-error.
        if error-status:error then do:
          logWrite:WriteFileToLog(error-status:get-message(1)).
          SomeStr = getStatusXml(false, LogWrite:LogStr).
          return false.
    end.
    end.
      run str/scantsd.p ( 2, input no , input recid(buf_trn-doc) ,input table TempDocLineIsTSD, if myflagsDoc:isDocMarkOn then "rsvmarks" else "" ) no-error.
        if error-status:error then do:
        logWrite:WriteFileToLog(return-value).
          SomeStr = getStatusXml(false, LogWrite:LogStr).
          return false.
        end.
/*        else LogWrite:LogStr = LogWrite:LogStr + {&new-line} + return-value.*/
      end.

    if can-find (first TempDocLine where TempDocLine.is-tsd-qnty = false) and 
       not isManual and 
       not invMulti then 
    do:
      empty temp-table TempDocLineIsTSD.
      for each TempDocLine where TempDocLine.is-tsd-qnty = false:
        create TempDocLineIsTSD.
        buffer-copy TempDocLine to TempDocLineIsTSD no-error.
        if error-status:error then do:
           logWrite:WriteFileToLog(error-status:get-message(1)).
          SomeStr = getStatusXml(false, LogWrite:LogStr).
          return false.
        end.
        end.
      run str/scantsd.p ( 1, input no , input recid(buf_trn-doc) ,input table TempDocLineIsTSD, if myflagsDoc:isDocMarkOn then "rsvmarks" else "" ) no-error.
      if error-status:error then do:
        logWrite:WriteFileToLog(return-value). 
        SomeStr = getStatusXml(false, LogWrite:LogStr).
        return false.
      end.
      end.

    SomeStr = getStatusXml(true, "").

    return true.
  end method.
  method public logical updatedocument (
      docType as char,
      table TempTrnDoc   ,
      table TempDocLine ,
      table TempMarkLine ,
      userid_ as char
      ):
     define variable ErrStatus as logical no-undo.
    define buffer bfTempDocLine for TempDocLine.
    define buffer buf_bar-code  for ub.bar-code.
    define buffer buf_prod-bc   for ub.prod-bc.
    define buffer buf_place     for ub.place.
    
     case docType:

        when {&TDEDT_Inv} then 
          do:
            if ImpInventory (table TempTrnDoc, table TempDocLine, userId_)
            then ErrStatus = false.
            else ErrStatus = true.

          end.
        when "UTD_DOC" then 
          do:
            if ImpUTDDOC (table TempTrnDoc, table TempDocLine, table TempMarkLine)
            then ErrStatus = false.
            else ErrStatus = true.

          end.
        when "InvIntroduce" then 
          do:
            if ImpUTDIntroduce(table TempTrnDoc, table TempDocLine, table TempMarkLine)
            then ErrStatus = false.
            else ErrStatus = true.

          end.
        when "invmark" then 
          do:
            if ImpInvMarksDOC (table TempTrnDoc, table TempDocLine, table TempMarkLine)
            then ErrStatus = false.
            else ErrStatus = true.

          end.
        when "UTD_Introduce" then 
          do:
            if ImpUTDIntroduce(table TempTrnDoc, table TempDocLine, table TempMarkLine)
            then ErrStatus = false.
            else ErrStatus = true.

          end.
         when "MarksInv" then 
          do:
            if ImpMarksInv (table TempTrnDoc, table TempDocLine, table TempMarkLine)
            then ErrStatus = false.
            else ErrStatus = true.

          end.
        otherwise  
        do:
          for each TempDocLine no-lock where not TempDocLine.b-code matches ("*" + string (TempDocLine.gds-code) + "*"):
                      
            find first bfTempDocLine where bfTempDocLine.gds-code = TempDocLine.gds-code and bfTempDocLine.b-code matches ( "*" + string (bfTempDocLine.gds-code) + "*")  no-error.
            find buf_bar-code no-lock where 
              buf_bar-code.gds-code = TempDocLine.gds-code and TempDocLine.b-code matches ("*" + string(buf_bar-code.b-code)+ "*") no-error.
            
            
            if not available buf_bar-code then 
            do:
              
              find first buf_prod-bc no-lock where buf_prod-bc.b-str = TempDocLine.b-code no-error.
              if available buf_prod-bc 
                then 
              do:
                find first buf_bar-code no-lock where buf_bar-code.b-code = buf_prod-bc.b-code and buf_bar-code.gds-code = TempDocLine.gds-code no-error.
              end.
              
              if not available buf_bar-code then 
              do:
                LogWrite:LogStr =  LogWrite:LogStr + {&new-line} + 'Отправлен ответ на запрос типа "WAYBILL".' + {&new-line} + "Не известный штрих-код:" + TempDocLine.b-code.
                logWrite:WriteFileToLog( "Не известный штрих-код:" + TempDocLine.b-code).
                SomeStr = "Не известный штрих-код:" + TempDocLine.b-code.
                ErrStatus = true.
                return false.
              end.
              
            end.

            if not available bfTempDocLine
              then 
            do:
              create bfTempDocLine.
              assign
                bfTempDocLine.gds-code = TempDocLine.gds-code
                bfTempDocLine.b-code   = string (TempDocLine.gds-code)
                .
            end.
            
            assign
              bfTempDocLine.doc-qnty  = bfTempDocLine.doc-qnty + TempDocLine.doc-qnty * buf_bar-code.cli-base-rate
              bfTempDocLine.fact-qnty = bfTempDocLine.fact-qnty + TempDocLine.fact-qnty * buf_bar-code.cli-base-rate
              bfTempDocLine.RowSum    = bfTempDocLine.RowSum + TempDocLine.RowSum
              .
            delete TempDocLine.
          
          end.
          
          for each TempDocLine no-lock:
            assign
              TempDocLine.price-rubl = TempDocLine.RowSum / TempDocLine.fact-qnty.
            .
            
          end.
          
          if ImpWB(table TempTrnDoc, table TempDocLine, table TempMarkLine, userId_)
          then ErrStatus = false.
          else ErrStatus = true.
          
        end.

      end.
      return ErrStatus.
   end.
method public void createTempGoods(buffer goods for goods, icli-base-rate as decimal , mark_ as logical):
  define buffer del_TempDocLineTSD for TempDocLineTSD .
  define buffer marking for ub.marking.
  if not mark_ then do:
  find first TempDocLineTSD where TempDocLineTSD.artic = goods.artic and
    TempDocLineTSD.prod-code = goods.prod-code and
    TempDocLineTSD.prod-type = goods.prod-type no-error . 
  if not available (TempDocLineTSD) then 
  do:
    create TempDocLineTSD .
    assign
      TempDocLineTSD.gds-code  = goods.gds-code
      TempDocLineTSD.artic     = goods.artic
      TempDocLineTSD.prod-code = goods.prod-code
      TempDocLineTSD.prod-type = goods.prod-type
      .
  end.

  if TempDocLine.NotDict then 
  TempDocLineTSD.fact-qnty = TempDocLineTSD.fact-qnty + TempDocLine.fact-qnty * icli-base-rate .
  else TempDocLineTSD.fact-qnty = TempDocLineTSD.fact-qnty + TempDocLine.fact-qnty .
  end.
  /*марки*/
  else 
  do:
    find first marking no-lock where marking.mark = TempDocLine.b-code no-error .
    if available (marking) then do:
          find first TempDocLineTSD where TempDocLineTSD.artic = goods.artic and
    TempDocLineTSD.prod-code = goods.prod-code and
    TempDocLineTSD.prod-type = goods.prod-type no-error . 
      if not available (TempDocLineTSD) then 
  do:
    create TempDocLineTSD .
    assign
      TempDocLineTSD.gds-code  = goods.gds-code
      TempDocLineTSD.artic     = goods.artic
      TempDocLineTSD.prod-code = goods.prod-code
      TempDocLineTSD.prod-type = goods.prod-type
      TempDocLineTSD.mark = marking.mark
      TempDocLineTSD.mark-parent = marking.mark-parent
      .
      if marking.mark-parent = "" then do:
        for each del_TempDocLineTSD where del_TempDocLineTSD.mark-parent = marking.mark:
          delete del_TempDocLineTSD .
        end.
      end.
            TempDocLineTSD.fact-qnty   = TempDocLineTSD.fact-qnty + TempDocLine.fact-qnty * marking.box-qnty.
      end.
      else do:
        if not TempDocLineTSD.mark = marking.mark-parent then do:
    create TempDocLineTSD .
    assign
      TempDocLineTSD.gds-code  = goods.gds-code
      TempDocLineTSD.artic     = goods.artic
      TempDocLineTSD.prod-code = goods.prod-code
      TempDocLineTSD.prod-type = goods.prod-type
      TempDocLineTSD.mark = marking.mark
      TempDocLineTSD.mark-parent = marking.mark-parent
      .
      if marking.mark-parent = "" then do:
        for each del_TempDocLineTSD where del_TempDocLineTSD.mark-parent = marking.mark:
          delete del_TempDocLineTSD .
        end.
      end.
            TempDocLineTSD.fact-qnty   = TempDocLineTSD.fact-qnty + TempDocLine.fact-qnty * marking.box-qnty.
                
        end.  
      end.
  end.
end.
end.
  
method public void createTempGoodsError():
  find first TempDocLineTSD where TempDocLineTSD.artic = TempDocLine.b-code and
    TempDocLineTSD.prod-code = 999999 and
    TempDocLineTSD.prod-type = "орг" no-error . 
  if not available (TempDocLineTSD) then 
  do:
    create TempDocLineTSD .
    assign
      TempDocLineTSD.artic       = TempDocLine.b-code
      TempDocLineTSD.prod-code   = 999999
      TempDocLineTSD.prod-type   = "орг"
      TempDocLineTSD.Flags_error = true
      .
  end.      
    .
  TempDocLineTSD.fact-qnty = TempDocLineTSD.fact-qnty + TempDocLine.fact-qnty .
end.
  
method public void createTrn(buffer clients for clients, docCode as character, parUserId as character):
  define buffer bf_trn-doc    for ub.trn-doc .
  define buffer bf_curr-accnt for ub.curr-accnt .
  define buffer bf_sysconf    for ub.sysconf .
  define buffer shop       for ub.shop .
  
  if not available clients
  then
     return error "createTrn не передан клиент".  
    
  find first shop no-lock where shop.obj-code = clients.obj-code no-error .
  if not available shop
  then
     return error "Не найден Магазин с кодом " + string(clients.obj-code).
  find first bf_sysconf no-lock where bf_sysconf.host-code = clients.host-code .
  if not available shop
  then
     return error "Не найден Фирма с кодом " + string(clients.host-code).
  v-today = today .
  { str/crtrndoc.i
  ?
  ?
  1
  1
  clients.host-code
  {&cmp}
  clients.obj-name
  clients.db-num
  parUserId
  "' '"
  docCode
  v-today
  {&inventory}
  no
  clients.host-code
  no
  clients.obj-code
  clients.obj-type
  no
  shop.inv-pay
  "'@  '"
  no
  ?
  {&wayb}
  ?
  {&TDEDT_Inv}
  ?
  no-error
  }
  
  if error-status:error then 
  do:
    return error return-value.
  end.
  find bf_trn-doc where bf_trn-doc.doc-code = docCode.
  assign
    bf_trn-doc.tot-calc = ?.

  assign
    bf_trn-doc.status_ = {&inquiry}
    bf_trn-doc.flag_   = no
    bf_trn-doc.PS      = TempTrnDoc.ext-doc-code + ", " + string(TempTrnDoc.doc-date)
    .

  find last bf_curr-accnt where bf_curr-accnt.curr-code = bf_sysconf.base-code
    and bf_curr-accnt.exch-date <= v-today use-index pi no-lock no-error.
  if not available bf_curr-accnt then 
  do:
    message "На дату" v-today "неизвестен курс базовой валюты." SKIP
      "Сумма по документу в валюте будет рассчитана при закрытии на факт".
  end.
  else 
  do:
    assign
      bf_trn-doc.base-rate  = bf_curr-accnt.exch-rate
      bf_trn-doc.base-scale = bf_curr-accnt.exch-scale.
  END.
  ASSIGN
    bf_trn-doc.exch-code  = 0
    bf_trn-doc.exch-rate  = 1
    bf_trn-doc.exch-scale = 1.

  { str/crinvdoc.i bf_trn-doc.doc-code no-error}
  if error-status:error then return error return-value.

end.
  
method public void createAttrInv(docCode as character, attrCode as character, attrValue as character):
  define buffer inv-doc-attr for ub.inv-doc-attr.
  create inv-doc-attr .
  assign
    inv-doc-attr.doc-code   = docCode
    inv-doc-attr.attr-code  = attrCode
    inv-doc-attr.attr-value = attrValue
    .
end.
  
method public void createDocLine(pardoc-code as character, 
  pargds-code as integer, factQnty as decimal):

  define variable varis-petrolium as logical no-undo.
  define variable varis-pieces    as logical no-undo.
  define buffer cr_doc-line   for ub.doc-line.
  define buffer last_doc-line for ub.doc-line.
  define buffer new_trn-doc   for ub.trn-doc .
  define buffer new_goods     for ub.goods .
  define variable varline-num  as integer no-undo.
  define variable rec-inv-line as recid   no-undo.
  define variable v-vat-pc     as decimal no-undo .
  define variable v-slt-pc     as decimal no-undo .
  define buffer bf_sysconf for ub.sysconf .
  define buffer prt-obj for ub.prt-obj .
    
  find first new_trn-doc no-lock where new_trn-doc.doc-code = pardoc-code no-error .
  find first new_goods no-lock where new_goods.gds-code = pargds-code no-error .
  find first bf_sysconf where bf_sysconf.host-code = new_trn-doc.host-code no-lock no-error .
  find last last_doc-line where last_doc-line.doc-code = pardoc-code use-index line-num no-lock no-error.
  if not available last_doc-line then 
  do:
    assign 
      varline-num = 1.
  end.
  else 
  do:
    assign 
      varline-num = last_doc-line.line-num + 1.
  end.
  find first cr_doc-line where cr_doc-line.doc-code  = pardoc-code  and
    cr_doc-line.artic     = new_goods.artic     and
    cr_doc-line.prod-type = new_goods.prod-type and
    cr_doc-line.prod-code = new_goods.prod-code no-error.
  if not available cr_doc-line then 
  do:
    v-vat-pc = pftxvalg(new_goods.gds-code, 1, ?, new_trn-doc.host-code, new_trn-doc.obj-type, new_trn-doc.obj-code) .
    v-slt-pc = st-sltpc(recid(new_goods), recid(new_trn-doc), if available(bf_sysconf) then bf_sysconf.cash-pay else 0) .
    create cr_doc-line.
    assign
      cr_doc-line.doc-code     = pardoc-code
      cr_doc-line.artic        = new_goods.artic
      cr_doc-line.prod-type    = new_goods.prod-type
      cr_doc-line.prod-code    = new_goods.prod-code
      cr_doc-line.obj-type     = new_trn-doc.obj-type
      cr_doc-line.obj-code     = new_trn-doc.obj-code
      cr_doc-line.status_      = new_trn-doc.status_
      cr_doc-line.ext-doc-type = new_trn-doc.ext-doc-type
      cr_doc-line.prt-root     = new_goods.prt-root
      cr_doc-line.vat-pc       = v-vat-pc
      cr_doc-line.slt-pc       = v-slt-pc
      cr_doc-line.cons-vat-pc  = bf_sysconf.cons-vat-pc
      cr_doc-line.line-num     = varline-num
      .

    if ( cr_doc-line.cli-base-rate = 0 or cr_doc-line.cli-base-rate = ? )
      then
      cr_doc-line.cli-base-rate = 1 .

  end.
  find first prt-obj no-lock where prt-obj.artic = cr_doc-line.artic and
    prt-obj.prod-code = cr_doc-line.prod-code and
    prt-obj.prod-type = cr_doc-line.prod-type and
    prt-obj.obj-code = cr_doc-line.obj-code and
    prt-obj.obj-type = cr_doc-line.obj-type no-error .
  if available (prt-obj) then cr_doc-line.fact-qnty = factQnty - prt-obj.fact-qnty .
  cr_doc-line.doc-qnty = factQnty .
end.
  
method public void createDocLineError(pardoc-code as character, 
  parartic as character, parprod-code as integer, parprod-type as character, factQnty as decimal):

  define variable varis-petrolium as logical no-undo.
  define variable varis-pieces    as logical no-undo.
  define buffer cr_doc-line   for ub.doc-line.
  define buffer last_doc-line for ub.doc-line.
  define buffer new_trn-doc   for ub.trn-doc .
  define buffer new_goods     for ub.goods .
  define variable varline-num  as integer no-undo.
  define variable rec-inv-line as recid   no-undo.
  define variable v-vat-pc     as decimal no-undo .
  define variable v-slt-pc     as decimal no-undo .
  define buffer bf_sysconf for ub.sysconf .
    
  find first new_trn-doc no-lock where new_trn-doc.doc-code = pardoc-code no-error .
  find first bf_sysconf where bf_sysconf.host-code = new_trn-doc.host-code no-lock.
  find last last_doc-line where last_doc-line.doc-code = pardoc-code use-index line-num no-lock no-error.
  if not available last_doc-line then 
  do:
    assign 
      varline-num = 1.
  end.
  else 
  do:
    assign 
      varline-num = last_doc-line.line-num + 1.
  end.
    
    create cr_doc-line.
    assign
      cr_doc-line.doc-code     = pardoc-code
      cr_doc-line.artic        = parartic
      cr_doc-line.prod-type    = parprod-type
      cr_doc-line.prod-code    = parprod-code
      cr_doc-line.obj-type     = new_trn-doc.obj-type
      cr_doc-line.obj-code     = new_trn-doc.obj-code
      cr_doc-line.status_      = new_trn-doc.status_
      cr_doc-line.ext-doc-type = new_trn-doc.ext-doc-type
      cr_doc-line.line-num     = varline-num
      .
  
  cr_doc-line.doc-qnty = factQnty .
  cr_doc-line.fact-qnty = factQnty .
end.
  method public logical ImpUTDDOC (table TempTrnDoc, table TempDocLine, table TempMarkLine):
    
    def var v-utd-db-num as integer no-undo.
    def var v-utd-doc-id as integer no-undo.
    def var v-ext-doc-code as character no-undo.
         
    define buffer buf_utd-marking-lines for ub.utd-marking-lines.
    define buffer utd-marking-lines for ub.utd-marking-lines.
    define buffer utd-lines for ub.utd-lines.
    define buffer marking for ub.marking.
    
    for each TempTrnDoc :
      
      v-ext-doc-code = replace (entry (2, TempTrnDoc.ext-doc-code, "("),")","").
      assign
        v-utd-db-num = integer (entry (1, v-ext-doc-code, "_"))
        v-utd-doc-id = integer (entry (2, v-ext-doc-code, "_"))
      no-error.
      if error-status:error
        then next.
      tml_:
      for each TempMarkLine where TempMarkLine.Sts = "Check" or TempMarkLine.Sts = "CheckScan" or TempMarkLine.Sts = "CrTsd" or TempMarkLine.Sts = "Ungrouped" :
        find first utd-marking-lines where utd-marking-lines.db-num = v-utd-db-num and utd-marking-lines.doc-id = v-utd-doc-id 
          and utd-marking-lines.mark = TempMarkLine.MarkCode 
          exclusive-lock no-error.
        if available (utd-marking-lines)
        then do:
          utd-marking-lines.sts = ObjSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB.
          find first marking where marking.mark = TempMarkLine.MarkCode no-lock no-error.
/*          marking.sts = ObjSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB.*/
          if available  marking and TempMarkLine.Sts = "CheckScan"
            then ungrg(marking.mark-parent).
        end.
        else do:
          def var v-GTIN as char no-undo.
          def var v-mark-ident as char no-undo.
          v-GTIN = getGtinByDM(TempMarkLine.MarkCode) .
          v-mark-ident = GetCodeIdent(TempMarkLine.MarkCode).
          if v-GTIN <> "" then 
          do:
            find first buf_utd-marking-lines where
                  buf_utd-marking-lines.db-num = v-utd-db-num and buf_utd-marking-lines.doc-id = v-utd-doc-id 
              and buf_utd-marking-lines.mark begins TempMarkLine.MarkParent exclusive-lock no-error.
            if not available (buf_utd-marking-lines)
            then do:
              logWrite:WriteFileToLog(substitute ("Нарушена целостности либо изменен документ &1 на стороне TH", v-utd-doc-id)).
              undo, return false.
            end.
            buf_utd-marking-lines.sts = ObjSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB.
            ungrg(buf_utd-marking-lines.mark).
            create utd-marking-lines .
            assign
              utd-marking-lines.db-num    = buf_utd-marking-lines.db-num
              utd-marking-lines.doc-id    = buf_utd-marking-lines.doc-id
              utd-marking-lines.gds-code  = buf_utd-marking-lines.gds-code
              utd-marking-lines.LineNum   = buf_utd-marking-lines.LineNum
              utd-marking-lines.doc-level = buf_utd-marking-lines.doc-level + 1
              utd-marking-lines.mark      = v-mark-ident
             .
            if ismark(v-mark-ident)
            then do:
               find first marking where marking.mark = v-mark-ident exclusive-lock no-error.
               if not available (marking) 
                 then create marking .
               assign
                 marking.gds-code    = utd-marking-lines.gds-code
                 marking.mark        = v-mark-ident
                 marking.mark-parent = buf_utd-marking-lines.mark
                 marking.sts         = ObjSrv:Env:Marking:Sts:Mark:PendingVerification:KeyIntDB
                 marking.gds-ext-id  = v-GTIN
                 marking.obj-code    = TempTrnDoc.obj-code
                 marking.obj-type    = TempTrnDoc.obj-type
                 .
               marking.unit-ext = getLevelMotpByDM(v-mark-ident) .
               marking.box-qnty = getQntyUTDByDM(v-mark-ident) .
               marking.unit = getLevelUTDByDM(v-mark-ident) .
            end.
            utd-marking-lines.sts = ObjSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB.
            if available marking
            THEN
               utd-marking-lines.mark = marking.mark.
         end.
        end.
      end.
      for each TempDocLine:
         find first utd-lines no-lock where utd-lines.doc-id = v-utd-doc-id 
                                           and utd-lines.db-num = v-utd-db-num 
                                           and utd-lines.LineNum eq TempDocLine.line-num no-error.
         if available ( utd-lines)
         then
            SetAttrUtdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.linenum,"QuantityBarCode",string(TempDocLine.fact-qnty)).
        
      end.
      for each TempMarkLine where TempMarkLine.Sts = "Ungrouped" :
        find first utd-marking-lines where utd-marking-lines.mark = TempMarkLine.MarkCode no-error.
        if available (utd-marking-lines)
        then do:
/*          utd-marking-lines.sts = ObjSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB.*/
          find first marking where marking.mark = TempMarkLine.MarkCode no-error.
          marking.sts = ObjSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB.
        end.
      end.
    end.
    
  end.

  method private void ungrg (mark-parent as char):
    define buffer buf_m for ub.marking.
    for each buf_m where buf_m.mark = mark-parent exclusive-lock :
      buf_m.sts = ObjSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB.
      ungrg(buf_m.mark-parent).
    end. 
  end.  

  method public logical ImpUTDIntroduce (table TempTrnDoc, table TempDocLine, table TempMarkLine):
    
    def var chAddIntoduce as class introduce no-undo.
    def var v-utd-db-num as integer no-undo.
    def var v-utd-doc-id as integer no-undo.
    def var v-ext-doc-code as character no-undo.
    define buffer utd-marking-lines for ub.utd-marking-lines.
    define buffer utd for ub.utd.
    define buffer marking for marking.
    
     
    chAddIntoduce = new introduce ().
     
    for each TempTrnDoc :
      
      if TempTrnDoc.ext-doc-type = "InvIntroduce"
      then do:
        find first utd where utd.doc-code = TempTrnDoc.ext-doc-code no-lock no-error.
        if not available (utd)
          then next.
        v-utd-db-num = utd.db-num.
        v-utd-doc-id = utd.doc-id.
      end.
      else do:
        v-ext-doc-code = replace (entry (2, TempTrnDoc.ext-doc-code, "("),")","").
        assign
          v-utd-db-num = integer (entry (1, v-ext-doc-code, "_"))
          v-utd-doc-id = integer (entry (2, v-ext-doc-code, "_"))
        no-error.
      end.
      
      if error-status:error
        then next.
        
      for each TempMarkLine where TempMarkLine.Sts = "CrTsd" :

        find first utd-marking-lines no-lock where utd-marking-lines.mark = TempMarkLine.MarkCode and utd-marking-lines.doc-id = v-utd-doc-id and utd-marking-lines.db-num = v-utd-db-num no-error.
        if available ( utd-marking-lines)
          then next.
        
        find first marking where marking.mark = utd-marking-lines.mark exclusive-lock no-error.
        if available (marking)
        then do:
          marking.sts = ObjSrv:Env:Marking:Sts:Mark:PendingVerification:KeyIntDB.
        end.
        
        chAddIntoduce:AddMarkUTD(TempMarkLine.MarkCode, v-utd-doc-id, v-utd-db-num, "CrTsd") no-error.

        if error-status:error
        then do:
          dispmessage (return-value, false).
          delete object chAddIntoduce no-error.
          return false.
        end.
      end.
    end.
    delete object chAddIntoduce no-error.
    
  end.

  method public logical ImpInvMarksDOC (table TempTrnDoc, table TempDocLine, table TempMarkLine):
    
    def buffer buf_marking for ub.marking.
    def buffer buf_marking-lines for ub.marking-lines.
    def buffer bf_doc-line for ub.doc-line.
    define buffer marking-attr for ub.marking-attr.
    define buffer goods for ub.goods.
    def var v-inv-doc as character no-undo.
     
    for each TempTrnDoc :
      
      assign
        v-inv-doc = TempTrnDoc.ext-doc-code
      no-error.
      
      if error-status:error
        then next.
      
      for each TempMarkLine where TempMarkLine.Sts = "CheckScan" :
        
        find first marking-attr no-lock where (    marking-attr.attr-code = "inv-doc"
                                               and marking-attr.mark = TempMarkLine.MarkCode) 
                                            or (marking-attr.attr-code = "inv-doc-scan"
                                               and marking-attr.mark = TempMarkLine.MarkCode)  
          no-error.
        
        if available (marking-attr) and not marking-attr.attr-value = v-inv-doc 
        then do:
          dispmessage ("Марка находится в инвентаризации - " + marking-attr.attr-value, false).
          return false.
        end.
        else do:
          if available (marking-attr) 
            then next.
       end.
        
        find first buf_marking where (buf_marking.mark = TempMarkLine.MarkCode) no-lock no-error.
      
        if not available (buf_marking)
        then do:
          dispmessage ("Марка не найдена в системе.", false).
          return false.    
        end.
        
        find first buf_marking-lines where (buf_marking-lines.mark = TempMarkLine.MarkCode)
          and buf_marking-lines.out-code = {&free-code} no-error.
      
        find first goods no-lock where goods.gds-code = buf_marking-lines.gds-code no-error.
        find first bf_doc-line where bf_doc-line.doc-code = v-inv-doc
          and bf_doc-line.artic = goods.artic
          and bf_doc-line.prod-type = goods.prod-type
          and bf_doc-line.prod-code = goods.prod-code no-lock no-error.
        
        if not available (bf_doc-line)
        then do:
          dispmessage (substitute ("В накладной к линии с товаром &1 &2 к марке &3.", string (goods.gds-code), goods.gds-name, buf_marking-lines.mark), false).
          return false.
        end.
        
/*        if buf_marking.sts = ObjSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB*/
/*        then do:                                                           */
/*          run dispmessage ("Упаковка разгруппирована.", false).            */
/*          return.                                                          */
/*        end.                                                               */
        
        if available (buf_marking) and available (buf_marking-lines)
        then do:

          create marking-attr.
          marking-attr.mark = TempMarkLine.MarkCode.
          marking-attr.attr-code = "inv-doc-scan".
          marking-attr.attr-value = v-inv-doc.
          ObjSrv:Lib:MarkingTree:UnGroupMark(buf_marking.mark).    
          
          if ObjSrv:Lib:MarkingTree:LevelDown(buf_marking.mark  ) 
          then do:
            ObjSrv:Lib:MarkingTree:LockInvChildeMark(buf_marking.mark, v-inv-doc).
          end.
         
    
        end.
      end.
    end.
    return true.
  end.

  method public void WriteUnknown ():
    
    SomeStr = getStatusXml(false, "Неизвестный запрос.").
   
  end.

  method public integer GetDbNum ():
    return dbNum.
  end method.
  method private integer GetDbNumLocal ():
    define buffer buf_sys-ctrl for ub.sys-ctrl .
  
    do
    on error undo, return error return-value
    :
      for first buf_sys-ctrl field (db-num) no-lock :
       return buf_sys-ctrl.db-num.
      end.
  
    end.
  end method.
  method public character gds-attr-mark-type (

  p-gds-code as integer
     /* код атрибута */
     /* значение атрибута */
  ):
  define buffer goods-attr for goods-attr.
  do
  on error undo, return error
  :
    
    find first goods-attr where goods-attr.gds-code = p-gds-code and goods-attr.attr-code = {&attr-mark-type} no-lock no-error. 
    
    if available goods-attr
      then return goods-attr.attr-value.
    return "".
    
  end.
  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  destructor public TSD ( ):
    
    delete object keyrec no-error.
    
  end destructor.

  method public void dispmessage (p-str as char, p-sts as logical): 
    LogWrite:LogStr = p-str.
    SomeStr = getStatusXml(p-sts, p-str).
  end.

  method public void getUTDDoc (iProtocol as char):
    
    define buffer buf_utd         for ub.utd.
    define buffer buf_utd-err     for ub.utd-err.
    define buffer buf_utd-m-l     for ub.utd-marking-lines.
    define buffer buf_utd-m-l-par for ub.utd-marking-lines.
    define buffer buf_m-l         for ub.marking-lines.
    define buffer buf_m-chi       for ub.marking.
    define buffer buf_m-par       for ub.marking.
    define buffer buf_utd-l       for ub.utd-lines.
    define buffer buf_m           for ub.marking.
    define buffer buf_goods     for ub.goods.
    define buffer buf_bar-code  for ub.bar-code.
    define buffer buf_trn-doc   for ub.trn-doc.
    define buffer buf_doc-line  for ub.doc-line.
    define buffer utd-marking-lines-attr for ub.utd-marking-lines-attr.
    define buffer buf_utd-marking-lines for ub.utd-marking-lines.
    define buffer marking-attr for ub.marking-attr.
    define buffer marking for ub.marking.
    define buffer utd-marking-lines for ub.utd-marking-lines.
    define buffer utd for ub.utd.
    
    define variable dFactSum   as decimal   no-undo.
    define variable priceSale  as dec no-undo.
    define variable docType    as character no-undo.
    define variable decDocQnty as decimal no-undo.
    define variable jj as integer no-undo.
    define variable jjm as integer no-undo.
    define variable iim as integer no-undo.
    define variable myflagsDoc     as class flagsdoc     no-undo.
    define variable myflagsDocLine as class flagsdocline no-undo.
    define variable pos as integer no-undo.
    def    var      internal-b-code like ub.bar-code.b-code no-undo .
    def    var      full-b-code     as character init "" no-undo .
    def    var      v-doc-num       as character no-undo .
    def var v-sts as character no-undo.
    def var vRecKey-line as character no-undo.
          
    myflagsDoc = new flagsdoc ().
    myflagsDocLine = new flagsdocline ().
    l_utd:
    for each buf_utd where buf_utd.obj-type = ObjType and buf_utd.obj-code = ObjCode and buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:AwaitingDelivery:KeyIntDB
      and buf_utd.EDocType = ObjSrv:Env:Utd:EDocType:UTD:KeyIntDB:
      v-doc-num = buf_utd.DocumentNumber + "(" + string(buf_utd.db-num) + "_" + string(buf_utd.doc-id) + ")".
      logWrite:WriteDebugLog( "Выгружаем документ УПД " + v-doc-num).    
      myflagsDoc:unSetAllFlags().
      myflagsDoc:isDocMarkOn = false.
      
      for each buf_utd-l where buf_utd-l.db-num = buf_utd.db-num and buf_utd-l.doc-id = buf_utd.doc-id no-lock:
         if WeighedProd(buf_utd-l.gds-code)
         then do:
            logWrite:WriteDebugLog( substitute ("Документ &1 содержит весовой товар &2. Документ пропущен.", v-doc-num, buf_utd-l.gds-code)).    
      
            next l_utd.
         end.
      end.
      block-u-l:
      for each buf_utd-l where buf_utd-l.db-num = buf_utd.db-num and buf_utd-l.doc-id = buf_utd.doc-id no-lock:
      
         block-mark:
         for each buf_utd-m-l where buf_utd-m-l.db-num = buf_utd-l.db-num 
                             and buf_utd-m-l.doc-id    = buf_utd-l.doc-id
                             and buf_utd-m-l.LineNum   = buf_utd-l.LineNum 
         no-lock:
            if    ismark(buf_utd-m-l.mark)
               or isOAD (buf_utd-m-l.mark)
            then do:
               ObjSrv:Lib:KeyRec:GenKeyRec ( input "utd-lines", 
                  input  buffer buf_utd-l:handle, 
                  output vRecKey-line). 
               find first buf_utd-err no-lock where buf_utd-err.doc-id = buf_utd-l.doc-id and buf_utd-err.db-num = buf_utd-l.db-num and buf_utd-err.reckey = vRecKey-line no-error .
               if not available buf_utd-err
               then do:
                  myflagsDoc:isDocMarkOn = true.
                  leave block-u-l.
               end.
               else
                  leave block-mark.
            end.
         end.
      end.         
      if buf_utd.cli-code = ? or buf_utd.obj-code = ? or buf_utd.cli-type = ? or buf_utd.obj-type = ?
      then do:
        logWrite:WriteFileToLog( substitute ( "Не указан контрагент/объект TH в документе УТД &1.", v-doc-num)).
        next l_utd.
      end.
      
      pos = 0.
      for each buf_utd-l where buf_utd-l.db-num = buf_utd.db-num and buf_utd-l.doc-id = buf_utd.doc-id no-lock:
        
        myflagsDocLine:unSetAllFlags().
        myflagsDocLine:isMarkOn            = logical(GetAttrUtdlinesEx (buf_utd-l.db-num,buf_utd-l.doc-id,buf_utd-l.lineNum,"MarkUtdLine","no")).
        myflagsDocLine:isVarietalVolumeOn  = logical(GetAttrUtdlinesEx (buf_utd-l.db-num,buf_utd-l.doc-id,buf_utd-l.lineNum,"ArticUtdLine","no")).
        myflagsDocLine:isNotEditManualQnty = not (myflagsDocLine:isMarkOn).
        
        find first buf_goods no-lock where buf_goods.gds-code = buf_utd-l.gds-code no-error.
        if not available (buf_goods)
        then do: 
          logWrite:WriteFileToLog( substitute ( "Не указан товар TH в документе УТД &1.", v-doc-num)).
          next l_utd.
        end.

        find first buf_bar-code no-lock where buf_bar-code.gds-code = buf_goods.gds-code.
        
       internal-b-code = buf_bar-code.b-code.                
        { str/bc-gnrti.i "bc" "internal-b-code" "full-b-code"}

        pos = pos + 1.
        PriceSale = buf_utd-l.Total / buf_utd-l.Quantity. 
        decDocQnty = buf_utd-l.Quantity.
        

        define variable vErrorLine as logical no-undo.
        ObjSrv:Lib:KeyRec:GenKeyRec ( input "utd-lines", 
            input  buffer buf_utd-l:handle, 
            output vRecKey-line). 
        find first buf_utd-err no-lock where buf_utd-err.doc-id = buf_utd-l.doc-id and buf_utd-err.db-num = buf_utd-l.db-num and buf_utd-err.reckey = vRecKey-line no-error .
        vErrorLine = available buf_utd-err.  
        for each buf_utd-m-l where buf_utd-m-l.db-num = buf_utd.db-num and buf_utd-m-l.doc-id = buf_utd.doc-id and buf_utd-m-l.LineNum = buf_utd-l.LineNum no-lock
          :
          define variable vMark as logical no-undo.
          vMark = isMark(buf_utd-m-l.mark).
          if vMark 
          then do:
             find first buf_m no-lock where buf_m.mark = buf_utd-m-l.mark no-error.
          end.
          if vErrorLine and false then 
          do:
            v-sts = "NotCorrect".
          end.
          else do:
             if not vMark
             then
                v-sts = "UTD".
             else if not buf_utd-m-l.sts = ObjSrv:Env:Marking:Sts:Mark:PendingVerification:KeyIntDB
                 and not buf_utd-m-l.sts = ObjSrv:Env:Marking:Sts:Mark:DeliveryControl:KeyIntDB          
             then do:
                  if available buf_m and buf_m.sts = ObjSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB 
                      or buf_utd-m-l.sts = ObjSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB 
                  then v-sts = "Check".
                  else v-sts = "NotCorrect".
              end.
              else if available buf_m and buf_m.sts = ObjSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB
              then
                 v-sts = "Ungrouped".
              else if available buf_m and buf_m.sts = ObjSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB
              then
                 v-sts = "NotCorrect".
              else do:
                if available buf_m and buf_m.sts = ObjSrv:Env:Marking:Sts:Mark:GrayZone:KeyIntDB
                  then v-sts = "GrayZone".
                  else do:
                    if can-find (first buf_m-par no-lock where buf_m-par.mark = buf_m.mark-parent and buf_m-par.sts = ObjSrv:Env:Marking:Sts:Mark:GrayZone:KeyIntDB) 
                      then v-sts = "GrayZone".
                      else v-sts = "UTD".
                  end.
              end. 
          end.

      
          jj = jj + 1.
          define variable vqnty as integer no-undo.
          if vmark
             and available buf_m 
          then do:
             vqnty = buf_m.box-qnty.
             if vqnty = ? then vqnty = integer (GetAttrUtdlinesEx (buf_utd-m-l.db-num,buf_utd-m-l.doc-id,buf_utd-m-l.lineNum,"box-qnty","0")) no-error.
          end.   
          else vqnty = integer(GetAttrUtdlinesEx (buf_utd-m-l.db-num,buf_utd-m-l.doc-id,buf_utd-m-l.lineNum,"box-qnty","0")) no-error.
          if vqnty = ? then vqnty = 0.
          addDocLineMark(
                    jj,
                      v-doc-num,
                    buf_utd-l.linenum,
                      buf_utd-m-l.mark,
                      v-doc-num + "_" + string (buf_goods.gds-code) + "_" + string(pos),
                      v-sts,
                      (if available buf_m then  buf_m.mark-parent else ""),
                    vqnty,
                    if available buf_m then  buf_m.unit-ext else "").
        end.

        define variable decFactQnty as decimal no-undo.
        decFactQnty  = dec (GetAttrUtdlinesEx(buf_utd-l.db-num,buf_utd-l.doc-id,buf_utd-l.linenum,"QuantityBarCode","0")).
          jjm = jjm + 1.
         addDocLine(jjm,
                       v-doc-num,
                       pos,
                       buf_goods.gds-code,
                       buf_goods.gds-name ,
                      buf_goods.unit-base,
                      full-b-code,
                       priceSale,
                       decDocQnty,
                       decFactQnty,
                      getErrForLineType(buffer buf_utd-l:handle, "*"),
                      v-doc-num + "_" + string (buf_goods.gds-code) + "_" + string(pos),
                       myflagsDocLine:FlagsToInt  ).
      end.
      
      
      docType = "UTD".
      addDoc(
           v-doc-num,
           docType,
           false,
           "накл+",
           buf_utd.cli-code,
           buf_utd.cli-type,
           buf_utd.obj-code,
           buf_utd.obj-type,
           "",
            "",
           dFactSum,
           datetime-tz (if buf_utd.DocumentDate = ? then now else buf_utd.DocumentDate),
           myflagsDoc:FlagsToInt
      ).
      logWrite:WriteDebugLog( "Выгружен документ УПД " + v-doc-num).    
      
    end.
    l_utd_Introduce:
    for each buf_utd where buf_utd.obj-type = ObjType and buf_utd.obj-code = ObjCode and buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:NewStatus:KeyIntDB
      and buf_utd.EDocType = ObjSrv:Env:Utd:EDocType:Introduce:KeyIntDB
        and buf_utd.doc-code = "" 
        and not can-find (first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_utd.doc-code):
      v-doc-num = buf_utd.DocumentNumber + "(" + string(buf_utd.db-num) + "_" + string(buf_utd.doc-id) + ")".
      logWrite:WriteDebugLog( "Выгружаем документ Первоначальный ввод КМ " + v-doc-num).
      pos = 0.
      l_utd1:
      for each buf_utd-l where buf_utd-l.db-num = buf_utd.db-num and buf_utd-l.doc-id = buf_utd.doc-id no-lock:

        myflagsDocLine:unSetAllFlags().
        myflagsDocLine:isMarkOn            = logical(GetAttrUtdlinesEx (buf_utd-l.db-num,buf_utd-l.doc-id,buf_utd-l.lineNum,"MarkUtdLine","yes")).
        myflagsDocLine:isVarietalVolumeOn  = logical(GetAttrUtdlinesEx (buf_utd-l.db-num,buf_utd-l.doc-id,buf_utd-l.lineNum,"ArticUtdLine","no")).
        myflagsDocLine:isNotEditManualQnty = not (myflagsDocLine:isMarkOn).
              
        find first buf_goods no-lock where buf_goods.gds-code = buf_utd-l.gds-code no-error.
        if not available (buf_goods)
        then do: 
          LogWrite:LogStr = LogWrite:LogStr + {&new-line} + substitute ( "Не указан товар TH в документе УТД &1.", v-doc-num).
          next l_utd1.
        end.
       
        find first buf_bar-code no-lock where buf_bar-code.gds-code = buf_goods.gds-code.
        
        internal-b-code = buf_bar-code.b-code.
        { str/bc-gnrti.i "bc" "internal-b-code" "full-b-code"}
        
        PriceSale = buf_utd-l.Total / buf_utd-l.Quantity. 
        decDocQnty = buf_utd-l.Quantity.
        
        
        pos = pos + 1.
        addDocLine(jjm,
                       v-doc-num,
                       pos,
                       buf_goods.gds-code,
                       buf_goods.gds-name ,
                      buf_goods.unit-base,
                      full-b-code,
                       priceSale,
                       decDocQnty,
                       decDocQnty,
                       "",
                      v-doc-num + "_" + string (buf_goods.gds-code),
                       myflagsDocLine:FlagsToInt  ).
        
        for each buf_utd-m-l where buf_utd-m-l.db-num = buf_utd.db-num and buf_utd-m-l.doc-id = buf_utd.doc-id and buf_utd-m-l.LineNum = buf_utd-l.LineNum no-lock
          :
          vmark =isMark(buf_utd-m-l.mark).
          if vmark
          then do:
          find first buf_m no-lock where buf_m.mark = buf_utd-m-l.mark no-error.
             if not available (buf_m)
             then do:
               logWrite:WriteFileToLog(substitute ("Некорректная марка &1.", buf_utd-m-l.mark)).
               next.
             end.
          end.
/*          if not buf_m.unit-ext = "UNIT"                                         */
/*          then do:                                                               */
/*            find first buf_m-chi no-lock where buf_m-chi.mark-parent = buf_m.mark*/
/*              and buf_m-chi.unit-ext = "UNIT" no-error.                          */
/*            if not available (buf_m-chi)                                         */
/*              then next.                                                         */
/*          end.                                                                   */
          find first utd-marking-lines-attr where
                utd-marking-lines-attr.db-num    = buf_utd-m-l.db-num
            and utd-marking-lines-attr.doc-id    = buf_utd-m-l.doc-id
            and utd-marking-lines-attr.LineNum   = buf_utd-m-l.LineNum
            and utd-marking-lines-attr.mark      = buf_utd-m-l.mark
            and utd-marking-lines-attr.attr-code = "CrTsd" no-lock no-error
          .
          def var v-mark as char no-undo.
          if available (utd-marking-lines-attr)
            then v-mark = utd-marking-lines-attr.attr-value.
            else v-mark = buf_utd-m-l.mark. 

          jj = jj + 1.
          if vmark and 
             available buf_m 
          then do:
             vqnty = buf_m.box-qnty.
             if vqnty = ? then vqnty = decimal(GetAttrUtdlinesEx (buf_utd-m-l.db-num,buf_utd-m-l.doc-id,buf_utd-m-l.lineNum,"box-qnty","0")) no-error.
          end.   
          else vqnty = decimal(GetAttrUtdlinesEx (buf_utd-m-l.db-num,buf_utd-m-l.doc-id,buf_utd-m-l.lineNum,"box-qnty","0")) no-error.
          if vqnty = ? then vqnty = 0.
          addDocLineMark(
                    jj,
                      v-doc-num,
                    buf_utd-l.linenum,
                      v-mark,
                      v-doc-num + "_" + string (buf_goods.gds-code),
                      "CrTSD",
                      (if available buf_m then  buf_m.mark-parent else ""),
                    vqnty,
                    if available buf_m then  buf_m.unit-ext else ""
                    ).
          
        end.
      end.      
      
      if buf_utd.cli-code = ? or buf_utd.obj-code = ? or buf_utd.cli-type = ? or buf_utd.obj-type = ?
      then do:
        logWrite:WriteFileToLog(substitute ( "Не указан контрагент/объект TH в документе УТД &1.", v-doc-num)).
        next l_utd_Introduce.
      end.
      

      docType = "Introduce".
      addDoc(
           v-doc-num,
           docType,
           false,
           "накл+",
           buf_utd.cli-code,
           buf_utd.cli-type,
           buf_utd.obj-code,
           buf_utd.obj-type,
           "",
            "",
           0,
           datetime-tz (if buf_utd.DocumentDate = ? then now else buf_utd.DocumentDate),
           myflagsDoc:FlagsToInt
      ).
      logWrite:WriteDebugLog( "Выгружен документ Первоначальный ввод КМ " + v-doc-num).
              
    end.

    def var v-attr-value   as character no-undo.
    def var v-attr-type    as character no-undo. 
    def var v-is-introduce as logical   no-undo.

    invd_:
    for each buf_trn-doc where buf_trn-doc.ext-doc-type = {&TDEDT_Inv} and buf_trn-doc.status_ = {&wayb} and not buf_trn-doc.flag:
      
      v-is-introduce = false.
      { str/tdat-val.i
        buf_trn-doc.doc-code
        {&trdcattr-inv-introduce}
        v-attr-value
        v-attr-type
        no-error
      }
      if not error-status:error and v-attr-value = "yes" then do:
        v-is-introduce = true.
        find first buf_utd no-lock where buf_utd.doc-code = buf_trn-doc.doc-code no-error.
        if not available (buf_utd)
        then do:
          logWrite:WriteFileToLog(substitute ( "Ошибочный документ &1 TH первоначального ввода, нет привязанного документа УТД.", v-doc-num)).
          next invd_.
        end.
      end.
      logWrite:WriteDebugLog( "Выгружаем документ " + buf_trn-doc.doc-code).
      
      v-doc-num = buf_trn-doc.doc-code.
      pos = 0.
      for each buf_doc-line where buf_doc-line.doc-code = buf_trn-doc.doc-code no-lock:
        find first buf_goods no-lock where buf_goods.artic = buf_doc-line.artic and buf_goods.prod-code = buf_doc-line.prod-code and buf_goods.prod-type = buf_doc-line.prod-type.
        find first buf_bar-code no-lock where buf_bar-code.gds-code = buf_goods.gds-code.
        
        if not ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_trn-doc.obj-type, buf_trn-doc.obj-code):GetIsMarkingForType(gds-attr-mark-type(buf_goods.gds-code))
        then do: 
        logWrite:WriteDebugLog( "Не выгружаем документ " + buf_trn-doc.doc-code + ". В нем содержится не маркированный товар.").
      
        next invd_.
        end.
/*        if not gds-attr-mark-type(buf_goods.gds-code) = "tabak"*/
/*        then next invd_.                                       */
        internal-b-code = buf_bar-code.b-code.
        { str/bc-gnrti.i "bc" "internal-b-code" "full-b-code"}
        pos = pos + 1.
        def var v-qnty as integer no-undo.        
        v-qnty = 0.
        if v-is-introduce
        then do:
           for each marking-attr no-lock where (marking-attr.attr-code = "inv-doc"
                                               and marking-attr.attr-value = buf_doc-line.doc-code) 
                                            or (marking-attr.attr-code = "inv-doc-scan"
                                            and marking-attr.attr-value = buf_doc-line.doc-code)  :
            if not can-find (first marking no-lock where marking.mark = marking-attr.mark and marking.unit-ext = "UNIT" and marking.gds-code = buf_goods.gds-code) 
              then next.
            v-qnty = v-qnty + 1.
          end.
          for each utd no-lock where utd.doc-code = buf_doc-line.doc-code:
            for each utd-marking-lines no-lock where utd-marking-lines.doc-id = utd.doc-id and utd-marking-lines.db-num = utd.db-num and utd-marking-lines.gds-code = buf_goods.gds-code
              and (utd-marking-lines.sts = ObjSrv:Env:Marking:Sts:Mark:PendingVerification:KeyIntDB or utd-marking-lines.sts = ObjSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB):
              for each marking no-lock where marking.mark = utd-marking-lines.mark.
                if can-find (buf_utd-marking-lines where 
                      buf_utd-marking-lines.doc-id = utd.doc-id and buf_utd-marking-lines.db-num = utd.db-num and buf_utd-marking-lines.mark = marking.mark-parent
                    )
                  then next.
                v-qnty = v-qnty + marking.box-qnty.
              end.
            end.
            decDocQnty = buf_doc-line.doc-qnty - buf_doc-line.fact-qnty.
            decFactQnty = v-qnty.
          end.
        end.
        else do:
          for each marking-attr no-lock where (    marking-attr.attr-code = "inv-doc"
                                               and marking-attr.attr-value = buf_doc-line.doc-code) 
                                            or (marking-attr.attr-code = "inv-doc-scan"
                                                and marking-attr.attr-value = buf_doc-line.doc-code)  :
            if not can-find (first marking no-lock where marking.mark = marking-attr.mark and marking.unit-ext = "UNIT" and marking.gds-code = buf_goods.gds-code) 
              then next.
            v-qnty = v-qnty + 1.
          end.
          decDocQnty = buf_doc-line.doc-qnty - buf_doc-line.fact-qnty.
          decFactQnty = v-qnty.
        end.
        
        assign
          priceSale   = if buf_doc-line.price-rubl <> ? then buf_doc-line.price-rubl else 0
          .
        jjm = jjm + 1.
        addDocLine(jjm,
                       v-doc-num,
                       pos,
                       buf_goods.gds-code,
                       buf_goods.gds-name ,
                      buf_goods.unit-base,
                      full-b-code,
                       priceSale,
                       decDocQnty,
                       decFactQnty,
                       "",
                      v-doc-num + "_" + string (buf_goods.gds-code),
                       myflagsDocLine:FlagsToInt  ).
        
        if not v-is-introduce
        then do:
          for each buf_m-l no-lock where buf_m-l.obj-type = buf_doc-line.obj-type
              and buf_m-l.obj-code = buf_doc-line.obj-code
              and buf_m-l.out-code = {&free-code}
              and buf_m-l.gds-code = buf_goods.gds-code
            :
               vmark = isMark(buf_m-l.mark).
            if vmark
            then do:
               find first buf_m no-lock where buf_m.mark = buf_m-l.mark no-error.
               if available (buf_m)
               then do:
                  if buf_m.sts = ObjSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB
                    then next.  
                  if not buf_m.unit-ext = "UNIT"
                  then do:
                    find first buf_m-chi no-lock where buf_m-chi.mark-parent = buf_m.mark
                      and buf_m-chi.unit-ext = "UNIT" no-error.
                    if not available (buf_m-chi)
                      then next.
                  end.
                  block-attr:
                  for each marking-attr where (marking-attr.attr-code = "inv-doc"
                                                         and marking-attr.mark = buf_m.mark) 
                                                      or (marking-attr.attr-code = "inv-doc-scan"
                                                          and marking-attr.mark = buf_m.mark) 
                  no-lock:
                  leave block-attr.
                  end.
                 if available marking-attr    
                 then v-sts = "Check".
                 else v-sts = "UTD".
               end.
               else next.
            end.
            else v-sts = "Check".
            jj = jj + 1.
            if vmark 
              and available buf_m
            then vqnty = buf_m.box-qnty.
/*            else vqnty = decimal(GetAttrUtdlinesEx (buf_m-l.db-num,buf_m-l.doc-id,buf_m-l.lineNum,"box-qnty","0")).*/
            if vqnty = ? then vqnty = 0.
            addDocLineMark(
                    jj,
                      v-doc-num,
                    pos,
                      buf_m-l.mark,
                      v-doc-num + "_" + string (buf_goods.gds-code),
                      "Check",
                      (if available buf_m then buf_m.mark-parent else ""),
                    vqnty,
                    if available buf_m then  buf_m.unit-ext else ""
                    ).
          
          end.
        end.
        else do:
          find first buf_utd no-lock where buf_utd.doc-code = buf_trn-doc.doc-code.
          l_utdf:
          for each buf_utd-l where buf_utd-l.db-num = buf_utd.db-num and buf_utd-l.doc-id = buf_utd.doc-id 
            and buf_utd-l.gds-code = buf_goods.gds-code no-lock:
    
            find first buf_goods no-lock where buf_goods.gds-code = buf_utd-l.gds-code no-error.
            if not available (buf_goods)
            then do: 
              logWrite:WriteFileToLog( substitute ( "Не указан товар TH в документе УТД &1.", v-doc-num)).
              next l_utdf.
            end.
           
            find first buf_bar-code no-lock where buf_bar-code.gds-code = buf_goods.gds-code.
            
            internal-b-code = buf_bar-code.b-code.
            { str/bc-gnrti.i "bc" "internal-b-code" "full-b-code"}
            
            PriceSale = buf_utd-l.Total / buf_utd-l.Quantity. 
            decDocQnty = buf_utd-l.Quantity.
            
            
            for each buf_utd-m-l where buf_utd-m-l.db-num = buf_utd.db-num and buf_utd-m-l.doc-id = buf_utd.doc-id and buf_utd-m-l.LineNum = buf_utd-l.LineNum 
              no-lock
              :
              vmark = ismark(buf_utd-m-l.mark).
              if vmark
              then do:
                 find first buf_m no-lock where buf_m.mark = buf_utd-m-l.mark no-error.
                 if not available (buf_m)
                 then do:
                   logWrite:WriteFileToLog(substitute ("Некорректная марка &1.", buf_utd-m-l.mark)).
                   next.
                 end.
              end.
/*              if not buf_m.unit-ext = "UNIT"                                         */
/*              then do:                                                               */
/*                find first buf_m-chi no-lock where buf_m-chi.mark-parent = buf_m.mark*/
/*                  and buf_m-chi.unit-ext = "UNIT" no-error.                          */
/*                if not available (buf_m-chi)                                         */
/*                  then next.                                                         */
/*              end.                                                                   */
              jj = jj + 1.
              if vmark
                 and available buf_m 
              then do:
                 vqnty = buf_m.box-qnty.
                 if vqnty = ? then vqnty = decimal(GetAttrUtdlinesEx (buf_utd-m-l.db-num,buf_utd-m-l.doc-id,buf_utd-m-l.lineNum,"box-qnty","0")) no-error.
              end.   
              else vqnty = decimal(GetAttrUtdlinesEx (buf_utd-m-l.db-num,buf_utd-m-l.doc-id,buf_utd-m-l.lineNum,"box-qnty","0")) no-error.
              if vqnty = ? then vqnty = 0.
              addDocLineMark(
                    jj,
                      v-doc-num,
                    buf_utd-l.linenum,
                    buf_m-l.mark,
                      v-doc-num + "_" + string (buf_goods.gds-code),
                      "CrTSD",
                      (if available buf_m then buf_m.mark-parent else ""),
                    vqnty,
                    if available buf_m then  buf_m.unit-ext else ""
                    ).
            end.
          end.
        end.
      end.
      if v-is-introduce
        then doctype = "InvIntroduce". 
        else docType = "InvMarks".
      addDoc(
           v-doc-num,
           docType,
           false,
           buf_trn-doc.status_ + string (buf_trn-doc.flag, "+/-"),
           buf_trn-doc.cli-code,
           buf_trn-doc.cli-type,
           buf_trn-doc.obj-code,
           buf_trn-doc.obj-type,
           "",
            "",
           0,
           now,
           myflagsDoc:FlagsToInt
      ).
      logWrite:WriteDebugLog( "Выгружен документ " + buf_trn-doc.doc-code).
      
    end.
  end.
  method private character decToString (iValue as decimal ):
     return replace(trim(string(iValue, "->>>>>>>>>>>>9.9<<<<<")),".",",").
  end.
  
  method private void addDoc(
     idoc-num as char,
     idocType as char,
     icomplite as logical,
     istatus as char,
     icli-code as int,
     icli-type as char,
     iobj-code as int,
     iobj-type as char,
     iuser-id as character,
     iuser-login as char,
     iFactSum as dec,
     idoc-date as datetime-tz,
     iflags as int
  ):
     find first TempTrnDocMT where TempTrnDocMT.DocName eq idoc-num no-lock no-error.
     if not available TempTrnDocMT
     then do:
        create TempTrnDocMT.
        TempTrnDocMT.DocName = idoc-num.
     end.
     assign
        TempTrnDocMT.DocType     = idocType
        TempTrnDocMT.Complete_   = icomplite
        TempTrnDocMT.Status_     = istatus
        TempTrnDocMT.ClientID    = icli-code
        TempTrnDocMT.ClientType  = icli-type
        TempTrnDocMT.ObjectID    = iobj-code
        TempTrnDocMT.ObjectType  = iobj-type
        TempTrnDocMT.UserID_     = iuser-id
        TempTrnDocMT.UserName    = iuser-login
        TempTrnDocMT.FactSum     = iFactSum
        TempTrnDocMT.StartDate   = idoc-date
        TempTrnDocMT.Flags_      = iflags
      .
  end.
  
  method public void docPrint(idir as char):
     tsdstreamopenapp(idir + "\MT_documents.txt").
     for each TempTrnDocMT no-lock:  
        put stream tsdstream unformatted 
        TempTrnDocMT.DocName + {&delimiteFld} + 
        TempTrnDocMT.DocType + {&delimiteFld} + 
        string(TempTrnDocMT.Complete_,"true/false") + {&delimiteFld} + 
        TempTrnDocMT.Status_ + {&delimiteFld} + 
        string (TempTrnDocMT.ClientID) + {&delimiteFld} + 
        TempTrnDocMT.ObjectType + {&delimiteFld} + 
        string (TempTrnDocMT.ObjectID) + {&delimiteFld} + 
        TempTrnDocMT.ObjectType + {&delimiteFld} + 
        TempTrnDocMT.UserID_ + {&delimiteFld} + 
        TempTrnDocMT.UserName + {&delimiteFld} +
        decToString(TempTrnDocMT.FactSum) + {&delimiteFld} + 
        iso-date (TempTrnDocMT.StartDate) + {&delimiteFld} 
        + string(TempTrnDocMT.Flags_) + {&delimiterLine}.
     end. 
     tsdstreamclose().
     
  end.
  
  method private void addDocLine(pos as integer,
                       idoc-num as char,
                       iline-num as int,
                       igds-code as int,
                       igds-name as character ,
                       iunit-base as character ,
                       ifull-b-code as char,
                       ipriceSale as dec,
                       idocQnty as dec,
                       ifactQnty as  dec,
                       iError as char,
                       iRecKey as char,
                       iflags as int 
  ):
     find first TempTrnLineMT where TempTrnLineMT.docname eq idoc-num
                              and TempTrnLineMT.pos eq pos
     no-lock no-error. 
     if not available TempTrnLineMT
     then do:
        create TempTrnLineMT.
        assign 
           TempTrnLineMT.docname = idoc-num
           TempTrnLineMT.pos = pos
        .
     end.
     assign
        TempTrnLineMT.goodsid     = igds-code
        TempTrnLineMT.goodsname   = igds-name
        TempTrnLineMT.UnitBC      = iunit-base
        TempTrnLineMT.BC          = ifull-b-code
        TempTrnLineMT.Price_      = ipriceSale
        TempTrnLineMT.DocQnty     = idocQnty
        TempTrnLineMT.FactQnty    = ifactQnty
        TempTrnLineMT.Error       = iError
        TempTrnLineMT.PartIDTH    = iRecKey
        TempTrnLineMT.Flags_      = iflags
        TempTrnLineMT.lineId      = iline-num
     . 
  end.
  method public void docLinePrint(idir as char):
      tsdstreamopenapp(idir + "\MT_lines.txt").
      for each TempTrnLineMT no-lock:  
        put stream tsdstream unformatted
          substitute ("&2&1&3&1&4&1&5&1&6&1&7&1&8&1&9&1",
                      {&delimiteFld},
                      TempTrnLineMT.pos,
                      TempTrnLineMT.docname ,
                      TempTrnLineMT.lineid,
                      TempTrnLineMT.goodsid,
                      TempTrnLineMT.goodsname,
                      TempTrnLineMT.UnitBC,
                      TempTrnLineMT.BC,
                      decToString(TempTrnLineMT.Price_)
                      
                     )
        +
         substitute ("&3&1&4&1&5&1&6&1&7&2",
                      {&delimiteFld},
                      {&delimiterLine},
                      decToString(TempTrnLineMT.DocQnty),
                      decToString(TempTrnLineMT.FactQnty),
                      TempTrnLineMT.Error, /* string (buf_goods.gds-code) */
                      TempTrnLineMT.PartIDTH,
                      TempTrnLineMT.Flags_
                      )
                     .
      end.
      tsdstreamclose().
  end.
  
  method private void addDocLineMark(
     iline-num as integer,
     idoc-num as char,
     pos as int,
     imark as char,
     iRecKey as char,
     iStatus as char,
     iMarkParent as char,
     iMarkQnty as int,
     iUnitBox as char
      
  ):
     find first TempMarkLineMT where TempMarkLineMT.DocName  eq idoc-num
                                  and TempMarkLineMT.MarkCode     eq imark
     no-error.
     if not available TempMarkLineMT
     then do:
        create TempMarkLineMT.
        assign
           TempMarkLineMT.DocName = idoc-num
           
           TempMarkLineMT.MarkCode     = imark
        .
     end.
     assign
        TempMarkLineMT.pos         = pos
        TempMarkLineMT.lineID      = iline-num
        TempMarkLineMT.PartIDTH      = iRecKey
        TempMarkLineMT.Status_     = iStatus
        TempMarkLineMT.MarkParent  = iMarkParent
        TempMarkLineMT.BoxQnty    = iMarkQnty
        TempMarkLineMT.UnitBox    = iUnitBox
     .
  end.
  method public void docLineMarkPrint(idir as char):
     tsdstreamopenapp(idir + "\MT_MarkLines.txt").
     for each TempMarkLineMT no-lock:
     put stream tsdstream unformatted 
         substitute ("&3&1&4&1&5&1&6&1&7&8&2",
                {&delimiteFld},
                {&delimiterLine},
                TempMarkLineMT.lineId,
                TempMarkLineMT.DocName,
                TempMarkLineMT.MarkCode,
                TempMarkLineMT.PartIDTH,
                TempMarkLineMT.Status_,
                if     TempMarkLineMT.MarkParent ne ? 
                   and TempMarkLineMT.BoxQnty   ne ?
                then
                   substitute ("&1&2&1&3",{&delimiteFld},
                                        TempMarkLineMT.MarkParent,
                                        TempMarkLineMT.BoxQnty)
                else ""
               )
    
      .
      end.
      tsdstreamclose().
    end.
  
  method public void docWrite():
     docPrint(resType,cp).
     
  end.
  method public void docPrint(type as char,encoding as char):
     for each TempTrnDocMT no-lock:
        create TempTrnLineMTs.
        TempTrnLineMTs.DocName = TempTrnDocMT.DocName.
/*        for each TempTrnLineMT where                         */
/*                 TempTrnLineMT.DocName = TempTrnDocMT.DocName*/
/*        :                                                    */
/*          create TempMarkLineMTs.                            */
/*          TempMarkLineMTs.PartIDTH  = TempTrnLineMT.PartIDTH.*/
/*        end.                                                 */
     end.
      
     ttPrint(type,
        DATASET  ds-doc:handle,encoding).
     empty temp-table TempTrnLineMTs .
/*     empty temp-table TempMarkLineMTs.*/
        /*
        WRITE-XML("longchar",SomeStr, true, encoding, ?, false, true ,false,true).
     else if type eq "json"
     then
        DATASET ds-doc:WRITE-json("longchar",SomeStr,TRUE,?,true,true,false).
     else
        SomeStr = getStatusXml(false,"Тип ответа не подерживается responseType должно быть xml или json") .
        */
  end.
  method public logical parseCSV( idir as char ):
    
    define variable lResult    as logical   no-undo.
    define variable cFactQnty  as decimal  no-undo.
    define variable cDocQnty   as decimal  no-undo.
    define variable cPriceRubl as decimal  no-undo.
    define variable RowSum     as decimal   no-undo.
    define variable iDbNum     as integer   no-undo.
    define variable docType    as character no-undo.
    define variable vFilename  as character no-undo.
    
    
    
    myflagsDoc:unSetAllFlags().

    iDbNum = GetDbNum().
    empty temp-table TempTrnDocMT.
    empty temp-table TempTrnLineMT.
    empty temp-table TempMarkLineMT.
    vFilename = idir + "\MT_documentsSend.json".
    if SearchFile(vFilename) ne ? 
    then do:
       dataset ds-doc:read-json ("file",SearchFile(vFilename),"EMPTY").
    end.

    
    for each TempTrnDocMT where TempTrnDocMT.Complete_ = true:
      logWrite:WriteDebugLog("Загружаем документ " + TempTrnDocMT.DocName).
      empty temp-table TempTrnDoc.
      empty temp-table TempDocLine.
      empty temp-table TempMarkLine.

      case TempTrnDocMT.DocType:
        when "ExtSalesWB" then do:
          docType = {&TDEDT_Ras_Vnesh}.
        end.
        when "IntSalesWB" then do:
          docType = {&TDEDT_Ras_Perem}.
        end.
        when "ExtPurchWB" then do:
          docType = {&TDEDT_Pri_Vnesh}.
        end.
        when "IntPurchWB" then do:
          docType = {&TDEDT_Pri_Perem}.
        end.
        when "Inv" then do:
          docType = {&TDEDT_Inv}.
        end.
        when "Introduce" then do:
          docType = "UTD_Introduce".
        end.
        when "UTD" then do:
          docType = "UTD_DOC".
        end.
        when "InvMarks" then do:
          docType = "invmark".
        end.
        when "MarksInv" then do:
          docType = "MarksInv".
        end.
        when "InvIntroduce" then do:
          docType = "InvIntroduce".
        end.
      end case.
        
      userId_ = TempTrnDocMT.UserID_.

      find first ub.user-login where ub.user-login.db-num = iDbNum and ub.user-login.user-id = userId_ no-lock no-error.  
      create TempTrnDoc.
      assign
        TempTrnDoc.line-num     = 1
        TempTrnDoc.doc-date     = today
        TempTrnDoc.ext-doc-code = TempTrnDocMT.DocName
        TempTrnDoc.ext-doc-type = docType 
        TempTrnDoc.cli-type     = TempTrnDocMT.ClientType
        TempTrnDoc.cli-code     = integer(TempTrnDocMT.ClientID)
        TempTrnDoc.obj-type     = TempTrnDocMT.ObjectType
        TempTrnDoc.obj-code     = TempTrnDocMT.ObjectID
        TempTrnDoc.ps           = if available (ub.user-login) then "" else " Пользователь: " + TempTrnDocMT.UserName
        TempTrnDoc.Status_      = TempTrnDocMT.Status_
        TempTrnDoc.Flags_       = TempTrnDocMT.Flags_
        .

      myflagsDoc:setFlagsToInt(TempTrnDocMT.Flags_).
       
      define variable cFactQntyDec as decimal no-undo .
      define variable cPriceRublDec as decimal no-undo .  
      for each TempTrnLineMT where TempTrnLineMT.docname = TempTrnDocMT.DocName:

          cDocQnty   = TempTrnLineMT.DocQnty .
          cFactQnty  = TempTrnLineMT.FactQnty .
          cPriceRubl = TempTrnLineMT.Price_ .
          
          RowSum    = cFactQnty * cPriceRubl .

        /* для помарочного учета объеденим все линии по товару и будем резервировать количество по маркам в rsrv-dtl.p*/
        if myflagsDoc:isDocMarkOn and (docType = {&TDEDT_Pri_Vnesh} or docType = {&TDEDT_Pri_Perem})
        then do:
          find first TempDocLine no-lock 
            where TempDocLine.gds-code = integer (TempTrnLineMT.goodsid) 
              and TempDocLine.b-code = (TempTrnLineMT.BC) no-error.
          if not available (TempDocLine)
          then do:
            create TempDocLine.
            assign
              TempDocLine.line-num     = integer (TempTrnLineMT.pos)
              TempDocLine.gds-code     = integer (TempTrnLineMT.goodsid)
              TempDocLine.b-code       = string (TempTrnLineMT.BC)
              TempDocLine.fact-qnty    = decimal(cFactQnty)
              TempDocLine.doc-qnty     = decimal(cDocQnty)
              TempDocLine.price-rubl   = ?
              TempDocLine.RowSum       = ?
              TempDocLine.PartIDTH     = TempTrnLineMT.PartIDTH
              TempDocLine.NotDict      = TempTrnLineMT.goodsid eq 0
              .
          end.
          else do:
            assign
              TempDocLine.fact-qnty    = TempDocLine.fact-qnty + cFactQnty
              TempDocLine.PartIDTH     = TempDocLine.PartIDTH + {&delim-par} + TempTrnLineMT.PartIDTH 
            .
          end.
  
        end.
        else do:
          create TempDocLine.
          assign
            TempDocLine.line-num     = TempTrnLineMT.pos
            TempDocLine.gds-code     = TempTrnLineMT.goodsid
            TempDocLine.b-code       = TempTrnLineMT.BC
            TempDocLine.fact-qnty    = cFactQnty
            TempDocLine.doc-qnty     = cDocQnty
            TempDocLine.price-rubl   = cPriceRubl
            TempDocLine.RowSum       = RowSum
            TempDocLine.PartIDTH = TempTrnLineMT.PartIDTH
            TempDocLine.NotDict      = TempTrnLineMT.goodsid eq 0
            .
        end.
      end.
      
      for each TempMarkLineMT 
/*      where TempMarkLineMT.DocName = TempTrnDoc.ext-doc-code*/
          :
      
        create TempMarkLine.
        assign
          TempMarkLine.DocName     =  TempMarkLineMT.DocName 
          TempMarkLine.PartIDTH    =  TempMarkLineMT.PartIDTH
          TempMarkLine.MarkCode    =  TempMarkLineMT.MarkCode
          TempMarkLine.Sts         =  TempMarkLineMT.Status_
          TempMarkLine.MarkParent  =  TempMarkLineMT.MarkParent     
          .
      end.

      updatedocument(doctype, table TempTrnDoc, table TempDocLine, table TempMarkLine, userId_).
      logWrite:WriteDebugLog("Загружен документ " + TempTrnDocMT.DocName).
    end.

    
    return true.
    
  end.
  
   
  method public void ttPrint(type as char,htable as handle):
     ttPrint(type, htable, cp).
  end.
  
  method public void ttPrint(type as char, htable as handle, encoding as char):
     if type eq "xml"
     then
        htable:WRITE-XML("longchar",SomeStr, true, encoding, ?, false, true ,false,true).
     else if type eq "json"
     then do:
        htable:WRITE-json("longchar",SomeStr,TRUE,?,true,true,false).
     end.
     else
        SomeStr = getStatusXml(false,"Тип ответа не подерживается responseType должно быть xml или json") .
  end.
  method public void docClear():
     empty temp-table TempTrnDocMT.
     empty temp-table TempTrnLineMTs.
     empty temp-table TempTrnLineMT.
     empty temp-table TempTrnLineMTs.
     empty temp-table TempTrnLineMT.
  end.
  define STREAM sReadDir.
  
  define temp-table tt-version no-undo
     field fnAME    as character 
     field FullPath as character 
     field device   as character 
     field version  as character 
  index version device version
  index fnAME FullPath fnAME. 
  method private void importVersion():
     define variable vPureName as character no-undo.
     define variable vFullPath as character no-undo.
     define variable vFileType as character no-undo.
     define variable mpos as integer no-undo.
     define buffer ttfile for tt-version.
     empty temp-table tt-version.
     define variable vDir as character no-undo.
     vdir = replace(search("exe/7z.exe"),"7z.exe","tsd").
     if objExists(vdir,"d") ne ?
     then do:
        input STREAM sReadDir FROM os-dir(vdir).
        repeat:
           import stream sReadDir vPureName vFullPath vFileType.
           if vPureName begins "." then next.
           if vFileType =  "f" then 
           do:
              find first ttfile where ttfile.FullPath = vFullPath 
                                  and ttfile.fnAME     = vPureName
              no-error.
              if not available ttfile
              then do:
                 create ttfile.
                 assign
                    ttfile.fnAME         = vPureName
                    ttfile.FullPath      = vFullPath
                 no-error.
                 mpos = r-index (vPureName,".").
                 if mpos > 0
                 then
                    vPureName = substring (vPureName,1,mpos - 1).
                 mpos = index (vPureName,"_").
                 if mpos = 0
                 then
                    ttfile.device = vPureName.
                 else assign 
                    ttfile.device  = CAPS(substring (vPureName,1,mpos - 1))
                    ttfile.version = substring (vPureName,  mpos + 1)
                 .
              end.
           end.
         end.
      end.
   end.
                       
   method public void getListVersions():
       importVersion(). 
       SomeStr = getStatusXml(true,"",getVersion()).
   end.
   method private longchar getVersion():
      define variable vVertion as longchar no-undo.
      for each tt-version break by tt-version.device:
         if first-of (tt-version.device)
         then do:
             vVertion = vVertion + substitute ("<&1><VERSIONS>",tt-version.device).
             
         end.
         vVertion = vVertion + substitute ("<VERSION>&1</VERSION>",tt-version.version).
         
         if last-of (tt-version.device)
         then do:
            vVertion = vVertion + substitute ("</VERSIONS><LASTVERSION>&2</LASTVERSION></&1>",tt-version.device,tt-version.version).
         end.
         
      end.
      return vVertion.
   end.
   
   method public char getFileVersion(iDevice as char,iversion as char):
      importVersion().
      if iversion = "" or iversion = ?
      then
         find last tt-version where tt-version.device = iDevice no-lock no-error.
      else
         find first tt-version where tt-version.device = iDevice
                                 and tt-version.version = iversion 
         no-lock no-error.
      return if available tt-version then tt-version.FullPath else ?.
   end.
   
   method public character addPrintBc(igds-code as integer, iqnty as decimal):
      
      define buffer code for code.
      define buffer goods for goods.
      define buffer bar-code for bar-code.
      find first goods where goods.gds-code =  igds-code no-lock no-error.
      if not available goods
      then
         return substitute ("Не известный код товара &1", igds-code).
      find first code  where code.parent eq "TiketPrint" 
                         and code.code   eq string(igds-code)
      exclusive-lock no-error.
      if not available code
      then do:
         create code.
         assign
            code.parent = "TiketPrint" 
            code.code = string(igds-code)
            Code.CodeValue = string(iqnty)  
         .
      end.
      assign
         Code.CodeName = goods.gds-name
         code.status_ = {&bef-current-status-int}
      .
  end.
   
  { utl/gtin.i class }

end class.

