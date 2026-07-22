block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отметка переоценок, закрытых после указанного документа как требующих перерасчета

Автор: Чернова Светлана Александровна
Дата создания: 07/09/07
Author: Svetlana Chernova
Creation date: 07/09/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 06/27/02

*/

define input  parameter p-doc-code            as character no-undo .
define input  parameter p-fact-order          as decimal   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отметка переоценок, закрытых после указанного документа как требующих перерасчета".
{ cmp/vssrevis.i "substitute('&1|&2',p-doc-code,p-fact-order)" }
{ cmp/trg-def.i  }
{ gbl/waitfram.i }

define buffer buf_trn-doc for ub.trn-doc .
define buffer buf_doc-line for ub.doc-line .
define buffer buf_price-list for ub.price-list .

define variable v-archive-recalc as logical   no-undo .

define temp-table temp-price-doc no-undo
  field doc-num as character
  index xpk is primary unique doc-num
.

define variable v-price-list-found as logical   no-undo .

do
on error undo, return error return-value
:
  assign
    v-archive-recalc = false
  .

  find first buf_trn-doc no-lock
    where buf_trn-doc.doc-code = p-doc-code
    no-error .
  if not available buf_trn-doc then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден документ" p-doc-code skip
      view-as alert-box error .
    undo, return error .
  end.

  for each buf_doc-line
    where buf_doc-line.doc-code = p-doc-code
  on error undo, return error
  :
    run process-price-list in this-procedure
      (input  buf_doc-line.obj-type  /* p-obj-type         */
      ,input  buf_doc-line.obj-code  /* p-obj-code         */
      ,input  buf_doc-line.artic     /* p-artic            */
      ,input  buf_doc-line.prod-type /* p-prod-type        */
      ,input  buf_doc-line.prod-code /* p-prod-code        */
      ,input  p-fact-order           /* p-fact-order       */
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры process-price-list" skip
        "Документ" p-doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        "Фактический номер" p-fact-order skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
  end.

  find first temp-price-doc
    no-error .
  if available temp-price-doc
  then do:
    define variable v-message as character no-undo .

    define variable v-need-stop-arh as logical   no-undo .

    assign
      v-need-stop-arh = false
    .

    define buffer calc-arh-lock_batchprocess for ub.batchprocess .

    run gbl/lock-prc.p
      (input {&lock-prc-calc-arh}
      ,input buf_trn-doc.obj-code
      ,input 0
      ,input 0
      ,input buf_trn-doc.obj-type
      ,input ""
      ,input ""
      ,input "Объект,,, ,,,Расчет складского архива по товарам"
      ,input false
      ,buffer calc-arh-lock_batchprocess
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры блокировки расчета складского архива по товарам" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error "Ошибка при вызове процедуры блокировки расчёта складского архива по товарам" .
      end.
      assign
        v-need-stop-arh = true
      .
    end.

    define buffer stop-arh-news-lock_btpr for batchprocess .

    if v-need-stop-arh = true
    then do:
      /* если расчёт складского архива заблокирован, */
      /* отправить команду на остановку процесса расчёта складского архива */
      do transaction
      on error undo, return error return-value
      :
        create stop-arh-news-lock_btpr .
        assign
          stop-arh-news-lock_btpr.bp_type       = {&btpr-type-lock} + {&lock-prc-stop-arh-news}
          stop-arh-news-lock_btpr.bp_status     = {&btpr-normal}
          stop-arh-news-lock_btpr.Key#_One      = buf_trn-doc.obj-code
          stop-arh-news-lock_btpr.Key#_Two      = 0
          stop-arh-news-lock_btpr.Key#_Three    = 0
          stop-arh-news-lock_btpr.CharKey_One   = buf_trn-doc.obj-type
          stop-arh-news-lock_btpr.CharKey_Two   = buf_trn-doc.doc-code
          stop-arh-news-lock_btpr.CharKey_Three = ""
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
            (input waitfram-join-function("Архив по товарам рассчитывается на другой машине"
                                         ,"Отправлено сообщение о необходимости остановки расчёта складского архива"
                                         ,substitute("Ожидание освобождение ресурса расчёта складского архива &1", string(v-start-lock-second, 'HH:MM:SS':U))
                                         )
            ) .
          run gbl/lock-prc.p
            (input {&lock-prc-calc-arh}
            ,input buf_trn-doc.obj-code
            ,input 0
            ,input 0
            ,input buf_trn-doc.obj-type
            ,input ""
            ,input ""
            ,input "Объект,,, ,,,Расчет складского архива по товарам"
            ,input false
            ,buffer calc-arh-lock_batchprocess
            ) no-error .
          if error-status :error
          then do:
            if error-status :get-message(1) <> ""
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры блокировки расчета складского архива по товарам" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error "В данный момент рассчитывается складской архив по товарам" .
            end.
          end.
          else do:
            run waitfram-hide in this-procedure .
            leave wait_block .
          end.
          pause 1 no-message .
        end.

        delete stop-arh-news-lock_btpr .

        run waitfram-hide in this-procedure .
      end.
    end.

    define variable v-need-stop-ahsp as logical   no-undo .

    assign
      v-need-stop-ahsp = false
    .

    define buffer calc-supp-arh-lock_batchprocess for ub.batchprocess .

    run gbl/lock-prc.p
      (input {&lock-prc-calc-supp-arh}
      ,input buf_trn-doc.obj-code
      ,input 0
      ,input 0
      ,input buf_trn-doc.obj-type
      ,input ""
      ,input ""
      ,input "Объект,,, ,,,Расчет складского складского архива по поставщикам"
      ,input false
      ,buffer calc-supp-arh-lock_batchprocess
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры блокировки расчета складского архива по поставщикам" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error "Ошибка при вызове процедуры блокировки расчёта складского архива по поставщикам" .
      end.
      assign
        v-need-stop-ahsp = true
      .
    end.

    define buffer stop-ahsp-news-lock_btpr for batchprocess .

    if v-need-stop-ahsp = true
    then do:
      /* если расчёт складского архива заблокирован, */
      /* отправить команду на остановку процесса расчёта складского архива */
      do transaction
      on error undo, return error return-value
      :
        create stop-ahsp-news-lock_btpr .
        assign
          stop-ahsp-news-lock_btpr.bp_type       = {&btpr-type-lock} + {&lock-prc-stop-ahsp-news}
          stop-ahsp-news-lock_btpr.bp_status     = {&btpr-normal}
          stop-ahsp-news-lock_btpr.Key#_One      = buf_trn-doc.obj-code
          stop-ahsp-news-lock_btpr.Key#_Two      = 0
          stop-ahsp-news-lock_btpr.Key#_Three    = 0
          stop-ahsp-news-lock_btpr.CharKey_One   = buf_trn-doc.obj-type
          stop-ahsp-news-lock_btpr.CharKey_Two   = buf_trn-doc.doc-code
          stop-ahsp-news-lock_btpr.CharKey_Three = ""
        .

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
            (input waitfram-join-function("Архив по поставщикам рассчитывается на другой машине"
                                         ,"Отправлено сообщение о необходимости остановки расчёта складского архива"
                                         ,substitute("Ожидание освобождение ресурса расчёта складского архива &1", string(v-start-lock-second, 'HH:MM:SS':U))
                                         )
            ) .
          run gbl/lock-prc.p
            (input {&lock-prc-calc-supp-arh}
            ,input buf_trn-doc.obj-code
            ,input 0
            ,input 0
            ,input buf_trn-doc.obj-type
            ,input ""
            ,input ""
            ,input "Объект,,, ,,,Расчет складского архива по поставщикам"
            ,input false
            ,buffer calc-supp-arh-lock_batchprocess
            ) no-error .
          if error-status :error
          then do:
            if error-status :get-message(1) <> ""
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры блокировки расчета архива по поставщикам" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error "Ошибка при вызове процедуры блокировки расчета архива по поставщикам" .
            end.
          end.
          else do:
            leave wait_block .
          end.
          pause 1 no-message .
        end.

        delete stop-ahsp-news-lock_btpr .

        run waitfram-hide in this-procedure .
      end.
    end.

    define variable v-need-stop-aht as logical   no-undo .

    assign
      v-need-stop-aht = false
    .

    define buffer calc-aht-lock_batchprocess for ub.batchprocess .

    run gbl/lock-prc.p
      (input {&lock-prc-calc-aht}
      ,input buf_trn-doc.obj-code
      ,input 0
      ,input 0
      ,input buf_trn-doc.obj-type
      ,input ""
      ,input ""
      ,input "Объект,,, ,,,Расчет складского архива по типам приобретения"
      ,input false
      ,buffer calc-aht-lock_batchprocess
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры блокировки расчета складского архива по поставщикам" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error "Ошибка при вызове процедуры блокировки расчёта складского архива по поставщикам" .
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
          stop-aht-news-lock_btpr.Key#_One      = buf_trn-doc.obj-code
          stop-aht-news-lock_btpr.Key#_Two      = 0
          stop-aht-news-lock_btpr.Key#_Three    = 0
          stop-aht-news-lock_btpr.CharKey_One   = buf_trn-doc.obj-type
          stop-aht-news-lock_btpr.CharKey_Two   = buf_trn-doc.doc-code
          stop-aht-news-lock_btpr.CharKey_Three = ""
        .

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
                                         ,"Отправлено сообщение о необходимости остановки расчёта складского архива"
                                         ,substitute("Ожидание освобождение ресурса расчёта складского архива &1", string(v-start-lock-second, 'HH:MM:SS':U))
                                         )
            ) .
          run gbl/lock-prc.p
            (input {&lock-prc-calc-aht}
            ,input buf_trn-doc.obj-code
            ,input 0
            ,input 0
            ,input buf_trn-doc.obj-type
            ,input ""
            ,input ""
            ,input "Объект,,, ,,,Расчет складского архива по типам приобретения"
            ,input false
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


    for each temp-price-doc
    on error undo, return error return-value
    :
      run trg/nu_prc.p
        (input temp-price-doc.doc-num /* p-doc-code   */
        ,input {&table_price-doc}     /* p-table-name */
        ,input buf_trn-doc.obj-type   /* p-obj-type   */
        ,input buf_trn-doc.obj-code   /* p-obj-code   */
        ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры nu_prc.p" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.

      { trg/btpr_upd.i
        &btpr-status="find"
        &btpr-type="{&btpr-type-arh}"
        &btpr-table="ub.batchprocess"
        &btpr-lock-option="exclusive-lock"
        &charkey_one=temp-price-doc.doc-num
        &charkey_two={&table_price-doc}
        &charkey_three=buf_trn-doc.obj-type
        &key#_one=buf_trn-doc.obj-code
      }
      if not available ub.batchprocess
      then do:
        assign
          v-archive-recalc = true
        .
      end.

      { trg/btpr_upd.i
        &btpr-status="find"
        &btpr-type="{&btpr-type-aht}"
        &btpr-table="ub.batchprocess"
        &btpr-lock-option="exclusive-lock"
        &charkey_one=temp-price-doc.doc-num
        &charkey_two={&table_price-doc}
        &charkey_three=buf_trn-doc.obj-type
        &key#_one=buf_trn-doc.obj-code
      }
      if not available ub.batchprocess
      then do:
        assign
          v-archive-recalc = true
        .
      end.
    end.

    if v-archive-recalc = true
    then do:
      /* необходимо пометить складской архив, как требующие перерасчета */
      run trg/markarh.p
        (input buf_trn-doc.obj-type  /* p-obj-type  */
        ,input buf_trn-doc.obj-code  /* p-obj-code  */
        ,input buf_trn-doc.fact-date /* p-fact-date */
        ,input p-doc-code            /* p-doc-code  */
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Закрытие документа задним числом" skip
          "Ошибка при отметке складского архива по товару, что он требует перерасчета" skip
          "Документ" buf_trn-doc.doc-code skip
          "Расширенный тип документа" buf_trn-doc.ext-doc-type skip
          "Объект" buf_trn-doc.obj-type buf_trn-doc.obj-code skip
          "Дата" buf_trn-doc.fact-date skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      run trg/markahsp.p
        (input  buf_trn-doc.obj-type  /* p-obj-type  */
        ,input  buf_trn-doc.obj-code  /* p-obj-code  */
        ,input  buf_trn-doc.fact-date /* p-fact-date */
        ,input  p-doc-code            /* p-doc-code  */
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Закрытие документа задним числом" skip
          "Ошибка при отметке складского архива по поставщикам, что он требует перерасчета" skip
          "Документ" buf_trn-doc.doc-code skip
          "Расширенный тип документа" buf_trn-doc.ext-doc-type skip
          "Объект" buf_trn-doc.obj-type buf_trn-doc.obj-code skip
          "Дата" buf_trn-doc.fact-date skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      run trg/markaht.p
        (input  buf_trn-doc.obj-type  /* p-obj-type  */
        ,input  buf_trn-doc.obj-code  /* p-obj-code  */
        ,input  buf_trn-doc.fact-date /* p-fact-date */
        ,input  p-doc-code            /* p-doc-code  */
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Закрытие документа задним числом" skip
          "Ошибка при отметке складского архива по типам приобретения, что он требует перерасчета" skip
          "Документ" buf_trn-doc.doc-code skip
          "Расширенный тип документа" buf_trn-doc.ext-doc-type skip
          "Объект" buf_trn-doc.obj-type buf_trn-doc.obj-code skip
          "Дата" buf_trn-doc.fact-date skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end.

procedure process-price-list :

  define input  parameter p-obj-type         like ub.trn-doc.obj-type     no-undo.
  define input  parameter p-obj-code         like ub.trn-doc.obj-code     no-undo.
  define input  parameter p-artic            like ub.doc-line.artic       no-undo.
  define input  parameter p-prod-type        like ub.doc-line.prod-type   no-undo.
  define input  parameter p-prod-code        like ub.doc-line.prod-code   no-undo.
  define input  parameter p-fact-order       like ub.trn-doc.fact-order   no-undo.

  define variable vss-description as character no-undo init "process-price-list: поиск строк переоценок, подлежащих перерасчету".

  define variable v-is-new   as   logical              no-undo.
  define variable v-root-node like ub.bar-code.node-code no-undo.

  define buffer buf_price-list for ub.price-list.
  define buffer buf_goods      for ub.goods.

  define variable v-b-code like ub.bar-code.b-code no-undo .

  do
  on error undo, return error return-value
  :
    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      no-error .
    if not available buf_goods then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.

    { gbl/gdsbcode.i
      buf_goods.gds-code
      ?
      v-b-code
      no-error
    }
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении основного бар-кода товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    for each buf_price-list
      where buf_price-list.obj-type   = p-obj-type
        and buf_price-list.obj-code   = p-obj-code
        and buf_price-list.b-code     = v-b-code
        and buf_price-list.price-type = ""
        and buf_price-list.fact-order > p-fact-order
    on error undo, return error
    :
      run register-price-doc in this-procedure
        (input buf_price-list.doc-num
        ) .
    end.
  end.

end procedure. /* process-price-list */


procedure register-price-doc :

  define input  parameter p-doc-num as character no-undo .

  define buffer buf_temp-price-doc for temp-price-doc .

  do
  on error undo, return error return-value
  :
    find first buf_temp-price-doc
      where buf_temp-price-doc.doc-num = p-doc-num
      no-error .
    if not available buf_temp-price-doc
    then do:
      create buf_temp-price-doc .
      assign
        buf_temp-price-doc.doc-num = p-doc-num
      .
    end.
  end.

end procedure. /* register-price-doc */