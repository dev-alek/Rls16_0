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

Дата создания: 08/04/05
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
    when "doc-abc-def-obj" then do:
      create locb-doc-abc-def-obj.
      { nws/impl-nws.i "doc-abc-def-obj" "locb-" }
    end.
    when "doc-abc-def-doc" then do:
      create locb-doc-abc-def-doc.
      { nws/impl-nws.i "doc-abc-def-doc" "locb-" }
    end.

    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе abc-анализа."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

/* ------------------------------- doc-abc-def-obj ---------------------------------------------- */
for each buf_doc-abc-def-obj where
         buf_doc-abc-def-obj.doad-id   = wt-doc-abc-def.doad-id  and
         buf_doc-abc-def-obj.db-num    = wt-doc-abc-def.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_doc-abc-def-obj.
end.
for each locb-doc-abc-def-obj where
         locb-doc-abc-def-obj.doad-id = wt-doc-abc-def.doad-id and
         locb-doc-abc-def-obj.db-num  = wt-doc-abc-def.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_doc-abc-def-obj.
  buffer-copy locb-doc-abc-def-obj to buf_doc-abc-def-obj.
end.

/* ------------------------------- doc-abc-def-doc ---------------------------------------------- */
for each buf_doc-abc-def-doc where
         buf_doc-abc-def-doc.doad-id   = wt-doc-abc-def.doad-id  and
         buf_doc-abc-def-doc.db-num    = wt-doc-abc-def.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_doc-abc-def-doc.
end.
for each locb-doc-abc-def-doc where
         locb-doc-abc-def-doc.doad-id = wt-doc-abc-def.doad-id and
         locb-doc-abc-def-doc.db-num  = wt-doc-abc-def.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_doc-abc-def-doc.
  buffer-copy locb-doc-abc-def-doc to buf_doc-abc-def-doc.
end.



/* ------------------------------- doc-abc-def ---------------------------------------------- */
if not available tb-doc-abc-def then do:
  create tb-doc-abc-def.
end.

/* обновляем документ */
buffer-copy wt-doc-abc-def to tb-doc-abc-def.

/* -------------------- почистим за собой ------------------------ */

for each locb-doc-abc-def-obj
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-doc-abc-def-obj.
end.
for each locb-doc-abc-def-doc
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-doc-abc-def-doc.
end.


/* $Workfile$ */