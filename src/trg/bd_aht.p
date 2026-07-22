block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создать запись о том, что необходимо пересчитать складской архив по типам приобретени

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 09/13/00

*/

define input  parameter p-doc-code   as character no-undo .
define input  parameter p-table-name as character no-undo .
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define input  parameter p-fact-date  as date      no-undo .
define input  parameter p-action     as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Создать запись о том, что необходимо пересчитать складской архив по типам приобретения".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6',p-doc-code,p-table-name,p-obj-type,p-obj-code,p-fact-date,p-action)"}
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ gbl/waitfram.i }

do
on error undo, return error return-value
:
  if lookup( p-table-name, {&table_trn-doc} + {&comma-char} + {&table_price-doc} ) = 0 then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестная таблица" skip
      "Документ" p-doc-code skip
      "Таблица" p-table-name skip
      "Действие" p-action skip
      view-as alert-box error .
    undo, return error .
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
      "Таблица" p-table-name skip
      "Действие" p-action skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  define variable v-need-stop-aht as logical   no-undo .

  assign
    v-need-stop-aht = false
  .

  define buffer calc-aht-lock_batchprocess for ub.batchprocess .

  run gbl/lock-prc.p
    (input {&lock-prc-calc-aht}
    ,input p-obj-code
    ,input 0
    ,input 0
    ,input p-obj-type
    ,input ""
    ,input ""
    ,input "Объект,,, ,,,Расчет складского архива по типам приобретения"
    ,input true
    ,buffer calc-aht-lock_batchprocess
    ) no-error .
  if error-status :error
  then do:
    if error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры блокировки расчета складского архива по типам приобретения" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error "Ошибка при вызове процедуры блокировки расчёта архива по типам приобретения" .
    end.
    assign
      v-need-stop-aht = true
    .
  end.

  define buffer stop-aht-news-lock_btpr for batchprocess .

  if v-need-stop-aht = true
  then do:
    /* если расчёт складского архива заблокирован, */
    /* отправить команду на остановку процесса расчёта складского архива */
    do transaction
    on error undo, return error return-value
    :
      create stop-aht-news-lock_btpr .
      assign
        stop-aht-news-lock_btpr.bp_type       = {&btpr-type-lock} + {&lock-prc-stop-aht-news}
        stop-aht-news-lock_btpr.bp_status     = {&btpr-normal}
        stop-aht-news-lock_btpr.Key#_One      = p-obj-code
        stop-aht-news-lock_btpr.Key#_Two      = 0
        stop-aht-news-lock_btpr.Key#_Three    = 0
        stop-aht-news-lock_btpr.CharKey_One   = p-obj-type
        stop-aht-news-lock_btpr.CharKey_Two   = p-doc-code
        stop-aht-news-lock_btpr.CharKey_Three = ""
      .

      define variable v-start-lock-time   as int64     no-undo .
      define variable v-start-lock-second as integer   no-undo .
      assign
        v-start-lock-time = etime
      .
      wait_block:
      do while true
      :
        assign
          v-start-lock-second = integer((etime - v-start-lock-time) / 1000)
        .
        run waitfram-show in this-procedure
          (input waitfram-join-function("Архив по типам приобретения рассчитывается на другой машине"
                                        ,"Отправлено сообщение о необходимости остановки расчёта складского архива по типам приобретения"
                                        ,substitute("Ожидание освобождение ресурса расчёта складского архива &1", string(v-start-lock-second, 'HH:MM:SS':U))
                                        )
          ) .
        run gbl/lock-prc.p
          (input {&lock-prc-calc-aht}
          ,input p-obj-code
          ,input 0
          ,input 0
          ,input p-obj-type
          ,input ""
          ,input ""
          ,input "Объект,,, ,,,Расчет складского архива по типам приобретения"
          ,input true
          ,buffer calc-aht-lock_batchprocess
          ) no-error .
        if error-status :error
        then do:
          if error-status :get-message(1) <> ""
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при вызове процедуры блокировки расчета складского архива по типам приобретения" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error "В данный момент рассчитывается складской архив по типам приобретения" .
          end.
        end.
        else do:
          leave wait_block .
        end.
        pause 1 no-message .
      end.

      delete stop-aht-news-lock_btpr .

      run waitfram-hide in this-procedure .
    end.
  end.

  /* при изменении документа */
  /* если существует запись по расчету складского архива - ничего не делаем */
  /* если отсутствует запись по расчету складского архива - помечаем складской архив для перерасчета с даты документа */

  /* при удалении документа */
  /* если существует запись по расчету складского архива - удаляем запись */
  /* если не существует записи по расчету складского архива - помечаем складской архив для перерасчета с даты документа */

  do transaction
  on error undo, return error return-value
  :
    { trg/btpr_upd.i
      &btpr-status="find"
      &btpr-type="{&btpr-type-aht}"
      &btpr-table="ub.batchprocess"
      &btpr-lock-option="exclusive-lock"
      &charkey_one=p-doc-code
      &charkey_two=p-table-name
      &charkey_three=p-obj-type
      &key#_one=p-obj-code
    }
    if available ub.batchprocess then do:
      if p-action = 'doc-delete':u
      then do:
        delete ub.batchprocess .
      end.
    end.
    else do:
      run trg/markaht.p
        (input p-obj-type  /* p-obj-type  */
        ,input p-obj-code  /* p-obj-code  */
        ,input p-fact-date /* p-fact-date */
        ,input p-doc-code  /* p-doc-code  */
        ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры markaht.p" skip
          "Объект" p-obj-type p-obj-code skip
          "Дата" p-fact-date skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
  end.
end.