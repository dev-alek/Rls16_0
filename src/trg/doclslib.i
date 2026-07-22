/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Общая библиотека для работы со списком документов

Автор: Чернова Светлана Александровна
Дата создания: 02/03/10
Author: Svetlana Chernova
Creation date: 02/03/10

Автор1: Перваков Михаил Сергеевич
Дата создания: 08/28/01

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define temp-table doc-list no-undo
  field doc-code         like ub.trn-doc.doc-code
  field obj-type         like ub.trn-doc.obj-type
  field obj-code         like ub.trn-doc.obj-code
  field fact-date        like ub.trn-doc.fact-date
  field shift-date       like ub.trn-doc.shift-date
  field shift-num        like ub.trn-doc.shift-num
  field shift-name       like ub.trn-doc.shift-name
  field fact-order       as decimal
  field is-trn-doc       as logical
  field doc-type         like ub.trn-doc.doc-type
  field is-archive-exist as logical

  index xpk is primary unique doc-code doc-type
  index xfact-order fact-order
  index xfact-date  fact-date
  .

define temp-table doclslib-goods no-undo
  field gds-code  as integer
  field artic     as character
  field prod-type as character
  field prod-code as integer

  index xpk is primary unique gds-code
  index xie1 artic prod-type prod-code
  .

define buffer inkas_trn-doc for ub.trn-doc .

define stream doclsliblog .

procedure doclslib-clear-doc-list :

  define buffer buf_doc-list for doc-list .

  do
  on error undo, return error
  :
    for each buf_doc-list
    on error undo, return error
    :
      delete buf_doc-list .
    end.
  end.

end procedure. /* doclslib-clear-doc-list */


procedure doclslib-init-trn-doc :

  define input parameter p-obj-type      as character no-undo .
  define input parameter p-obj-code      as integer   no-undo .
  define input parameter p-cut-date      as date      no-undo .

  define buffer buf_trn-doc for ub.trn-doc .
  define buffer buf_doc-list for doc-list .

  do
  on error undo, return error
  :

    if p-cut-date = ?
    then do:
      for each buf_trn-doc no-lock
        where buf_trn-doc.obj-type = p-obj-type
          and buf_trn-doc.obj-code = p-obj-code
          and buf_trn-doc.status_  = {&fact}
      on error undo, return error
      :
        create buf_doc-list .
        assign
          buf_doc-list.doc-code   = buf_trn-doc.doc-code
          buf_doc-list.doc-type   = buf_trn-doc.doc-type
          buf_doc-list.fact-date  = buf_trn-doc.fact-date
          buf_doc-list.shift-date = buf_trn-doc.shift-date
          buf_doc-list.shift-num  = buf_trn-doc.shift-num
          buf_doc-list.shift-name = buf_trn-doc.shift-name
          buf_doc-list.fact-order = buf_trn-doc.fact-order
          buf_doc-list.is-trn-doc = true
        .
      end.
    end.
    else do:
      for each buf_trn-doc no-lock
        where buf_trn-doc.obj-type  = p-obj-type
          and buf_trn-doc.obj-code  = p-obj-code
          and buf_trn-doc.status_   = {&fact}
          and buf_trn-doc.fact-date >= p-cut-date
      on error undo, return error
      :
        create buf_doc-list .
        assign
          buf_doc-list.doc-code   = buf_trn-doc.doc-code
          buf_doc-list.doc-type   = buf_trn-doc.doc-type
          buf_doc-list.fact-date  = buf_trn-doc.fact-date
          buf_doc-list.shift-date = buf_trn-doc.shift-date
          buf_doc-list.shift-num  = buf_trn-doc.shift-num
          buf_doc-list.shift-name = buf_trn-doc.shift-name
          buf_doc-list.fact-order = buf_trn-doc.fact-order
          buf_doc-list.is-trn-doc = true
        .
      end.
    end.
  end.

end procedure. /* doclslib-init-trn-doc */


