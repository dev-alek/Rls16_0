using Progress.Lang.*.
using Ibs.Th.Gbl.ReportXml.
using Ibs.Th.Gbl.rep-out.
block-level on error undo, throw.
/*------------------------------------------------------------------------
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Срабатывание промо-акции

Автор: Шкляр Елена
Дата создания: 09/07/05
Author: Shklyar Elena
Creation date: 09/07/05
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Срабатывание промоакции НП" .

define temp-table tt-promo like ub.PromoAction .
       
define input parameter parparentproc as handle no-undo.
define input parameter table for tt-promo.
define input parameter p-cond        as integer.

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ gbl/cur-time.i }

{ gbl/prn-lib.i     }
{ rep/html-conv.i }

{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }   
{ str/lib-trn.i  }
{ str/cspromo-chk.i } /* функции для работы с промоакциями по НП */

define stream Out-Stream.
define stream OutStr-html.
     
define temp-table tt-info
   field obj-code like ub.chk-doc.obj-code
   field obj-type like ub.chk-doc.obj-type
   field obj-name as character
   field pl-code as integer
   field gds-name as character
   field price-base as decimal
   field doc-code like ub.chk-doc.doc-code
   field shift-num like ub.chk-doc.shift-num
   field shift-date like ub.chk-doc.shift-date
   field chk-date as date
   field chk-num as int
   field z-number as int
   field cashier as char
   field src-qnty as dec
   field src-promo-qnty as dec
   field src-price as dec
   field src-sum as dec /* Сумма продажи */
   field discnt as dec /* скидка за ед. товара */
   field src-sum-no-disc as dec /* Сумма без скидки */
   field src-sum-disc as dec /* Сумма скидки */
   field ret-doc-code as char
   field ret-shift-num as int
   field ret-shift-date as date
   field ret-chk-date as date
   field ret-chk-num as int
   field ret-cashier as char
   field ret-src-qnty as dec
   field ret-promo-qnty as dec
   field ret-src-price as dec
   field ret-src-sum as dec    
   field ret-discnt as dec /* скидка за ед. товара */
   field ret-sum-no-disc as dec 
   field dop-qnty as dec   
   field dop-sum as dec
   field ret-dop-qnty as dec   
   field ret-dop-src-sum as dec
   field promo-id as char
   field nameAction as char
   field itog-qnty as dec
   field itog-price as dec
   field itog-sum as dec
   field itog-sum-no-disc as dec /* Сумма без скидки */
   field itog-sum-disc as dec /* Сумма скидки */
   field itog-proc as dec
   field sts as char 
   field b-code as integer
   field change-BL as char
   field ret-nodiscnt as log /* в возвратном чеке нет скидки */
   field pay-desk as int /* номер кассы */
   field ext-code as char /* номер промоакции в 1С */
   index sort1 chk-date chk-num. 
     
define variable v-report-name       as character no-undo .
define variable v-file-name-rep-htm as character no-undo .
define variable v-filt-1            as character no-undo . /* фильтр по mDate */
define variable v-filt-2            as character no-undo . /* фильтр по mStatus */
define variable v-date-start        as date      no-undo . /* для имени листа в Excel */
define variable v-page-name         as character no-undo . /* имя листа в Excel */
define variable v-obj-code          as integer   no-undo .  
/* по каждой акции:*/
define variable v-wdaylist          as character no-undo . /* перечень дней недели (пн=1) */
define variable v-timelist          as character extent 7 no-undo . /* перечень времени на каждый день недели */
define variable v-sdaynum           as character no-undo . /* номер дня недели (пн=1) */
define variable v-idaynum           as integer   no-undo . /* номер дня недели (пн=1) */
define variable v-timebeg           as character no-undo .
define variable v-timeend           as character no-undo .
define variable vi                  as integer   no-undo .
define variable vj                  as integer   no-undo .  
define variable ii                  as integer   no-undo .
define variable kk                  as integer   no-undo .
define variable v-period            as character no-undo .
define variable v-list-obj          as character no-undo .
define variable v-obj-name          as character no-undo .
define variable v-first             as logical   no-undo .

