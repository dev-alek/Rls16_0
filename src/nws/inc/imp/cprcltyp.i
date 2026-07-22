/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История Типы прайс-листов

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
    when "c-price-list-type-pay-type" then do:
      create locb-c-price-list-type-pay-type.
      { nws/impl-nws.i "c-price-list-type-pay-type" "locb-" }
    end.
    when "c-price-list-type-cassa" then do:
      create locb-c-price-list-type-cassa.
      { nws/impl-nws.i "c-price-list-type-cassa" "locb-" }
    end.
    when "c-price-list-type-gds-grp" then do:
      create locb-c-price-list-type-gds-grp.
      { nws/impl-nws.i "c-price-list-type-gds-grp" "locb-" }
    end.
    when "c-price-list-type-attr" then do:
      create locb-c-price-list-type-attr.
      { nws/impl-nws.i "c-price-list-type-attr" "locb-" }
    end.
    when "c-price-list-type-cash-pay" then do:
      create locb-c-price-list-type-cash-pay.
      { nws/impl-nws.i "c-price-list-type-cash-pay" "locb-" }
    end.


    otherwise do:
      message "Не предуcмотрен прием таблицы " rec-name skip
              "в cоcтаве куcта."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.


/* ------------------------------- c-price-list-type-pay-type ---------------------------------------------- */
for each buf_c-price-list-type-pay-type where buf_c-price-list-type-pay-type.plt-id     = wt-c-price-list-type.plt-id
                                  and buf_c-price-list-type-pay-type.plt-db-num = wt-c-price-list-type.plt-db-num
                                  and buf_c-price-list-type-pay-type.chip-num         = wt-c-price-list-type.chip-num
                                  and buf_c-price-list-type-pay-type.corr-user-db-num = wt-c-price-list-type.corr-user-db-num
on error  undo, return error
:
  delete buf_c-price-list-type-pay-type.
end.

for each locb-c-price-list-type-pay-type where locb-c-price-list-type-pay-type.plt-id = wt-c-price-list-type.plt-id
                                    and locb-c-price-list-type-pay-type.plt-db-num = wt-c-price-list-type.plt-db-num
                                    and locb-c-price-list-type-pay-type.chip-num         = wt-c-price-list-type.chip-num
                                    and locb-c-price-list-type-pay-type.corr-user-db-num = wt-c-price-list-type.corr-user-db-num

no-lock
on error  undo, return error
:
  create buf_c-price-list-type-pay-type.
  buffer-copy locb-c-price-list-type-pay-type to buf_c-price-list-type-pay-type.
end.

/* ------------------------------- c-price-list-type-cassa ---------------------------------------------- */
for each buf_c-price-list-type-cassa where buf_c-price-list-type-cassa.plt-id     = wt-c-price-list-type.plt-id
                                  and buf_c-price-list-type-cassa.plt-db-num = wt-c-price-list-type.plt-db-num
                                  and buf_c-price-list-type-cassa.chip-num         = wt-c-price-list-type.chip-num
                                  and buf_c-price-list-type-cassa.corr-user-db-num = wt-c-price-list-type.corr-user-db-num

on error  undo, return error
:
  delete buf_c-price-list-type-cassa.
end.

for each locb-c-price-list-type-cassa where locb-c-price-list-type-cassa.plt-id = wt-c-price-list-type.plt-id
                                    and locb-c-price-list-type-cassa.plt-db-num = wt-c-price-list-type.plt-db-num
                                    and locb-c-price-list-type-cassa.chip-num         = wt-c-price-list-type.chip-num
                                    and locb-c-price-list-type-cassa.corr-user-db-num = wt-c-price-list-type.corr-user-db-num

no-lock
on error  undo, return error
:
  create buf_c-price-list-type-cassa.
  buffer-copy locb-c-price-list-type-cassa to buf_c-price-list-type-cassa.
end.

/* ------------------------------- c-price-list-type-gds-grp ---------------------------------------------- */
for each buf_c-price-list-type-gds-grp where buf_c-price-list-type-gds-grp.plt-id     = wt-c-price-list-type.plt-id
                                  and buf_c-price-list-type-gds-grp.plt-db-num = wt-c-price-list-type.plt-db-num
                                  and buf_c-price-list-type-gds-grp.chip-num         = wt-c-price-list-type.chip-num
                                  and buf_c-price-list-type-gds-grp.corr-user-db-num = wt-c-price-list-type.corr-user-db-num