procedure doclslib-init-price-doc :

  define input parameter p-obj-type      as character no-undo .
  define input parameter p-obj-code      as integer   no-undo .
  define input parameter p-cut-date      as date      no-undo .

  define buffer buf_price-doc for ub.price-doc .
  define buffer buf_doc-list for doc-list .

  do
  on error undo, return error
  :
    if p-cut-date = ?
    then do:
      for each buf_price-doc no-lock
        where buf_price-doc.obj-type = p-obj-type
          and buf_price-doc.obj-code = p-obj-code
          and buf_price-doc.status_  = {&act-overvalue}
      on error undo, return error
      :
        create buf_doc-list .
        assign
          buf_doc-list.doc-code   = buf_price-doc.doc-num
          buf_doc-list.doc-type   = ''
          buf_doc-list.fact-date  = buf_price-doc.fact-date
          buf_doc-list.shift-date = buf_price-doc.shift-date
          buf_doc-list.shift-num  = buf_price-doc.shift-num
          buf_doc-list.shift-name = buf_price-doc.shift-name
          buf_doc-list.fact-order = buf_price-doc.fact-order
          buf_doc-list.is-trn-doc = false
        .
      end.
    end.
    else do:
      for each buf_price-doc no-lock
        where buf_price-doc.obj-type = p-obj-type
          and buf_price-doc.obj-code = p-obj-code
          and buf_price-doc.status_  = {&act-overvalue}
          and ub.buf_price-doc.fact-date >= p-cut-date
      on error undo, return error
      :
        create buf_doc-list .
        assign
          buf_doc-list.doc-code   = buf_price-doc.doc-num
          buf_doc-list.doc-type   = ''
          buf_doc-list.fact-date  = buf_price-doc.fact-date
          buf_doc-list.shift-date = buf_price-doc.shift-date
          buf_doc-list.shift-num  = buf_price-doc.shift-num
          buf_doc-list.shift-name = buf_price-doc.shift-name
          buf_doc-list.fact-order = buf_price-doc.fact-order
          buf_doc-list.is-trn-doc = false
        .
      end.
    end.
  end.

end procedure. /* doclslib-init-price-doc */


procedure doclslib-clear-bydate-doc-list :
  define input parameter p-fact-date as date no-undo .

  define buffer buf_doc-list for doc-list .

  /* удаление всех документов, по которым не нужно вести расчет складского архива */
  do
  on error undo, return error
  :
    if p-fact-date <> ?
    then do:
      for each buf_doc-list
        where buf_doc-list.fact-date < p-fact-date
      on error undo, return error
      :
        delete buf_doc-list .
      end.
    end.
  end.

end procedure. /* doclslib-clear-bydate-doc-list */


procedure doclslib-clear-rst :
  define input parameter p-fact-date as date no-undo .

  define buffer buf_doc-list for doc-list .

  /* удаление всех документов, по которым не нужно вести расчет складского архива */
  /* для расчета складского архива задним числом */
  do
  on error undo, return error
  :
    if p-fact-date <> ?
    then do:
      for each buf_doc-list
        where buf_doc-list.fact-date >= p-fact-date
      on error undo, return error
      :
        delete buf_doc-list .
      end.
    end.
  end.

end procedure. /* doclslib-clear-bydate-doc-list */


procedure doclslib-export-doc-list :
  /* выводим список документов, по которым мы будем вести расчет в текстовый файл */
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer no-undo .
  define input  parameter p-log-file-name as character no-undo .
  define input  parameter p-description   as character no-undo .

  define buffer buf_doc-list for doc-list .

  do
  on error undo, return error
  :
    output stream doclsliblog to value(p-log-file-name) .
    export stream doclsliblog "#############################################################" .
    export stream doclsliblog "Список документов" .
    export stream doclsliblog p-description .
    export stream doclsliblog "Объект" p-obj-type p-obj-code .
    export stream doclsliblog "Дата" string(today, '99/99/9999':U) string(time, 'HH:MM:SS':U).

    for each buf_doc-list
    by buf_doc-list.fact-order
    on error undo, return error
    :
      export stream doclsliblog buf_doc-list .
    end.

    export stream doclsliblog "#############################################################" .
    output stream doclsliblog close .
  end.

end procedure. /* doclslib-export-doc-list */