define buffer buf_chk-discnt      for ub.chk-discnt .
define buffer buf_chk-discnt-attr for ub.chk-discnt-attr .
define buffer buf_chk-doc         for ub.chk-doc .
define buffer buf_ret-chk-doc     for ub.chk-doc .
define buffer buf_chk-gds         for ub.chk-gds .
define buffer buf_promo-chk-gds   for ub.chk-gds .
define buffer bf_chk-discnt       for ub.chk-discnt .
define buffer bf_chk-discnt-attr  for ub.chk-discnt-attr .
define buffer buf_bar-code for ub.bar-code.
define buffer buf_goods for ub.goods.
define buffer buf_person for ub.person.
define buffer buf_clients for ub.clients.
define buffer buf_PromoAction for ub.PromoAction.

define VARIABLE p-report-id as character no-undo .
define variable vPromoName  as character no-undo .
define variable vStatusCond as character no-undo .
define variable vAllPromo   as logical   no-undo.
define variable vPromoPrice as decimal   no-undo.
define variable vLstSts     as character no-undo.

vPromoPrice = 0.01. /* акционная цена товара */

/*Данные для шапки*/
/*Период*/
if x-TOG-Shift then 
do:
  v-period = string (x-Date-Start,"99.99.9999") + " - " + string (x-Date-End,"99.99.9999") + " Смены: " + string (x-Shift-Start) + " - " + string (x-Shift-End).
end.
else 
do:
  v-period = string (x-Date-Start,"99.99.9999") + " - " + string (x-Date-End,"99.99.9999") .
end. 
    
vPromoName = "".
for each tt-promo:
    vPromoName = vPromoName + "," + tt-promo.nameAction.
end.    
vPromoName = trim(vPromoName,",").
if vPromoName = "" then 
assign
   vPromoName = "Все"
   vAllPromo = yes.
else vAllPromo = no.   
 
case p-cond:
    when 1 then 
       assign 
          vStatusCond = "Все"
          vLstSts = "*"
          .
    when 2 then
       assign 
          vStatusCond = "Не прекращено"
          vLstSts = "0"
          .
    when 3 then
       assign 
          vStatusCond = "Прекращено"
          vLstSts = "1"
          .
    otherwise .    
end case.
     
/*Название объекта*/
run clients-write(INPUT v-cntxt-host-code-obj, INPUT {&cmp}, OUTPUT v-obj-name) no-error .    

for each obj-list no-lock:
  if v-list-obj = "" then v-list-obj = string(obj-list.obj-code).
  else v-list-obj = v-list-obj + ", " + string(obj-list.obj-code).

  if x-TOG-Shift then 
  do:
    for each buf_chk-doc no-lock 
      where buf_chk-doc.obj-code = obj-list.obj-code 
      and buf_chk-doc.obj-type = obj-list.obj-type
      and buf_chk-doc.chk-type = int({&rcpt-sale})
      and buf_chk-doc.shift-date >= x-Date-Start 
      and buf_chk-doc.shift-date <= x-Date-End
      and buf_chk-doc.out-code <> ?:
          
      if (buf_chk-doc.shift-date = X-date-Start)
        and (buf_chk-doc.shift-num < x-Shift-Start) then next. 
      if (buf_chk-doc.shift-date = X-date-End)
        and (buf_chk-doc.shift-num > x-Shift-End) then next.
      
      run report .
    end.
  end.
  else 
  do:
    for each buf_chk-doc no-lock 
      where buf_chk-doc.obj-code = obj-list.obj-code 
      and buf_chk-doc.obj-type = obj-list.obj-type
      and buf_chk-doc.chk-type  = int({&rcpt-sale})
      and buf_chk-doc.chk-date >= x-Date-Start 
      and buf_chk-doc.chk-date <= x-Date-End
      and buf_chk-doc.out-code <> ?:

      run report .
      
    end.  
  end.  

end.

run report-itog.
   
/*печать*/
run gbl/getrpnum.p (output p-report-id).
    
v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html".   
                      
output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8'.
put stream OutStr-html unformatted
  { rep/htmlhead.i }
  .          
                
run report-header.
run report-body.
   
put stream OutStr-html unformatted
   '</tbody>' skip
   '</table>' skip
   '</body>' skip
   '</html>' skip
   .
                            
output stream OutStr-html close.     

run prn-lib-reportviewer in this-procedure (
   input this-procedure
   ,input v-file-name-rep-htm
   ,input "" 
   ) no-error.
if error-status:error then
do:
   message return-value view-as alert-box.
   return .
end.

/*Общие данные*/

