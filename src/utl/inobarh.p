block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: inobarh.p $
$Archive: utl/inobarh.p $

Инициализвация остатков складского архива по товарам для одного объекта

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 06/23/06

*/

define input  parameter p-obj-type    as character no-undo .
define input  parameter p-obj-code    as integer   no-undo .
define input  parameter p-cut-date    as date      no-undo .
define output parameter p-error-count as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: inobarh.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/inobarh.p $":U .
define variable vss-description as character no-undo init "Расчет остатков в складском архиве по товарам на основании текущих остатков товара".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ gbl/arh.i      }
{ trg/factord.i  }
{ gbl/clntattr.i }
{ trg/doclslib.i }
{ trg/prdoclib.i }
{ trg/partslib.i }
{ str/prl-vat.i  }
{ str/clcprtsl.i }

{&def-temp-stk-tot}
{&def-temp-stk-line}
{&def-var-list}

define stream slog .

define variable v-total-err       as integer   no-undo .
define variable v-log-file-name   as character no-undo .
define variable v-error-file-name as character no-undo .
define variable v-list-file-name  as character no-undo .

do
on error undo, return error return-value
:

  assign
    v-log-file-name   = substitute('inobarh_&1_&2.txt':U
                                  ,p-obj-type
                                  ,p-obj-code
                                  )
    v-error-file-name = substitute('inobarh_&1_&2.err':U
                                  ,p-obj-type
                                  ,p-obj-code
                                  )
    v-list-file-name  = substitute('inobarh_&1_&2_doc_list.txt':U
                                  ,p-obj-type
                                  ,p-obj-code
                                  )
  .


  define variable v-curr-r-b as character no-undo .
  { gbl/curr-r-b.i
    v-curr-r-b
  }

/* на сменном объекте необходимо заблокировать смену */
    define buffer lock_shift-obj for ub.shift-obj .
    run factord-lock-shift in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-cut-date
      ,buffer lock_shift-obj
      ) no-error .
    if error-status :error
    then do:
      run log-information in this-procedure
        (input p-obj-type             /* p-obj-type */
        ,input p-obj-code             /* p-obj-code */
        ,input substitute("Процесс остановлен:  &1" , return-value  )
        ) .

      run clntattr-write in this-procedure
        (input  p-obj-type                 /* p-obj-type */
        ,input  p-obj-code                 /* p-obj-code */
        ,input  {&attr-arh-del}            /* p-code     */
        ,input  "yes"                      /* p-value    */
        ) no-error .

      run clntattr-write in this-procedure
        (input  p-obj-type                 /* p-obj-type */
        ,input  p-obj-code                 /* p-obj-code */
        ,input  {&attr-arh-calc}           /* p-code     */
        ,input  "yes"                      /* p-value    */
        ) no-error .
        p-error-count = 1 .
    end.
   else do:
        run process-object in this-procedure
          (input  p-obj-type
          ,input  p-obj-code
          ,input  p-cut-date
          ) .

        assign
          p-error-count = v-total-err
        .
  end.
end.

