using Progress.Lang.*.
using Ibs.Th.Gbl.ReportXml.
using Ibs.Th.Gbl.rep-out.
block-level on error undo, throw.
/*------------------------------------------------------------------------
$Revision: 14aa1c227e1d, 3435, rls $
$Author: EShklyar $
$Date: 2023/10/16 15:13:32 $
$Workfile: r-work_promo.p $
$Archive: rep/r-work_promo.p $

Срабатывание промо-акции

Автор: Шкляр Елена
Дата создания: 09/07/05
Author: Shklyar Elena
Creation date: 09/07/05
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define input parameter parparentproc  as	handle 	no-undo.
define input parameter p-itog     as    logical no-undo.

define variable vss-revision    as character no-undo init "$Revision: 14aa1c227e1d, 3435, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2023/10/16 15:13:32 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-work_promo.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-work_promo.p $":U .
define variable vss-description as character no-undo init "Срабатывание промо-акции СТ" .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ gbl/cur-time.i }

{ gbl/prn-lib.i     }
{ rep/html-conv.i }

{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }   
{ str/lib-trn.i  }

define stream Out-Stream.
define stream OutStr-html.

DEFINE TEMP-TABLE tt-promo
  field obj-code     as integer
  field obj-type     as character
  field obj-name     as character
  field shift-date   as date
  field shift-num    as integer
  field promo-id     as character
  field promo-name   as character
  field object-qnty  as integer
  field goods-qnty   as integer
  field discount-sum as decimal
  field itog-sum     as decimal
  field methodCalc   as integer
  field return-qnty  as integer
  field sale-qnty    as integer
  field change-BL    as character
  Index pi obj-code obj-type shift-num shift-date promo-id
  . 

DEFINE TEMP-TABLE tt-promo-itog-obj
  field obj-code     as integer
  field obj-type     as character
  field obj-name     as character
  field promo-id     as character
  field promo-name   as character
  field object-qnty  as integer
  field goods-qnty   as integer
  field discount-sum as decimal
  field itog-sum     as decimal
  field return-qnty  as integer
  field sale-qnty    as integer
  field change-BL    as characte
  Index pi obj-code obj-type promo-id
  .   

DEFINE TEMP-TABLE tt-promo-itog
  field promo-id     as character
  field promo-name   as character
  field object-qnty  as integer
  field goods-qnty   as integer
  field discount-sum as decimal
  field itog-sum     as decimal
  field return-qnty  as integer
  field sale-qnty    as integer
  field change-BL    as character
  Index pi promo-id
  .   
     
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
define buffer buf_tt-promo-itog   for tt-promo-itog .
define buffer buf_chk-gds         for ub.chk-gds .
define buffer bf_chk-discnt       for ub.chk-discnt .
define buffer bf_chk-discnt-attr  for ub.chk-discnt-attr .

define VARIABLE p-report-id as character no-undo .

/* определение, что промоакция на НП */
function ChkPLLine returns logical
    (input iDocCode as character,
    input iLineNum as integer,
    input iPromoId as character)
    : 
    define buffer buf_chk-gds for ub.chk-gds.    
    define buffer bf_chk-discnt for ub.chk-discnt.
    define buffer buf_bar-code for ub.bar-code.
    define buffer buf_goods for ub.goods.
    define buffer  buf_chk-discnt-attr for ub.chk-discnt-attr. 
    
    define variable vPromo as logical no-undo.
    define variable is-petrolium         as logical   no-undo.
    define variable is-pieces            as logical   no-undo.
    
    vPromo = no.
        
    find first buf_chk-gds no-lock where                 
               buf_chk-gds.doc-code = iDocCode
           and buf_chk-gds.line-num  = iLineNum                                                   
    no-error.
    if avail buf_chk-gds 
    then do:
       find first buf_bar-code no-lock where buf_bar-code.b-code = buf_chk-gds.b-code no-error .
       if avail buf_bar-code then
       find first buf_goods no-lock where buf_goods.gds-code = buf_bar-code.gds-code no-error .
       if avail buf_bar-code and avail buf_goods then do:
           { str/is-petrl.i
              buf_goods.artic
              buf_goods.prod-type
              buf_goods.prod-code
              is-petrolium
              is-pieces
              no-error
            }        
            if is-petrolium then 
             vPromo = yes.
        end. 
    end.        
    
    return vPromo.
