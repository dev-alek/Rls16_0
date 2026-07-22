block-level on error undo, throw.
/*

$Revision: 0d5da778db5d, 1549, rls $
$Author: ASMorozov $
$Date: Wed Oct 17 22:18:22 2018 +0300 $
$Workfile: AdapteeProcOra-i506-1c.p $
$Archive: ibs/th/skt/Adapters/AdapteeProcOra-i506-1c.p $



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

{ cmp/library.i  }
{ utl/tt506.i}
{ibs/th/skt/ControlledClients/TSDTT-1c.i}

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
      temp_trn-doc.ext-doc-type  = TempTrnDoc.ext-doc-type
      temp_trn-doc.doc-code      = TempTrnDoc.ext-doc-code
      temp_trn-doc.cli-type      = TempTrnDoc.cli-type
      temp_trn-doc.cli-code      = TempTrnDoc.cli-code
      temp_trn-doc.obj-type      = TempTrnDoc.obj-type
      temp_trn-doc.obj-code      = TempTrnDoc.obj-code
      temp_trn-doc.contract-code = ?
      .
    
    for each TempDocLine no-lock:
      
      create temp_gds-line.
      
      assign
        temp_gds-line.doc-code   = TempTrnDoc.ext-doc-code
        temp_gds-line.line-num   = TempDocLine.line-num
        temp_gds-line.gds-code   = TempDocLine.gds-code
        temp_gds-line.line-qnty  = TempDocLine.fact-qnty
        .
      
    end.
    
  end.

  { gbl/curdbnum.i
      iDbNum
    }

  run utl/ora-i506-1c.p (
    input this-procedure ,
    input this-procedure ,
    input table temp_trn-doc ,
    input table temp_gds-line ,
    input table temp_grp-line ,
    output num-rec-ok
    ) no-error .
  if error-status:error 
    then return error return-value.
  
  

end.


procedure pcall-log-file:
  
  define input parameter msg as character no-undo.
  
  assign 
    LogWrite:LogStr = msg
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
