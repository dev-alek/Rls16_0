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

{ cmp/str-glbl.i }
{ cmp/library.i  }
{ utl/tt516.i}
{ gbl/getcntxt.i def }
{ str/trdcalib.i }
{ ref/alc-type-attr.i }

{ibs/th/bge/egais/wb-egais.i}

define input  parameter table for  tt-wb-header.
define input  parameter table for  tt-wb-gds-EG.
define input  parameter userId_ as character no-undo.
define input  parameter Mode as character no-undo.
define input-output parameter p-doc-code as character no-undo.
define stream outstr.

define variable iDbNum as integer no-undo.
define variable MsgLog as character no-undo.

define buffer buf_goods for ub.goods.
define buffer buf_doc-attr for ub.doc-attr.

MAIN-BLOCK:
do trans:
  
  define variable num-rec-ok as logical no-undo.
  define variable ii         as integer no-undo.
  define variable jj         as integer no-undo.
  define variable minPrice   as decimal no-undo.
  define variable logWrite   as class   LogWrite no-undo.

  find first tt-wb-header no-lock.
    
  { gbl/getcurus.i
    iDbNum
    userId_
    no-error
  }

  create temp_trn-doc.
  assign
    temp_trn-doc.line-num      = ii
    temp_trn-doc.doc-date      = tt-wb-header.wb-date
    temp_trn-doc.ps            = tt-wb-header.ps
    temp_trn-doc.doc-code      = tt-wb-header.wbregid + {&delim-cmd} + tt-wb-header.uniq-key-rec 
    temp_trn-doc.ext-doc-type  = tt-wb-header.wb-type
    temp_trn-doc.cli-type      = tt-wb-header.cli-type
    temp_trn-doc.cli-code      = tt-wb-header.cli-code
    temp_trn-doc.obj-type      = tt-wb-header.obj-type
    temp_trn-doc.obj-code      = tt-wb-header.obj-code
    temp_trn-doc.cargo-from    = tt-wb-header.cargo-from
    temp_trn-doc.exch-code     = 0
    temp_trn-doc.exch-rate     = 1
    temp_trn-doc.exch-scale    = 1
    temp_trn-doc.contract-code = ?
    temp_trn-doc.price-type    = if tt-wb-header.wb-type = {&TDEDT_Ras_Vnesh } then "TSFTSD" else ""
    .
    
  jj = 0.
  for each tt-wb-gds-EG no-lock:
    
    
    find first buf_goods no-lock where buf_goods.gds-code = tt-wb-gds-EG.gds-code no-error.
    
    if not available (buf_goods)
    then do:
      return error ("Не найден товар с кодом - " + string (tt-wb-gds-EG.gds-code)).
    end.
    
    jj = jj + 1.
    create temp_doc-line.
    
    assign
      temp_doc-line.line-num   = jj
      temp_doc-line.gds-code   = tt-wb-gds-EG.gds-code
      temp_doc-line.price-cli  = tt-wb-gds-EG.price
      temp_doc-line.doc-code   = temp_trn-doc.doc-code
      temp_doc-line.RefA = tt-wb-gds-EG.RefA
      temp_doc-line.RefB = tt-wb-gds-EG.RefB
      temp_doc-line.alc-code = tt-wb-gds-EG.alc-code
      temp_doc-line.alc-type-code = tt-wb-gds-EG.alc-type-code
      temp_doc-line.importer-th = tt-wb-gds-EG.importer-th
      temp_doc-line.line-num-str = tt-wb-gds-EG.Identity
    .
    
    find first ub.alc-type where ub.alc-type.alc-type-code = tt-wb-gds-EG.alc-type-code no-error. 
    
    if available (ub.alc-type)
    then do:
      run alc-type-attr-val (  input   ub.alc-type.alc-type-inner-code,
                               input   ub.alc-type.create-user-db-num,
                               input   "alc-min-price",
                               output  minPrice
                            )  no-error.
    end.
    
    if tt-wb-gds-EG.price < minPrice * buf_goods.cli-base-rate 
    then do:
      MsgLog = MsgLog + {&new-line} + substitute ("Для товара &2/&1 &3 цена в накладной ЕГАИС - &4 меньше допустимой - &5 по группе &6", tt-wb-gds-EG.alc-code, buf_goods.gds-code, tt-wb-gds-EG.gds-name, tt-wb-gds-EG.price * buf_goods.cli-base-rate, minPrice, tt-wb-gds-EG.alc-type-code).
    end.

    if tt-wb-header.UnitType <> ''
    then do:
      if true /* tt-wb-header.UnitType = 'UnPacked'*/ 
      then
        assign
          temp_doc-line.fact-qnty  = buf_goods.cli-base-rate * tt-wb-gds-EG.qnty
          temp_doc-line.doc-qnty   = buf_goods.cli-base-rate * tt-wb-gds-EG.qnty
          temp_doc-line.cli-qnty   = tt-wb-gds-EG.qnty
          temp_doc-line.price-cli = tt-wb-gds-EG.price
        .
      else
        assign
          temp_doc-line.fact-qnty  = tt-wb-gds-EG.qnty
          temp_doc-line.doc-qnty   = tt-wb-gds-EG.qnty
          temp_doc-line.cli-qnty   = tt-wb-gds-EG.qnty
          temp_doc-line.price-cli = tt-wb-gds-EG.price
        .
    end.
    else do:
      if tt-wb-gds-EG.UnitType = 'UnPacked' 
      then
        assign
          temp_doc-line.fact-qnty  = buf_goods.cli-base-rate * tt-wb-gds-EG.qnty
          temp_doc-line.doc-qnty   = buf_goods.cli-base-rate * tt-wb-gds-EG.qnty
          temp_doc-line.cli-qnty   = tt-wb-gds-EG.qnty
          temp_doc-line.price-cli = tt-wb-gds-EG.price
        .
      else
        assign
          temp_doc-line.fact-qnty  = tt-wb-gds-EG.qnty
          temp_doc-line.doc-qnty   = tt-wb-gds-EG.qnty
          temp_doc-line.cli-qnty   = tt-wb-gds-EG.qnty
          temp_doc-line.price-cli = tt-wb-gds-EG.price
        .    
    end.
    
    
  end.
  
  if MsgLog <> ""
  then do:
    output stream outstr to value ("warWBLog.txt").
    put stream outstr unformatted MsgLog.
    output stream outstr close.
    message substitute ("&2&1 Продолжить?", MsgLog, {&new-line}) view-as alert-box question buttons yes-no title "Вопрос..." update isChoise as logical.
    if isChoise
    then do:
      MsgLog = "".
    end.
    else do:
      return error "Отменено пользователем." .
    end.
  end.
  
  case Mode: 
    when "set-refAB"
    then do:
      run set-refAB no-error.
      if error-status:error 
      then do: 
        return error return-value .
      end.
    end.
    when "conn" then do:
      run set-refAB no-error.
      if error-status:error 
      then do: 
        return error return-value .
      end.
      def var temp-str as char no-undo.
      
      for each buf_doc-attr exclusive-lock where buf_doc-attr.attr-code = {&trdcattr-negais} and buf_doc-attr.attr-value begins (tt-wb-header.wbregid):
        delete buf_doc-attr.
      end.
      
      temp-str = string(tt-wb-header.wbregid + {&delim-cmd} + tt-wb-header.uniq-key-rec).
      { str/tdat-wrt.i
        p-doc-code
        {&trdcattr-negais}
        temp-str 
        no-error
      }
      if error-status:error 
      then do:
        return error MsgLog + {&new-line} + return-value.
      end.
      { str/tdat-wrt.i
        p-doc-code
        {&trdcattr-nids}
        entry(1,tt-wb-header.uniq-key-rec,{&delim-cmd})
        no-error
      }
      if error-status:error 
      then do:
        return error MsgLog + {&new-line} + return-value.
      end.
      { str/tdat-wrt.i
        p-doc-code
        {&trdcattr-dids}
        entry(2,tt-wb-header.uniq-key-rec,{&delim-cmd})
        no-error
      }
      if error-status:error 
      then do:
        return error MsgLog + {&new-line} + return-value.
      end.

    end.
    otherwise do:
      run utl/ora-i516.p (
        input this-procedure ,
        input this-procedure ,
        input table temp_trn-doc ,
        input table temp_doc-line ,
        output num-rec-ok
        ) no-error .
      if error-status:error 
      then do:
        return error MsgLog + {&new-line} + return-value.
      end.
    end.
  end case.
  

