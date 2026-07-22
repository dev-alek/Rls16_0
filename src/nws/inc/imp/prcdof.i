/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

ДНЦ

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
    when "price-doc-forming-gds" then do:
      create locb-price-doc-forming-gds.
      { nws/impl-nws.i "price-doc-forming-gds" "locb-" }
    end.
    when "price-doc-forming-gds-qnty" then do:
      create locb-price-doc-forming-gds-qnty.
      { nws/impl-nws.i "price-doc-forming-gds-qnty" "locb-" }
    end.
    when "price-doc-forming-gds-sum" then do:
      create locb-price-doc-forming-gds-sum.
      { nws/impl-nws.i "price-doc-forming-gds-sum" "locb-" }
    end.
    when "price-doc-forming-attr" then do:
      create locb-price-doc-forming-attr.
      { nws/impl-nws.i "price-doc-forming-attr" "locb-" }
    end.
    when "price-doc-forming-gds-tnv" then do:
      create locb-price-doc-forming-gds-tnv.
      { nws/impl-nws.i "price-doc-forming-gds-tnv" "locb-" }
    end.
    otherwise do:
      message "Не предуcмотрен прием таблицы " rec-name skip
              "в cоcтаве куcта."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.



/* ------------------------------- price-doc-forming-gds ---------------------------------------------- */
for each buf_price-doc-forming-gds where buf_price-doc-forming-gds.plt-id     = wt-price-doc-forming.plt-id
                                   and buf_price-doc-forming-gds.plt-db-num = wt-price-doc-forming.plt-db-num
                                   and buf_price-doc-forming-gds.pdf-id     = wt-price-doc-forming.pdf-id
                                   and buf_price-doc-forming-gds.pdf-db     = wt-price-doc-forming.pdf-db

on error  undo, return error
:
  delete buf_price-doc-forming-gds.
end.

for each locb-price-doc-forming-gds where locb-price-doc-forming-gds.plt-id     = wt-price-doc-forming.plt-id
                                   and locb-price-doc-forming-gds.plt-db-num = wt-price-doc-forming.plt-db-num
                                   and locb-price-doc-forming-gds.pdf-id     = wt-price-doc-forming.pdf-id
                                   and locb-price-doc-forming-gds.pdf-db     = wt-price-doc-forming.pdf-db

no-lock
on error  undo, return error
:
  create buf_price-doc-forming-gds.
  buffer-copy locb-price-doc-forming-gds to buf_price-doc-forming-gds.
end.
/* ------------------------------- price-doc-forming-gds-qnty ---------------------------------------------- */
for each buf_price-doc-forming-gds-qnty where buf_price-doc-forming-gds-qnty.plt-id     = wt-price-doc-forming.plt-id
                                   and buf_price-doc-forming-gds-qnty.plt-db-num = wt-price-doc-forming.plt-db-num
                                   and buf_price-doc-forming-gds-qnty.pdf-id     = wt-price-doc-forming.pdf-id
                                   and buf_price-doc-forming-gds-qnty.pdf-db     = wt-price-doc-forming.pdf-db

on error  undo, return error
:
  delete buf_price-doc-forming-gds-qnty.
end.

for each locb-price-doc-forming-gds-qnty where locb-price-doc-forming-gds-qnty.plt-id     = wt-price-doc-forming.plt-id
                                    and locb-price-doc-forming-gds-qnty.plt-db-num = wt-price-doc-forming.plt-db-num
                                    and locb-price-doc-forming-gds-qnty.pdf-id     = wt-price-doc-forming.pdf-id
                                    and locb-price-doc-forming-gds-qnty.pdf-db     = wt-price-doc-forming.pdf-db

no-lock
on error  undo, return error
:
  create buf_price-doc-forming-gds-qnty.
  buffer-copy locb-price-doc-forming-gds-qnty to buf_price-doc-forming-gds-qnty.
end.
/* ------------------------------- price-doc-forming-gds-sum ---------------------------------------------- */
for each buf_price-doc-forming-gds-sum where buf_price-doc-forming-gds-sum.plt-id     = wt-price-doc-forming.plt-id
                                   and buf_price-doc-forming-gds-sum.plt-db-num = wt-price-doc-forming.plt-db-num
                                   and buf_price-doc-forming-gds-sum.pdf-id     = wt-price-doc-forming.pdf-id
                                   and buf_price-doc-forming-gds-sum.pdf-db     = wt-price-doc-forming.pdf-db

on error  undo, return error
:
  delete buf_price-doc-forming-gds-sum.
end.

for each locb-price-doc-forming-gds-sum where locb-price-doc-forming-gds-sum.plt-id     = wt-price-doc-forming.plt-id
                                    and locb-price-doc-forming-gds-sum.plt-db-num = wt-price-doc-forming.plt-db-num
                                    and locb-price-doc-forming-gds-sum.pdf-id     = wt-price-doc-forming.pdf-id
                                    and locb-price-doc-forming-gds-sum.pdf-db     = wt-price-doc-forming.pdf-db