procedure doclslib-clear-batch-process :

  define input parameter p-bp_type like ub.batchprocess.bp_type no-undo .

  define buffer buf_batchprocess        for ub.batchprocess .
  define buffer execdelete_batchprocess for ub.batchprocess .
  define buffer buf_doc-list            for doc-list .

  for each buf_doc-list
  on end-key undo, return error substitute( "doclslib-clear-batch-process. end-key   &1&2&3", return-value, {&new-line}, error-status :get-message ( 1 ) )
  on error   undo, return error substitute( "doclslib-clear-batch-process. error     &1&2&3", return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop    undo, return error substitute( "doclslib-clear-batch-process. STOP      &2"
                                 + "bp_type &3&2"
                                 + "Документ &4"
                                 , {&new-line}
                                 , p-bp_type
                                 , buf_doc-list.doc-code
                                )
  :
    find first buf_batchprocess exclusive-lock
      where buf_BatchProcess.BP_Status   = {&btpr-normal}
        and buf_batchprocess.bp_type     = p-bp_type
        and buf_batchprocess.charkey_one = buf_doc-list.doc-code
      no-error .
    if available buf_batchprocess
    then do:
      delete buf_batchprocess .
    end.
  end.

end procedure. /* doclslib-clear-batch-process */


procedure doclslib-calc-arh :

  define input  parameter p-log-handle     as handle    no-undo .
  define input  parameter p-obj-type       as character no-undo .
  define input  parameter p-obj-code       as integer   no-undo .
  define input  parameter p-cut-date       as date      no-undo .
  define input  parameter p-update-recalc  as logical   no-undo .

  define variable v-prev-fact-date as date      no-undo .

  define buffer buf_doc-list for doc-list .
  define buffer stop-arh-restore-lock_btpr for ub.batchprocess .
  define buffer stop-arh-news-lock_btpr    for ub.batchprocess .

  do
  on stop    undo, return error substitute( "doclslib-calc-arh. stop      &1&2&3", return-value, {&new-line}, error-status :get-message ( 1 ) )
  on end-key undo, return error substitute( "doclslib-calc-arh. end-key   &1&2&3", return-value, {&new-line}, error-status :get-message ( 1 ) )
  on error   undo, return error substitute( "doclslib-calc-arh. error     &1&2&3", return-value, {&new-line}, error-status :get-message ( 1 ) )

  :
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

    for each buf_doc-list
    by buf_doc-list.fact-order
    on stop    undo, return error substitute( "f e . stop      &1&2&3", return-value, {&new-line}, error-status :get-message ( 1 ) )
    on end-key undo, return error substitute( "f e . end-key   &1&2&3", return-value, {&new-line}, error-status :get-message ( 1 ) )
    on error   undo, return error substitute( "f e . error     &1&2&3", return-value, {&new-line}, error-status :get-message ( 1 ) )
    :
      find first stop-arh-restore-lock_btpr no-lock
        where stop-arh-restore-lock_btpr.bp_type       = {&btpr-type-lock} + {&lock-prc-stop-arh-restore}
          and stop-arh-restore-lock_btpr.bp_status     = {&btpr-normal}
          and stop-arh-restore-lock_btpr.Key#_One      = buf_doc-list.obj-code
          and stop-arh-restore-lock_btpr.Key#_Two      = 0
          and stop-arh-restore-lock_btpr.Key#_Three    = 0
          and stop-arh-restore-lock_btpr.CharKey_One   = buf_doc-list.obj-type
          and stop-arh-restore-lock_btpr.CharKey_Two   = ""
          and stop-arh-restore-lock_btpr.CharKey_Three = ""
        no-error .
      if available stop-arh-restore-lock_btpr
      then do:
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input "Процедура восстановления складского архива запросила остановку процедуры расчета складского архива"
          ) .
        undo, return error "Процедура восстановления складского архива запросила остановку процедуры расчета складского архива" .
      end.

      find first stop-arh-news-lock_btpr no-lock
        where stop-arh-news-lock_btpr.bp_type       = {&btpr-type-lock} + {&lock-prc-stop-arh-news}
          and stop-arh-news-lock_btpr.bp_status     = {&btpr-normal}
          and stop-arh-news-lock_btpr.Key#_One      = buf_doc-list.obj-code
          and stop-arh-news-lock_btpr.Key#_Two      = 0
          and stop-arh-news-lock_btpr.Key#_Three    = 0
          and stop-arh-news-lock_btpr.CharKey_One   = buf_doc-list.obj-type
