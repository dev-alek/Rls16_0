/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры довавления и удаления покупателя в группы

Автор: Чернова Светлана Александровна
Дата создания: 11/10/05
Author: Svetlana Chernova
Creation date: 11/10/05


*/
PROCEDURE BIB-ADD :
define input  parameter p-db-num       as integer   no-undo .
define input  parameter p-id           as integer   no-undo .
define input  parameter p-obj-code     as integer   no-undo .
define input  parameter p-obj-type     as character no-undo .
define input  parameter p-stts         as integer   no-undo .
define input  parameter p-db-num-usr   as integer   no-undo .
define input  parameter p-userid       as character no-undo .
define input-output parameter v-sec as integer   no-undo .

  do
  on error undo, return error return-value
  :
if v-cntxt-db-num <> 0 then do :
   if p-db-num <> v-cntxt-db-num then do:
      message substitute(" Группа создана в другой БД (&1) , корректировать ее в текущей БД нельзя !" , p-db-num ) .
      return error substitute(" Группа создана в другой БД (&1) , корректировать ее нельзя !" , p-db-num).
   end.
end.

find first ub.buyer-in-buyer-group exclusive-lock where
        ub.buyer-in-buyer-group.bgr-db-num   = p-db-num  and
        ub.buyer-in-buyer-group.bgr-id       = p-id      and
        ub.buyer-in-buyer-group.bbg-obj-code = p-obj-code and
        ub.buyer-in-buyer-group.bbg-obj-type = p-obj-type no-error .
      if not available ub.buyer-in-buyer-group then do:
          create ub.buyer-in-buyer-group.
            assign
                ub.buyer-in-buyer-group.bgr-db-num  = p-db-num
                ub.buyer-in-buyer-group.bgr-id      = p-id
                ub.buyer-in-buyer-group.bbg-obj-code = p-obj-code
                ub.buyer-in-buyer-group.bbg-obj-type = p-obj-type
            .
      end.
      assign
        ub.buyer-in-buyer-group.db-num-chg    = p-db-num-usr
        ub.buyer-in-buyer-group.stts          = p-stts
        ub.buyer-in-buyer-group.sys-date      = today
        ub.buyer-in-buyer-group.sys-time      = time
        ub.buyer-in-buyer-group.sys-time-chr  = string(ub.buyer-in-buyer-group.sys-time,"hh:mm")
        ub.buyer-in-buyer-group.who           = p-userid
      .
      run ref/h-grbuy.p (buffer ub.buyer-in-buyer-group , input-output v-sec )  .
  end.

end procedure. /* bib-add */

PROCEDURE BIB-DEL :
define input  parameter p-db-num       as integer   no-undo .
define input  parameter p-id           as integer   no-undo .
define input  parameter p-obj-code     as integer   no-undo .
define input  parameter p-obj-type     as character no-undo .
define input  parameter p-db-num-usr   as integer   no-undo .
define input  parameter p-userid       as character no-undo .
define input-output parameter v-sec as integer   no-undo .

  do
  on error undo, return error return-value
  :

if v-cntxt-db-num <> 0 then do :
   if p-db-num <> v-cntxt-db-num then do:
      message substitute(" Группа создана в другой БД (&1) , удалять покупателей в текущей БД нельзя !" , p-db-num ) .
      return error substitute(" Группа создана в другой БД (&1) , удалять покупателей нельзя !" , p-db-num).
   end.
end.

find first ub.buyer-in-buyer-group exclusive-lock where
        ub.buyer-in-buyer-group.bgr-db-num   = p-db-num  and
        ub.buyer-in-buyer-group.bgr-id       = p-id      and
        ub.buyer-in-buyer-group.bbg-obj-code = p-obj-code and
        ub.buyer-in-buyer-group.bbg-obj-type = p-obj-type no-error .

 if not available ub.buyer-in-buyer-group then  return error .
      assign
        ub.buyer-in-buyer-group.db-num-chg    = p-db-num-usr
        ub.buyer-in-buyer-group.stts          = 1
        ub.buyer-in-buyer-group.sys-date      = today
        ub.buyer-in-buyer-group.sys-time      = time
        ub.buyer-in-buyer-group.sys-time-chr  = string(ub.buyer-in-buyer-group.sys-time,"hh:mm")
        ub.buyer-in-buyer-group.who           = p-userid
      .
  run ref/h-grbuy.p (buffer ub.buyer-in-buyer-group , input-output v-sec )  .
  end.
end procedure. /* bib-del */