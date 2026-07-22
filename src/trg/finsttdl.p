block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Удаление выписки закрытой до факт

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/19/06
Author: Bakhtadze Natalya
Creation date: 11/19/06

*/

define input parameter p-host-code like ub.fin-statement.host-code no-undo .
define input parameter p-sttm-code like ub.fin-statement.sttm-code no-undo .
define input parameter p-fact-delete as logical no-undo . /*yes - удаление закрытого на факт*/
define input parameter p-silence as logical no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Удаление выписки закрытой до факт ".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ ref/fs-attr.i }
{ trg/finsttmh.i }


do
on error undo, return error return-value
:
  define variable v-mes as character no-undo .
  define variable v-status_ like ub.fin-statement.status_ no-undo .

  define buffer buf_fin-statement for ub.fin-statement .

  find first buf_fin-statement exclusive-lock where
            buf_fin-statement.host-code = p-host-code
        AND buf_fin-statement.sttm-code = p-sttm-code
    no-error .
  if not available buf_fin-statement then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Фирма" p-host-code
      "Выписка" p-sttm-code skip
      view-as alert-box error .
    undo, return error .
  end.
  if (buf_fin-statement.status_ = {&fin-fact}
  and p-fact-delete = no)
  or
    (buf_fin-statement.status_ <> {&fin-fact}
  and p-fact-delete = yes)
  or (not g#news and p-fact-delete = ?)
    then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Фирма" p-host-code
      "Платеж" p-sttm-code skip
      "Статус" buf_fin-statement.status_
      "Параметр p-fact-delete" p-fact-delete
      view-as alert-box error .
    undo, return error .
  end.
  if p-fact-delete = yes then do:
    assign
    buf_fin-statement.is-del = true
    /*простановка ? в атрибут где bde-date осуществляется fin-statementh.i */
    .

    /*создаем копию*/
    if not g#news then do:
      run write-fin-statement-history in this-procedure ( buffer buf_fin-statement) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при копировании в историю удаляемых выписок" skip
          view-as alert-box error .
        undo, return error.
      end.
    end.
  end. /*p-fact-delete*/
  delete buf_fin-statement no-error .
  if error-status:error then do:
    assign
    v-mes =  substitute("Выписка: код фирмы &1, вн № &2, статус &3: &4"
                                 , p-host-code
                                 , p-sttm-code
                                 , v-status_
                                 ,  return-value ).

    if not p-silence then
    message v-mes
    view-as alert-box error .
    undo, return error v-mes.
  end.
end.