/*          and stop-arh-news-lock_btpr.CharKey_Two   = ""*/
          and stop-arh-news-lock_btpr.CharKey_Three = ""
        no-error .
      if available stop-arh-news-lock_btpr
      then do:
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input "Система новостей запросила остановку процедуры расчета складского архива"
          ) .
        undo, return error "Система новостей запросила остановку процедуры расчета складского архива" .
      end.

      if buf_doc-list.is-trn-doc
      then do:
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input substitute("Начало расчёта. Документ &1. Факт &2. Номер &3"
                           ,buf_doc-list.doc-code
                           ,string(buf_doc-list.fact-date, '99/99/9999':u)
                           ,buf_doc-list.fact-order
                           )
          ) .
        run trg/calc-arh.p
          (input buf_doc-list.doc-code /* p-doc-code */
          ,input p-cut-date            /* p-cut-date */
          ).
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input substitute("Расчёт завершен. Документ &1. Факт &2. Номер &3"
                           ,buf_doc-list.doc-code
                           ,string(buf_doc-list.fact-date, '99/99/9999':u)
                           ,buf_doc-list.fact-order
                           )
          ) .
      end.
      else do:
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input substitute("Начало расчёта. Переоценка &1. Факт &2. Номер &3"
                           ,buf_doc-list.doc-code
                           ,string(buf_doc-list.fact-date, '99/99/9999':u)
                           ,buf_doc-list.fact-order
                           )
          ) .
        run trg/calc-apc.p
          (input buf_doc-list.doc-code /* p-doc-num  */
          ,input p-cut-date            /* p-cut-date */
          ).
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input substitute("Расчёт завершен. Переоценка &1. Факт &2. Номер &3"
                           ,buf_doc-list.doc-code
                           ,string(buf_doc-list.fact-date, '99/99/9999':u)
                           ,buf_doc-list.fact-order
                           )
          ) .
      end.

      /* если необходимо обновлять дату перерасчета */
      /* в случае, когда обрабатывается первый документ нового дня */
      /* и необходимо устанавливать дату перерасчета */
      if  p-update-recalc  = true
      and v-prev-fact-date <> ?
      and buf_doc-list.fact-date > v-prev-fact-date
      then do:
        /* устанавливаем дату, с которой производится перерасчет складского архива по товарам */
        run gbl/clntat-w.p
          (input p-obj-type                                     /* p-obj-type */
          ,input p-obj-code                                     /* p-obj-code */
          ,input {&attr-arh-recalc-date}                        /* p-code     */
          ,input string(buf_doc-list.fact-date, '99/99/9999':U) /* p-value    */
          ) .
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input substitute("Завершён расчет дня &1. Устанавливается дата перерасчёта &2"
                           ,string(v-prev-fact-date, '99/99/9999':u)
                           ,string(buf_doc-list.fact-date, '99/99/9999':u)
                           )
          ) .
      end.

      assign
        v-prev-fact-date = buf_doc-list.fact-date
      .
    end.
  end.

end procedure. /* doclslib-calc-arh */


procedure doclslib-calc-aht :

  define input  parameter p-log-handle    as handle    no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define input  parameter p-cut-date      as date      no-undo .
  define input  parameter p-update-recalc as logical   no-undo .

  define variable v-prev-fact-date as date      no-undo .

  define buffer buf_doc-list for doc-list .
  define buffer stop-aht-restore-lock_btpr for ub.batchprocess .
  define buffer stop-aht-news-lock_btpr    for ub.batchprocess .

  do
  on error undo, return error return-value
  :
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


    /* расчет складского архива по типам приобретения */
    for each buf_doc-list
    by buf_doc-list.fact-order
    on error undo, return error
    :
      find first stop-aht-restore-lock_btpr no-lock
        where stop-aht-restore-lock_btpr.bp_type       = {&btpr-type-lock} + {&lock-prc-stop-aht-restore}
          and stop-aht-restore-lock_btpr.bp_status     = {&btpr-normal}
          and stop-aht-restore-lock_btpr.Key#_One      = buf_doc-list.obj-code
          and stop-aht-restore-lock_btpr.Key#_Two      = 0
          and stop-aht-restore-lock_btpr.Key#_Three    = 0
          and stop-aht-restore-lock_btpr.CharKey_One   = buf_doc-list.obj-type
          and stop-aht-restore-lock_btpr.CharKey_Two   = ""
          and stop-aht-restore-lock_btpr.CharKey_Three = ""
        no-error .
      if available stop-aht-restore-lock_btpr
      then do:
        undo, return error "Процедура восстановления складского архива запросила остановку процедуры автоматического расчета складского архива" .
      end.

      find first stop-aht-news-lock_btpr no-lock
        where stop-aht-news-lock_btpr.bp_type       = {&btpr-type-lock} + {&lock-prc-stop-aht-news}
          and stop-aht-news-lock_btpr.bp_status     = {&btpr-normal}
          and stop-aht-news-lock_btpr.Key#_One      = buf_doc-list.obj-code
          and stop-aht-news-lock_btpr.Key#_Two      = 0
          and stop-aht-news-lock_btpr.Key#_Three    = 0
          and stop-aht-news-lock_btpr.CharKey_One   = buf_doc-list.obj-type
