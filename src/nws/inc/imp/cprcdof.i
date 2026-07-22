/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История ДНЦ

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
    when "c-price-doc-forming-gds" then do:
      create locb-c-price-doc-forming-gds.
      { nws/impl-nws.i "c-price-doc-forming-gds" "locb-" }
    end.
    when "c-price-doc-forming-gds-qnty" then do:
      create lb-c-price-doc-forming-gds-qnty.
      { nws/impl-nws.i "c-price-doc-forming-gds-qnty" "lb-" }
    end.
    when "c-price-doc-forming-gds-sum" then do:
      create locb-c-price-doc-forming-gds-sum.
      { nws/impl-nws.i "c-price-doc-forming-gds-sum" "locb-" }
    end.
    when "c-price-doc-forming-attr" then do:
      create locb-c-price-doc-forming-attr.
      { nws/impl-nws.i "c-price-doc-forming-attr" "locb-" }
    end.
    when "c-price-doc-forming-gds-tnv" then do:
      create locb-c-price-doc-forming-gds-tnv.
      { nws/impl-nws.i "c-price-doc-forming-gds-tnv" "locb-" }
    end.
    otherwise do:
      message "Не предуcмотрен прием таблицы " rec-name skip
              "в cоcтаве куcта."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.


/* ------------------------------- c-price-doc-forming-gds ---------------------------------------------- */
for each buf_c-price-doc-forming-gds where buf_c-price-doc-forming-gds.plt-id     = wt-c-price-doc-forming.plt-id
                                   and buf_c-price-doc-forming-gds.chip-num         = wt-c-price-doc-forming.chip-num
                                   and buf_c-price-doc-forming-gds.corr-user-db-num = wt-c-price-doc-forming.corr-user-db-num
                                   and buf_c-price-doc-forming-gds.plt-db-num = wt-c-price-doc-forming.plt-db-num
                                   and buf_c-price-doc-forming-gds.pdf-id     = wt-c-price-doc-forming.pdf-id
                                   and buf_c-price-doc-forming-gds.pdf-db     = wt-c-price-doc-forming.pdf-db

on error  undo, return error
:
  delete buf_c-price-doc-forming-gds.
end.

for each locb-c-price-doc-forming-gds where locb-c-price-doc-forming-gds.plt-id = wt-c-price-doc-forming.plt-id
                                    and locb-c-price-doc-forming-gds.plt-db-num = wt-c-price-doc-forming.plt-db-num
                                    and locb-c-price-doc-forming-gds.pdf-id     = wt-c-price-doc-forming.pdf-id
                                    and locb-c-price-doc-forming-gds.pdf-db     = wt-c-price-doc-forming.pdf-db
                                    and locb-c-price-doc-forming-gds.chip-num         = wt-c-price-doc-forming.chip-num
                                    and locb-c-price-doc-forming-gds.corr-user-db-num = wt-c-price-doc-forming.corr-user-db-num


no-lock
on error  undo, return error
:
  create buf_c-price-doc-forming-gds.
  buffer-copy locb-c-price-doc-forming-gds to buf_c-price-doc-forming-gds.
end.

/* ------------------------------- c-price-doc-forming-gds-qnty ---------------------------------------------- */
for each buf_c-price-doc-forming-gds-qnty where buf_c-price-doc-forming-gds-qnty.plt-id     = wt-c-price-doc-forming.plt-id
                                   and buf_c-price-doc-forming-gds-qnty.plt-db-num = wt-c-price-doc-forming.plt-db-num
                                   and buf_c-price-doc-forming-gds-qnty.pdf-id     = wt-c-price-doc-forming.pdf-id
                                   and buf_c-price-doc-forming-gds-qnty.pdf-db     = wt-c-price-doc-forming.pdf-db
                                   and buf_c-price-doc-forming-gds-qnty.chip-num         = wt-c-price-doc-forming.chip-num
                                   and buf_c-price-doc-forming-gds-qnty.corr-user-db-num = wt-c-price-doc-forming.corr-user-db-num


