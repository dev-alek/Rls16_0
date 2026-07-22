block-level on error undo, throw.
/*

$Revision: 7873e57b4b99, 1540, rls $
$Author: ASMorozov $
$Date: Mon Oct 08 19:20:24 2018 +0300 $
$Workfile: AdapteeProcOra-i516.p $
$Archive: ibs/th/skt/Adapters/AdapteeProcOra-i516.p $



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
{ibs/th/skt/ControlledClients/TSDTT.i}
{ gbl/getcntxt.i def }

define temp-table tt-excisemarks no-undo
  field excisemarks      as character
  field beforRefB             as character
  index pi
  excisemarks
  .
define shared variable g#auto-user-id as character no-undo .


define input  parameter table for  TempTrnDoc.
define input  parameter table for  TempDocLine.
define input  parameter userId_ as character no-undo.


define variable iDbNum as integer no-undo.

MAIN-BLOCK:
do:
  
  define variable num-rec-ok as logical no-undo.
  define variable ii         as integer no-undo.
  define variable logWrite   as class   LogWrite no-undo.

  logWrite = new LogWrite().
  
  for each TempTrnDoc no-lock:
    
    ii = ii + 1.

    create temp_trn-doc.
    assign
      temp_trn-doc.line-num      = ii
      temp_trn-doc.doc-date      = TempTrnDoc.doc-date
      temp_trn-doc.ps            = TempTrnDoc.ps
      temp_trn-doc.doc-code      = TempTrnDoc.ext-doc-code
      temp_trn-doc.ext-doc-type  = TempTrnDoc.ext-doc-type 
      temp_trn-doc.cli-type      = TempTrnDoc.cli-type
      temp_trn-doc.cli-code      = TempTrnDoc.cli-code
      temp_trn-doc.obj-type      = TempTrnDoc.obj-type
      temp_trn-doc.obj-code      = TempTrnDoc.obj-code
      temp_trn-doc.exch-code     = 0
      temp_trn-doc.exch-rate     = 1
      temp_trn-doc.exch-scale    = 1
      temp_trn-doc.contract-code = ?
      temp_trn-doc.price-type    = if TempTrnDoc.ext-doc-type = {&TDEDT_Ras_Vnesh } then "TSFTSD" else ""
      .
    
  end.

  for each TempDocLine no-lock:
    
    create temp_doc-line.
    
    assign
      temp_doc-line.line-num   = TempDocLine.line-num
      temp_doc-line.gds-code   = TempDocLine.gds-code
      temp_doc-line.fact-qnty  = TempDocLine.fact-qnty
      temp_doc-line.doc-qnty   = TempDocLine.doc-qnty
      temp_doc-line.price-cli  = TempDocLine.price-rubl
      temp_doc-line.price-rubl = TempDocLine.price-rubl
      temp_doc-line.doc-code   = temp_trn-doc.doc-code
      .
    
  end.
  
  { gbl/curdbnum.i
      iDbNum
    }
  
  run utl/ora-i516.p (
    input this-procedure ,
    input this-procedure ,
    input table temp_trn-doc ,
    input table temp_doc-line ,
    input table tt-excisemarks,
    output num-rec-ok
    ) no-error .
  if error-status:error 
    then return error return-value.
  
  

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

  find first ub.user-login where ub.user-login.db-num = iDbNum and ub.user-login.user-id = userId_ no-error.
  
  if available ub.user-login
  then 
  do:
    assign
      pUserId  = userId_
      .
  end.
  else 
  do:
    assign
      pUserId = g#auto-user-id
      userId_ = g#auto-user-id
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
    p-cntxt-userid          =  userId_
    p-cntxt-level           =  v-cntxt-level
    p-cntxt-host-code-obj   =  vt-host-code
    p-cntxt-obj-type        =  temp_trn-doc.obj-type
    p-cntxt-obj-code        =  temp_trn-doc.obj-code
    p-cntxt-is-admin        =  v-cntxt-is-admin
  .

  end.
end procedure. /* mainmenu_getcntxt */
