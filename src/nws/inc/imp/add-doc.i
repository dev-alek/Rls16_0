/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$


Автор: Чернова Светлана Александровна
Дата создания: 01/11/08
Author: Svetlana Chernova
Creation date: 01/11/08
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
    when "add-line" then do:
      create locb-add-line.
      { nws/impl-nws.i "add-line" "locb-" }
    end.
    when "add-trn" then do:
      create locb-add-trn.
      { nws/impl-nws.i "add-trn" "locb-" }
    end.
    when "add-trn-attr" then do:
      create locb-add-trn-attr.
      { nws/impl-nws.i "add-trn-attr" "locb-" }
    end.
    when "doc-line-attr" then do:
      create locb-add-doc-line-attr.
      { nws/impl-nws.i "add-doc-line-attr" "locb-" }
    end.

    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе ДопРасх."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.


/* ------------------------------- add-line ---------------------------------------------- */
for each buf_add-line where
         buf_add-line.doc-code   = wt-add-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_add-line.
end.
for each locb-add-line where
         locb-add-line.doc-code = wt-add-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_add-line.
  buffer-copy locb-add-line to buf_add-line.
end.


/* ------------------------------- add-trn-attr ---------------------------------------------- */
for each buf_add-trn-attr where
         buf_add-trn-attr.doc-code   = wt-add-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_add-trn-attr.
end.
for each locb-add-trn-attr where
         locb-add-trn-attr.doc-code = wt-add-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_add-trn-attr.
  buffer-copy locb-add-trn-attr to buf_add-trn-attr.
end.
/* ------------------------------- doc-line-attr ---------------------------------------------- */
for each buf_doc-line-attr where
         buf_doc-line-attr.doc-code   = wt-add-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_doc-line-attr.
end.
for each locb-add-doc-line-attr where
         locb-add-doc-line-attr.doc-code = wt-add-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_doc-line-attr.
  buffer-copy locb-add-doc-line-attr to buf_doc-line-attr.
end.


/* ------------------------------- add-trn ---------------------------------------------- */
for each buf_add-trn where
         buf_add-trn.doc-code   = wt-add-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_add-trn.
end.
for each locb-add-trn where
         locb-add-trn.doc-code = wt-add-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_add-trn.
  buffer-copy locb-add-trn to buf_add-trn.
end.


/* ------------------------------- add-doc ---------------------------------------------- */
if not available tb-add-doc then do:
  create tb-add-doc.
end.

/* обновляем документ */
buffer-copy wt-add-doc to tb-add-doc.

/* -------------------- почистим за собой ------------------------ */

for each locb-add-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-add-line.
end.
for each locb-add-trn
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-add-trn.
end.
for each locb-add-trn-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-add-trn-attr.
end.
for each locb-add-doc-line-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-add-doc-line-attr.
end.

/* $Workfile$ */