procedure report:
  define variable is-petrolium         as logical   no-undo.
  define variable is-pieces            as logical   no-undo.
  define variable v-sum-r              as decimal   no-undo.
  define variable v-sum-no-disc        as decimal   no-undo.
  define variable v-sum-disc           as decimal   no-undo.  

  define buffer buf_promoAttr for ub.promoAttr.
  define buffer buf_bar-code for ub.bar-code.
  define buffer buf_goods for ub.goods.
  
  /* чеки приема по топливу по промоакции */
  chkda:
  for each  buf_chk-gds no-lock where 
            buf_chk-gds.doc-code = buf_chk-doc.doc-code and 
            buf_chk-gds.pl-code <> ?:                    
                
                /*
    /* ищем скидку на данную строку товара */                            
    find first bf_chk-discnt-attr no-lock where 
             bf_chk-discnt-attr.attr-code = "promo-id" and 
             bf_chk-discnt-attr.doc-code = buf_chk-doc.doc-code and 
             bf_chk-discnt-attr.object-line-num = buf_chk-gds.line-num
       no-error.    
    /* ищем скидку промо на подитог */   
    if not avail bf_chk-discnt-attr
    then do: 
        find first bf_chk-discnt-attr no-lock where 
                 bf_chk-discnt-attr.attr-code = "promo-id" and 
                 bf_chk-discnt-attr.doc-code = buf_chk-doc.doc-code and 
                 bf_chk-discnt-attr.object-line-num <> 0
           no-error.                      
        if avail bf_chk-discnt-attr and
           bf_chk-discnt-attr.object-line-num > buf_chk-gds.line-num
        then do:   
            find first buf_chk-discnt no-lock where 
                   buf_chk-discnt.doc-code = bf_chk-discnt-attr.doc-code and
                   buf_chk-discnt.discnt-id = bf_chk-discnt-attr.discnt-id and
                   buf_chk-discnt.record-type = 1 and
                   buf_chk-discnt.line-num = bf_chk-discnt-attr.line-num and
                   buf_chk-discnt.object-line-num = buf_chk-gds.line-num
                   no-error.
            if available buf_chk-discnt and 
               buf_chk-discnt.line-type = integer({&discnt-sub-total}) 
            then . 
            else next chkda.                     
        end.   
        else next chkda.
    end.
                  */
    find first buf_chk-discnt no-lock where 
               buf_chk-discnt.doc-code = buf_chk-doc.doc-code and
               buf_chk-discnt.promo-id > ""   and                
               buf_chk-discnt.record-type = 1 and               
               buf_chk-discnt.object-line-num = buf_chk-gds.line-num
       no-error.   
    if not avail buf_chk-discnt then next chkda.
                    
    if not vAllPromo then do:     
       if not can-find(first tt-promo where 
                             tt-promo.id = int(buf_chk-discnt.promo-id))
       then next chkda.
    end.
              
    find first buf_bar-code no-lock where buf_bar-code.b-code = buf_chk-gds.b-code no-error .
    find first buf_goods no-lock where buf_goods.gds-code = buf_bar-code.gds-code no-error .
    { str/is-petrl.i
       buf_goods.artic
       buf_goods.prod-type
       buf_goods.prod-code
       is-petrolium
       is-pieces
       no-error
    }        
    if not is-petrolium then next .
    
    find first tt-info no-lock where
               tt-info.obj-code = buf_chk-doc.obj-code and
               tt-info.obj-type = buf_chk-doc.obj-type and 
               tt-info.doc-code = buf_chk-gds.doc-code and 
               tt-info.b-code = buf_chk-gds.b-code
        no-error.
    if not avail tt-info 
    then do: 
      create tt-info.    
      assign
         tt-info.obj-code = buf_chk-doc.obj-code
         tt-info.obj-type = buf_chk-doc.obj-type
         tt-info.doc-code = buf_chk-gds.doc-code
         tt-info.chk-num = buf_chk-doc.chk-num
         tt-info.chk-date = buf_chk-doc.chk-date
         tt-info.z-number = buf_chk-doc.z-number
         tt-info.shift-num = buf_chk-doc.shift-num
         tt-info.shift-date = buf_chk-doc.shift-date
         tt-info.pl-code  = buf_chk-gds.pl-code                  
         tt-info.b-code = buf_chk-gds.b-code
         tt-info.pay-desk = buf_chk-doc.pay-desk
         .                                                                           
      /* кассир */
      find first buf_person where 
                 buf_person.psn-code = buf_chk-doc.cashier-psn-code 
         no-lock no-error.
      if avail buf_person THEN  
         tt-info.cashier = buf_person.name1 + ' ' + buf_person.name2 + ' '.
      find first buf_clients where 
                 buf_clients.obj-code = buf_chk-doc.cashier-psn-code  and 
                 buf_clients.obj-type = 'чел' 
         no-lock no-error.
      if avail buf_clients then 
         tt-info.cashier = tt-info.cashier + buf_clients.obj-name.
      for first buf_clients no-lock where 
                buf_clients.obj-code = tt-info.obj-code and
                buf_clients.obj-type = tt-info.obj-type:
          tt-info.obj-name = buf_clients.obj-name .
      end.      
      for first buf_bar-code no-lock where
                 buf_bar-code.b-code = buf_chk-gds.b-code:
         find first buf_goods no-lock where
                    buf_goods.gds-code = buf_bar-code.gds-code 
            no-error.
         if available buf_goods then 
            tt-info.gds-name = buf_goods.gds-name.
      end.              
    end.                        
    
    if tt-info.promo-id  = "" then do:
      tt-info.promo-id = buf_chk-discnt.promo-id.
      
      /* название промоакции */   
      for first buf_PromoAction no-lock where 
                buf_PromoAction.id = int64(tt-info.promo-id):
          assign          
             tt-info.nameAction = buf_PromoAction.nameAction 
             tt-info.ext-code = buf_PromoAction.ext-code
             .
                                        
          find first ub.promoAttr where
                     ub.promoAttr.attr-code = "charge-BL" and
                     ub.promoAttr.tablename = "PromoPay" and
                     buf_PromoAction.id = int64(entry(1,ub.PromoAttr.p-key,{&delim-key})) and 
                     buf_PromoAction.db-num = integer(entry(2,ub.PromoAttr.p-key,{&delim-key})) 
                no-error.
          if available (ub.PromoAttr) and 
             logical(ub.PromoAttr.attr-value) = true 
          then tt-info.change-BL = "да" .
          else tt-info.change-BL = "нет" .
                    
      end.
    end.   
                  
    if ChkPromoPrice(buf_chk-gds.doc-code, buf_chk-gds.line-num) then
       assign
          tt-info.src-promo-qnty = buf_chk-gds.src-qnty
          tt-info.discnt = 0
          tt-info.src-qnty = tt-info.src-qnty + buf_chk-gds.src-qnty  
          v-sum-r = RoundUp(buf_chk-gds.src-qnty, buf_chk-gds.src-price)
          v-sum-no-disc = v-sum-r
          v-sum-disc = 0
          . 
    else do:
       if ChkDopLitr(buf_chk-gds.doc-code, buf_chk-gds.line-num)
       then
           assign 
              tt-info.dop-qnty = buf_chk-gds.src-qnty 
              tt-info.dop-sum = Round(buf_chk-gds.src-price * buf_chk-gds.src-qnty, 2)
              .
       else      
           assign
              tt-info.price-base = buf_chk-gds.price-base
              tt-info.src-price = buf_chk-gds.src-price            
              .
          
       assign    
          tt-info.src-qnty = tt-info.src-qnty + buf_chk-gds.src-qnty              
          tt-info.discnt = buf_chk-discnt.discnt-value-abs / buf_chk-gds.src-qnty
          v-sum-r = Round((buf_chk-gds.src-price - tt-info.discnt) * buf_chk-gds.src-qnty, 2)          
          v-sum-disc = ChkPromoSum(buf_chk-gds.doc-code, buf_chk-gds.line-num)
          v-sum-no-disc = Round(buf_chk-gds.src-price * buf_chk-gds.src-qnty, 2) + v-sum-disc
          .  
    end.  
               
    assign
       tt-info.src-sum = tt-info.src-sum + v-sum-r   
       tt-info.src-sum-no-disc = tt-info.src-sum-no-disc + v-sum-no-disc
       tt-info.src-sum-disc = tt-info.src-sum-no-disc - tt-info.src-sum
       .
       
  end.               
                   

