block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Расчет складского архива по типам приобретени

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 06/21/00

Параметры:
p-obj-type       Объект, для которого необходимо проверить наличие складского архива по типам приобретени
p-obj-code       Или p-obj-type = "", p-obj-code = 0,
                 если необходимо рассчитать складской архив по типам приобретения по всем объектам
p-last-date      Дата конца диапазона (диапазон задан в календарных сутках)
p-last-date  = ? Если необходимо рассчитать все документы

*/

define input  parameter p-obj-type          as character no-undo .
define input  parameter p-obj-code          as integer   no-undo .
define input  parameter p-last-date         as date      no-undo .
define input  parameter p-check-act         as logical   no-undo .
define input  parameter p-check-act-db-num  as integer   no-undo .
define input  parameter p-check-act-user-id as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Расчет складского архива по типам приобретения".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4',p-obj-type,p-obj-code,p-last-date,p-check-act)" }
{ cmp/trg-def.i  }
{ gbl/clntattr.i }
{ gbl/cur-time.i }
{ gbl/waitfram.i }
{ gbl/get-ro.i   }

define stream slog .

&glob def-doc-list define temp-table doc-list no-undo  ~
  field doc-code   like ub.trn-doc.doc-code   ~
  field fact-date  like ub.trn-doc.fact-date  ~
  field fact-order like ub.trn-doc.fact-order ~
  field obj-type   like ub.trn-doc.obj-type   ~
  field obj-code   like ub.trn-doc.obj-code   ~
  field is-trn-doc as logical                 ~
  field batchprocess_rowid as rowid           ~
  index xpk is primary unique doc-code        ~
  index xfact obj-type obj-code fact-order ~
  index xdate fact-date  ~
.

{&def-doc-list}

define variable v-was-processing as logical   no-undo init false .
define variable v-get-ro_read-only as logical   no-undo .

