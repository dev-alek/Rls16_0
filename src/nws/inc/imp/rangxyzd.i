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
    when "rang-xyz-def-obj" then do:
      create locb-rang-xyz-def-obj.
      { nws/impl-nws.i "rang-xyz-def-obj" "locb-" }
    end.

    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе xyz-анализа."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

/* ------------------------------- rang-xyz-def-obj ---------------------------------------------- */
for each buf_rang-xyz-def-obj where
         buf_rang-xyz-def-obj.raxd-id   = wt-rang-xyz-def.raxd-id  and
         buf_rang-xyz-def-obj.db-num    = wt-rang-xyz-def.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_rang-xyz-def-obj.
end.
for each locb-rang-xyz-def-obj where
         locb-rang-xyz-def-obj.raxd-id = wt-rang-xyz-def.raxd-id and
         locb-rang-xyz-def-obj.db-num  = wt-rang-xyz-def.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_rang-xyz-def-obj.
  buffer-copy locb-rang-xyz-def-obj to buf_rang-xyz-def-obj.
end.



/* ------------------------------- rang-xyz-def ---------------------------------------------- */
if not available tb-rang-xyz-def then do:
  create tb-rang-xyz-def.
end.

/* обновляем документ */
buffer-copy wt-rang-xyz-def to tb-rang-xyz-def.

/* -------------------- почистим за собой ------------------------ */

for each locb-rang-xyz-def-obj
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-rang-xyz-def-obj.
end.


/* $Workfile$ */