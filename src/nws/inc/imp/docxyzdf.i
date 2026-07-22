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
    when "doc-xyz-def-obj" then do:
      create locb-doc-xyz-def-obj.
      { nws/impl-nws.i "doc-xyz-def-obj" "locb-" }
    end.

    when "doc-xyz-def-doc" then do:
      create locb-doc-xyz-def-doc.
      { nws/impl-nws.i "doc-xyz-def-doc" "locb-" }
    end.

    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе xyz-анализа."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

/* ------------------------------- doc-xyz-def-obj ---------------------------------------------- */
for each buf_doc-xyz-def-obj where
         buf_doc-xyz-def-obj.doxd-id   = wt-doc-xyz-def.doxd-id  and
         buf_doc-xyz-def-obj.db-num    = wt-doc-xyz-def.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_doc-xyz-def-obj.
end.
for each locb-doc-xyz-def-obj where
         locb-doc-xyz-def-obj.doxd-id = wt-doc-xyz-def.doxd-id and
         locb-doc-xyz-def-obj.db-num  = wt-doc-xyz-def.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_doc-xyz-def-obj.
  buffer-copy locb-doc-xyz-def-obj to buf_doc-xyz-def-obj.
end.

/* ------------------------------- doc-xyz-def-doc ---------------------------------------------- */
for each buf_doc-xyz-def-doc where
         buf_doc-xyz-def-doc.doxd-id   = wt-doc-xyz-def.doxd-id  and
         buf_doc-xyz-def-doc.db-num    = wt-doc-xyz-def.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_doc-xyz-def-doc.
end.
for each locb-doc-xyz-def-doc where
         locb-doc-xyz-def-doc.doxd-id = wt-doc-xyz-def.doxd-id and
         locb-doc-xyz-def-doc.db-num  = wt-doc-xyz-def.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_doc-xyz-def-doc.
  buffer-copy locb-doc-xyz-def-doc to buf_doc-xyz-def-doc.
end.



/* ------------------------------- doc-xyz-def ---------------------------------------------- */
if not available tb-doc-xyz-def then do:
  create tb-doc-xyz-def.
end.

/* обновляем документ */
buffer-copy wt-doc-xyz-def to tb-doc-xyz-def.

/* -------------------- почистим за собой ------------------------ */

for each locb-doc-xyz-def-obj
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-doc-xyz-def-obj.
end.
for each locb-doc-xyz-def-doc
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-doc-xyz-def-doc.
end.


/* $Workfile$ */