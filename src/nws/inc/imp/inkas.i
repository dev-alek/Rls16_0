/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Прием продажи через новости

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
    when "inkas-pay" then do:
      create locb-inkas-pay.
      { nws/impl-nws.i "inkas-pay" "locb-" }
    end.
    when "inkas-pay-desk" then do:
      create locb-inkas-pay-desk.
      { nws/impl-nws.i "inkas-pay-desk" "locb-" }
    end.
    when "inkas-pay-wth" then do:
      create locb-inkas-pay-wth.
      { nws/impl-nws.i "inkas-pay-wth" "locb-" }
    end.
    when "sale-doc" then do:
      create locb-sale-doc.
      { nws/impl-nws.i "sale-doc" "locb-" }
    end.
    when "c-sale-doc" then do:
      create locb-c-sale-doc.
      { nws/impl-nws.i "c-sale-doc" "locb-" }
    end.
    when "chk-doc" then do:
      create locb-chk-doc.
      { nws/impl-nws.i "chk-doc" "locb-" }
    end.
    when "chk-gds" then do:
      create locb-chk-gds.
      { nws/impl-nws.i "chk-gds" "locb-" }
    end.
    when "chk-gds-attr" then do:
      create locb-chk-gds-attr.
      { nws/impl-nws.i "chk-gds-attr" "locb-" }
    end.
    when "chk-pay" then do:
      create locb-chk-pay.
      { nws/impl-nws.i "chk-pay" "locb-" }
    end.
    when "chk-pay-attr" then do:
      create locb-chk-pay-attr.
      { nws/impl-nws.i "chk-pay-attr" "locb-" }
    end.
    when "chk-discnt" then do:
      create locb-chk-discnt.
      { nws/impl-nws.i "chk-discnt" "locb-" }
    end.
     when "chk-discnt-attr" then do:
      create locb-chk-discnt-attr.
      { nws/impl-nws.i "chk-discnt-attr" "locb-" }
    end.
    when "chk-doc-attr" then do:
      create locb-chk-doc-attr.
      { nws/impl-nws.i "chk-doc-attr" "locb-" }
    end.
    when "chk-gds-pay" then do:
      create locb-chk-gds-pay.
      { nws/impl-nws.i "chk-gds-pay" "locb-" }
    end.
    when "c-chk-doc" then do:
      create locb-c-chk-doc.
      { nws/impl-nws.i "c-chk-doc" "locb-" }
    end.
    when "c-chk-gds" then do:
      create locb-c-chk-gds.
      { nws/impl-nws.i "c-chk-gds" "locb-" }
    end.
    when "c-chk-pay" then do:
      create locb-c-chk-pay.
      { nws/impl-nws.i "c-chk-pay" "locb-" }
    end.
    when "c-chk-discnt" then do:
      create locb-c-chk-discnt.
      { nws/impl-nws.i "c-chk-discnt" "locb-" }
    end.
    when "c-chk-doc-attr" then do:
      create locb-c-chk-doc-attr.
      { nws/impl-nws.i "c-chk-doc-attr" "locb-" }
    end.
    when "c-inkas" then do:
      create locb-c-inkas.
      { nws/impl-nws.i "c-inkas" "locb-" }
    end.
    when "c-inkas-pay" then do:
      create locb-c-inkas-pay.
      { nws/impl-nws.i "c-inkas-pay" "locb-" }
    end.
    when "c-inkas-pay-desk" then do:
      create locb-c-inkas-pay-desk.
      { nws/impl-nws.i "c-inkas-pay-desk" "locb-" }
    end.
    when "c-inkas-pay-wth" then do:
      create locb-c-inkas-pay-wth.
      { nws/impl-nws.i "c-inkas-pay-wth" "locb-" }
    end.

    otherwise do:
      message "nws/inc/imp/inkas.i: Не предусмотрен прием таблицы " rec-name skip
              "в составе накладной"
              view-as alert-box error.
      return error "nws/inc/imp/inkas.i: Не предусмотрен прием таблицы " + rec-name + {&new-line} + "в составе накладной".
    end.
  END CASE.
end.


if not available tb-inkas then do:
  create tb-inkas.
end.

/* сохраняем историю изменения документа */
define variable v-old-inkas-status as character no-undo .
define variable v-new-inkas-status as character no-undo .

assign
  v-old-inkas-status = tb-inkas.status_
  v-new-inkas-status = wt-inkas.status_
