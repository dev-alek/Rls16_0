block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление банковской выписки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/02/05
Author: Bakhtadze Natalya
Creation date: 08/02/05

*/

TRIGGER PROCEDURE FOR DELETE OF ub.fin-statement .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление банковской выписки".
{ cmp/vssrevis.i "substitute('&1|&2', ub.fin-statement.host-code, ub.fin-statement.sttm-code) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ trg/finsttmh.i }

define buffer buf_sysconf  for ub.sysconf.
define buffer buf_fin-connect for ub.fin-connect.
define buffer buf_fin-statement-line for ub.fin-statement-line.
define buffer buf_fin-statement-attr for ub.fin-statement-attr.
define buffer buf_fin-doc for ub.fin-doc.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news then do:
    find first buf_sysconf no-lock where buf_sysconf.host-code = ub.fin-statement.host-code.
    if buf_sysconf.firm-db-num <> g#db-num
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя удалять запись БАНКОВСКОЙ ВЫПИСКИ в БД, отличной от главной БД фирмы" skip
      "Номер текущей БД" g#db-num "Номер главной БД фирмы" buf_sysconf.firm-db-num
      view-as alert-box error .
      undo main-block, return error .
    end.
  end.



  if (ub.fin-statement.status_ = {&fin-fact}
  OR ub.fin-statement.status_ = {&fin-bank})
  and ub.fin-statement.is-del  <> yes
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Нельзя удалять выписку, закрытую до статуса" ub.fin-statement.status_ skip
      "Фирма" ub.fin-statement.host-code skip
      "Выписка" ub.fin-statement.sttm-code skip
      "Статус выписки" ub.fin-statement.status_ skip
      view-as alert-box error .
    undo main-block, return error .
  end.

  if not g#news
  and ub.fin-statement.status_ <> {&fin-new}
  and ub.fin-statement.status_ <> {&fin-fact} then do:
    run write-fin-statement-history in this-procedure( buffer ub.fin-statement) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при обновлении истории по выписке" skip
        "Фирма" ub.fin-statement.host-code skip
        "Платеж" ub.fin-statement.sttm-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
  end.

  /* удаляем строки платежа */
  for each buf_fin-statement-line where
          buf_fin-statement-line.sttm-code = ub.fin-statement.sttm-code
     AND  buf_fin-statement-line.host-code = ub.fin-statement.host-code
  on error undo main-block, return error
  :

    if buf_fin-statement-line.fin-doc-code > 0 then do:
      find first buf_fin-doc where
              buf_fin-doc.host-code = ub.fin-statement.host-code
          and buf_fin-doc.sttm-code = ub.fin-statement.sttm-code
          and buf_fin-doc.fin-doc-code = buf_fin-statement-line.fin-doc-code.
      assign
      buf_fin-doc.sttm-code = 0.
    end.
    delete buf_fin-statement-line .
  end.

  for each buf_fin-statement-attr where
          buf_fin-statement-attr.sttm-code = ub.fin-statement.sttm-code
     AND  buf_fin-statement-attr.host-code = ub.fin-statement.host-code
  on error undo main-block, return error
  :
    delete buf_fin-statement-attr .
  end.

  if buf_sysconf.firm-db-num <> 0
  then do:
    /* отправляем команду по новостям */
    /*удалиться может в УБД тольо если главная БД фирмы не равна 0 и тогда надо посылать только в "0"*/
    run nws/cmd-del.p
      ( input {&table_fin-statement}
       ,input (buffer ub.fin-statement:handle)
       ,input "0":U
      ) no-error .
    if error-status :error then do:
      return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
    end.
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_fin-statement}
        , input ( buffer ub.fin-statement:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.