/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Прием стоплиста через новости

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

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
    when "stop-list-line" then do:
      create locb-stop-list-line.
      { nws/impl-nws.i "stop-list-line" "locb-" }
    end.
    when "c-stop-list-line" then do:
      create locb-c-stop-list-line.
      { nws/impl-nws.i "c-stop-list-line" "locb-" }
    end.
    when "c-stop-list" then do:
      create locb-c-stop-list.
      { nws/impl-nws.i "c-stop-list" "locb-" }
    end.
    otherwise do:
      message "nws/inc/imp/stop-l.i: Не предусмотрен прием таблицы " rec-name skip
              "в составе накладной"
              view-as alert-box error.
      return error "nws/inc/imp/stop-l.i: Не предусмотрен прием таблицы " + rec-name + {&new-line} + "в составе накладной".
    end.
  END CASE.
end.


if not available tb-stop-list then do:
  if wt-stop-list.status_ = {&fact} then do:
     v-to-send = yes.
   end.
  create tb-stop-list.
end.
else do:
  if wt-stop-list.status_ = {&fact}
  and tb-stop-list.status_ <> {&fact} then do:
    v-to-send = yes.
  end.
end.

/* сохраняем историю изменения документа */
define variable v-old-stop-list-status as character no-undo .
define variable v-new-stop-list-status as character no-undo .

assign
  v-old-stop-list-status = tb-stop-list.status_
  v-new-stop-list-status = wt-stop-list.status_
.

run trg/nwsdochs.p
  (input g#db-num                  /* p-db-num       */
  ,input {&nwsdochs_action_update} /* p-action-type  */
  ,input wt-stop-list.stop-list-code  /* p-doc-code     */
  ,input wt-stop-list.obj-type         /* p-obj-type     */
  ,input wt-stop-list.obj-code         /* p-obj-code     */
  ,input {&table_stop-list}            /* p-doc-type     */
  ,input wt-stop-list.list-type        /* p-ext-doc-type */
  ,input wt-stop-list.fact-date        /* p-fact-date    */
  ,input 0                         /* p-fact-qnty    */
  ,input 0                         /* p-fact-base    */
  ,input 0                         /* p-fact-rubl    */
  ,input 0                         /* p-num-line     */
  ,input v-old-stop-list-status        /* p-old-status   */
  ,input v-new-stop-list-status        /* p-new-status   */
  ,input g#news-source-db          /* p-pck-db-num   */
  ,input p-pck-num                 /* p-pck-pack-num */
  ,input wt-stop-list.user-db-num      /* p-user-db-num  */
  ,input wt-stop-list.user-name        /* p-user-name    */
  ,input wt-stop-list.sys-date         /* p-sys-date     */
  ,input wt-stop-list.sys-time         /* p-sys-time     */
  ,input wt-stop-list.sys-time-int     /* p-sys-time-int */
  ) no-error .
if error-status :error then do:
  run write-to-log in this-procedure
    (input substitute("&1 &2", error-status :get-message(1), return-value )
    ) .
  undo, return error .
end.


/* обновляем документ */
buffer-copy wt-stop-list to tb-stop-list.

/* ------------------------------- stop-list-line ---------------------------------------------- */
for each buf_stop-list-line where
       buf_stop-list-line.classif-type = wt-stop-list.classif-type
   and buf_stop-list-line.stop-list-code = wt-stop-list.stop-list-code
on error  undo, return error
:
  delete buf_stop-list-line.
end.
for each buf_c-stop-list-line where
       buf_c-stop-list-line.classif-type = wt-stop-list.classif-type
   and buf_c-stop-list-line.stop-list-code = wt-stop-list.stop-list-code
on error  undo, return error
:
  delete buf_c-stop-list-line.
end.
for each buf_c-stop-list where
       buf_c-stop-list.classif-type = wt-stop-list.classif-type
   and buf_c-stop-list.stop-list-code = wt-stop-list.stop-list-code
on error  undo, return error
:
  delete buf_c-stop-list.
end.

/* ------------------------------- stop-list-line------------------------------------------ */
for each locb-stop-list-line where
        locb-stop-list-line.classif-type = wt-stop-list.classif-type
    and locb-stop-list-line.stop-list-code = wt-stop-list.stop-list-code
                        no-lock
on error  undo, return error
:
  create buf_stop-list-line.
  buffer-copy locb-stop-list-line to buf_stop-list-line.
end.
/* ------------------------------- c-stop-list-line------------------------------------------ */
for each locb-c-stop-list-line where
        locb-c-stop-list-line.classif-type = wt-stop-list.classif-type
    and locb-c-stop-list-line.stop-list-code = wt-stop-list.stop-list-code
                        no-lock
on error  undo, return error
:
  create buf_c-stop-list-line.
  buffer-copy locb-c-stop-list-line to buf_c-stop-list-line.
end.


/* ------------------------------- c-stop-list------------------------------------------ */
for each locb-c-stop-list where
        locb-c-stop-list.classif-type = wt-stop-list.classif-type
    and locb-c-stop-list.stop-list-code = wt-stop-list.stop-list-code
                        no-lock
on error  undo, return error
:
  create buf_c-stop-list.
  buffer-copy locb-c-stop-list to buf_c-stop-list.
end.



/* ------------------------ почистим за собой ---------------------------------------------- */

for each locb-stop-list-line
on error  undo, return error
:
  delete locb-stop-list-line.
end.
for each locb-c-stop-list-line
on error  undo, return error
:
  delete locb-c-stop-list-line.
end.
for each locb-c-stop-list
on error  undo, return error
:
  delete locb-c-stop-list.
end.

if v-to-send then do:
  run fill-stpl-list in p-imp-handle ( buffer tb-stop-list).
end.

/* $Workfile$ e n d */