.

run trg/nwsdochs.p
  (input g#db-num                  /* p-db-num       */
  ,input {&nwsdochs_action_update} /* p-action-type  */
  ,input wt-inkas.inkas-code       /* p-doc-code     */
  ,input wt-inkas.obj-type         /* p-obj-type     */
  ,input wt-inkas.obj-code         /* p-obj-code     */
  ,input {&table_inkas}            /* p-doc-type     */
  ,input '':u                      /* p-ext-doc-type */
  ,input wt-inkas.fact-date        /* p-fact-date    */
  ,input wt-inkas.qnty             /* p-fact-qnty    */
  ,input 0                         /* p-fact-base    */
  ,input 0                         /* p-fact-rubl    */
  ,input 0                         /* p-num-line     */
  ,input v-old-inkas-status        /* p-old-status   */
  ,input v-new-inkas-status        /* p-new-status   */
  ,input g#news-source-db          /* p-pck-db-num   */
  ,input p-pck-num                 /* p-pck-pack-num */
  ,input wt-inkas.user-db-num      /* p-user-db-num  */
  ,input wt-inkas.user-name        /* p-user-name    */
  ,input wt-inkas.sys-date         /* p-sys-date     */
  ,input wt-inkas.sys-time         /* p-sys-time     */
  ,input wt-inkas.sys-time-int     /* p-sys-time-int */
  ) no-error .
if error-status :error then do:
  run write-to-log in this-procedure
    (input substitute("&1 &2", error-status :get-message(1), return-value )
    ) .
  undo, return error .
end.

/* обновляем документ */
buffer-copy wt-inkas to tb-inkas.

/* ------------------------------- inkas-pay ---------------------------------------------- */
for each buf_inkas-pay where buf_inkas-pay.inkas-code = wt-inkas.inkas-code
on error  undo, return error
:
  delete buf_inkas-pay.
end.
for each locb-inkas-pay where locb-inkas-pay.inkas-code = wt-inkas.inkas-code
                        no-lock
on error  undo, return error
:
  create buf_inkas-pay.
  buffer-copy locb-inkas-pay to buf_inkas-pay.
end.
/* ------------------------------- inkas-pay-desk------------------------------------------ */
for each buf_inkas-pay-desk where buf_inkas-pay-desk.inkas-code = wt-inkas.inkas-code
on error  undo, return error
:
  delete buf_inkas-pay-desk.
end.
for each locb-inkas-pay-desk where locb-inkas-pay-desk.inkas-code = wt-inkas.inkas-code
                        no-lock
on error  undo, return error
:
  create buf_inkas-pay-desk.
  buffer-copy locb-inkas-pay-desk to buf_inkas-pay-desk.
end.

/* ------------------------------- inkas-pay-wth------------------------------------------ */
for each buf_inkas-pay-wth where buf_inkas-pay-wth.inkas-code = wt-inkas.inkas-code
on error  undo, return error
:
  delete buf_inkas-pay-wth.
end.
for each locb-inkas-pay-wth where locb-inkas-pay-wth.inkas-code = wt-inkas.inkas-code
                        no-lock
on error  undo, return error
:
  create buf_inkas-pay-wth.
  buffer-copy locb-inkas-pay-wth to buf_inkas-pay-wth.
end.


/* ------------------------------- c-inkas-pay ---------------------------------------------- */
for each buf_c-inkas-pay where buf_c-inkas-pay.inkas-code = wt-inkas.inkas-code
on error  undo, return error
:
  delete buf_c-inkas-pay.
end.
for each locb-c-inkas-pay where locb-c-inkas-pay.inkas-code = wt-inkas.inkas-code
                        no-lock
on error  undo, return error
:
  create buf_c-inkas-pay.
  buffer-copy locb-c-inkas-pay to buf_c-inkas-pay.
end.
/* ------------------------------- c-inkas-pay-desk------------------------------------------ */
for each buf_c-inkas-pay-desk where buf_c-inkas-pay-desk.inkas-code = wt-inkas.inkas-code
on error  undo, return error
:
  delete buf_c-inkas-pay-desk.
end.
for each locb-c-inkas-pay-desk where locb-c-inkas-pay-desk.inkas-code = wt-inkas.inkas-code
                        no-lock
on error  undo, return error
:
  create buf_c-inkas-pay-desk.
  buffer-copy locb-c-inkas-pay-desk to buf_c-inkas-pay-desk.
