/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Разбор документа план-меню в новостях

Автор: Белоусов Илья Александрович
Дата создания: 10/23/07
Author: Ilia Belousov
Creation date: 10/23/07

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :

  { nws/imps-nws.i rec-full }

  assign
    rec-name = entry( 1, rec-full, {&delim-nws} )
    .

  {&test-count}

  CASE rec-name :
    when "fbr-pln-line" then do:
      create locb-fbr-pln-line.
      { nws/impl-nws.i "fbr-pln-line" "locb-" }
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе производства."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

for each buf_fbr-pln-line where buf_fbr-pln-line.doc-code = wt-fbr-pln.doc-code
on error  undo, return error
:
  delete buf_fbr-pln-line.
end.
for each locb-fbr-pln-line where locb-fbr-pln-line.doc-code = wt-fbr-pln.doc-code
                       no-lock
on error  undo, return error
:
  create buf_fbr-pln-line.
  buffer-copy locb-fbr-pln-line to buf_fbr-pln-line.
end.

if not available tb-fbr-pln then do:
  create tb-fbr-pln.
end.

/* сохраняем историю изменения документа */
define variable v-old-fbr-pln-status as character no-undo .
define variable v-new-fbr-pln-status as character no-undo .

assign
  v-old-fbr-pln-status = tb-fbr-pln.status_
  v-new-fbr-pln-status = wt-fbr-pln.status_
.

run trg/nwsdochs.p
  (input g#db-num                  /* p-db-num       */
  ,input {&nwsdochs_action_update} /* p-action-type  */
  ,input wt-fbr-pln.doc-code       /* p-doc-code     */
  ,input wt-fbr-pln.obj-type       /* p-obj-type     */
  ,input wt-fbr-pln.obj-code       /* p-obj-code     */
  ,input {&table_fbr-pln}          /* p-doc-type     */
  ,input '':u                      /* p-ext-doc-type */
  ,input wt-fbr-pln.fact-date      /* p-fact-date    */
  ,input 0                         /* p-fact-qnty    */
  ,input 0                         /* p-fact-base    */
  ,input 0                         /* p-fact-rubl    */
  ,input 0                         /* p-num-line     */
  ,input v-old-fbr-pln-status      /* p-old-status   */
  ,input v-new-fbr-pln-status      /* p-new-status   */
  ,input g#news-source-db          /* p-pck-db-num   */
  ,input p-pck-num                 /* p-pck-pack-num */
  ,input wt-fbr-pln.user-db-num    /* p-user-db-num  */
  ,input wt-fbr-pln.user-name      /* p-user-name    */
  ,input wt-fbr-pln.sys-date       /* p-sys-date     */
  ,input wt-fbr-pln.sys-time       /* p-sys-time     */
  ,input wt-fbr-pln.sys-time-int   /* p-sys-time-int */
  ) no-error .
if error-status :error then do:
  run write-to-log in this-procedure
    (input substitute("&1 &2", error-status :get-message(1), return-value )
    ) .
  undo, return error .
end.

/* обновляем документ */
buffer-copy wt-fbr-pln to tb-fbr-pln.

/* ---------------------------- почистим за собой -------------------------------- */
for each locb-fbr-pln-line
on error  undo, return error
:
  delete locb-fbr-pln-line.
end.


/* $Workfile$ e n d */