procedure process-object :

  define input  parameter p-obj-type like ub.gds-obj.obj-type no-undo .
  define input  parameter p-obj-code like ub.gds-obj.obj-code no-undo .
  define input  parameter p-cut-date as date      no-undo .

  do
  on error undo, return error return-value
  :
    define buffer calc-arh-lock_batchprocess for ub.batchprocess .

    /* блокировка расчёта складского архива по товарам */
    run gbl/lock-prc.p
      (input {&lock-prc-calc-arh}
      ,input p-obj-code
      ,input 0
      ,input 0
      ,input p-obj-type
      ,input ""
      ,input ""
      ,input "Объект,,, ,,,Расчёт складского архива по товару"
      ,input true
      ,buffer calc-arh-lock_batchprocess
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "В данный момент рассчитывается складской архив по товарам" skip
        "Невозможно произвести расчет складского архива по товарам на основании документов" skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    define buffer restore-arh-lock_batchprocess for ub.batchprocess .
    /* блокировка процедуры восстановления складского архива */
    run gbl/lock-prc.p
      (input {&lock-prc-restore-arh}
      ,input p-obj-code
      ,input 0
      ,input 0
      ,input p-obj-type
      ,input ""
      ,input ""
      ,input "Объект,,, ,,,Восстановление складского складского архива по товарам"
      ,input true
      ,buffer restore-arh-lock_batchprocess
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры блокировки восстановления складского архива по товарам" skip
          "Объект" p-obj-type p-obj-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo, return error return-value .
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


    do transaction
    on error undo, return error return-value
    :

      /* так как производится инициализация архива */
      /* то очищаем всю историю */
      run utl/arhiclr.p
        (input  p-obj-type       /* p-obj-type              */
        ,input  p-obj-code       /* p-obj-code              */
        ,input  {&btpr-type-arh} /* p-archive-type          */
        ) .

      /* создаем запись об инициализации архива */
      define variable v-create-chip-num as integer   no-undo .

      run utl/arhiscr.p
        (input  p-obj-type                    /* p-obj-type              */
        ,input  p-obj-code                    /* p-obj-code              */
        ,input  {&btpr-type-arh}              /* p-archive-type          */
        ,input  {&archive-history-init-start} /* p-action-type           */
        ,input  ""                            /* p-file-name             */
        ,input  ""                            /* p-file-md5              */
        ,input  0                             /* p-file-invalid-chip-num */
        ,input  ""                            /* p-source-type           */
        ,input  ""                            /* p-source-ref            */
        ,input  p-cut-date                    /* p-source-date           */
        ,output v-create-chip-num             /* p-create-chip-num       */
        ) .
    end.

    run invalidate-md5-signature in this-procedure
      (input  p-obj-type        /* p-obj-type              */
      ,input  p-obj-code        /* p-obj-code              */
      ,input  {&btpr-type-arh}  /* p-archive-type          */
      ,input  v-create-chip-num /* p-create-chip-num       */
      ) .

    define variable v-delete-ind       as integer   no-undo .
    define variable v-delete-attr-list as character no-undo .
    define variable v-attr-delete      as logical   no-undo .

    assign
      v-delete-attr-list  = {&attr-arh-detail-date}
          + {&comma-char} + {&attr-arh-start-date}
          + {&comma-char} + {&attr-arh-del}
          + {&comma-char} + {&attr-arh-disable}
          + {&comma-char} + {&attr-arh-calc}
          + {&comma-char} + {&attr-arh-recalc-date}
    .

    /* удаляем все атрибуты, */
    /* которые относятся к складскому архиву по товарам */
    do v-delete-ind = 1 to num-entries(v-delete-attr-list, {&comma-char})
    :
      run clntattr-delete in this-procedure
        (input p-obj-type
        ,input p-obj-code
        ,input entry(v-delete-ind, v-delete-attr-list, {&comma-char})
        ,output v-attr-delete
        ) .
    end.

    /* устанавливаем признак того, */
    /* что на объекте производится расчет складского архива по товарам */
    run clntattr-write in this-procedure
      (input p-obj-type       /* p-obj-type */
      ,input p-obj-code       /* p-obj-code */
      ,input {&attr-arh-calc} /* p-code     */
      ,input true             /* p-value    */
      ) .

    /* помечаем, что на объекте производится первоначальный расчет */
    /* остатков */
    run clntattr-write in this-procedure
      (input p-obj-type       /* p-obj-type */
      ,input p-obj-code       /* p-obj-code */
      ,input {&attr-arh-del} /* p-code     */
      ,input true             /* p-value    */
      ) .

    os-delete value(v-error-file-name) .

    run log-clear in this-procedure
      .

    run log-information in this-procedure
      (input p-obj-type             /* p-obj-type */
      ,input p-obj-code             /* p-obj-code */
      ,input "Начало инициализации" /* p-message  */
      ) .

    define variable v-archive-date         as date      no-undo .
    define variable v-shift-on             as logical   no-undo .
    define variable v-shift-date           as date      no-undo .
    define variable v-shift-num            as integer   no-undo .
    define variable v-fact-order           as decimal   no-undo .
    define variable v-shift-end-fact-order as decimal   no-undo .
    define variable v-day-end-fact-order   as decimal   no-undo .

    assign
      v-archive-date = p-cut-date - 1
    .

    /* на сменном объекте необходимо заблокировать смену */
    define buffer lock_shift-obj for ub.shift-obj .
    run factord-lock-shift in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  v-archive-date
      ,buffer lock_shift-obj
      ) no-error .
    if error-status :error
    then do:
      run log-information in this-procedure
        (input p-obj-type             /* p-obj-type */
        ,input p-obj-code             /* p-obj-code */
        ,input substitute("Процесс прерван:  &1" , return-value  )
        ) .
        undo, return.
    end.

    run factord-cut-archive in this-procedure
      (input  p-obj-type             /* p-obj-type             */
      ,input  p-obj-code             /* p-obj-code             */
      ,input  v-archive-date         /* p-fact-date            */
      ,output v-shift-on             /* p-shift-on             */
      ,output v-shift-date           /* p-shift-date           */
      ,output v-shift-num            /* p-shift-num            */
      ,output v-day-end-fact-order   /* p-day-end-fact-order   */
      ,output v-shift-end-fact-order /* p-shift-end-fact-order */
      ) .

    run log-information in this-procedure
      (input p-obj-type                      /* p-obj-type */
      ,input p-obj-code                      /* p-obj-code */
      ,input "Составление списка документов" /* p-message  */
      ) .

    run doclslib-clear-doc-list in this-procedure .

    run doclslib-init-trn-doc in this-procedure
      (input p-obj-type /* p-obj-type */
      ,input p-obj-code /* p-obj-code */
      ,input p-cut-date /* p-cut-date */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры doclslib-init-trn-doc" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value . /* --->>>--- */
    end.

    run doclslib-init-price-doc in this-procedure
      (input p-obj-type /* p-obj-type */
      ,input p-obj-code /* p-obj-code */
      ,input p-cut-date /* p-cut-date */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры doclslib-init-price-doc" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value . /* --->>>--- */
    end.

    run log-information in this-procedure
      (input p-obj-type                                           /* p-obj-type */
      ,input p-obj-code                                           /* p-obj-code */
      ,input "Удаление заданий на обработку складских документов" /* p-message  */
      ) .

    /* очищаем все отложенные задания типа arh по данному объекту */
    run clear-batch-arh in this-procedure
      (input p-obj-type /* p-obj-type */
      ,input p-obj-code /* p-obj-code */
      ,input today      /* p-cut-date */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры clear-batch-arh" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value . /* --->>>--- */
    end.


    run doclslib-clear-bydate-doc-list in this-procedure
      (input p-cut-date /* p-fact-date */
      ) .

    /* выводим документы, по которым будет вести расчет в текстовый файл */
    run doclslib-export-doc-list in this-procedure
      (input p-obj-type                                   /* p-obj-type      */
      ,input p-obj-code                                   /* p-obj-code      */
      ,input v-list-file-name                             /* p-log-file-name */
      ,input "Инициализация складского архива по товарам" /* p-description   */
      ) .

    define variable v-total-ind as integer   no-undo .

    run log-information in this-procedure
      (input p-obj-type       /* p-obj-type */
      ,input p-obj-code       /* p-obj-code */
      ,input "Очистка архива" /* p-message  */
      ) .

    run clear-db in this-procedure
      (input p-obj-type /* p-obj-type */
      ,input p-obj-code /* p-obj-code */
      ) .

    /* записываем дату, с которой в системе */
    /* будет рассчитанный складской архив по товарам */
    run clntattr-write in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input {&attr-arh-start-date}
      ,input string(p-cut-date, '99/99/9999')
      ) .

    run clntattr-write in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input {&attr-arh-detail-date}
      ,input string(p-cut-date, '99/99/9999')
      ) .

    run clear-tot in this-procedure .

    define buffer buf_gds-obj for ub.gds-obj .

    define variable v-host-code  as integer   no-undo .
    define variable v-base-rate  like ub.curr-accnt.exch-rate no-undo .
    define variable v-base-scale like ub.curr-accnt.exch-scale no-undo .
    define variable v-ind        as integer   no-undo .
    define variable v-cons-pay   as integer   no-undo .
    define variable v-cons-type  as character no-undo .

    { gbl/hostcode.i
      p-obj-type
      p-obj-code
      v-host-code
    }

    /* определяем код поставки - консигнация */
    { gbl/objatext.i
      p-obj-type
      p-obj-code
      "'cons-pay=request'"
      v-cons-pay
      v-cons-type
    }

    { gbl/baserate.i
      v-host-code
      v-archive-date
      v-base-rate
      v-base-scale
      no-error
    }
    /* курс может быть неопределенным */
    /* но это имеет значение, только если остаток по товару отличен от нуля */
    define variable v-base-rate-reason as character no-undo .
    assign
      v-base-rate-reason = return-value
    .

    form
      p-obj-type label "Объект" p-obj-code no-label skip
      v-ind      label "Обработано" skip
      v-total-err label "Ошибок" skip
      buf_gds-obj.artic label "Артикул" skip
      with frame a view-as dialog-box side-labels three-d
      title "Обработка товаров" .
    display
      p-obj-type p-obj-code
      with frame a .

    run log-information in this-procedure
      (input p-obj-type          /* p-obj-type */
      ,input p-obj-code          /* p-obj-code */
      ,input "Обработка товаров" /* p-message  */
      ) .

    for each buf_gds-obj no-lock
      where buf_gds-obj.obj-type = p-obj-type
        and buf_gds-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :

      assign
        v-ind = v-ind + 1
      .
      if v-ind mod 10 = 0
      then do:
        display
          v-ind skip
          buf_gds-obj.artic skip
          v-total-err skip
          with frame a .
      end.

      run process-gds-obj in this-procedure
        (input buf_gds-obj.obj-type   /* p-obj-type             */
        ,input buf_gds-obj.obj-code   /* p-obj-code             */
        ,input buf_gds-obj.artic      /* p-artic                */
        ,input buf_gds-obj.prod-type  /* p-prod-type            */
        ,input buf_gds-obj.prod-code  /* p-prod-code            */
        ,input v-cons-pay             /* p-cons-pay             */
        ,input v-base-rate            /* p-base-rate            */
        ,input v-base-scale           /* p-base-scale           */
        ,input v-base-rate-reason     /* p-base-rate-reason     */
        ,input v-archive-date         /* p-archive-date         */
        ,input v-shift-on             /* p-shift-on             */
        ,input v-shift-date           /* p-shift-date           */
        ,input v-shift-num            /* p-shift-num            */
        ,input v-day-end-fact-order   /* p-day-end-fact-order   */
        ,input v-shift-end-fact-order /* p-shift-end-fact-order */
        ) .
    end.

    run store-tot in this-procedure
      (input v-archive-date         /* p-archive-date         */
      ,input v-shift-on             /* p-shift-on             */
      ,input v-shift-date           /* p-shift-date           */
      ,input v-shift-num            /* p-shift-num            */
      ,input v-day-end-fact-order   /* p-day-end-fact-order   */
      ,input v-shift-end-fact-order /* p-shift-end-fact-order */
      ) .

    /* помечаем, что на объекте произведен первоначальный расчет остатков */
    run clntattr-delete in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input {&attr-arh-del}
      ,output v-attr-delete
      ) .

    if v-total-err <> 0
    then do:
      run log-information in this-procedure
        (input p-obj-type                                                                                                           /* p-obj-type */
        ,input p-obj-code                                                                                                           /* p-obj-code */
        ,input "### ВНИМАНИЕ !!! ### Были обнаружены ошибки в товарных количествах. Всего ошибочных товаров " + string(v-total-err) /* p-message  */
        ) .
    end.

    run log-information in this-procedure
      (input p-obj-type                                                     /* p-obj-type */
      ,input p-obj-code                                                     /* p-obj-code */
      ,input "Инициализация завершена. Обработано товаров " + string(v-ind) /* p-message  */
      ) .

    run utl/arhiscr.p
      (input  p-obj-type                   /* p-obj-type              */
      ,input  p-obj-code                   /* p-obj-code              */
      ,input  {&btpr-type-arh}             /* p-archive-type          */
      ,input  {&archive-history-init-stop} /* p-action-type           */
      ,input  ""                           /* p-file-name             */
      ,input  ""                           /* p-file-md5              */
      ,input  0                            /* p-file-invalid-chip-num */
      ,input  ""                           /* p-source-type           */
      ,input  ""                           /* p-source-ref            */
      ,input  p-cut-date                   /* p-source-date           */
      ,output v-create-chip-num            /* p-create-chip-num       */
      ) .
  end.

end procedure. /* process-object */


procedure process-gds-obj :

  define input  parameter p-obj-type             like ub.gds-obj.obj-type  no-undo .
  define input  parameter p-obj-code             like ub.gds-obj.obj-code  no-undo .
  define input  parameter p-artic                like ub.gds-obj.artic     no-undo .
  define input  parameter p-prod-type            like ub.gds-obj.prod-type no-undo .
  define input  parameter p-prod-code            like ub.gds-obj.prod-code no-undo .
  define input  parameter p-cons-pay             as integer   no-undo .
  define input  parameter p-base-rate            like ub.curr-accnt.exch-rate no-undo .
  define input  parameter p-base-scale           like ub.curr-accnt.exch-scale no-undo .
  define input  parameter p-base-rate-reason     as character no-undo .
  define input  parameter p-archive-date         as date      no-undo .
  define input  parameter p-shift-on             as logical   no-undo .
  define input  parameter p-shift-date           as date      no-undo .
  define input  parameter p-shift-num            as integer   no-undo .
  define input  parameter p-day-end-fact-order   as decimal   no-undo .
  define input  parameter p-shift-end-fact-order as decimal   no-undo .

  define buffer buf_goods              for ub.goods .
  define buffer buf_temp-parts         for temp-parts .
  define buffer buf_temp-prt-obj       for temp-prt-obj .
  define buffer buf_tt-clcparts        for tt-clcparts .
  define buffer buf_tt-allsum-line     for tt-allsum-line .
  define buffer buf_temp-stk-line      for temp-stk-line .
  define buffer buf_temp-stk-tot       for temp-stk-tot .

  define variable v-total-parts-fact-qnty   as decimal   no-undo .

  assign
    v-total-parts-fact-qnty   = 0
  .

  do
  on error undo, return error return-value
  :
    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при поиске товара" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if buf_goods.gds-type = {&gds-goods}
    then do:
      /* обрабатываем остаток по товару */

      run clear-line in this-procedure .


      define var parrecid-prl as recid no-undo .
      { str/out-vatp.i def " " " " " " -prl " " }

      define variable v-total-crsa-fact-qnty as decimal   no-undo .
      define variable v-cur-base             as decimal   no-undo .
      define variable v-cur-VAT-base         as decimal   no-undo .
      define variable v-cur-SLT-base         as decimal   no-undo .
      define variable v-cur-road-tax-base    as decimal   no-undo .
      define variable v-cur-excise-base      as decimal   no-undo .

      /* определяем количество товара по признакам */
      /* на дату инициализации складского архива */
      run prdoclib-init-prt-obj-by-factord in this-procedure
        (input p-obj-type           /* p-obj-type           */
        ,input p-obj-code           /* p-obj-code           */
        ,input p-artic              /* p-artic              */
        ,input p-prod-type          /* p-prod-type          */
        ,input p-prod-code          /* p-prod-code          */
        ,input p-day-end-fact-order /* p-fact-order         */
        ,input false                /* p-include-fact-order */
        ) .

      /* определяем сумму в продажных ценах */
      run prdoclib-calc-temp-fact-sale in this-procedure
        (input  p-obj-type             /* p-obj-type           */
        ,input  p-obj-code             /* p-obj-code           */
        ,input  buf_goods.gds-code     /* p-gds-code           */
        ,input  p-day-end-fact-order   /* p-day-end-fact-order */
        ,input  v-curr-r-b             /* p-curr-r-b           */
        ,output v-total-crsa-fact-qnty /* p-fact-qnty          */
        ,output v-cur-base             /* p-cur-base           */
        ,output v-cur-VAT-base         /* p-cur-VAT-base       */
        ,output v-cur-SLT-base         /* p-cur-SLT-base       */
        ,output v-cur-road-tax-base    /* p-cur-road-tax-base  */
        ,output v-cur-excise-base      /* p-cur-excise-base    */
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры" skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      /* получаем количество по партиям на необходимую дату */
      run partslib-init-temp-parts-by-factord in this-procedure
        (input p-obj-type           /* p-obj-type           */
        ,input p-obj-code           /* p-obj-code           */
        ,input p-artic              /* p-artic              */
        ,input p-prod-type          /* p-prod-type          */
        ,input p-prod-code          /* p-prod-code          */
        ,input p-day-end-fact-order /* p-fact-order         */
        ,input false                /* p-include-fact-order */
        ) .

      /* подготавливаем данные для расчета сумм */
      for each buf_tt-clcparts
      on error undo, return error return-value
      :
        delete buf_tt-clcparts .
      end.

      define variable v-rest-exist as logical   no-undo .
      define variable v-exist-qnty as integer   no-undo .

      assign
        v-rest-exist = false
        v-exist-qnty = 0
      .

      for each buf_temp-parts
      on error undo, return error return-value
      :
        create buf_tt-clcparts .
        buffer-copy buf_temp-parts to buf_tt-clcparts .
        if buf_temp-parts.qnty <> 0
        then do:
          assign
            v-rest-exist = true
            v-exist-qnty = v-exist-qnty + buf_temp-parts.qnty
          .
        end.
      end.

      define variable v-crsa-vat-pc    as decimal   no-undo .
      define variable v-crsa-slt-pc    as decimal   no-undo .

      /* определяем налоги для разбивки по НДС и НП */
      define variable v-b-code     as integer   no-undo .
      define variable v-doc-num    as character no-undo .
      define variable v-price-sale as decimal   no-undo .
      define variable v-road-tax   as decimal   no-undo .
      define variable v-excise     as decimal   no-undo .

      { gbl/gdsbcode.i
        buf_goods.gds-code
        ?
        v-b-code
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при поиске первичного бар-кода товара" skip
          "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      { gbl/bcprcex.i
        p-obj-type
        p-obj-code
        v-b-code
        0
        p-day-end-fact-order
        v-doc-num
        v-price-sale
        v-road-tax
        v-excise
        v-crsa-vat-pc
        v-crsa-slt-pc
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при поиске цены товара" skip
          "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
          "Бар-код" v-b-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if v-doc-num = ?
      then do:
        /* если переоценка не задана, считаем налоги равными нулю */
        assign
          v-crsa-vat-pc     = 0
          v-crsa-slt-pc     = 0
        .
      end.

      if v-crsa-vat-pc = ?
      then do:
        if v-rest-exist = true
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Не задан налог товара на дату" skip
            "Налог" "НДС" skip
            "Код товара" buf_goods.gds-code skip
            "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
            "Переоценка" v-doc-num skip
            "Объект" p-obj-type p-obj-code skip
            "Тип налога" {&vat-tax-code} skip
            "Дата" string(p-archive-date, '99/99/9999':u) skip
            "Количество" v-exist-qnty skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        else do:
          assign
            v-crsa-vat-pc = 0
          .
        end.
      end.

      if v-crsa-slt-pc = ?
      then do:
        if v-rest-exist = true
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Не задан налог товара на дату" skip
            "Налог" "НП" skip
            "Код товара" buf_goods.gds-code skip
            "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
            "Переоценка" v-doc-num skip
            "Объект" p-obj-type p-obj-code skip
            "Тип налога" {&slt-tax-code} skip
            "Дата" string(p-archive-date, '99/99/9999':u) skip
            "Количество" v-exist-qnty skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        else do:
          assign
            v-crsa-slt-pc = 0
          .
        end.
      end.

      define variable v-host-code  as integer   no-undo .
      { gbl/hostcode.i
        p-obj-type
        p-obj-code
        v-host-code
      }
      define variable v-cons-vat-pc as decimal   no-undo .
      { gbl/consvtpc.i
        v-host-code
        v-cons-vat-pc
      }
      if v-cons-vat-pc = ?
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не задан налог на услуги по продаже консигнационного товара" skip
          "Фирма" v-host-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      define variable v-cur-price-sale     as decimal   no-undo .
      define variable v-cur-price-road-tax as decimal   no-undo .
      define variable v-cur-price-excise   as decimal   no-undo .

      if v-total-crsa-fact-qnty <> 0
      then do:
        assign
          v-cur-price-sale     = v-cur-base / v-total-crsa-fact-qnty
          v-cur-price-road-tax = v-cur-road-tax-base / v-total-crsa-fact-qnty
          v-cur-price-excise   = v-cur-excise-base / v-total-crsa-fact-qnty
        .
      end.
      else do:
        assign
          v-cur-price-sale     = 0
          v-cur-price-road-tax = 0
          v-cur-price-excise   = 0
        .
      end.

      if  v-cur-base          = 0
      and v-cur-VAT-base      = 0
      and v-cur-SLT-base      = 0
      and v-cur-road-tax-base = 0
      and v-cur-excise-base   = 0
      then do:
        if p-base-rate = ?
        or p-base-scale = ?
        then do:
          assign
            p-base-rate  = 0
            p-base-scale = 0
          .
        end.
      end.

      if p-base-rate = ?
      or p-base-scale = ?
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Курс имеет неопределенное значение" skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "Причина" p-base-rate-reason skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      /* рассчитываем суммы */
      run clcprtsl_calc-ttable in this-procedure
        (input false                /* paris-doc         */
        ,input true                 /* paris-cur         */
        ,input ?                    /* parroad-tax       */
        ,input ?                    /* parexcise         */
        ,input ?                    /* parvat-pc         */
        ,input ?                    /* parcons-vat-pc    */
        ,input ?                    /* parslt-pc         */
        ,input p-base-rate          /* parbase-rate      */
        ,input p-base-scale         /* parbase-scale     */
        ,input v-curr-r-b           /* parr-b            */
        ,input v-cur-price-sale     /* parcur-base       */
        ,input v-cur-price-road-tax /* parcur-road-tax   */
        ,input v-cur-price-excise   /* parcur-excise     */
        ,input v-crsa-vat-pc             /* parcur-vat-pc     */
        ,input v-cons-vat-pc        /* parcurcons-vat-pc */
        ,input v-crsa-slt-pc             /* parcurslt-pc      */
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при расчете учетных цен по партии"
          view-as alert-box error .
        undo, return error return-value .
      end.

      find first buf_tt-allsum-line
        where buf_tt-allsum-line.sum-type = {&sum-general-sign}
        no-error .
      if available buf_tt-allsum-line
      then do:
        /* надо брать суммы с обратным знаком */
        assign
          v-fact-qnty      = - buf_tt-allsum-line.fact-qnty
          v-sum-base       = - buf_tt-allsum-line.sum-dsc-base-cur
          v-sum-rubl       = - buf_tt-allsum-line.sum-dsc-rubl-cur
          v-vat-base       = - buf_tt-allsum-line.vat-base-cur
          v-vat-rubl       = - buf_tt-allsum-line.vat-rubl-cur
          v-slt-base       = - buf_tt-allsum-line.slt-base-cur
          v-slt-rubl       = - buf_tt-allsum-line.slt-rubl-cur
          v-road-tax-base  = - buf_tt-allsum-line.road-tax-base-cur
          v-road-tax-rubl  = - buf_tt-allsum-line.road-tax-rubl-cur
          v-excise-base    = - buf_tt-allsum-line.excise-base-cur
          v-excise-rubl    = - buf_tt-allsum-line.excise-rubl-cur
          v-transport-base = 0
          v-transport-rubl = 0
          v-other-base     = - buf_tt-allsum-line.dsc-base-cur
          v-other-rubl     = - buf_tt-allsum-line.dsc-rubl-cur
        .
      end.
      else do:
        assign
          v-fact-qnty      = 0
          v-sum-base       = 0
          v-sum-rubl       = 0
          v-vat-base       = 0
          v-vat-rubl       = 0
          v-slt-base       = 0
          v-slt-rubl       = 0
          v-road-tax-base  = 0
          v-road-tax-rubl  = 0
          v-excise-base    = 0
          v-excise-rubl    = 0
          v-transport-base = 0
          v-transport-rubl = 0
          v-other-base     = 0
          v-other-rubl     = 0
        .
      end.

      /* проверяем, что не получили неопределенных значений */
      if
      &scop fl1  v-
      &scop fls1
      &scop fl2  = ?
      &scop fl3  or
      {&price-single-list}
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "При расчете переоценки были получены неопределенные значения" skip
          "Расчет складского архива невозможен" skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          &scop fp1   "v-
          &scop fps1  "
          &scop fp2   v-
          &scop fps2
          &scop fp3
          &scop fp4   skip
          {&price-pair-list}
          view-as alert-box error .
        undo, return error return-value .
      end.

      find first buf_temp-stk-line
        where buf_temp-stk-line.obj-type   = p-obj-type
          and buf_temp-stk-line.obj-code   = p-obj-code
          and buf_temp-stk-line.artic      = p-artic
          and buf_temp-stk-line.prod-type  = p-prod-type
          and buf_temp-stk-line.prod-code  = p-prod-code
          and buf_temp-stk-line.fact-order = p-day-end-fact-order
          and buf_temp-stk-line.sum-type   = {&arh-crsa}
          and buf_temp-stk-line.cat-id     = {&root-cat-id}
        no-error .
      if not available buf_temp-stk-line
      then do:
        create buf_temp-stk-line .

        assign
          buf_temp-stk-line.obj-type   = p-obj-type
          buf_temp-stk-line.obj-code   = p-obj-code
          buf_temp-stk-line.artic      = p-artic
          buf_temp-stk-line.prod-type  = p-prod-type
          buf_temp-stk-line.prod-code  = p-prod-code
          buf_temp-stk-line.fact-order = p-day-end-fact-order
          buf_temp-stk-line.sum-type   = {&arh-crsa}
          buf_temp-stk-line.cat-id     = {&root-cat-id}
        .
        assign
          buf_temp-stk-line.fact-date    = p-archive-date
          buf_temp-stk-line.shift-date   = ?
          buf_temp-stk-line.shift-num    = 0
        .
      end.

      assign
        &scop FT1    buf_temp-stk-line.new-
        &scop FTs1
        &scop FT2    = buf_temp-stk-line.new-
        &scop FTs2
        &scop FT3    + v-
        &scop FTs3
        &scop FT4
        &scop FT5
        {&price-trio-list}
      .

      define variable ind-ext    as integer no-undo .
      define variable v-cat-id   as character no-undo extent 4 .
      define variable v-sum-type as character no-undo extent 4 .

      assign
        v-sum-type[1] = {&arh-crsa}
        v-cat-id[1]   = {&root-cat-id}
        v-sum-type[2] = {&arh-crsa} + {&arh-VAT}
        v-cat-id[2]   = trim(string(v-crsa-vat-pc, ">99")) + "," + {&single-cat-id}
        v-sum-type[3] = {&arh-crsa} + {&arh-SLT}
        v-cat-id[3]   = {&single-cat-id} + "," + trim(string(v-crsa-slt-pc, ">99"))
        v-sum-type[4] = {&arh-crsa} + {&arh-VATSLT}
        v-cat-id[4]   = trim(string(v-crsa-vat-pc, ">99")) + "," + trim(string(v-crsa-slt-pc, ">99"))
      .

      do ind-ext = 1 to 4
      :
        find first buf_temp-stk-tot
          where buf_temp-stk-tot.obj-type   = p-obj-type
            and buf_temp-stk-tot.obj-code   = p-obj-code
            and buf_temp-stk-tot.fact-order = p-day-end-fact-order
            and buf_temp-stk-tot.sum-type   = v-sum-type[ind-ext]
            and buf_temp-stk-tot.cat-id     = v-cat-id[ind-ext]
          no-error .
        if not available buf_temp-stk-tot
        then do:
          create buf_temp-stk-tot .
          assign
            buf_temp-stk-tot.obj-type   = p-obj-type
            buf_temp-stk-tot.obj-code   = p-obj-code
            buf_temp-stk-tot.fact-order = p-day-end-fact-order
            buf_temp-stk-tot.sum-type   = v-sum-type[ind-ext]
            buf_temp-stk-tot.cat-id     = v-cat-id[ind-ext]
          .
          assign
            buf_temp-stk-tot.fact-date  = p-archive-date
            buf_temp-stk-tot.shift-date = ?
            buf_temp-stk-tot.shift-num  = 0
          .
        end.
        assign
          &scop FT1    buf_temp-stk-tot.new-
          &scop FTs1
          &scop FT2    = buf_temp-stk-tot.new-
          &scop FTs2
          &scop FT3    + v-
          &scop FTs3
          &scop FT4
          &scop FT5
          {&price-trio-list}
        .
      end.

      /* вычисляем остаток в учетных ценах */
      /* с разбивками по НДС, НП */
      /* с разбивками по виду поставки */
      /* идем по всем партиям свободной зоны */
      /* во временной таблице уже находятся только те партии, которые нужны */
      for each buf_temp-parts
      on error undo, return error return-value
      :
        for each buf_tt-clcparts
        on error undo, return error return-value
        :
          delete buf_tt-clcparts .
        end.

        create buf_tt-clcparts .
        buffer-copy buf_temp-parts to buf_tt-clcparts .

        run clcprtsl_calc-ttable in this-procedure
          (input false /* paris-doc         */
          ,input false /* paris-cur         */
          ,input ?     /* parroad-tax       */
          ,input ?     /* parexcise         */
          ,input ?     /* parvat-pc         */
          ,input ?     /* parcons-vat-pc    */
          ,input ?     /* parslt-pc         */
          ,input ?     /* parbase-rate      */
          ,input ?     /* parbase-scale     */
          ,input ?     /* parr-b            */
          ,input ?     /* parcur-base       */
          ,input ?     /* parcur-road-tax   */
          ,input ?     /* parcur-excise     */
          ,input ?     /* parcur-vat-pc     */
          ,input ?     /* parcurcons-vat-pc */
          ,input ?     /* parcurslt-pc      */
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры clcprtsl_calc-ttable" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.

        assign
          v-total-parts-fact-qnty = v-total-parts-fact-qnty + buf_temp-parts.fact-qnty
        .

        define variable v-cost-vat-pc as decimal   no-undo .
        define variable v-cost-slt-pc as decimal   no-undo .
        assign
          v-cost-vat-pc         = buf_temp-parts.vat-pc
          v-cost-slt-pc         = buf_temp-parts.slt-pc
        .

        find first buf_tt-allsum-line
          where buf_tt-allsum-line.sum-type = {&sum-general-sign}
          no-error .
        if available buf_tt-allsum-line
        then do:
          /* надо брать суммы с обратным знаком */
          assign
            v-fact-qnty      = - buf_tt-allsum-line.fact-qnty
            v-sum-base       = - buf_tt-allsum-line.sum-dsc-base-acc
            v-sum-rubl       = - buf_tt-allsum-line.sum-dsc-rubl-acc
            v-vat-base       = - buf_tt-allsum-line.vat-base-acc
            v-vat-rubl       = - buf_tt-allsum-line.vat-rubl-acc
            v-slt-base       = - buf_tt-allsum-line.slt-base-acc
            v-slt-rubl       = - buf_tt-allsum-line.slt-rubl-acc
            v-road-tax-base  = - buf_tt-allsum-line.road-tax-base-acc
            v-road-tax-rubl  = - buf_tt-allsum-line.road-tax-rubl-acc
            v-excise-base    = - buf_tt-allsum-line.excise-base-acc
            v-excise-rubl    = - buf_tt-allsum-line.excise-rubl-acc
            v-transport-base = - buf_tt-allsum-line.transport-base-acc
            v-transport-rubl = - buf_tt-allsum-line.transport-rubl-acc
            v-other-base     = - buf_tt-allsum-line.other-base-acc
            v-other-rubl     = - buf_tt-allsum-line.other-rubl-acc
          .
        end.
        else do:
          assign
            v-fact-qnty      = 0
            v-sum-base       = 0
            v-sum-rubl       = 0
            v-vat-base       = 0
            v-vat-rubl       = 0
            v-slt-base       = 0
            v-slt-rubl       = 0
            v-road-tax-base  = 0
            v-road-tax-rubl  = 0
            v-excise-base    = 0
            v-excise-rubl    = 0
            v-transport-base = 0
            v-transport-rubl = 0
            v-other-base     = 0
            v-other-rubl     = 0
          .
        end.

        if
        &scop fl1  v-
        &scop fls1
        &scop fl2  = ?
        &scop fl3  or
        {&price-single-list}
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Программа clcprtsl_calc-ttable вернула неопределенные значения" skip
            "Расчет складского архива невозможен" skip
            "Объект" p-obj-type p-obj-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            "Тип суммы" {&sum-general-sign} skip
            &scop fp1   "v-
            &scop fps1  "
            &scop fp2   v-
            &scop fps2
            &scop fp3
            &scop fp4   skip
            {&price-pair-list}
            view-as alert-box error .
          undo, return error return-value .
        end.

        /* запись информации об учетной цене для товара */

        assign
          v-sum-type[1] = {&arh-cost}
          v-cat-id[1]   = {&single-cat-id} + "," + {&single-cat-id}
          v-sum-type[2] = {&arh-cost} + {&arh-VAT}
          v-cat-id[2]   = trim(string(v-cost-vat-pc, ">99")) + "," + {&single-cat-id}
          v-sum-type[3] = {&arh-cost} + {&arh-SLT}
          v-cat-id[3]   = {&single-cat-id} + "," + trim(string(v-cost-slt-pc, ">99"))
          v-sum-type[4] = {&arh-cost} + {&arh-VATSLT}
          v-cat-id[4]   = trim(string(v-cost-vat-pc, ">99")) + "," + trim(string(v-cost-slt-pc, ">99"))
        .
        do ind-ext = 1 to 4
        :
          find first buf_temp-stk-line
            where buf_temp-stk-line.obj-type   = p-obj-type
              and buf_temp-stk-line.obj-code   = p-obj-code
              and buf_temp-stk-line.artic      = p-artic
              and buf_temp-stk-line.prod-type  = p-prod-type
              and buf_temp-stk-line.prod-code  = p-prod-code
              and buf_temp-stk-line.fact-order = p-day-end-fact-order
              and buf_temp-stk-line.sum-type   = v-sum-type[ind-ext]
              and buf_temp-stk-line.cat-id     = v-cat-id[ind-ext]
            no-error .
          if not available buf_temp-stk-line
          then do:
            create buf_temp-stk-line .
            assign
              buf_temp-stk-line.obj-type   = p-obj-type
              buf_temp-stk-line.obj-code   = p-obj-code
              buf_temp-stk-line.artic      = p-artic
              buf_temp-stk-line.prod-type  = p-prod-type
              buf_temp-stk-line.prod-code  = p-prod-code
              buf_temp-stk-line.fact-order = p-day-end-fact-order
              buf_temp-stk-line.sum-type   = v-sum-type[ind-ext]
              buf_temp-stk-line.cat-id     = v-cat-id[ind-ext]
            .
            assign
              buf_temp-stk-line.fact-date    = p-archive-date
              buf_temp-stk-line.shift-date   = ?
              buf_temp-stk-line.shift-num    = 0
            .
          end.

          assign
            &scop FT1    buf_temp-stk-line.new-
            &scop FTs1
            &scop FT2    = buf_temp-stk-line.new-
            &scop FTs2
            &scop FT3    + v-
            &scop FTs3
            &scop FT4
            &scop FT5
            {&price-trio-list}
          .

          find first buf_temp-stk-tot
            where buf_temp-stk-tot.obj-type   = p-obj-type
              and buf_temp-stk-tot.obj-code   = p-obj-code
              and buf_temp-stk-tot.fact-order = p-day-end-fact-order
              and buf_temp-stk-tot.sum-type   = v-sum-type[ind-ext]
              and buf_temp-stk-tot.cat-id     = v-cat-id[ind-ext]
            no-error .
          if not available buf_temp-stk-tot
          then do:
            create buf_temp-stk-tot .
            assign
              buf_temp-stk-tot.obj-type   = p-obj-type
              buf_temp-stk-tot.obj-code   = p-obj-code
              buf_temp-stk-tot.fact-order = p-day-end-fact-order
              buf_temp-stk-tot.sum-type   = v-sum-type[ind-ext]
              buf_temp-stk-tot.cat-id     = v-cat-id[ind-ext]
            .
            assign
              buf_temp-stk-tot.fact-date  = p-archive-date
              buf_temp-stk-tot.shift-date = ?
              buf_temp-stk-tot.shift-num  = 0
            .
          end.
          assign
            &scop FT1    buf_temp-stk-tot.new-
            &scop FTs1
            &scop FT2    = buf_temp-stk-tot.new-
            &scop FTs2
            &scop FT3    + v-
            &scop FTs3
            &scop FT4
            &scop FT5
            {&price-trio-list}
          .
        end.
      end.

      run store-line in this-procedure
        (input p-archive-date
        ,input p-shift-on
        ,input p-shift-date
        ,input p-shift-num
        ,input p-day-end-fact-order
        ,input p-shift-end-fact-order
        ) .

      if v-total-crsa-fact-qnty <> v-total-parts-fact-qnty
      then do:
        assign
          v-total-err = v-total-err + 1
        .
        output stream slog to value(v-error-file-name) append .
        export stream slog '###':U 'error01':U string(today, '99/99/9999':U) string(time, 'HH:MM:SS':U) .
        export stream slog "Общее количество по признакам не совпадает с общим количеством по партиям" .
        export stream slog "Объект" p-obj-type p-obj-code .
        export stream slog "Код товара" buf_goods.gds-code .
        export stream slog "Артикул" p-artic p-prod-type p-prod-code .
        export stream slog "Общее количество по признакам" v-total-crsa-fact-qnty .
        export stream slog "Общее количество по партиям" v-total-parts-fact-qnty .
        for each buf_temp-parts
        on error undo, return error return-value
        :
          export stream slog "parts"
            buf_temp-parts.in-code
            buf_temp-parts.part-code
            buf_temp-parts.qnty
            .
        end.

        output stream slog close .
      end.
    end.
  end.

end procedure. /* process-gds-obj */



procedure store-line :

  define input  parameter p-archive-date         as date      no-undo .
  define input  parameter p-shift-on             as logical   no-undo .
  define input  parameter p-shift-date           as date      no-undo .
  define input  parameter p-shift-num            as integer   no-undo .
  define input  parameter p-day-end-fact-order   as decimal   no-undo .
  define input  parameter p-shift-end-fact-order as decimal   no-undo .

  define buffer buf_temp-stk-line      for temp-stk-line .
  define buffer buf_stk-line           for ub.stk-line .

  do
  on error undo, return error return-value
  :

    define variable l-need-create-record as logical   no-undo .

    for each buf_temp-stk-line
    on error undo, return error return-value
    :
      if
      &scop fp1   buf_temp-stk-line.
      &scop fps1
      &scop fp2   <> buf_temp-stk-line.new-
      &scop fps2
      &scop fp3
      &scop fp4   or
      {&price-pair-list}
      or ( buf_temp-stk-line.cat-id = {&root-cat-id} )
      then do:

        assign
          l-need-create-record =
                                  &scop fl1  buf_temp-stk-line.new-
                                  &scop fls1
                                  &scop fl2  <> 0
                                  &scop fl3  or
                                  {&price-single-list}
                              or ( buf_temp-stk-line.cat-id = {&root-cat-id} )
        .

        find first buf_stk-line exclusive-lock
          where buf_stk-line.obj-type   = buf_temp-stk-line.obj-type
            and buf_stk-line.obj-code   = buf_temp-stk-line.obj-code
            and buf_stk-line.artic      = buf_temp-stk-line.artic
            and buf_stk-line.prod-type  = buf_temp-stk-line.prod-type
            and buf_stk-line.prod-code  = buf_temp-stk-line.prod-code
            and buf_stk-line.fact-order = buf_temp-stk-line.fact-order
            and buf_stk-line.sum-type   = buf_temp-stk-line.sum-type
            and buf_stk-line.cat-id     = buf_temp-stk-line.cat-id
          no-error .
        if l-need-create-record
        then do:
          if not available buf_stk-line
          then do:
            create buf_stk-line .
          end.
          buffer-copy buf_temp-stk-line to buf_stk-line
          assign
            &scop fp1   buf_stk-line.
            &scop fps1
            &scop fp2   = buf_temp-stk-line.new-
            &scop fps2
            &scop fp3
            &scop fp4
            {&price-pair-list}
          .
        end.
        else do:
          if available buf_stk-line
          then do:
            delete buf_stk-line .
          end.
        end.
      end. /*если было изменение*/
    end. /*each tt-stk-line*/


    if p-shift-on = true
    then do:
      for each buf_temp-stk-line
      on error undo, return error return-value
      :
        if
        &scop fp1   buf_temp-stk-line.
        &scop fps1
        &scop fp2   <> buf_temp-stk-line.new-
        &scop fps2
        &scop fp3
        &scop fp4   or
        {&price-pair-list}
        or ( buf_temp-stk-line.cat-id = {&root-cat-id} )
        then do:

          assign
            l-need-create-record =
                                    &scop fl1  buf_temp-stk-line.new-
                                    &scop fls1
                                    &scop fl2  <> 0
                                    &scop fl3  or
                                    {&price-single-list}
                                or ( buf_temp-stk-line.cat-id = {&root-cat-id} )
          .

          find first buf_stk-line exclusive-lock
            where buf_stk-line.obj-type   = buf_temp-stk-line.obj-type
              and buf_stk-line.obj-code   = buf_temp-stk-line.obj-code
              and buf_stk-line.artic      = buf_temp-stk-line.artic
              and buf_stk-line.prod-type  = buf_temp-stk-line.prod-type
              and buf_stk-line.prod-code  = buf_temp-stk-line.prod-code
              and buf_stk-line.fact-order = p-shift-end-fact-order
              and buf_stk-line.sum-type   = buf_temp-stk-line.sum-type
              and buf_stk-line.cat-id     = buf_temp-stk-line.cat-id
            no-error .
          if l-need-create-record
          then do:
            if not available buf_stk-line
            then do:
              create buf_stk-line .
            end.
            buffer-copy buf_temp-stk-line to buf_stk-line
            assign
              buf_stk-line.fact-order = p-shift-end-fact-order
              buf_stk-line.shift-date = p-shift-date
              buf_stk-line.shift-num  = p-shift-num
              &scop fp1   buf_stk-line.
              &scop fps1
              &scop fp2   = buf_temp-stk-line.new-
              &scop fps2
              &scop fp3
              &scop fp4
              {&price-pair-list}
            .
          end.
          else do:
            if available buf_stk-line
            then do:
              delete buf_stk-line .
            end.
          end.
        end. /*если было изменение*/
      end. /*each tt-stk-line*/
    end.
  end.

end procedure. /* store-line */


procedure store-tot :

  define input  parameter p-archive-date         as date      no-undo .
  define input  parameter p-shift-on             as logical   no-undo .
  define input  parameter p-shift-date           as date      no-undo .
  define input  parameter p-shift-num            as integer   no-undo .
  define input  parameter p-day-end-fact-order   as decimal   no-undo .
  define input  parameter p-shift-end-fact-order as decimal   no-undo .

  define buffer buf_temp-stk-tot      for temp-stk-tot .
  define buffer buf_stk-tot           for ub.stk-tot .

  do
  on error undo, return error return-value
  :

    define variable l-need-create-record as logical   no-undo .

    for each buf_temp-stk-tot
    on error undo, return error return-value
    :
      if
      &scop fp1   buf_temp-stk-tot.
      &scop fps1
      &scop fp2   <> buf_temp-stk-tot.new-
      &scop fps2
      &scop fp3
      &scop fp4   or
      {&price-pair-list}
      or ( buf_temp-stk-tot.cat-id = {&root-cat-id} )
      then do:

        assign
          l-need-create-record =
                                  &scop fl1  buf_temp-stk-tot.new-
                                  &scop fls1
                                  &scop fl2  <> 0
                                  &scop fl3  or
                                  {&price-single-list}
                              or ( buf_temp-stk-tot.cat-id = {&root-cat-id} )
        .

        find first buf_stk-tot exclusive-lock
          where buf_stk-tot.obj-type   = buf_temp-stk-tot.obj-type
            and buf_stk-tot.obj-code   = buf_temp-stk-tot.obj-code
            and buf_stk-tot.fact-order = buf_temp-stk-tot.fact-order
            and buf_stk-tot.sum-type   = buf_temp-stk-tot.sum-type
            and buf_stk-tot.cat-id     = buf_temp-stk-tot.cat-id
          no-error .
        if l-need-create-record
        then do:
          if not available buf_stk-tot
          then do:
            create buf_stk-tot .
          end.
          buffer-copy buf_temp-stk-tot to buf_stk-tot
          assign
            &scop fp1   buf_stk-tot.
            &scop fps1
            &scop fp2   = buf_temp-stk-tot.new-
            &scop fps2
            &scop fp3
            &scop fp4
            {&price-pair-list}
          .
        end.
        else do:
          if available buf_stk-tot
          then do:
            delete buf_stk-tot .
          end.
        end.
      end. /*если было изменение*/
    end. /*each tt-stk-tot*/

    if p-shift-on
    then do:
      for each buf_temp-stk-tot
      on error undo, return error return-value
      :
        if
        &scop fp1   buf_temp-stk-tot.
        &scop fps1
        &scop fp2   <> buf_temp-stk-tot.new-
        &scop fps2
        &scop fp3
        &scop fp4   or
        {&price-pair-list}
        or ( buf_temp-stk-tot.cat-id = {&root-cat-id} )
        then do:

          assign
            l-need-create-record =
                                    &scop fl1  buf_temp-stk-tot.new-
                                    &scop fls1
                                    &scop fl2  <> 0
                                    &scop fl3  or
                                    {&price-single-list}
                                or ( buf_temp-stk-tot.cat-id = {&root-cat-id} )
          .

          find first buf_stk-tot exclusive-lock
            where buf_stk-tot.obj-type   = buf_temp-stk-tot.obj-type
              and buf_stk-tot.obj-code   = buf_temp-stk-tot.obj-code
              and buf_stk-tot.fact-order = p-shift-end-fact-order
              and buf_stk-tot.sum-type   = buf_temp-stk-tot.sum-type
              and buf_stk-tot.cat-id     = buf_temp-stk-tot.cat-id
            no-error .
          if l-need-create-record
          then do:
            if not available buf_stk-tot
            then do:
              create buf_stk-tot .
            end.
            buffer-copy buf_temp-stk-tot to buf_stk-tot
            assign
              buf_stk-tot.fact-order = p-shift-end-fact-order
              buf_stk-tot.shift-date = p-shift-date
              buf_stk-tot.shift-num  = p-shift-num
              &scop fp1   buf_stk-tot.
              &scop fps1
              &scop fp2   = buf_temp-stk-tot.new-
              &scop fps2
              &scop fp3
              &scop fp4
              {&price-pair-list}
            .
          end.
          else do:
            if available buf_stk-tot
            then do:
              delete buf_stk-tot .
            end.
          end.
        end. /*если было изменение*/
      end. /*each tt-stk-tot*/
    end.

  end.

end procedure. /* store-tot */


procedure clear-tot :

  define buffer buf_temp-stk-tot      for temp-stk-tot .

  do
  on error undo, return error return-value
  :
    for each buf_temp-stk-tot
    on error undo, return error return-value
    :
      delete buf_temp-stk-tot .
    end.
  end.

end procedure. /* clear-tot */

procedure clear-line :

  define buffer buf_temp-stk-line      for temp-stk-line .

  do
  on error undo, return error return-value
  :
    for each buf_temp-stk-line
    on error undo, return error return-value
    :
      delete buf_temp-stk-line .
    end.
  end.

end procedure. /* clear-line */


procedure clear-db :

  define buffer buf_stk-line      for ub.stk-line .
  define buffer buf_stk-tot       for ub.stk-tot .
  define buffer buf_ot-line       for ub.ot-line .
  define buffer buf_ot-tot        for ub.ot-tot .

  do
  on error undo, return error return-value
  :
    define input parameter p-obj-type like ub.gds-obj.obj-type no-undo .
    define input parameter p-obj-code like ub.gds-obj.obj-code no-undo .

    define variable v-ind as integer   no-undo .

    form
      p-obj-type p-obj-code skip
      v-ind skip
      with frame a view-as dialog-box side-labels three-d
      title "Удаление складского архива по товарам" .

    display
      p-obj-type p-obj-code
      v-ind
      with frame a .

    for each buf_stk-line exclusive-lock
      where buf_stk-line.obj-type = p-obj-type
        and buf_stk-line.obj-code = p-obj-code
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind mod 10 = 0
      then do:
        display
          v-ind skip
          with frame a .
      end.
      delete buf_stk-line .
    end.

    for each buf_stk-tot exclusive-lock
      where buf_stk-tot.obj-type = p-obj-type
        and buf_stk-tot.obj-code = p-obj-code
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind mod 10 = 0
      then do:
        display
          v-ind skip
          with frame a .
      end.
      delete buf_stk-tot .
    end.

    for each buf_ot-line exclusive-lock
      where buf_ot-line.obj-type = p-obj-type
        and buf_ot-line.obj-code = p-obj-code
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind mod 10 = 0
      then do:
        display
          v-ind skip
          with frame a .
      end.
      delete buf_ot-line .
    end.

    for each buf_ot-tot exclusive-lock
      where buf_ot-tot.obj-type = p-obj-type
        and buf_ot-tot.obj-code = p-obj-code
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind mod 10 = 0
      then do:
        display
          v-ind skip
          with frame a .
      end.
      delete buf_ot-tot .
    end.
  end.

end procedure. /* clear-db */


procedure log-clear :

  do
  on error undo, return error return-value
  :
    output stream slog to value(v-log-file-name) .
    output stream slog close .
  end.

end procedure. /* log-clear */


procedure log-information :

  do
  on error undo, return error return-value
  :
    define input parameter p-obj-type as character no-undo .
    define input parameter p-obj-code as integer   no-undo .
    define input parameter p-message  as character no-undo .

    output stream slog to value(v-log-file-name) append .
    export stream slog
      p-obj-type
      p-obj-code
      cur-time-string()
      p-message .
    output stream slog close .
  end.

end procedure. /* log-information */



procedure clear-batch-arh :

  define input parameter p-obj-type as character no-undo .
  define input parameter p-obj-code as integer   no-undo .
  define input parameter p-cut-date as date      no-undo .

  do
  on error undo, return error return-value
  :

    define buffer buf_batchprocess    for ub.batchprocess .
    define buffer delete_batchprocess for ub.batchprocess .
    define buffer buf_trn-doc         for ub.trn-doc .
    define buffer buf_price-doc       for ub.price-doc .


    for each buf_batchprocess no-lock where
             buf_batchprocess.bp_type  = {&btpr-type-prc}
    on error undo, return error return-value
    :
          find first buf_price-doc no-lock
            where buf_price-doc.doc-num = buf_batchprocess.charkey_one
            no-error .

          if not available buf_price-doc
          then do:
            do transaction
            on error undo, return error return-value
            :
              find delete_batchprocess exclusive-lock
                where recid(delete_batchprocess) = recid(buf_batchprocess)
                no-error .
              delete delete_batchprocess .
            end.
          end.
    end.


    for each buf_batchprocess no-lock
      where buf_batchprocess.bp_type = {&btpr-type-arh}
    on error undo, return error return-value
    :
      case buf_batchprocess.charkey_two :
        when {&table_trn-doc}
        then do:
          find first buf_trn-doc no-lock
            where buf_trn-doc.doc-code = buf_batchprocess.charkey_one
            no-error .
          if (available buf_trn-doc
             and buf_trn-doc.obj-type  = p-obj-type
             and buf_trn-doc.obj-code  = p-obj-code
             and buf_trn-doc.fact-date < p-cut-date
             )
          or not available buf_trn-doc
          then do:
            do transaction
            on error undo, return error return-value
            :
              /* документ был удален, помечаем запись как обработанную */
              find delete_batchprocess exclusive-lock
                where recid(delete_batchprocess) = recid(buf_batchprocess)
                no-error .
              delete delete_batchprocess .
            end.
          end.
        end.
        when {&table_price-doc}
        then do:
          find first buf_price-doc no-lock
            where buf_price-doc.doc-num = buf_batchprocess.charkey_one
            no-error .
          if (available buf_price-doc
             and buf_price-doc.obj-type = p-obj-type
             and buf_price-doc.obj-code = p-obj-code
             and buf_price-doc.fact-date < p-cut-date
             )
          or not available buf_price-doc
          then do:
            do transaction
            on error undo, return error return-value
            :
              find delete_batchprocess exclusive-lock
                where recid(delete_batchprocess) = recid(buf_batchprocess)
                no-error .
              delete delete_batchprocess .
            end.
          end.
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестный тип таблицы" skip
            "charkey_one"  buf_batchprocess.charkey_one skip
            "charkey_two"  buf_batchprocess.charkey_two skip
            view-as alert-box error .
          undo, return error return-value .
        end.

      end case .
    end.
  end.

end procedure. /* clear-batch-arh */

procedure invalidate-md5-signature :

  define input  parameter p-obj-type     as character no-undo .
  define input  parameter p-obj-code     as integer   no-undo .
  define input  parameter p-archive-type as character no-undo .
  define input  parameter p-chip-num     as integer   no-undo .

  define buffer buf_archive-history for ub.archive-history .

  do
  on error undo, return error return-value
  :
    for each buf_archive-history exclusive-lock
      where buf_archive-history.obj-type     = p-obj-type
        and buf_archive-history.obj-code     = p-obj-code
        and buf_archive-history.archive-type = p-archive-type
        and buf_archive-history.file-valid   = true
    on error undo, return error return-value
    :
      assign
        buf_archive-history.file-valid            = false
        buf_archive-history.file-invalid-chip-num = p-chip-num
      .
    end.
  end.

end procedure. /* invalidate-md5-signature */