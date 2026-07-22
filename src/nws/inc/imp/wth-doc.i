/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Прием в новостях док-тов МЦ

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
    when "wth-line" then do:
      create locb-wth-line.
      { nws/impl-nws.i "wth-line" "locb-" }
    end.
    when "wth-dtl" then do:
      create locb-wth-dtl.
      { nws/impl-nws.i "wth-dtl" "locb-" }
    end.
    when "wth-parts" then do:
      create locb-wth-parts.
      { nws/impl-nws.i "wth-parts" "locb-" }
    end.
    when "wth-doc-attr" then do:
      create locb-wth-doc-attr.
      { nws/impl-nws.i "wth-doc-attr" "locb-" }
    end.
    when "chk-doc" then do:
      create locbw-chk-doc.
      { nws/impl-nws.i "chk-doc" "locbw-" }
    end.
    when "chk-pay" then do:
      create locbw-chk-pay.
      { nws/impl-nws.i "chk-pay" "locbw-" }
    end.
    when "c-chk-doc" then do:
      create locbw-c-chk-doc.
      { nws/impl-nws.i "c-chk-doc" "locbw-" }
    end.
    when "c-chk-pay" then do:
      create locbw-c-chk-pay.
      { nws/impl-nws.i "c-chk-pay" "locbw-" }
    end.
    when "c-wth-doc" then do:
      create locbw-c-wth-doc.
      { nws/impl-nws.i "c-wth-doc" "locbw-" }
    end.
    when "c-wth-line" then do:
      create locbw-c-wth-line.
      { nws/impl-nws.i "c-wth-line" "locbw-" }
    end.
    when "c-wth-dtl" then do:
      create locbw-c-wth-dtl.
      { nws/impl-nws.i "c-wth-dtl" "locbw-" }
    end.
    when "c-wth-parts" then do:
      create locbw-c-wth-parts.
      { nws/impl-nws.i "c-wth-parts" "locbw-" }
    end.
    when "inkas-pay-wth" then do:
      create locbw-inkas-pay-wth.
      { nws/impl-nws.i "inkas-pay-wth" "locbw-" }
    end.
    when "c-inkas-pay-wth" then do:
      create locbw-c-inkas-pay-wth.
      { nws/impl-nws.i "c-inkas-pay-wth" "locbw-" }
    end.



    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе документа мат. ценностей"
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

if not available tb-wth-doc then do:
  create tb-wth-doc.
end.
else do:
  /* По новостям может придти только изменение(закрытие на факт) только внутреннего прихода. Резервирования по нему нет.
  Документ закрытый на факт изменять нельзя никогда */
  if tb-wth-doc.status_ = {&fact} then  return error substitute("Документ &1 уже закрыт на факт." ,tb-wth-doc.doc-code).
end.

/* сохраняем историю изменения документа */
define variable v-old-wth-doc-status as character no-undo .
define variable v-new-wth-doc-status as character no-undo .

assign
  v-old-wth-doc-status = tb-wth-doc.status_
  v-new-wth-doc-status = wt-wth-doc.status_
.

run trg/nwsdochs.p
  (input g#db-num                  /* p-db-num       */
  ,input {&nwsdochs_action_update} /* p-action-type  */
  ,input wt-wth-doc.doc-code       /* p-doc-code     */
  ,input wt-wth-doc.obj-type       /* p-obj-type     */
  ,input wt-wth-doc.obj-code       /* p-obj-code     */
  ,input {&table_wth-doc}          /* p-doc-type     */
  ,input ""                        /* p-ext-doc-type */
  ,input wt-wth-doc.fact-date      /* p-fact-date    */
  ,input wt-wth-doc.fact-sum       /* p-fact-qnty    */
  ,input 0                         /* p-fact-base    */
  ,input 0                         /* p-fact-rubl    */
  ,input 0                         /* p-num-line     */
  ,input v-old-wth-doc-status      /* p-old-status   */
  ,input v-new-wth-doc-status      /* p-new-status   */
  ,input g#news-source-db          /* p-pck-db-num   */
  ,input p-pck-num                 /* p-pck-pack-num */
  ,input wt-wth-doc.user-db-num    /* p-user-db-num  */
  ,input wt-wth-doc.user-name      /* p-user-name    */
  ,input wt-wth-doc.sys-date       /* p-sys-date     */
  ,input wt-wth-doc.sys-time       /* p-sys-time     */
  ,input wt-wth-doc.sys-time-int   /* p-sys-time-int */
  ) no-error .
