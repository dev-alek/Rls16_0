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
    when "xyz-analysis-obj" then do:
      create locb-xyz-analysis-obj.
      { nws/impl-nws.i "xyz-analysis-obj" "locb-" }
    end.
    when "xyz-analysis-doc" then do:
      create locb-xyz-analysis-doc.
      { nws/impl-nws.i "xyz-analysis-doc" "locb-" }
    end.
    when "xyz-analysis-attr" then do:
      create locb-xyz-analysis-attr.
      { nws/impl-nws.i "xyz-analysis-attr" "locb-" }
    end.
    when "xyz-analysis-period" then do:
      create locb-xyz-analysis-period.
      { nws/impl-nws.i "xyz-analysis-period" "locb-" }
    end.
    when "xyz-analysis-goods" then do:
      create locb-xyz-analysis-goods.
      { nws/impl-nws.i "xyz-analysis-goods" "locb-" }
    end.
    when "xyz-analysis-gds-obj" then do:
      create locb-xyz-analysis-gds-obj.
      { nws/impl-nws.i "xyz-analysis-gds-obj" "locb-" }
    end.
    when "xyz-analysis-goods-attr" then do:
      create locb-xyz-analysis-goods-attr.
      { nws/impl-nws.i "xyz-analysis-goods-attr" "locb-" }
    end.
    when "xyz-analysis-gds-obj-attr" then do:
      create locb-xyz-analysis-gds-obj-attr.
      { nws/impl-nws.i "xyz-analysis-gds-obj-attr" "locb-" }
    end.


    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе xyz-анализа."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

/* ------------------------------- xyz-analysis-obj ---------------------------------------------- */
for each buf_xyz-analysis-obj where
         buf_xyz-analysis-obj.xyz-id   = wt-xyz-analysis.xyz-id  and
         buf_xyz-analysis-obj.db-num    = wt-xyz-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_xyz-analysis-obj.
end.
for each locb-xyz-analysis-obj where
         locb-xyz-analysis-obj.xyz-id = wt-xyz-analysis.xyz-id and
         locb-xyz-analysis-obj.db-num  = wt-xyz-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_xyz-analysis-obj.
  buffer-copy locb-xyz-analysis-obj to buf_xyz-analysis-obj.
end.

/* ------------------------------- xyz-analysis-doc ---------------------------------------------- */
for each buf_xyz-analysis-doc where
         buf_xyz-analysis-doc.xyz-id   = wt-xyz-analysis.xyz-id  and
         buf_xyz-analysis-doc.db-num    = wt-xyz-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_xyz-analysis-doc.
end.
for each locb-xyz-analysis-doc where
         locb-xyz-analysis-doc.xyz-id = wt-xyz-analysis.xyz-id and
         locb-xyz-analysis-doc.db-num  = wt-xyz-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_xyz-analysis-doc.
  buffer-copy locb-xyz-analysis-doc to buf_xyz-analysis-doc.
end.

/* ------------------------------- xyz-analysis-attr ---------------------------------------------- */
for each buf_xyz-analysis-attr where
         buf_xyz-analysis-attr.xyz-id   = wt-xyz-analysis.xyz-id  and
         buf_xyz-analysis-attr.db-num   = wt-xyz-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_xyz-analysis-attr.
end.
for each locb-xyz-analysis-attr where
         locb-xyz-analysis-attr.xyz-id = wt-xyz-analysis.xyz-id and
         locb-xyz-analysis-attr.db-num  = wt-xyz-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_xyz-analysis-attr.
  buffer-copy locb-xyz-analysis-attr to buf_xyz-analysis-attr.
end.

/* ------------------------------- xyz-analysis-period ---------------------------------------------- */
for each buf_xyz-analysis-period where
         buf_xyz-analysis-period.xyz-id   = wt-xyz-analysis.xyz-id  and
         buf_xyz-analysis-period.db-num   = wt-xyz-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_xyz-analysis-period.
end.
for each locb-xyz-analysis-period where
         locb-xyz-analysis-period.xyz-id = wt-xyz-analysis.xyz-id and
         locb-xyz-analysis-period.db-num  = wt-xyz-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_xyz-analysis-period.
  buffer-copy locb-xyz-analysis-period to buf_xyz-analysis-period.
