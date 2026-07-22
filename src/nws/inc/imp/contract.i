/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/24/06
Author: Michael Kochetkov
Creation date: 03/24/06

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
    when "contract-line" then do:
      create locb-contract-line.
      { nws/impl-nws.i "contract-line" "locb-" }
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip "в составе договора." view-as alert-box error.
      return error.
    end.
  END CASE.
end.

/* ------------------------------- contract-line ---------------------------------------------- */
for each buf_contract-line where buf_contract-line.contract-num = wt-contract.contract-code and
                              buf_contract-line.host-code = wt-contract.host-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_contract-line.
end.
for each locb-contract-line where locb-contract-line.contract-num = wt-contract.contract-code and
                               locb-contract-line.host-code = wt-contract.host-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_contract-line.
  buffer-copy locb-contract-line to buf_contract-line.
end.

/* ------------------------------- contract ---------------------------------------------- */
if not available tb-contract then do:
  create tb-contract.
end.

/* обновляем документ */
buffer-copy wt-contract to tb-contract.

/* -------------------- почистим за собой ------------------------ */
for each locb-contract-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-contract-line.
end.


/* $Workfile$ */