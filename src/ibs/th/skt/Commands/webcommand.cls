/*

$Revision: 43c09557cdee, 3584, rls $
$Author: DRuban $
$Date: 2023/12/28 12:56:36 $
$Workfile: webCommand.cls $
$Archive: ibs/th/skt/Commands/webCommand.cls $



Автор: Морозов Александр Сергеевич
Дата создания: 01/30/15
Author: Alexandr Morozov
Creation date: 01/30/15

*/

using ibs.th.skt.*.
using ibs.th.skt.Commands.*.
using ibs.th.skt.ControlledClients.*.
using ibs.th.skt.Adapters.*.
block-level on error undo, throw.

class ibs.th.skt.Commands.webCommand inherits ICommand: 
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Обработка запросов в сокет по web" get.
  
  { cmp/str-glbl.i class}  
  {ibs/th/skt/ControlledClients/websrvTT.i}
  
  define public property ErrStatus as logical no-undo 
    get.
    private set.

  define public property LogMsg as character no-undo 
    get.
    private set.

  define private variable websrv      as class     websrv .
  define private variable hRoot       as handle    no-undo.
  define private variable hDoc        as handle    no-undo.
  define private variable hRow        as handle    no-undo.
  define private variable tthDocument as handle    no-undo.
  define private variable i           as integer   no-undo.
  define private variable userId_     as character no-undo.
  define private variable sn          as character no-undo.
  define private variable hndlSocket  as handle    no-undo.
  define private variable good        AS LOGICAL   NO-UNDO.
  define private variable line-num    as integer no-undo .
  define private variable v-type      as character no-undo .

  method public override void Execute_( input req as IRequest, resp as class IResponse ):
  
  do transaction:

    &scop CRLF chr(13) + chr(10)
    &scop HdEnd chr(13) + chr(10) + chr(13) + chr(10)
    
/*    define variable resp       as class     IResponse no-undo.*/
    define variable contLength as integer   no-undo.
    define variable strLog     as character no-undo.
    define variable str        as character no-undo.
    define buffer buf_bar-code  for ub.bar-code.
    define buffer buf_prod-bc   for ub.prod-bc.
    define buffer buf_place     for ub.place.
    define buffer bfTempDocLine for TempDocLine.
    define variable ANS as logical .
    
    websrv = new websrv().
    
    create x-document hDoc.
    create x-noderef  hRoot.
/*    create x-noderef  hRow.*/
    
    hDoc:load("longchar",req:Content,no).
    websrv:CP = hDoc:encoding.
    if hDoc:encoding <> "windows-" + session:charset then
    do:
      str = req:Content.
      str = codepage-convert (str, session:charset, hDoc:encoding) no-error.
      if error-status:error
        then return error "Ошибка при преобразовании кодировки".
      req:Content = str.
      delete object hDoc.
      create x-document hDoc.
      hDoc:load("longchar",req:Content,no).
    end.
    hDoc:encoding = if session:charset begins "12" then "windows-" + session:charset else session:charset.
    hDoc:get-document-element(hRoot) .
    assign
/*      websrv:ObjCode = integer (substring (hRoot:get-attribute("to"), 4))*/
/*      websrv:ObjType = substring (hRoot:get-attribute("to"), 1, 3)       */
      websrv:ReqType = hRoot:get-attribute("item")
    .
    hndlsocket = req:HndlSocket.
    case websrv:ReqType :
      when "WAYBILL" then 
        do:
/*            run gbl/inidebug.p .*/
          parseXML(hRoot, 1).

