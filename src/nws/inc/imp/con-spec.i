/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Спецификаци

Автор: Чернова Светлана Александровна
Дата создания: 05/25/09
Author: Svetlana Chernova
Creation date: 05/25/09

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
    when "contract-specif-attr" then do:
      create locb-contract-specif-attr.
      { nws/impl-nws.i "contract-specif-attr" "locb-" }
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip "в составе договора." view-as alert-box error.
      return error.
    end.
  END CASE.
end.

/* ------------------------------- contract-specif-attr ---------------------------------------------- */
for each buf_contract-specif-attr
  where buf_contract-specif-attr.contract-num = wt-contract-specif.contract-num
    and buf_contract-specif-attr.host-code    = wt-contract-specif.host-code
    and buf_contract-specif-attr.gds-code     = wt-contract-specif.gds-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete buf_contract-specif-attr.
end.
for each locb-contract-specif-attr no-lock
  where locb-contract-specif-attr.contract-num = wt-contract-specif.contract-num
    and locb-contract-specif-attr.host-code    = wt-contract-specif.host-code
    and locb-contract-specif-attr.gds-code     = wt-contract-specif.gds-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  create buf_contract-specif-attr.
  buffer-copy locb-contract-specif-attr to buf_contract-specif-attr.
end.

/* ------------------------------- contract-specif ---------------------------------------------- */
if not available tb-contract-specif then do:
  create tb-contract-specif.
end.

/* обновляем документ */
buffer-copy wt-contract-specif to tb-contract-specif.

/* -------------------- почистим за собой ------------------------ */
for each locb-contract-specif-attr
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete locb-contract-specif-attr.
end.


/* $Workfile$ */