end.

/* ------------------------------- c-inkas-pay-wth ---------------------------------------------- */
for each buf_c-inkas-pay-wth where buf_c-inkas-pay-wth.inkas-code = wt-inkas.inkas-code
on error  undo, return error
:
  delete buf_c-inkas-pay-wth.
end.
for each locb-c-inkas-pay-wth where locb-c-inkas-pay-wth.inkas-code = wt-inkas.inkas-code
                        no-lock
on error  undo, return error
:
  create buf_c-inkas-pay-wth.
  buffer-copy locb-c-inkas-pay-wth to buf_c-inkas-pay-wth.
end.

/* ------------------------------- sale-doc ---------------------------------------------- */
for each buf_sale-doc where buf_sale-doc.inkas-code = wt-inkas.inkas-code
on error  undo, return error
:
  delete buf_sale-doc.
end.
for each locb-sale-doc where locb-sale-doc.inkas-code = wt-inkas.inkas-code
                        no-lock
on error  undo, return error
:
  create buf_sale-doc.
  buffer-copy locb-sale-doc to buf_sale-doc.
end.

/* ------------------------------- c-sale-doc ---------------------------------------------- */
for each buf_c-sale-doc where buf_c-sale-doc.inkas-code = wt-inkas.inkas-code
on error  undo, return error
:
  delete buf_c-sale-doc.
end.
for each locb-c-sale-doc where locb-c-sale-doc.inkas-code = wt-inkas.inkas-code
                        no-lock
on error  undo, return error
:
  create buf_c-sale-doc.
  buffer-copy locb-c-sale-doc to buf_c-sale-doc.
end.
/* ------------------------------- chk-gds-pay --------------------------------------------- */
for each buf_chk-gds-pay where buf_chk-gds-pay.out-code = wt-inkas.inkas-code
on error  undo, return error
:
  delete buf_chk-gds-pay.
end.
for each locb-chk-gds-pay where locb-chk-gds-pay.out-code = wt-inkas.inkas-code
                      no-lock
on error  undo, return error
:
  create buf_chk-gds-pay.
  buffer-copy locb-chk-gds-pay to buf_chk-gds-pay.
end.

/* ------------------------------- chk-doc ---------------------------------------------- */
for each buf_chk-doc where buf_chk-doc.out-code = wt-inkas.inkas-code
on error  undo, return error
:
  for each buf_chk-doc-attr where buf_chk-doc-attr.doc-code = buf_chk-doc.doc-code
  on error  undo, return error
  :
    delete buf_chk-doc-attr.
  end.
  delete buf_chk-doc.
end.


v-need-saledc = no.
for each locb-chk-doc where locb-chk-doc.out-code = wt-inkas.inkas-code
                      no-lock
on error  undo, return error
:
  create buf_chk-doc.
  buffer-copy locb-chk-doc to buf_chk-doc.
  for each locb-chk-doc-attr where locb-chk-doc-attr.doc-code = buf_chk-doc.doc-code
                      no-lock
  on error  undo, return error
  :
     create buf_chk-doc-attr.
     buffer-copy locb-chk-doc-attr to buf_chk-doc-attr.
  end.
  if buf_chk-doc.d-card <> ""
  and not v-need-saledc
  then do:
    v-need-saledc = yes.
  end.
end.
/* ------------------------------- chk-gds --------------------------------------------- */
for each buf_chk-gds where buf_chk-gds.out-code = wt-inkas.inkas-code
on error  undo, return error
:
  for each buf_chk-gds-attr where buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
      and buf_chk-gds-attr.line-num = buf_chk-gds.line-num
  on error  undo, return error
  :
    delete buf_chk-gds-attr.
  end.
  delete buf_chk-gds.
end.
for each locb-chk-gds where locb-chk-gds.out-code = wt-inkas.inkas-code
                      no-lock
on error  undo, return error
:
  create buf_chk-gds.
  buffer-copy locb-chk-gds to buf_chk-gds.
  for each locb-chk-gds-attr where locb-chk-gds-attr.doc-code = locb-chk-gds.doc-code
      and locb-chk-gds-attr.line-num = locb-chk-gds.line-num
                        no-lock
  on error  undo, return error
  :
    create buf_chk-gds-attr.
    buffer-copy locb-chk-gds-attr to buf_chk-gds-attr.
  end.