end procedure .

procedure report-itog:
    define variable v-sum-r as decimal no-undo.
    define variable v-sum-no-disc        as decimal   no-undo.
    define variable v-sum-disc           as decimal   no-undo. 
    
    define buffer buf_chk-discnt for ub.chk-discnt.
    define buffer buf_chk-doc    for ub.chk-doc.
    define buffer buf_chk-gds    for ub.chk-gds.
    
    for each tt-info:
        for each buf_chk-doc no-lock where 
                 buf_chk-doc.obj-code = tt-info.obj-code 
             and buf_chk-doc.obj-type = tt-info.obj-type
             and buf_chk-doc.pay-desk = tt-info.pay-desk
             and buf_chk-doc.chk-type = int({&rcpt-return})
             and buf_chk-doc.doc-num2 = substitute("&1:&2",tt-info.chk-num,tt-info.z-number),
             each buf_chk-gds no-lock where 
                  buf_chk-gds.doc-code = buf_chk-doc.doc-code and 
                  buf_chk-gds.pl-code  = tt-info.pl-code 
                  :
             
             find first buf_chk-discnt no-lock where 
                        buf_chk-discnt.doc-code = buf_chk-doc.doc-code and
                        buf_chk-discnt.promo-id > ""   and                
                        buf_chk-discnt.record-type = 1 and               
                        buf_chk-discnt.object-line-num = buf_chk-gds.line-num
                  no-error.             
             
             assign
                 tt-info.ret-doc-code = buf_chk-gds.doc-code                                                   
                 tt-info.ret-chk-num = buf_chk-doc.chk-num
                 tt-info.ret-chk-date = buf_chk-doc.chk-date
                 tt-info.ret-shift-num = buf_chk-doc.shift-num
                 tt-info.ret-shift-date = buf_chk-doc.shift-date
                 .
                 
              if ChkPromoPrice(buf_chk-gds.doc-code, buf_chk-gds.line-num) then
                assign
                  tt-info.ret-promo-qnty = -1 * buf_chk-gds.src-qnty                                
                  v-sum-r = RoundUp(buf_chk-gds.src-qnty, buf_chk-gds.src-price)
                  v-sum-no-disc = v-sum-r
                  v-sum-disc = 0
                  tt-info.ret-nodiscnt = no
                  . 
              else do:
                   if ChkDopLitr(buf_chk-gds.doc-code, buf_chk-gds.line-num)
                   then  
                     assign 
                        tt-info.dop-qnty = tt-info.dop-qnty - buf_chk-gds.src-qnty 
                        tt-info.dop-sum = tt-info.dop-sum - Round(buf_chk-gds.src-price * buf_chk-gds.src-qnty, 2)
                        v-sum-disc = 0
                        tt-info.ret-nodiscnt = no
                        .
                   else    
                      assign
                         tt-info.ret-src-price = buf_chk-gds.src-price
                         tt-info.ret-discnt = if avail buf_chk-discnt then buf_chk-discnt.discnt-value-abs / buf_chk-gds.src-qnty else 0
                         v-sum-disc = ChkPromoSum(buf_chk-gds.doc-code, buf_chk-gds.line-num)
                         tt-info.ret-nodiscnt = if (v-sum-disc = 0 and tt-info.ret-discnt = 0) then yes else no.                               
                         .
                      
                   assign                                        
                      tt-info.ret-discnt = if avail buf_chk-discnt then buf_chk-discnt.discnt-value-abs / buf_chk-gds.src-qnty else 0
                      v-sum-r = Round((buf_chk-gds.src-price - tt-info.ret-discnt) * buf_chk-gds.src-qnty, 2) 
                      tt-info.ret-src-qnty = tt-info.ret-src-qnty - buf_chk-gds.src-qnty                               
                      v-sum-no-disc = if tt-info.ret-nodiscnt then Round(tt-info.src-price * buf_chk-gds.src-qnty, 2) 
                                                              else (Round(buf_chk-gds.src-price * buf_chk-gds.src-qnty, 2) + v-sum-disc)                      
                      .           
                                   
              end.     
                               
              assign
                 tt-info.ret-src-sum = tt-info.ret-src-sum - v-sum-r  
                 tt-info.ret-sum-no-disc = tt-info.ret-sum-no-disc - v-sum-no-disc
       /*tt-info.src-sum-disc = tt-info.src-sum-no-disc - tt-info.src-sum*/
                 .                  
                                    
              /* кассир */
              if tt-info.ret-cashier = "" then do:
                  find first buf_person where 
                             buf_person.psn-code = buf_chk-doc.cashier-psn-code 
                     no-lock no-error.
                  if avail buf_person THEN  
                     tt-info.ret-cashier = buf_person.name1 + ' ' + buf_person.name2 + ' '.
                  find first buf_clients where 
                             buf_clients.obj-code = buf_chk-doc.cashier-psn-code  and 
                             buf_clients.obj-type = 'чел' 
                     no-lock no-error.
                  if avail buf_clients then 
                     tt-info.ret-cashier = tt-info.ret-cashier + buf_clients.obj-name.
              end.           
        end.      
        /* итоги */
        assign
           tt-info.itog-qnty = tt-info.src-qnty - tt-info.ret-src-qnty - tt-info.ret-promo-qnty
           tt-info.itog-sum-no-disc = tt-info.src-sum-no-disc - tt-info.ret-sum-no-disc
           tt-info.itog-sum = tt-info.src-sum - tt-info.ret-src-sum
           tt-info.itog-sum-disc = tt-info.itog-sum-no-disc - tt-info.itog-sum
           tt-info.itog-proc = tt-info.itog-sum-disc * 100 / tt-info.itog-sum-no-disc
           tt-info.sts = (if (tt-info.src-promo-qnty > 0 and tt-info.ret-promo-qnty > 0 and tt-info.ret-src-qnty = 0) 
                              or (tt-info.src-promo-qnty > 0 and tt-info.src-promo-qnty = tt-info.ret-promo-qnty) 
                              or tt-info.itog-qnty = 0
                          then "1" 
                          else "0")
           .
    end.
