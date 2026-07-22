block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создать запись о том, что необходимо пересчитать межфирменные архивы

Автор: Чернова Светлана Александровна
Дата создания: 04/03/08
Author: Svetlana Chernova
Creation date: 04/03/08

Author1: Mikle Pervakov
Creation date: 09/13/00

*/

define input  parameter p-doc-code   as character no-undo .
define input  parameter p-fact-date  as date      no-undo .
define input  parameter p-action     as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Создать запись о том, что необходимо пересчитать межфирменные архивы".
{ cmp/vssrevis.i "substitute('&1|&2|&3',p-doc-code,p-fact-date,p-action)"}
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ gbl/waitfram.i }

do
on error undo, return error return-value
:

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

  run mark-hold in this-procedure
    (input {&hold-main-cat-code} /* p-cat-code       */
    ,input {&lock-prc-calc-hold} /* p-lock-code      */
    ,input {&btpr-type-hold}     /* p-btpr-type-code */
    ,input p-action              /* p-action         */
    ) .

  run mark-hold in this-procedure
    (input {&hold-inv-cat-code}  /* p-cat-code       */
    ,input {&lock-prc-calc-hinv} /* p-lock-code      */
    ,input {&btpr-type-hinv}     /* p-btpr-type-code */
    ,input p-action              /* p-action         */
    ) .

  run mark-hold in this-procedure
    (input {&hold-spi-cat-code}  /* p-cat-code       */
    ,input {&lock-prc-calc-hspi} /* p-lock-code      */
    ,input {&btpr-type-hspi}     /* p-btpr-type-code */
    ,input p-action              /* p-action         */
    ) .
end.


procedure mark-hold :

  define input  parameter p-cat-code       as integer   no-undo .
  define input  parameter p-lock-code      as character no-undo .
  define input  parameter p-btpr-type-code as character no-undo .
  define input  parameter p-action         as character no-undo .
define variable v-need-stop-hold as logical   no-undo .
  do
  on error undo, return error substitute(" &1 &2" ,return-value, error-status:get-message(1) )
  :
    define buffer calc-hold-lock_batchprocess for ub.batchprocess .
    v-need-stop-hold = false .
    run gbl/lock-prc.p
      (input p-lock-code
      ,input p-cat-code
      ,input 0
      ,input 0
      ,input ""
      ,input ""
      ,input ""
      ,input "Категория,,,,,,Расчет межфирменных архивов"
      ,input true
      ,buffer calc-hold-lock_batchprocess
      ) no-error .
    if error-status :error then do:
          if error-status :get-message(1) <> "" then do:
          message
            vss-workfile vss-revision vss-description skip
            return-value skip
            error-status :get-message(1) skip
            "В данный момент рассчитываются межфирменные архивы" skip
            "Категория" p-cat-code skip
            "Невозможно пометить архивы как требующие перерасчета" skip
            view-as alert-box error .
          undo, return error .
        end.

        assign
          v-need-stop-hold = true
        .

  define buffer stop-hold-news-lock_btpr for batchprocess .

  if v-need-stop-hold = true
  then do:
    /* если расчёт складского архива заблокирован, */
    /* отправить команду на остановку процесса расчёта складского архива */
    do transaction
    on error undo, return error return-value
    :
      create stop-hold-news-lock_btpr .
      assign
        stop-hold-news-lock_btpr.bp_type       = {&btpr-type-lock} + 'hold'
        stop-hold-news-lock_btpr.bp_status     = {&btpr-normal}
        stop-hold-news-lock_btpr.Key#_One      = 0
        stop-hold-news-lock_btpr.Key#_Two      = 0
        stop-hold-news-lock_btpr.Key#_Three    = 0
        stop-hold-news-lock_btpr.CharKey_One   = ""
        stop-hold-news-lock_btpr.CharKey_Two   = p-doc-code
        stop-hold-news-lock_btpr.CharKey_Three = ""
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
          (input p-lock-code
          ,input p-cat-code
          ,input 0
          ,input 0
          ,input ""
          ,input ""
          ,input ""
          ,input "Категория,,,,,,Расчет межфирменных архивов"
          ,input true
          ,buffer calc-hold-lock_batchprocess
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

      delete stop-hold-news-lock_btpr .

      run waitfram-hide in this-procedure .
    end.
  end.
  end.


    /* при изменении документа */
    /* если существует запись по расчету архива - ничего не делаем */
    /* если отсутствует запись по расчету архива - помечаем архив для перерасчета с даты документа */

    /* при удалении документа */
    /* если существует запись по расчету архива - удаляем запись */
    /* если не существует записи по расчету архива - помечаем архив для перерасчета с даты документа */
  do transaction
  on error undo, return error return-value
  :


    { trg/btpr_upd.i
      &btpr-status="find"
      &btpr-type="p-btpr-type-code"
      &btpr-table="ub.batchprocess"
      &btpr-lock-option="exclusive-lock"
      &charkey_one=p-doc-code
    }
    if available ub.batchprocess then do:
      if p-action = 'doc-delete':u
      then do:
        delete ub.batchprocess .
      end.
    end.
    else do:
      run trg/markhold.p
        (input p-cat-code  /* p-cat-code  */
        ,input p-lock-code /* p-lock-code */
        ,input p-fact-date /* p-fact-date */
        ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры markhold.p" skip
          "Дата" p-fact-date skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
  end.
  end.

end procedure. /* mark-hold */