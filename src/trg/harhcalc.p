block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Первоначальный расчет межфирменных архивов

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/11/06

*/

define input  parameter p-cat-code       like ub.hold-time.cat-code no-undo .
define input  parameter p-lock-code      as character no-undo .
define input  parameter p-btpr-type-code as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Первоначальный расчет межфирменных архивов".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/holdattr.i }
{ trg/harhcrht.i }
{ gbl/cur-time.i }
{ gbl/waitfram.i }

define variable conf-par     as character no-undo .
define variable par-type     as character no-undo .
define variable v-month      as integer   no-undo .
define variable v-year       as integer   no-undo .
define variable lok          as logical   no-undo .
define variable v-begin-date as date      no-undo .

define buffer del_hold-time for ub.hold-time .
define buffer del_hold-trn for ub.hold-trn .
define buffer del_hold-goods for ub.hold-goods .
define buffer del_hold-gds-grp for ub.hold-gds-grp .
define buffer del_hold-purch for ub.hold-purch .
define buffer del_hold-purch-grp for ub.hold-purch-grp .
define buffer del_hold-purch-supp for ub.hold-purch-supp .
define buffer del_hold-purch-supp-gds for ub.hold-purch-supp-gds .
define buffer del_hold-sale for ub.hold-sale .
define buffer del_hold-sale-grp for ub.hold-sale-grp .
define buffer buf_trn-doc for ub.trn-doc .
define buffer buf_db for ub.db .
define buffer buf_clients for ub.clients .