end.    

/* Печать шапки и заголовков */    
procedure report-header:                        
    put stream OutStr-html unformatted
      '<body>' skip
      /*Первая таблица*/
      '<TABLE name="1"  fit_to_page="true" orientation="portrait" CELLSPACING="0" BORDER="0">'skip
      '<thead>' skip
      .
    
    put stream OutStr-html unformatted
      '<tr class="set_columns">' skip
      '<td style="width: 80px;"></td>' skip
      '<td style="width: 80px;"></td>' skip
      '<td style="width: 80px;"></td>' skip
      '<td style="width: 80px;"></td>' skip
      '<td style="width: 80px;"></td>' skip
      '<td style="width: 80px;"></td>' skip
      '<td style="width: 80px;"></td>' skip
      '<td style="width: 80px;"></td>' skip
      '<td style="width: 80px;"></td>' skip
      '<td style="width: 80px;"></td>' skip
      '<td style="width: 80px;"></td>' skip
      '<td style="width: 80px;"></td>' skip
      '<td style="width: 80px;"></td>' skip
      '<td style="width: 80px;"></td>' skip
      '<td style="width: 80px;"></td>' skip
      '<td style="width: 80px;"></td>' skip
      '<td style="width: 80px;"></td>' skip
      '<td style="width: 80px;"></td>' skip
      '<td style="width: 80px;"></td>' skip
      '<td style="width: 80px;"></td>' skip
      '<td style="width: 80px;"></td>' skip
      '<td style="width: 80px;"></td>' skip
      '<td style="width: 80px;"></td>' skip
      '<td style="width: 80px;"></td>' skip
      '<td style="width: 80px;"></td>' skip
      '<td style="width: 80px;"></td>' skip
      '</tr>' skip
      .
                            
     
    put stream OutStr-html unformatted
       '<TR><TD colspan="27"></TD></TR>' skip
       '<TR>' skip
       '<TD colspan="6" style="font-weight: bold;">Отчет по примененным скидкам на НП</TD>' skip
       '</TR>' skip
       '<TR>' skip
       '<TD colspan="4">Период:</TD>' skip
       '<TD colspan="11">' + v-period + '</TD>' skip
       '</TR>' skip
       '<TR>' skip
       '<TD colspan="4">Объекты:</TD>' skip            
       '<TD colspan="11">АЗК № ' + v-list-obj + ' маг</TD>' skip
       '<TD colspan="3"></TD>' skip
       '<TD colspan="9">Статус условий может принимать значения:</TD>' skip      
       '</TR>' skip
       '<TR>' skip
       '<TD colspan="4">Промоакции:</TD>' skip
       '<TD colspan="11">' + vPromoName + '</TD>' skip
       '<TD colspan="3"></TD>' skip
       '<TD colspan="9">1 – при полном или частичном возврате, когда промоакция перестала действовать.</TD>' skip
       '</TR>' skip
       '<TR>' skip
       '<TD colspan="4">Статус выполнения условий:</TD>' skip
       '<TD colspan="11">' + vStatusCond + '</TD>' skip
       '<TD colspan="3"></TD>' skip
       '<TD colspan="9">0 – при частичном возврате, когда промоакция продолжает действовать.</TD>' skip
       '</TR>' skip
    
      '</thead>' skip
      .
 
   put stream OutStr-html unformatted
        '<tbody>' skip
        '<TR>' skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Объект</TH>'    skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">НП, код</TH>'   skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">НП, назв.</TH>' skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Цена</TH>'      skip
        '<TH text_wrap="true" rowspan="4" colspan="8" style="text-align: center; font-weight:bold; ">Чек продажи</TH>'   skip
        '<TH text_wrap="true" rowspan="4" colspan="6" style="text-align: center; font-weight:bold; ">Чек возврата</TH>'  skip
        '<TH text_wrap="true" rowspan="4" colspan="8" style="text-align: center; font-weight:bold; ">Итоги по применению промоакции</TH>' skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Запрет начисления баллов лояльности</TH>'           skip
        '</TR>' skip
        
        '<TR>' skip
        '</TR>' skip
        
        '<TR>' skip
        '</TR>' skip
        
        '<TR>' skip
        '</TR>' skip
        
        '<TR>' skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Номер и дата смены чека</TH>'         skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Дата чека</TH>'                       skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Номер чека</TH>'                      skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Кассир</TH>'                          skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Кол-во</TH>'                          skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Сумма продажи</TH>'                   skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Сумма без скидки</TH>'                skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Сумма скидки</TH>'                    skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Номер и дата смены чека</TH>'         skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Дата чека</TH>'                       skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Номер чека</TH>'                      skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Кассир</TH>'                          skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Кол-во</TH>'                          skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Сумма возвр.</TH>'                    skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Код акции </TH>'                      skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Наим. акции</TH>'                     skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Кол-во</TH>'                          skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Сумма без скидки</TH>'                skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Сумма со скидкой по чеку</TH>'        skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Сумма скидки по чеку</TH>'            skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">% скидки по чеку</TH>'                skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Статус условий </TH>'                 skip                
        '</TR>' skip
        
        '<TR>' skip
        '<TH style="text-align: center; font-weight:bold; ">1</TH>'    skip
        '<TH style="text-align: center; font-weight:bold; ">2</TH>'    skip
        '<TH style="text-align: center; font-weight:bold; ">3</TH>'    skip
        '<TH style="text-align: center; font-weight:bold; ">4</TH>'    skip
        '<TH style="text-align: center; font-weight:bold; ">5.1</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">5.2</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">5.3</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">5.4</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">5.5</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">5.6</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">5.7</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">5.8</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">6.1</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">6.2</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">6.3</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">6.4</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">6.5</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">6.6</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">7.1</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">7.2</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">7.3</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">7.4</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">7.5</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">7.6</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">7.7</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">7.8</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">8</TH>'  skip
        '</TR>' skip
      .
          
