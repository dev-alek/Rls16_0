block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: l-tppr.p $
$Archive: ref/l-tppr.p $

Процедура вызова и сбора recid по типам прайс-листов по одному объекту с выбором ТПЛ


Автор: Чернова Светлана Александровна
Дата создания: 08/10/06
Author: Svetlana Chernova
Creation date: 08/10/06

*/
define input  parameter parParentProc as handle no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define input  parameter p-bttn as character no-undo .
define output parameter p-recid as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: l-tppr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/l-tppr.p $":U .
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

if p-obj-type = {&cmp} or p-obj-type = {&prs} then do:
end.
/* ОБЪЕКТЫ */
else do:

define buffer buf_grp-obj-price for ub.grp-obj-price  .

for each buf_price-list-type no-lock where
          buf_price-list-type.stts     = integer({&pdf-new}) and
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
                      buf_price-list-type.stts        = integer({&pdf-new}) and
                      buf_price-list-type.gop-id      = buf_grp-obj-price.gop-id and
                      buf_price-list-type.gop-db-num  = buf_grp-obj-price.gop-db-num
                      :
                      v-par = v-par + string(recid(buf_price-list-type)) +  "," .
                  end.
        end.
end.

end.
run waitfram-hide in this-procedure .
v-par = trim (v-par, "," ).
if num-entries (v-par, "," ) = 1 then do:
   find first buf_price-list-type no-lock where recid(buf_price-list-type) = int(v-par)  no-error .
   if not error-status :error then  do:
      message "Найден 1 подходящий ТПЛ для объекта"
        p-obj-type
        p-obj-code
        skip
        buf_price-list-type.name skip
        view-as alert-box information .
      p-recid =  v-par .
      return .
   end.
end.


run ref/typepric.w (
    input parParentProc     ,
    input "mode=plt-id," + p-bttn + ",title=Типы Прайс-листов для " + caps(buf_clients.obj-name) + " endtitle" ,
    input-output v-par
    ) no-error .
p-recid =  v-par .