no-lock
on error  undo, return error
:
  create buf_price-doc-forming-gds-sum.
  buffer-copy locb-price-doc-forming-gds-sum to buf_price-doc-forming-gds-sum.
end.

/* ------------------------------- price-doc-forming-attr ---------------------------------------------- */
for each buf_price-doc-forming-attr where buf_price-doc-forming-attr.plt-id     = wt-price-doc-forming.plt-id
                                   and buf_price-doc-forming-attr.plt-db-num = wt-price-doc-forming.plt-db-num
                                   and buf_price-doc-forming-attr.pdf-id     = wt-price-doc-forming.pdf-id
                                   and buf_price-doc-forming-attr.pdf-db     = wt-price-doc-forming.pdf-db

on error  undo, return error
:
  delete buf_price-doc-forming-attr.
end.

for each locb-price-doc-forming-attr where locb-price-doc-forming-attr.plt-id     = wt-price-doc-forming.plt-id
                                    and locb-price-doc-forming-attr.plt-db-num = wt-price-doc-forming.plt-db-num
                                    and locb-price-doc-forming-attr.pdf-id     = wt-price-doc-forming.pdf-id
                                    and locb-price-doc-forming-attr.pdf-db     = wt-price-doc-forming.pdf-db

no-lock
on error  undo, return error
:
  create buf_price-doc-forming-attr.
  buffer-copy locb-price-doc-forming-attr to buf_price-doc-forming-attr.
end.

/* ------------------------------- price-doc-forming-gds-tnv ---------------------------------------------- */
for each buf_price-doc-forming-gds-tnv where buf_price-doc-forming-gds-tnv.plt-id     = wt-price-doc-forming.plt-id
                                   and buf_price-doc-forming-gds-tnv.plt-db-num = wt-price-doc-forming.plt-db-num
                                   and buf_price-doc-forming-gds-tnv.pdf-id     = wt-price-doc-forming.pdf-id
                                   and buf_price-doc-forming-gds-tnv.pdf-db     = wt-price-doc-forming.pdf-db

on error  undo, return error
:
  delete buf_price-doc-forming-gds-tnv.
end.

for each locb-price-doc-forming-gds-tnv where locb-price-doc-forming-gds-tnv.plt-id     = wt-price-doc-forming.plt-id
                                    and locb-price-doc-forming-gds-tnv.plt-db-num = wt-price-doc-forming.plt-db-num
                                    and locb-price-doc-forming-gds-tnv.pdf-id     = wt-price-doc-forming.pdf-id
                                    and locb-price-doc-forming-gds-tnv.pdf-db     = wt-price-doc-forming.pdf-db

no-lock
on error  undo, return error
:
  create buf_price-doc-forming-gds-tnv.
  buffer-copy locb-price-doc-forming-gds-tnv to buf_price-doc-forming-gds-tnv.
end.

/* ------------------------------- price-doc-forming ---------------------------------------------- */
if not available tb-price-doc-forming then do:
  create tb-price-doc-forming.
end.
buffer-copy wt-price-doc-forming to tb-price-doc-forming.

/*------------------------- почиcтим за cобой ----------------------------------------------- */

for each locb-price-doc-forming-gds
on error  undo, return error
:
  delete locb-price-doc-forming-gds.
end.

for each locb-price-doc-forming-gds-qnty
on error  undo, return error
:
  delete locb-price-doc-forming-gds-qnty.
end.

for each locb-price-doc-forming-gds-sum
on error  undo, return error
:
  delete locb-price-doc-forming-gds-sum.
end.

for each locb-price-doc-forming-attr
on error  undo, return error
:
  delete locb-price-doc-forming-attr.
end.

for each locb-price-doc-forming-gds-tnv
on error  undo, return error
:
  delete locb-price-doc-forming-gds-tnv.
end.
release tb-price-doc-forming.
v-send-to-cash = no.
if g#db-num > 0 then do:
{ gbl/a-nwspdf.i
  wt-price-doc-forming.plt-id
  wt-price-doc-forming.plt-db-num
  wt-price-doc-forming.pdf-id
  wt-price-doc-forming.pdf-db
  v-send-to-cash
  no-error
}
end.
if v-send-to-cash then do:
  run fill-pdf in p-imp-handle ( input wt-price-doc-forming.plt-id
                                  ,input wt-price-doc-forming.plt-db-num
                                  ,input wt-price-doc-forming.pdf-id
                                  ,input wt-price-doc-forming.pdf-db
                                  ,input (if wt-price-doc-forming.STTS = integer({&pdf-delete}) then yes else no)
                                  ).
end.


/* $Workfile$ e n d */