end.
/* ------------------------------- chk-pay ---------------------------------------------- */
for each buf_chk-pay where buf_chk-pay.out-code = wt-inkas.inkas-code
on error  undo, return error
:
  for each buf_chk-pay-attr where buf_chk-pay-attr.doc-code = buf_chk-pay.doc-code
      and buf_chk-pay-attr.line-num = buf_chk-pay.line-num
  on error  undo, return error
  :
    delete buf_chk-pay-attr.
  end.
  delete buf_chk-pay.
end.
for each locb-chk-pay where locb-chk-pay.out-code = wt-inkas.inkas-code
                      no-lock
on error  undo, return error
:
  create buf_chk-pay.
  buffer-copy locb-chk-pay to buf_chk-pay.
  for each locb-chk-pay-attr where locb-chk-pay-attr.doc-code = locb-chk-pay.doc-code
      and locb-chk-pay-attr.line-num = locb-chk-pay.line-num
                        no-lock
  on error  undo, return error
  :
    create buf_chk-pay-attr.
    buffer-copy locb-chk-pay-attr to buf_chk-pay-attr.
  end.
end.
/* ------------------------------- chk-discnt --------------------------------------------- */
for each buf_chk-discnt where buf_chk-discnt.out-code = wt-inkas.inkas-code
on error  undo, return error
:
  for each buf_chk-discnt-attr where buf_chk-discnt-attr.doc-code = buf_chk-discnt.doc-code and
    buf_chk-discnt-attr.line-num = buf_chk-discnt.line-num:
    
    delete buf_chk-discnt-attr.
  end. 
  delete buf_chk-discnt.
end.
for each locb-chk-discnt where locb-chk-discnt.out-code = wt-inkas.inkas-code
                      no-lock
on error  undo, return error
:
  create buf_chk-discnt.
  buffer-copy locb-chk-discnt to buf_chk-discnt.
   for each locb-chk-discnt-attr where locb-chk-discnt-attr.doc-code = locb-chk-discnt.doc-code and
    locb-chk-discnt-attr.line-num = locb-chk-discnt.line-num:
    
    create buf_chk-discnt-attr.
    buffer-copy locb-chk-discnt-attr to buf_chk-discnt-attr.
  end.
end.
/* ------------------------------- c-chk-doc-attr --------------------------------------------- */
for each buf_c-chk-doc-attr where buf_c-chk-doc-attr.out-code = wt-inkas.inkas-code
on error  undo, return error
:
  delete buf_c-chk-doc-attr.
end.
for each locb-c-chk-doc-attr where locb-c-chk-doc-attr.out-code = wt-inkas.inkas-code
                      no-lock
on error  undo, return error
:
  create buf_c-chk-doc-attr.
  buffer-copy locb-c-chk-doc-attr to buf_c-chk-doc-attr.
end.

/*для некоторых касс например ipc-servies-plus может быть ситуация когда чек удаляется и рождается снова с таким же кодом   в БД*/
for each locb-c-chk-doc where locb-c-chk-doc.out-code = wt-inkas.inkas-code
                      no-lock:
   find  first buf_c-chk-doc where buf_c-chk-doc.doc-code = locb-c-chk-doc.doc-code
                 and buf_c-chk-doc.out-code = ? no-error.

   if available buf_c-chk-doc then do:
   for each buf_c-chk-gds where buf_c-chk-gds.doc-code = locb-c-chk-doc.doc-code:
     delete buf_c-chk-gds.
   end.
   for each buf_c-chk-pay where buf_c-chk-pay.doc-code = locb-c-chk-doc.doc-code:
     delete buf_c-chk-pay.
   end.
   for each buf_c-chk-discnt where buf_c-chk-discnt.doc-code = locb-c-chk-doc.doc-code:
     delete buf_c-chk-discnt.
   end.
   for each buf_c-chk-doc-attr where buf_c-chk-doc-attr.doc-code = locb-c-chk-doc.doc-code:
     delete buf_c-chk-doc-attr.
   end.
   delete buf_c-chk-doc.
end.
end.




/* ------------------------------- c-chk-doc ---------------------------------------------- */
for each buf_c-chk-doc where buf_c-chk-doc.out-code = wt-inkas.inkas-code
on error  undo, return error
:
  delete buf_c-chk-doc.
end.
for each locb-c-chk-doc where locb-c-chk-doc.out-code = wt-inkas.inkas-code
                      no-lock
