block-level on error undo, throw.
/*

$Revision: 315b966a6a9b, 3487, rls $
$Author: BelovaMM $
$Date: 2023/10/16 15:13:36 $
$Workfile: AdapteeProcOra-i516-1c.p $
$Archive: ibs/th/skt/Adapters/AdapteeProcOra-i516-1c.p $



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

define variable vss-revision    as character no-undo init "$Revision: 315b966a6a9b, 3487, rls $":U .
define variable vss-author      as character no-undo init "$Author: BelovaMM $":U .
define variable vss-date        as character no-undo init "$Date: 2023/10/16 15:13:36 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: AdapteeProcOra-i516-1c.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ibs/th/skt/Adapters/AdapteeProcOra-i516-1c.p $":U .
define variable vss-description as character no-undo init "Импорт накладных из временной таблицы".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ utl/tt516-1c.i}
{ibs/th/skt/ControlledClients/TSDTT-1c.i}
{ gbl/getcntxt.i def }
{ str/doc-code.i }
{ str/trdcalib.i }

define shared variable g#auto-user-id as character no-undo .


define input  parameter table for  TempTrnDoc.
define input  parameter table for  TempDocLine.
define input  parameter table for  TempDocPart.
define input  parameter table for  TempDocMark.
define input  parameter userId_ as character no-undo.


define variable iDbNum as integer no-undo.

MAIN-BLOCK:
do:
  
  define variable num-rec-ok as logical no-undo.
  define variable ii         as integer no-undo.
  define variable logWrite   as class   LogWrite no-undo.
  define variable v-doc-code as character no-undo.

  logWrite = new LogWrite().

  empty temp-table temp_trn-doc.
  empty temp-table temp_doc-line.
  empty temp-table temp_doc-mark. 
  
  for each TempTrnDoc no-lock:
    
    ii = ii + 1.

    if TempTrnDoc.ext-doc-code = ? or TempTrnDoc.ext-doc-code = ""
    then do:
      run doc-code in this-procedure
        ( input  "main":U,
          input  TempTrnDoc.obj-type,
          input  TempTrnDoc.obj-code,
          input  ? ,
          output TempTrnDoc.ext-doc-code ) no-error.
    end.

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
      temp_trn-doc.contract-code = if TempTrnDoc.dog-code <> ? then integer (TempTrnDoc.dog-code) else 0
      temp_trn-doc.price-type    = if TempTrnDoc.ext-doc-type = {&TDEDT_Ras_Vnesh } then "TSFTSD" else ""
      temp_trn-doc.doc-code      = TempTrnDoc.ext-doc-code
      temp_trn-doc.doc-id        = TempTrnDoc.doc-id
      .
    
    if TempTrnDoc.source-doc ne ? and TempTrnDoc.source-doc ne ""
    then do:
      find first ub.doc-attr no-lock where ub.doc-attr.attr-code = {&trdcattr-nids} and ub.doc-attr.attr-value = TempTrnDoc.source-doc no-error.
      
      find first ub.trn-doc no-lock where ub.trn-doc.doc-code = ub.doc-attr.doc-code no-error.
      
      if available (ub.doc-attr) and available (ub.trn-doc)
      then do:
        assign
          temp_trn-doc.cli-type = ub.trn-doc.cli-type
          temp_trn-doc.cli-code = ub.trn-doc.cli-code
          temp_trn-doc.out-code = ub.doc-attr.doc-code
          temp_trn-doc.contract-code = ub.trn-doc.contract-code.
      end.
      else do:
        if error-status:error 
          then return error "Не найдена накладная-источник внешней системы с ИД  - " + TempTrnDoc.source-doc .
      end.
    end.
    
  end.

  for each TempDocLine no-lock:
    
    create temp_doc-line.
    
    assign
      temp_doc-line.line-num     = TempDocLine.line-num
      temp_doc-line.gds-code     = TempDocLine.gds-code
      temp_doc-line.fact-qnty    = TempDocLine.fact-qnty
      temp_doc-line.doc-qnty     = TempDocLine.doc-qnty
      temp_doc-line.price-cli    = TempDocLine.price-rubl
      temp_doc-line.price-rubl   = TempDocLine.price-rubl
      temp_doc-line.doc-code     = temp_trn-doc.doc-code
      temp_doc-line.doc-density  = TempDocLine.fact-dnsty
      temp_doc-line.fact-density = TempDocLine.fact-dnsty
      temp_doc-line.cli-qnty     = TempDocLine.cli-qnty
      temp_doc-line.part-id      = TempDocLine.part-id
      temp_doc-line.vsd-uuid     = TempDocLine.vsd-uuid
      temp_doc-line.vat-pc       = TempDocLine.vat-pc
      .
    
  end.
  
  for each TempDocMark no-lock:
    
    create temp_doc-mark.
    
    assign
      temp_doc-mark.part-id  = TempDocMark.prt-id
      temp_doc-mark.mark     = TempDocMark.mark
      temp_doc-mark.gds-code = TempDocMark.gds-code
      temp_doc-mark.gtin     = TempDocMark.gtin
      temp_doc-mark.gtin_qnt = TempDocMark.gtin_qnt
      temp_doc-mark.upd_id   = TempDocMark.upd_id
    .
    
  end.
  
  { gbl/curdbnum.i
      iDbNum
    }
  find first temp_doc-line where temp_doc-line.fact-density > 0 no-error.
  if available (temp_doc-line)
  then do:
    run utl/ora-i517.p (
      input this-procedure ,
      input this-procedure ,
      input table temp_trn-doc ,
      input table temp_doc-line ,
      output v-doc-code,
      output num-rec-ok
      ) no-error .
    if error-status:error 
      then return error return-value.
  end.
  else do:
    find first TempTrnDoc .
    if TempTrnDoc.ext-doc-type = {&TDEDT_Pri_Perem}
    or TempTrnDoc.ext-doc-type = {&TDEDT_Vozvrat_Perem}
    then do :
      run utl/trndocmv-1c.p (
        input this-procedure ,
        input table TempTrnDoc ,
        input table TempDocLine ,
        input table TempDocPart ,
        input table TempDocMark
        ) no-error .
      if error-status:error 
        then return error return-value.
      return .
    end .
    else do :
      run utl/ora-i516-1c.p (
        input this-procedure ,
        input this-procedure ,
        input table temp_trn-doc ,
        input table temp_doc-line ,
        input table temp_doc-mark ,
        output v-doc-code,
        output num-rec-ok
        ) no-error .
      if error-status:error 
        then return error return-value.
    end .
  end.
  find first ub.trn-doc no-lock where ub.trn-doc.doc-code  = v-doc-code no-error.
  case ub.trn-doc.ext-doc-type:
    when {&TDEDT_Pri_Vnesh} then do:
      if ub.trn-doc.cli-type = 'маг' 
      then do:
        disable triggers for load of ub.trn-doc.
        find current ub.trn-doc exclusive-lock .  
        ub.trn-doc.ext-doc-type = {&TDEDT_Pri_Perem}.
        ub.trn-doc.internal = true.
        ub.trn-doc.discnt-type = {&percent}.
      end.
    end.
    when {&TDEDT_Vozvrat_Vnesh} then do:
      if ub.trn-doc.cli-type = 'маг' 
      then do:
        disable triggers for load of ub.trn-doc.
        find current ub.trn-doc exclusive-lock .  
        ub.trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Perem}.
        ub.trn-doc.internal = true.
        ub.trn-doc.discnt-type = {&percent}.
      end.
    end.
  end case.  
  
  /* для внутреннего прихода заполняем атрибут Прочие перемещения */
  if ub.trn-doc.ext-doc-type = {&TDEDT_Pri_Perem}
  then do:
    { str/tdat-wrt.i 
             ub.trn-doc.doc-code
             {&trdcattr-othermoves}
             "yes" 
             no-error }
     if error-status:error 
        then return error return-value.
  end.

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