/*          for each TempDocLine no-lock where not TempDocLine.b-code matches ("*" + string (TempDocLine.gds-code) + "*"):                                                           */
/*                                                                                                                                                                                   */
/*            find first bfTempDocLine where bfTempDocLine.gds-code = TempDocLine.gds-code and bfTempDocLine.b-code matches ( "*" + string (bfTempDocLine.gds-code) + "*")  no-error.*/
/*            find buf_bar-code where                                                                                                                                                */
/*              buf_bar-code.gds-code = TempDocLine.gds-code and TempDocLine.b-code matches ("*" + string(buf_bar-code.b-code)+ "*") no-error.                                       */
/*                                                                                                                                                                                   */
/*                                                                                                                                                                                   */
/*            if not available buf_bar-code then do:                                                                                                                                 */
/*                                                                                                                                                                                   */
/*              find first buf_prod-bc where buf_prod-bc.b-str = TempDocLine.b-code no-error.                                                                                        */
/*              if available buf_prod-bc                                                                                                                                             */
/*              then do:                                                                                                                                                             */
/*                find first buf_bar-code where buf_bar-code.b-code = buf_prod-bc.b-code and buf_bar-code.gds-code = TempDocLine.gds-code no-error.                                  */
/*              end.                                                                                                                                                                 */
/*                                                                                                                                                                                   */
/*              if not available buf_bar-code then do:                                                                                                                               */
/*                LogWrite:LogStr = 'Отправлен ответ на запрос типа "WAYBILL".' + {&new-line} + "Не известный штрих-код:" + TempDocLine.b-code.                                      */
/*                tsd:SomeStr = tsd:getStatusXml(false, "Не известный штрих-код:" + TempDocLine.b-code).                                                                             */
/*                writeSock("").                                                                                                                                                     */
/*                return resp.                                                                                                                                                       */
/*              end.                                                                                                                                                                 */
/*                                                                                                                                                                                   */
/*            end.                                                                                                                                                                   */
/*                                                                                                                                                                                   */
/*            if not available bfTempDocLine                                                                                                                                         */
/*            then do:                                                                                                                                                               */
/*              create bfTempDocLine.                                                                                                                                                */
/*              assign                                                                                                                                                               */
/*                bfTempDocLine.gds-code = TempDocLine.gds-code                                                                                                                      */
/*                bfTempDocLine.b-code = string (TempDocLine.gds-code)                                                                                                               */
/*              .                                                                                                                                                                    */
/*            end.                                                                                                                                                                   */
/*                                                                                                                                                                                   */
/*            assign                                                                                                                                                                 */
/*              bfTempDocLine.doc-qnty  = bfTempDocLine.doc-qnty + TempDocLine.doc-qnty * buf_bar-code.cli-base-rate                                                                 */
/*              bfTempDocLine.fact-qnty = bfTempDocLine.fact-qnty + TempDocLine.fact-qnty * buf_bar-code.cli-base-rate                                                               */
/*              bfTempDocLine.RowSum    = bfTempDocLine.RowSum + TempDocLine.RowSum                                                                                                  */
/*              .                                                                                                                                                                    */
/*            delete TempDocLine.                                                                                                                                                    */
/*                                                                                                                                                                                   */
/*          end.                                                                                                                                                                     */
/*                                                                                                                                                                                   */
/*          for each TempDocLine no-lock:                                                                                                                                            */
/*            assign                                                                                                                                                                 */
/*              TempDocLine.price-rubl = TempDocLine.RowSum / TempDocLine.fact-qnty.                                                                                                 */
/*              .                                                                                                                                                                    */
/*                                                                                                                                                                                   */
/*          end.                                                                                                                                                                     */
          
          websrv:ImpWB(table TempTrnDoc, table TempDocLine, table TempGdsDtl, table TempParts, table TempDocAttr, output ANS) .
            if ANS then ErrStatus = false.
            else ErrStatus = true.
          
        end.

      otherwise 
      do:
        websrv:WriteUnknown().
      end.
    end.
/*    tsd:CodePageConvert().*/

    case websrv:ReqType :
      when "WAYBILL" then 
        do:
          LogWrite:LogStr = 'Отправлен ответ на запрос типа "WAYBILL".' + {&new-line} + LogWrite:LogStr.
        end.
        
    end case.

    if ErrStatus then 
    do:
      writeSock("").
/*      if ErrStatus = true then undo.*/
    end.
    else do:
      writeSock(str).
/*      if ErrStatus = true then undo.*/
    end.
    
  end /*trans*/.
    delete object websrv.