on error  undo, return error
:
  create buf_c-chk-doc.
  buffer-copy locb-c-chk-doc to buf_c-chk-doc.
end.
/* ------------------------------- c-chk-gds --------------------------------------------- */
for each buf_c-chk-gds where buf_c-chk-gds.out-code = wt-inkas.inkas-code
on error  undo, return error
:
  delete buf_c-chk-gds.
end.
for each locb-c-chk-gds where locb-c-chk-gds.out-code = wt-inkas.inkas-code
                      no-lock
on error  undo, return error
:
  create buf_c-chk-gds.
  buffer-copy locb-c-chk-gds to buf_c-chk-gds.
end.
/* ------------------------------- c-chk-pay ---------------------------------------------- */
for each buf_c-chk-pay where buf_c-chk-pay.out-code = wt-inkas.inkas-code
on error  undo, return error
:
  delete buf_c-chk-pay.
end.
for each locb-c-chk-pay where locb-c-chk-pay.out-code = wt-inkas.inkas-code
                      no-lock
on error  undo, return error
:
  create buf_c-chk-pay.
  buffer-copy locb-c-chk-pay to buf_c-chk-pay.
end.
/* ------------------------------- c-chk-discnt --------------------------------------------- */
for each buf_c-chk-discnt where buf_c-chk-discnt.out-code = wt-inkas.inkas-code
on error  undo, return error
:
  delete buf_c-chk-discnt.
end.
for each locb-c-chk-discnt where locb-c-chk-discnt.out-code = wt-inkas.inkas-code
                      no-lock
on error  undo, return error
:
  create buf_c-chk-discnt.
  buffer-copy locb-c-chk-discnt to buf_c-chk-discnt.
end.

/*запишем атрибут необходимости расчета ДК - пока команда cmdp-dc еще не пришла*/
if g#db-num = 0
and wt-inkas.status_ = {&fact}
and v-need-saledc
then do:
 { str/tdat-wrt.i
    wt-inkas.inkas-code
    ~{&trdcattr-need-saledc~}
    string(1)
  }
end.

/* ------------------------ почистим за собой ---------------------------------------------- */

for each locb-inkas-pay
on error  undo, return error
:
  delete locb-inkas-pay.
end.
for each locb-c-inkas-pay
on error  undo, return error
:
  delete locb-c-inkas-pay.
end.

for each locb-inkas-pay-desk
on error  undo, return error
:
  delete locb-inkas-pay-desk.
end.
for each locb-c-inkas-pay-desk
on error  undo, return error
:
  delete locb-c-inkas-pay-desk.
end.

for each locb-inkas-pay-wth
on error  undo, return error
:
  delete locb-inkas-pay-wth.
end.
for each locb-c-inkas-pay-wth
on error  undo, return error
:
  delete locb-c-inkas-pay-wth.
end.


for each locb-sale-doc
on error  undo, return error
:
  delete locb-sale-doc.
end.
for each locb-c-sale-doc
on error  undo, return error
:
  delete locb-c-sale-doc.
end.
for each locb-chk-doc
on error  undo, return error
:
  delete locb-chk-doc.
end.
for each locb-chk-gds
on error  undo, return error
:
  delete locb-chk-gds.
end.
for each locb-chk-gds-attr
on error  undo, return error
:
  delete locb-chk-gds-attr.
end.
for each locb-chk-pay
on error  undo, return error
:
  delete locb-chk-pay.
end.
for each locb-chk-pay-attr
on error  undo, return error
:
  delete locb-chk-pay-attr.
end.
for each locb-chk-discnt
on error  undo, return error
:
  delete locb-chk-discnt.
end.
for each locb-chk-doc-attr
on error  undo, return error
:
  delete locb-chk-doc-attr.
end.
for each locb-chk-gds-pay
on error  undo, return error
:
  delete locb-chk-gds-pay.
end.
for each locb-c-chk-doc
on error  undo, return error
:
  delete locb-c-chk-doc.
end.
for each locb-c-chk-gds
on error  undo, return error
:
  delete locb-c-chk-gds.
end.
for each locb-c-chk-pay
on error  undo, return error
:
  delete locb-c-chk-pay.
end.
for each locb-c-chk-discnt
on error  undo, return error
:
  delete locb-c-chk-discnt.
end.
for each locb-c-chk-doc-attr
on error  undo, return error
:
  delete locb-c-chk-doc-attr.
end.


/* $Workfile$ e n d */