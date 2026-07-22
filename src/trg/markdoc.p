block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Зарегистрировать удаление или изменение закрытого документа

Автор: Чернова Светлана Александровна
Дата создания: 09/24/07
Author: Svetlana Chernova
Creation date: 09/24/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 09/09/03

*/

define input  parameter p-doc-code as character no-undo .
define input  parameter p-action   as character no-undo .

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Зарегистрировать удаление или изменение закрытого документа".
{ cmp/vssrevis.i "substitute('&1|&2',p-doc-code,p-action)" }
{ cmp/trg-def.i  }
{ gbl/waitfram.i }

define buffer buf_trn-doc for ub.trn-doc .

do transaction
on error undo, return error return-value
:

  run waitfram-show in this-procedure
    (input substitute("Регистрация изменения/удаления документа &1", p-doc-code)
    ) .

  /* найти документ */
  find first buf_trn-doc exclusive-lock
    where buf_trn-doc.doc-code = p-doc-code
    no-error .
  if not available buf_trn-doc
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден документ" skip
      "Документ" p-doc-code skip
      "Действие" p-action skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if buf_trn-doc.status_ <> {&fact}
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Документ не закрыт до статуса" {&fact} skip
      "Документ" p-doc-code skip
      "Действие" p-action skip
      "Статус" buf_trn-doc.status_ skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  /* проверить заданное действие */
  if p-action = ?
  or lookup(p-action, 'doc-delete':u + {&comma-char} + 'doc-change':u) = 0
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Неизвестное действие" skip
      "Документ" p-doc-code skip
      "Действие" p-action skip
      view-as alert-box error .
    undo, return error return-value .
  end.


  if p-action = 'doc-change':u
  then do:
    run waitfram-show in this-procedure
      (input substitute("Регистрация изменения шапки документа &1", p-doc-code)
      ) .
    /* для действия изменение - следует перерассчитать шапку документа */
    run trg/nu_trnhd.p
      (input p-doc-code /* p-doc-code */
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при выполнении процедуры nu_trnhd.p" skip
        "Документ" p-doc-code skip
        view-as alert-box .
      undo, return error .
    end.
  end.


  /* при изменении документа */
  /* если существует запись по расчету архива - ничего не делаем */
  /* если отсутствует запись по расчету архива - помечаем архив для перерасчета с даты документа */

  /* при удалении документа */
  /* если существует запись по расчету архива - удаляем запись */
  /* если не существует записи по расчету архива - помечаем архив для перерасчета с даты документа */


  /* удаляется информация о необходимости расчета документа */
  /* или складской архив по товарам помечается, как требующий перерасчета */
  run waitfram-show in this-procedure
    (input substitute("Регистрация документа &1 в складском архиве по товарам", p-doc-code)
    ) .
  run trg/bd_arh.p
    (input buf_trn-doc.doc-code  /* p-doc-code   */
    ,input {&table_trn-doc}      /* p-table-name */
    ,input buf_trn-doc.obj-type  /* p-obj-type   */
    ,input buf_trn-doc.obj-code  /* p-obj-code   */
    ,input buf_trn-doc.fact-date /* p-fact-date  */
    ,input p-action              /* p-action     */
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры bd_arh.p" skip
      "Документ" buf_trn-doc.doc-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.

  /* удаляется информация о необходимости расчета документа */
  /* или складской архив по поставщикам помечается, как требующий перерасчета */
  run waitfram-show in this-procedure
    (input substitute("Регистрация документа &1 в складском архиве по поставщикам", p-doc-code)
    ) .
  run trg/bd_ahsp.p
    (input buf_trn-doc.doc-code  /* p-doc-code   */
    ,input {&table_trn-doc}      /* p-table-name */
    ,input buf_trn-doc.obj-type  /* p-obj-type   */
    ,input buf_trn-doc.obj-code  /* p-obj-code   */
    ,input buf_trn-doc.fact-date /* p-fact-date  */
    ,input p-action              /* p-action     */
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры bd_ahsp.p" skip
      "Документ" buf_trn-doc.doc-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.

  /* удаляется информация о необходимости расчета документа */
  /* или складской архив по типам приобретения помечается, как требующий перерасчета */
  run waitfram-show in this-procedure
    (input substitute("Регистрация документа &1 в складском архиве по типам приобретения", p-doc-code)
    ) .
  run trg/bd_aht.p
    (input buf_trn-doc.doc-code  /* p-doc-code   */
    ,input {&table_trn-doc}      /* p-table-name */
    ,input buf_trn-doc.obj-type  /* p-obj-type   */
    ,input buf_trn-doc.obj-code  /* p-obj-code   */
    ,input buf_trn-doc.fact-date /* p-fact-date  */
    ,input p-action              /* p-action     */
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры bd_arh.p" skip
      "Документ" buf_trn-doc.doc-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.

  /* при удалении документа, помечаем межфирменные архивы, как требующие перерасчета */
  define variable hold-value as character no-undo .
  define variable hold-type  as character no-undo.

  define variable v-holding as logical   no-undo .

  { gbl/conf-rd.i
    "'holding'"
    0
    "''"
    0
    "''"
    "''"
    "''"
    no
    hold-value
    hold-type
    no-error
  }
  if  ( not error-status:error )
  and hold-value = "yes"
  then do:
    assign
      v-holding = true
    .
  end.
  else do:
    assign
      v-holding = false
    .
  end.

  if  g#db-num = 0
  and v-holding = true
  then do:
    run waitfram-show in this-procedure
      (input substitute("Регистрация документа &1 в межфирменных архивах", p-doc-code)
      ) .
    run trg/bd_hold.p
      (input buf_trn-doc.doc-code  /* p-doc-code  */
      ,input buf_trn-doc.fact-date /* p-fact-date */
      ,input p-action              /* p-action    */
      ).
  end.


  /* помечать переоценки, закрытые после нашего документа как требующие перерасчета */
  run waitfram-show in this-procedure
    (input substitute("Регистрация изменения переоценок", p-doc-code)
    ) .
  run trg/mark-prc.p
    (input  buf_trn-doc.doc-code   /* p-doc-code   */
    ,input  buf_trn-doc.fact-order /* p-fact-order */
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры mark-prc.p"  skip
      "Документ" buf_trn-doc.doc-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.

  run waitfram-hide in this-procedure .

end.