/* процедуру можно запустить только если задан конфигурационный параметр holding */
do
on error undo, return error
:

  { gbl/conf-rd.i
    'holding'
    0
    "''"
    0
    "''"
    "''"
    "''"
    yes
    conf-par
    par-type
    no-error
  }
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при чтении параметра разрешены межфирменные архивы" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.

  if lookup(conf-par, 'true,yes') = 0
  then do:
    message
      "Межфирменные архивы запрещены параметром конфигурации" skip
      view-as alert-box information .
    return.
  end.

  run gbl/d-inpmnt.w
    (input ""
    ,input ?
    ,input-output v-month
    ,input-output v-year
    ,output lok
    ).
  if lok <> true
  then do:
    message
      "Не задана дата начала расчета межфирменных архивов" skip
      view-as alert-box information .
    return .
  end.

  assign
    v-begin-date = date(v-month, 1, v-year)
  .
  if v-begin-date = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при задании даты начала расчета межфирменных архивов" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.

  define variable v-ok as logical   no-undo .
  message
    "ВНИМАНИЕ" skip
    "У вас должна быть работоспособная резервная копия базы данных" skip
    "Это последний вопрос перед инициализацией межфирменного архива" skip
    "" skip
    "Будет произведено УДАЛЕНИЕ архива и расчет с даты" string(v-begin-date, '99/99/9999':u) skip
    "Продолжить?" skip
    view-as alert-box question buttons yes-no update v-ok .
  if v-ok <> true
  then do:
    undo, return error return-value .
  end.

  /* todo проверить не производиться ли уже расчет в настоящий момент ? */
  run holdattr-write in this-procedure
    (input p-cat-code
    ,input {&hold-attr-is-calc}
    ,input 'true':u
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при записи атрибута - первоначальный расчет межфирменных архивов" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
  /*запишем дату перв расчета архива */

  run holdattr-write in this-procedure
    (input p-cat-code
    ,input {&hold-attr-begin-date}
    ,input string(v-begin-date, '99/99/9999':u)
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при записи даты начала межфирменных архивов" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.

  /*произведем расчет архивов по всем объектам*/

  /*сначала полностью удалим все архивы*/

  for each del_hold-time
    where del_hold-time.cat-code = p-cat-code
  on error undo, return error
  :
    delete del_hold-time .
  end.

  for each del_hold-trn
    where del_hold-trn.cat-code = p-cat-code
  on error undo, return error
  :
    delete del_hold-trn .
  end.
  for each del_hold-goods
    where del_hold-goods.cat-code = p-cat-code
  on error undo, return error
  :
    delete del_hold-goods .
  end.
  for each del_hold-gds-grp
    where del_hold-gds-grp.cat-code = p-cat-code
  on error undo, return error
  :
    delete del_hold-gds-grp .
  end.
  for each del_hold-purch
    where del_hold-purch.cat-code = p-cat-code
  on error undo, return error
  :
    delete del_hold-purch .
  end.
  for each del_hold-purch-grp
    where del_hold-purch-grp.cat-code = p-cat-code
  on error undo, return error
  :
    delete del_hold-purch-grp .
  end.
  for each del_hold-purch-supp
    where del_hold-purch-supp.cat-code = p-cat-code
  on error undo, return error
  :
    delete del_hold-purch-supp .
  end.
  for each del_hold-purch-supp-gds
    where del_hold-purch-supp-gds.cat-code = p-cat-code
  on error undo, return error
  :
    delete del_hold-purch-supp-gds .
  end.
  for each del_hold-sale
    where del_hold-sale.cat-code = p-cat-code
  on error undo, return error
  :
    delete del_hold-sale .
  end.
  for each del_hold-sale-grp
    where del_hold-sale-grp.cat-code = p-cat-code
  on error undo, return error
  :
    delete del_hold-sale-grp .
  end.

  for each buf_db no-lock
  ,each buf_clients no-lock
    where buf_clients.db-num = buf_db.db-num
  ,each buf_trn-doc no-lock
    where buf_trn-doc.obj-type = buf_clients.obj-type
      and buf_trn-doc.obj-code = buf_clients.obj-code
      and buf_trn-doc.status_ = {&fact}
      and buf_trn-doc.fact-date >= v-begin-date
  on error undo, return error
  :
    run waitfram-show in this-procedure
      (input substitute("Расчет архивов по категории &1. Документ &2"
             ,p-cat-code
             ,buf_trn-doc.doc-code
             )
      ) .

    do transaction
    on error undo, return error
    :
      define buffer buf_batchprocess for ub.batchprocess .
      define buffer update_batchprocess for ub.batchprocess .

      find first buf_BatchProcess exclusive-lock
        where buf_BatchProcess.bp_type     = p-btpr-type-code
          and buf_BatchProcess.bp_status   = {&btpr-normal}
          and buf_batchprocess.charkey_one = buf_trn-doc.doc-code
        no-error .
      if available buf_BatchProcess
      then do:
        /* update batchprocess record status as executing and deleted */
        { trg/btpr_upd.i
          &btpr-status="executing_deleted"
          &btpr-table="update_batchprocess"
          &btpr-rowid="rowid(buf_batchprocess)"
        }
      end.

      run trg/harhtclc.p
        (input p-cat-code           /* p-cat-code       */
        ,input p-lock-code          /* p-lock-code      */
        ,input p-btpr-type-code     /* p-btpr-type-code */
        ,input buf_trn-doc.doc-code /* p-doc-code       */
        ) no-error.
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          string       ("Ошибка при первоначальном расчете межфирменных архивов:" + {&new-line} +
                        "cat-code:" + {&space-char} + string(p-cat-code) + {&new-line} +
                        "документ:" + {&space-char} + buf_trn-doc.doc-code + {&new-line}
                        )
        view-as alert-box error .
        undo, return error
          ("Ошибка при первоначальном расчете межфирменных архивов:" + {&new-line} +
                        "cat-code:" + {&space-char} + string(p-cat-code) + {&new-line} +
                        "документ:" + {&space-char} + buf_trn-doc.doc-code + {&new-line}
                        ).
      end.
    end.
  end.

  run holdattr-write in this-procedure
    (input p-cat-code
    ,input {&hold-attr-is-calc}
    ,input 'false':u
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при записи атрибута - первоначальный расчет межфирменных архивов" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
end.