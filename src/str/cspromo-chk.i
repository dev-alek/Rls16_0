/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Функции для работы с промоакциями по НП

Автор: Белова Марина
Дата создания: 31/01/2025
Author: Marina Belova
Creation date: 31/01/2025

*/

/* Проверка, что в чеке есть промоакция по НП */
function ChkGdsPromo returns logical
    (input iDocCode as character)
    : 
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_chk-gds-attr for ub.chk-gds-attr.
    define variable vPromo as logical no-undo.
    
    vPromo = no.
    cspr:
    for each buf_chk-gds no-lock where                 
                 buf_chk-gds.doc-code = iDocCode,
           first buf_chk-gds-attr no-lock where                 
                 buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num                                      
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and buf_chk-gds-attr.attr-value <> "0":                 
       vPromo = yes.
       leave cspr.          
    end.          
    
    return vPromo.
end.

function ChkPromoLine returns logical
    (input iDocCode as character,
    input iLineNum as integer)
    : 
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_chk-gds-attr for ub.chk-gds-attr.
    define variable vPromo as logical no-undo.
    
    vPromo = no.
    
    find first buf_chk-gds-attr no-lock where                 
                 buf_chk-gds-attr.doc-code = iDocCode
             and buf_chk-gds-attr.line-num  = iLineNum                                      
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and buf_chk-gds-attr.attr-value <> "0"
    no-error.
    if avail buf_chk-gds-attr then vPromo = yes.
    
    return vPromo.
end.

/* возвращает сумму скидки по промоакции НП по строке чека */
function ChkPromoSum returns decimal
    (input iDocCode as character,
     input iLineNum as integer)
    : 
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define variable vSumPromo as decimal no-undo.
   
   find first buf_chk-gds-attr no-lock where                 
              buf_chk-gds-attr.doc-code = iDocCode
          and buf_chk-gds-attr.line-num  = iLineNum                                      
          and buf_chk-gds-attr.attr-code = "CSPromoSum"
      no-error.
   if avail buf_chk-gds-attr then   
      vSumPromo = DEC(buf_chk-gds-attr.attr-value) no-error.                    
      
   return vSumPromo.
end function.

/* возвращает признак, что по строке акционная цена по промоакции НП (требует округления вверх) */
function ChkPromoPrice returns logical
    (input iDocCode as character,
     input iLineNum as integer)
    : 
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define variable v-is-promo as logical no-undo.
   
   v-is-promo = no.
   find first buf_chk-gds-attr no-lock where                 
              buf_chk-gds-attr.doc-code = iDocCode
          and buf_chk-gds-attr.line-num  = iLineNum                                      
          and buf_chk-gds-attr.attr-code = "CSPromo"
      no-error.
   if avail buf_chk-gds-attr 
     and can-do("2,4,5,7", buf_chk-gds-attr.attr-value)                 
   then v-is-promo = yes.
   
   return v-is-promo.
end function.

/* возвращает признак, что по строке доп.литр пролива */
function ChkDopLitr returns logical
    (input iDocCode as character,
     input iLineNum as integer)
    : 
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define variable v-is-promo as logical no-undo.
   
   v-is-promo = no.
   find first buf_chk-gds-attr no-lock where                 
              buf_chk-gds-attr.doc-code = iDocCode
          and buf_chk-gds-attr.line-num  = iLineNum                                      
          and buf_chk-gds-attr.attr-code = "CSPromo"
      no-error.
   if avail buf_chk-gds-attr and
     buf_chk-gds-attr.attr-value = "3"                 
   then v-is-promo = yes.
   
   return v-is-promo.
end function.
        
/* округление вверх */
function RoundUp return decimal
    (input iQnty as decimal,
     input iPrice as decimal):
         
    def var vSum  as decimal no-undo.     
    def var vSumR as decimal no-undo.
    
    vSum = ABSOLUTE(iQnty) * iPrice.
    vSumR = Round(vSum,2).
    if vSumR < vSum then vSumR = vSumR + 0.01.
    if iQnty < 0 then vSumR = - vSumR.
                                 
    return vSumR.     