/*  return resp.*/
    
  end method.


  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  method private void parseXML(hParent AS HANDLE, level AS INTEGER):
    
    DEFINE VARIABLE ii AS INTEGER NO-UNDO.
    DEFINE VARIABLE hNoderef AS HANDLE NO-UNDO.
    DEFINE VARIABLE hText AS HANDLE NO-UNDO.
    
    CREATE X-NODEREF hNoderef.
    CREATE X-NODEREF hText .

    REPEAT ii = 1 TO hParent:NUM-CHILDREN:
        good = hParent:GET-CHILD(hNoderef,ii).
        IF NOT good THEN 
            LEAVE.
        IF hNoderef:SUBTYPE <> "element" THEN
            NEXT.
            
        hNoderef:GET-CHILD(hText, 1) no-error .
/*        if (hText:node-value = ? or trim(hText:node-value) = "")           */
/*           and hNoderef:NAME <> "trn-doc" and hNoderef:NAME <> "docLine"   */
/*           and hNoderef:NAME <> "gds-dtl" and hNoderef:NAME <> "parts" then*/
/*            NEXT.                                                          */
        
        if hNoderef:NAME = "trn-doc" then do :
            create TempTrnDoc .
            line-num = 0 .
        end.
        if hNoderef:NAME = "SuppInDocNo"        then do :
            assign TempTrnDoc.SuppInDocNo =        hText:node-value no-error .
/*            create TempDocAttr .                                        */
/*            assign                                                      */
/*                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo        */
/*                TempDocAttr.attr-code   = {&trdcattr-doc-num-in-ext-sys}*/
/*                TempDocAttr.attr-value  = hText:node-value              */
/*            no-error.                                                   */
/*            if error-status:error then delete TempDocAttr .             */
        end.
        if hNoderef:NAME = "Stts"               then assign TempTrnDoc.Stts =               hText:node-value no-error .
        if hNoderef:NAME = "ExtDocType"         then assign TempTrnDoc.ext-doc-type =       hText:node-value no-error .
        if hNoderef:NAME = "DocDate"            then assign TempTrnDoc.doc-date =           date(hText:node-value) no-error .
        if hNoderef:NAME = "ContractId"         then assign TempTrnDoc.ContractID =         integer(hText:node-value) no-error .
        if hNoderef:NAME = "ContractNum"        then assign TempTrnDoc.ContractNum =        hText:node-value no-error .
        if hNoderef:NAME = "CliType"            then assign TempTrnDoc.cli-type =           hText:node-value no-error .
        if hNoderef:NAME = "CliCode"            then assign TempTrnDoc.cli-code =           integer(hText:node-value) no-error .
        if hNoderef:NAME = "ObjType"            then assign TempTrnDoc.obj-type =           hText:node-value no-error .
        if hNoderef:NAME = "ObjCode"            then assign TempTrnDoc.obj-code =           integer(hText:node-value) no-error .
        if hNoderef:NAME = "VatType"            then assign TempTrnDoc.vat-type =           hText:node-value no-error .
        if hNoderef:NAME = "TransportExpSuppl"  then assign TempTrnDoc.tot-transp =         decimal(hText:node-value) no-error .
        if hNoderef:NAME = "OtherExpSuppl"      then assign TempTrnDoc.tot-other =          decimal(hText:node-value) no-error .
        if hNoderef:NAME = "Wrkr"               then assign TempTrnDoc.wrkr =               integer(hText:node-value) no-error .
        if hNoderef:NAME = "Agnt"               then assign TempTrnDoc.agnt =               integer(hText:node-value) no-error .
        if hNoderef:NAME = "Boss"               then assign TempTrnDoc.boss =               integer(hText:node-value) no-error .
        if hNoderef:NAME = "PayCode"            then assign TempTrnDoc.pay-code =           integer(hText:node-value) no-error .
        if hNoderef:NAME = "DiscntType"         then assign TempTrnDoc.discnt-type =        hText:node-value no-error .
        if hNoderef:NAME = "DiscntPc"           then assign TempTrnDoc.discnt-pc =          decimal(hText:node-value) no-error .
        if hNoderef:NAME = "User-id"            then assign TempTrnDoc.user-id =            hText:node-value no-error .
        if hNoderef:NAME = "PS"                 then assign TempTrnDoc.ps =                 hText:node-value no-error . 
        if hNoderef:NAME = "ReasonCode"         then assign TempTrnDoc.reason-code =        integer(hText:node-value) no-error .
        if hNoderef:NAME = "hold-obj-type"      then assign TempTrnDoc.hold-obj-type =      hText:node-value no-error . 
        if hNoderef:NAME = "hold-obj-code"      then assign TempTrnDoc.hold-obj-code =      integer(hText:node-value) no-error .
        if hNoderef:NAME = "ShipNum"            then assign TempTrnDoc.ship-num =           hText:node-value no-error .
        if hNoderef:NAME = "ShipDate"           then assign TempTrnDoc.ship-date =          date(hText:node-value) no-error .
        
        if hNoderef:NAME = "PlaceStorage" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-place-storage}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "QntyPlace" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-qntyplace}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "Packer" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-packer}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "Dispath" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-dispath}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "NFinDoc" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-nfindoc}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "DFinDoc" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-dfindoc}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "clcasol" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-clcasol}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "clcaswt" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-clcaswt}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "indoclnsum" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-indoclnsum}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "purchlimit" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-purchlimit}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "purchcodelist" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-purchcodelist}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "expense_own" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-expense_own}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "priceTarget" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-price-target}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "envd" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-envd}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "discntStop" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-discnt-stop}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "discntOther" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-discnt-other}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "scanfile" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-scanfile}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "addsum" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-addsum}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "F21ord_phone" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-ord_phone}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "F22ord_contact" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-ord_contact}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "F4ord_dl" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-ord_dl}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "F8ord_adr" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-ord_adr}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "Auto" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-auto}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "cargo-desc" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-cargo-desc}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "cargo-mass" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-cargo-mass}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "carry-type" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-carry-type}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "ddog" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-ddog}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "ddov" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-ddov}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "dids" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-dids}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "nids" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-nids}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "negais" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-negais}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "egais" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-egais}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "delivery-date" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-delivery-date}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "delivery-time" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-delivery-time}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