end.

/* определение, что промоакция по СП */
function ChkGoodLine returns logical
    (input iDocCode as character,    
    input iPromoId as character)
    : 
    define buffer buf_chk-gds for ub.chk-gds.    
    define buffer bf_chk-discnt for ub.chk-discnt.
    define buffer buf_bar-code for ub.bar-code.
    define buffer buf_goods for ub.goods.
    define buffer  buf_chk-discnt-attr for ub.chk-discnt-attr. 
    
    define variable vGds as logical no-undo.
    define variable is-petrolium         as logical   no-undo.
    define variable is-pieces            as logical   no-undo.
    define variable vRecordType         as integer   no-undo .
    
    vGds = no.
        
    if can-find(first bf_chk-discnt no-lock where 
                      bf_chk-discnt.doc-code = iDocCode and 
                      bf_chk-discnt.record-type = 1 and                
                      bf_chk-discnt.promo-id = iPromoId)
    then vRecordType = 1.
    else vRecordType = 0. 
         
    /* если хоть один сопут. товар есть по скидке промо */  
    chkdisc:
    for each bf_chk-discnt no-lock where                   
             bf_chk-discnt.doc-code = iDocCode and 
             bf_chk-discnt.record-type = vRecordType and 
             bf_chk-discnt.promo-id = iPromoId,                     
       first buf_chk-gds no-lock where 
             buf_chk-gds.doc-code = bf_chk-discnt.doc-code and 
             buf_chk-gds.line-num = bf_chk-discnt.object-line-num,
       first buf_bar-code no-lock where buf_bar-code.b-code = buf_chk-gds.b-code,
       first buf_goods no-lock where buf_goods.gds-code = buf_bar-code.gds-code:
                                        
       { str/is-petrl.i
          buf_goods.artic
          buf_goods.prod-type
          buf_goods.prod-code
          is-petrolium
          is-pieces
          no-error
        }                  
                           
        if not is-petrolium then 
        do:
            vGds = yes.   
            leave chkdisc.
        end.                                           
    end.           
         
    return vGds.
end.

/*Данные для шапки*/
/*Период*/
if x-TOG-Shift then 
do:
  v-period = "Смены с " + string (x-Shift-Start) + " по " + string (x-Shift-End) + " За период с " + string (x-Date-Start,"99.99.9999") + " по " + string (x-Date-End,"99.99.9999") .
end.
else 
do:
  v-period = "За период с " + string (x-Date-Start,"99.99.9999") + " по " + string (x-Date-End,"99.99.9999") .
end.      
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
      and buf_chk-doc.chk-type <> 8
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
      and buf_chk-doc.chk-type <> 8
      and buf_chk-doc.chk-date >= x-Date-Start 
      and buf_chk-doc.chk-date <= x-Date-End
      and buf_chk-doc.out-code <> ?:
      run report .
    end.  
  end.  
end.

/*Общие данные*/