end function.   

/* Возвращает сумму скидки по промоации НП по чеку, если она задана
** и рассчитывает, если не задана */
function GetPromoSum returns decimal
    (input iDocCode as character)
    :
    define buffer buf_chk-doc for ub.chk-doc.
    define buffer buf2_chk-doc for ub.chk-doc. 
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_chk-gds-attr for ub.chk-gds-attr.
    define buffer buf2_chk-gds for ub.chk-gds.
    define buffer buf2_chk-gds-attr for ub.chk-gds-attr.    
    define variable v-price-base as decimal no-undo.
    define variable v-doc-qnty as decimal no-undo.
    define variable v-sum-base as decimal no-undo.    
    define variable v-sum-all as decimal no-undo.    
    define variable v-sum-promo as decimal no-undo.     
    define variable v-sum-chk as decimal no-undo.       
    
    /* считаем скидку по промо НП без округления */
    assign
       v-price-base = 0 
       v-doc-qnty = 0
       v-sum-all = 0
       v-sum-chk = 0   
       v-sum-promo = 0
       .
    for each buf_chk-gds no-lock where                 
             buf_chk-gds.doc-code = iDocCode,
       first buf_chk-gds-attr no-lock where                 
             buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
         and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num                                      
         and buf_chk-gds-attr.attr-code = "CSPromoSum"         
       :
       v-sum-promo = Dec(buf_chk-gds-attr.attr-value).        
    end.
    if v-sum-promo = 0 then do:   
        for each buf_chk-gds no-lock where                 
                 buf_chk-gds.doc-code = iDocCode,
           first buf_chk-gds-attr no-lock where                 
                 buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num                                      
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and can-do("1,6", buf_chk-gds-attr.attr-value)        
           :    
           assign                
             v-price-base = buf_chk-gds.price-base
             v-doc-qnty   = if buf_chk-gds.doc-qnty = ? then buf_chk-gds.src-qnty else buf_chk-gds.doc-qnty
             v-sum-base = if buf_chk-gds.sum-base = ? then round(v-doc-qnty * v-price-base, 2) else buf_chk-gds.sum-base
             .        
        end.
        for each buf_chk-gds no-lock where                 
                 buf_chk-gds.doc-code = iDocCode,
           first buf_chk-gds-attr no-lock where                 
                 buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num                                      
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and can-do("2,4,5,7", buf_chk-gds-attr.attr-value)          
           :
           /* если не отработал верхний цикл, 
           ** надо найти цену из чека продажи */
           if v-price-base = 0 then do:
              find first buf_chk-doc no-lock where    
                         buf_chk-doc.doc-code = iDocCode
                  no-error. 
              if avail buf_chk-doc and 
                 buf_chk-doc.chk-type = int({&rcpt-return}) and 
                 buf_chk-doc.doc-num2 > ""  and 
                 num-entries(buf_chk-doc.doc-num2,":") = 2
              then 
              for first buf2_chk-doc no-lock where 
                        buf2_chk-doc.obj-code = buf_chk-doc.obj-code 
                    and buf2_chk-doc.obj-type = buf_chk-doc.obj-type
                    and buf2_chk-doc.chk-type = int({&rcpt-sale})
                    and buf2_chk-doc.chk-num = int(entry(1,buf_chk-doc.doc-num2,":"))
                    and buf2_chk-doc.z-number = int(entry(2, buf_chk-doc.doc-num2,":"))
                    :
                for each buf2_chk-gds no-lock where                 
                         buf2_chk-gds.doc-code = buf2_chk-doc.doc-code,
                   first buf2_chk-gds-attr no-lock where                 
                         buf2_chk-gds-attr.doc-code = buf2_chk-gds.doc-code
                     and buf2_chk-gds-attr.line-num  = buf2_chk-gds.line-num                                      
                     and buf2_chk-gds-attr.attr-code = "CSPromo"
                     and can-do("1,6", buf2_chk-gds-attr.attr-value)        
                   :    
                    v-price-base = buf2_chk-gds.price-base.
                end.    
              
              end.      
               
           end.                   
           if buf_chk-gds.sum-base = ? or buf_chk-gds.src-qnty = 0 then do:
               assign
                  v-sum-all = (buf_chk-gds.src-qnty + v-doc-qnty) * v-price-base
                  v-sum-chk = v-sum-base + RoundUp(buf_chk-gds.src-qnty, buf_chk-gds.src-price)
                  .                   
           end.
           else do:
              assign                
              v-sum-all = (buf_chk-gds.doc-qnty + v-doc-qnty ) * v-price-base          
              v-sum-chk = v-sum-base + buf_chk-gds.sum-base
              .                
           end.                      
        end.        
        v-sum-promo = Round(v-sum-all, 2) - Round(v-sum-chk, 2).   
    end.   
    
    return v-sum-promo.
