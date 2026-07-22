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
    when "ord-gds-cons" then do:
      create locb-ord-gds-cons.
      { nws/impl-nws.i "ord-gds-cons" "locb-" }
    end.
    when "ord-dtl-cons" then do:
      create locb-ord-dtl-cons.
      { nws/impl-nws.i "ord-dtl-cons" "locb-" }
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе савокупных заявок."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

/* ------------------------------- ord-gds-cons ---------------------------------------------- */
for each buf_ord-gds-cons where buf_ord-gds-cons.cons-code = wt-ord-cons.cons-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_ord-gds-cons.
end.
for each locb-ord-gds-cons where locb-ord-gds-cons.cons-code = wt-ord-cons.cons-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_ord-gds-cons.
  buffer-copy locb-ord-gds-cons to buf_ord-gds-cons.
end.

/* ------------------------------- ord-dtl-cons ---------------------------------------------- */
for each buf_ord-dtl-cons where buf_ord-dtl-cons.cons-code = wt-ord-cons.cons-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_ord-dtl-cons.
end.
for each locb-ord-dtl-cons where locb-ord-dtl-cons.cons-code = wt-ord-cons.cons-code
                      no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_ord-dtl-cons.
  buffer-copy locb-ord-dtl-cons to buf_ord-dtl-cons.
end.

/* ------------------------------- ord-doc ---------------------------------------------- */
if not available tb-ord-cons then do:
  create tb-ord-cons.
end.

/* сохраняем историю изменения документа */
define variable v-old-ord-cons-status as character no-undo .
define variable v-new-ord-cons-status as character no-undo .

if tb-ord-cons.status_ = ""
or tb-ord-cons.status_ = ?
then do:
  assign
    v-old-ord-cons-status = ""
  .
end.
else do:
  assign
    v-old-ord-cons-status = tb-ord-cons.status_ + string(tb-ord-cons.flag_, '+/-':u)
  .
end.

assign
  v-new-ord-cons-status = wt-ord-cons.status_ + string(wt-ord-cons.flag_, '+/-':u)
.

run trg/nwsdochs.p
  (input g#db-num                   /* p-db-num       */
  ,input {&nwsdochs_action_update}  /* p-action-type  */
  ,input wt-ord-cons.cons-code      /* p-doc-code     */
  ,input wt-ord-cons.input-obj-type /* p-obj-type     */
  ,input wt-ord-cons.input-obj-code /* p-obj-code     */
  ,input {&table_ord-cons}          /* p-doc-type     */
  ,input '':u                       /* p-ext-doc-type */
  ,input wt-ord-cons.fact-date      /* p-fact-date    */
  ,input 0                          /* p-fact-qnty    */
  ,input 0                          /* p-fact-base    */
  ,input 0                          /* p-fact-rubl    */
  ,input 0                          /* p-num-line     */
  ,input v-old-ord-cons-status      /* p-old-status   */
  ,input v-new-ord-cons-status      /* p-new-status   */
  ,input g#news-source-db           /* p-pck-db-num   */
  ,input p-pck-num                  /* p-pck-pack-num */
  ,input wt-ord-cons.user-db-num    /* p-user-db-num  */
  ,input wt-ord-cons.user-name      /* p-user-name    */
  ,input wt-ord-cons.sys-date       /* p-sys-date     */
  ,input wt-ord-cons.sys-time       /* p-sys-time     */
  ,input wt-ord-cons.sys-time-int   /* p-sys-time-int */
  ) no-error .
if error-status :error then do:
  run write-to-log in this-procedure
    (input substitute("&1 &2", error-status :get-message(1), return-value )
    ) .
  undo, return error .
end.

/* обновляем документ */
buffer-copy wt-ord-cons to tb-ord-cons.

/* -------------------- почистим за собой ------------------------ */
for each locb-ord-gds-cons
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-gds-cons.
end.
for each locb-ord-dtl-cons
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-dtl-cons.
end.
/* $Workfile$ */