/*          and stop-aht-news-lock_btpr.CharKey_Two   = ""*/
          and stop-aht-news-lock_btpr.CharKey_Three = ""
        no-error .
      if available stop-aht-news-lock_btpr
      then do:
        undo, return error "Система новостей запросила остановку процедуры автоматического расчета складского архива" .
      end.

      if buf_doc-list.is-trn-doc
      then do:
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input substitute("Начало расчёта. Документ &1. Факт &2. Номер &3"
                           ,buf_doc-list.doc-code
                           ,string(buf_doc-list.fact-date, '99/99/9999':u)
                           ,buf_doc-list.fact-order
                           )
          ) .
        run trg/aht-doc.p
          (input buf_doc-list.doc-code /* p-doc-code */
          ,input p-cut-date            /* p-cut-date */
          ).
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input substitute("Расчёт завершен. Документ &1. Факт &2. Номер &3"
                           ,buf_doc-list.doc-code
                           ,string(buf_doc-list.fact-date, '99/99/9999':u)
                           ,buf_doc-list.fact-order
                           )
          ) .
      end.
      else do:
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input substitute("Начало расчёта. Переоценка &1. Факт &2. Номер &3"
                           ,buf_doc-list.doc-code
                           ,string(buf_doc-list.fact-date, '99/99/9999':u)
                           ,buf_doc-list.fact-order
                           )
          ) .
        run trg/aht-prc.p
          (input buf_doc-list.doc-code /* p-doc-num  */
          ,input p-cut-date            /* p-cut-date */
          ).
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input substitute("Расчёт завершен. Переоценка &1. Факт &2. Номер &3"
                           ,buf_doc-list.doc-code
                           ,string(buf_doc-list.fact-date, '99/99/9999':u)
                           ,buf_doc-list.fact-order
                           )
          ) .
      end.

      /* если необходимо обновлять дату перерасчета */
      /* в случае, когда обрабатывается первый документ нового дня */
      /* и необходимо устанавливать дату перерасчета */
      if  p-update-recalc  = true
      and v-prev-fact-date <> ?
      and buf_doc-list.fact-date > v-prev-fact-date
      then do:
        /* устанавливаем дату, с которой производится перерасчет складского архива по типам приобретения */
        run gbl/clntat-w.p
          (input p-obj-type                                     /* p-obj-type */
          ,input p-obj-code                                     /* p-obj-code */
          ,input {&attr-aht-recalc-date}                        /* p-code     */
          ,input string(buf_doc-list.fact-date, '99/99/9999':U) /* p-value    */
          ) .
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input substitute("Завершён расчет дня &1. Устанавливается дата перерасчёта &2"
                           ,string(v-prev-fact-date, '99/99/9999':u)
                           ,string(buf_doc-list.fact-date, '99/99/9999':u)
                           )
          ) .
      end.

      assign
        v-prev-fact-date = buf_doc-list.fact-date
      .
    end.
  end.

end procedure. /* doclslib-calc-aht */



procedure doclslib-calc-ahsp :

  define input  parameter p-log-handle    as handle    no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define input  parameter p-cut-date      as date      no-undo .
  define input  parameter p-update-recalc as logical   no-undo .

  define variable v-prev-fact-date as date      no-undo .

  define buffer buf_doc-list for doc-list .
  define buffer stop-ahsp-restore-lock_btpr for ub.batchprocess .
  define buffer stop-ahsp-news-lock_btpr    for ub.batchprocess .

  do
  on error undo, return error return-value
  :
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

    /* расчет складского архива по поставщикам */
    for each buf_doc-list
      where buf_doc-list.is-trn-doc = true
    by buf_doc-list.fact-order
    on error undo, return error
    :
      find first stop-ahsp-restore-lock_btpr no-lock
        where stop-ahsp-restore-lock_btpr.bp_type       = {&btpr-type-lock} + {&lock-prc-stop-ahsp-restore}
          and stop-ahsp-restore-lock_btpr.bp_status     = {&btpr-normal}
          and stop-ahsp-restore-lock_btpr.Key#_One      = buf_doc-list.obj-code
          and stop-ahsp-restore-lock_btpr.Key#_Two      = 0
          and stop-ahsp-restore-lock_btpr.Key#_Three    = 0
          and stop-ahsp-restore-lock_btpr.CharKey_One   = buf_doc-list.obj-type
          and stop-ahsp-restore-lock_btpr.CharKey_Two   = ""
          and stop-ahsp-restore-lock_btpr.CharKey_Three = ""
        no-error .
      if available stop-ahsp-restore-lock_btpr
      then do:
        undo, return error "Процедура восстановления складского архива запросила остановку процедуры расчета складского архива" .
      end.

      find first stop-ahsp-news-lock_btpr no-lock
        where stop-ahsp-news-lock_btpr.bp_type       = {&btpr-type-lock} + {&lock-prc-stop-ahsp-news}
          and stop-ahsp-news-lock_btpr.bp_status     = {&btpr-normal}
          and stop-ahsp-news-lock_btpr.Key#_One      = buf_doc-list.obj-code
          and stop-ahsp-news-lock_btpr.Key#_Two      = 0
          and stop-ahsp-news-lock_btpr.Key#_Three    = 0
          and stop-ahsp-news-lock_btpr.CharKey_One   = buf_doc-list.obj-type
