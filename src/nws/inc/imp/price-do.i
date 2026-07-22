/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Разбор переоценки

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
    when "price-list" then do:
      create locb-price-list.
      run nws-impl-without-check in p-imp-handle
        ( input (buffer locb-price-list:handle)
        ) no-error.
      if error-status :error then do:
        return error return-value .
      end.
      run check-avail-artic in p-imp-handle
        ( input locb-price-list.artic
         ,input locb-price-list.prod-type
         ,input locb-price-list.prod-code
        ).
      run check-avail-b-code in p-imp-handle
        ( input-output locb-price-list.b-code
        ) no-error.
      if error-status :error then do:
        find first buf_bar-code no-lock
          where buf_bar-code.b-code = locb-price-list.b-code
          no-error
        .
        if not available buf_bar-code
          and locb-price-list.doc-qnty = ?
        then do:
          delete locb-price-list.
        end.
      end.
    end.
    when "doc-attr" then do:
      create locb-doc-attr.
      { nws/impl-nws.i "doc-attr" "locb-" }
    end.

    when "price-list-attr" then do:
      create locb-price-list-attr.
      { nws/impl-nws.i "price-list-attr" "locb-" }
    end.


    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе переоценки."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

/* ------------------------------- price-list ---------------------------------------------- */
for each buf_price-list where buf_price-list.doc-num = wt-price-doc.doc-num
on error  undo, return error
:
  delete buf_price-list.
end.
for each locb-price-list where locb-price-list.doc-num = wt-price-doc.doc-num
                         no-lock
on error  undo, return error
:
  create buf_price-list.
  buffer-copy  locb-price-list to buf_price-list.
end.

/* ------------------------------- doc-attr ---------------------------------------------- */

for each buf_doc-attr where buf_doc-attr.doc-code = wt-price-doc.doc-num
on error  undo, return error
:
  delete buf_doc-attr.
end.
for each locb-doc-attr where locb-doc-attr.doc-code = wt-price-doc.doc-num
                       no-lock
on error  undo, return error
:
  create buf_doc-attr.
  buffer-copy locb-doc-attr to buf_doc-attr.
end.

/* ------------------------------- price-list-attr ---------------------------------------------- */
for each buf_price-list-attr where buf_price-list-attr.doc-num = wt-price-doc.doc-num
on error  undo, return error
:
  delete buf_price-list-attr.
end.
for each locb-price-list-attr where locb-price-list-attr.doc-num = wt-price-doc.doc-num
                       no-lock
on error  undo, return error
:
  create buf_price-list-attr.
  buffer-copy locb-price-list-attr to buf_price-list-attr.
end.

/* ------------------------------- price-doc ---------------------------------------------- */
if not available tb-price-doc then do:
  create tb-price-doc.
end.



/* сохраняем историю изменения документа */
define variable v-old-price-doc-status as character no-undo .
define variable v-new-price-doc-status as character no-undo .

assign
  v-old-price-doc-status = tb-price-doc.status_
  v-new-price-doc-status = wt-price-doc.status_
.

run trg/nwsdochs.p
  (input g#db-num                  /* p-db-num       */
  ,input {&nwsdochs_action_update} /* p-action-type  */
  ,input wt-price-doc.doc-num      /* p-doc-code     */
  ,input wt-price-doc.obj-type     /* p-obj-type     */
  ,input wt-price-doc.obj-code     /* p-obj-code     */
  ,input {&table_price-doc}        /* p-doc-type     */
  ,input {&TDEDT_Overturn}         /* p-ext-doc-type */
  ,input wt-price-doc.fact-date    /* p-fact-date    */
  ,input wt-price-doc.rest-qnty    /* p-fact-qnty    */
  ,input 0                         /* p-fact-base    */
  ,input 0                         /* p-fact-rubl    */
  ,input 0                         /* p-num-line     */
  ,input v-old-price-doc-status    /* p-old-status   */
  ,input v-new-price-doc-status    /* p-new-status   */
  ,input g#news-source-db          /* p-pck-db-num   */
  ,input p-pck-num                 /* p-pck-pack-num */
  ,input wt-price-doc.user-db-num  /* p-user-db-num  */
  ,input wt-price-doc.user-name    /* p-user-name    */
  ,input wt-price-doc.sys-date     /* p-sys-date     */
  ,input wt-price-doc.sys-time     /* p-sys-time     */
  ,input wt-price-doc.sys-time-int /* p-sys-time-int */
  ) no-error .
if error-status :error then do:
  run write-to-log in this-procedure
    (input substitute("&1 &2", error-status :get-message(1), return-value )
    ) .
  undo, return error .
end.

/* обновляем документ */
buffer-copy wt-price-doc to tb-price-doc.

/*------------------------- почистим за собой ----------------------------------------------- */

for each locb-price-list
on error  undo, return error
:
  delete locb-price-list.
end.

for each locb-doc-attr
on error  undo, return error
:
  delete locb-doc-attr.
end.

for each locb-price-list-attr
on error  undo, return error
:
  delete locb-price-list-attr.
end.

/* $Workfile$ e n d */