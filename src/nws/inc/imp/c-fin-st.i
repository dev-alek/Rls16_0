/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Прием истории банковских выписок в новостях

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/20/06
Author: Bakhtadze Natalya
Creation date: 03/20/06

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
    when "c-fin-statement-line" then do:
      create locb-c-fin-statement-line.
      { nws/impl-nws.i "c-fin-statement-line" "locb-" }
    end.
    when "c-fin-statement-attr" then do:
      create locb-c-fin-statement-attr.
      { nws/impl-nws.i "c-fin-statement-attr" "locb-" }
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе совокупных выписок."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

/* ------------------------------- c-fin-statement-line ---------------------------------------------- */
for each buf_c-fin-statement-line where buf_c-fin-statement-line.sttm-code = wt-c-fin-statement.sttm-code and
                              buf_c-fin-statement-line.host-code = wt-c-fin-statement.host-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-fin-statement-line.
end.
for each locb-c-fin-statement-line where locb-c-fin-statement-line.sttm-code = wt-c-fin-statement.sttm-code and
                               locb-c-fin-statement-line.host-code = wt-c-fin-statement.host-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-fin-statement-line.
  buffer-copy locb-c-fin-statement-line to buf_c-fin-statement-line.
end.

/* ------------------------------- c-fin-statement-attr ---------------------------------------------- */
for each buf_c-fin-statement-attr where buf_c-fin-statement-attr.sttm-code = wt-c-fin-statement.sttm-code and
                              buf_c-fin-statement-attr.host-code = wt-c-fin-statement.host-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-fin-statement-attr.
end.
for each locb-c-fin-statement-attr where locb-c-fin-statement-attr.sttm-code = wt-c-fin-statement.sttm-code and
                               locb-c-fin-statement-attr.host-code = wt-c-fin-statement.host-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-fin-statement-attr.
  buffer-copy locb-c-fin-statement-attr to buf_c-fin-statement-attr.
end.



/* ------------------------------- c-fin-statement ---------------------------------------------- */
if not available tb-c-fin-statement then do:
  create tb-c-fin-statement.
end.

/* обновляем документ */
buffer-copy wt-c-fin-statement to tb-c-fin-statement.

/* -------------------- почистим за собой ------------------------ */
for each locb-c-fin-statement-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-fin-statement-line.
end.

for each locb-c-fin-statement-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-fin-statement-attr.
end.


/* $Workfile$ */