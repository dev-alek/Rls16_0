/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Импорт документа сверки

Автор: Уханов Дмитрий Юрьевич
Дата создания: 02/15/07
Author: Dmitry Ukhanov
Creation date: 02/15/07

Автор1: Суслов Алексей Юрьевич
Дата создания1: 04/04/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

do counter = 1 to l-counter
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:

  { nws/imps-nws.i rec-full }

  assign
    rec-name = entry( 1, rec-full, {&delim-nws} )
    .

  {&test-count}

  CASE rec-name :
    when "rvs-line" then do:
      create locb-rvs-line.
      { nws/impl-nws.i "rvs-line" "locb-" }
    end.
    when "rvs-line-pump" then do:
      create locb-rvs-line-pump.
      { nws/impl-nws.i "rvs-line-pump" "locb-" }
    end.
    when "rvs-pump" then do:
      create locbr-rvs-pump.
      { nws/impl-nws.i "rvs-pump" "locbr-" }
    end.
    when "doc-attr" then do:
      create locbr-doc-attr.
      { nws/impl-nws.i "doc-attr" "locbr-" }
    end.
    when "doc-line-attr" then do:
      create locbr-doc-line-attr.
      { nws/impl-nws.i "doc-line-attr" "locbr-" }
    end.
    when "rvs-line-attr" then do:
      create locbr-rvs-line-attr.
      { nws/impl-nws.i "rvs-line-attr" "locbr-" }
    end.
    otherwise do:
      message
        substitute( "Не предусмотрен прием таблицы &1", rec-name ) skip
        substitute( "в составе сверки." ) skip
        view-as alert-box error.
      return error .
    end.
  end case.
end.

for each buf_rvs-line
  where buf_rvs-line.rvs-code = wt-rvs-doc.rvs-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:
  delete buf_rvs-line.
end.
for each locb-rvs-line
  where locb-rvs-line.rvs-code = wt-rvs-doc.rvs-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:
  create buf_rvs-line.
  buffer-copy locb-rvs-line to buf_rvs-line.
end.

for each buf_rvs-line-pump
  where buf_rvs-line-pump.rvs-code = wt-rvs-doc.rvs-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:
  delete buf_rvs-line-pump.
end.
for each locb-rvs-line-pump
  where locb-rvs-line-pump.rvs-code = wt-rvs-doc.rvs-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:
  create buf_rvs-line-pump.
  buffer-copy locb-rvs-line-pump to buf_rvs-line-pump.
end.

for each buf_rvs-pump
  where buf_rvs-pump.rvs-code = wt-rvs-doc.rvs-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:
  delete buf_rvs-pump.
end.
for each locbr-rvs-pump
  where locbr-rvs-pump.rvs-code = wt-rvs-doc.rvs-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:
  create buf_rvs-pump.
  buffer-copy locbr-rvs-pump to buf_rvs-pump.
end.

for each buf_doc-attr
  where buf_doc-attr.doc-code = wt-rvs-doc.rvs-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:
  delete buf_doc-attr.
end.
for each locbr-doc-attr
  where locbr-doc-attr.doc-code = wt-rvs-doc.rvs-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:
  create buf_doc-attr.
  buffer-copy locbr-doc-attr to buf_doc-attr.
end.
for each buf_doc-line-attr where buf_doc-line-attr.doc-code = wt-rvs-doc.rvs-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:
  delete buf_doc-line-attr.
end.
for each locbr-doc-line-attr where locbr-doc-line-attr.doc-code = wt-rvs-doc.rvs-code
                       no-lock
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:
  create buf_doc-line-attr.
  buffer-copy locbr-doc-line-attr to buf_doc-line-attr.
end.
for each buf_rvs-line-attr where buf_rvs-line-attr.rvs-code = wt-rvs-doc.rvs-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:
  delete buf_rvs-line-attr.
end.
for each locbr-rvs-line-attr where locbr-rvs-line-attr.rvs-code = wt-rvs-doc.rvs-code
                       no-lock
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:
  create buf_rvs-line-attr.
  buffer-copy locbr-rvs-line-attr to buf_rvs-line-attr.
end.

if not available tb-rvs-doc then do:
  create tb-rvs-doc.
end.

/* сохраняем историю изменения документа */
define variable v-old-rvs-doc-status as character no-undo .
define variable v-new-rvs-doc-status as character no-undo .

assign
  v-old-rvs-doc-status = tb-rvs-doc.status_
  v-new-rvs-doc-status = wt-rvs-doc.status_
.

run trg/nwsdochs.p
  (input g#db-num                      /* p-db-num       */
  ,input {&nwsdochs_action_update}     /* p-action-type  */
  ,input wt-rvs-doc.rvs-code           /* p-doc-code     */
  ,input wt-rvs-doc.obj-type           /* p-obj-type     */
  ,input wt-rvs-doc.obj-code           /* p-obj-code     */
  ,input {&table_rvs-doc}              /* p-doc-type     */
  ,input '':u                          /* p-ext-doc-type */
  ,input wt-rvs-doc.fact-date          /* p-fact-date    */
  ,input wt-rvs-doc.state-measure-qnty /* p-fact-qnty    */
  ,input 0                             /* p-fact-base    */
  ,input 0                             /* p-fact-rubl    */
  ,input 0                             /* p-num-line     */
  ,input v-old-rvs-doc-status          /* p-old-status   */
  ,input v-new-rvs-doc-status          /* p-new-status   */
  ,input g#news-source-db              /* p-pck-db-num   */
  ,input p-pck-num                     /* p-pck-pack-num */
  ,input wt-rvs-doc.user-db-num        /* p-user-db-num  */
  ,input wt-rvs-doc.user-name          /* p-user-name    */
  ,input wt-rvs-doc.sys-date           /* p-sys-date     */
  ,input wt-rvs-doc.sys-time           /* p-sys-time     */
  ,input wt-rvs-doc.sys-time-int       /* p-sys-time-int */
  ) no-error .
if error-status :error then do:
  run write-to-log in this-procedure
    (input substitute("&1 &2", error-status :get-message(1), return-value )
    ) .
  undo, return error .
end.


buffer-copy wt-rvs-doc to tb-rvs-doc.

if wt-rvs-doc.rvs-type <> {&rvs-after-doc}
  and ( v-new-rvs-doc-status = {&permitted}
        or v-new-rvs-doc-status = {&rvs-froze}
      )
then do:
  /* в сверках по документу ставим бликировку на сверке "перед", а снимаем блокировку на сверке "после" */
  run trg/lock-rvs.p
    ( input wt-rvs-doc.rvs-code
     ,input "assign-rvs-on=true"
     ,input wt-rvs-doc.rvs-code
     ,input false
    ) no-error.
  if error-status :error then do:
    undo, return error return-value .
  end.
end.

/* -------------------- почистим за собой ------------------------ */
for each locb-rvs-line
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:
  delete locb-rvs-line.
end.
for each locb-rvs-line-pump
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:
  delete locb-rvs-line-pump.
end.
for each locbr-rvs-pump
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:
  delete locbr-rvs-pump.
end.
for each locbr-doc-attr
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:
  delete locbr-doc-attr.
end.
for each locbr-rvs-line-attr
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:
  delete locbr-rvs-line-attr.
end.

/* $Workfile$   E n d */