procedure report:
  define variable vRecordType as integer   no-undo .
  
  for each buf_chk-discnt-attr no-lock where buf_chk-discnt-attr.attr-code = "promo-id" and buf_chk-discnt-attr.doc-code = buf_chk-doc.doc-code:
    if ChkGoodLine(buf_chk-discnt-attr.doc-code, buf_chk-discnt-attr.attr-value)
    then 
    for first buf_chk-discnt no-lock where buf_chk-discnt.doc-code = buf_chk-discnt-attr.doc-code and buf_chk-discnt.record-type = 5
      and buf_chk-discnt.discnt-id = buf_chk-discnt-attr.discnt-id:
          
      find first tt-promo where 
                 tt-promo.obj-code = buf_chk-doc.obj-code and 
                 tt-promo.obj-type = buf_chk-doc.obj-type and 
                 tt-promo.promo-id = buf_chk-discnt-attr.attr-value and 
                 tt-promo.shift-date = buf_chk-doc.shift-date and
                 tt-promo.shift-num = buf_chk-doc.shift-num 
      no-error .              
                
      if not available (tt-promo) then 
      do:
        create tt-promo .
        assign
          tt-promo.obj-code   = buf_chk-doc.obj-code
          tt-promo.obj-type   = buf_chk-doc.obj-type
          tt-promo.promo-id   = buf_chk-discnt-attr.attr-value
          tt-promo.shift-date = buf_chk-doc.shift-date
          tt-promo.shift-num  = buf_chk-doc.shift-num
          .               
                   
        for first ub.clients no-lock where ub.clients.obj-code = tt-promo.obj-code and
          ub.clients.obj-type = tt-promo.obj-type:
          tt-promo.obj-name = ub.clients.obj-name .
        end.
        for first ub.PromoAction no-lock where ub.PromoAction.id = int64(tt-promo.promo-id):
          tt-promo.promo-name = ub.PromoAction.nameAction .
          tt-promo.methodCalc = ub.PromoAction.methodCalc . 
            find first ub.promoAttr where
              ub.promoAttr.attr-code = "charge-BL" and
              ub.promoAttr.tablename = "PromoPay" and
              ub.PromoAction.id = int64(entry(1,ub.PromoAttr.p-key,{&delim-key})) and 
              ub.PromoAction.db-num = integer(entry(2,ub.PromoAttr.p-key,{&delim-key})) 
              no-error.
            if available (ub.PromoAttr) then do:
              if logical(ub.PromoAttr.attr-value) = true then tt-promo.change-BL = "да" .
              else tt-promo.change-BL = "нет" .
            end.
            else tt-promo.change-BL = "нет" .                                                        
        end.                                                   
      end.              
      
      assign
        tt-promo.object-qnty = tt-promo.object-qnty + buf_chk-discnt.object-sum
        .
                    
      if buf_chk-doc.chk-type = integer({&rcpt-return}) or buf_chk-doc.chk-type = integer({&rcpt-return-write-off}) then 
        tt-promo.return-qnty = tt-promo.return-qnty + buf_chk-discnt.object-sum .
        
      if can-find(first bf_chk-discnt no-lock where 
                        bf_chk-discnt.doc-code =  buf_chk-doc.doc-code and 
                        bf_chk-discnt.record-type = 1 and                
                        bf_chk-discnt.promo-id = tt-promo.promo-id)
      then vRecordType = 1.
      else vRecordType = 0.                   
      
      for each bf_chk-discnt no-lock where 
               bf_chk-discnt.doc-code =  buf_chk-doc.doc-code and 
               bf_chk-discnt.record-type = vRecordType and                
               bf_chk-discnt.promo-id = tt-promo.promo-id,
         first buf_chk-gds no-lock where 
               buf_chk-gds.doc-code = bf_chk-discnt.doc-code and 
               buf_chk-gds.line-num = bf_chk-discnt.object-line-num:        
            if not ChkPLLine(buf_chk-gds.doc-code, buf_chk-gds.line-num, tt-promo.promo-id)
            then do:                                         
                /*сообщение если, тогда нет скидки*/
                if tt-promo.methodCalc <> 6 then 
                do:
                  assign
                    tt-promo.discount-sum = tt-promo.discount-sum + bf_chk-discnt.discnt-value-abs
                    .
                end.
                assign 
                  tt-promo.goods-qnty = tt-promo.goods-qnty + buf_chk-gds.doc-qnty
                  tt-promo.itog-sum   = tt-promo.itog-sum + buf_chk-gds.src-sum
                  .     
            end.                        
      end.   

      if tt-promo.goods-qnty > 0 or tt-promo.methodCalc = 6 then tt-promo.sale-qnty = tt-promo.object-qnty - (tt-promo.return-qnty * 2) .
            
    end.   
  end.                                           
  
end procedure .
   
/*печать*/

run get-report-num (output p-report-id).
    
v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html".   
                        
output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8'.
put stream OutStr-html unformatted
  { rep/htmlhead.i }
  .
                        
                        