on error  undo, return error
:
  delete buf_c-price-list-type-gds-grp.
end.

for each locb-c-price-list-type-gds-grp where locb-c-price-list-type-gds-grp.plt-id = wt-c-price-list-type.plt-id
                                    and locb-c-price-list-type-gds-grp.plt-db-num = wt-c-price-list-type.plt-db-num
                                    and locb-c-price-list-type-gds-grp.chip-num         = wt-c-price-list-type.chip-num
                                    and locb-c-price-list-type-gds-grp.corr-user-db-num = wt-c-price-list-type.corr-user-db-num

no-lock
on error  undo, return error
:
  create buf_c-price-list-type-gds-grp.
  buffer-copy locb-c-price-list-type-gds-grp to buf_c-price-list-type-gds-grp.
end.
/* ------------------------------- c-price-list-type-attr ---------------------------------------------- */
for each buf_c-price-list-type-attr where buf_c-price-list-type-attr.plt-id     = wt-c-price-list-type.plt-id
                                  and buf_c-price-list-type-attr.plt-db-num = wt-c-price-list-type.plt-db-num
                                  and buf_c-price-list-type-attr.chip-num         = wt-c-price-list-type.chip-num
                                  and buf_c-price-list-type-attr.corr-user-db-num = wt-c-price-list-type.corr-user-db-num

on error  undo, return error
:
  delete buf_c-price-list-type-attr.
end.

for each locb-c-price-list-type-attr where locb-c-price-list-type-attr.plt-id = wt-c-price-list-type.plt-id
                                    and locb-c-price-list-type-attr.plt-db-num = wt-c-price-list-type.plt-db-num
                                    and locb-c-price-list-type-attr.chip-num         = wt-c-price-list-type.chip-num
                                    and locb-c-price-list-type-attr.corr-user-db-num = wt-c-price-list-type.corr-user-db-num

no-lock
on error  undo, return error
:
  create buf_c-price-list-type-attr.
  buffer-copy locb-c-price-list-type-attr to buf_c-price-list-type-attr.
end.
/* ------------------------------- c-price-list-type-cash-pay ---------------------------------------------- */
for each buf_c-price-list-type-cash-pay where buf_c-price-list-type-cash-pay.plt-id     = wt-c-price-list-type.plt-id
                                  and buf_c-price-list-type-cash-pay.plt-db-num = wt-c-price-list-type.plt-db-num
                                  and buf_c-price-list-type-cash-pay.chip-num         = wt-c-price-list-type.chip-num
                                  and buf_c-price-list-type-cash-pay.corr-user-db-num = wt-c-price-list-type.corr-user-db-num

on error  undo, return error
:
  delete buf_c-price-list-type-cash-pay.
end.

for each locb-c-price-list-type-cash-pay where locb-c-price-list-type-cash-pay.plt-id = wt-c-price-list-type.plt-id
                                    and locb-c-price-list-type-cash-pay.plt-db-num = wt-c-price-list-type.plt-db-num
                                    and locb-c-price-list-type-cash-pay.chip-num         = wt-c-price-list-type.chip-num
                                    and locb-c-price-list-type-cash-pay.corr-user-db-num = wt-c-price-list-type.corr-user-db-num

no-lock
on error  undo, return error
:
  create buf_c-price-list-type-cash-pay.
  buffer-copy locb-c-price-list-type-cash-pay to buf_c-price-list-type-cash-pay.
end.



/* ------------------------------- c-price-list-type ---------------------------------------------- */
if not available tb-c-price-list-type then do:
  create tb-c-price-list-type.
end.
buffer-copy wt-c-price-list-type to tb-c-price-list-type.

/*------------------------- почиcтим за cобой ----------------------------------------------- */



for each locb-c-price-list-type-pay-type
on error  undo, return error
:
  delete locb-c-price-list-type-pay-type.
end.

for each locb-c-price-list-type-cassa
on error  undo, return error
:
  delete locb-c-price-list-type-cassa.
end.

for each locb-c-price-list-type-gds-grp
on error  undo, return error
:
  delete locb-c-price-list-type-gds-grp.
end.

for each locb-c-price-list-type-attr
on error  undo, return error
:
  delete locb-c-price-list-type-attr.
end.

for each locb-c-price-list-type-cash-pay
on error  undo, return error
:
  delete locb-c-price-list-type-cash-pay.
end.

/* $Workfile$ e n d */