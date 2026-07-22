block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Перерасчет переоценок, которые изменились в связи с закрытием или удалением документов

Автор: Чернова Светлана Александровна
Дата создания: 07/09/07
Author: Svetlana Chernova
Creation date: 07/09/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 07/01/02

*/

define input  parameter p-obj-type          as character no-undo .
define input  parameter p-obj-code          as integer   no-undo .
define input  parameter p-check-act         as logical   no-undo .
define input  parameter p-check-act-db-num  as integer   no-undo .
define input  parameter p-check-act-user-id as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Перерасчет переоценок, которые изменились в связи с закрытием или удалением документов".
{ cmp/vssrevis.i "substitute('&1|&2|&3':u,p-obj-type,p-obj-code,p-check-act)" }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ gbl/get-ro.i   }

define buffer buf_batchprocess for ub.batchprocess .
define buffer exec_batchprocess for ub.batchprocess .
define buffer buf_price-doc for ub.price-doc .

define variable v-was-processing as logical   no-undo .
define variable v-get-ro_read-only      as logical   no-undo .

do
on error undo, return error return-value
:
  define buffer calc-prc-lock_batchprocess for ub.batchprocess .

  run get-ro_get-read-only in this-procedure
    (output v-get-ro_read-only
    ) .

  if v-get-ro_read-only = false
  then do:
    run gbl/lock-prc.p
      (input  {&lock-prc-calc-prc}                 /* p-process-key     */
      ,input  p-obj-code                           /* p-Key#_One        */
      ,input  0                                    /* p-Key#_Two        */
      ,input  0                                    /* p-Key#_Three      */
      ,input  p-obj-type                           /* p-CharKey_One     */
      ,input  ""                                   /* p-CharKey_Two     */
      ,input  ""                                   /* p-CharKey_Three   */
      ,input  "Объект,,, ,,,Перерасчет переоценок" /* p-key-descr-list  */
      ,input  false                                /* p-message-on      */
      ,buffer calc-prc-lock_batchprocess           /* lock_batchprocess */
      ) no-error .
    if error-status :error then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "В данный момент рассчитываются переоценки" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo, return error "В данный момент рассчитываются переоценки" .
    end.
  end.

  /* перерассчитать все переоценки */
  for each buf_BatchProcess no-lock
    where buf_BatchProcess.bp_type       = {&btpr-type-prc}
      and buf_BatchProcess.bp_status     = {&btpr-normal}
      and buf_BatchProcess.CharKey_Three = p-obj-type
      and buf_BatchProcess.Key#_One      = p-obj-code
  on error undo, return error
  :
    if p-check-act = true
    then do:
      /* проверяем права пользователя на расчет архива по поставщикам */
      define variable v-ok as logical   no-undo .
      define variable v-chk-act-host-code as integer   no-undo .
      { gbl/hostcode.i
        p-obj-type
        p-obj-code
        v-chk-act-host-code
      }
      { gbl/chk-actg.i
        p-check-act-db-num
        p-check-act-user-id
        {&action-head-code-main}
        'actn_archive-prc_update':U
        {&cntxt-object}
        v-chk-act-host-code
        p-obj-type
        p-obj-code
        0
        0
        0
        false
        v-ok
      }
      if v-ok <> true
      then do:
        undo, return error substitute("Отсутствуют права на перерасчёт переоценок. &1"
                                     ,return-value
                                     ) .
      end.
    end.

    if v-get-ro_read-only = false
    then do:
      find first buf_price-doc no-lock
        where buf_price-doc.doc-num = buf_batchprocess.charkey_one
        no-error .
      if not available buf_price-doc then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найден документ переоценки" skip
          "Переоценка" buf_batchprocess.charkey_one skip
          view-as alert-box error .
        undo, return error .
      end.

      assign
        v-was-processing = true
      .

      do transaction
      on error undo, return error return-value
      :
        { trg/btpr_upd.i
          &btpr-status="executing_deleted"
          &btpr-table="exec_batchprocess"
          &btpr-rowid="rowid(buf_batchprocess)"
        }

        run str/pr-oldd.p
          (input buf_price-doc.doc-num /* p-doc-num */
          ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при перерасчете переоценки" skip
            "Переоценка" buf_price-doc.doc-num skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
    end.
    else do:
      undo, return error substitute("Перерасчет переоценок. Объект &1 &2. Имеются нерассчитанные переоценки. Переценки невозможно рассчитать при подключении только_для_чтения"
                                   ,p-obj-type
                                   ,p-obj-code
                                   ) .
    end.
  end.
end.

if v-was-processing then do:
  return "true":u .
end.
else do:
  return "":u .
end.