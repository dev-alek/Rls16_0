block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Инициализация остатков складского архива по типам приобретения на основании текущих остатков товара

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/28/04

Для восстановления складского архива по типам приобретения на основании документов

*/

define input  parameter p-handle-callback    as handle    no-undo .
define input  parameter p-obj-type           as character no-undo .
define input  parameter p-obj-code           as integer   no-undo .
define input  parameter p-new-start-date     as date      no-undo .
define input  parameter p-current-start-date as date      no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Первоначальный расчет складского архива по типам приобретения".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5':u,p-handle-callback,p-obj-type,p-obj-code,p-new-start-date,p-current-start-date)" }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ gbl/aht.i      }
{ trg/factord.i  }
{ trg/doclslib.i }
{ trg/prdoclib.i }
{ trg/partslib.i }
{ str/clcprtsl.i }
{ str/prl-vat.i  }

define stream slog .

define buffer buf_aht-stk-line for ub.aht-stk-line .
define buffer buf_aht-stk-tot for ub.aht-stk-tot .
define buffer buf_temp-aht-stk-line for temp-aht-stk-line .
define buffer buf_temp-aht-stk-tot for temp-aht-stk-tot .

do
on error undo, return error return-value
:
  define variable v-curr-r-b as character no-undo .
  { gbl/curr-r-b.i
    v-curr-r-b
  }
  define variable v-shift-on             as logical   no-undo .
  define variable v-shift-date           as date      no-undo .
  define variable v-shift-num            as integer   no-undo .
  define variable v-fact-order           as decimal   no-undo .
  define variable v-shift-end-fact-order as decimal   no-undo .
  define variable v-day-end-fact-order   as decimal   no-undo .
  define variable v-old-shift-on             as logical   no-undo .
  define variable v-old-shift-date           as date      no-undo .
  define variable v-old-shift-num            as integer   no-undo .
  define variable v-old-fact-order           as decimal   no-undo .
  define variable v-old-shift-end-fact-order as decimal   no-undo .
  define variable v-old-day-end-fact-order   as decimal   no-undo .
  run factord-cut-archive in this-procedure
    (input  p-obj-type             /* p-obj-type             */
    ,input  p-obj-code             /* p-obj-code             */
    ,input  p-new-start-date       /* p-fact-date            */
    ,output v-shift-on             /* p-shift-on             */
    ,output v-shift-date           /* p-shift-date           */
    ,output v-shift-num            /* p-shift-num            */
    ,output v-day-end-fact-order   /* p-day-end-fact-order   */
    ,output v-shift-end-fact-order /* p-shift-end-fact-order */
    ) .
  run factord-cut-archive in this-procedure
    (input  p-obj-type                 /* p-obj-type             */
    ,input  p-obj-code                 /* p-obj-code             */
    ,input  p-current-start-date       /* p-fact-date            */
    ,output v-old-shift-on             /* p-shift-on             */
    ,output v-old-shift-date           /* p-shift-date           */
    ,output v-old-shift-num            /* p-shift-num            */
    ,output v-old-day-end-fact-order   /* p-day-end-fact-order   */
    ,output v-old-shift-end-fact-order /* p-shift-end-fact-order */
    ) .
  run doclslib-clear-doc-list in this-procedure .
  run doclslib-init-trn-doc in this-procedure
    (input p-obj-type           /* p-obj-type */
    ,input p-obj-code           /* p-obj-code */
    ,input p-new-start-date + 1 /* p-cut-date */
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
    (input p-obj-type           /* p-obj-type */
    ,input p-obj-code           /* p-obj-code */
    ,input p-new-start-date + 1 /* p-cut-date */
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
  run clear-tot in this-procedure .
  define buffer buf_gds-obj for ub.gds-obj .
  define variable v-host-code   as integer   no-undo .
  define variable v-base-rate   like ub.curr-accnt.exch-rate no-undo .
  define variable v-base-scale  like ub.curr-accnt.exch-scale no-undo .
  define variable v-total-count as integer   no-undo .
  define variable v-cons-pay    as integer   no-undo .
  define variable v-cons-type   as character no-undo .
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
    p-new-start-date
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
    p-obj-type    label "Объект" p-obj-code no-label skip
    v-total-count label "Обработано" skip
    buf_gds-obj.artic label "Артикул" skip
    with frame a view-as dialog-box side-labels three-d
    title "Создание начальных остатков. Архив по типам приобретения" .
  display
    p-obj-type p-obj-code
    with frame a .

  for each buf_gds-obj no-lock
    where buf_gds-obj.obj-type = p-obj-type
      and buf_gds-obj.obj-code = p-obj-code
  on error undo, return error return-value
  :

    define variable v-crsa-vat-pc    as decimal   no-undo .
    define variable v-crsa-slt-pc    as decimal   no-undo .

    /* определяем налоги для разбивки по НДС и НП в текущих продажных ценах */
    define variable v-b-code     as integer   no-undo .
    define variable v-doc-num    as character no-undo .
    define variable v-price-sale as decimal   no-undo .
    define variable v-road-tax   as decimal   no-undo .
    define variable v-excise     as decimal   no-undo .

    { gbl/gdsbcode.i
      buf_gds-obj.gds-code
      ?
      v-b-code
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при поиске первичного бар-кода товара" skip
        "Код товара" buf_gds-obj.gds-code skip
        "Артикул" buf_gds-obj.artic buf_gds-obj.prod-type buf_gds-obj.prod-code skip
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
      v-day-end-fact-order
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
        "Артикул" buf_gds-obj.artic buf_gds-obj.prod-type buf_gds-obj.prod-code skip
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

    assign
      v-total-count = v-total-count + 1
    .
    if v-total-count modulo 10 = 0
    then do:
      display
        v-total-count skip
        buf_gds-obj.artic skip
        with frame a .
    end.

    define variable v-overturn-exist as logical   no-undo .

    run cb_rst-aht_overturn-exist in p-handle-callback
      (input  buf_gds-obj.artic
      ,input  buf_gds-obj.prod-type
      ,input  buf_gds-obj.prod-code
      ,output v-overturn-exist
      ) .

    run clear-line in this-procedure .

    define variable v-gds-goods as logical   no-undo .
    { gbl/gdscdat.i
      buf_gds-obj.gds-code
      "'gds-goods=request':u"
      v-gds-goods
      no-error
    }

    define variable v-need-copy-crsa-cost as logical   no-undo .

    if  v-gds-goods      = true
    and v-overturn-exist = true
    then do:
      assign
        v-need-copy-crsa-cost = false
      .
      /* заполняем остатки для {&arh-crsa} {&arh-cost} */
      run process-gds-obj in this-procedure
        (input buf_gds-obj.obj-type   /* p-obj-type             */
        ,input buf_gds-obj.obj-code   /* p-obj-code             */
        ,input buf_gds-obj.gds-code   /* p-gds-code             */
        ,input v-day-end-fact-order   /* p-day-end-fact-order   */
        ,input v-cons-pay             /* p-cons-pay             */
        ,input v-curr-r-b             /* p-curr-r-b             */
        ,input v-base-rate            /* p-base-rate            */
        ,input v-base-scale           /* p-base-scale           */
        ,input v-base-rate-reason     /* p-base-rate-reason     */
        ,input p-new-start-date       /* p-archive-date         */
        ) .
    end.
    else do:
      assign
        v-need-copy-crsa-cost = true
      .
    end.

    define variable v-sum-type-list        as character no-undo .
    define variable v-sum-type             as character no-undo .
    define variable v-num-entries-sum-type as integer   no-undo .
    define variable v-ind                  as integer   no-undo .

    /* или копируем остатки за исключением {&arh-crsa} {&arh-cost} */
    /* или копируем все остатки */
    /* в зависимости от того, выполнялась процедура p r o c e s s - g d s - o b j или нет */
    run ahrstutl-line-sum-type-list in p-handle-callback
      (input  v-gds-goods     /* p-gds-goods     */
      ,output v-sum-type-list /* p-sum-type-list */
      ) .
    assign
      v-num-entries-sum-type = num-entries(v-sum-type-list)
    .
    do v-ind = 1 to v-num-entries-sum-type
    :
      assign
        v-sum-type = entry(v-ind, v-sum-type-list)
      .

      for each buf_aht-stk-line
        where buf_aht-stk-line.obj-type   = p-obj-type
          and buf_aht-stk-line.obj-code   = p-obj-code
          and buf_aht-stk-line.gds-code   = buf_gds-obj.gds-code
          and buf_aht-stk-line.fact-order = v-old-day-end-fact-order
          and buf_aht-stk-line.sum-type   = v-sum-type
      on error undo, return error return-value
      :
        create buf_temp-aht-stk-line .
        assign
          buf_temp-aht-stk-line.obj-type   = p-obj-type
          buf_temp-aht-stk-line.obj-code   = p-obj-code
          buf_temp-aht-stk-line.gds-code   = buf_gds-obj.gds-code
          buf_temp-aht-stk-line.fact-order = v-day-end-fact-order
          buf_temp-aht-stk-line.sum-type   = v-sum-type
        .
        if v-need-copy-crsa-cost = true
        or (v-need-copy-crsa-cost = false
            and lookup(v-sum-type , {&aht-repayment} + {&comma-char} + {&aht-cons_acc}
                    + {&comma-char} + {&aht-cons_benf} + {&comma-char} + {&aht-resp_stor}
                    + {&comma-char} + {&aht-service} + {&comma-char} + {&aht-old_cons}
                      ) = 0
           )
        then do:
          assign
            buf_temp-aht-stk-line.fact-qnty  = buf_aht-stk-line.fact-qnty
            &scop fp1   buf_temp-aht-stk-line.cost-
            &scop fps1
            &scop fp2   = buf_aht-stk-line.cost-
            &scop fps2
            &scop fp3
            &scop fp4
            {&price-pair-list}
            &scop fp1   buf_temp-aht-stk-line.crsa-
            &scop fps1
            &scop fp2   = buf_aht-stk-line.crsa-
            &scop fps2
            &scop fp3
            &scop fp4
            {&price-pair-list}
          .
        end.
        assign
          &scop fp1   buf_temp-aht-stk-line.sale-
          &scop fps1
          &scop fp2   = buf_aht-stk-line.sale-
          &scop fps2
          &scop fp3
          &scop fp4
          {&price-pair-list}
        .
      end.
    end.

    /* store-line сохраняем информацию об остатке на начало складского архива */
    for each buf_temp-aht-stk-line on error undo, return error return-value :
      find first buf_aht-stk-line exclusive-lock
        where buf_aht-stk-line.obj-type   = buf_temp-aht-stk-line.obj-type
          and buf_aht-stk-line.obj-code   = buf_temp-aht-stk-line.obj-code
          and buf_aht-stk-line.gds-code   = buf_temp-aht-stk-line.gds-code
          and buf_aht-stk-line.fact-order = buf_temp-aht-stk-line.fact-order
          and buf_aht-stk-line.sum-type   = buf_temp-aht-stk-line.sum-type
        no-error .
      if not available buf_aht-stk-line
      then do:
        create buf_aht-stk-line .
        assign
          buf_aht-stk-line.obj-type   = buf_temp-aht-stk-line.obj-type
          buf_aht-stk-line.obj-code   = buf_temp-aht-stk-line.obj-code
          buf_aht-stk-line.gds-code   = buf_temp-aht-stk-line.gds-code
          buf_aht-stk-line.fact-order = buf_temp-aht-stk-line.fact-order
          buf_aht-stk-line.sum-type   = buf_temp-aht-stk-line.sum-type
        .
        if v-need-copy-crsa-cost = true
        or (v-need-copy-crsa-cost = false
            and lookup(v-sum-type , {&aht-repayment} + {&comma-char} + {&aht-cons_acc}
                    + {&comma-char} + {&aht-cons_benf} + {&comma-char} + {&aht-resp_stor}
                    + {&comma-char} + {&aht-service} + {&comma-char} + {&aht-old_cons}
                      ) = 0
           )
        then do:
          assign
            buf_aht-stk-line.fact-qnty  = buf_temp-aht-stk-line.fact-qnty
            &scop fp1   buf_aht-stk-line.cost-
            &scop fps1
            &scop fp2   = buf_temp-aht-stk-line.cost-
            &scop fps2
            &scop fp3
            &scop fp4
            {&price-pair-list}
            &scop fp1   buf_aht-stk-line.crsa-
            &scop fps1
            &scop fp2   = buf_temp-aht-stk-line.crsa-
            &scop fps2
            &scop fp3
            &scop fp4
            {&price-pair-list}
          .
        end.
        assign
          &scop fp1   buf_aht-stk-line.sale-
          &scop fps1
          &scop fp2   = buf_temp-aht-stk-line.sale-
          &scop fps2
          &scop fp3
          &scop fp4
          {&price-pair-list}
        .
      end.
    end.

    /* обновляем итоговую информацию по объекту на основании данных по строке */
    run update-tot in this-procedure .
  end.

  run ahrstutl-tot-sum-type-list in p-handle-callback
    (output v-sum-type-list
    ) .
  assign
    v-num-entries-sum-type = num-entries(v-sum-type-list)
  .
  do v-ind = 1 to v-num-entries-sum-type
  :
    assign
      v-sum-type = entry(v-ind, v-sum-type-list)
    .
    find first buf_temp-aht-stk-tot
      where buf_temp-aht-stk-tot.obj-type   = p-obj-type
        and buf_temp-aht-stk-tot.obj-code   = p-obj-code
        and buf_temp-aht-stk-tot.fact-order = v-day-end-fact-order
        and buf_temp-aht-stk-tot.sum-type   = v-sum-type
      no-error .
    if not available buf_temp-aht-stk-tot
    then do:
      create buf_temp-aht-stk-tot .
      assign
        buf_temp-aht-stk-tot.obj-type   = p-obj-type
        buf_temp-aht-stk-tot.obj-code   = p-obj-code
        buf_temp-aht-stk-tot.sum-type   = v-sum-type
        buf_temp-aht-stk-tot.fact-order = v-day-end-fact-order
      .
    end.
  end.

  /* store-tot */
  for each buf_temp-aht-stk-tot on error undo, return error return-value :
    create buf_aht-stk-tot .
    buffer-copy buf_temp-aht-stk-tot to buf_aht-stk-tot
    .
  end.

  run aht_add-date in this-procedure
    (input p-obj-type           /* p-obj-type   */
    ,input p-obj-code           /* p-obj-code   */
    ,input {&aht-stk-normal}    /* p-stk-type   */
    ,input v-day-end-fact-order /* p-fact-order */
    ,input p-new-start-date     /* p-fact-date  */
    ,input ?                    /* p-shift-date */
    ,input 0                    /* p-shift-num  */
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при добавлении даты в складской архив" skip
      "Объект" p-obj-type p-obj-code skip
      "Дата" p-new-start-date skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end.

procedure process-gds-obj :

  define input  parameter p-obj-type             like ub.gds-obj.obj-type  no-undo .
  define input  parameter p-obj-code             like ub.gds-obj.obj-code  no-undo .
  define input  parameter p-gds-code             like ub.gds-obj.gds-code  no-undo .
  define input  parameter p-day-end-fact-order   as decimal   no-undo .
  define input  parameter p-cons-pay             as integer   no-undo .
  define input  parameter p-curr-r-b             as character no-undo .
  define input  parameter p-base-rate            like ub.curr-accnt.exch-rate no-undo .
  define input  parameter p-base-scale           like ub.curr-accnt.exch-scale no-undo .
  define input  parameter p-base-rate-reason     as character no-undo .
  define input  parameter p-archive-date         as date      no-undo .

  define buffer buf_goods        for ub.goods .
  define buffer buf_temp-parts   for temp-parts .
  define buffer buf_temp-prt-obj for temp-prt-obj .
  define buffer buf_tt-clcparts  for tt-clcparts .

  define variable v-gds-goods as logical   no-undo .

  define variable v-aht-type-list   as character extent 6 no-undo
    initial [{&aht-repayment}, {&aht-cons_acc}, {&aht-cons_benf}, {&aht-resp_stor}, {&aht-old_cons}, {&aht-service}] .
  define variable v-aht-type        as character no-undo .
  define variable v-aht-type-ind    as integer   no-undo .
  define variable v-allsum-sum-type as character no-undo .

  define variable v-cost-fact-qnty        as decimal   no-undo .
  define variable v-fact-qnty as decimal   no-undo .
  &scop fl1  define variable v-cost-
  &scop fls1
  &scop fl2  as decimal   no-undo .
  &scop fl3
  {&price-single-list}
  &scop fl1  define variable v-crsa-
  &scop fls1
  &scop fl2  as decimal   no-undo .
  &scop fl3
  {&price-single-list}
  &scop fl1  define variable v-sale-
  &scop fls1
  &scop fl2  as decimal   no-undo .
  &scop fl3
  {&price-single-list}

  define variable v-total-crsa-fact-qnty  as decimal   no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/gdscdat.i
      p-gds-code
      "'gds-goods=request':u"
      v-gds-goods
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Код товара" p-gds-code skip
        'gds-goods=request':u
        view-as alert-box error .
      undo, return error return-value .
    end.

    if v-gds-goods
    then do:
      /* обрабатываем остаток по товару */

      define variable v-cur-base          as decimal   no-undo .
      define variable v-cur-VAT-base      as decimal   no-undo .
      define variable v-cur-SLT-base      as decimal   no-undo .
      define variable v-cur-road-tax-base as decimal   no-undo .
      define variable v-cur-excise-base   as decimal   no-undo .

      define variable v-artic     like ub.goods.artic     no-undo .
      define variable v-prod-type like ub.goods.prod-type no-undo .
      define variable v-prod-code like ub.goods.prod-code no-undo .

      { gbl/arptpc.i
        p-gds-code
        v-artic
        v-prod-type
        v-prod-code
      }

      /* определяем количество товара по признакам */
      /* на дату инициализации складского архива */
      run prdoclib-init-prt-obj-by-factord in this-procedure
        (input p-obj-type           /* p-obj-type           */
        ,input p-obj-code           /* p-obj-code           */
        ,input v-artic              /* p-artic              */
        ,input v-prod-type          /* p-prod-type          */
        ,input v-prod-code          /* p-prod-code          */
        ,input p-day-end-fact-order /* p-fact-order         */
        ,input false                /* p-include-fact-order */
        ) .

      assign
        v-fact-qnty         = 0
        v-cur-base          = 0
        v-cur-VAT-base      = 0
        v-cur-SLT-base      = 0
        v-cur-road-tax-base = 0
        v-cur-excise-base   = 0
      .

      run prdoclib-calc-temp-fact-sale in this-procedure
        (input  p-obj-type             /* p-obj-type           */
        ,input  p-obj-code             /* p-obj-code           */
        ,input  p-gds-code             /* p-gds-code           */
        ,input  p-day-end-fact-order   /* p-day-end-fact-order */
        ,input  p-curr-r-b             /* p-curr-r-b           */
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
        ,input v-artic              /* p-artic              */
        ,input v-prod-type          /* p-prod-type          */
        ,input v-prod-code          /* p-prod-code          */
        ,input p-day-end-fact-order /* p-fact-order         */
        ,input false                /* p-include-fact-order */
        ) .

      for each buf_tt-clcparts
      on error undo, return error return-value
      :
        delete buf_tt-clcparts .
      end.

      define variable v-rest-exist as logical   no-undo .
      assign
        v-rest-exist = false
      .

      for each buf_temp-prt-obj
      on error undo, return error return-value
      :
        if buf_temp-prt-obj.fact-qnty <> 0
        then do:
          assign
            v-rest-exist = true
          .
        end.
      end.

      /* во временной таблице уже находятся только те партии, которые нужны */
      define variable v-exist-qnty as integer   no-undo .

      assign
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

      if v-crsa-vat-pc = ?
      then do:
        if v-rest-exist = true
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Не задан налог товара на дату" skip
            "Налог" "НДС" skip
            "Код товара" p-gds-code skip
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
            "Код товара" p-gds-code skip
            "Объект" p-obj-type p-obj-code skip
            "Тип налога" {&slt-tax-code} skip
            "Дата" p-archive-date skip
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

      if v-cur-price-sale     = ?
      or v-cur-price-road-tax = ?
      or v-cur-price-excise   = ?
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Получены неопределенные значения в текущих продажных ценах" skip
          "Объект" p-obj-type p-obj-code skip
          "Код товара" p-gds-code skip
          "cur-price-sale"     v-cur-price-sale     skip
          "cur-price-road-tax" v-cur-price-road-tax skip
          "cur-price-excise"   v-cur-price-excise   skip
          view-as alert-box error .
        undo, return error return-value .
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
          "Код товара" p-gds-code skip
          "Причина" p-base-rate-reason skip
          view-as alert-box error .
        undo, return error return-value .
      end.

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
        ,input p-curr-r-b           /* parr-b            */
        ,input v-cur-price-sale     /* parcur-base       */
        ,input v-cur-price-road-tax /* parcur-road-tax   */
        ,input v-cur-price-excise   /* parcur-excise     */
        ,input v-crsa-vat-pc        /* parcur-vat-pc     */
        ,input v-cons-vat-pc        /* parcurcons-vat-pc */
        ,input v-crsa-slt-pc        /* parcurslt-pc      */
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове программы clcprtsl_calc-ttable" skip
          "Объект" p-obj-type p-obj-code skip
          "Код товара" p-gds-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .

        undo, return error return-value .
      end.

      do v-aht-type-ind = 1 to extent(v-aht-type-list)
      :
        assign
          v-aht-type = v-aht-type-list[v-aht-type-ind]
        .

        run aht_get-sum-type in this-procedure
          (input  v-aht-type        /* p-aht-type        */
          ,output v-allsum-sum-type /* p-allsum-sum-type */
          ) .
        define buffer buf_tt-allsum-line for tt-allsum-line .
        find first buf_tt-allsum-line
          where buf_tt-allsum-line.sum-type = v-allsum-sum-type
          no-error .
        if available buf_tt-allsum-line
        then do:
          /* надо брать суммы с обратным знаком */
          assign
            v-cost-fact-qnty      = - buf_tt-allsum-line.fact-qnty
            v-cost-sum-base       = - buf_tt-allsum-line.sum-dsc-base-acc
            v-cost-sum-rubl       = - buf_tt-allsum-line.sum-dsc-rubl-acc
            v-cost-vat-base       = - buf_tt-allsum-line.vat-base-acc
            v-cost-vat-rubl       = - buf_tt-allsum-line.vat-rubl-acc
            v-cost-slt-base       = - buf_tt-allsum-line.slt-base-acc
            v-cost-slt-rubl       = - buf_tt-allsum-line.slt-rubl-acc
            v-cost-road-tax-base  = - buf_tt-allsum-line.road-tax-base-acc
            v-cost-road-tax-rubl  = - buf_tt-allsum-line.road-tax-rubl-acc
            v-cost-excise-base    = - buf_tt-allsum-line.excise-base-acc
            v-cost-excise-rubl    = - buf_tt-allsum-line.excise-rubl-acc
            v-cost-transport-base = - buf_tt-allsum-line.transport-base-acc
            v-cost-transport-rubl = - buf_tt-allsum-line.transport-rubl-acc
            v-cost-other-base     = - buf_tt-allsum-line.other-base-acc
            v-cost-other-rubl     = - buf_tt-allsum-line.other-rubl-acc
            v-cost-discnt-base    = - buf_tt-allsum-line.dsc-base-acc
            v-cost-discnt-rubl    = - buf_tt-allsum-line.dsc-rubl-acc
          .
          assign
            v-crsa-sum-base       = - buf_tt-allsum-line.sum-dsc-base-cur
            v-crsa-sum-rubl       = - buf_tt-allsum-line.sum-dsc-rubl-cur
            v-crsa-vat-base       = - buf_tt-allsum-line.vat-base-cur
            v-crsa-vat-rubl       = - buf_tt-allsum-line.vat-rubl-cur
            v-crsa-slt-base       = - buf_tt-allsum-line.slt-base-cur
            v-crsa-slt-rubl       = - buf_tt-allsum-line.slt-rubl-cur
            v-crsa-road-tax-base  = - buf_tt-allsum-line.road-tax-base-cur
            v-crsa-road-tax-rubl  = - buf_tt-allsum-line.road-tax-rubl-cur
            v-crsa-excise-base    = - buf_tt-allsum-line.excise-base-cur
            v-crsa-excise-rubl    = - buf_tt-allsum-line.excise-rubl-cur
            v-crsa-transport-base = 0
            v-crsa-transport-rubl = 0
            v-crsa-other-base     = 0
            v-crsa-other-rubl     = 0
            v-crsa-discnt-base    = - buf_tt-allsum-line.dsc-base-cur
            v-crsa-discnt-rubl    = - buf_tt-allsum-line.dsc-rubl-cur
          .
        end.
        else do:
          assign
            v-cost-fact-qnty      = 0
            v-cost-sum-base       = 0
            v-cost-sum-rubl       = 0
            v-cost-vat-base       = 0
            v-cost-vat-rubl       = 0
            v-cost-slt-base       = 0
            v-cost-slt-rubl       = 0
            v-cost-road-tax-base  = 0
            v-cost-road-tax-rubl  = 0
            v-cost-excise-base    = 0
            v-cost-excise-rubl    = 0
            v-cost-transport-base = 0
            v-cost-transport-rubl = 0
            v-cost-other-base     = 0
            v-cost-other-rubl     = 0
            v-cost-discnt-base    = 0
            v-cost-discnt-rubl    = 0
          .
          assign
            v-crsa-sum-base       = 0
            v-crsa-sum-rubl       = 0
            v-crsa-vat-base       = 0
            v-crsa-vat-rubl       = 0
            v-crsa-slt-base       = 0
            v-crsa-slt-rubl       = 0
            v-crsa-road-tax-base  = 0
            v-crsa-road-tax-rubl  = 0
            v-crsa-excise-base    = 0
            v-crsa-excise-rubl    = 0
            v-crsa-transport-base = 0
            v-crsa-transport-rubl = 0
            v-crsa-other-base     = 0
            v-crsa-other-rubl     = 0
            v-crsa-discnt-base    = 0
            v-crsa-discnt-rubl    = 0
          .
        end.

        if
        &scop fl1  v-cost-
        &scop fls1
        &scop fl2  = ?
        &scop fl3  or
        {&price-single-list}
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Программа clcprtsl.i вернула неопределенные значения" skip
            "Объект" p-obj-type p-obj-code skip
            "Код товара" p-gds-code skip
            "Тип суммы" v-allsum-sum-type skip
            &scop fp1   "cost-
            &scop fps1  "
            &scop fp2   v-cost-
            &scop fps2
            &scop fp3   skip
            &scop fp4
            {&price-pair-list}
            view-as alert-box error .
          undo, return error return-value .
        end.

        if
        &scop fl1  v-crsa-
        &scop fls1
        &scop fl2  = ?
        &scop fl3  or
        {&price-single-list}
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Программа clcprtsl.i вернула неопределенные значения" skip
            "Объект" p-obj-type p-obj-code skip
            "Код товара" p-gds-code skip
            &scop fp1   "v-crsa-
            &scop fps1  "
            &scop fp2   v-crsa-
            &scop fps2
            &scop fp3   skip
            &scop fp4
            {&price-pair-list}
            view-as alert-box error .
          undo, return error return-value .
        end.

        assign
          v-fact-qnty = v-cost-fact-qnty
        .

        if v-fact-qnty <> 0
        or
        &scop fl1  v-cost-
        &scop fls1
        &scop fl2  <> 0
        &scop fl3  or
        {&price-single-list}
        or
        &scop fl1  v-crsa-
        &scop fls1
        &scop fl2  <> 0
        &scop fl3  or
        {&price-single-list}
        or
        &scop fl1  v-sale-
        &scop fls1
        &scop fl2  <> 0
        &scop fl3  or
        {&price-single-list}
        then do:
          /* если по строке переоценки был оборот */
          /* сохраняем запись в складской архив */
          run store-stk-line in this-procedure
            (input p-obj-type           /* p-obj-type      */
            ,input p-obj-code           /* p-obj-code      */
            ,input p-gds-code           /* p-artic         */
            ,input p-day-end-fact-order /* p-fact-order    */
            ,input v-aht-type           /* p-sum-type      */
            ,input v-fact-qnty          /* p-fact-qnty     */
            &scop fl1    ,input v-cost-
            &scop fls1
            &scop fl2
            &scop fl3
            {&price-single-list}
            &scop fl1    ,input v-crsa-
            &scop fls1
            &scop fl2
            &scop fl3
            {&price-single-list}
            &scop fl1    ,input v-sale-
            &scop fls1
            &scop fl2
            &scop fl3
            {&price-single-list}
            ) no-error .
        end.
      end.
    end.
  end.
end procedure. /* process-gds-obj */


procedure store-stk-line :

  define input  parameter p-obj-type       as character no-undo .
  define input  parameter p-obj-code       as integer   no-undo .
  define input  parameter p-gds-code       as integer   no-undo .
  define input  parameter p-fact-order     as decimal   no-undo .
  define input  parameter p-sum-type       as character no-undo .
  define input  parameter p-fact-qnty      as decimal   no-undo .
  &scop fl1    define input  parameter p-cost-
  &scop fls1
  &scop fl2    as decimal   no-undo .
  &scop fl3
  {&price-single-list}
  &scop fl1    define input  parameter p-crsa-
  &scop fls1
  &scop fl2    as decimal   no-undo .
  &scop fl3
  {&price-single-list}
  &scop fl1    define input  parameter p-sale-
  &scop fls1
  &scop fl2    as decimal   no-undo .
  &scop fl3
  {&price-single-list}

  do
  on error undo, return error return-value
  :
    /* сохраняем информацию о товаре в базу данных */
    define buffer buf_aht-stk-line for ub.aht-stk-line .

    find first buf_aht-stk-line exclusive-lock
      where buf_aht-stk-line.obj-type   = p-obj-type
        and buf_aht-stk-line.obj-code   = p-obj-code
        and buf_aht-stk-line.gds-code   = p-gds-code
        and buf_aht-stk-line.fact-order = p-fact-order
        and buf_aht-stk-line.sum-type   = p-sum-type
      no-error .
    if not available buf_aht-stk-line
    then do:
      create buf_aht-stk-line .
      assign
        buf_aht-stk-line.obj-type   = p-obj-type
        buf_aht-stk-line.obj-code   = p-obj-code
        buf_aht-stk-line.gds-code   = p-gds-code
        buf_aht-stk-line.fact-order = p-fact-order
        buf_aht-stk-line.sum-type   = p-sum-type
      .
    end.

    assign
      buf_aht-stk-line.fact-qnty = buf_aht-stk-line.fact-qnty + p-fact-qnty
      &scop FT1    buf_aht-stk-line.cost-
      &scop FTs1
      &scop FT2    = buf_aht-stk-line.cost-
      &scop FTs2
      &scop FT3    + p-cost-
      &scop FTs3
      &scop FT4
      &scop FT5
      {&price-trio-list}
      &scop FT1    buf_aht-stk-line.crsa-
      &scop FTs1
      &scop FT2    = buf_aht-stk-line.crsa-
      &scop FTs2
      &scop FT3    + p-crsa-
      &scop FTs3
      &scop FT4
      &scop FT5
      {&price-trio-list}
      &scop FT1    buf_aht-stk-line.sale-
      &scop FTs1
      &scop FT2    = buf_aht-stk-line.sale-
      &scop FTs2
      &scop FT3    + p-sale-
      &scop FTs3
      &scop FT4
      &scop FT5
      {&price-trio-list}
    .
  end.
end procedure. /* store-stk-line */
procedure clear-tot :
  define buffer buf_temp-aht-stk-tot for temp-aht-stk-tot .
  do on error undo, return error return-value :
    for each buf_temp-aht-stk-tot on error undo, return error return-value :
      delete buf_temp-aht-stk-tot .
    end.
  end.
end procedure. /* clear-tot */
procedure clear-line :
  define buffer buf_temp-aht-stk-line      for temp-aht-stk-line .
  do on error undo, return error return-value :
    for each buf_temp-aht-stk-line
    on error undo, return error return-value :
      delete buf_temp-aht-stk-line .
    end.
  end.
end procedure. /* clear-line */
procedure update-tot :
  define buffer buf_temp-aht-stk-line for temp-aht-stk-line .
  define buffer buf_temp-aht-stk-tot  for temp-aht-stk-tot .
  do on error undo, return error return-value :
    for each buf_temp-aht-stk-line on error undo, return error return-value :
      find first buf_temp-aht-stk-tot
        where buf_temp-aht-stk-tot.obj-type   = p-obj-type
          and buf_temp-aht-stk-tot.obj-code   = p-obj-code
          and buf_temp-aht-stk-tot.fact-order = v-day-end-fact-order
          and buf_temp-aht-stk-tot.sum-type   = buf_temp-aht-stk-line.sum-type
        no-error .
      if not available buf_temp-aht-stk-tot
      then do:
        create buf_temp-aht-stk-tot .
        assign
          buf_temp-aht-stk-tot.obj-type   = p-obj-type
          buf_temp-aht-stk-tot.obj-code   = p-obj-code
          buf_temp-aht-stk-tot.sum-type   = buf_temp-aht-stk-line.sum-type
          buf_temp-aht-stk-tot.fact-order = v-day-end-fact-order
        .
      end.
      assign
        &scop FT1    buf_temp-aht-stk-tot.cost-
        &scop FTs1
        &scop FT2    = buf_temp-aht-stk-tot.cost-
        &scop FTs2
        &scop FT3    + buf_temp-aht-stk-line.cost-
        &scop FTs3
        &scop FT4
        &scop FT5
        {&price-trio-list}
        &scop FT1    buf_temp-aht-stk-tot.crsa-
        &scop FTs1
        &scop FT2    = buf_temp-aht-stk-tot.crsa-
        &scop FTs2
        &scop FT3    + buf_temp-aht-stk-line.crsa-
        &scop FTs3
        &scop FT4
        &scop FT5
        {&price-trio-list}
        &scop FT1    buf_temp-aht-stk-tot.sale-
        &scop FTs1
        &scop FT2    = buf_temp-aht-stk-tot.sale-
        &scop FTs2
        &scop FT3    + buf_temp-aht-stk-line.sale-
        &scop FTs3
        &scop FT4
        &scop FT5
        {&price-trio-list}
      .
    end.
  end.
end procedure. /* update-tot */