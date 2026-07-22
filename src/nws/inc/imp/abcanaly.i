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
    when "abc-analysis-obj" then do:
      create locb-abc-analysis-obj.
      { nws/impl-nws.i "abc-analysis-obj" "locb-" }
    end.
    when "abc-analysis-doc" then do:
      create locb-abc-analysis-doc.
      { nws/impl-nws.i "abc-analysis-doc" "locb-" }
    end.
    when "abc-analysis-attr" then do:
      create locb-abc-analysis-attr.
      { nws/impl-nws.i "abc-analysis-attr" "locb-" }
    end.
    when "abc-analysis-period" then do:
      create locb-abc-analysis-period.
      { nws/impl-nws.i "abc-analysis-period" "locb-" }
    end.
    when "abc-analysis-goods" then do:
      create locb-abc-analysis-goods.
      { nws/impl-nws.i "abc-analysis-goods" "locb-" }
    end.
    when "abc-analysis-gds-obj" then do:
      create locb-abc-analysis-gds-obj.
      { nws/impl-nws.i "abc-analysis-gds-obj" "locb-" }
    end.
    when "abc-analysis-goods-attr" then do:
      create locb-abc-analysis-goods-attr.
      { nws/impl-nws.i "abc-analysis-goods-attr" "locb-" }
    end.
    when "abc-analysis-gds-obj-attr" then do:
      create locb-abc-analysis-gds-obj-attr.
      { nws/impl-nws.i "abc-analysis-gds-obj-attr" "locb-" }
    end.


    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе abc-анализа."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

/* ------------------------------- abc-analysis-obj ---------------------------------------------- */
for each buf_abc-analysis-obj where
         buf_abc-analysis-obj.abc-id   = wt-abc-analysis.abc-id  and
         buf_abc-analysis-obj.db-num    = wt-abc-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_abc-analysis-obj.
end.
for each locb-abc-analysis-obj where
         locb-abc-analysis-obj.abc-id = wt-abc-analysis.abc-id and
         locb-abc-analysis-obj.db-num  = wt-abc-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_abc-analysis-obj.
  buffer-copy locb-abc-analysis-obj to buf_abc-analysis-obj.
end.

/* ------------------------------- abc-analysis-doc ---------------------------------------------- */
for each buf_abc-analysis-doc where
         buf_abc-analysis-doc.abc-id   = wt-abc-analysis.abc-id  and
         buf_abc-analysis-doc.db-num    = wt-abc-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_abc-analysis-doc.
end.
for each locb-abc-analysis-doc where
         locb-abc-analysis-doc.abc-id = wt-abc-analysis.abc-id and
         locb-abc-analysis-doc.db-num  = wt-abc-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_abc-analysis-doc.
  buffer-copy locb-abc-analysis-doc to buf_abc-analysis-doc.
end.

/* ------------------------------- abc-analysis-attr ---------------------------------------------- */
for each buf_abc-analysis-attr where
         buf_abc-analysis-attr.abc-id   = wt-abc-analysis.abc-id  and
         buf_abc-analysis-attr.db-num   = wt-abc-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_abc-analysis-attr.
end.
for each locb-abc-analysis-attr where
         locb-abc-analysis-attr.abc-id = wt-abc-analysis.abc-id and
         locb-abc-analysis-attr.db-num  = wt-abc-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_abc-analysis-attr.
  buffer-copy locb-abc-analysis-attr to buf_abc-analysis-attr.
end.

/* ------------------------------- abc-analysis-period ---------------------------------------------- */
for each buf_abc-analysis-period where
         buf_abc-analysis-period.abc-id   = wt-abc-analysis.abc-id  and
         buf_abc-analysis-period.db-num   = wt-abc-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_abc-analysis-period.
end.
for each locb-abc-analysis-period where
         locb-abc-analysis-period.abc-id = wt-abc-analysis.abc-id and
         locb-abc-analysis-period.db-num  = wt-abc-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_abc-analysis-period.
  buffer-copy locb-abc-analysis-period to buf_abc-analysis-period.