/*          and stop-ahsp-news-lock_btpr.CharKey_Two   = ""*/
          and stop-ahsp-news-lock_btpr.CharKey_Three = ""
        no-error .
      if available stop-ahsp-news-lock_btpr
      then do:
        undo, return error "Система новостей запросила остановку процедуры расчета складского архива" .
      end.

      run doclslib-log-information in this-procedure
        (input p-log-handle
        ,input substitute("Начало расчёта. Документ &1. Факт &2. Номер &3"
                          ,buf_doc-list.doc-code
                          ,string(buf_doc-list.fact-date, '99/99/9999':u)
                          ,buf_doc-list.fact-order
                          )
        ) .
      define variable v-need-process as logical   no-undo .
      run trg/ah-csptr.p
        (input  buf_doc-list.doc-code /* p-doc-code     */
        ,input  p-cut-date            /* p-cut-date     */
        ,input  false                 /* p-check-only   */
        ,output v-need-process        /* p-need-process */
        ).
      run doclslib-log-information in this-procedure
        (input p-log-handle
        ,input substitute("Расчёт завершен. Документ &1. Факт &2. Номер &3"
                          ,buf_doc-list.doc-code
                          ,string(buf_doc-list.fact-date, '99/99/9999':u)
                          ,buf_doc-list.fact-order
                          )
        ) .

      /* если необходимо обновлять дату перерасчета */
      /* в случае, когда обрабатывается первый документ нового дня */
      /* и необходимо устанавливать дату перерасчета */
      if  p-update-recalc  = true
      and v-prev-fact-date <> ?
      and buf_doc-list.fact-date > v-prev-fact-date
      then do:
        /* устанавливаем дату, с которой производится перерасчет складского архива по поставщикам */
        run gbl/clntat-w.p
          (input p-obj-type                                     /* p-obj-type */
          ,input p-obj-code                                     /* p-obj-code */
          ,input {&attr-ahsp-recalc-date}                        /* p-code     */
          ,input string(buf_doc-list.fact-date, '99/99/9999':U) /* p-value    */
          ) .
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input substitute("Завершён расчет дня &1. Устанавливается дата перерасчёта &2"
                           ,string(v-prev-fact-date, '99/99/9999':u)
                           ,string(buf_doc-list.fact-date, '99/99/9999':u)
                           )
          ) .
      end.

      assign
        v-prev-fact-date = buf_doc-list.fact-date
      .
    end.
  end.

end procedure. /* doclslib-calc-ahsp */


procedure doclslib-log-information :

  define input  parameter p-log-handle as handle    no-undo .
  define input  parameter p-message    as character no-undo .

  do
  on error undo, return error return-value
  :
    define variable v-log-procedure-name as character no-undo .

    assign
      v-log-procedure-name = "cb-doclslib-log"
    .

    if valid-handle(p-log-handle)
    and p-log-handle :get-signature(v-log-procedure-name) <> ""
    then do:
      run value(v-log-procedure-name) in p-log-handle
        (input p-message
        ) no-error .
    end.
  end.

end procedure. /* doclslib-log-information */


procedure doclslib-find-last-fact-date :

  define output parameter p-last-fact-date  as date      no-undo .
  define output parameter p-reason          as character no-undo .

  do
  on error undo, return error
  :
    define variable v-last-fact-date    as date      no-undo .

    define buffer buf_doc-list for doc-list .

    assign
      v-last-fact-date    = ?
    .

    for each buf_doc-list
    by buf_doc-list.fact-order
    on error undo, return error
    :
      if buf_doc-list.is-archive-exist = false
      or buf_doc-list.fact-date = ?
      then do:
        assign
          p-reason = p-reason + substitute("По документу &1 отсутствует рассчитанный складской архив"
                                          ,buf_doc-list.doc-code
                                          )
        .
        leave .
      end.

      if buf_doc-list.fact-date = ?
      then do:
        assign
          p-reason = p-reason + substitute("Документ &1 имеет не заданную фактическую дату "
                                          ,buf_doc-list.doc-code
                                          )
        .
        leave .
      end.
      if v-last-fact-date = ?
      or (v-last-fact-date <> ?
          and v-last-fact-date < buf_doc-list.fact-date
         )
      then do:
        assign
          v-last-fact-date = buf_doc-list.fact-date
          p-reason         = substitute("Последний рассчитанный документ &1" + {&new-line}
                                       ,buf_doc-list.doc-code
                                       )
        .
      end.
    end.

    assign
      p-last-fact-date = v-last-fact-date
    .
  end.

end procedure. /* doclslib-find-last-fact-date */


