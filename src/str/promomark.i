/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Шкляр Елена
Дата создания: 03/24/06
Author: Shklyar Elena
Creation date: 03/24/06

*/

define buffer buf_PromoAction for ub.PromoAction .
define buffer buf_PromoGoods  for ub.PromoGoods .
define buffer buf_PromoGift   for ub.PromoGift .
define buffer buf_goods-attr  for ub.goods-attr .
define buffer buf_clients     for ub.clients .

for each buf_PromoGift no-lock:
   if can-find (first buf_goods-attr no-lock where buf_goods-attr.gds-code = buf_PromoGift.gds-code and 
      buf_goods-attr.attr-code = {&attr-mark-type} and buf_goods-attr.attr-value <> "not-type" and 
      buf_goods-attr.attr-value <> "") then 
   do:
      find first buf_PromoAction exclusive-lock where buf_PromoAction.id = buf_PromoGift.idaction and 
         buf_PromoAction.db-num = buf_PromoGift.db-num and buf_PromoAction.end-date >= today no-error .
      if available (buf_PromoAction) then 
      do:
         buf_PromoAction.end-date = today - 1 .
         buf_PromoAction.Status_ = 1 .

         /*Удаление с кассы*/
    find first buf_clients no-lock
         where buf_clients.db-num   = buf_PromoAction.db-num
           and buf_clients.obj-type = {&shop} no-error .
    if available (buf_clients) then do:
    
        run str/diallog.w (
        input this-procedure
      , input this-procedure
      , input "str/promosendoxml.p":U  + {&delim-par} +
                "1":U  + {&delim-par} +  /*error-message-option*/
                "1":U + {&delim-par} +  /*auto-go-option*/
                "1":U                  /*return-value-option*/
      , input ({&cd-type-IBm-XML} + {&delim-par} + buf_clients.obj-type + {&delim-par} + string(buf_clients.obj-code) + {&delim-par} + "U":U + {&delim-par} + string(buf_clients.db-num) + {&delim-par} + string(buf_PromoAction.id))
      , input yes /*p-auto-go*/
      , input "":U
      , input substitute("Отсылка промоакций на кассы &1", {&cd-type-IBm-XML})
  ) no-error.
  end.
      end.   
   end.   
end.   
/*for each buf_PromoGoods no-lock:                                                                        */
/*   if can-find (first buf_goods-attr no-lock where buf_goods-attr.gds-code = buf_PromoGoods.gds-code and*/
/*      buf_goods-attr.attr-code = {&attr-mark-type} and buf_goods-attr.attr-value <> "not-type" and      */
/*      buf_goods-attr.attr-value <> "") then                                                             */
/*   do:                                                                                                  */
/*      find first buf_PromoAction exclusive-lock where buf_PromoAction.id = buf_PromoGoods.idaction and  */
/*         buf_PromoAction.db-num = buf_PromoGoods.db-num and buf_PromoAction.end-date >= today no-error .*/
/*      if available (buf_PromoAction) then                                                               */
/*      do:                                                                                               */
/*         buf_PromoAction.end-date = today - 1 .                                                         */
/*      end.                                                                                              */
/*   end.                                                                                                 */
/*end.                                                                                                    */


/* $Workfile$ e n d */