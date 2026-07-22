/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Функция показывает коды групп объектов ценообразования для clients

Автор: Чернова Светлана Александровна
Дата создания: 05/21/07
Author: Svetlana Chernova
Creation date: 05/21/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

FUNCTION price-grp RETURNS CHARACTER
(buffer buf_clients for ub.clients):
define variable tt-grp-obj as character no-undo .
tt-grp-obj =  "" .
  for each x_obj-grp-obj-price  where
           x_obj-grp-obj-price.stts = 0 and
           x_obj-grp-obj-price.obj-type = buf_clients.obj-type and
           x_obj-grp-obj-price.obj-code = buf_clients.obj-code :
           tt-grp-obj = tt-grp-obj + string(x_obj-grp-obj-price.gop-id ) +
           ( if x_obj-grp-obj-price.gop-db-num = 0 then "" else
           "БД"  + string (x_obj-grp-obj-price.gop-db-num)) + "," .
  end.
return trim(tt-grp-obj, ",") .
END FUNCTION.


/* $Workfile$ e n d */