end.


procedure pcall-log-file:
  
  define input parameter msg as character no-undo.
  
  if msg begins "n-d" then do:
    p-doc-code = entry (2, msg, "=").
  end.
  else do: 
  assign 
    MsgLog = msg + {&new-line}
    .
  end.
  

end.


procedure get-db-num:
  
  define output parameter pDbNum as integer no-undo.
  
  pDbNum = iDbNum.

end.

procedure get-userid:

  define output parameter pUserId as character no-undo.
  assign
    pUserId = userId_ + ",egais"
    .
  
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

procedure set-refAB:

  find first ub.trn-doc where ub.trn-doc.doc-code = p-doc-code no-lock.


    foreach_:
    for each ub.parts exclusive-lock
      where 
            ub.parts.out-code  = p-doc-code
        and ub.parts.obj-code  = ub.trn-doc.obj-code
        and ub.parts.obj-type  = ub.trn-doc.obj-type
        by ub.parts.artic by ub.parts.prod-type by ub.parts.prod-code by ub.parts.qnty
      :
      
      find first buf_goods where buf_goods.artic = ub.parts.artic and buf_goods.prod-type = ub.parts.prod-type and buf_goods.prod-code = ub.parts.prod-code no-error.
      
      if not available (buf_goods) 
        then return error error-status:get-message (1).
      
      find next tt-wb-gds-EG where tt-wb-gds-EG.gds-code = buf_goods.gds-code and tt-wb-gds-EG.qnty =  ub.parts.qnty use-index qntyIndex no-lock no-error. /* на случай если две партии с одинаковым количеством*/
      if not available (tt-wb-gds-EG) then do:
        find first tt-wb-gds-EG where  tt-wb-gds-EG.gds-code = buf_goods.gds-code and tt-wb-gds-EG.qnty =  ub.parts.qnty use-index qntyIndex no-lock no-error.
        if not available (tt-wb-gds-EG) 
          then find first tt-wb-gds-EG where  tt-wb-gds-EG.gds-code = buf_goods.gds-code use-index qntyIndex no-lock no-error.
        if not available (tt-wb-gds-EG)
          then next foreach_.
      end.

      run trg/partps.p ( input buf_goods.gds-code
                       , input ub.parts.in-code
                       , ?
                       , input ub.parts.part-code
                       , input ub.parts.mark-db-num
                       , input ub.parts.mark-code
                       , input ub.parts.alc-bottling-date
                       , input tt-wb-gds-EG.refA + ',' + tt-wb-gds-EG.refB + ',' + tt-wb-gds-EG.alc-code + ',' + tt-wb-gds-EG.alc-type-code
                       , input ub.parts.alc-quality-certif-path
                       , input ub.parts.alc-certif-path
                       , if tt-wb-gds-EG.importer-th <> "" then substring (tt-wb-gds-EG.importer-th, 1, 3) else ""
                       , if tt-wb-gds-EG.importer-th <> "" then substring (tt-wb-gds-EG.importer-th, 4) else ""
                       ) no-error .
      if error-status :error
      then do:
        undo, return error "Ошибка при вызове процедуры partps.p" + 
                            {&new-line} + 
                            error-status :get-message(1) + 
                            {&new-line} + return-value + {&new-line}.
      end.
    end.
  


end procedure.