end function.    

/* расчет суммы оплаты по чеку брутто с учетом промоакции НП */
function GetUnBaseSum returns decimal
    (input iDocCode as character,
     input iLineNum as integer,
     input iQnty as decimal,
     input iPrice as decimal):
          
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   
   define variable vBaseSum as decimal no-undo.
   define variable vDiscSum as decimal no-undo.
   
   vDiscSum = 0.
   find first buf_chk-gds-attr no-lock where                 
                     buf_chk-gds-attr.doc-code = iDocCode
                 and buf_chk-gds-attr.line-num  = iLineNum                                      
                 and buf_chk-gds-attr.attr-code = "CSPromoSum"
          no-error.
   if avail buf_chk-gds-attr then  
      vDiscSum = dec(buf_chk-gds-attr.attr-value) no-error.
   
   vBaseSum = iQnty * iPrice + vDiscSum.
                   
   if vDiscSum = 0 and ChkPromoPrice(iDocCode, iLineNum) then 
      vBaseSum = RoundUp(iQnty, iPrice).   
   
   return vBaseSum.
end function. 

/* расчет суммы оплаты по строке с учетом акционной цены по промоакции НП */
function GetRoundSum returns decimal
    (input iDocCode as character,
     input iLineNum as integer,
     input iQnty as decimal,
     input iPrice as decimal):
          
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   
   define variable vBaseSum as decimal no-undo.
   
   /* для акционной цены округление вверх */                   
   if ChkPromoPrice(iDocCode, iLineNum) then 
      vBaseSum = RoundUp(iQnty, iPrice).
   else vBaseSum = iQnty * iPrice.      
   
   return vBaseSum.
end function. 

/* расчет суммы оплаты по строке с учетом акционной цены по промоакции НП 
** по удаленному чеку*/
function GetRoundSumChkDel returns decimal
    (input iDocCode as character,
     input iLineNum as integer,
     input iChipNum as integer,
     input iQnty as decimal,
     input iPrice as decimal):
          
   define buffer  buf_c-chk-doc-attr for ub.c-chk-doc-attr.
   
   define variable vBaseSum as decimal no-undo.
   define variable vIsPromo as logical no-undo.
   
   /* для акционной цены округление вверх */
   for each buf_c-chk-doc-attr no-lock where
            buf_c-chk-doc-attr.doc-code = iDocCode
        and buf_c-chk-doc-attr.chip-num = iChipNum                
       :
       if num-entries(buf_c-chk-doc-attr.attr-code, {&delim-par}) > 1
       then do :
         if entry(1, buf_c-chk-doc-attr.attr-code, {&delim-par}) begins "gds="
         and entry(2, buf_c-chk-doc-attr.attr-code, {&delim-par}) = "CSPromo"
         and entry(2, entry(1, buf_c-chk-doc-attr.attr-code, {&delim-par}), "=") = String(iLineNum)
         and can-do("2,4,5,7", buf_c-chk-doc-attr.attr-value)
         then vIsPromo = yes.  
       end.
   end.       
                       
   if ChkPromoPrice(iDocCode, iLineNum) then 
      vBaseSum = RoundUp(iQnty, iPrice).
   else vBaseSum = iQnty * iPrice.      
   
   return vBaseSum.