/*        if hNoderef:NAME = "cargo-doc" then do :                */
/*            create TempDocAttr .                                */
/*            assign                                              */
/*                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo*/
/*                TempDocAttr.attr-code   = {&trdcattr-cargo-doc} */
/*                TempDocAttr.attr-value  = hText:node-value      */
/*            no-error.                                           */
/*            if error-status:error then delete TempDocAttr .     */
/*        end.                                                    */
/*        if hNoderef:NAME = "EI-pack" then do :                  */
/*            create TempDocAttr .                                */
/*            assign                                              */
/*                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo*/
/*                TempDocAttr.attr-code   = {&trdcattr-EI-pack}   */
/*                TempDocAttr.attr-value  = hText:node-value      */
/*            no-error.                                           */
/*            if error-status:error then delete TempDocAttr .     */
/*        end.                                                    */
        if hNoderef:NAME = "ptbobj" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-ptbobj}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "autoent" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-autoent}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "car-num" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-car-num}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "fio-driver" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-fio-driver}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "time-income" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-time-income}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "inspection-cert" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-inspection-cert}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "date-cert" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-date-cert}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "condition" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-condition}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
/*        if hNoderef:NAME = "date-pour" then do :                */
/*            create TempDocAttr .                                */
/*            assign                                              */
/*                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo*/
/*                TempDocAttr.attr-code   = {&trdcattr-date-pour} */
/*                TempDocAttr.attr-value  = hText:node-value      */
/*            no-error.                                           */
/*            if error-status:error then delete TempDocAttr .     */
/*        end.                                                    */
/*        if hNoderef:NAME = "time-pour" then do :                */
/*            create TempDocAttr .                                */
/*            assign                                              */
/*                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo*/
/*                TempDocAttr.attr-code   = {&trdcattr-time-pour} */
/*                TempDocAttr.attr-value  = hText:node-value      */
/*            no-error.                                           */
/*            if error-status:error then delete TempDocAttr .     */
/*        end.                                                    */
        if hNoderef:NAME = "seals-condition" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-seals-condition}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "ptb-item-pour" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-ptb-item-pour}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "postpay" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-postpay}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "Driver" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-driver}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "dsf" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-dsf}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "exp-trans" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-exp-trans}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "ndog" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-ndog}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "ndov" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-ndov}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "ndovwho" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-ndovwho}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "nosn" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-nosn}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "nsf" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-nsf}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "dateinv" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-dateinv}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "ser_on_pack" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-ser_on_pack}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "print-num" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-print-num}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "Recipient" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-recipient}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "Shipper" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-shipper}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "oldsuppcntr" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-oldsuppcntr}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "t_accept-fname" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-t_accept-fname}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "t_accept-position" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-t_accept-position}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "t_pass-fname" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-t_pass-fname}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "t_pass-position" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-t_pass-position}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "zakaz-date" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-zakaz-date}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "zakaz-number" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = {&trdcattr-zakaz-number}
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        
        if hNoderef:NAME = "doc-Line" then do :
            v-type = "doc-line" .
            create TempDocLine .
            line-num = line-num + 1 .
            assign
                TempDocLine.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocLine.line-num    = line-num
            no-error.
        end.
        if hNoderef:NAME = "gdsCode"        then assign TempDocLine.gds-code        = integer(hText:node-value) no-error .
        if hNoderef:NAME = "DocQnty"        then do :
            if v-type = "doc-line"          then assign TempDocLine.doc-qnty        = decimal(hText:node-value) no-error .
            if v-type = "gds-dtl"           then assign TempGdsDtl.doc-qnty         = decimal(hText:node-value) no-error .
        end.
        if hNoderef:NAME = "PriceRubl"      then assign TempDocLine.price-rubl      = decimal(hText:node-value) no-error .
        if hNoderef:NAME = "VatPcDoc"       then assign TempDocLine.vat-pc          = decimal(hText:node-value) no-error .
        
        if hNoderef:NAME = "gds-dtl" then do :
            v-type = "gds-dtl" .
            create TempGdsDtl .
            assign
                TempGdsDtl.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempGdsDtl.line-num    = TempDocLine.line-num
                TempGdsDtl.gds-code    = TempDocLine.gds-code
            .
        end.
        if hNoderef:NAME = "PrtCode"        then assign TempGdsDtl.prt-code         = integer(hText:node-value) no-error .
        if hNoderef:NAME = "BarCodeUnitBase" then assign TempGdsDtl.b-code          = integer(hText:node-value) no-error .
        if hNoderef:NAME = "PriceRublDoc"   then assign TempGdsDtl.price-rubl       = decimal(hText:node-value) no-error .
        
        if hNoderef:NAME = "parts" then do :
            create TempParts .
            assign
                TempParts.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempParts.line-num    = TempDocLine.line-num
                TempParts.gds-code    = TempDocLine.gds-code
            .
        end.
        if hNoderef:NAME = "partCode"       then assign TempParts.part-code         = hText:node-value no-error .
        if hNoderef:NAME = "parDocNum"      then assign TempParts.out-code          = hText:node-value no-error .
        
        parseXML(hNoderef, (level + 1)).
    end.
    
    DELETE OBJECT hNoderef.
    DELETE OBJECT hText.

  end method.  
  
  
  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  method private logical writeSock ( arg as character ):
    
    define variable mbuffer  as memptr   no-undo.
    define variable mbuffer1 as memptr   no-undo.
    define variable tempStr  as longchar no-undo.
    define variable glog     as logical  no-undo.
    
    
    
    set-size(mbuffer1) = length (websrv:SomeStr, "RAW":U) + 1.
    put-string(mbuffer1,1) = websrv:SomeStr.        
    
    assign
      glog = hndlsocket:write(mbuffer1,1,get-size(mbuffer1)) no-error.
    set-size(mbuffer1) = 0.
    if not glog
      then do:
        LogWrite:LogStr = LogWrite:LogStr + " " + "Ошибка при отправке сообщения удаленному клиенту.".
        ErrStatus = true.
      end.
    return true.
      
  end method.
  
  
end class.