/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Пересылка на кассы после импорта откуда-нибудь

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/27/09
Author: Bakhtadze Natalya
Creation date: 02/27/09

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{str/imp2cd_def.i new }
{ ref/extclass.i }
{ cmp/library.i }

procedure send-to-cash:
  if not can-find(first ub.cash-desk where
                  ub.cash-desk.db-num = ibs.th.gbl.gbl-var:g#db-num AND
                  ub.cash-desk.cash-on = yes) then return.


  do
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-workfile )
  on endkey undo , return error substitute( "&1. endkey", vss-workfile )
  :
    if can-find(first gds-list no-lock)
    or can-find(first gdsolist no-lock)
    or can-find(first bc-list no-lock)
    or can-find(first pbc-list no-lock)
    or can-find(first cash-txn no-lock)
    or can-find(first cash-txr no-lock)
    or can-find(first dc-list no-lock)
    or can-find(first dc-dis-card-mask no-lock)
    or can-find(first stpl-list no-lock)
    or can-find(first pdf-list no-lock)
    or can-find(first cash-pay-list no-lock)
    or can-find(first ext-classif-list no-lock)
    or can-find(first c-ext-classif-list no-lock)
    or can-find(first PromoAction-list no-lock)
    or can-find(first thbjattr-list no-lock)
    or sendEMRC
    or settingUpd
    or sendMarkType
    then do:
      run str/diallog.w (
                         &if "{&imp2cd_parparentproc}" <> '' &then
                         input {&imp2cd_parparentproc}
                         &else
                         input ?
                         &endif
                        ,input ?
                        ,input 'str/sendnall.p':U
                        ,input string(ibs.th.gbl.gbl-var:g#db-num)
                        ,input yes /*p-auto-go*/
                        ,input '':U
                        ,input 'Отправка информации на кассу') no-error .
    end.
  end.
end procedure.

procedure fill-setting :
   define input parameter i-obj      as character no-undo .
   define input parameter i-obj-type as character no-undo .
   define input parameter i-obj-code as integer   no-undo .
   define input parameter i-parent   as character no-undo .
   define input parameter i-code     as character no-undo .
   define buffer buf_thbj-attr for ub.thbj-attr.
   define buffer buf_sys-ctrl for ub.sys-ctrl.
   define buffer buf_clients for ub.clients.
   
   define variable v-db-num    as integer no-undo. 
   define variable v-shop-code as integer no-undo.
   define variable v-reg-code  as integer no-undo.
            
   settingUpd = yes.
   sendGisMt = no.
   if i-obj = "thbj-attr" 
   then do:         
      v-db-num  = ibs.th.gbl.gbl-var:g#db-num.
      if v-db-num <> 0 then do:
          find first buf_clients no-lock
               where buf_clients.obj-type = {&shop}
                 and buf_clients.db-num   = v-db-num
             no-error.
          if available buf_clients then v-shop-code = buf_clients.obj-code.   
      end.                                       
   end.
   /* если это настройки, то проверяем, относятся ли они к нашей секции (магазину, БД, глобальные) 
   ** и еще в ГБД на кассу не посылаем */    
   if i-obj = "thbj-attr" and 
      (i-parent = {&attr-gisMT} or i-parent = {&attr-marking})  
   then do:       
       /* если изменился глобальный атрибут, то его отсылаем только если нет локального */
      if i-parent = {&attr-gisMT} and i-obj-type = "" and i-obj-code = 0 then do:          
          if not can-find(first buf_thbj-attr no-lock where 
                                buf_thbj-attr.obj-type = {&db}
                            and buf_thbj-attr.obj-code = v-db-num
                            and buf_thbj-attr.upper-prop-code = i-parent
                            and buf_thbj-attr.prop-code = i-code)  
          then sendGisMt = yes.
      end.  
      /* изменился регион */
      if i-parent = {&attr-gisMT} and i-obj-type = {&region} then do:
          /* у БД мог измениться код региона, поэтому посылать ли эту настройку определяем потом */
          sendGisMt = yes.          
      end.   
      /* изменился локальный атрибут */
      else if (i-parent = {&attr-gisMT} and i-obj-type = {&db} and i-obj-code = v-db-num)       
         then sendGisMt = yes.  
      else if i-parent = {&attr-marking} and i-obj-type = {&shop} and i-obj-code = v-shop-code 
         then sendGisMt = yes.      
      else if i-parent = {&attr-marking} and i-obj-type = "" then do:  
          if not can-find(first buf_thbj-attr no-lock where 
                                buf_thbj-attr.obj-type = {&shop}
                            and buf_thbj-attr.obj-code = v-shop-code
                            and buf_thbj-attr.upper-prop-code = i-parent
                            and buf_thbj-attr.prop-code = i-code)  
          then sendGisMt = yes.
      end.                  
      if sendGisMt = yes then do:                
          if not can-find(first thbjattr-list where 
                                thbjattr-list.obj-type = i-obj-type
                            and thbjattr-list.obj-code = i-obj-code
                            and thbjattr-list.upper-prop-code = i-parent
                            and thbjattr-list.prop-code = i-code)
          then do:
              create thbjattr-list.
              assign
                 thbjattr-list.obj-type = i-obj-type
                 thbjattr-list.obj-code = i-obj-code
                 thbjattr-list.upper-prop-code = i-parent
                 thbjattr-list.prop-code = i-code
                 .
          end.    
      end.                  
   end.   
                                
end procedure.

procedure fill-code :
   define input parameter i-parent as character no-undo .
   define input parameter i-code   as character no-undo .
   if i-parent begins "EMC"
   then
      sendEMRC = yes.
   if i-parent begins "MarkType"
   then
      sendMarkType = yes.
end procedure.

procedure fill-gds-list :
define parameter buffer buf_goods for ub.goods.

do
on error undo, return error
:
  for first gds-list where gds-list.gds-code = buf_goods.gds-code:
    delete gds-list.
  end.

  create gds-list.
  buffer-copy buf_goods to gds-list no-error.
  if error-status:error then message error-status:get-message(1) view-as alert-box.
  release gds-list.
end.

end procedure. /* fill-gds-list */


procedure fill-dc-list :
define parameter buffer buf_dis-card for ub.dis-card .

do
on error undo, return error
:
  find first dc-list where
            dc-list.d-card = buf_dis-card.d-card no-lock no-error.
  if not available dc-list then do:
    create dc-list.
    buffer-copy buf_dis-card to dc-list.
    release dc-list.
  end.
end.
end procedure. /* fill-dc-list */

procedure fill-dc-list-mask :
define parameter buffer buf_dis-card-mask for ub.dis-card-mask .

do
on error undo, return error
:
   find first dc-list where
            dc-list.d-card = buf_dis-card-mask.mask no-lock no-error.
   if not available dc-list
   then do:
      find first ub.dis-card no-lock where
                 ub.dis-card.d-card = buf_dis-card-mask.mask no-error .
      if  available dis-card
      then
         run fill-dc-list(buffer dis-card) .         
   end.
            
            
  find first dc-dis-card-mask where
             dc-dis-card-mask.mask-num = buf_dis-card-mask.mask-num no-lock no-error.
  buffer-copy buf_dis-card-mask to dc-dis-card-mask.
  release dc-dis-card-mask.
  
end.
end procedure. /* fill-dc-list-mask */

procedure fill-dc-list-mask-attr :
define parameter buffer buf_dis-card-mask-attr for ub.dis-card-mask-attr .
define buffer dis-card-mask for ub.dis-card-mask .

do
on error undo, return error
:
  find first dc-dis-card-mask where
             dc-dis-card-mask.mask-num = buf_dis-card-mask-attr.mask-num no-lock no-error.
  if not available dc-dis-card-mask
  then do:
     find first dis-card-mask where dis-card-mask.mask-num eq buf_dis-card-mask-attr.mask-num no-lock no-error.
     if available dis-card-mask
     then
        run  fill-dc-list-mask (buffer dis-card-mask).
  end.
  find first dc-dis-card-mask-attr where
            dc-dis-card-mask-attr.mask-num  = buf_dis-card-mask-attr.mask-num
       and  dc-dis-card-mask-attr.attr-code = buf_dis-card-mask-attr.attr-code
            no-lock no-error.
  buffer-copy buf_dis-card-mask-attr to dc-dis-card-mask-attr.
  release dc-dis-card-mask-attr.
  
end.
end procedure. /* fill-dc-list-mask */

procedure fill-dc-list-attr :
define input parameter p-d-card as character no-undo .
define input parameter p-emitent-host-code as integer no-undo .

do
on error undo, return error
:
  find first dc-list where
            dc-list.d-card = p-d-card no-error .
  if not avail dc-list then do:
    create dc-list.
    assign
    dc-list.d-card = p-d-card
    dc-list.emitent-host-code = p-emitent-host-code
    .
    release dc-list.
  end.
end.
end procedure. /* fill-dc-list */

procedure fill-cash-pay :
define input parameter p-cdpay-code as integer no-undo .
define input parameter p-curr-code  as integer no-undo .

do
on error undo, return error
:
  if not can-find( cash-pay-list where cash-pay-list.cdpay-code = p-cdpay-code
                                   and cash-pay-list.curr-code  = p-curr-code )
  then do:
    create cash-pay-list.
    assign
       cash-pay-list.cdpay-code = p-cdpay-code
       cash-pay-list.curr-code  = p-curr-code
    .
    release cash-pay-list.
  end.
end.
end procedure. /* fill-dc-list */

procedure fill-PromoAction :
define input parameter p-id as int64 no-undo .
define input parameter p-db-num  as integer no-undo .

do
on error undo, return error
:
  if not can-find( PromoAction-list where PromoAction-list.id = p-id
                                      and PromoAction-list.db-num  = p-db-num )
  then do:
    create PromoAction-list.
    assign
       PromoAction-list.id = p-id
       PromoAction-list.db-num  = p-db-num
    .
    release PromoAction-list.
  end.
end.
end procedure. /* fill-dc-list */

procedure fill-ext-classif:
define input parameter p-db-num as integer no-undo .
define input parameter p-Key#One  as integer no-undo .
define input parameter p-Key#Two  as integer no-undo .
define input parameter p-CharKey_One  as character no-undo .

do
on error undo, return error
:
  if not can-find( ext-classif-list where ext-classif-list.db-num = p-db-num
                                   and ext-classif-list.Key#One  = p-Key#One
                                   and ext-classif-list.Key#Two = p-Key#Two
                                   and ext-classif-list.CharKey_One = p-CharKey_One )
  then do:
    create ext-classif-list.
    assign
    ext-classif-list.db-num = p-db-num
    ext-classif-list.Key#One  = p-Key#One
    ext-classif-list.Key#Two = p-Key#Two
    ext-classif-list.CharKey_One = p-CharKey_One
    .
    release ext-classif-list.
  end.
end.
end procedure. /* fill-ext-classif */

procedure fill-c-ext-classif:
define input parameter p-db-num as integer no-undo .
define input parameter p-Key#One  as integer no-undo .
define input parameter p-Key#Two  as integer no-undo .
define input parameter p-CharKey_One  as character no-undo .
define input parameter p-chip-num as integer no-undo .

do
on error undo, return error
:
  if not can-find( c-ext-classif-list where c-ext-classif-list.db-num = p-db-num
                                   and c-ext-classif-list.Key#One  = p-Key#One
                                   and c-ext-classif-list.Key#Two = p-Key#Two
                                   and c-ext-classif-list.CharKey_One = p-CharKey_One
                                   and c-ext-classif-list.chip-num = p-chip-num )
  then do:
    create c-ext-classif-list.
    assign
        c-ext-classif-list.db-num = p-db-num
        c-ext-classif-list.Key#One  = p-Key#One
        c-ext-classif-list.Key#Two = p-Key#Two
        c-ext-classif-list.CharKey_One = p-CharKey_One
        c-ext-classif-list.chip-num = p-chip-num
    .
    release c-ext-classif-list.
  end.
end.
end procedure. /* fill-c-ext-classif */

procedure fill-g-list :
define input parameter p-gds-code as integer no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define buffer buf_goods for ub.goods.

do
on error undo, return error
:
  find first gds-list where
            gds-list.gds-code = p-gds-code no-error .
  if not avail gds-list then do:
    if p-obj-type = {&shop} then do:
      find first gdsolist where
                gdsolist.gds-code = p-gds-code
          AND  gdsolist.obj-type = p-obj-type
          AND  gdsolist.obj-code = p-obj-code   no-error .
    end.
    else do:
      find first buf_goods no-lock where
                  buf_goods.gds-code = p-gds-code no-error .
      create gds-list.
      buffer-copy buf_goods to gds-list.
    end.
  end.
  if p-obj-type = {&shop} and not avail gdsolist then do:
    find first gdsolist where
              gdsolist.gds-code = p-gds-code
        AND  gdsolist.obj-type = p-obj-type
        AND  gdsolist.obj-code = p-obj-code   no-error .
    if not available gdsolist then do:
      find first buf_goods no-lock where
                  buf_goods.gds-code = p-gds-code no-error .
      if avail buf_goods then do:
        create gdsolist.
        buffer-copy buf_goods to gdsolist
        assign
        gdsolist.obj-type = p-obj-type
        gdsolist.obj-code = p-obj-code
        .
      end.
    end.
  end.
  if avail gdsolist then do:
    assign
    gdsolist.to-del = no
    .
    release gdsolist.
  end.
  if avail gds-list then do:
    assign
    gds-list.to-del = no
    .
    release gds-list.
  end.
end.
end procedure. /* fill-g-list */

procedure fill-cash-txn :
define parameter buffer buf_tax for ub.tax.

do
on error undo, return error
:
  if not can-find( cash-txn where
                  cash-txn.tax-code = buf_tax.tax-code
              and cash-txn.tax-name = buf_tax.tax-name
                 ) then do:
    create cash-txn.
    assign
    cash-txn.tax-code = buf_tax.tax-code
    cash-txn.tax-name = buf_tax.tax-name
    .
    release cash-txn.
  end.
end.

end procedure. /* fill-cash-txn */

procedure fill-cash-txr :
define input parameter p-tax-code as integer no-undo .
define input parameter p-rate-code as integer no-undo .
define input parameter p-status_ as character no-undo .
define input parameter p-host-code as integer no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-tax-type as character no-undo .
define input parameter p-value as decimal no-undo .
define input parameter p-crf as integer no-undo .
define input parameter p-rec as recid no-undo .
define buffer buf_tax for ub.tax.
do
on error undo, return error
:
  find first cash-txr where
          cash-txr.tax-code = p-tax-code
      AND cash-txr.host-code = p-host-code
      AND cash-txr.rate-code = p-rate-code
      AND cash-txr.obj-type = p-obj-type
      AND cash-txr.obj-code = p-obj-code
      /* AND (p-status_ = ? or cash-txr.status_ = p-status_) */
      AND cash-txr.rc = p-rec no-error .
  if not avail cash-txr then do:
    find first  cash-txn where
                    cash-txn.tax-code = p-tax-code no-error .
    if not available cash-txn then do:
      find first buf_tax no-lock where buf_tax.tax-code = p-tax-code.
      create cash-txn.
      assign
      cash-txn.tax-code = buf_tax.tax-code
      cash-txn.tax-name = buf_tax.tax-name
      .
      release cash-txn.
      define variable II as integer no-undo.
      find last  cash-txr where cash-txr.crf > 0 no-error.
      if available cash-txr
      then 
         II = cash-txr.crf + 1.
      else 
         II = 1. 
       /* отправим все ствки по налогу */
         _tax-rate:  
      FOR EACH ub.tax-rate NO-LOCK WHERE
                          ub.tax-rate.tax-code = buf_tax.tax-code
                      and ub.tax-rate.status_  <>   {&deleted-status-int-full}:
                        create cash-txr.
                        assign
                        cash-txr.tax-code = tax-rate.tax-code
                        cash-txr.rate-code = tax-rate.rate-code
                        cash-txr.tax-type = buf_tax.tax-type
                        cash-txr.host-code = p-host-code
                        cash-txr.obj-type = p-obj-type
                        cash-txr.obj-code = p-obj-code
                        cash-txr.status_ = tax-rate.status_
                        cash-txr.rc = RECID(tax-rate)
                        cash-txr.crf = ii
                        ii = ii + 1
                        .
                        
                        { gbl/pftaxval.i recid(ub.tax-rate) 0 0 ? p-host-code p-obj-type p-obj-code cash-txr.rate-value no-error }
                        if error-status:error then next _tax-rate.
       END.
       
    end.
    else do:
       for each cash-txr where cash-txr.tax-code = tax-rate.tax-code:
          delete cash-txr.
       end.
       _tax-rate2:
        FOR EACH ub.tax-rate NO-LOCK WHERE
                          ub.tax-rate.tax-code = buf_tax.tax-code
                      and ub.tax-rate.status_  <>   {&deleted-status-int-full}:
                        create cash-txr.
                        assign
                        cash-txr.tax-code = tax-rate.tax-code
                        cash-txr.rate-code = tax-rate.rate-code
                        cash-txr.tax-type = buf_tax.tax-type
                        cash-txr.host-code = p-host-code
                        cash-txr.obj-type = p-obj-type
                        cash-txr.obj-code = p-obj-code
                        cash-txr.status_ = tax-rate.status_
                        cash-txr.rc = RECID(tax-rate)
                        cash-txr.crf = ii
                        ii = ii + 1
                        .
                        
                        { gbl/pftaxval.i recid(ub.tax-rate) 0 0 ? p-host-code p-obj-type p-obj-code cash-txr.rate-value no-error }
                        if error-status:error then next _tax-rate2.
       END.
    end.   
    /* обработаем пришедшую стаку которой нет еще в базе */   
    find first cash-txr where
          cash-txr.tax-code = p-tax-code
      AND cash-txr.rate-code = p-rate-code
     /* AND cash-txr.host-code = p-host-code
      AND cash-txr.obj-type = p-obj-type
      AND cash-txr.obj-code = p-obj-code
      AND cash-txr.rc = p-rec*/ no-error .
    if not avail cash-txr and  p-status_ <> {&deleted-status-int-full} 
    then do:        
       create cash-txr.
       assign
       cash-txr.tax-code  = p-tax-code
       cash-txr.rate-code = p-rate-code
       cash-txr.host-code = p-host-code
       cash-txr.obj-type  = p-obj-type
       cash-txr.obj-code  = p-obj-code
       cash-txr.tax-type  = p-tax-type
       cash-txr.crf       = p-crf
       cash-txr.rc        = p-rec
       cash-txr.status_   = (if p-status_ = ? then {&current-status} else p-status_)
       .
    
    end.
    if  avail cash-txr 
    then do: 
       if p-status_ eq {&deleted-status-int-full}
       then
          delete cash-txr.
       else assign
       cash-txr.tax-code  = p-tax-code
       cash-txr.rate-code = p-rate-code
       cash-txr.host-code = p-host-code
       cash-txr.obj-type  = p-obj-type
       cash-txr.obj-code  = p-obj-code
       cash-txr.tax-type  = p-tax-type
       cash-txr.crf       = p-crf
       cash-txr.rc        = p-rec
       cash-txr.status_   = (if p-status_ = ? then {&current-status} else p-status_)
       .
       
    end.   
    release cash-txr.
  end.
end.

end procedure. /* fill-cash-txr */

procedure fill-stpl-list :
define parameter buffer buf_stop-list for ub.stop-list.

do
on error undo, return error
:
  find first stpl-list where
            stpl-list.classif-type =  buf_stop-list.classif-type
        and stpl-list.stop-list-code = buf_stop-list.stop-list-code no-error .
  if not avail stpl-list then do:
    create stpl-list.
    buffer-copy buf_stop-list
    to stpl-list.
    release stpl-list.
  end.
end.

end procedure. /* fill-stop-list */

procedure fill-pbc-list :
define input parameter p-rc as recid no-undo .
define input parameter p-gds-code as integer no-undo .
define input parameter p-b-code as integer no-undo .
define input parameter p-b-str as character no-undo .
define input parameter p-bc-on as logical no-undo .
define input parameter p-del as logical no-undo .

do
on error undo, return error
:
  if p-bc-on = false
  or p-del = yes
  or not can-find(gds-list where gds-list.gds-code     = p-gds-code
                            no-lock ) then do:
    find first pbc-list where pbc-list.rc = p-rc no-error.
    if not available pbc-list then do:
      create pbc-list.
    end.
    assign
    pbc-list.b-code = p-b-code
    pbc-list.b-str = p-b-str
    pbc-list.rc = p-rc
    pbc-list.bc-on = p-bc-on
    pbc-list.del = p-del
    .
    release pbc-list .
  end.
end.
end procedure. /* fill-pbc-list */

procedure fill-bar-code :
define input parameter p-b-code as integer no-undo .
define input parameter p-gds-code as integer no-undo .
define input parameter p-del as logical no-undo .
define input parameter p-node-code as integer no-undo .
define input parameter p-in-code as character no-undo .
define input parameter p-part-code as character no-undo .
define input parameter p-cli-base-rate as decimal no-undo .
define input parameter p-unit-cli as character no-undo .

do
on error undo, return error
:

  if p-del = yes
  or not can-find(gds-list where gds-list.gds-code     = p-gds-code
                            no-lock ) then do:
    find first bc-list where
            bc-list.b-code = p-b-code and bc-list.del = p-del no-error.
    if not avail bc-list then do:
      create bc-list.
      assign
      bc-list.gds-code = p-gds-code
      bc-list.b-code = p-b-code
      bc-list.node-code = p-node-code
      bc-list.in-code = p-in-code
      bc-list.part-code = p-part-code
      bc-list.cli-base-rate = p-cli-base-rate
      bc-list.unit-cli = p-unit-cli
      bc-list.del = p-del
      .
    end.
  end.
end.

end procedure. /* fill-bar-code */

procedure fill-pdf :
define input parameter p-plt-id as integer no-undo .
define input parameter p-plt-db-num as integer no-undo .
define input parameter p-pdf-id as integer no-undo .
define input parameter p-pdf-db-num as integer no-undo .
define input parameter p-del as logical no-undo .
define buffer buf_pdf-list for pdf-list.

do
on error undo, return error
:
  find first pdf-list where
           pdf-list.plt-id = p-plt-id
       and pdf-list.plt-db-num = p-plt-db-num
       and pdf-list.pdf-id = p-pdf-id
       and pdf-list.pdf-db = p-pdf-db-num no-error.
  if not available pdf-list then do:
    find last buf_pdf-list use-index oi no-error.
    create pdf-list.
    assign
    pdf-list.plt-id = p-plt-id
    pdf-list.plt-db-num = p-plt-db-num
    pdf-list.pdf-id = p-pdf-id
    pdf-list.pdf-db = p-pdf-db-num
    pdf-list.to-del = p-del
    pdf-list.order-num = (if available buf_pdf-list then buf_pdf-list.order-num + 1 else 1)
    .
    release pdf-list.
  end.
end.

end procedure. /* fill-pdf */

/* $Workfile$ e n d */