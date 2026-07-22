/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

куст поставки с включенным заказом не должен ходить по ОР

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
    when "ord-line-rcv" then do:
      create locb-ord-line-rcv.
      { nws/impl-nws.i "ord-line-rcv" "locb-" }
    end.
    when "ord-dtl-rcv" then do:
      create locb-ord-dtl-rcv.
      { nws/impl-nws.i "ord-dtl-rcv" "locb-" }
    end.
    when "ord-line" then do:
      create rcvlocb-ord-line.
      { nws/impl-nws.i "ord-line" "rcvlocb-" }
    end.
    when "ord-dtl" then do:
      create rcvlocb-ord-dtl.
      { nws/impl-nws.i "ord-dtl" "rcvlocb-" }
    end.
    when "ord-doc" then do:
      create rcvlocb-ord-doc.
      { nws/impl-nws.i "ord-doc" "rcvlocb-" }
    end.
    when "ord-rcv-line-attr" then do:
      create locb-ord-rcv-line-attr.
      { nws/impl-nws.i "ord-rcv-line-attr" "locb-" }
    end.
    when "ord-line-attr" then do:
      create rcvlocb-ord-line-attr.
      { nws/impl-nws.i "ord-line-attr" "rcvlocb-" }
    end.
    when "ord-doc-attr" then do:
      create rcvlocb-ord-doc-attr.
      { nws/impl-nws.i "ord-doc-attr" "rcvlocb-" }
    end.
    when "ord-rcv-attr" then do:
      create locb-ord-rcv-attr.
      { nws/impl-nws.i "ord-rcv-attr" "locb-" }
    end.


    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе поставок под заказы."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
/* ------------------------------- ord-doc ---------------------------------------------- */
for each rcvlocb-ord-doc where rcvlocb-ord-doc.doc-code = wt-ord-doc-rcv.doc-code and
                               rcvlocb-ord-doc.doc-type <> {&o-r}
                      no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :


if not can-find(first buf_ord-doc where buf_ord-doc.doc-code = wt-ord-doc-rcv.doc-code
      and buf_ord-doc.doc-type <> {&o-r} no-lock )
   then create buf_ord-doc.
   else find buf_ord-doc where buf_ord-doc.doc-code = wt-ord-doc-rcv.doc-code
                           and buf_ord-doc.doc-type <> {&o-r}
                               exclusive-lock no-error.

  buffer-copy rcvlocb-ord-doc to buf_ord-doc.
end.

/* ------------------------------- ord-doc-attr ---------------------------------------------- */
for each rcvlocb-ord-doc-attr where rcvlocb-ord-doc-attr.doc-code = wt-ord-doc-rcv.doc-code
                      no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :

if not can-find(first buf_ord-doc-attr where buf_ord-doc-attr.doc-code = wt-ord-doc-rcv.doc-code no-lock )
   then create buf_ord-doc-attr.
   else find buf_ord-doc-attr where buf_ord-doc-attr.doc-code = wt-ord-doc-rcv.doc-code exclusive-lock no-error.

  buffer-copy rcvlocb-ord-doc-attr to buf_ord-doc-attr.
end.


/* ------------------------------- ord-line-rcv ---------------------------------------------- */
for each buf_ord-line-rcv where buf_ord-line-rcv.rcv-code = wt-ord-doc-rcv.rcv-code and
                                buf_ord-line-rcv.doc-code = wt-ord-doc-rcv.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_ord-line-rcv.
end.

for each locb-ord-line-rcv where locb-ord-line-rcv.rcv-code = wt-ord-doc-rcv.rcv-code and
                                 locb-ord-line-rcv.doc-code = wt-ord-doc-rcv.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_ord-line-rcv.
  buffer-copy locb-ord-line-rcv to buf_ord-line-rcv.
end.

/* ------------------------------- ord-rcv-line-attr ---------------------------------------------- */
for each buf_ord-rcv-line-attr where buf_ord-rcv-line-attr.rcv-code = wt-ord-doc-rcv.rcv-code and
                                buf_ord-rcv-line-attr.doc-code = wt-ord-doc-rcv.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_ord-rcv-line-attr.