if error-status :error then do:
  run write-to-log in this-procedure
    (input substitute("&1 &2", error-status :get-message(1), return-value )
    ) .
  undo, return error .
end.

/* обновляем документ */
buffer-copy wt-wth-doc to tb-wth-doc.

/* ------------------------------- wth-dtl ---------------------------------------------- */
on delete of ub.wth-dtl override do: end.

for each buf_wth-dtl where buf_wth-dtl.doc-code = wt-wth-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_wth-dtl.
end.
for each locb-wth-dtl where locb-wth-dtl.doc-code = wt-wth-doc.doc-code
                      no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_wth-dtl.
  buffer-copy locb-wth-dtl to buf_wth-dtl.
end.

/* ------------------------------- wth-parts ---------------------------------------------- */
on delete of ub.wth-parts override do: end.
for each buf_wth-parts where buf_wth-parts.out-code = wt-wth-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_wth-parts no-error.
  if error-status:error then return error return-value.
end.
/*резервирование.*/
run trg/wthrspt.p (table locb-wth-parts
                  , yes ) no-error.
if error-status :error
then do:
  run write-to-log in this-procedure
    (input substitute("&1 &2", error-status:get-message(1), return-value)
    ) .
  undo, return error
    substitute("Ошибка при установке резервов по документу &1. &3 &4 " ,
                wt-wth-doc.doc-code  ,
                return-value ,
                error-status:get-message(1))
    .
end.
             /*резервируются только нормальные партии. а недовоз по внутреннему перемещению просто копируется*/
for each locb-wth-parts where locb-wth-parts.out-code = wt-wth-doc.doc-code and locb-wth-parts.stts = 1
                      no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_wth-parts.
  buffer-copy locb-wth-parts to buf_wth-parts.
end.


/* ------------------------------- wth-line ---------------------------------------------- */
on delete of ub.wth-line override do: end.
on delete of ub.c-chk-doc override do: end.
on delete of ub.c-chk-pay override do: end.

for each buf_wth-line where buf_wth-line.doc-code = wt-wth-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_wth-line.
end.
for each locb-wth-line where locb-wth-line.doc-code = wt-wth-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_wth-line.
  buffer-copy locb-wth-line to buf_wth-line.
end.
/* ------------------------------- wth-doc-attr ---------------------------------------------- */
on delete of ub.wth-doc-attr override do: end.

for each buf_wth-doc-attr where buf_wth-doc-attr.doc-code = wt-wth-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_wth-doc-attr.
end.
for each locb-wth-doc-attr where locb-wth-doc-attr.doc-code = wt-wth-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_wth-doc-attr.
  buffer-copy locb-wth-doc-attr to buf_wth-doc-attr.
end.

/* ------------------------------- chk-doc ---------------------------------------------- */
on delete of ub.chk-doc override do: end.
for each buf_chk-doc where buf_chk-doc.out-code = wt-wth-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
   for each buf_c-chk-doc where buf_c-chk-doc.doc-code = buf_chk-doc.doc-code:
     delete buf_c-chk-doc.
   end.
   for each buf_c-chk-pay where buf_c-chk-pay.doc-code = buf_chk-doc.doc-code:
     delete buf_c-chk-pay.
   end.
  delete buf_chk-doc.
end.
for each locb-chk-doc where locb-chk-doc.out-code = wt-wth-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  for each buf_c-chk-doc where buf_c-chk-doc.doc-code = locb-chk-doc.doc-code:
    delete buf_c-chk-doc.
  end.
  for each buf_c-chk-pay where buf_c-chk-pay.doc-code = locb-chk-doc.doc-code:
    delete buf_c-chk-pay.
  end.
  create buf_chk-doc.
  buffer-copy locb-chk-doc to buf_chk-doc.
end.
/* ------------------------------- chk-pay ---------------------------------------------- */
on delete of ub.chk-pay override do: end.
for each buf_chk-pay where buf_chk-pay.out-code = wt-wth-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_chk-pay.
end.
for each locb-chk-pay where locb-chk-pay.out-code = wt-wth-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_chk-pay.
  buffer-copy locb-chk-pay to buf_chk-pay.
end.

/* ------------------------------- c-chk-doc ---------------------------------------------- */
for each locb-c-chk-doc where locb-c-chk-doc.out-code = wt-wth-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
   for each buf_c-chk-doc where buf_c-chk-doc.doc-code = locb-c-chk-doc.doc-code:
     delete buf_c-chk-doc.
   end.
   for each buf_c-chk-pay where buf_c-chk-pay.doc-code = locb-c-chk-doc.doc-code:
     delete buf_c-chk-pay.
   end.
  create buf_c-chk-doc.
  buffer-copy locb-c-chk-doc to buf_c-chk-doc.
