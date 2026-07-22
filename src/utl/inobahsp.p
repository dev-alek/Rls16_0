block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: inobahsp.p $
$Archive: utl/inobahsp.p $

Инициализвация остатков складского архива по поставщикам для одного объекта

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 06/28/06

*/

define input  parameter p-obj-type    as character no-undo .
define input  parameter p-obj-code    as integer   no-undo .
define input  parameter p-cut-date    as date      no-undo .
define output parameter p-error-count as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: inobahsp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/inobahsp.p $":U .
define variable vss-description as character no-undo init "Расчет остатков складского архива по поставщикам на основании текущих остатков товара".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ gbl/ah-csp.i   }
{ trg/factord.i  }
{ gbl/clntattr.i }
{ trg/doclslib.i }
{ trg/prdoclib.i }
{ trg/partslib.i }
{ str/prl-vat.i  }
{ str/clcprtsl.i }

{&def-temp-stk-supp-tot}
{&def-temp-stk-supp-line}
&scop fp1   define variable v-
&scop fps1
&scop fp2   like ub.ot-supp-tot.
&scop fps2
&scop fp3   no-undo .
&scop fp4
{&price-pair-list}

define stream slog .

define variable v-log-file-name   as character no-undo .
define variable v-error-file-name as character no-undo .
define variable v-list-file-name  as character no-undo .

