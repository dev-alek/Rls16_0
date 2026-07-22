block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: c-tppr.p $
$Archive: ref/c-tppr.p $

Процедура вызова и сбора recid по типам прайс-листов по одному клиенту


Автор: Чернова Светлана Александровна
Дата создания: 08/10/06
Author: Svetlana Chernova
Creation date: 08/10/06

*/
define input  parameter parParentProc as handle no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: c-tppr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/c-tppr.p $":U .
define variable vss-description as character no-undo init "Процедура вызова и сбора recid по типам прайс-листов по одному клиенту".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ ref/xobjgrp.i  }  /* список объектов  */
{ gbl/waitfram.i }

define buffer buf_clients for ub.clients  .
define buffer buf_price-list-type for ub.price-list-type  .
find first buf_clients no-lock where
           buf_clients.obj-type  = p-obj-type and
           buf_clients.obj-code  = p-obj-code no-error .
if error-status :error then return error error-status :get-message(1)  .
run waitfram-show in this-procedure ("Выборка типов прайс-листов...") .
define variable v-par as character no-undo  init "" .
/* ПОКУПАТЕЛИ */
if p-obj-type = {&cmp} or p-obj-type = {&prs} then do:

define buffer buf_buyer-in-buyer-group for ub.buyer-in-buyer-group  .
define buffer buf_buyer-group          for ub.buyer-group  .

for each buf_buyer-in-buyer-group no-lock where
         buf_buyer-in-buyer-group.bbg-obj-type = p-obj-type and
         buf_buyer-in-buyer-group.bbg-obj-code = p-obj-code,
    first buf_price-list-type no-lock where
          buf_price-list-type.bgr-id     = buf_buyer-in-buyer-group.bgr-id and
          buf_price-list-type.bgr-db-num = buf_buyer-in-buyer-group.bgr-db-num
          :
          v-par = v-par + string(recid(buf_price-list-type)) +  "," .
end.

/* все покупатели */
for each buf_price-list-type no-lock where
         buf_price-list-type.rs-buyer  = 0
          :
          v-par = v-par + string(recid(buf_price-list-type)) +  "," .
end.

/* По обороту */
define buffer buf_turnover-buyer-main for ub.turnover-buyer-main  .
define variable v-summa as decimal   no-undo init 0 .
for each   buf_turnover-buyer-main no-lock WHERE
    buf_turnover-buyer-main.cli-type =  p-obj-type AND
    buf_turnover-buyer-main.cli-code =  p-obj-code
    :
    v-summa = v-summa + buf_turnover-buyer-main.sum-doc-rubl-itog .
end.
define buffer buf_tnv-in-turnover-group for ub.tnv-in-turnover-group  .

define buffer buf_tnv-group for ub.turnover-group  .
define buffer last_tnv-in-turnover-group for ub.tnv-in-turnover-group  .
define variable v-tog-db-num as integer   no-undo init 0.
define variable v-tog-id    as integer   no-undo init 0.


for each buf_tnv-group no-lock :
    for each buf_tnv-in-turnover-group no-lock where
              buf_tnv-in-turnover-group.tog-db-num  = buf_tnv-group.tog-db-num  and
              buf_tnv-in-turnover-group.tog-id      = buf_tnv-group.tog-id       and
              buf_tnv-in-turnover-group.stts        = 0
              break by buf_tnv-in-turnover-group.ttg-summa
              :
              find first  last_tnv-in-turnover-group no-lock  where
                          last_tnv-in-turnover-group.stts       = 0 and
                          last_tnv-in-turnover-group.tog-db-num = buf_tnv-in-turnover-group.tog-db-num and
                          last_tnv-in-turnover-group.tog-id     = buf_tnv-in-turnover-group.tog-id      and
                          last_tnv-in-turnover-group.ttg-summa   > buf_tnv-in-turnover-group.ttg-summa
                          use-index pi no-error .
           if available last_tnv-in-turnover-group  then do:
                if v-summa >= buf_tnv-in-turnover-group.ttg-summa and  v-summa < last_tnv-in-turnover-group.ttg-summa then do:
                    v-tog-db-num = buf_tnv-in-turnover-group.tog-db-num .
                    v-tog-id     = buf_tnv-in-turnover-group.tog-id     .
                    leave.
                end.
           end.
           else do:
              if v-summa >= buf_tnv-in-turnover-group.ttg-summa then do:
              v-tog-db-num = buf_tnv-in-turnover-group.tog-db-num .
              v-tog-id     = buf_tnv-in-turnover-group.tog-id     .
              leave.
              end.
           end.

    end.
    if v-tog-id <> 0 then do:
       for each buf_price-list-type no-lock where
              buf_price-list-type.tog-id     = v-tog-id and
              buf_price-list-type.tog-db-num = v-tog-db-num
              :
              v-par = v-par + string(recid(buf_price-list-type)) +  "," .
       end.
    end.
end.
end.

/* ОБЪЕКТЫ */
else do:

define buffer buf_grp-obj-price for ub.grp-obj-price  .

for each buf_price-list-type no-lock where
          buf_price-list-type.use-obj  = 1 /* все */
          :
          v-par = v-par + string(recid(buf_price-list-type)) +  "," .
end.

for each buf_grp-obj-price no-lock :
        empty temp-table x_obj-group.
        run metod-gop-obj in this-procedure ( v-cntxt-db-num,  buf_grp-obj-price.gop-id , buf_grp-obj-price.gop-db-num) .
        if can-find( first x_obj-group where
                  x_obj-group.obj-type = p-obj-type and
                  x_obj-group.obj-code = p-obj-code ) then do
                  :
                  for each buf_price-list-type no-lock where
                      buf_price-list-type.use-obj     = 2 and
                      buf_price-list-type.gop-id      = buf_grp-obj-price.gop-id and
                      buf_price-list-type.gop-db-num  = buf_grp-obj-price.gop-db-num
                      :
                      v-par = v-par + string(recid(buf_price-list-type)) +  "," .
                  end.
        end.
end.

end.
run waitfram-hide in this-procedure .
run ref/typepric.w (
    input parParentProc     ,
    input "mode=plt-id,b-del,b-chg,title=Типы прайс-листов для " + caps(buf_clients.obj-name) + " endtitle" ,
    input-output v-par
    ) no-error .