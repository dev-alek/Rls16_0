block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 16 сент. 2021 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 16 сент. 2021 г.

*/

/* ***************************  Definitions  ************************** */
define variable vss-revision    as character no-undo init "$Revision: 1eba0946c2d7, 3078, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: Пт авг 05 19:16:25 2022 +0300 $":U .
define variable vss-Workfile    as character no-undo init "$Workfile: utd-checkSpec.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/utd-checkSpec.p $":U .
define variable vss-description as character no-undo init "Проверка по спецификации линий УПД" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ str/lib-trn.i }
{ gbl/key-rec.i }
{ gbl/ObjSrv.i }
{ str/utd.i }

define input parameter pDb-num as integer no-undo .
define input parameter pDoc-id as integer no-undo .

define buffer buf_utd for ub.utd .
define buffer buf_utd-attr for ub.utd-attr.
define buffer buf_utd-lines for ub.utd-lines .
define buffer buf_utd-marking-lines for ub.utd-marking-lines .
define buffer buf_marking for ub.marking .
define buffer buf_marking-childs for ub.marking .
define buffer buf_contract for ub.contract .
define buffer buf_utd-err for ub.utd-err .

define variable v-vattype as character no-undo .
define variable v-vatpc   as decimal   no-undo .
define variable v-ok      as logical no-undo .
define variable v-ok-marks as logical no-undo .
define variable v-price   as decimal no-undo .
define variable objKeyRec as class ibs.th.gbl.keyrec no-undo.
define variable vRecKey   as character no-undo.
define variable vMarkUtd   as logical no-undo init no .

find first buf_utd no-lock where buf_utd.db-num = pDb-num
                             and buf_utd.doc-id = pDoc-id
                             no-error .
v-ok = true .     

find first buf_contract no-lock where buf_contract.host-code = buf_utd.host-code
                                  and buf_contract.contract-code = buf_utd.contract-code   
                                  no-error .
if not available buf_contract
then do :
  assign v-ok = false .
end .                                                      

                        
for first buf_contract no-lock where buf_contract.host-code = buf_utd.host-code
                                 and buf_contract.contract-code = buf_utd.contract-code
                                 :
  if buf_contract.contract-date-end < buf_utd.DocumentDate
  then do :
    assign v-ok = false .
    AddUtdErr(buf_utd.db-num,
              buf_utd.doc-id,
              buffer buf_contract:handle,
              "CheckMOTP",
              "ContrDate",
              (buf_contract.contract-name + {&delim-par} + string(buf_contract.contract-date-end)) ) .
  end .
  else do :
    ClearUtdErrTypeCode(buf_utd.db-num,buf_utd.doc-id,"CheckMOTP","ContrDate").
    
  end .