end.


/* ------------------------------- xyz-analysis-goods-attr ---------------------------------------------- */
for each buf_xyz-analysis-goods-attr where
         buf_xyz-analysis-goods-attr.xyz-id   = wt-xyz-analysis.xyz-id  and
         buf_xyz-analysis-goods-attr.db-num   = wt-xyz-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_xyz-analysis-goods-attr.
end.
for each locb-xyz-analysis-goods-attr where
         locb-xyz-analysis-goods-attr.xyz-id = wt-xyz-analysis.xyz-id and
         locb-xyz-analysis-goods-attr.db-num  = wt-xyz-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_xyz-analysis-goods-attr.
  buffer-copy locb-xyz-analysis-goods-attr to buf_xyz-analysis-goods-attr.
end.

/* ------------------------------- xyz-analysis-goods ---------------------------------------------- */
for each buf_xyz-analysis-goods where
         buf_xyz-analysis-goods.xyz-id   = wt-xyz-analysis.xyz-id  and
         buf_xyz-analysis-goods.db-num   = wt-xyz-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_xyz-analysis-goods.
end.
for each locb-xyz-analysis-goods where
         locb-xyz-analysis-goods.xyz-id = wt-xyz-analysis.xyz-id and
         locb-xyz-analysis-goods.db-num  = wt-xyz-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_xyz-analysis-goods.
  buffer-copy locb-xyz-analysis-goods to buf_xyz-analysis-goods.
end.

/* ------------------------------- xyz-analysis-gds-obj-attr ---------------------------------------------- */
for each buf_xyz-analysis-gds-obj-attr where
         buf_xyz-analysis-gds-obj-attr.xyz-id   = wt-xyz-analysis.xyz-id  and
         buf_xyz-analysis-gds-obj-attr.db-num   = wt-xyz-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_xyz-analysis-gds-obj-attr.
end.
for each locb-xyz-analysis-gds-obj-attr where
         locb-xyz-analysis-gds-obj-attr.xyz-id = wt-xyz-analysis.xyz-id and
         locb-xyz-analysis-gds-obj-attr.db-num  = wt-xyz-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_xyz-analysis-gds-obj-attr.
  buffer-copy locb-xyz-analysis-gds-obj-attr to buf_xyz-analysis-gds-obj-attr.
end.

/* ------------------------------- xyz-analysis-gds-obj ---------------------------------------------- */
for each buf_xyz-analysis-gds-obj where
         buf_xyz-analysis-gds-obj.xyz-id   = wt-xyz-analysis.xyz-id  and
         buf_xyz-analysis-gds-obj.db-num   = wt-xyz-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_xyz-analysis-gds-obj.
end.
for each locb-xyz-analysis-gds-obj where
         locb-xyz-analysis-gds-obj.xyz-id = wt-xyz-analysis.xyz-id and
         locb-xyz-analysis-gds-obj.db-num  = wt-xyz-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_xyz-analysis-gds-obj.
  buffer-copy locb-xyz-analysis-gds-obj to buf_xyz-analysis-gds-obj.
end.


/* ------------------------------- xyz-analysis ---------------------------------------------- */
if not available tb-xyz-analysis then do:
  create tb-xyz-analysis.
end.

/* обновляем документ */
buffer-copy wt-xyz-analysis to tb-xyz-analysis.

/* -------------------- почистим за собой ------------------------ */

for each locb-xyz-analysis-obj
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-xyz-analysis-obj.
end.
for each locb-xyz-analysis-doc
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-xyz-analysis-doc.
end.
for each locb-xyz-analysis-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-xyz-analysis-attr.
end.
for each locb-xyz-analysis-period
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-xyz-analysis-period.
end.
for each locb-xyz-analysis-goods
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-xyz-analysis-goods.
end.
for each locb-xyz-analysis-gds-obj
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-xyz-analysis-gds-obj.
end.
for each locb-xyz-analysis-goods-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-xyz-analysis-goods-attr.
end.
for each locb-xyz-analysis-gds-obj-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-xyz-analysis-gds-obj-attr.
end.


/* $Workfile$ */