on error  undo, return error
:
  delete buf_c-price-doc-forming-gds-qnty.
end.

for each lb-c-price-doc-forming-gds-qnty where lb-c-price-doc-forming-gds-qnty.plt-id = wt-c-price-doc-forming.plt-id
                                   and lb-c-price-doc-forming-gds-qnty.plt-db-num = wt-c-price-doc-forming.plt-db-num
                                   and lb-c-price-doc-forming-gds-qnty.pdf-id     = wt-c-price-doc-forming.pdf-id
                                   and lb-c-price-doc-forming-gds-qnty.pdf-db     = wt-c-price-doc-forming.pdf-db
                                   and lb-c-price-doc-forming-gds-qnty.chip-num         = wt-c-price-doc-forming.chip-num
                                   and lb-c-price-doc-forming-gds-qnty.corr-user-db-num = wt-c-price-doc-forming.corr-user-db-num


no-lock
on error  undo, return error
:
  create buf_c-price-doc-forming-gds-qnty.
  buffer-copy lb-c-price-doc-forming-gds-qnty to buf_c-price-doc-forming-gds-qnty.
end.

/* ------------------------------- c-price-doc-forming-gds-sum ---------------------------------------------- */
for each buf_c-price-doc-forming-gds-sum where
                                       buf_c-price-doc-forming-gds-sum.plt-id     = wt-c-price-doc-forming.plt-id
                                   and buf_c-price-doc-forming-gds-sum.plt-db-num = wt-c-price-doc-forming.plt-db-num
                                   and buf_c-price-doc-forming-gds-sum.pdf-id     = wt-c-price-doc-forming.pdf-id
                                   and buf_c-price-doc-forming-gds-sum.pdf-db     = wt-c-price-doc-forming.pdf-db
                                   and buf_c-price-doc-forming-gds-sum.chip-num         = wt-c-price-doc-forming.chip-num
                                   and buf_c-price-doc-forming-gds-sum.corr-user-db-num = wt-c-price-doc-forming.corr-user-db-num


on error  undo, return error
:
  delete buf_c-price-doc-forming-gds-sum.
end.

for each locb-c-price-doc-forming-gds-sum where locb-c-price-doc-forming-gds-sum.plt-id = wt-c-price-doc-forming.plt-id
                                    and locb-c-price-doc-forming-gds-sum.plt-db-num = wt-c-price-doc-forming.plt-db-num
                                    and locb-c-price-doc-forming-gds-sum.pdf-id     = wt-c-price-doc-forming.pdf-id
                                    and locb-c-price-doc-forming-gds-sum.pdf-db     = wt-c-price-doc-forming.pdf-db
                                    and locb-c-price-doc-forming-gds-sum.chip-num         = wt-c-price-doc-forming.chip-num
                                    and locb-c-price-doc-forming-gds-sum.corr-user-db-num = wt-c-price-doc-forming.corr-user-db-num
no-lock
on error  undo, return error
:
  create buf_c-price-doc-forming-gds-sum.
  buffer-copy locb-c-price-doc-forming-gds-sum to buf_c-price-doc-forming-gds-sum.
end.

/* ------------------------------- c-price-doc-forming-attr ---------------------------------------------- */
for each buf_c-price-doc-forming-attr where buf_c-price-doc-forming-attr.plt-id     = wt-c-price-doc-forming.plt-id
                                  and buf_c-price-doc-forming-attr.plt-db-num = wt-c-price-doc-forming.plt-db-num
                                  and buf_c-price-doc-forming-attr.pdf-id     = wt-c-price-doc-forming.pdf-id
                                  and buf_c-price-doc-forming-attr.pdf-db     = wt-c-price-doc-forming.pdf-db
                                  and buf_c-price-doc-forming-attr.chip-num         = wt-c-price-doc-forming.chip-num
                                  and buf_c-price-doc-forming-attr.corr-user-db-num = wt-c-price-doc-forming.corr-user-db-num

on error  undo, return error
:
  delete buf_c-price-doc-forming-attr.
end.

