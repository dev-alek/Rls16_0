/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

В какой валюте печатать отчет в зависимости от R-B

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 06/30/03 5:49

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
case x-set_pay_type :
  when 1 then do: /* crsa */
        tprintrubl = ( var-report-r-b = {&r-b-rubl} ) .
  end.
  when 2 or when 3 then do: /* cost  & sale */
        if x-set_val_type = 1 /* rubl */ then tprintrubl = yes .
        if x-set_val_type = 2 /* base */ then tprintrubl = no  .
  end.
end case.
/* $Workfile$ e n d */