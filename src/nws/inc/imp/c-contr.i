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
    when "c-contract-line" then do:
      create locb-c-contract-line.
      { nws/impl-nws.i "c-contract-line" "locb-" }
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе истории договора."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

/* ------------------------------- contract-line ---------------------------------------------- */
for each buf_c-contract-line where buf_c-contract-line.contract-num = wt-c-contract.contract-code and
                              buf_c-contract-line.host-code = wt-c-contract.host-code  and
                              buf_c-contract-line.corr-user-db-num  = wt-c-contract.corr-user-db-num  and
                              buf_c-contract-line.chip-num  = wt-c-contract.chip-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-contract-line.
end.
for each locb-c-contract-line where locb-c-contract-line.contract-num = wt-c-contract.contract-code and
                               locb-c-contract-line.host-code = wt-c-contract.host-code  and
                               locb-c-contract-line.corr-user-db-num  = wt-c-contract.corr-user-db-num  and
                               locb-c-contract-line.chip-num = wt-c-contract.chip-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-contract-line.
  buffer-copy locb-c-contract-line to buf_c-contract-line.
end.

/* ------------------------------- contract ---------------------------------------------- */
if not available tb-c-contract then do:
  create tb-c-contract.
end.

/* обновляем документ */
buffer-copy wt-c-contract to tb-c-contract.

/* -------------------- почистим за собой ------------------------ */
for each locb-c-contract-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-contract-line.
end.


/* $Workfile$ */