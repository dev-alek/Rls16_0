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
define input  parameter p-archive-name   as character no-undo .

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

/*процедуру можно запустить только если задан конфигурационный параметр holding */

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
    (input p-archive-name
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
    undo, return error return-value .
  end.

  assign
    v-begin-date = date(v-month, 1, v-year)
  .
  if v-begin-date = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при задании даты начала расчета межфирменных архивов" skip
      p-archive-name skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.

  define variable v-ok as logical   no-undo .
  message
    "ВНИМАНИЕ" skip
    "Это последний вопрос перед частичным расчетом архивов" skip
    p-archive-name skip
    "Будет произведен частичный расчет архивов с даты" string(v-begin-date, '99/99/9999':u) skip
    "Продолжить?" skip
    view-as alert-box question buttons yes-no update v-ok .
  if v-ok <> true
  then do:
    undo, return error return-value .
  end.

  define variable v-attr-value as character no-undo .
  define variable v-attr-type  as character no-undo .

  run holdattr-value in this-procedure
    (input  p-cat-code
    ,input  {&hold-attr-begin-date}
    ,output v-attr-value
    ,output v-attr-type
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при чтении даты начала межфирменных архивов" skip
      p-archive-name skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.

  define variable v-start-hold as date      no-undo .
  assign
    v-start-hold = date(v-attr-value)
  .

  if v-start-hold = ?
  then do:
    message
      p-archive-name skip
      "Неизвестна дата инициализации архива" skip
      "Невозможно произвести частичный расчет" skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if v-start-hold > v-begin-date
  then do:
    message
      p-archive-name skip
      "Дата частичного перерасчета архива не может быть раньше" skip
      "чем дата начала архива" skip
      "Дата начала архива" string(v-start-hold, '99/99/9999':u) skip
      "Дата частичного перерасчета архива" string(v-begin-date, '99/99/9999':u) skip
      view-as alert-box error .
    undo, return error return-value .
  end.


  /*проверить не производиться ли уже расчет в настоящий момент ? */

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
      p-archive-name skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.


  define variable v-ind as integer   no-undo .

  /* удаляются все архивы начиная с даты перерасчета */
  for each del_hold-time
    where del_hold-time.cat-code   = p-cat-code
      and del_hold-time.start-date >= v-begin-date
  on error undo, return error
  :
    assign
      v-ind = 0
    .

    for each del_hold-trn
      where del_hold-trn.cat-code  = p-cat-code
        and del_hold-trn.time-code = del_hold-time.time-code
    on error undo, return error
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Дата &1. Удаление списка документов &2"
                           ,string(del_hold-time.start-date, '99/99/9999':u)
                           ,v-ind)
          ) .
      end.
      delete del_hold-trn .
    end.

    assign
      v-ind = 0
    .

    for each del_hold-goods
      where del_hold-goods.cat-code  = p-cat-code
        and del_hold-goods.time-code = del_hold-time.time-code
    on error undo, return error
    :
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Дата &1. Удаление списка товаров &2"
                           ,string(del_hold-time.start-date, '99/99/9999':u)
                           ,v-ind)
          ) .
      end.
      delete del_hold-goods .
    end.

    assign
      v-ind = 0
    .

    for each del_hold-gds-grp
      where del_hold-gds-grp.cat-code  = p-cat-code
        and del_hold-gds-grp.time-code = del_hold-time.time-code
    on error undo, return error
    :
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Дата &1. Удаление списка групп товаров &2"
                           ,string(del_hold-time.start-date, '99/99/9999':u)
                           ,v-ind)
          ) .
      end.
      delete del_hold-gds-grp .
    end.

    assign
      v-ind = 0
    .

    for each del_hold-purch
      where del_hold-purch.cat-code  = p-cat-code
        and del_hold-purch.time-code = del_hold-time.time-code
    on error undo, return error
    :
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Дата &1. Удаление информации о закупках &2"
                           ,string(del_hold-time.start-date, '99/99/9999':u)
                           ,v-ind)
          ) .
      end.
      delete del_hold-purch .
    end.

    assign
      v-ind = 0
    .

    for each del_hold-purch-grp
      where del_hold-purch-grp.cat-code  = p-cat-code
        and del_hold-purch-grp.time-code = del_hold-time.time-code
    on error undo, return error
    :
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Дата &1. Удаление информации о закупках по группам &2"
                           ,string(del_hold-time.start-date, '99/99/9999':u)
                           ,v-ind)
          ) .
      end.
      delete del_hold-purch-grp .
    end.

    assign
      v-ind = 0
    .

    for each del_hold-purch-supp
      where del_hold-purch-supp.cat-code  = p-cat-code
        and del_hold-purch-supp.time-code = del_hold-time.time-code
    on error undo, return error
    :
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Дата &1. Удаление информации о закупках по поставщикам &2"
                           ,string(del_hold-time.start-date, '99/99/9999':u)
                           ,v-ind)
          ) .
      end.
      delete del_hold-purch-supp .
    end.

    assign
      v-ind = 0
    .

    for each del_hold-purch-supp-gds
      where del_hold-purch-supp-gds.cat-code  = p-cat-code
        and del_hold-purch-supp-gds.time-code = del_hold-time.time-code
    on error undo, return error
    :
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Дата &1. Удаление информации о закупках по поставщикам по товарам &2"
                           ,string(del_hold-time.start-date, '99/99/9999':u)
                           ,v-ind)
          ) .
      end.
      delete del_hold-purch-supp-gds .
    end.

    assign
      v-ind = 0
    .

    for each del_hold-sale
      where del_hold-sale.cat-code  = p-cat-code
        and del_hold-sale.time-code = del_hold-time.time-code
    on error undo, return error
    :
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Дата &1. Удаление информации о продажах &2"
                           ,string(del_hold-time.start-date, '99/99/9999':u)
                           ,v-ind)
          ) .
      end.
      delete del_hold-sale .
    end.

    assign
      v-ind = 0
    .

    for each del_hold-sale-grp
      where del_hold-sale-grp.cat-code  = p-cat-code
        and del_hold-sale-grp.time-code = del_hold-time.time-code
    on error undo, return error
    :
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Дата &1. Удаление информации о продажах по группам &2"
                           ,string(del_hold-time.start-date, '99/99/9999':u)
                           ,v-ind)
          ) .
      end.
      delete del_hold-sale-grp .
    end.

    delete del_hold-time .
  end.

  /* произведем расчет архивов по всем объектам */
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
      (input substitute("Расчет архивов по категории &1. Документ &2. Дата &3"
             ,p-cat-code
             ,buf_trn-doc.doc-code
             ,string(buf_trn-doc.fact-date, '99/99/9999':u)
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
          p-archive-name skip
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