end .
CheckGds (buf_utd.db-num,buf_utd.doc-id,buf_utd.obj-type,buf_utd.obj-code,"CheckGds").
CheckQnty(buf_utd.db-num, buf_utd.doc-id, "CheckQnty").
if v-ok
then do :
  ClearUtdErr(buf_utd.db-num,buf_utd.doc-id,"CheckСontract").
  /* Пока оставим для старых документов */
  ClearUtdErrTypeCode(buf_utd.db-num,buf_utd.doc-id,"CheckMOTP","SpecifErr").
    
  objKeyRec = new ibs.th.gbl.keyrec().
  lines_ :
  for each buf_utd-lines no-lock where buf_utd-lines.db-num = pDb-num
                                   and buf_utd-lines.doc-id = pDoc-id
                                   :
    vMarkUtd = CheckMarkUtdLine(buf_utd-lines.db-num,
                                buf_utd-lines.doc-id,
                                buf_utd-lines.LineNum).
  
    objKeyRec:GenKeyRec ( input "utd-lines"
                         ,input buffer buf_utd-lines:handle
                         ,output vRecKey).
    if can-find (first buf_utd-err  where buf_utd-err.db-num = buf_utd.db-num
                                      and buf_utd-err.doc-id    = buf_utd.doc-id
                                      and buf_utd-err.CheckType = "LoadUtd"
                                      and buf_utd-err.reckey    =  vRecKey)
    then next lines_ .
    
    if vMarkUtd
    then do :
      v-ok-marks = true .
      marks_ :
      for each buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num   = buf_utd-lines.db-num
                                               and buf_utd-marking-lines.doc-id   = buf_utd-lines.doc-id
                                               and buf_utd-marking-lines.LineNum  = buf_utd-lines.LineNum,
      first buf_marking no-lock where buf_marking.mark = buf_utd-marking-lines.mark :
        if buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB
        then do :
          v-ok-marks = false .
          leave marks_ .
        end .
      end .
      if     v-ok-marks 
         and available buf_utd-marking-lines 
      then next lines_ .
    end .
    
    if buf_utd-lines.TaxRate <= 0
    then do :
      assign
        v-vattype = "без"
        v-vatpc = 0
      .
    end .
    else do :
      assign
        v-vattype = "в т. ч."
        v-vatpc = buf_utd-lines.TaxRate
      .
    end .  
    
    assign v-price = buf_utd-lines.total / buf_utd-lines.Quantity .
    {  str/ckcntspc.i
       buf_utd.host-code
       buf_utd.contract-code
       buf_utd-lines.gds-code
       v-price
       v-vattype
       v-vatpc
       no-error
    }
    if error-status :error then 
    do:
      assign v-ok = false .
      AddUtdErr(buf_utd.db-num,
                buf_utd.doc-id,
                buffer buf_utd-lines:handle,
                "CheckСontract",
                "SpecifErr",
                (string(buf_utd-lines.linenum) + {&delim-par} + error-status :get-message(1) + {&delim-par} + return-value)).
      if vMarkUtd
      then do :
        for each buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num   = buf_utd-lines.db-num
                                                 and buf_utd-marking-lines.doc-id   = buf_utd-lines.doc-id
                                                 and buf_utd-marking-lines.LineNum  = buf_utd-lines.LineNum,
        first buf_marking exclusive-lock where buf_marking.mark = buf_utd-marking-lines.mark :
          assign
            buf_marking.sts = objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB
          .
        end .
      end . /* vMarkUtd */
    end.
    else do :
      if vMarkUtd
      then do :
        for each buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num   = buf_utd-lines.db-num
                                                 and buf_utd-marking-lines.doc-id   = buf_utd-lines.doc-id
                                                 and buf_utd-marking-lines.LineNum  = buf_utd-lines.LineNum,
        first buf_marking exclusive-lock where buf_marking.mark = buf_utd-marking-lines.mark :
           objKeyRec:GenKeyRec ( input "utd-marking-lines"
                                ,input buffer buf_utd-marking-lines:handle
                                ,output vRecKey).
           block-utd-err:
           for each buf_utd-err  where buf_utd-err.db-num = buf_utd.db-num
                                   and buf_utd-err.doc-id    = buf_utd.doc-id
                                   and buf_utd-err.CheckType = "CheckMOTP"
                                   and buf_utd-err.CodeErr   = "MotpMarkErr"
                                   and buf_utd-err.reckey    =  vRecKey
           no-lock:
              leave block-utd-err.                                
           end .
           assign
              buf_marking.sts = objSrv:Env:Marking:Sts:Mark:DeliveryControl:KeyIntDB when not available buf_utd-err
           .
        end .
      end . /* vMarkUtd */
    end .
  end .
  
  delete object objKeyRec.
end .
if v-ok
then do:
   if      GetErrForUtdstr(buf_utd.db-num,buf_utd.doc-id,"CheckGds") ne ""
   then
      v-ok = no.
   else if GetErrForUtdstr(buf_utd.db-num,buf_utd.doc-id,"CheckQnty") ne ""
   then
      v-ok = no. 
end.
find current buf_utd exclusive-lock .
if not v-ok
then do :
  assign
    buf_utd.sts = objSrv:Env:Utd:Sts:TH:InconsistencyWithSupplyContract:KeyIntDB
  .
end .
else do :
   if CheckErrForUtd(pDb-num,pDoc-id)
   then do:
      buf_utd.sts = objSrv:Env:Utd:Sts:TH:LinesInError:KeyIntDB.
   end.
   else do:
      for each buf_utd-lines no-lock where buf_utd-lines.db-num = pDb-num
                                       and buf_utd-lines.doc-id = pDoc-id
      :
   /*      vMarkUtd = CheckMarkUtd(buf_utd.db-num,buf_utd.doc-id, buf_utd-lines.LineNum).*/
   /*      if vMarkUtd                                                                   */
   /*      then do :                                                                     */
         for each buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num eq buf_utd.db-num
                                             and buf_utd-marking-lines.doc-id      eq buf_utd.doc-id
                                             and buf_utd-marking-lines.LineNum     eq buf_utd-lines.LineNum,
         first buf_marking exclusive-lock where buf_marking.mark = buf_utd-marking-lines.mark :
     /*        for each buf_marking-childs exclusive-lock where buf_marking-childs.mark-parent = buf_marking.mark :*/
     /*          assign                                                                                            */
     /*            buf_marking-childs.sts = objSrv:Env:Marking:Sts:Mark:DeliveryControl:KeyIntDB                   */
     /*          .                                                                                                 */
     /*        end .                                                                                               */
            if buf_marking.sts = objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB then next .
            assign
              buf_marking.sts = objSrv:Env:Marking:Sts:Mark:DeliveryControl:KeyIntDB
            .
         end.
      end .
   /*   end . /* vMarkUtd */*/
      buf_utd.sts = objSrv:Env:Utd:Sts:TH:AwaitingDelivery:KeyIntDB.
   end.
end .
CheckMarking(buf_utd.db-num,buf_utd.doc-id,"CheckСontract").
CheckMarkUtd-28rel(buf_utd.db-num,buf_utd.doc-id).
release buf_utd no-error .