end procedure.

/* Печать строк */
procedure report-body:
    for each tt-info where can-do(vLstSts,tt-info.sts):
        put stream OutStr-html unformatted
            '<TR>' skip
            '<TD text_wrap="true" style="text-align: center;">' + tt-info.obj-name + '</TD>'  skip
            '<TD text_wrap="true" style="text-align: center;">' + string(tt-info.b-code) + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + tt-info.gds-name + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + if tt-info.src-price <> 0 then fnc-convert-dot-to-colon(tt-info.src-price,"->>>>>>>>>>>9.99",2) + '</TD>' else "0" + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + "№" + string(tt-info.shift-num) + " " + string(tt-info.shift-date)  + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(tt-info.chk-date)  + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(tt-info.chk-num)  + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + tt-info.cashier  + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + if tt-info.src-qnty <> 0 then fnc-convert-dot-to-colon((tt-info.src-qnty),"->>>>>>>>>>>9.99",2) + '</TD>' else "0.00" + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + if tt-info.src-sum <> 0 then fnc-convert-dot-to-colon(tt-info.src-sum,"->>>>>>>>>>>9.99",2) + '</TD>' else "0.00" + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + if tt-info.src-sum-no-disc <> 0 then fnc-convert-dot-to-colon(tt-info.src-sum-no-disc,"->>>>>>>>>>>9.99",2) + '</TD>' else "0.00" + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + if tt-info.src-sum-disc <> 0 then fnc-convert-dot-to-colon(tt-info.src-sum-disc,"->>>>>>>>>>>9.99",2) + '</TD>' else "0.00" + '</TD>' skip
            .
        if tt-info.ret-doc-code <> "" then
        put stream OutStr-html unformatted    
            '<TD text_wrap="true" style="text-align: center;">' + "№" + string(tt-info.ret-shift-num) + " " + string(tt-info.ret-shift-date)  + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(tt-info.ret-chk-date)  + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(tt-info.ret-chk-num)   + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + tt-info.ret-cashier  + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + if (tt-info.ret-src-qnty +  + tt-info.ret-promo-qnty) <> 0 then fnc-convert-dot-to-colon((tt-info.ret-src-qnty + tt-info.ret-promo-qnty),"->>>>>>>>>>>9.99",2) + '</TD>' else "0.00" + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + if tt-info.ret-src-sum <> 0 then fnc-convert-dot-to-colon(tt-info.ret-src-sum,"->>>>>>>>>>>9.99",2) + '</TD>' else "0.00" + '</TD>' skip
            .
        else 
        put stream OutStr-html unformatted    
            '<TD text_wrap="true" style="text-align: center;">' + "-" + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + "-" + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + "-" + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + "-" + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + "-" + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + "-" + '</TD>' skip
            .
        put stream OutStr-html unformatted             
            '<TD text_wrap="true" style="text-align: center;">' + tt-info.promo-id + (if tt-info.ext-code > "" then (" / " + tt-info.ext-code) else "") + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + tt-info.nameAction  + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + if tt-info.itog-qnty <> 0 then fnc-convert-dot-to-colon(tt-info.itog-qnty,"->>>>>>>>>>>9.99",2) + '</TD>' else "0.00" + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + if tt-info.itog-sum-no-disc <> 0 then fnc-convert-dot-to-colon(tt-info.itog-sum-no-disc,"->>>>>>>>>>>9.99",2) + '</TD>' else "0.00" + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + if tt-info.itog-sum <> 0 then fnc-convert-dot-to-colon(tt-info.itog-sum,"->>>>>>>>>>>9.99",2) + '</TD>' else "0.00" + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + if tt-info.itog-sum-disc <> 0 then fnc-convert-dot-to-colon(tt-info.itog-sum-disc,"->>>>>>>>>>>9.99",2) + '</TD>' else "0.00" + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + if tt-info.itog-proc <> 0 then fnc-convert-dot-to-colon(tt-info.itog-proc,"->>>>>>>>>>>9.99",2) + '</TD>' else "0.00" + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + tt-info.sts  + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + tt-info.change-BL  + '</TD>' skip
            '</TR>'
            skip .
    end.   
    