end function. 

function GetSaleRetDisc returns decimal
    (input iDocCode as character,
     input iSaleCode as character):
         
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define buffer buf_chk-gds for ub.chk-gds.
   
   define variable vQntyPromoRet as decimal no-undo.
   define variable vQntyPromoSel as decimal no-undo.
   define variable vDiscSumRet   as decimal no-undo.
   define variable vDiscSumSale  as decimal no-undo.
   
   vDiscSumRet = 0.
   
   /* определяем кол-во по акц.цене в чеке возврата */
   cspr:
   for each  buf_chk-gds no-lock where                 
             buf_chk-gds.doc-code = iDocCode,
       first buf_chk-gds-attr no-lock where                 
             buf_chk-gds-attr.doc-code  = buf_chk-gds.doc-code
         and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num                                      
         and buf_chk-gds-attr.attr-code = "CSPromo"
         and can-do("2,4,5,7", buf_chk-gds-attr.attr-value)
       :                 
       vQntyPromoRet = buf_chk-gds.src-qnty. 
       leave cspr.          
   end.    
   
   /* определяем кол-во по акц.цене в чеке продажи и величину скидки */
   if vQntyPromoRet <> 0 then 
   for each  buf_chk-gds no-lock where                 
             buf_chk-gds.doc-code = iSaleCode:
                 
       find first buf_chk-gds-attr no-lock where                 
                  buf_chk-gds-attr.doc-code  = buf_chk-gds.doc-code
              and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num                                      
              and buf_chk-gds-attr.attr-code = "CSPromo"
       no-error.
       if avail buf_chk-gds-attr       
            and can-do("2,4,5,7", buf_chk-gds-attr.attr-value)
       then                  
         vQntyPromoSel = buf_chk-gds.src-qnty.             
       
       find first buf_chk-gds-attr no-lock where                 
                 buf_chk-gds-attr.doc-code  = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num                                      
             and buf_chk-gds-attr.attr-code = "CSPromoSum"
       no-error.
       if avail buf_chk-gds-attr then                       
          vDiscSumSale = dec(buf_chk-gds-attr.attr-value) no-error.           
   end.
   
   /* если равны, берем сумму скидки из чека продажи */
   if vQntyPromoRet <> 0 and 
      vQntyPromoSel = -1 * vQntyPromoRet
   then vDiscSumRet = -1 * vDiscSumSale.                    
         
   return vDiscSumRet.
end function. 

