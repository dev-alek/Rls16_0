/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Разбор документа производства в новостях

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
    when "fbr-line" then do:
      create locb-fbr-line.
      { nws/impl-nws.i "fbr-line" "locb-" }
    end.
    when "fbr-recipe" then do:
      create locb-fbr-recipe.
      { nws/impl-nws.i "fbr-recipe" "locb-" }
    end.
    when "fbr-recipe-gds" then do:
      create locb-fbr-recipe-gds.
      { nws/impl-nws.i "fbr-recipe-gds" "locb-" }
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе производства."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

for each buf_fbr-line where buf_fbr-line.doc-code = wt-fbr-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete buf_fbr-line.
end.
for each locb-fbr-line where locb-fbr-line.doc-code = wt-fbr-doc.doc-code
                       no-lock
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  create buf_fbr-line.
  buffer-copy locb-fbr-line to buf_fbr-line.
end.

for each buf_fbr-recipe where buf_fbr-recipe.doc-code = wt-fbr-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete buf_fbr-recipe.
end.
for each locb-fbr-recipe where locb-fbr-recipe.doc-code = wt-fbr-doc.doc-code
                       no-lock
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  create buf_fbr-recipe.
  buffer-copy locb-fbr-recipe to buf_fbr-recipe.
end.

for each buf_fbr-recipe-gds where buf_fbr-recipe-gds.doc-code = wt-fbr-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete buf_fbr-recipe-gds.
end.
for each locb-fbr-recipe-gds where locb-fbr-recipe-gds.doc-code = wt-fbr-doc.doc-code
                       no-lock
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  create buf_fbr-recipe-gds.
  buffer-copy locb-fbr-recipe-gds to buf_fbr-recipe-gds.
end.

if not available tb-fbr-doc then do:
  create tb-fbr-doc.
end.

/* сохраняем историю изменения документа */
define variable v-old-fbr-doc-status as character no-undo .
define variable v-new-fbr-doc-status as character no-undo .

assign
  v-old-fbr-doc-status = tb-fbr-doc.status_
  v-new-fbr-doc-status = wt-fbr-doc.status_
.

run trg/nwsdochs.p
  (input g#db-num                  /* p-db-num       */
  ,input {&nwsdochs_action_update} /* p-action-type  */
  ,input wt-fbr-doc.doc-code       /* p-doc-code     */
  ,input wt-fbr-doc.obj-type       /* p-obj-type     */
  ,input wt-fbr-doc.obj-code       /* p-obj-code     */
  ,input {&table_fbr-doc}          /* p-doc-type     */
  ,input '':u                      /* p-ext-doc-type */
  ,input wt-fbr-doc.fact-date      /* p-fact-date    */
  ,input wt-fbr-doc.out-qnty       /* p-fact-qnty    */
  ,input wt-fbr-doc.out-base       /* p-fact-base    */
  ,input wt-fbr-doc.out-rubl       /* p-fact-rubl    */
  ,input 0                         /* p-num-line     */
  ,input v-old-fbr-doc-status      /* p-old-status   */
  ,input v-new-fbr-doc-status      /* p-new-status   */
  ,input g#news-source-db          /* p-pck-db-num   */
  ,input p-pck-num                 /* p-pck-pack-num */
  ,input wt-fbr-doc.user-db-num    /* p-user-db-num  */
  ,input wt-fbr-doc.user-name      /* p-user-name    */
  ,input wt-fbr-doc.sys-date       /* p-sys-date     */
  ,input wt-fbr-doc.sys-time       /* p-sys-time     */
  ,input wt-fbr-doc.sys-time-int   /* p-sys-time-int */
  ) no-error .
if error-status :error then do:
  run write-to-log in this-procedure
    (input substitute("&1 &2", error-status :get-message(1), return-value )
    ) .
  undo, return error .
end.

/* обновляем документ */
buffer-copy wt-fbr-doc to tb-fbr-doc.

/* ---------------------------- почистим за собой -------------------------------- */
for each locb-fbr-line
on error  undo, return error
:
  delete locb-fbr-line.
end.

/* $Workfile$ e n d */