put stream OutStr-html unformatted
  '<body>' skip
  /*Первая таблица*/
  '<TABLE name="1"  fit_to_page="true" orientation="portrait" CELLSPACING="0" BORDER="0">'skip
  '<thead>' skip
  .

put stream OutStr-html unformatted
  '<tr class="set_columns">' skip
  '<td style="width: 100px;"></td>' skip
  '<td style="width: 80px;"></td>' skip
  '<td style="width: 80px;"></td>' skip
  '<td style="width: 150px;"></td>' skip
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
  '<TR><TD colspan="11"></TD></TR>' skip
  '<TR>' skip
  '<TD colspan="11" style="font-weight: bold;">Отчет по реализации промоакций на СТ за период с ' + string(x-Date-Start,"99.99.99") + ' по ' + string(x-Date-End,"99.99.99") + '</TD>' skip
  '</TR>'skip
  '<TR>' skip
  '<TD colspan="11">Выбор объекта:</TD>' skip
  '</TR>'skip
  '<TR>' skip
  '<TD colspan="11">' + "АЗК №" + v-list-obj + " маг" + '</TD>' skip
  '</TR>'skip

  '</thead>' skip
  '<tbody>' skip
  .
put stream OutStr-html unformatted
  '<TR>' skip
  '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Дата смены</TD>' skip
  '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">№ смены</TD>' skip
  '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">№ промоакции</TD>' skip
  '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Наименование промо-акции</TD>' skip
  '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Кол-во срабатываний</TD>' skip
  '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Кол-во продаж</TD>' skip
  '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Кол-во возвратов</TD>' skip
  '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Кол-во акционных товаров</TD>' skip
  '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Сумма скидки</TD>' skip
  '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Сумма без скидки</TD>' skip
 /* '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Сумма c учетом скидки</TD>' skip */
  '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Запрет начисления баллов лояльности</TD>' skip
  '</TR>'skip       
  .        

for each obj-list by obj-list.obj-code:
  ii = 0 .
  for each tt-promo where tt-promo.obj-code = obj-list.obj-code and tt-promo.obj-type = obj-list.obj-type:
    if not can-find (first tt-promo-itog-obj where tt-promo-itog-obj.obj-code = tt-promo.obj-code and tt-promo-itog-obj.obj-type = tt-promo.obj-type) then 
    do:
      if not p-itog then 
      do: 
        put stream OutStr-html unformatted
          '<tr><TD colspan="11" text_wrap="true" style="text-align: left; font-weight: bold;">' + tt-promo.obj-name + '</TD></tr>' skip
          .
      end.
      create tt-promo-itog-obj .
      assign
        tt-promo-itog-obj.obj-code   = tt-promo.obj-code
        tt-promo-itog-obj.obj-type   = tt-promo.obj-type
        tt-promo-itog-obj.obj-name   = tt-promo.obj-name
        tt-promo-itog-obj.promo-id   = tt-promo.promo-id
        tt-promo-itog-obj.promo-name = tt-promo.promo-name
        .
      ii = 1 .
    end.  
    if not p-itog then 
    do:  
    
      put stream OutStr-html unformatted
        '<TR>' skip
        '<TD text_wrap="true" style="text-align: center;">' + if tt-promo.shift-date <> ? then string(tt-promo.shift-date,"99.99.9999") + '</TD>' else " "  + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + if tt-promo.shift-num <> 0 then string(tt-promo.shift-num) + '</TD>' else " "  + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(tt-promo.promo-id) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(tt-promo.promo-name) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: right;">' + if tt-promo.object-qnty <> 0 then fnc-convert-dot-to-colon(tt-promo.object-qnty,"->>>>>>>>>>>9",0) + '</TD>' else "0" + '</TD>' skip
        '<TD text_wrap="true" style="text-align: right;">' + if tt-promo.sale-qnty <> 0 then fnc-convert-dot-to-colon(tt-promo.sale-qnty,"->>>>>>>>>>>9",0) + '</TD>' else "0" + '</TD>' skip
        '<TD text_wrap="true" style="text-align: right;">' + if tt-promo.return-qnty <> 0 then fnc-convert-dot-to-colon(tt-promo.return-qnty,"->>>>>>>>>>>9",0) + '</TD>' else "0" + '</TD>' skip
        '<TD text_wrap="true" style="text-align: right;">' + if tt-promo.goods-qnty <> 0 then fnc-convert-dot-to-colon(tt-promo.goods-qnty,"->>>>>>>>>>>9",0) + '</TD>' else "0" + '</TD>' skip
        '<TD text_wrap="true" style="text-align: right;">' + if tt-promo.discount-sum <> 0 then fnc-convert-dot-to-colon(tt-promo.discount-sum,"->>>>>>>>>>>9.99",2) + '</TD>' else "0.00" + '</TD>' skip
        '<TD text_wrap="true" style="text-align: right;">' + if tt-promo.itog-sum <> 0 then fnc-convert-dot-to-colon(tt-promo.itog-sum,"->>>>>>>>>>>9.99",2) + '</TD>' else "0.00" + '</TD>' skip