main-block:
do
on error undo main-block, return error return-value
:
  run get-ro_get-read-only in this-procedure
    (output v-get-ro_read-only
    ) .

  /* обрабатываем выбранные документы */
  if  p-obj-type = ""
  and p-obj-code = 0
  then do:
    for each ub.db no-lock
    ,each ub.clients no-lock
      where ub.clients.db-num = ub.db.db-num
    on error undo, return error return-value
    :
      run waitfram-show in this-procedure
        (input substitute("Расчет складского архива по типам приобретения. Объект &1 &2"
                         ,ub.clients.obj-type
                         ,ub.clients.obj-code
                         )
        ) .

      run process-object in this-procedure
        (input ub.clients.obj-type
        ,input ub.clients.obj-code
        ) no-error .
      if error-status :error
      then do:
        if error-status :get-message(1) <> ""
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры process-object" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        end.
        /* продолжаем обработку */
      end.
    end.
  end.
  else do:
    find first ub.clients no-lock
      where ub.clients.obj-type = p-obj-type
        and ub.clients.obj-code = p-obj-code
      no-error .
    if not available ub.clients
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестный объект" p-obj-type p-obj-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    run waitfram-show in this-procedure
      (input substitute("Расчет складского архива по типам приобретения. Объект &1 &2"
                        ,ub.clients.obj-type
                        ,ub.clients.obj-code
                        )
      ) .

    run process-object in this-procedure
      (input ub.clients.obj-type
      ,input ub.clients.obj-code
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры process-object" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo, return error return-value .
    end.

  end.

  run waitfram-hide in this-procedure .

  if v-was-processing
  then do:
    return "true":u .
  end.
  else do:
    return "":u .
  end.
end.


procedure process-object :

  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .

  define variable v-today as date      no-undo.
  define variable v-time  as integer   no-undo.

  define variable v-aht-calc-char    as character no-undo .
  define variable v-aht-del-char     as character no-undo .
  define variable v-aht-disable-char as character no-undo .
  define variable v-aht-calc         as logical   no-undo .
  define variable v-aht-del          as logical   no-undo .
  define variable v-aht-disable      as logical   no-undo .
  define variable v-aht-recalc-char  as character no-undo .
  define variable v-aht-recalc       as date      no-undo .
  define variable v-attr-type        as character no-undo .

  define buffer buf_batchprocess for ub.batchprocess .
  define buffer calc-aht-lock_batchprocess for ub.batchprocess .
  define buffer stop-aht-restore-lock_btpr for ub.batchprocess .
  define buffer stop-aht-news-lock_btpr    for ub.batchprocess .

  do
  on error undo, return error return-value
  :

    if v-get-ro_read-only = false
    then do:
      run gbl/lock-prc.p
        (input  {&lock-prc-calc-aht}       /* p-process-key     */
        ,input  p-obj-code                 /* p-Key#_One        */
        ,input  0                          /* p-Key#_Two        */
        ,input  0                          /* p-Key#_Three      */
        ,input  p-obj-type                 /* p-CharKey_One     */
        ,input  ""                         /* p-CharKey_Two     */
        ,input  ""                         /* p-CharKey_Three   */
        ,input  "Объект,,, ,,,Расчет складского архива по типам приобретения" /* p-key-descr-list  */
        ,input  false                      /* p-message-on      */
        ,buffer calc-aht-lock_batchprocess /* lock_batchprocess */
        ) no-error .
      if error-status :error
      then do:
        if error-status :get-message(1) <> ""
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при попытке заблокировать ресурс" skip
            "Невозможно произвести расчет складского архива по типам приобретения" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error substitute("&1: Ошибка при попытке заблокировать ресурс &2"
                                       ,vss-workfile
                                       ,error-status :get-message(1)
                                       ).
        end.
        undo, return error "В данный момент рассчитывается складской архив по типам приобретения" .
      end.
    end.

    /* пtроверяем, что не производится первоначальный расчет складского архива по типам приобретения */
    run clntattr-value in this-procedure
      (input  p-obj-type       /* p-obj-type */
      ,input  p-obj-code       /* p-obj-code */
      ,input  {&attr-aht-calc} /* p-code     */
      ,output v-aht-calc-char  /* p-value    */
      ,output v-attr-type      /* p-type     */
      ) .
    assign
      v-aht-calc = (lookup(v-aht-calc-char, 'yes,true') > 0)
    .
    run clntattr-value in this-procedure
      (input  p-obj-type       /* p-obj-type */
      ,input  p-obj-code       /* p-obj-code */
      ,input  {&attr-aht-del}  /* p-code     */
      ,output v-aht-del-char   /* p-value    */
      ,output v-attr-type      /* p-type     */
      ) .
    assign
      v-aht-del = (lookup(v-aht-del-char, 'yes,true') > 0)
    .
    run clntattr-value in this-procedure
      (input  p-obj-type          /* p-obj-type */
      ,input  p-obj-code          /* p-obj-code */
      ,input  {&attr-aht-disable} /* p-code     */
      ,output v-aht-disable-char  /* p-value    */
      ,output v-attr-type         /* p-type     */
      ) .
    assign
      v-aht-disable = (lookup(v-aht-disable-char, 'yes,true') > 0)
    .
    run clntattr-value in this-procedure
      (input  p-obj-type              /* p-obj-type */
      ,input  p-obj-code              /* p-obj-code */
      ,input  {&attr-aht-recalc-date} /* p-code     */
      ,output v-aht-recalc-char       /* p-value    */
      ,output v-attr-type             /* p-type     */
      ) .
    assign
      v-aht-recalc = date(v-aht-recalc-char)
    .

    if v-aht-del  = true
    then do:
      /* у архива отсутствуют начальные остатки */
      /* удаляем все задания на расчет архива */
      if v-get-ro_read-only = false
      then do:
        for each BatchProcess exclusive-lock
          where BatchProcess.bp_type       = {&btpr-type-aht}
            and BatchProcess.bp_status     = {&btpr-normal}
            and BatchProcess.CharKey_Three = p-obj-type
            and BatchProcess.Key#_One      = p-obj-code
        on error undo, return error return-value
        :
          { trg/btpr_upd.i
            &btpr-status="executing_deleted"
            &btpr-table="buf_batchprocess"
            &btpr-rowid="rowid(BatchProcess)"
          }
        end.
      end.

      if v-aht-disable = true
      then do:
        undo, return error substitute("Складской архив по типам приобретения. Объект &1 &2. Расчет архива запрещен"
                          ,p-obj-type
                          ,p-obj-code
                          )
          .
      end.
      else do:
        undo, return error substitute("Складской архив по типам приобретения. Объект &1 &2. Отсутствуют начальные остатки"
                          ,p-obj-type
                          ,p-obj-code
                          )
          .
      end.
    end.

    if v-aht-calc = true
    then do:
      undo, return error substitute("Складской архив по типам приобретения. Объект &1 &2. Архив требует расчета"
                         ,p-obj-type
                         ,p-obj-code
                         )
        .
    end.

    /* перерассчитать переоценки */
    run trg/bt_prc.p
      (input p-obj-type          /* p-obj-type          */
      ,input p-obj-code          /* p-obj-code          */
      ,input p-check-act         /* p-check-act         */
      ,input p-check-act-db-num  /* p-check-act-db-num  */
      ,input p-check-act-user-id /* p-check-act-user-id */
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при перасчете переоценок" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo, return error return-value  .
    end.

    /* перерассчитать складской архив, если это необходимо */
    if v-aht-recalc <> ?
    then do:
      if p-check-act = true
      then do:
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
          'actn_archive-aht_update':U
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
          undo, return error substitute("Требуется автоматический перерасчёт складского архива по типам приобретения. Отсутствуют права на расчет складского архива по типам приобретения. &1"
                                       ,return-value
                                       ) .
        end.
      end.
      if v-get-ro_read-only = false
      then do:
        run trg/calcaht.p
          (input p-obj-type          /* p-obj-type          */
          ,input p-obj-code          /* p-obj-code          */
          ,input false               /* p-check-doc         */
          ,input false               /* p-message-on        */
          ,input v-aht-recalc        /* p-last-fact-date    */
          ,input p-check-act         /* p-check-act         */
          ,input p-check-act-db-num  /* p-check-act-db-num  */
          ,input p-check-act-user-id /* p-check-act-user-id */
          ) no-error .
        if error-status :error
        then do:
          if error-status :get-message(1) <> ""
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при перерасчете складского архива по типам приобретения" skip
              "Объект" p-obj-type p-obj-code skip
              "Дата перерасчета" v-aht-recalc skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
          end.
          undo, return error return-value .
        end.
      end.
      else do:
        undo, return error substitute("Складской архив по типам приобретения. Объект &1 &2. &3"
                          ,p-obj-type
                          ,p-obj-code
                          ,"Требуется перерасчет. Перерасчет невозможно выполнить так как база находится в режиме только на чтение"
                          ) .
      end.
    end.

    for each doc-list
    :
      delete doc-list .
    end.

    /* выбираем все задания по данному объекту для расчета складского архива по типам приобретения */
    for each BatchProcess exclusive-lock
      where BatchProcess.bp_type       = {&btpr-type-aht}
        and BatchProcess.bp_status     = {&btpr-normal}
        and BatchProcess.CharKey_Three = p-obj-type
        and BatchProcess.Key#_One      = p-obj-code
    on error undo, return error return-value
    :
      case batchprocess.charkey_two :
        when {&table_trn-doc}
        then do:
          find first ub.trn-doc no-lock
            where ub.trn-doc.doc-code = batchprocess.charkey_one
            no-error .
          if available ub.trn-doc
          then do:
            if  ub.trn-doc.obj-type = p-obj-type
            and ub.trn-doc.obj-code = p-obj-code
            then do:
              find first doc-list
                where doc-list.doc-code = ub.trn-doc.doc-code
                no-error .
              if not available doc-list
              then do:
                create doc-list .
                assign
                  doc-list.batchprocess_rowid = rowid(batchprocess)
                .
                assign
                  doc-list.doc-code   = ub.trn-doc.doc-code
                  doc-list.fact-order = ub.trn-doc.fact-order
                  doc-list.fact-date  = ub.trn-doc.fact-date
                  doc-list.obj-type   = ub.trn-doc.obj-type
                  doc-list.obj-code   = ub.trn-doc.obj-code
                  doc-list.is-trn-doc = true
                .
              end.
            end.
          end.
          else do:
            if v-get-ro_read-only = false
            then do:
              { trg/btpr_upd.i
                &btpr-status="executing_deleted"
                &btpr-table="buf_batchprocess"
                &btpr-rowid="rowid(BatchProcess)"
              }
            end.
          end.
        end.
        when {&table_price-doc}
        then do:
          find first ub.price-doc no-lock
            where ub.price-doc.doc-num = batchprocess.charkey_one
            no-error .
          if available ub.price-doc
          then do:
            if  ub.price-doc.obj-type = p-obj-type
            and ub.price-doc.obj-code = p-obj-code
            then do:
              find first doc-list
                where doc-list.doc-code = ub.price-doc.doc-num
                no-error .
              if not available doc-list
              then do:
                create doc-list .
                assign
                  doc-list.batchprocess_rowid = rowid(batchprocess)
                .
                assign
                  doc-list.doc-code   = ub.price-doc.doc-num
                  doc-list.fact-order = ub.price-doc.fact-order
                  doc-list.fact-date  = ub.price-doc.fact-date
                  doc-list.obj-type   = ub.price-doc.obj-type
                  doc-list.obj-code   = ub.price-doc.obj-code
                  doc-list.is-trn-doc = false
                .
              end.
            end.
          end.
          else do:
            if v-get-ro_read-only = false
            then do:
              { trg/btpr_upd.i
                &btpr-status="executing_deleted"
                &btpr-table="buf_batchprocess"
                &btpr-rowid="rowid(BatchProcess)"
              }
            end.
          end.
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестный тип таблицы" skip
            "charkey_one"  batchprocess.charkey_one skip
            "charkey_two"  batchprocess.charkey_two skip
            view-as alert-box error .
          undo, return error return-value .
        end.

      end case .
    end.

    if p-last-date <> ?
    then do:
      find first doc-list no-lock
        where doc-list.fact-date <= p-last-date
        no-error .
      if not available doc-list
      then do:
        /* ни один из необсчитанных документов */
        /* не может повлиять на запрошенный диапазон */
        /* не производим расчет архива */
        return . /* ---<<<--- */
      end.
    end.

    if p-check-act = true
    then do:
      /* проверяем права пользователя на расчет складского архива по типам приобретения */
      { gbl/hostcode.i
        p-obj-type
        p-obj-code
        v-chk-act-host-code
      }
      { gbl/chk-actg.i
        p-check-act-db-num
        p-check-act-user-id
        {&action-head-code-main}
        'actn_archive-aht_update':U
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
        undo, return error substitute("Отсутствуют права на расчет складского архива по типам приобретения. &1"
                                     ,return-value
                                     ) .
      end.
    end.

    if v-get-ro_read-only = true
    then do:
      undo, return error "Имеются нерассчитанные документы. Невозможно произвести расчёт документов в режиме подключения к базе только_на_чтение." .
    end.

    define buffer buf_lock_gdsrenart_batchprocess for ub.batchprocess .

    run gbl/lockrngd.p
      (input  {&lock-prc-goods-rename-artic}  /* p-lock-gds-type   */
      ,input  {&lock-prc-subtype-disable}     /* p-sub-type        */
      ,buffer buf_lock_gdsrenart_batchprocess /* lock_batchprocess */
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при блокировании функции переименования артикула товара" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo, return error return-value .
    end.

    define buffer buf_lock_gdsrengc_batchprocess for ub.batchprocess .

    run gbl/lockrngd.p
      (input  {&lock-prc-goods-rename-gds-code} /* p-lock-gds-type   */
      ,input  {&lock-prc-subtype-disable}       /* p-sub-type        */
      ,buffer buf_lock_gdsrengc_batchprocess    /* lock_batchprocess */
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при блокировании функции переименования кода товара" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo, return error return-value .
    end.

    /* обрабатываем выбранные документы */
    for each doc-list
    by doc-list.obj-type
    by doc-list.obj-code
    by doc-list.fact-order
    on error undo, return error return-value
    :
      find first stop-aht-restore-lock_btpr no-lock
        where stop-aht-restore-lock_btpr.bp_type       = {&btpr-type-lock} + {&lock-prc-stop-aht-restore}
          and stop-aht-restore-lock_btpr.bp_status     = {&btpr-normal}
          and stop-aht-restore-lock_btpr.Key#_One      = doc-list.obj-code
          and stop-aht-restore-lock_btpr.Key#_Two      = 0
          and stop-aht-restore-lock_btpr.Key#_Three    = 0
          and stop-aht-restore-lock_btpr.CharKey_One   = doc-list.obj-type
          and stop-aht-restore-lock_btpr.CharKey_Two   = ""
          and stop-aht-restore-lock_btpr.CharKey_Three = ""
        no-error .
      if available stop-aht-restore-lock_btpr
      then do:
        undo, return error "Процедура восстановления складского архива запросила остановку автоматического расчета складского архива" .
      end.

      find first stop-aht-news-lock_btpr no-lock
        where stop-aht-news-lock_btpr.bp_type       = {&btpr-type-lock} + {&lock-prc-stop-aht-news}
          and stop-aht-news-lock_btpr.bp_status     = {&btpr-normal}
          and stop-aht-news-lock_btpr.Key#_One      = doc-list.obj-code
          and stop-aht-news-lock_btpr.Key#_Two      = 0
          and stop-aht-news-lock_btpr.Key#_Three    = 0
          and stop-aht-news-lock_btpr.CharKey_One   = doc-list.obj-type
/*          and stop-aht-news-lock_btpr.CharKey_Two   = ""*/
          and stop-aht-news-lock_btpr.CharKey_Three = ""
        no-error .
      if available stop-aht-news-lock_btpr
      then do:
        undo, return error "Система новостей запросила остановку автоматического расчета складского архива" .
      end.

      output stream slog to objaht.txt append .
      export stream slog doc-list except doc-list.batchprocess_rowid .
      run cur-time in this-procedure ( output v-today
                                     , output v-time
                                     ).
      export stream slog string(v-today, "99/99/9999") string(v-time, "hh:mm") .
      output stream slog close .
      assign
        v-was-processing = true
      .

      do transaction
      on error undo, return error return-value
      :
        /* update batchprocess record status as executing and deleted */
        { trg/btpr_upd.i
          &btpr-status="executing_deleted"
          &btpr-table="buf_batchprocess"
          &btpr-rowid="doc-list.batchprocess_rowid"
        }

        if doc-list.is-trn-doc
        then do:
          run trg/aht-doc.p
            (input doc-list.doc-code /* p-doc-code */
            ,input ?                 /* p-cut-date */
            ).
        end.
        else do:
          run trg/aht-prc.p
            (input doc-list.doc-code /* p-doc-num  */
            ,input ?                 /* p-cut-date */
            ).
        end.
      end.
    end.
  end.

end procedure. /* process-object */