end procedure.
                                                                                                                    
procedure clients-write:
    
   DEFINE input PARAMETER   p-obj-code      as integer      no-undo .
   DEFINE INPUT PARAMETER   p-obj-type      as character    no-undo .
   DEFINE OUTPUT PARAMETER  p-obj-name      as character    no-undo .
   define buffer buf_clients for ub.clients .
        
   find first buf_clients no-lock where buf_clients.obj-code = p-obj-code
      and buf_clients.obj-type = p-obj-type no-error .
   if AVAILABLE buf_clients then 
   do:
      p-obj-name = buf_clients.obj-name .
   end.     
end.                                            

procedure ConvertStr-chk-type: 
  
   define input parameter p-chk-type as character no-undo.
   define output parameter p-name-chk-type as character no-undo.
   define variable v-num-element as integer no-undo.

   /* Код_вида_расходов. Получение номера элемента в списке кодов */
   v-num-element = lookup(p-chk-type, {&receipt-codes}).

   /* Получение наименования код_вида_расходов по полученному элементу из списка наименований */
   p-name-chk-type = entry(v-num-element, {&receipt-codes-full}).
   if p-chk-type <> "" and v-num-element = 0 then
   do:
      message "Ошибка 115." view-as alert-box.
      return.
   end.

end procedure.

procedure ConvertStr-pay-type: 
  
   define input parameter p-pay-code as integer no-undo.
   define output parameter p-name-pay-type as character no-undo.
  
   find first ub.cash-pay no-lock where ub.cash-pay.cdpay-code = p-pay-code and ub.cash-pay.status_ = {&current-status} no-error .
   if available (ub.cash-pay) then p-name-pay-type = ub.cash-pay.obj-name .
end procedure.  