/* создаем скидки для возвратного чека */
function SetPromoDisc return logical
 (input iDocCode as character,
     input iLineNum as integer
    /* , input-output var-discnt-id as integer*/ )
    :
   
   define buffer buf_chk-doc for ub.chk-doc.
   define buffer buf2_chk-doc for ub.chk-doc.
   define buffer buf_chk-gds for ub.chk-gds.   
   define buffer buf2_chk-gds for ub.chk-gds.
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.   
   define buffer buf2_chk-gds-attr for ub.chk-gds-attr.
   define buffer buf_chk-discnt for ub.chk-discnt.
   define buffer buf2_chk-discnt for ub.chk-discnt.
   define buffer buf_chk-discnt-attr for ub.chk-discnt-attr.
   define buffer buf2_chk-discnt-attr for ub.chk-discnt-attr.
   
   define variable v-promo-sum as decimal no-undo.
   define variable v-disc-promo-id as character no-undo.   
   define variable var-discnt-id as integer no-undo.   
   define variable v-chk-sale as character no-undo.
              
   find first buf_chk-gds-attr no-lock where                 
              buf_chk-gds-attr.doc-code = iDocCode
          and buf_chk-gds-attr.line-num  = iLineNum                                      
          and buf_chk-gds-attr.attr-code = "CSPromo"
      no-error.
      
   if avail buf_chk-gds-attr      
     then do:              
           
     find first buf_chk-discnt no-lock where 
                buf_chk-discnt.doc-code = buf_chk-gds-attr.doc-code
            and buf_chk-discnt.line-num = buf_chk-gds-attr.line-num
            and buf_chk-discnt.record-type = 0
            and buf_chk-discnt.promo-id > ""
            no-error.
     if not avail buf_chk-discnt then do:                                        
          
        find first buf_chk-doc no-lock where                 
                   buf_chk-doc.doc-code = iDocCode         
           no-error.                  
        find first buf_chk-gds no-lock where                 
                   buf_chk-gds.doc-code = iDocCode
              and  buf_chk-gds.line-num = iLineNum
           no-error.   
        
        /* найти чек продажи и взять код акции из него */           
       for first buf2_chk-doc no-lock where 
                 buf2_chk-doc.obj-code = buf_chk-doc.obj-code 
             and buf2_chk-doc.obj-type = buf_chk-doc.obj-type
             and buf2_chk-doc.pay-desk = buf_chk-doc.pay-desk
             and buf2_chk-doc.chk-type = int({&rcpt-sale})
             and buf2_chk-doc.chk-num  = int(entry(1,buf_chk-doc.doc-num2,":"))
             and buf2_chk-doc.z-number = int(entry(2, buf_chk-doc.doc-num2,":"))
           :
           /* ищем этот товар в чеке продажи */    
           find first buf2_chk-gds no-lock where                 
                      buf2_chk-gds.doc-code = buf2_chk-doc.doc-code
                 and  buf2_chk-gds.b-code   = buf_chk-gds.b-code
           no-error.
           if not avail buf2_chk-gds then return no.
           
           /* Запоминаем чек продажи */
           v-chk-sale = buf2_chk-doc.doc-code.
           
           find first buf_chk-discnt no-lock where 
                      buf_chk-discnt.doc-code =  buf2_chk-doc.doc-code and
                      buf_chk-discnt.record-type = 1 and 
                      buf_chk-discnt.object-line-num = buf2_chk-gds.line-num and
                      buf_chk-discnt.promo-id > "" 
           no-error .
           if avail buf_chk-discnt
           then do:
              v-disc-promo-id = buf_chk-discnt.promo-id.
               
              find first buf2_chk-discnt no-lock where 
                buf2_chk-discnt.doc-code = iDocCode and
                buf2_chk-discnt.record-type = 5 and 
                buf2_chk-discnt.line-num = 0 and
                buf2_chk-discnt.promo-id =  v-disc-promo-id 
              no-error.
              find first buf2_chk-discnt-attr no-lock where 
                         buf2_chk-discnt-attr.doc-code = iDocCode and
                         buf2_chk-discnt-attr.record-type = 5 and 
                         buf2_chk-discnt-attr.line-num = 0 and                                
                         buf2_chk-discnt-attr.attr-code = "promo-id" and 
                         buf2_chk-discnt-attr.attr-value = v-disc-promo-id 
                    no-error .
              if not avail buf2_chk-discnt 
              then do:
                  for each buf_chk-discnt no-lock where 
                           buf_chk-discnt.doc-code = buf_chk-gds-attr.doc-code            
                       and buf_chk-discnt.record-type = 5:
                       var-discnt-id  = var-discnt-id + 1.     
                  end. 
    
                  create buf2_chk-discnt.
                  assign
                    buf2_chk-discnt.doc-code = iDocCode 
                    buf2_chk-discnt.record-type = 5 
                    buf2_chk-discnt.line-num = 0
                    buf2_chk-discnt.promo-id = v-disc-promo-id                        
                    buf2_chk-discnt.object-sum = 0 /* кол-во срабатыв. акции */
                    buf2_chk-discnt.discnt-id = if avail buf2_chk-discnt-attr 
                                                   then buf2_chk-discnt-attr.discnt-id 
                                                   else (var-discnt-id + 1)
                    var-discnt-id = 0                                     
                    buf2_chk-discnt.object-line-num = 0                              
                    buf2_chk-discnt.pay-desk = buf_chk-doc.pay-desk
                    buf2_chk-discnt.obj-code = buf_chk-doc.obj-code
                    buf2_chk-discnt.obj-type = buf_chk-doc.obj-type
                    buf2_chk-discnt.chk-date = buf_chk-doc.chk-date
                    buf2_chk-discnt.shift-date = buf_chk-doc.shift-date
                    buf2_chk-discnt.shift-num = buf_chk-doc.shift-num
                    buf2_chk-discnt.chk-time = buf_chk-doc.chk-time
                    .
              end.
              if avail buf2_chk-discnt and
                 not avail buf2_chk-discnt-attr 
              then do:   
                 create buf2_chk-discnt-attr.
                 assign
                    buf2_chk-discnt-attr.doc-code = iDocCode
                    buf2_chk-discnt-attr.discnt-id = buf2_chk-discnt.discnt-id
                    buf2_chk-discnt-attr.record-type     = 5 
                    buf2_chk-discnt-attr.line-num        = 0                     
                    buf2_chk-discnt-attr.object-line-num = 0
                    buf2_chk-discnt-attr.attr-code       = "promo-id"
                    buf2_chk-discnt-attr.attr-value      = v-disc-promo-id 
                    .
              end.
           end.             
       end.                               
        v-promo-sum = 0.          
        if can-do("1,6,7", buf_chk-gds-attr.attr-value)              
        then do: 
            /* проверяем, что если в чеке возврата то же кол-во по акц. цене, что и в чеке продажи,
            ** то сумму скидки берем из чека продажи */            
           if v-chk-sale <> ? and v-chk-sale <> "" then
              v-promo-sum = GetSaleRetDisc(iDocCode,v-chk-sale).
           /* если это не так, то считаем скидку сами */ 
           v-promo-sum = if v-promo-sum = 0 then GetPromoSum(iDocCode) else v-promo-sum.
           if v-promo-sum <> 0 then do:
               find first buf2_chk-gds-attr no-lock where                 
                          buf2_chk-gds-attr.doc-code = iDocCode
                      and buf2_chk-gds-attr.line-num  = iLineNum                                      
                      and buf2_chk-gds-attr.attr-code = "CSPromoSum"
                  no-error.
               if not avail buf2_chk-gds-attr then do:
                   create buf2_chk-gds-attr.
                   assign
                      buf2_chk-gds-attr.doc-code = iDocCode
                      buf2_chk-gds-attr.line-num  = iLineNum                                      
                      buf2_chk-gds-attr.attr-code = "CSPromoSum"
                      buf2_chk-gds-attr.attr-value = string(Round(v-promo-sum,2))
                      .
               end.
           end.                  
        end.        
        
        for each buf_chk-discnt no-lock where 
                buf_chk-discnt.doc-code = buf_chk-gds-attr.doc-code            
            and buf_chk-discnt.record-type = 0:
           var-discnt-id  = var-discnt-id + 1.     
        end.        
        
        create buf_chk-discnt.
        assign 
            buf_chk-discnt.doc-code = iDocCode
            buf_chk-discnt.line-num = iLineNum
            buf_chk-discnt.record-type = 0
            buf_chk-discnt.discnt-id = (var-discnt-id + 1)
            buf_chk-discnt.time-oper = buf_chk-gds.time-oper
            buf_chk-discnt.line-type = integer({&discnt-gds})
            buf_chk-discnt.line-sign = no
            buf_chk-discnt.pass-discnt = integer({&discnt-p-auto})
            buf_chk-discnt.value-type = integer({&discnt-v-abs})                
            buf_chk-discnt.src-d-card = buf_chk-gds.src-d-card                
            buf_chk-discnt.d-card = buf_chk-gds.d-card                                
            buf_chk-discnt.discnt-value-abs = 0
            buf_chk-discnt.discnt-value-pcnt = 0
            buf_chk-discnt.object-line-num = iLineNum
            buf_chk-discnt.pay-desk = buf_chk-doc.pay-desk
            buf_chk-discnt.obj-code = buf_chk-doc.obj-code
            buf_chk-discnt.obj-type = buf_chk-doc.obj-type 
            buf_chk-discnt.chk-date = buf_chk-doc.chk-date 
            buf_chk-discnt.chk-time = buf_chk-doc.chk-time
            buf_chk-discnt.shift-date = buf_chk-doc.shift-date
            buf_chk-discnt.shift-num = buf_chk-doc.shift-num
            buf_chk-discnt.object-qnty = buf_chk-gds.src-qnty
            buf_chk-discnt.object-sum = buf_chk-gds.src-sum
            var-discnt-id = var-discnt-id + 1            
            buf_chk-discnt.promo-id = v-disc-promo-id  
            buf_chk-discnt.discnt-type = integer({&discnt-t-promo})           
            .
        
        find first buf_chk-discnt-attr no-lock where 
                   buf_chk-discnt-attr.attr-code = "promo-id"            
               and buf_chk-discnt-attr.discnt-id = buf_chk-discnt.discnt-id
               and buf_chk-discnt-attr.doc-code = buf_chk-discnt.doc-code
               and buf_chk-discnt-attr.line-num = buf_chk-discnt.line-num
               no-error.
        if not avail buf_chk-discnt-attr then 
        do:        
            create buf_chk-discnt-attr .
            assign
                buf_chk-discnt-attr.attr-code = "promo-id"
                buf_chk-discnt-attr.attr-value = buf_chk-discnt.promo-id
                buf_chk-discnt-attr.discnt-id = buf_chk-discnt.discnt-id
                buf_chk-discnt-attr.doc-code = buf_chk-discnt.doc-code
                buf_chk-discnt-attr.line-num = buf_chk-discnt.line-num
                buf_chk-discnt-attr.object-line-num = buf_chk-discnt.object-line-num
                buf_chk-discnt-attr.record-type = buf_chk-discnt.record-type
                . 
         end.                 
     end.                   
   end.
       
   return yes.
