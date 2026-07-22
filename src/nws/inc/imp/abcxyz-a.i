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
    when "abcx-analysis-attr" then do:
      create locb-abcxyz-analysis-attr.
      { nws/impl-nws.i "abcxyz-analysis-attr" "locb-" }
    end.
    when "abcxyz-analysis-goods" then do:
      create locb-abcxyz-analysis-goods.
      { nws/impl-nws.i "abcxyz-analysis-goods" "locb-" }
    end.
    when "abcxyz-analysis-goods-attr" then do:
      create locb-abcxyz-analysis-goods-attr.
      { nws/impl-nws.i "abcxyz-analysis-goods-attr" "locb-" }
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе abcx-анализа."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.


/* ------------------------------- abcxyz-analysis-attr ---------------------------------------------- */
for each buf_abcxyz-analysis-attr where
         buf_abcxyz-analysis-attr.abcx-id   = wt-abcxyz-analysis.abcx-id  and
         buf_abcxyz-analysis-attr.db-num   = wt-abcxyz-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_abcxyz-analysis-attr.
end.
for each locb-abcxyz-analysis-attr where
         locb-abcxyz-analysis-attr.abcx-id = wt-abcxyz-analysis.abcx-id and
         locb-abcxyz-analysis-attr.db-num  = wt-abcxyz-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_abcxyz-analysis-attr.
  buffer-copy locb-abcxyz-analysis-attr to buf_abcxyz-analysis-attr.
end.


/* ------------------------------- abcxyz-analysis-goods-attr ---------------------------------------------- */
for each buf_abcxyz-analysis-goods-attr where
         buf_abcxyz-analysis-goods-attr.abcx-id   = wt-abcxyz-analysis.abcx-id  and
         buf_abcxyz-analysis-goods-attr.db-num   = wt-abcxyz-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_abcxyz-analysis-goods-attr.
end.
for each locb-abcxyz-analysis-goods-attr where
         locb-abcxyz-analysis-goods-attr.abcx-id = wt-abcxyz-analysis.abcx-id and
         locb-abcxyz-analysis-goods-attr.db-num  = wt-abcxyz-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_abcxyz-analysis-goods-attr.
  buffer-copy locb-abcxyz-analysis-goods-attr to buf_abcxyz-analysis-goods-attr.
end.

/* ------------------------------- abcxyz-analysis-goods ---------------------------------------------- */
for each buf_abcxyz-analysis-goods where
         buf_abcxyz-analysis-goods.abcx-id   = wt-abcxyz-analysis.abcx-id  and
         buf_abcxyz-analysis-goods.db-num   = wt-abcxyz-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_abcxyz-analysis-goods.
end.
for each locb-abcxyz-analysis-goods where
         locb-abcxyz-analysis-goods.abcx-id = wt-abcxyz-analysis.abcx-id and
         locb-abcxyz-analysis-goods.db-num  = wt-abcxyz-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_abcxyz-analysis-goods.
  buffer-copy locb-abcxyz-analysis-goods to buf_abcxyz-analysis-goods.
end.


/* ------------------------------- abcxyz-analysis ---------------------------------------------- */
if not available tb-abcxyz-analysis then do:
  create tb-abcxyz-analysis.
end.

/* обновляем документ */
buffer-copy wt-abcxyz-analysis to tb-abcxyz-analysis.

/* -------------------- почистим за собой ------------------------ */

for each locb-abcxyz-analysis-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abcxyz-analysis-attr.
end.
for each locb-abcxyz-analysis-goods
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abcxyz-analysis-goods.
end.
for each locb-abcxyz-analysis-goods-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abcxyz-analysis-goods-attr.
end.

/* $Workfile$ */