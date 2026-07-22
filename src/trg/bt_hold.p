block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Расчет межфирменных архивов

Автор: Чернова Светлана Александровна
Дата создания: 04/03/08
Author: Svetlana Chernova
Creation date: 04/03/08

Author1: Mikle Pervakov
Creation date: 09/12/02

Параметры:
p-last-date      Дата конца диапазона (диапазон задан в календарных сутках)

*/

define input  parameter p-last-date         as date      no-undo .
define input  parameter p-check-act         as logical   no-undo .
define input  parameter p-check-act-db-num  as integer   no-undo .
define input  parameter p-check-act-user-id as character no-undo .


def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Расчет межфирменных архивов".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/holdattr.i }
{ gbl/cur-time.i }
{ gbl/waitfram.i }
{ gbl/get-ro.i   }

define stream slog .

define variable lwasprocessing as logical   no-undo .
define variable v-get-ro_read-only as logical   no-undo .

main-block:
do
on error undo main-block, return error
:
  run get-ro_get-read-only in this-procedure
    (output v-get-ro_read-only
    ) .

  run process-documents in this-procedure
    (input {&hold-main-cat-code}
    ,input {&lock-prc-calc-hold}
    ,input {&btpr-type-hold}
    ) no-error .
  if error-status :error
  then do:
    return error return-value .
  end.

  run process-documents in this-procedure
    (input {&hold-inv-cat-code}
    ,input {&lock-prc-calc-hinv}
    ,input {&btpr-type-hinv}
    ) no-error .
  if error-status :error
  then do:
    return error return-value .
  end.

  run process-documents in this-procedure
    (input {&hold-spi-cat-code}
    ,input {&lock-prc-calc-hspi}
    ,input {&btpr-type-hspi}
    ) no-error .
  if error-status :error
  then do:
    return error return-value .
  end.


  if lwasprocessing then do:
    return "true":u .
  end.
  else do:
    return "":u .
  end.
end.