end function.

/* Возвращает сумму по акционной цене по промоакции НП */
function GetPromoPriceSum returns decimal
    (input iDocCode as character)
    : 
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_chk-gds-attr for ub.chk-gds-attr.
    define variable vPromoSum as decimal no-undo.
    
    vPromoSum = 0.
    cspr:
    for each buf_chk-gds no-lock where                 
                 buf_chk-gds.doc-code = iDocCode,
           first buf_chk-gds-attr no-lock where                 
                 buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num                                      
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and can-do("2,4,5,7", buf_chk-gds-attr.attr-value):                 
       vPromoSum = RoundUp(buf_chk-gds.src-qnty, buf_chk-gds.src-price).
       leave cspr.          
    end.          
    
    return vPromoSum.
end.

/* Возвращает сумму по акционной цене по промоакции НП */
function GetPromoPriceLine returns integer
    (input iDocCode as character)
    : 
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_chk-gds-attr for ub.chk-gds-attr.
    define variable vPromoLine as integer no-undo.
    
    vPromoLine = 0.
    cspr:
    for each buf_chk-gds no-lock where                 
                 buf_chk-gds.doc-code = iDocCode,
           first buf_chk-gds-attr no-lock where                 
                 buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num                                      
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and can-do("2,4,5,7", buf_chk-gds-attr.attr-value):                 
       vPromoLine = buf_chk-gds-attr.line-num.
       leave cspr.          
    end.          
    
    return vPromoLine.
end.
