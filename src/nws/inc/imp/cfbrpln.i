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
    when "c-fbr-pln-line" then do:
      create locb-c-fbr-pln-line.
      { nws/impl-nws.i "c-fbr-pln-line" "locb-" }
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе производства."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

for each buf_c-fbr-pln-line where buf_c-fbr-pln-line.doc-code = wt-c-fbr-pln.doc-code
on error  undo, return error
:
  delete buf_c-fbr-pln-line.
end.
for each locb-c-fbr-pln-line where locb-c-fbr-pln-line.doc-code = wt-c-fbr-pln.doc-code
                       no-lock
on error  undo, return error
:
  create buf_c-fbr-pln-line.
  buffer-copy locb-c-fbr-pln-line to buf_c-fbr-pln-line.
end.

if not available tb-c-fbr-pln then do:
  create tb-c-fbr-pln.
end.

/* сохраняем историю изменения документа */
define variable v-old-c-fbr-pln-status as character no-undo .
define variable v-new-c-fbr-pln-status as character no-undo .

assign
  v-old-c-fbr-pln-status = tb-c-fbr-pln.status_
  v-new-c-fbr-pln-status = wt-c-fbr-pln.status_
.

run trg/nwsdochs.p
  (input g#db-num                  /* p-db-num       */
  ,input {&nwsdochs_action_update} /* p-action-type  */
  ,input wt-c-fbr-pln.doc-code       /* p-doc-code     */
  ,input wt-c-fbr-pln.obj-type       /* p-obj-type     */
  ,input wt-c-fbr-pln.obj-code       /* p-obj-code     */
  ,input {&table_c-fbr-pln}          /* p-doc-type     */
  ,input '':u                      /* p-ext-doc-type */
  ,input wt-c-fbr-pln.fact-date      /* p-fact-date    */
  ,input 0                         /* p-fact-qnty    */
  ,input 0                         /* p-fact-base    */
  ,input 0                         /* p-fact-rubl    */
  ,input 0                         /* p-num-line     */
  ,input v-old-c-fbr-pln-status      /* p-old-status   */
  ,input v-new-c-fbr-pln-status      /* p-new-status   */
  ,input g#news-source-db          /* p-pck-db-num   */
  ,input p-pck-num                 /* p-pck-pack-num */
  ,input wt-c-fbr-pln.user-db-num    /* p-user-db-num  */
  ,input wt-c-fbr-pln.user-name      /* p-user-name    */
  ,input wt-c-fbr-pln.sys-date       /* p-sys-date     */
  ,input wt-c-fbr-pln.sys-time       /* p-sys-time     */
  ,input wt-c-fbr-pln.sys-time-int   /* p-sys-time-int */
  ) no-error .
if error-status :error then do:
  run write-to-log in this-procedure
    (input substitute("&1 &2", error-status :get-message(1), return-value )
    ) .
  undo, return error .
end.

/* обновляем документ */
buffer-copy wt-c-fbr-pln to tb-c-fbr-pln.

/* ---------------------------- почистим за собой -------------------------------- */
for each locb-c-fbr-pln-line
on error  undo, return error
:
  delete locb-c-fbr-pln-line.
end.


/* $Workfile$ e n d */