/*        '<TD text_wrap="true" style="text-align: right;">' + if tt-promo.itog-sum <> 0 then fnc-convert-dot-to-colon((tt-promo.itog-sum - tt-promo.discount-sum),"->>>>>>>>>>>9.99",2) + '</TD>' else "0.00" + '</TD>' skip */
        '<TD text_wrap="true" style="text-align: center;">' + tt-promo.change-BL + '</TD>' skip
        '</TR>' skip.
    end.

    find first tt-promo-itog-obj where tt-promo-itog-obj.obj-code = tt-promo.obj-code and
      tt-promo-itog-obj.obj-type = tt-promo.obj-type and
      tt-promo-itog-obj.obj-name = tt-promo.obj-name and
      tt-promo-itog-obj.promo-id = tt-promo.promo-id and
      tt-promo-itog-obj.promo-name = tt-promo.promo-name no-error .
    if not available (tt-promo-itog-obj) then 
    do:
      create tt-promo-itog-obj .
      assign
        tt-promo-itog-obj.obj-code   = tt-promo.obj-code
        tt-promo-itog-obj.obj-type   = tt-promo.obj-type
        tt-promo-itog-obj.obj-name   = tt-promo.obj-name
        tt-promo-itog-obj.promo-id   = tt-promo.promo-id
        tt-promo-itog-obj.promo-name = tt-promo.promo-name
        tt-promo-itog-obj.change-BL  = tt-promo.change-BL
        .
      ii = ii + 1 .
    end.                                          
    assign
      tt-promo-itog-obj.goods-qnty   = tt-promo-itog-obj.goods-qnty + tt-promo.goods-qnty
      tt-promo-itog-obj.object-qnty  = tt-promo-itog-obj.object-qnty + tt-promo.object-qnty
      tt-promo-itog-obj.discount-sum = tt-promo-itog-obj.discount-sum + tt-promo.discount-sum
      tt-promo-itog-obj.itog-sum     = tt-promo-itog-obj.itog-sum + tt-promo.itog-sum
      tt-promo-itog-obj.return-qnty  = tt-promo-itog-obj.return-qnty + tt-promo.return-qnty
      tt-promo-itog-obj.sale-qnty    = tt-promo-itog-obj.sale-qnty + tt-promo.sale-qnty
      tt-promo-itog-obj.change-BL  = tt-promo.change-BL
      .
  end.
  v-first = true .
  for each tt-promo-itog-obj where tt-promo-itog-obj.obj-code = obj-list.obj-code and tt-promo-itog-obj.obj-type = obj-list.obj-type:
    if v-first then 
    do:
      put stream OutStr-html unformatted
        '<TR>' skip
        '<TD text_wrap="true" colspan=2 rowspan=' + string(ii) + ' style="text-align: center; font-weight: bold;">' + "Итого по " + string(tt-promo-itog-obj.obj-name) + '</TD>' skip
        .
      put stream OutStr-html unformatted
        '<TD text_wrap="true" style="text-align: center; font-weight: bold;">' + string(tt-promo-itog-obj.promo-id) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight: bold;">' + string(tt-promo-itog-obj.promo-name) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: right; font-weight: bold;">' + if tt-promo-itog-obj.object-qnty <> 0 then fnc-convert-dot-to-colon(tt-promo-itog-obj.object-qnty,"->>>>>>>>>>>9",0) + '</TD>' else "0" + '</TD>' skip
        '<TD text_wrap="true" style="text-align: right; font-weight: bold;">' + if tt-promo-itog-obj.sale-qnty <> 0 then fnc-convert-dot-to-colon(tt-promo-itog-obj.sale-qnty,"->>>>>>>>>>>9",0) + '</TD>' else "0" + '</TD>' skip
        '<TD text_wrap="true" style="text-align: right; font-weight: bold;">' + if tt-promo-itog-obj.return-qnty <> 0 then fnc-convert-dot-to-colon(tt-promo-itog-obj.return-qnty,"->>>>>>>>>>>9",0) + '</TD>' else "0" + '</TD>' skip
        '<TD text_wrap="true" style="text-align: right; font-weight: bold;">' + if tt-promo-itog-obj.goods-qnty <> 0 then fnc-convert-dot-to-colon(tt-promo-itog-obj.goods-qnty,"->>>>>>>>>>>9",0) + '</TD>' else "0" + '</TD>' skip
        '<TD text_wrap="true" style="text-align: right; font-weight: bold;">' + if tt-promo-itog-obj.discount-sum <> 0 then fnc-convert-dot-to-colon(tt-promo-itog-obj.discount-sum,"->>>>>>>>>>>9.99",2) + '</TD>' else "0.00" + '</TD>' skip
        '<TD text_wrap="true" style="text-align: right; font-weight: bold;">' + if tt-promo-itog-obj.itog-sum <> 0 then fnc-convert-dot-to-colon(tt-promo-itog-obj.itog-sum,"->>>>>>>>>>>9.99",2) + '</TD>' else "0.00" + '</TD>' skip
        /*'<TD text_wrap="true" style="text-align: right; font-weight: bold;">' + if tt-promo-itog-obj.itog-sum <> 0 then fnc-convert-dot-to-colon((tt-promo-itog-obj.itog-sum - tt-promo-itog-obj.discount-sum),"->>>>>>>>>>>9.99",2) + '</TD>' else "0.00" + '</TD>' skip */
        '<TD text_wrap="true" style="text-align: center;">' + tt-promo-itog-obj.change-BL + '</TD>' skip
        '</TR>' skip.
      v-first = false .
    end.
    else 
    do:
      put stream OutStr-html unformatted
        '<TR>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight: bold;">' + string(tt-promo-itog-obj.promo-id) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight: bold;">' + string(tt-promo-itog-obj.promo-name) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: right; font-weight: bold;">' + if tt-promo-itog-obj.object-qnty <> 0 then fnc-convert-dot-to-colon(tt-promo-itog-obj.object-qnty,"->>>>>>>>>>>9",0) + '</TD>' else "0" + '</TD>' skip
        '<TD text_wrap="true" style="text-align: right; font-weight: bold;">' + if tt-promo-itog-obj.sale-qnty <> 0 then fnc-convert-dot-to-colon(tt-promo-itog-obj.sale-qnty,"->>>>>>>>>>>9",0) + '</TD>' else "0" + '</TD>' skip
        '<TD text_wrap="true" style="text-align: right; font-weight: bold;">' + if tt-promo-itog-obj.return-qnty <> 0 then fnc-convert-dot-to-colon(tt-promo-itog-obj.return-qnty,"->>>>>>>>>>>9",0) + '</TD>' else "0" + '</TD>' skip
        '<TD text_wrap="true" style="text-align: right; font-weight: bold;">' + if tt-promo-itog-obj.goods-qnty <> 0 then fnc-convert-dot-to-colon(tt-promo-itog-obj.goods-qnty,"->>>>>>>>>>>9",0) + '</TD>' else "0" + '</TD>' skip
        '<TD text_wrap="true" style="text-align: right; font-weight: bold;">' + if tt-promo-itog-obj.discount-sum <> 0 then fnc-convert-dot-to-colon(tt-promo-itog-obj.discount-sum,"->>>>>>>>>>>9.99",2) + '</TD>' else "0.00" + '</TD>' skip
        '<TD text_wrap="true" style="text-align: right; font-weight: bold;">' + if tt-promo-itog-obj.itog-sum <> 0 then fnc-convert-dot-to-colon(tt-promo-itog-obj.itog-sum,"->>>>>>>>>>>9.99",2) + '</TD>' else "0.00" + '</TD>' skip
        /*'<TD text_wrap="true" style="text-align: right; font-weight: bold;">' + if tt-promo-itog-obj.itog-sum <> 0 then fnc-convert-dot-to-colon((tt-promo-itog-obj.itog-sum - tt-promo-itog-obj.discount-sum),"->>>>>>>>>>>9.99",2) + '</TD>' else "0.00" + '</TD>' skip*/
        '<TD text_wrap="true" style="text-align: center; font-weight: bold;">' + tt-promo-itog-obj.change-BL + '</TD>' skip
        '</TR>' skip.
    end.    
    find first tt-promo-itog where tt-promo-itog.promo-id = tt-promo-itog-obj.promo-id no-error .
    if not available (tt-promo-itog) then 
    do:
      create tt-promo-itog .
      assign
        tt-promo-itog.promo-id   = tt-promo-itog-obj.promo-id
        tt-promo-itog.promo-name = tt-promo-itog-obj.promo-name
        tt-promo-itog.change-BL = tt-promo-itog-obj.change-BL
        .
      kk = kk + 1 .
    end.   
    assign
      tt-promo-itog.discount-sum = tt-promo-itog.discount-sum + tt-promo-itog-obj.discount-sum
      tt-promo-itog.goods-qnty   = tt-promo-itog.goods-qnty + tt-promo-itog-obj.goods-qnty
      tt-promo-itog.itog-sum     = tt-promo-itog.itog-sum + tt-promo-itog-obj.itog-sum
      tt-promo-itog.object-qnty  = tt-promo-itog.object-qnty + tt-promo-itog-obj.object-qnty
      tt-promo-itog.return-qnty  = tt-promo-itog.return-qnty + tt-promo-itog-obj.return-qnty
      tt-promo-itog.sale-qnty    = tt-promo-itog.sale-qnty + tt-promo-itog-obj.sale-qnty
      tt-promo-itog.change-BL = tt-promo-itog-obj.change-BL
      .     
  end.