procedure doclslib-check-arh-exist :
  define input parameter  p-obj-type       as character no-undo .
  define input parameter  p-obj-code       as integer   no-undo .
  define input parameter  p-cut-fact-order as decimal   no-undo .
  define output parameter p-archive-exist  as logical   no-undo .

  define buffer buf_stk-tot for ub.stk-tot .

  do
  on error undo, return error
  :
    find first buf_stk-tot no-lock
      where buf_stk-tot.obj-type   = p-obj-type
        and buf_stk-tot.obj-code   = p-obj-code
        and buf_stk-tot.fact-order > p-cut-fact-order
      no-error .
    assign
      p-archive-exist = (available buf_stk-tot)
    .
  end.

end procedure. /* doclslib-check-arh-exist */


procedure doclslib-check-aht-exist :
  define input parameter  p-obj-type       as character no-undo .
  define input parameter  p-obj-code       as integer   no-undo .
  define input parameter  p-cut-fact-order as decimal   no-undo .
  define output parameter p-archive-exist  as logical   no-undo .

  define buffer buf_aht-stk-tot for ub.aht-stk-tot .

  do
  on error undo, return error
  :
    find first buf_aht-stk-tot no-lock
      where buf_aht-stk-tot.obj-type   = p-obj-type
        and buf_aht-stk-tot.obj-code   = p-obj-code
        and buf_aht-stk-tot.fact-order > p-cut-fact-order
      no-error .
    assign
      p-archive-exist = (available buf_aht-stk-tot)
    .
  end.

end procedure. /* doclslib-check-aht-exist */


procedure doclslib-check-ahsp-exist :
  define input parameter  p-obj-type       as character no-undo .
  define input parameter  p-obj-code       as integer   no-undo .
  define input parameter  p-cut-fact-order as decimal   no-undo .
  define output parameter p-archive-exist  as logical   no-undo .

  define buffer buf_stk-supp-tot for ub.stk-supp-tot .

  do
  on error undo, return error
  :
    find first buf_stk-supp-tot no-lock
      where buf_stk-supp-tot.obj-type   = p-obj-type
        and buf_stk-supp-tot.obj-code   = p-obj-code
        and buf_stk-supp-tot.fact-order > p-cut-fact-order
      no-error .
    assign
      p-archive-exist = (available buf_stk-supp-tot)
    .
  end.

end procedure. /* doclslib-check-ahsp-exist */


procedure doclslib-check-doc-arh-exist :

  define buffer buf_doc-list for doc-list .
  define buffer buf_ot-tot for ub.ot-tot .

  do
  on error undo, return error return-value
  :

    for each buf_doc-list
    on error undo, return error
    :
      find first buf_ot-tot no-lock
        where buf_ot-tot.doc-code = buf_doc-list.doc-code
        no-error .
      if available buf_ot-tot
      then do:
        assign
          buf_doc-list.is-archive-exist = true
        .
      end.
      else do:
        assign
          buf_doc-list.is-archive-exist = false
        .
      end.
    end.

  end.

end procedure. /* doclslib-check-doc-arh-exist */


procedure doclslib-check-doc-aht-exist :

  define buffer buf_doc-list for doc-list .
  define buffer buf_aht-doc for ub.aht-doc .

  do
  on error undo, return error return-value
  :

    for each buf_doc-list
    on error undo, return error
    :
      find first buf_aht-doc no-lock
        where buf_aht-doc.doc-code = buf_doc-list.doc-code
        no-error .
      if available buf_aht-doc
      then do:
        assign
          buf_doc-list.is-archive-exist = true
        .
      end.
      else do:
        assign
          buf_doc-list.is-archive-exist = false
        .
      end.
    end.

  end.

end procedure. /* doclslib-check-doc-aht-exist */


procedure doclslib-check-doc-ahsp-exist :

  define buffer buf_doc-list for doc-list .
  define buffer buf_ot-supp-line for ub.ot-supp-tot .


  do
  on error undo, return error return-value
  :
    for each buf_doc-list
    on error undo, return error
    :
      find first buf_ot-supp-line no-lock
        where buf_ot-supp-line.doc-code = buf_doc-list.doc-code
        no-error .
      if available buf_ot-supp-line
      then do:
        assign
          buf_doc-list.is-archive-exist = true
        .
      end.
      else do:
        /* так как записи в случае нулевых количеств не сохраняются в базу данных, */
        /* необходимо документы инвентаризации, которые имеют нулевые суммы, */
        /* считать уже рассчитанными  */
        if buf_doc-list.doc-type = {&inventory}
        then do:
          define variable v-need-process as logical   no-undo .
          run trg/ah-csptr.p
            (input  buf_doc-list.doc-code /* p-doc-code       */
            ,input  0                     /* p-cut-fact-order */
            ,input  true                  /* p-check-only     */
            ,output v-need-process        /* p-need-process   */
            ).
          if v-need-process = true
          then do:
            assign
              buf_doc-list.is-archive-exist = false
            .
          end.
          else do:
            assign
              buf_doc-list.is-archive-exist = true
            .
          end.
        end.
        else do:
          assign
            buf_doc-list.is-archive-exist = false
          .
        end.
      end.
    end.
  end.

