/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Типы прайс-листов

Автор: Чернова Светлана Александровна
Дата создания: 06/08/06
Author: Svetlana Chernova
Creation date: 06/08/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :

  { nws/imps-nws.i rec-full }

  assign
    rec-name = entry( 1, rec-full, {&delim-nws} )
    .

  {&test-count}

  CASE rec-name :
    when "price-list-type-pay-type" then do:
      create locb-price-list-type-pay-type.
      { nws/impl-nws.i "price-list-type-pay-type" "locb-" }
    end.
    when "price-list-type-cassa" then do:
      create locb-price-list-type-cassa.
      { nws/impl-nws.i "price-list-type-cassa" "locb-" }
    end.
    when "price-list-type-gds-grp" then do:
      create locb-price-list-type-gds-grp.
      { nws/impl-nws.i "price-list-type-gds-grp" "locb-" }
    end.
    when "price-list-type-attr" then do:
      create locb-price-list-type-attr.
      { nws/impl-nws.i "price-list-type-attr" "locb-" }
    end.
    when "price-list-type-cash-pay" then do:
      create locb-price-list-type-cash-pay.
      { nws/impl-nws.i "price-list-type-cash-pay" "locb-" }
    end.
    otherwise do:
      message "Не предуcмотрен прием таблицы " rec-name skip
              "в cоcтаве куcта."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.



/* ------------------------------- price-list-type-pay-type ---------------------------------------------- */
for each buf_price-list-type-pay-type where buf_price-list-type-pay-type.plt-id     = wt-price-list-type.plt-id
                                  and buf_price-list-type-pay-type.plt-db-num = wt-price-list-type.plt-db-num
on error  undo, return error
:
  delete buf_price-list-type-pay-type.
end.

for each locb-price-list-type-pay-type where locb-price-list-type-pay-type.plt-id     = wt-price-list-type.plt-id
                                    and locb-price-list-type-pay-type.plt-db-num = wt-price-list-type.plt-db-num
no-lock
on error  undo, return error
:
  create buf_price-list-type-pay-type.
  buffer-copy locb-price-list-type-pay-type to buf_price-list-type-pay-type.
end.

/* ------------------------------- price-list-type-cassa ---------------------------------------------- */
for each buf_price-list-type-cassa where buf_price-list-type-cassa.plt-id     = wt-price-list-type.plt-id
                                  and buf_price-list-type-cassa.plt-db-num = wt-price-list-type.plt-db-num
on error  undo, return error
:
  delete buf_price-list-type-cassa.
end.

for each locb-price-list-type-cassa where locb-price-list-type-cassa.plt-id     = wt-price-list-type.plt-id
                                    and locb-price-list-type-cassa.plt-db-num = wt-price-list-type.plt-db-num
no-lock
on error  undo, return error
:
  create buf_price-list-type-cassa.
  buffer-copy locb-price-list-type-cassa to buf_price-list-type-cassa.
end.
/* ------------------------------- price-list-type-gds-grp ---------------------------------------------- */
for each buf_price-list-type-gds-grp where buf_price-list-type-gds-grp.plt-id     = wt-price-list-type.plt-id
                                  and buf_price-list-type-gds-grp.plt-db-num = wt-price-list-type.plt-db-num
on error  undo, return error
:
  delete buf_price-list-type-gds-grp.
end.

for each locb-price-list-type-gds-grp where locb-price-list-type-gds-grp.plt-id     = wt-price-list-type.plt-id
                                    and locb-price-list-type-gds-grp.plt-db-num = wt-price-list-type.plt-db-num
no-lock
on error  undo, return error
:
  create buf_price-list-type-gds-grp.
  buffer-copy locb-price-list-type-gds-grp to buf_price-list-type-gds-grp.
end.
/* ------------------------------- price-list-type-attr ---------------------------------------------- */
for each buf_price-list-type-attr where buf_price-list-type-attr.plt-id     = wt-price-list-type.plt-id
                                  and buf_price-list-type-attr.plt-db-num = wt-price-list-type.plt-db-num
on error  undo, return error
:
  delete buf_price-list-type-attr.
end.

for each locb-price-list-type-attr where locb-price-list-type-attr.plt-id     = wt-price-list-type.plt-id
                                    and locb-price-list-type-attr.plt-db-num = wt-price-list-type.plt-db-num
no-lock
on error  undo, return error
:
  create buf_price-list-type-attr.
  buffer-copy locb-price-list-type-attr to buf_price-list-type-attr.
end.
/* ------------------------------- price-list-type-cash-pay ---------------------------------------------- */
for each buf_price-list-type-cash-pay where buf_price-list-type-cash-pay.plt-id     = wt-price-list-type.plt-id
                                  and buf_price-list-type-cash-pay.plt-db-num = wt-price-list-type.plt-db-num
on error  undo, return error
:
  delete buf_price-list-type-cash-pay.
end.

for each locb-price-list-type-cash-pay where locb-price-list-type-cash-pay.plt-id     = wt-price-list-type.plt-id
                                    and locb-price-list-type-cash-pay.plt-db-num = wt-price-list-type.plt-db-num
no-lock
on error  undo, return error
:
  create buf_price-list-type-cash-pay.
  buffer-copy locb-price-list-type-cash-pay to buf_price-list-type-cash-pay.
end.

/* ------------------------------- price-list-type ---------------------------------------------- */
if not available tb-price-list-type then do:
  create tb-price-list-type.
end.
buffer-copy wt-price-list-type to tb-price-list-type.
run trg/bp_tpl.p (tb-price-list-type.plt-id ,tb-price-list-type.plt-db-num ) no-error.



/*------------------------- почиcтим за cобой ----------------------------------------------- */


for each locb-price-list-type-pay-type
on error  undo, return error
:
  delete locb-price-list-type-pay-type.
end.


for each locb-price-list-type-cassa
on error  undo, return error
:
  delete locb-price-list-type-cassa.
end.


for each locb-price-list-type-gds-grp
on error  undo, return error
:
  delete locb-price-list-type-gds-grp.
end.

for each locb-price-list-type-attr
on error  undo, return error
:
  delete locb-price-list-type-attr.
end.

for each locb-price-list-type-cash-pay
on error  undo, return error
:
  delete locb-price-list-type-cash-pay.
end.

/* $Workfile$ e n d */