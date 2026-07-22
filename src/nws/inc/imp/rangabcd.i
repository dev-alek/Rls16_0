/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

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
    when "rang-abc-def-obj" then do:
      create locb-rang-abc-def-obj.
      { nws/impl-nws.i "rang-abc-def-obj" "locb-" }
    end.

    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе abc-анализа."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

/* ------------------------------- rang-abc-def-obj ---------------------------------------------- */
for each buf_rang-abc-def-obj where
         buf_rang-abc-def-obj.raad-id   = wt-rang-abc-def.raad-id  and
         buf_rang-abc-def-obj.db-num    = wt-rang-abc-def.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_rang-abc-def-obj.
end.
for each locb-rang-abc-def-obj where
         locb-rang-abc-def-obj.raad-id = wt-rang-abc-def.raad-id and
         locb-rang-abc-def-obj.db-num  = wt-rang-abc-def.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_rang-abc-def-obj.
  buffer-copy locb-rang-abc-def-obj to buf_rang-abc-def-obj.
end.



/* ------------------------------- rang-abc-def ---------------------------------------------- */
if not available tb-rang-abc-def then do:
  create tb-rang-abc-def.
end.

/* обновляем документ */
buffer-copy wt-rang-abc-def to tb-rang-abc-def.

/* -------------------- почистим за собой ------------------------ */

for each locb-rang-abc-def-obj
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-rang-abc-def-obj.
end.


/* $Workfile$ */