end procedure. /* doclslib-check-doc-ahsp-exist */


procedure doclslib-clear-ahsp-doc-list :

  define buffer buf_doc-list for doc-list .
  define buffer buf_trn-doc  for ub.trn-doc .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_parts    for ub.parts .

  do
  on error undo, return error return-value
  :

    /* удаляем все документы, которые не содержат товары */
    check-doc-list :
    for each buf_doc-list
    on error undo, return error return-value
    :
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = buf_doc-list.doc-code
        .
      if buf_trn-doc.office = true
      then do:
        /* это документ по услугам */
        /* такие документы не попадают в складской архив по поставщикам */
        delete buf_doc-list .
        next check-doc-list .
      end.

      find first buf_doc-line no-lock
        where buf_doc-line.doc-code = buf_trn-doc.doc-code
        no-error .
      if not available buf_doc-line
      then do:
        /* в документе нет ни одной строки */
        /* такие документы не попадают в складской архив по поставщикам */
        delete buf_doc-list .
        next check-doc-list .
      end.

      find first buf_parts no-lock
        where buf_parts.out-code = buf_trn-doc.doc-code
          and buf_parts.fact-qnty <> 0
        no-error .
      if not available buf_parts
      then do:
        /* в документе нет ни одной строки */
        /* такие документы не попадают в складской архив по поставщикам */
        delete buf_doc-list .
        next check-doc-list .
      end.
    end.

  end.

end procedure. /* doclslib-clear-ahsp-doc-list */


procedure doclslib-init-goods :

  define buffer buf_doclslib-goods for doclslib-goods .
  define buffer buf_doc-list       for doc-list .
  define buffer buf_trn-doc        for ub.trn-doc .
  define buffer buf_price-doc      for ub.price-doc .
  define buffer buf_doc-line       for ub.doc-line .
  define buffer buf_price-list     for ub.price-list .

  define variable v-gds-code as integer   no-undo .

  do
  on error undo, return error return-value
  :

    for each buf_doclslib-goods
    on error undo, return error return-value
    :
      delete buf_doclslib-goods .
    end.

    for each buf_doc-list
    on error undo, return error return-value
    :
      if buf_doc-list.is-trn-doc
      then do:
        find first buf_trn-doc no-lock
          where buf_trn-doc.doc-code = buf_doc-list.doc-code
          .

        for each buf_doc-line no-lock
          where buf_doc-line.doc-code = buf_trn-doc.doc-code
        on error undo, return error return-value
        :
          { gbl/gds-code.i
            buf_doc-line.artic
            buf_doc-line.prod-type
            buf_doc-line.prod-code
            v-gds-code
          }

          find first buf_doclslib-goods
            where buf_doclslib-goods.gds-code = v-gds-code
            no-error .
          if not available buf_doclslib-goods
          then do:
            create buf_doclslib-goods .
            assign
              buf_doclslib-goods.gds-code  = v-gds-code
              buf_doclslib-goods.artic     = buf_doc-line.artic
              buf_doclslib-goods.prod-type = buf_doc-line.prod-type
              buf_doclslib-goods.prod-code = buf_doc-line.prod-code
            .
          end.
        end.
      end.
      else do:
        find first buf_price-doc no-lock
          where buf_price-doc.doc-num = buf_doc-list.doc-code
          .

        for each buf_price-list no-lock
          where buf_price-list.doc-num = buf_price-doc.doc-num
        on error undo, return error return-value
        :
          { gbl/gds-code.i
            buf_price-list.artic
            buf_price-list.prod-type
            buf_price-list.prod-code
            v-gds-code
          }

          find first buf_doclslib-goods
            where buf_doclslib-goods.gds-code = v-gds-code
            no-error .
          if not available buf_doclslib-goods
          then do:
            create buf_doclslib-goods .
            assign
              buf_doclslib-goods.gds-code  = v-gds-code
              buf_doclslib-goods.artic     = buf_price-list.artic
              buf_doclslib-goods.prod-type = buf_price-list.prod-type
              buf_doclslib-goods.prod-code = buf_price-list.prod-code
            .
          end.
        end.
      end.
    end.
  end.

end procedure. /* doclslib-init-goods */

/* $Workfile$ */