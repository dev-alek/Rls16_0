/*

$Revision: c40b85de8d6c, 956, rls $
$Author: SSlivenko $
$Date: Thu Feb 16 15:19:57 2017 +0300 $
$Workfile: websrv.cls $
$Archive: ibs/th/skt/ControlledClients/websrv.cls $



Автор: Морозов Александр Сергеевич
Дата создания: 01/30/15
Author: Alexandr Morozov
Creation date: 01/30/15

*/

using Progress.Lang.*.
using ibs.th.skt.Commands.*.
using ibs.th.skt.ControlledClients.*.
using ibs.th.skt.Adapters.*.
using ibs.th.skt.*.
block-level on error undo, throw.


class ibs.th.skt.ControlledClients.websrv : 

  &scop delimiteFld chr(9)
  &scop delimiterLine chr(31)
  
  { cmp/str-glbl.i class}
  {ibs/th/skt/ControlledClients/websrvTT.i}
  
  define stream str1 .
  define stream str2 .

  define public property SomeStr as longchar no-undo
    get.
    set.

  define public property ObjCode as integer no-undo
    private get.
    set.
    
  define public property ObjType as character no-undo
    private get.
    set.

  define public property SN as character no-undo
    private get.
    set.

  define public property ReqType as character no-undo
    get.
    set.

  define public property CP as character no-undo
    get.
    set.

  define private buffer buf_user      for ub.user-login.
  define private buffer buf_goods     for ub.goods.
  define private buffer buf_clients   for ub.clients.
  define private buffer buf_shop      for ub.shop.
  define private buffer buf_store     for ub.store.
  define private buffer buf_bar-code  for ub.bar-code.
  define private buffer buf_gds-obj   for ub.gds-obj.
  define private buffer buf_price-all for ub.price-all.
  define private buffer buf_prod-bc   for ub.prod-bc.
  define private buffer buf_trn-doc   for ub.trn-doc.
  define private buffer buf_doc-line  for ub.doc-line.
  define private variable tthDocument as handle no-undo.
  define private stream webstream.
  define private variable logWrite as class LogWrite no-undo.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
		
  constructor public websrv (  ):
    
    logWrite = new LogWrite().
		
  end constructor.



  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  method private void webstreamopen (streamFile as char):
    
    output stream webstream to value (streamFile).

  end method.


  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  method private void webstreamclose ():
    
    output stream webstream close.

  end method.  
  
  
  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  method public character getStatusXml (statusOk as logical, statusMsg as char):
    
    define variable statusOkTag as character no-undo.
    define variable statusMsgTag as character no-undo. 
  
    assign
      statusOkTag = substitute ('<STATUS>&1</STATUS>', if statusOk then "OK" else "ERROR")
      statusMsgTag = if statusOk then '' else substitute ('<STATUS_MESSAGE>&1</STATUS_MESSAGE>', statusMsg)
    .
    return substitute ('<?xml version="1.0" encoding="&1"?><websrv>&2&3</websrv>', CP, statusOkTag, statusMsgTag).

  end method.

  

/*  method public void Check_ ():                                                                                */
/*                                                                                                               */
/*    define variable confPar   as character no-undo.                                                            */
/*    define variable parType   as character no-undo.                                                            */
/*    define variable statusOK  as logical   no-undo init false.                                                 */
/*    run gbl/conf-rd.p ("tsd-list", "", "", 0, "", "", "", no, output confPar, output parType) no-error.        */
/*    if lookup (SN, confPar, ";") > 0                                                                           */
/*      then statusOK = true.                                                                                    */
/*    find first buf_clients no-lock                                                                             */
/*      where buf_clients.obj-type = ObjType and buf_clients.obj-code = ObjCode no-error.                        */
/*    if available (buf_clients)                                                                                 */
/*      then statusOK = true.                                                                                    */
/*	  else statusOK = false.                                                                                      */
/*    SomeStr =                                                                                                  */
/*      if statusOK = true                                                                                       */
/*        then getStatusXml(statusOK, "")                                                                        */
/*        else if lookup (SN, confPar) = 0 then getStatusXml(statusOK, "LIC") else getStatusXml(statusOK, "OBJ").*/
/*                                                                                                               */
/*  end method.                                                                                                  */




  
  method public void ImpWB (table TempTrnDoc, table TempDocLine, table TempGdsDtl, table TempParts, table TempDocAttr, output ANS as logical):

    define variable adapter         as class AdapterWebSrv-TrnDoc.
    define variable glog            as logical         no-undo.
    define variable varzero-string  as logical no-undo.
    
    find first TempTrnDoc.
    
      adapter = new AdapterWebSrv-TrnDoc().
      
      adapter:SetTempTable(table TempTrnDoc, table TempDocLine, table TempGdsDtl, table TempParts, table TempDocAttr).
      
      adapter:WriteDB(glog) no-error.
  
      LogWrite:LogStr = LogWrite:LogStr + {&new-line} + adapter:StrLog.
      delete object adapter.
  
      if glog
        then do:
          SomeStr = getStatusXml(true, "").
          ANS = true.
        end.
        else do:
          SomeStr = getStatusXml(false, LogWrite:LogStr).
          ANS = false.
        end.
    
    
  end.
  


  method public void CodePageConvert ():
    
    define variable str as char no-undo.
    
    
    if session:charset <> replace (CP, "windows-", "") 
      then do:
        str = codepage-convert (SomeStr, replace (CP, "windows-", ""), session:charset) no-error.
        if str = ? 
          then.
          else SomeStr = str. 
      end.
        
  end.  
  

  method public void WriteUnknown ():
    
    SomeStr = getStatusXml(false, "Неизвестный запрос.").
   
  end.

  method public integer GetDbNum ():
    define buffer buf_sys-ctrl for ub.sys-ctrl .
  
    do
    on error undo, return error return-value
    :
      for first buf_sys-ctrl field (db-num) no-lock :
       return buf_sys-ctrl.db-num.
      end.
  
    end.
  end method.

end class.