end.

for each locb-ord-rcv-line-attr where locb-ord-rcv-line-attr.rcv-code = wt-ord-doc-rcv.rcv-code and
                                 locb-ord-rcv-line-attr.doc-code = wt-ord-doc-rcv.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_ord-rcv-line-attr.
  buffer-copy locb-ord-rcv-line-attr to buf_ord-rcv-line-attr.
end.

/* ------------------------------- ord-rcv-attr --------------------------------------------- */
for each buf_ord-rcv-attr where buf_ord-rcv-attr.rcv-code = wt-ord-doc-rcv.rcv-code and
                                buf_ord-rcv-attr.doc-code = wt-ord-doc-rcv.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_ord-rcv-attr.
end.

for each locb-ord-rcv-attr where locb-ord-rcv-attr.rcv-code = wt-ord-doc-rcv.rcv-code and
                                 locb-ord-rcv-attr.doc-code = wt-ord-doc-rcv.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_ord-rcv-attr.
  buffer-copy locb-ord-rcv-attr to buf_ord-rcv-attr.
end.

/* ------------------------------- ord-dtl-rcv ---------------------------------------------- */
for each buf_ord-dtl-rcv where buf_ord-dtl-rcv.rcv-code = wt-ord-doc-rcv.rcv-code and
                               buf_ord-dtl-rcv.doc-code = wt-ord-doc-rcv.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_ord-dtl-rcv.
end.
for each locb-ord-dtl-rcv where locb-ord-dtl-rcv.rcv-code = wt-ord-doc-rcv.rcv-code and
                                locb-ord-dtl-rcv.doc-code = wt-ord-doc-rcv.doc-code
                      no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_ord-dtl-rcv.
  buffer-copy locb-ord-dtl-rcv to buf_ord-dtl-rcv.
end.
/* ------------------------------- ord-line ---------------------------------------------- */
for each buf_ord-line where buf_ord-line.doc-code = wt-ord-doc-rcv.doc-code,
    first buf_ord-doc no-lock where buf_ord-doc.doc-code = buf_ord-line.doc-code
                                and buf_ord-doc.doc-type <> {&o-r}
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_ord-line.
end.

for each rcvlocb-ord-line where rcvlocb-ord-line.doc-code = wt-ord-doc-rcv.doc-code no-lock,
    first buf_ord-doc no-lock where buf_ord-doc.doc-code = wt-ord-doc-rcv.doc-code
                                and buf_ord-doc.doc-type <> {&o-r}
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_ord-line.
  buffer-copy rcvlocb-ord-line to buf_ord-line.
end.
/* ------------------------------- ord-line-attr ---------------------------------------------- */
for each buf_ord-line-attr where buf_ord-line-attr.doc-code = wt-ord-doc-rcv.doc-code ,
    first buf_ord-doc no-lock where buf_ord-doc.doc-code = wt-ord-doc-rcv.doc-code
                                and buf_ord-doc.doc-type <> {&o-r}

on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_ord-line-attr.
end.

for each rcvlocb-ord-line-attr where rcvlocb-ord-line-attr.doc-code = wt-ord-doc-rcv.doc-code no-lock ,
    first buf_ord-doc no-lock where buf_ord-doc.doc-code = wt-ord-doc-rcv.doc-code
                                and buf_ord-doc.doc-type <> {&o-r}
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_ord-line-attr.
  buffer-copy rcvlocb-ord-line-attr to buf_ord-line-attr.
end.



/* ------------------------------- ord-dtl ---------------------------------------------- */
for each buf_ord-dtl where buf_ord-dtl.doc-code = wt-ord-doc-rcv.doc-code ,
    first buf_ord-doc no-lock where buf_ord-doc.doc-code = wt-ord-doc-rcv.doc-code
                                and buf_ord-doc.doc-type <> {&o-r}
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_ord-dtl.
end.
for each rcvlocb-ord-dtl where rcvlocb-ord-dtl.doc-code = wt-ord-doc-rcv.doc-code
                      no-lock ,
    first buf_ord-doc no-lock where buf_ord-doc.doc-code = wt-ord-doc-rcv.doc-code
                                and buf_ord-doc.doc-type <> {&o-r}