end.


/* ------------------------------- abc-analysis-goods-attr ---------------------------------------------- */
for each buf_abc-analysis-goods-attr where
         buf_abc-analysis-goods-attr.abc-id   = wt-abc-analysis.abc-id  and
         buf_abc-analysis-goods-attr.db-num   = wt-abc-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_abc-analysis-goods-attr.
end.
for each locb-abc-analysis-goods-attr where
         locb-abc-analysis-goods-attr.abc-id = wt-abc-analysis.abc-id and
         locb-abc-analysis-goods-attr.db-num  = wt-abc-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_abc-analysis-goods-attr.
  buffer-copy locb-abc-analysis-goods-attr to buf_abc-analysis-goods-attr.
end.

/* ------------------------------- abc-analysis-goods ---------------------------------------------- */
for each buf_abc-analysis-goods where
         buf_abc-analysis-goods.abc-id   = wt-abc-analysis.abc-id  and
         buf_abc-analysis-goods.db-num   = wt-abc-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_abc-analysis-goods.
end.
for each locb-abc-analysis-goods where
         locb-abc-analysis-goods.abc-id = wt-abc-analysis.abc-id and
         locb-abc-analysis-goods.db-num  = wt-abc-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_abc-analysis-goods.
  buffer-copy locb-abc-analysis-goods to buf_abc-analysis-goods.
end.

/* ------------------------------- abc-analysis-gds-obj-attr ---------------------------------------------- */
for each buf_abc-analysis-gds-obj-attr where
         buf_abc-analysis-gds-obj-attr.abc-id   = wt-abc-analysis.abc-id  and
         buf_abc-analysis-gds-obj-attr.db-num   = wt-abc-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_abc-analysis-gds-obj-attr.
end.
for each locb-abc-analysis-gds-obj-attr where
         locb-abc-analysis-gds-obj-attr.abc-id = wt-abc-analysis.abc-id and
         locb-abc-analysis-gds-obj-attr.db-num  = wt-abc-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_abc-analysis-gds-obj-attr.
  buffer-copy locb-abc-analysis-gds-obj-attr to buf_abc-analysis-gds-obj-attr.
end.

/* ------------------------------- abc-analysis-gds-obj ---------------------------------------------- */
for each buf_abc-analysis-gds-obj where
         buf_abc-analysis-gds-obj.abc-id   = wt-abc-analysis.abc-id  and
         buf_abc-analysis-gds-obj.db-num   = wt-abc-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_abc-analysis-gds-obj.
end.
for each locb-abc-analysis-gds-obj where
         locb-abc-analysis-gds-obj.abc-id = wt-abc-analysis.abc-id and
         locb-abc-analysis-gds-obj.db-num  = wt-abc-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_abc-analysis-gds-obj.
  buffer-copy locb-abc-analysis-gds-obj to buf_abc-analysis-gds-obj.
end.


/* ------------------------------- abc-analysis ---------------------------------------------- */
if not available tb-abc-analysis then do:
  create tb-abc-analysis.
end.

/* обновляем документ */
buffer-copy wt-abc-analysis to tb-abc-analysis.

/* -------------------- почистим за собой ------------------------ */

for each locb-abc-analysis-obj
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abc-analysis-obj.
end.
for each locb-abc-analysis-doc
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abc-analysis-doc.
end.
for each locb-abc-analysis-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abc-analysis-attr.
end.
for each locb-abc-analysis-period
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abc-analysis-period.
end.
for each locb-abc-analysis-goods
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abc-analysis-goods.
end.
for each locb-abc-analysis-gds-obj
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abc-analysis-gds-obj.
end.
for each locb-abc-analysis-goods-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abc-analysis-goods-attr.
end.
for each locb-abc-analysis-gds-obj-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abc-analysis-gds-obj-attr.
end.


/* $Workfile$ */