end.
/* ------------------------------- c-chk-pay ---------------------------------------------- */

for each buf_c-chk-pay where buf_c-chk-pay.out-code = wt-wth-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-chk-pay.
end.

for each locb-c-chk-pay where locb-c-chk-pay.out-code = wt-wth-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-chk-pay.
  buffer-copy locb-c-chk-pay to buf_c-chk-pay.
end.

/* ------------------------------- c-wth-doc ---------------------------------------------- */
on delete of ub.c-wth-doc override do: end.

for each buf_c-wth-doc where buf_c-wth-doc.doc-code = wt-wth-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-wth-doc.
end.
for each locbw-c-wth-doc where locbw-c-wth-doc.doc-code = wt-wth-doc.doc-code
                      no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-wth-doc.
  buffer-copy locbw-c-wth-doc to buf_c-wth-doc.
end.


/* ------------------------------- c-wth-dtl ---------------------------------------------- */
for each buf_c-wth-dtl where buf_c-wth-dtl.doc-code = wt-wth-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-wth-dtl.
end.
for each locbw-c-wth-dtl where locbw-c-wth-dtl.doc-code = wt-wth-doc.doc-code
                      no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-wth-dtl.
  buffer-copy locbw-c-wth-dtl to buf_c-wth-dtl.
end.
/* ------------------------------- c-wth-parts ---------------------------------------------- */
for each buf_c-wth-parts where buf_c-wth-parts.out-code = wt-wth-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-wth-parts.
end.
for each locbw-c-wth-parts where locbw-c-wth-parts.out-code = wt-wth-doc.doc-code
                      no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-wth-parts.
  buffer-copy locbw-c-wth-parts to buf_c-wth-parts.
end.

/* ------------------------------- c-wth-line ---------------------------------------------- */
on delete of ub.c-wth-line override do: end.
for each buf_c-wth-line where buf_c-wth-line.doc-code = wt-wth-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-wth-line.
end.
for each locbw-c-wth-line where locbw-c-wth-line.doc-code = wt-wth-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-wth-line.
  buffer-copy locbw-c-wth-line to buf_c-wth-line.
end.


/* ------------------------------- inkas-pay-wth------------------------------------------ */
for each buf_inkas-pay-wth where buf_inkas-pay-wth.inkas-code = wt-wth-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :

  delete buf_inkas-pay-wth.
end.
for each locb-inkas-pay-wth where locb-inkas-pay-wth.inkas-code = wt-wth-doc.doc-code
                        no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :

  create buf_inkas-pay-wth.
  buffer-copy locb-inkas-pay-wth to buf_inkas-pay-wth.
end.



/* Резервирование  ***  СМ ВЫШЕ  ***   */
/*run str/nwswthrs.p ( tb-wth-doc.doc-code
                    ) no-error.
if error-status :error
then do:
  run write-to-log in this-procedure
    (input substitute("&1 &2", error-status:get-message(1), return-value)
    ) .
  undo, return error
    substitute("Ошибка при установке резервов по документу &1. &3 &4 " ,
                wt-wth-doc.doc-code  ,
                return-value ,
                error-status:get-message(1))
    .
end.
*/

/* ------------------------ почистим за собой ---------------------------------------------- */

for each locb-wth-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-wth-line.
end.
for each locb-wth-dtl
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-wth-dtl.
end.
for each locb-wth-parts
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-wth-parts.
end.

for each locbw-chk-doc
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locbw-chk-doc.
end.
for each locbw-chk-pay
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locbw-chk-pay.
end.
for each locbw-c-chk-doc
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locbw-c-chk-doc.
end.
for each locbw-c-chk-pay
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locbw-c-chk-pay.
end.
for each locbw-c-wth-doc
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locbw-c-wth-doc.
end.
for each locbw-c-wth-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locbw-c-wth-line.
end.
for each locbw-c-wth-dtl
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locbw-c-wth-dtl.
end.
for each locbw-c-wth-parts
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locbw-c-wth-parts.
end.
for each locbw-inkas-pay-wth
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locbw-inkas-pay-wth.
end.
for each locbw-c-inkas-pay-wth
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locbw-c-inkas-pay-wth.
end.





/* $Workfile$ */