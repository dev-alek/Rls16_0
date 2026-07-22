/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Прием рутов для ВС через новости

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/22/08
Author: Bakhtadze Natalya
Creation date: 02/22/08

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
    when "esys-route-dump" then do:
      create locb-esys-route-dump.
      { nws/impl-nws.i "esys-route-dump" "locb-" }
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе истории чека МЦ"
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.


if not available tb-esys-route then do:
  create tb-esys-route.
end.


/* обновляем роуты ВС */
buffer-copy wt-esys-route to tb-esys-route.

/* ------------------------------- esys-route-dump --------------------------------------------- */
for each buf_esys-route-dump where
        buf_esys-route-dump.esrd-dump-ord = wt-esys-route.esr-dump-ord
    AND buf_esys-route-dump.esrd-cr-db-num = wt-esys-route.esr-cr-db-num
on error  undo, return error
:
  delete buf_esys-route-dump.
end.
for each locb-esys-route-dump where
        locb-esys-route-dump.esrd-dump-ord = wt-esys-route.esr-dump-ord
    AND locb-esys-route-dump.esrd-cr-db-num = wt-esys-route.esr-cr-db-num
    no-lock
on error  undo, return error
:
  create buf_esys-route-dump.
  buffer-copy locb-esys-route-dump to buf_esys-route-dump.
end.

/* ------------------------ почистим за собой ---------------------------------------------- */

for each locb-esys-route-dump
on error  undo, return error
:
  delete locb-esys-route-dump.
end.

/* $Workfile$ e n d */