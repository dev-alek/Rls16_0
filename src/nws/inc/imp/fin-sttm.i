/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Приема в новостях банковских выписок

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

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
    when "fin-statement-line" then do:
      create locb-fin-statement-line.
      { nws/impl-nws.i "fin-statement-line" "locb-" }
    end.
    when "fin-statement-attr" then do:
      create locb-fin-statement-attr.
      { nws/impl-nws.i "fin-statement-attr" "locb-" }
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе совокупных выписок."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

/* ------------------------------- fin-statement-tax ---------------------------------------------- */
for each buf_fin-statement-line where buf_fin-statement-line.sttm-code = wt-fin-statement.sttm-code and
                              buf_fin-statement-line.host-code = wt-fin-statement.host-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_fin-statement-line.
end.
for each locb-fin-statement-line where locb-fin-statement-line.sttm-code = wt-fin-statement.sttm-code and
                               locb-fin-statement-line.host-code = wt-fin-statement.host-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_fin-statement-line.
  buffer-copy locb-fin-statement-line to buf_fin-statement-line.
end.

/* ------------------------------- fin-statement-attr ---------------------------------------------- */
for each buf_fin-statement-attr where buf_fin-statement-attr.sttm-code = wt-fin-statement.sttm-code and
                              buf_fin-statement-attr.host-code = wt-fin-statement.host-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_fin-statement-attr.
end.
for each locb-fin-statement-attr where locb-fin-statement-attr.sttm-code = wt-fin-statement.sttm-code and
                               locb-fin-statement-attr.host-code = wt-fin-statement.host-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_fin-statement-attr.
  buffer-copy locb-fin-statement-attr to buf_fin-statement-attr.
end.



/* ------------------------------- fin-statement ---------------------------------------------- */
if not available tb-fin-statement then do:
  create tb-fin-statement.
end.

/* обновляем документ */
buffer-copy wt-fin-statement to tb-fin-statement.

/* -------------------- почистим за собой ------------------------ */
for each locb-fin-statement-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-fin-statement-line.
end.

for each locb-fin-statement-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-fin-statement-attr.
end.


/* $Workfile$ */