procedure process-documents :

  define input  parameter p-cat-code as integer   no-undo .
  define input  parameter p-lock-code as character no-undo .
  define input  parameter p-btpr-type-code as character no-undo .

  define variable v-today as date      no-undo.
  define variable v-time  as integer   no-undo.

  define buffer buf_batchprocess            for ub.batchprocess .
  define buffer update_batchprocess         for ub.batchprocess .
  define buffer calc-hold-lock_batchprocess for ub.batchprocess .
  define buffer buf_trn-doc                 for ub.trn-doc .

  do
  on error undo, return error
  :

    if v-get-ro_read-only = false
    then do:
      run gbl/lock-prc.p
        (input p-lock-code
        ,input p-cat-code
        ,input 0
        ,input 0
        ,input ""
        ,input ""
        ,input ""
        ,input "Категория,,,,,,Расчет межфирменных архивов"
        ,input false
        ,buffer calc-hold-lock_batchprocess
        ) no-error .
      if error-status :error
      then do:
        if error-status :get-message(1) <> ""
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при попытке заблокировать ресурс" skip
            "Невозможно произвести расчет межфирменного архива" skip
            "Категория" p-cat-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error substitute("&1: Ошибка при попытке заблокировать ресурс &2"
                                      ,vss-workfile
                                      ,error-status :get-message(1)
                                      ).
        end.
        undo, return error substitute("В данный момент рассчитывается межфирменный архив категории &1"
                                    ,p-cat-code ) .
      end.
    end.

    /* запросить атрибут - первоначального расчета на объекте */
    define variable v-hold-calc-value as character no-undo .
    define variable v-hold-calc-type  as character no-undo .
    define variable v-hold-calc       as logical   no-undo .

    run holdattr-value in this-procedure
      (input  p-cat-code           /* p-cat-code */
      ,input  {&hold-attr-is-calc} /* p-code     */
      ,output v-hold-calc-value    /* p-value    */
      ,output v-hold-calc-type     /* p-type     */
      ) .
    assign
      v-hold-calc = (lookup(v-hold-calc-value, 'yes,true') > 0)
    .
    if v-hold-calc = true then do:
      /* происходит первоначальный расчет межфирменного архива */
      return . /* --->>>--- */
    end.

    /* считывает дату начала архива по объекту */
    define variable v-attr-begin-date-value as character no-undo .
    define variable v-attr-begin-date-type  as character no-undo .
    define variable v-attr-begin-date       as date      no-undo .

    assign
      v-attr-begin-date = ?
    .
    run holdattr-value in this-procedure
      (input  p-cat-code              /* p-cat-code */
      ,input  {&hold-attr-begin-date} /* p-code     */
      ,output v-attr-begin-date-value /* p-value    */
      ,output v-attr-begin-date-type  /* p-type     */
      ) .
    if v-attr-begin-date-value <> "" then do:
      assign
        v-attr-begin-date = date(v-attr-begin-date-value)
      .
    end.

    /* перерассчитать архив, если это необходимо */
    define buffer buf_hold-time for ub.hold-time .
    for each buf_hold-time share-lock
      where buf_hold-time.cat-code  = p-cat-code
        and buf_hold-time.time-type = {&harh-type-month}
        and buf_hold-time.status_   = {&deleted}
    on error undo, return error
    :
      if v-get-ro_read-only = false
      then do:
        run trg/harhrclc.p
          (input buf_hold-time.cat-code    /* p-cat-code       */
          ,input p-lock-code               /* p-lock-code      */
          ,input p-btpr-type-code          /* p-btpr-type-code */
          ,input buf_hold-time.start-date  /* p-start-date     */
          ) no-error .
        if error-status :error
        then do:
          return error return-value .
        end.
      end.
      else do:
        undo, return error "Межфирменный архив требует перерасчета. Невозможно выполнить перерасчет в режиме только_для_чтения." .
      end.
    end.

    /* выбираем все задания для расчета архива */
    for each buf_BatchProcess share-lock
      where buf_BatchProcess.bp_type   = p-btpr-type-code
        and buf_BatchProcess.bp_status = {&btpr-normal}
    on error undo, return error
    :
      if v-get-ro_read-only = false
      then do:
        find first buf_trn-doc no-lock
          where buf_trn-doc.doc-code = buf_batchprocess.charkey_one
          no-error .
        if available buf_trn-doc
        then do:
          run waitfram-show in this-procedure
            (input substitute("Расчет межфирменного архива категории &1. Документ &2. Дата &3"
                            ,p-cat-code
                            ,buf_trn-doc.doc-code
                            ,buf_trn-doc.fact-date
                            )
            ) .

          if p-last-date = ?
          or ( p-last-date <> ?
              and buf_trn-doc.fact-date <= p-last-date
              )
          then do:
            if  v-attr-begin-date <> ?
            and buf_trn-doc.fact-date < v-attr-begin-date
            then do:

              run cur-time in this-procedure
                (output v-today
                ,output v-time
                ).

              output stream slog to objhold.txt append .
              export stream slog
                string(v-today, '99/99/9999':u)
                string(v-time, 'HH:MM:SS':u)
                buf_trn-doc.doc-code
                'mark_deleted':u
                p-cat-code
                .
              output stream slog close .

              do transaction
              on error undo, return error return-value
              :
                { trg/btpr_upd.i
                  &btpr-status="executing_deleted"
                  &btpr-table="update_batchprocess"
                  &btpr-rowid="rowid(buf_batchprocess)"
                }
              end.
            end.
            else do:
              /* необходимо рассчитать документ */
              if p-check-act = true
              then do:
                /* проверяем права пользователя на расчет межфирменного архива */
                def var v-ok as logical   no-undo .
              { gbl/chk-actg.i
                p-check-act-db-num
                p-check-act-user-id
                {&action-head-code-main}
                'actn_archive-hold_update':U
                {&cntxt-global}
                0
                '':U
                0
                0
                0
                0
                false
                v-ok
              }
                if v-ok <> true
                then do:
                  &scop arm-code {&conjoint}
                  undo, return error substitute("Отсутствуют права на расчет межфирменного архива (&1/&2/&3)"
                    ,return-value
                    ,{&archive-hold}
                    ,{&update}
                    ) .
                end.
              end.

              run cur-time in this-procedure
                (output v-today
                ,output v-time
                ).
              output stream slog to objhold.txt append .
              export stream slog
                string(v-today, '99/99/9999':u)
                string(v-time, 'HH:MM:SS':u)
                buf_trn-doc.doc-code
                'calc':u
                p-cat-code
                .
              output stream slog close .

              assign
                lwasprocessing = true
              .

              do transaction
              on error undo, return error
              :
                /* update batchprocess record status as executing and deleted */
                { trg/btpr_upd.i
                  &btpr-status="executing_deleted"
                  &btpr-table="update_batchprocess"
                  &btpr-rowid="rowid(buf_batchprocess)"
                }

                run trg/harhtclc.p
                  (input p-cat-code           /* p-cat-code       */
                  ,input p-lock-code          /* p-lock-code      */
                  ,input p-btpr-type-code     /* p-btpr-type-code */
                  ,input buf_trn-doc.doc-code /* p-doc-code       */
                  ) no-error .
                if error-status :error
                then do:
                  return error return-value .
                end.
              end.
            end.
          end.
        end.
      end.
      else do:
        undo, return error "Межфирменный архив требует расчета. Невозможно выполнить расчет в режиме только_для_чтения." .
      end.
    end.

    run waitfram-hide in this-procedure .
  end.

end procedure. /* process-object */