on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_ord-dtl.
  buffer-copy rcvlocb-ord-dtl to buf_ord-dtl.
end.

/* ------------------------------- ord-doc-rcv ---------------------------------------------- */
if not available tb-ord-doc-rcv then do:
   create tb-ord-doc-rcv no-error.
end.


/* сохраняем историю изменения документа */
define variable v-old-ord-doc-rcv-status as character no-undo .
define variable v-new-ord-doc-rcv-status as character no-undo .

if tb-ord-doc-rcv.status_ = ""
or tb-ord-doc-rcv.status_ = ?
then do:
  assign
    v-old-ord-doc-rcv-status = ""
  .
end.
else do:
  assign
    v-old-ord-doc-rcv-status = tb-ord-doc-rcv.status_ + string(tb-ord-doc-rcv.flag_, '+/-':u)
  .
end.

assign
  v-new-ord-doc-rcv-status = wt-ord-doc-rcv.status_ + string(wt-ord-doc-rcv.flag_, '+/-':u)
.

run trg/nwsdochs.p
  (input g#db-num                    /* p-db-num       */
  ,input {&nwsdochs_action_update}   /* p-action-type  */
  ,input wt-ord-doc-rcv.rcv-code     /* p-doc-code     */
  ,input wt-ord-doc-rcv.obj-type     /* p-obj-type     */
  ,input wt-ord-doc-rcv.obj-code     /* p-obj-code     */
  ,input {&table_ord-doc-rcv}        /* p-doc-type     */
  ,input '':u                        /* p-ext-doc-type */
  ,input wt-ord-doc-rcv.fact-date    /* p-fact-date    */
  ,input 0                           /* p-fact-qnty    */
  ,input 0                           /* p-fact-base    */
  ,input 0                           /* p-fact-rubl    */
  ,input 0                           /* p-num-line     */
  ,input v-old-ord-doc-rcv-status    /* p-old-status   */
  ,input v-new-ord-doc-rcv-status    /* p-new-status   */
  ,input g#news-source-db            /* p-pck-db-num   */
  ,input p-pck-num                   /* p-pck-pack-num */
  ,input wt-ord-doc-rcv.user-db-num  /* p-user-db-num  */
  ,input wt-ord-doc-rcv.user-name    /* p-user-name    */
  ,input wt-ord-doc-rcv.sys-date     /* p-sys-date     */
  ,input wt-ord-doc-rcv.sys-time     /* p-sys-time     */
  ,input wt-ord-doc-rcv.sys-time-int /* p-sys-time-int */
  ) no-error .
if error-status :error then do:
  run write-to-log in this-procedure
    (input substitute("&1 &2", error-status :get-message(1), return-value )
    ) .
  undo, return error .
end.

/* обновляем документ */
buffer-copy wt-ord-doc-rcv to tb-ord-doc-rcv no-error.

/* -------------------- почистим за собой ------------------------ */
for each locb-ord-line-rcv
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-line-rcv.
end.
for each locb-ord-rcv-line-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-rcv-line-attr.
end.
for each locb-ord-rcv-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-rcv-attr.
end.

for each locb-ord-dtl-rcv
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-dtl-rcv.
end.

for each rcvlocb-ord-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete rcvlocb-ord-line.
end.
for each rcvlocb-ord-line-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete rcvlocb-ord-line-attr.
end.

for each rcvlocb-ord-dtl
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete rcvlocb-ord-dtl.
end.
for each rcvlocb-ord-doc
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete rcvlocb-ord-doc.
end.

for each rcvlocb-ord-doc-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete rcvlocb-ord-doc-attr.
end.


/* $Workfile$ e n d */