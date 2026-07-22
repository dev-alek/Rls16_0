/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$
 


Автор: Рубан Дмитрий Андреевич
Дата создания: 11/07/18
Author: Ruban Dmitriy
Creation date: 11/07/18

*/
block-level on error undo, throw.

&scoped-define main-tbl PromoAction
trigger procedure for delete of ub.{&main-tbl}.

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo init "Тригер удаления {&main-tbl}". 
{ trg/trghistnws.i 
  &hist = yes 
  &seqnamehist = "s-promo-chip"
  &nws  = yes
  &del  = yes
}

   for each  ub.PromoCriterion where ub.PromoCriterion.idAction eq  ub.PromoAction.id
   exclusive-lock:
       delete ub.PromoCriterion.
   end.
   
   for each  ub.PromoGift where ub.PromoGift.idAction eq  ub.PromoAction.id
   exclusive-lock:
       delete ub.PromoGift.
   end.     
 
    for each  ub.PromoAttr where ub.PromoAttr.tablename eq  "PromoAction" and ub.PromoAction.id = int64(entry(1,ub.PromoAttr.p-key,{&delim-key}))
   exclusive-lock:
       delete ub.PromoAttr.
   end.  
     
   for each  ub.PromoGoods where ub.PromoGoods.idAction eq  ub.PromoAction.id
   exclusive-lock:
       delete ub.PromoGoods.
   end.
   for each  ub.PromoObject where ub.PromoObject.idAction eq  ub.PromoAction.id
   exclusive-lock:
       delete ub.PromoObject.
   end.
   
   for each  ub.PromoAttr where ub.PromoAttr.tablename eq "{&main-tbl}"
                            and ub.PromoAttr.p-key     eq string(ub.{&main-tbl}.id) + {&delim-key} + string(ub.{&main-tbl}.db-num)
   exclusive-lock:
       delete ub.PromoAttr.
   end.
