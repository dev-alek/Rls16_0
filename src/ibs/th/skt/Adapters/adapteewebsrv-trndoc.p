block-level on error undo, throw.
/*

$Revision: c40b85de8d6c, 956, rls $
$Author: SSlivenko $
$Date: Thu Feb 16 15:19:57 2017 +0300 $
$Workfile: AdapteeWebSrv-TrnDoc.p $
$Archive: ibs/th/skt/Adapters/AdapteeWebSrv-TrnDoc.p $



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

{ cmp/str-glbl.i }
{ cmp/library.i  }
{ utl/tt516.i}
{ibs/th/skt/ControlledClients/websrvTT.i}
{ gbl/getcntxt.i def }

define shared variable g#auto-user-id as character no-undo .


define input  parameter table for  TempTrnDoc.
define input  parameter table for  TempDocLine.
define input  parameter table for  TempDocAttr.
define input  parameter table for  TempGdsDtl.
define input  parameter table for  TempParts.
define output parameter ERROR_ as logical no-undo .

define variable iDbNum as integer no-undo.

MAIN-BLOCK:
do:
  
  define variable num-rec-ok as logical no-undo.
  define variable logWrite   as class   LogWrite no-undo.

  logWrite = new LogWrite().
  
  for each TempTrnDoc no-lock:
    

    create temp_trn-doc.
    assign
      temp_trn-doc.doc-date      = TempTrnDoc.doc-date
      temp_trn-doc.ps            = TempTrnDoc.ps
      temp_trn-doc.doc-code      = TempTrnDoc.SuppInDocNo
      temp_trn-doc.ext-doc-type  = TempTrnDoc.ext-doc-type 
      temp_trn-doc.cli-type      = TempTrnDoc.cli-type
      temp_trn-doc.cli-code      = TempTrnDoc.cli-code
      temp_trn-doc.obj-type      = TempTrnDoc.obj-type
      temp_trn-doc.obj-code      = TempTrnDoc.obj-code
      temp_trn-doc.exch-code     = 0
      temp_trn-doc.exch-rate     = 1
      temp_trn-doc.exch-scale    = 1
      temp_trn-doc.contract-code = TempTrnDoc.ContractID
      temp_trn-doc.price-type    = ""
      temp_trn-doc.agnt          = TempTrnDoc.agnt
      temp_trn-doc.wrkr          = TempTrnDoc.wrkr
      temp_trn-doc.boss          = TempTrnDoc.boss
      temp_trn-doc.creid         = TempTrnDoc.user-id
      temp_trn-doc.vat-type      = TempTrnDoc.vat-type
      temp_trn-doc.pay-code      = TempTrnDoc.pay-code
      temp_trn-doc.reason-code   = TempTrnDoc.reason-code
      temp_trn-doc.stts          = TempTrnDoc.stts
      temp_trn-doc.hold-obj-type = TempTrnDoc.hold-obj-type
      temp_trn-doc.hold-obj-code = TempTrnDoc.hold-obj-code
      temp_trn-doc.ship-num      = TempTrnDoc.ship-num
      temp_trn-doc.ship-date     = TempTrnDoc.ship-date
      .
    
  

      for each TempDocLine no-lock where TempDocLine.SuppInDocNo = TempTrnDoc.SuppInDocNo :
        
        create temp_doc-line.
        
        assign
          temp_doc-line.line-num   = TempDocLine.line-num
          temp_doc-line.gds-code   = TempDocLine.gds-code
          temp_doc-line.fact-qnty  = TempDocLine.doc-qnty
          temp_doc-line.doc-qnty   = TempDocLine.doc-qnty
          temp_doc-line.price-cli  = TempDocLine.price-rubl
          temp_doc-line.price-rubl = TempDocLine.price-rubl
          temp_doc-line.vat-pc     = TempDocLine.vat-pc
          temp_doc-line.doc-code   = temp_trn-doc.doc-code
          .
        
      end.
  
  end.
  
  { gbl/curdbnum.i
      iDbNum
    }
  
  run utl/websrv_trn-doc.p (
    input this-procedure ,
    input this-procedure ,
    input table temp_trn-doc ,
    input table temp_doc-line ,
    input table TempGdsDtl ,
    input table TempParts ,
    input table TempDocAttr ,
    output num-rec-ok,
    output ERROR_
    ) no-error .
/*  if error-status:error            */
/*    then return error return-value.*/
  
  

end.


procedure pcall-log-file:
  
  define input parameter msg as character no-undo.
  
  assign 
    LogWrite:LogStr = LogWrite:LogStr + {&new-line} + msg
    .

end.


procedure get-db-num:
  
  define output parameter pDbNum as integer no-undo.
  
  pDbNum = iDbNum.

end.

procedure get-userid:

  define output parameter pUserId as character no-undo.

  find first ub.user-login where ub.user-login.db-num = iDbNum and ub.user-login.user-id = temp_trn-doc.creid no-error.
  
  if available ub.user-login
  then 
  do:
    assign
      pUserId  = temp_trn-doc.creid
      .
  end.
  else 
  do:
    assign
      pUserId = g#auto-user-id
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
    p-cntxt-userid          =  temp_trn-doc.creid
    p-cntxt-level           =  v-cntxt-level
    p-cntxt-host-code-obj   =  vt-host-code
    p-cntxt-obj-type        =  temp_trn-doc.obj-type
    p-cntxt-obj-code        =  temp_trn-doc.obj-code
    p-cntxt-is-admin        =  v-cntxt-is-admin
  .

  end.
end procedure. /* mainmenu_getcntxt */