do
on error undo, return error return-value
:

  assign
    v-log-file-name   = substitute('inobahsp_&1_&2.txt':U
                                  ,p-obj-type
                                  ,p-obj-code
                                  )
    v-error-file-name = substitute('inobahsp_&1_&2.err':U
                                  ,p-obj-type
                                  ,p-obj-code
                                  )
    v-list-file-name  = substitute('inobahsp_&1_&2_doc_list.txt':U
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
        ,input  {&attr-ahsp-del}            /* p-code     */
        ,input  "yes"                      /* p-value    */
        ) no-error .

      run clntattr-write in this-procedure
        (input  p-obj-type                 /* p-obj-type */
        ,input  p-obj-code                 /* p-obj-code */
        ,input  {&attr-ahsp-calc}           /* p-code     */
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
        p-error-count = 0
      .
  end.

end.


procedure process-object :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-cut-date as date      no-undo .

  do
  on error undo, return error return-value
  :
    define buffer calc-supp-arh-lock_batchprocess for ub.batchprocess .

    run gbl/lock-prc.p
      (input {&lock-prc-calc-supp-arh}
      ,input p-obj-code
      ,input 0
      ,input 0
      ,input p-obj-type
      ,input ""
      ,input ""
      ,input "Объект,,, ,,,Расчет складского архива по поставщикам"
      ,input true
      ,buffer calc-supp-arh-lock_batchprocess
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "В данный момент рассчитываются складского архив по поставщикам" skip
        "Невозможно произвести инициализацию складского архива по поставщикам" skip
        view-as alert-box error .
      undo, return error .
    end.

    define buffer restore-ahsp-lock_batchprocess for ub.batchprocess .
    /* блокировка процедуры восстановления складского архива */
    run gbl/lock-prc.p
      (input {&lock-prc-restore-ahsp}
      ,input p-obj-code
      ,input 0
      ,input 0
      ,input p-obj-type
      ,input ""
      ,input ""
      ,input "Объект,,, ,,,Восстановление складского складского архива по поставщикам"
      ,input true
      ,buffer restore-ahsp-lock_batchprocess
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры блокировки восстановления складского архива по поставщикам" skip
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

      /* так как производится инициализация складского архива по поставщикам */
      /* то очищаем всю историю */
      run utl/arhiclr.p
        (input  p-obj-type        /* p-obj-type              */
        ,input  p-obj-code        /* p-obj-code              */
        ,input  {&btpr-type-ahsp} /* p-archive-type          */
        ) .

      /* создаем запись об инициализации складского архива по поставщикам */
      define variable v-create-chip-num as integer   no-undo .

      run utl/arhiscr.p
        (input  p-obj-type                    /* p-obj-type              */
        ,input  p-obj-code                    /* p-obj-code              */
        ,input  {&btpr-type-ahsp}             /* p-archive-type          */
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
      v-delete-attr-list  = {&attr-ahsp-detail-date}
          + {&comma-char} + {&attr-ahsp-start-date}
          + {&comma-char} + {&attr-ahsp-del}
          + {&comma-char} + {&attr-ahsp-disable}
          + {&comma-char} + {&attr-ahsp-calc}
          + {&comma-char} + {&attr-ahsp-recalc-date}
    .

    /* удаляем все атрибуты, */
    /* которые относятся к складскому архиву по поставщикам */
    do v-delete-ind = 1 to num-entries(v-delete-attr-list, {&comma-char})
    :
      run clntattr-delete in this-procedure
        (input p-obj-type
        ,input p-obj-code
        ,input entry(v-delete-ind, v-delete-attr-list, {&comma-char})
        ,output v-attr-delete
        ) .
    end.

    /* устанавливаем признак того, что на объекте производится расчет архива */
    run clntattr-write in this-procedure
      (input p-obj-type        /* p-obj-type */
      ,input p-obj-code        /* p-obj-code */
      ,input {&attr-ahsp-calc} /* p-code     */
      ,input true              /* p-value    */
      ) .

    /* помечаем, что на объекте производится первоначальный расчет */
    /* остатков */
    run clntattr-write in this-procedure
      (input p-obj-type       /* p-obj-type */
      ,input p-obj-code       /* p-obj-code */
      ,input {&attr-ahsp-del} /* p-code     */
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
        (input p-obj-type
        ,input p-obj-code
        ,input substitute("Процесс прерван:  &1" , return-value )
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
      undo, return error . /* --->>>--- */
    end.

    run log-information in this-procedure
      (input p-obj-type                                           /* p-obj-type */
      ,input p-obj-code                                           /* p-obj-code */
      ,input "Удаление заданий на обработку складских документов" /* p-message  */
      ) .

    /* очищаем все отложенные задания типа ahsp по данному объекту */
    run clear-batch-ahsp in this-procedure
      (input p-obj-type /* p-obj-type */
      ,input p-obj-code /* p-obj-code */
      ,input today /* p-cut-date */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры clear-batch-ahsp" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error . /* --->>>--- */
    end.

    /* выводим документы, по которым будет вести расчет в текстовый файл */
    run doclslib-export-doc-list in this-procedure
      (input p-obj-type                                       /* p-obj-type      */
      ,input p-obj-code                                       /* p-obj-code      */
      ,input v-list-file-name                                 /* p-log-file-name */
      ,input "Инициализация складского архива по поставщикам" /* p-description   */
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
    /* будет рассчитанный складской архив по поставщикам */
    run clntattr-write in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input {&attr-ahsp-start-date}
      ,input string(p-cut-date, '99/99/9999')
      ) .

    run clntattr-write in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input {&attr-ahsp-detail-date}
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
      ,input {&attr-ahsp-del}
      ,output v-attr-delete
      ) .

    run log-information in this-procedure
      (input p-obj-type              /* p-obj-type */
      ,input p-obj-code              /* p-obj-code */
      ,input "Инициализация завершена. Обработано товаров " + string(v-ind) /* p-message  */
      ) .

    run utl/arhiscr.p
      (input  p-obj-type                   /* p-obj-type              */
      ,input  p-obj-code                   /* p-obj-code              */
      ,input  {&btpr-type-ahsp}            /* p-archive-type          */
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
  define buffer buf_tt-clcparts        for tt-clcparts .
  define buffer buf_tt-allsum-line     for tt-allsum-line .
  define buffer buf_temp-stk-supp-line for temp-stk-supp-line .
  define buffer buf_temp-stk-supp-tot  for temp-stk-supp-tot .

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
      undo, return error .
    end.

    if buf_goods.gds-type = {&gds-goods}
    then do:
      /* обрабатываем остаток по товару */

      run clear-line in this-procedure .

      define variable v-vat-pc            as decimal   no-undo .
      define variable v-slt-pc            as decimal   no-undo .

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
          v-vat-pc         = buf_temp-parts.vat-pc
          v-slt-pc         = buf_temp-parts.slt-pc
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
            "Расчет складского архива по поставщикам невозможен" skip
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
          undo, return error .
        end.


        /* сохраняем информацию о поставщиках (с разбиениями по типам поставки) */
        define variable v-ahsp-type-ind        as integer   no-undo .
        define variable v-ahsp-type-list       as character extent 5 no-undo
          initial [{&arh-repayment}, {&arh-cons_acc}, {&arh-cons_benf}, {&arh-resp_stor}, {&arh-old_cons}] .
        define variable v-allsum-sum-type-list as character extent 5 no-undo
          initial [{&sum-repayment-sign}, {&sum-cons_acc-sign}, {&sum-cons_benf-sign}, {&sum-resp_stor-sign}, {&sum-old-cons-sign}] .
        define variable v-ahsp-type            as character no-undo .
        define variable v-allsum-sum-type      as character no-undo .

        do v-ahsp-type-ind = 1 to extent(v-ahsp-type-list)
        :
          assign
            v-ahsp-type       = v-ahsp-type-list[v-ahsp-type-ind]
            v-allsum-sum-type = v-allsum-sum-type-list[v-ahsp-type-ind]
          .

          find first buf_tt-allsum-line
            where buf_tt-allsum-line.sum-type = v-allsum-sum-type
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

          if v-ahsp-type = {&arh-cons_benf}
          then do:
            assign
              v-fact-qnty = 0
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
              "Расчет складского архива по поставщикам невозможен" skip
              "Объект" p-obj-type p-obj-code skip
              "Артикул" p-artic p-prod-type p-prod-code skip
              "Тип суммы" v-allsum-sum-type skip
              &scop fp1   "v-
              &scop fps1  "
              &scop fp2   v-
              &scop fps2
              &scop fp3
              &scop fp4   skip
              {&price-pair-list}
              view-as alert-box error .
            undo, return error .
          end.

          define variable ind-ext    as integer no-undo .
          define variable v-cat-id   as character no-undo extent 4 .
          define variable v-sum-type as character no-undo extent 4 .

          assign
            v-sum-type[1] = {&arh-cost}
            v-cat-id[1]   = {&single-cat-id}
            v-sum-type[2] = {&arh-cost} + {&arh-supp}
            v-cat-id[2]   = v-ahsp-type
          .
          do ind-ext = 1 to 2
          :
            find first buf_temp-stk-supp-line
              where buf_temp-stk-supp-line.obj-type   = p-obj-type
                and buf_temp-stk-supp-line.obj-code   = p-obj-code
                and buf_temp-stk-supp-line.cli-type   = buf_temp-parts.supp-type
                and buf_temp-stk-supp-line.cli-code   = buf_temp-parts.supp-code
                and buf_temp-stk-supp-line.artic      = p-artic
                and buf_temp-stk-supp-line.prod-type  = p-prod-type
                and buf_temp-stk-supp-line.prod-code  = p-prod-code
                and buf_temp-stk-supp-line.fact-order = p-day-end-fact-order
                and buf_temp-stk-supp-line.sum-type   = v-sum-type[ind-ext]
                and buf_temp-stk-supp-line.cat-id     = v-cat-id[ind-ext]
              no-error .
            if not available buf_temp-stk-supp-line
            then do:
              create buf_temp-stk-supp-line .
              assign
                buf_temp-stk-supp-line.obj-type   = p-obj-type
                buf_temp-stk-supp-line.obj-code   = p-obj-code
                buf_temp-stk-supp-line.cli-type   = buf_temp-parts.supp-type
                buf_temp-stk-supp-line.cli-code   = buf_temp-parts.supp-code
                buf_temp-stk-supp-line.artic      = p-artic
                buf_temp-stk-supp-line.prod-type  = p-prod-type
                buf_temp-stk-supp-line.prod-code  = p-prod-code
                buf_temp-stk-supp-line.fact-order = p-day-end-fact-order
                buf_temp-stk-supp-line.sum-type   = v-sum-type[ind-ext]
                buf_temp-stk-supp-line.cat-id     = v-cat-id[ind-ext]
              .
              assign
                buf_temp-stk-supp-line.fact-date    = p-archive-date
                buf_temp-stk-supp-line.shift-date   = ?
                buf_temp-stk-supp-line.shift-num    = 0
              .
            end.

            assign
              &scop FT1    buf_temp-stk-supp-line.new-
              &scop FTs1
              &scop FT2    = buf_temp-stk-supp-line.new-
              &scop FTs2
              &scop FT3    + v-
              &scop FTs3
              &scop FT4
              &scop FT5
              {&price-trio-list}
            .

            find first buf_temp-stk-supp-tot
              where buf_temp-stk-supp-tot.obj-type   = p-obj-type
                and buf_temp-stk-supp-tot.obj-code   = p-obj-code
                and buf_temp-stk-supp-tot.cli-type   = buf_temp-parts.supp-type
                and buf_temp-stk-supp-tot.cli-code   = buf_temp-parts.supp-code
                and buf_temp-stk-supp-tot.fact-order = p-day-end-fact-order
                and buf_temp-stk-supp-tot.sum-type   = v-sum-type[ind-ext]
                and buf_temp-stk-supp-tot.cat-id     = v-cat-id[ind-ext]
              no-error .
            if not available buf_temp-stk-supp-tot
            then do:
              create buf_temp-stk-supp-tot .
              assign
                buf_temp-stk-supp-tot.obj-type   = p-obj-type
                buf_temp-stk-supp-tot.obj-code   = p-obj-code
                buf_temp-stk-supp-tot.cli-type   = buf_temp-parts.supp-type
                buf_temp-stk-supp-tot.cli-code   = buf_temp-parts.supp-code
                buf_temp-stk-supp-tot.fact-order = p-day-end-fact-order
                buf_temp-stk-supp-tot.sum-type   = v-sum-type[ind-ext]
                buf_temp-stk-supp-tot.cat-id     = v-cat-id[ind-ext]
              .
              assign
                buf_temp-stk-supp-tot.fact-date  = p-archive-date
                buf_temp-stk-supp-tot.shift-date = ?
                buf_temp-stk-supp-tot.shift-num  = 0
              .
            end.
            assign
              &scop FT1    buf_temp-stk-supp-tot.new-
              &scop FTs1
              &scop FT2    = buf_temp-stk-supp-tot.new-
              &scop FTs2
              &scop FT3    + v-
              &scop FTs3
              &scop FT4
              &scop FT5
              {&price-trio-list}
            .
          end.
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

  define buffer buf_temp-stk-supp-line for temp-stk-supp-line .
  define buffer buf_stk-supp-line      for ub.stk-supp-line .

  do
  on error undo, return error return-value
  :

    define variable l-need-create-record as logical   no-undo .


    for each buf_temp-stk-supp-line
    on error undo, return error return-value
    :
      if
      &scop fp1   buf_temp-stk-supp-line.
      &scop fps1
      &scop fp2   <> buf_temp-stk-supp-line.new-
      &scop fps2
      &scop fp3
      &scop fp4   or
      {&price-pair-list}
      or ( buf_temp-stk-supp-line.cat-id = {&single-cat-id} )
      then do:

        assign
          l-need-create-record =
                                  &scop fl1  buf_temp-stk-supp-line.new-
                                  &scop fls1
                                  &scop fl2  <> 0
                                  &scop fl3  or
                                  {&price-single-list}
                              or ( buf_temp-stk-supp-line.cat-id = {&single-cat-id} )
        .

        find first buf_stk-supp-line exclusive-lock
          where buf_stk-supp-line.obj-type   = buf_temp-stk-supp-line.obj-type
            and buf_stk-supp-line.obj-code   = buf_temp-stk-supp-line.obj-code
            and buf_stk-supp-line.cli-type   = buf_temp-stk-supp-line.cli-type
            and buf_stk-supp-line.cli-code   = buf_temp-stk-supp-line.cli-code
            and buf_stk-supp-line.artic      = buf_temp-stk-supp-line.artic
            and buf_stk-supp-line.prod-type  = buf_temp-stk-supp-line.prod-type
            and buf_stk-supp-line.prod-code  = buf_temp-stk-supp-line.prod-code
            and buf_stk-supp-line.fact-order = buf_temp-stk-supp-line.fact-order
            and buf_stk-supp-line.sum-type   = buf_temp-stk-supp-line.sum-type
            and buf_stk-supp-line.cat-id     = buf_temp-stk-supp-line.cat-id
          no-error .
        if l-need-create-record
        then do:
          if not available buf_stk-supp-line
          then do:
            create buf_stk-supp-line .
          end.
          buffer-copy buf_temp-stk-supp-line to buf_stk-supp-line
          assign
            &scop fp1   buf_stk-supp-line.
            &scop fps1
            &scop fp2   = buf_temp-stk-supp-line.new-
            &scop fps2
            &scop fp3
            &scop fp4
            {&price-pair-list}
          .
        end.
        else do:
          if available buf_stk-supp-line
          then do:
            delete buf_stk-supp-line .
          end.
        end.
      end. /*если было изменение*/
    end. /*each tt-stk-supp-line*/

    if p-shift-on = true
    then do:
      for each buf_temp-stk-supp-line
      on error undo, return error return-value
      :
        if
        &scop fp1   buf_temp-stk-supp-line.
        &scop fps1
        &scop fp2   <> buf_temp-stk-supp-line.new-
        &scop fps2
        &scop fp3
        &scop fp4   or
        {&price-pair-list}
        or ( buf_temp-stk-supp-line.cat-id = {&single-cat-id} )
        then do:

          assign
            l-need-create-record =
                                    &scop fl1  buf_temp-stk-supp-line.new-
                                    &scop fls1
                                    &scop fl2  <> 0
                                    &scop fl3  or
                                    {&price-single-list}
                                or ( buf_temp-stk-supp-line.cat-id = {&single-cat-id} )
          .

          find first buf_stk-supp-line exclusive-lock
            where buf_stk-supp-line.obj-type   = buf_temp-stk-supp-line.obj-type
              and buf_stk-supp-line.obj-code   = buf_temp-stk-supp-line.obj-code
              and buf_stk-supp-line.cli-type   = buf_temp-stk-supp-line.cli-type
              and buf_stk-supp-line.cli-code   = buf_temp-stk-supp-line.cli-code
              and buf_stk-supp-line.artic      = buf_temp-stk-supp-line.artic
              and buf_stk-supp-line.prod-type  = buf_temp-stk-supp-line.prod-type
              and buf_stk-supp-line.prod-code  = buf_temp-stk-supp-line.prod-code
              and buf_stk-supp-line.fact-order = p-shift-end-fact-order
              and buf_stk-supp-line.sum-type   = buf_temp-stk-supp-line.sum-type
              and buf_stk-supp-line.cat-id     = buf_temp-stk-supp-line.cat-id
            no-error .
          if l-need-create-record
          then do:
            if not available buf_stk-supp-line
            then do:
              create buf_stk-supp-line .
            end.
            buffer-copy buf_temp-stk-supp-line to buf_stk-supp-line
            assign
              buf_stk-supp-line.fact-order = p-shift-end-fact-order
              buf_stk-supp-line.shift-date = p-shift-date
              buf_stk-supp-line.shift-num  = p-shift-num
              &scop fp1   buf_stk-supp-line.
              &scop fps1
              &scop fp2   = buf_temp-stk-supp-line.new-
              &scop fps2
              &scop fp3
              &scop fp4
              {&price-pair-list}
            .
          end.
          else do:
            if available buf_stk-supp-line
            then do:
              delete buf_stk-supp-line .
            end.
          end.
        end. /*если было изменение*/
      end. /*each tt-stk-supp-line*/
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

  define buffer buf_temp-stk-supp-tot for temp-stk-supp-tot .
  define buffer buf_stk-supp-tot      for ub.stk-supp-tot .

  do
  on error undo, return error return-value
  :

    define variable l-need-create-record as logical   no-undo .

    for each buf_temp-stk-supp-tot
    on error undo, return error return-value
    :
      if
      &scop fp1   buf_temp-stk-supp-tot.
      &scop fps1
      &scop fp2   <> buf_temp-stk-supp-tot.new-
      &scop fps2
      &scop fp3
      &scop fp4   or
      {&price-pair-list}
      or ( buf_temp-stk-supp-tot.cat-id = {&single-cat-id} )
      then do:

        assign
          l-need-create-record =
                                  &scop fl1  buf_temp-stk-supp-tot.new-
                                  &scop fls1
                                  &scop fl2  <> 0
                                  &scop fl3  or
                                  {&price-single-list}
                              or ( buf_temp-stk-supp-tot.cat-id = {&single-cat-id} )
        .

        find first buf_stk-supp-tot exclusive-lock
          where buf_stk-supp-tot.obj-type   = buf_temp-stk-supp-tot.obj-type
            and buf_stk-supp-tot.obj-code   = buf_temp-stk-supp-tot.obj-code
            and buf_stk-supp-tot.cli-type   = buf_temp-stk-supp-tot.cli-type
            and buf_stk-supp-tot.cli-code   = buf_temp-stk-supp-tot.cli-code
            and buf_stk-supp-tot.fact-order = buf_temp-stk-supp-tot.fact-order
            and buf_stk-supp-tot.sum-type   = buf_temp-stk-supp-tot.sum-type
            and buf_stk-supp-tot.cat-id     = buf_temp-stk-supp-tot.cat-id
          no-error .
        if l-need-create-record
        then do:
          if not available buf_stk-supp-tot
          then do:
            create buf_stk-supp-tot .
          end.
          buffer-copy buf_temp-stk-supp-tot to buf_stk-supp-tot
          assign
            &scop fp1   buf_stk-supp-tot.
            &scop fps1
            &scop fp2   = buf_temp-stk-supp-tot.new-
            &scop fps2
            &scop fp3
            &scop fp4
            {&price-pair-list}
          .
        end.
        else do:
          if available buf_stk-supp-tot
          then do:
            delete buf_stk-supp-tot .
          end.
        end.
      end. /*если было изменение*/
    end. /*each tt-stk-supp-tot*/

    if p-shift-on
    then do:
      for each buf_temp-stk-supp-tot
      on error undo, return error return-value
      :
        if
        &scop fp1   buf_temp-stk-supp-tot.
        &scop fps1
        &scop fp2   <> buf_temp-stk-supp-tot.new-
        &scop fps2
        &scop fp3
        &scop fp4   or
        {&price-pair-list}
        or ( buf_temp-stk-supp-tot.cat-id = {&single-cat-id} )
        then do:

          assign
            l-need-create-record =
                                    &scop fl1  buf_temp-stk-supp-tot.new-
                                    &scop fls1
                                    &scop fl2  <> 0
                                    &scop fl3  or
                                    {&price-single-list}
                                or ( buf_temp-stk-supp-tot.cat-id = {&single-cat-id} )
          .

          find first buf_stk-supp-tot exclusive-lock
            where buf_stk-supp-tot.obj-type   = buf_temp-stk-supp-tot.obj-type
              and buf_stk-supp-tot.obj-code   = buf_temp-stk-supp-tot.obj-code
              and buf_stk-supp-tot.cli-type   = buf_temp-stk-supp-tot.cli-type
              and buf_stk-supp-tot.cli-code   = buf_temp-stk-supp-tot.cli-code
              and buf_stk-supp-tot.fact-order = p-shift-end-fact-order
              and buf_stk-supp-tot.sum-type   = buf_temp-stk-supp-tot.sum-type
              and buf_stk-supp-tot.cat-id     = buf_temp-stk-supp-tot.cat-id
            no-error .
          if l-need-create-record
          then do:
            if not available buf_stk-supp-tot
            then do:
              create buf_stk-supp-tot .
            end.
            buffer-copy buf_temp-stk-supp-tot to buf_stk-supp-tot
            assign
              buf_stk-supp-tot.fact-order = p-shift-end-fact-order
              buf_stk-supp-tot.shift-date = p-shift-date
              buf_stk-supp-tot.shift-num  = p-shift-num
              &scop fp1   buf_stk-supp-tot.
              &scop fps1
              &scop fp2   = buf_temp-stk-supp-tot.new-
              &scop fps2
              &scop fp3
              &scop fp4
              {&price-pair-list}
            .
          end.
          else do:
            if available buf_stk-supp-tot
            then do:
              delete buf_stk-supp-tot .
            end.
          end.
        end. /*если было изменение*/
      end. /*each tt-stk-supp-tot*/
    end.

  end.

end procedure. /* store-tot */


procedure clear-tot :

  define buffer buf_temp-stk-supp-tot for temp-stk-supp-tot .

  do
  on error undo, return error return-value
  :
    for each buf_temp-stk-supp-tot
    on error undo, return error return-value
    :
      delete buf_temp-stk-supp-tot .
    end.
  end.

end procedure. /* clear-tot */

procedure clear-line :

  define buffer buf_temp-stk-supp-line for temp-stk-supp-line .

  do
  on error undo, return error return-value
  :
    for each buf_temp-stk-supp-line
    on error undo, return error return-value
    :
      delete buf_temp-stk-supp-line .
    end.
  end.

end procedure. /* clear-line */


procedure clear-db :

  define buffer buf_stk-supp-line for ub.stk-supp-line .
  define buffer buf_stk-supp-tot  for ub.stk-supp-tot .
  define buffer buf_ot-supp-line  for ub.ot-supp-line .
  define buffer buf_ot-supp-tot   for ub.ot-supp-tot .

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
      title "Удаление складского архива по поставщикам" .

    display
      p-obj-type p-obj-code
      v-ind
      with frame a .

    for each buf_stk-supp-line exclusive-lock
      where buf_stk-supp-line.obj-type = p-obj-type
        and buf_stk-supp-line.obj-code = p-obj-code
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
      delete buf_stk-supp-line .
    end.

    for each buf_stk-supp-tot exclusive-lock
      where buf_stk-supp-tot.obj-type = p-obj-type
        and buf_stk-supp-tot.obj-code = p-obj-code
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
      delete buf_stk-supp-tot .
    end.

    for each buf_ot-supp-line exclusive-lock
      where buf_ot-supp-line.obj-type = p-obj-type
        and buf_ot-supp-line.obj-code = p-obj-code
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
      delete buf_ot-supp-line .
    end.

    for each buf_ot-supp-tot exclusive-lock
      where buf_ot-supp-tot.obj-type = p-obj-type
        and buf_ot-supp-tot.obj-code = p-obj-code
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
      delete buf_ot-supp-tot .
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


procedure clear-batch-ahsp :

  define input parameter p-obj-type as character no-undo .
  define input parameter p-obj-code as integer   no-undo .
  define input parameter p-cut-date as date      no-undo .

  do
  on error undo, return error return-value
  :
    define buffer buf_batchprocess for ub.batchprocess .
    define buffer delete_batchprocess for ub.batchprocess .
    define buffer buf_trn-doc for ub.trn-doc .

    for each buf_batchprocess no-lock
      where buf_batchprocess.bp_type = {&btpr-type-ahsp}
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
            find delete_batchprocess exclusive-lock
              where recid(delete_batchprocess) = recid(buf_batchprocess)
              no-error .
            delete delete_batchprocess .
          end.
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестный тип таблицы" skip
            "charkey_one"  buf_batchprocess.charkey_one skip
            "charkey_two"  buf_batchprocess.charkey_two skip
            view-as alert-box error .
          undo, return error .
        end.

      end case .
    end.
  end.

end procedure. /* clear-batch-ahsp */


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