end.

v-first = true .
for each tt-promo-itog :
  if v-first then 
  do:
    put stream OutStr-html unformatted
      '<TR>' skip
      '<TD text_wrap="true" colspan=2 rowspan=' + string(kk) + ' style="text-align: center; font-weight: bold;">' + "ИТОГО" + '</TD>' skip
      .
    put stream OutStr-html unformatted
      '<TD text_wrap="true" style="text-align: center; font-weight: bold;">' + string(tt-promo-itog.promo-id) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center; font-weight: bold;">' + string(tt-promo-itog.promo-name) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: right; font-weight: bold;">' + if tt-promo-itog.object-qnty <> 0 then fnc-convert-dot-to-colon(tt-promo-itog.object-qnty,"->>>>>>>>>>>9",0) + '</TD>' else "0" + '</TD>' skip
      '<TD text_wrap="true" style="text-align: right; font-weight: bold;">' + if tt-promo-itog.sale-qnty <> 0 then fnc-convert-dot-to-colon(tt-promo-itog.sale-qnty,"->>>>>>>>>>>9",0) + '</TD>' else "0" + '</TD>' skip
      '<TD text_wrap="true" style="text-align: right; font-weight: bold;">' + if tt-promo-itog.return-qnty <> 0 then fnc-convert-dot-to-colon(tt-promo-itog.return-qnty,"->>>>>>>>>>>9",0) + '</TD>' else "0" + '</TD>' skip
      '<TD text_wrap="true" style="text-align: right; font-weight: bold;">' + if tt-promo-itog.goods-qnty <> 0 then fnc-convert-dot-to-colon(tt-promo-itog.goods-qnty,"->>>>>>>>>>>9",0) + '</TD>' else "0" + '</TD>' skip
      '<TD text_wrap="true" style="text-align: right; font-weight: bold;">' + if tt-promo-itog.discount-sum <> 0 then fnc-convert-dot-to-colon(tt-promo-itog.discount-sum,"->>>>>>>>>>>9.99",2) + '</TD>' else "0.00" + '</TD>' skip
      '<TD text_wrap="true" style="text-align: right; font-weight: bold;">' + if tt-promo-itog.itog-sum <> 0 then fnc-convert-dot-to-colon(tt-promo-itog.itog-sum,"->>>>>>>>>>>9.99",2) + '</TD>' else "0.00" + '</TD>' skip
 /*     '<TD text_wrap="true" style="text-align: right; font-weight: bold;">' + if tt-promo-itog.itog-sum <> 0 then fnc-convert-dot-to-colon((tt-promo-itog.itog-sum - tt-promo-itog.discount-sum),"->>>>>>>>>>>9.99",2) + '</TD>' else "0.00" + '</TD>' skip */
      '<TD text_wrap="true" style="text-align: center; font-weight: bold;">' + tt-promo-itog.change-BL + '</TD>' skip
      '</TR>' skip.
    v-first = false .
  end.
  else 
  do:
    put stream OutStr-html unformatted
      '<TR>' skip
      '<TD text_wrap="true" style="text-align: center; font-weight: bold;">' + string(tt-promo-itog.promo-id) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center; font-weight: bold;">' + string(tt-promo-itog.promo-name) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: right; font-weight: bold;">' + if tt-promo-itog.object-qnty <> 0 then fnc-convert-dot-to-colon(tt-promo-itog.object-qnty,"->>>>>>>>>>>9",0) + '</TD>' else "0" + '</TD>' skip
      '<TD text_wrap="true" style="text-align: right; font-weight: bold;">' + if tt-promo-itog.sale-qnty <> 0 then fnc-convert-dot-to-colon(tt-promo-itog.sale-qnty,"->>>>>>>>>>>9",0) + '</TD>' else "0" + '</TD>' skip
      '<TD text_wrap="true" style="text-align: right; font-weight: bold;">' + if tt-promo-itog.return-qnty <> 0 then fnc-convert-dot-to-colon(tt-promo-itog.return-qnty,"->>>>>>>>>>>9",0) + '</TD>' else "0" + '</TD>' skip
      '<TD text_wrap="true" style="text-align: right; font-weight: bold;">' + if tt-promo-itog.goods-qnty <> 0 then fnc-convert-dot-to-colon(tt-promo-itog.goods-qnty,"->>>>>>>>>>>9",0) + '</TD>' else "0" + '</TD>' skip
      '<TD text_wrap="true" style="text-align: right; font-weight: bold;">' + if tt-promo-itog.discount-sum <> 0 then fnc-convert-dot-to-colon(tt-promo-itog.discount-sum,"->>>>>>>>>>>9.99",2) + '</TD>' else "0.00" + '</TD>' skip
      '<TD text_wrap="true" style="text-align: right; font-weight: bold;">' + if tt-promo-itog.itog-sum <> 0 then fnc-convert-dot-to-colon(tt-promo-itog.itog-sum,"->>>>>>>>>>>9.99",2) + '</TD>' else "0.00" + '</TD>' skip
      /*'<TD text_wrap="true" style="text-align: right; font-weight: bold;">' + if tt-promo-itog.itog-sum <> 0 then fnc-convert-dot-to-colon((tt-promo-itog.itog-sum - tt-promo-itog.discount-sum),"->>>>>>>>>>>9.99",2) + '</TD>' else "0.00" + '</TD>' skip*/
      '<TD text_wrap="true" style="text-align: center; font-weight: bold;">' + tt-promo-itog.change-BL + '</TD>' skip
      '</TR>' skip.
  end.            
end.
   
put stream OutStr-html unformatted

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

PROCEDURE get-report-num :

  define output parameter p-report-num as integer no-undo .

  do
    on error undo, return error return-value
    :
    run gbl/getrpnum.p (output p-report-num).
  end.

END PROCEDURE.