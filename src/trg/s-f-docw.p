block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись счета-фактуры

Автор: Чернова Светлана Александровна
Дата создания: 10/06/05
Author: Svetlana Chernova
Creation date: 10/06/05

*/


TRIGGER PROCEDURE FOR WRITE OF ub.schet-fact-doc OLD old_schet-fact-doc.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись счета-фактуры".
{ cmp/vssrevis.i "substitute('&1|&2|&3', ub.schet-fact-doc.doc-code, ub.schet-fact-doc.doc-date, ub.schet-fact-doc.status_) " }
{ cmp/trg-def.i }

define buffer buf_sysconf for ub.sysconf  .
define variable v-s-f-office       as logical   no-undo .
define variable p-sys-time1         as character no-undo .
define buffer buf_c-schet-fact-doc  for ub.c-schet-fact-doc.
define buffer buf_c-schet-fact-line for ub.c-schet-fact-line.
define buffer buf_schet-fact-line   for ub.schet-fact-line.


main-block :
do transaction
on error undo main-block, return error
:
/* Если УБД - активная сторона */
find first  buf_sysconf no-lock where
            buf_sysconf.host-code = ub.schet-fact-doc.host-code no-error .
if error-status :error then do:
    message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    ""
    view-as alert-box error
    .
    undo,return error .
end.

v-s-f-office =  buf_sysconf.gen-s-f-office .

    if v-s-f-office = false  then do:  /* УБД - активная сторона */
      if not g#news and g#db-num <> 0 then do:
        if ub.schet-fact-doc.status_ = {&fact} then do: /* закрыли - теперь шлем */
          /* пишем историю */
          run proc-hist in this-procedure .
          /* отправляем в новости */
          run str/callnews.p (input {&table_schet-fact-doc} , input (buffer ub.schet-fact-doc:handle) ) no-error .
          if error-status:error then do:
            message
              vss-workfile vss-revision vss-description skip   "Ошибка при передаче в новости счета-фактуры" skip
              error-status :get-message(1) skip    return-value skip     view-as alert-box error .
            undo, return error.
          end.
          run str/callnews.p (input {&table_c-schet-fact-doc} , input (buffer buf_c-schet-fact-doc:handle) )  no-error .
          if error-status:error then do:
            message
              vss-workfile vss-revision vss-description skip   "Ошибка при передаче в новости истории счета-фактуры" skip
              error-status :get-message(1) skip    return-value skip     view-as alert-box error .
            undo, return error.
          end.
         end.
      end.
      if not g#news and  g#db-num = 0
         and ub.schet-fact-doc.status_ = {&fact} then do:
          if  ub.schet-fact-doc.db-num <> 0  then do: /* Посылаем только шапку cmd-bush */
                run trg/cmd-s-fr.p (input ub.schet-fact-doc.doc-code, input ub.schet-fact-doc.db-num) no-error .
                if error-status :error then do:
                    message
                      vss-workfile vss-revision vss-description skip
                      error-status :get-message(1) skip
                      return-value skip
                      ""
                      view-as alert-box error
                    .
                    return error.
                end.
          end.
          run proc-hist in this-procedure .
      end.
    end.
    else do: /* Создание Только в офисе */
      if not g#news and ub.schet-fact-doc.status_ = {&fact} then do:
         run proc-hist in this-procedure .
      end.
    end.

end. /*main-block*/


procedure proc-hist :

  do
  on error undo, return error return-value
  :
  create buf_c-schet-fact-doc .
  BUFFER-COPY ub.schet-fact-doc TO buf_c-schet-fact-doc .
  assign  buf_c-schet-fact-doc.chip-num  = next-value (s-corr-chip, {&db-name_schema}) .
  { gbl/curdburt.i
    buf_c-schet-fact-doc.corr-user-db-num
    buf_c-schet-fact-doc.corr-user-name
    buf_c-schet-fact-doc.corr-date
    p-sys-time1
    buf_c-schet-fact-doc.corr-time
  }

  for each buf_schet-fact-line no-lock
    where buf_schet-fact-line.db-num   = ub.schet-fact-doc.db-num
      and buf_schet-fact-line.doc-code = ub.schet-fact-doc.doc-code
    :
    create buf_c-schet-fact-line .
    BUFFER-COPY buf_schet-fact-line TO buf_c-schet-fact-line .
    assign
      buf_c-schet-fact-line.chip-num         = buf_c-schet-fact-doc.chip-num
      buf_c-schet-fact-line.corr-user-db-num = buf_c-schet-fact-doc.corr-user-db-num
    .
  end.
    run str/calloxml.p ( input {&nwsdochs_action_update}, input {&table_schet-fact-doc}, input ( buffer ub.schet-fact-doc:handle )) no-error.
    if error-status :error then do:
      undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4", {&new-line}, vss-workfile, return-value, error-status :get-message ( 1 ) ).
    end.
    run str/calloxml.p ( input {&nwsdochs_action_update}, input {&table_c-schet-fact-doc}, input ( buffer buf_c-schet-fact-doc:handle )) no-error.
    if error-status :error then do:
      undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4", {&new-line}, vss-workfile, return-value, error-status :get-message ( 1 ) ).
    end.

  end.

end procedure. /* proc-hist */