for each locb-c-price-doc-forming-attr where locb-c-price-doc-forming-attr.plt-id = wt-c-price-doc-forming.plt-id
                                    and locb-c-price-doc-forming-attr.plt-db-num = wt-c-price-doc-forming.plt-db-num
                                    and locb-c-price-doc-forming-attr.pdf-id     = wt-c-price-doc-forming.pdf-id
                                    and locb-c-price-doc-forming-attr.pdf-db     = wt-c-price-doc-forming.pdf-db
                                    and locb-c-price-doc-forming-attr.chip-num         = wt-c-price-doc-forming.chip-num
                                    and locb-c-price-doc-forming-attr.corr-user-db-num = wt-c-price-doc-forming.corr-user-db-num

no-lock
on error  undo, return error
:
  create buf_c-price-doc-forming-attr.
  buffer-copy locb-c-price-doc-forming-attr to buf_c-price-doc-forming-attr.
end.

/* ------------------------------- c-price-doc-forming-gds-tnv ---------------------------------------------- */
for each buf_c-price-doc-forming-gds-tnv where buf_c-price-doc-forming-gds-tnv.plt-id = wt-c-price-doc-forming.plt-id
                                      and buf_c-price-doc-forming-gds-tnv.plt-db-num = wt-c-price-doc-forming.plt-db-num
                                      and buf_c-price-doc-forming-gds-tnv.pdf-id     = wt-c-price-doc-forming.pdf-id
                                      and buf_c-price-doc-forming-gds-tnv.pdf-db     = wt-c-price-doc-forming.pdf-db
                                      and buf_c-price-doc-forming-gds-tnv.chip-num         = wt-c-price-doc-forming.chip-num
                                      and buf_c-price-doc-forming-gds-tnv.corr-user-db-num = wt-c-price-doc-forming.corr-user-db-num


on error  undo, return error
:
  delete buf_c-price-doc-forming-gds-tnv.
end.

for each locb-c-price-doc-forming-gds-tnv where locb-c-price-doc-forming-gds-tnv.plt-id = wt-c-price-doc-forming.plt-id
                                    and locb-c-price-doc-forming-gds-tnv.plt-db-num = wt-c-price-doc-forming.plt-db-num
                                    and locb-c-price-doc-forming-gds-tnv.pdf-id     = wt-c-price-doc-forming.pdf-id
                                    and locb-c-price-doc-forming-gds-tnv.pdf-db     = wt-c-price-doc-forming.pdf-db
                                    and locb-c-price-doc-forming-gds-tnv.chip-num         = wt-c-price-doc-forming.chip-num
                                    and locb-c-price-doc-forming-gds-tnv.corr-user-db-num = wt-c-price-doc-forming.corr-user-db-num

no-lock
on error  undo, return error
:
  create buf_c-price-doc-forming-gds-tnv.
  buffer-copy locb-c-price-doc-forming-gds-tnv to buf_c-price-doc-forming-gds-tnv.
end.

/* ------------------------------- c-price-doc-forming ---------------------------------------------- */
if not available tb-c-price-doc-forming then do:
  create tb-c-price-doc-forming.
end.
buffer-copy wt-c-price-doc-forming to tb-c-price-doc-forming.

/*------------------------- почиcтим за cобой ----------------------------------------------- */

for each locb-c-price-doc-forming-gds
on error  undo, return error
:
  delete locb-c-price-doc-forming-gds.
end.

for each lb-c-price-doc-forming-gds-qnty
on error  undo, return error
:
  delete lb-c-price-doc-forming-gds-qnty.
end.

for each locb-c-price-doc-forming-gds-sum
on error  undo, return error
:
  delete locb-c-price-doc-forming-gds-sum.
end.

for each locb-c-price-doc-forming-attr
on error  undo, return error
:
  delete locb-c-price-doc-forming-attr.
end.

for each locb-c-price-doc-forming-gds-tnv
on error  undo, return error
:
  delete locb-c-price-doc-forming-gds-tnv.
end.
/* $Workfile$ e n d */