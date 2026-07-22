/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
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
    when "ord-line" then do:
      create locb-ord-line.
      { nws/impl-nws.i "ord-line" "locb-" }
    end.
    when "ord-line-attr" then do:
      create locb-ord-line-attr.
      { nws/impl-nws.i "ord-line-attr" "locb-" }
    end.
    when "ord-doc-attr" then do:
      create locb-ord-doc-attr.
      { nws/impl-nws.i "ord-doc-attr" "locb-" }
    end.
    when "ord-dtl" then do:
      create locb-ord-dtl.
      { nws/impl-nws.i "ord-dtl" "locb-" }
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе заказов."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

/* ------------------------------- ord-line ---------------------------------------------- */
for each buf_ord-line where buf_ord-line.doc-code = wt-ord-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_ord-line.
end.
for each locb-ord-line where locb-ord-line.doc-code = wt-ord-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_ord-line.
  buffer-copy locb-ord-line to buf_ord-line.
end.
/* ------------------------------- ord-line-attr ---------------------------------------------- */
for each buf_ord-line-attr where buf_ord-line-attr.doc-code = wt-ord-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_ord-line-attr.
end.
for each locb-ord-line-attr where locb-ord-line-attr.doc-code = wt-ord-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_ord-line-attr.
  buffer-copy locb-ord-line-attr to buf_ord-line-attr.
end.

/* ------------------------------- ord-doc-attr ---------------------------------------------- */
for each buf_ord-doc-attr where buf_ord-doc-attr.doc-code = wt-ord-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_ord-doc-attr.
end.
for each locb-ord-doc-attr where locb-ord-doc-attr.doc-code = wt-ord-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_ord-doc-attr.
  buffer-copy locb-ord-doc-attr to buf_ord-doc-attr.
end.



/* ------------------------------- ord-dtl ---------------------------------------------- */
for each buf_ord-dtl where buf_ord-dtl.doc-code = wt-ord-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_ord-dtl.
end.
for each locb-ord-dtl where locb-ord-dtl.doc-code = wt-ord-doc.doc-code
                      no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_ord-dtl.
  buffer-copy locb-ord-dtl to buf_ord-dtl.
end.

/* ------------------------------- ord-doc ---------------------------------------------- */
if not available tb-ord-doc then do:
  create tb-ord-doc.
end.

/* сохраняем историю изменения документа */
define variable v-old-ord-doc-status as character no-undo .
define variable v-new-ord-doc-status as character no-undo .

if tb-ord-doc.status_ = ""
or tb-ord-doc.status_ = ?
then do:
  assign
    v-old-ord-doc-status = ""
  .
end.
else do:
  assign
    v-old-ord-doc-status = tb-ord-doc.status_ + string(tb-ord-doc.flag_, '+/-':u)
  .
end.


assign
  v-new-ord-doc-status = wt-ord-doc.status_ + string(wt-ord-doc.flag_, '+/-':u)
.

run trg/nwsdochs.p
  (input g#db-num                  /* p-db-num       */
  ,input {&nwsdochs_action_update} /* p-action-type  */
  ,input wt-ord-doc.doc-code       /* p-doc-code     */
  ,input wt-ord-doc.obj-type       /* p-obj-type     */
  ,input wt-ord-doc.obj-code       /* p-obj-code     */
  ,input {&table_ord-doc}          /* p-doc-type     */
  ,input '':u                      /* p-ext-doc-type */
  ,input wt-ord-doc.fact-date      /* p-fact-date    */
  ,input wt-ord-doc.cli-qnty       /* p-fact-qnty    */
  ,input 0                         /* p-fact-base    */
  ,input 0                         /* p-fact-rubl    */
  ,input 0                         /* p-num-line     */
  ,input v-old-ord-doc-status      /* p-old-status   */
  ,input v-new-ord-doc-status      /* p-new-status   */
  ,input g#news-source-db          /* p-pck-db-num   */
  ,input p-pck-num                 /* p-pck-pack-num */
  ,input wt-ord-doc.user-db-num    /* p-user-db-num  */
  ,input wt-ord-doc.user-name      /* p-user-name    */
  ,input wt-ord-doc.sys-date       /* p-sys-date     */
  ,input wt-ord-doc.sys-time       /* p-sys-time     */
  ,input wt-ord-doc.sys-time-int   /* p-sys-time-int */
  ) no-error .
if error-status :error then do:
  run write-to-log in this-procedure
    (input substitute("&1 &2", error-status :get-message(1), return-value )
    ) .
  undo, return error .
end.


/* сохраняем изменения */
buffer-copy wt-ord-doc to tb-ord-doc.

/* -------------------- почистим за собой ------------------------ */
for each locb-ord-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-line.
end.

for each locb-ord-line-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-line-attr.
end.

for each locb-ord-doc-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-doc-attr.
end.

for each locb-ord-dtl
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-dtl.
end.

/* $Workfile$ e n d */