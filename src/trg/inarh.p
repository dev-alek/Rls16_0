block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Инициализация остатков складского архива по товарам на основании текущих остатков товара

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/28/04

Для восстановления складсого архива по товарам на основании документов

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
define variable vss-description as character no-undo init "Инициализация остатков складского архива по товарам на основании текущих остатков товара".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5':u,p-handle-callback,p-obj-type,p-obj-code,p-new-start-date,p-current-start-date)" }
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

define stream slog .

{&def-temp-stk-tot}
{&def-temp-stk-line}
{&def-var-list}

define buffer buf_stk-line for ub.stk-line .
define buffer buf_stk-tot for ub.stk-tot .
define buffer buf_temp-stk-line for temp-stk-line .
define buffer buf_temp-stk-tot for temp-stk-tot .

do
on error undo, return error return-value
:
  define variable v-curr-r-b as character no-undo .
  { gbl/curr-r-b.i
    v-curr-r-b
  }

  define variable v-shift-on                 as logical   no-undo .
  define variable v-shift-date               as date      no-undo .
  define variable v-shift-num                as integer   no-undo .
  define variable v-fact-order               as decimal   no-undo .
  define variable v-shift-end-fact-order     as decimal   no-undo .
  define variable v-day-end-fact-order       as decimal   no-undo .
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
    title "Создание начальных остатков. Архив по товарам" .
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

    run cb_rst-arh_overturn-exist in p-handle-callback
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
        ,input buf_gds-obj.artic      /* p-artic                */
        ,input buf_gds-obj.prod-type  /* p-prod-type            */
        ,input buf_gds-obj.prod-code  /* p-prod-code            */
        ,input v-cons-pay             /* p-cons-pay             */
        ,input v-base-rate            /* p-base-rate            */
        ,input v-base-scale           /* p-base-scale           */
        ,input v-base-rate-reason     /* p-base-rate-reason     */
        ,input p-new-start-date       /* p-archive-date         */
        ,input v-shift-on             /* p-shift-on             */
        ,input v-shift-date           /* p-shift-date           */
        ,input v-shift-num            /* p-shift-num            */
        ,input v-day-end-fact-order   /* p-day-end-fact-order   */
        ,input v-shift-end-fact-order /* p-shift-end-fact-order */
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
    /* в зависимости от того, выполнялась процедура process-gds-obj или нет */
    run ahrstutl-line-sum-type-list in this-procedure
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
      if v-need-copy-crsa-cost = true
      or (v-need-copy-crsa-cost = false
          and not v-sum-type begins {&arh-crsa}
          and not v-sum-type begins {&arh-cost}
          )
      then do:
        for each buf_stk-line
          where buf_stk-line.obj-type   = p-obj-type
            and buf_stk-line.obj-code   = p-obj-code
            and buf_stk-line.artic      = buf_gds-obj.artic
            and buf_stk-line.prod-type  = buf_gds-obj.prod-type
            and buf_stk-line.prod-code  = buf_gds-obj.prod-code
            and buf_stk-line.fact-order = v-old-day-end-fact-order
            and buf_stk-line.sum-type   begins v-sum-type
        on error undo, return error return-value
        :
          create buf_temp-stk-line .
          assign
            &scop fp1 buf_temp-stk-line.
            &scop fp2 = buf_stk-line.
            {&stk-line-pair-list}
            buf_temp-stk-line.fact-order = v-day-end-fact-order
            buf_temp-stk-line.fact-date  = p-new-start-date
            buf_temp-stk-line.shift-date = ?
            buf_temp-stk-line.shift-num  = 0
            &scop fp1   buf_temp-stk-line.new-
            &scop fps1
            &scop fp2   = buf_stk-line.
            &scop fps2
            &scop fp3
            &scop fp4
            {&price-pair-list}
          .
        end.

        if v-shift-on = true
        then do:
          for each buf_stk-line
            where buf_stk-line.obj-type   = p-obj-type
              and buf_stk-line.obj-code   = p-obj-code
              and buf_stk-line.artic      = buf_gds-obj.artic
              and buf_stk-line.prod-type  = buf_gds-obj.prod-type
              and buf_stk-line.prod-code  = buf_gds-obj.prod-code
              and buf_stk-line.fact-order = v-old-day-end-fact-order
              and buf_stk-line.sum-type   begins v-sum-type
          on error undo, return error return-value
          :
            create buf_temp-stk-line .
            assign
              &scop fp1 buf_temp-stk-line.
              &scop fp2 = buf_stk-line.
              {&stk-line-pair-list}
              buf_temp-stk-line.fact-order = v-shift-end-fact-order
              buf_temp-stk-line.fact-date  = p-new-start-date
              buf_temp-stk-line.shift-date = v-shift-date
              buf_temp-stk-line.shift-num  = v-shift-num

              &scop fp1   buf_temp-stk-line.new-
              &scop fps1
              &scop fp2   = buf_stk-line.
              &scop fps2
              &scop fp3
              &scop fp4
              {&price-pair-list}
            .
          end.
        end.
      end.
    end.

    /* сохраняем информацию об остатке на начало складского архива */
    run store-line in this-procedure .

    /* обновляем итоговую информацию по объекту на основании данных по строке */
    run update-tot in this-procedure .
  end.

  run ahrstutl-tot-sum-type-list in this-procedure
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
    find first buf_temp-stk-tot
      where buf_temp-stk-tot.obj-type   = p-obj-type
        and buf_temp-stk-tot.obj-code   = p-obj-code
        and buf_temp-stk-tot.fact-order = v-day-end-fact-order
        and buf_temp-stk-tot.sum-type   = v-sum-type
        and buf_temp-stk-tot.cat-id     = {&root-cat-id}
      no-error .
    if not available buf_temp-stk-tot
    then do:
      create buf_temp-stk-tot .
      assign
        buf_temp-stk-tot.obj-type   = p-obj-type
        buf_temp-stk-tot.obj-code   = p-obj-code
        buf_temp-stk-tot.sum-type   = v-sum-type
        buf_temp-stk-tot.cat-id     = {&root-cat-id}
        buf_temp-stk-tot.fact-order = v-day-end-fact-order
        buf_temp-stk-tot.fact-date  = p-new-start-date
        buf_temp-stk-tot.shift-date = ?
        buf_temp-stk-tot.shift-num  = 0
      .
    end.

    if v-shift-on = true
    then do:
      find first buf_temp-stk-tot
        where buf_temp-stk-tot.obj-type   = p-obj-type
          and buf_temp-stk-tot.obj-code   = p-obj-code
          and buf_temp-stk-tot.fact-order = v-shift-end-fact-order
          and buf_temp-stk-tot.sum-type   = v-sum-type
          and buf_temp-stk-tot.cat-id     = {&root-cat-id}
        no-error .
      if not available buf_temp-stk-tot
      then do:
        create buf_temp-stk-tot .
        assign
          buf_temp-stk-tot.obj-type   = p-obj-type
          buf_temp-stk-tot.obj-code   = p-obj-code
          buf_temp-stk-tot.sum-type   = v-sum-type
          buf_temp-stk-tot.cat-id     = {&root-cat-id}
          buf_temp-stk-tot.fact-order = v-shift-end-fact-order
          buf_temp-stk-tot.fact-date  = p-new-start-date
          buf_temp-stk-tot.shift-date = v-shift-date
          buf_temp-stk-tot.shift-num  = v-shift-num
        .
      end.
    end.
  end.

  run store-tot in this-procedure .

end.

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

      if v-shift-on = true
      then do:
        find first buf_temp-stk-line
          where buf_temp-stk-line.obj-type   = p-obj-type
            and buf_temp-stk-line.obj-code   = p-obj-code
            and buf_temp-stk-line.artic      = p-artic
            and buf_temp-stk-line.prod-type  = p-prod-type
            and buf_temp-stk-line.prod-code  = p-prod-code
            and buf_temp-stk-line.fact-order = p-shift-end-fact-order
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
            buf_temp-stk-line.fact-order = p-shift-end-fact-order
            buf_temp-stk-line.sum-type   = {&arh-crsa}
            buf_temp-stk-line.cat-id     = {&root-cat-id}
          .
          assign
            buf_temp-stk-line.fact-date    = p-archive-date
            buf_temp-stk-line.shift-date   = p-shift-date
            buf_temp-stk-line.shift-num    = p-shift-num
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
      end.


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

          if v-shift-on = true
          then do:
            find first buf_temp-stk-line
              where buf_temp-stk-line.obj-type   = p-obj-type
                and buf_temp-stk-line.obj-code   = p-obj-code
                and buf_temp-stk-line.artic      = p-artic
                and buf_temp-stk-line.prod-type  = p-prod-type
                and buf_temp-stk-line.prod-code  = p-prod-code
                and buf_temp-stk-line.fact-order = p-shift-end-fact-order
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
                buf_temp-stk-line.fact-order = p-shift-end-fact-order
                buf_temp-stk-line.sum-type   = v-sum-type[ind-ext]
                buf_temp-stk-line.cat-id     = v-cat-id[ind-ext]
              .
              assign
                buf_temp-stk-line.fact-date    = p-archive-date
                buf_temp-stk-line.shift-date   = p-shift-date
                buf_temp-stk-line.shift-num    = p-shift-num
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
          end.
        end.
      end.

      if v-total-crsa-fact-qnty <> v-total-parts-fact-qnty
      then do:
        output stream slog to inarh.err append .
        export stream slog string(today, '99/99/9999':u) string(time, 'HH:MM:SS':u) "err-qnty" p-obj-type p-obj-code p-artic p-prod-type p-prod-code cur-time-string() .
        export stream slog "v-total-crsa-fact-qnty parts-fact-qnty" v-total-crsa-fact-qnty v-total-parts-fact-qnty .
        output stream slog close .
      end.
    end.
  end.
end procedure. /* process-gds-obj */

procedure store-line :

  define buffer buf_temp-stk-line      for temp-stk-line .
  define buffer buf_stk-line           for ub.stk-line .

  do
  on error undo, return error return-value
  :
    for each buf_temp-stk-line
    on error undo, return error return-value
    :
      create buf_stk-line .
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
  end.

end procedure. /* store-line */


procedure store-tot :

  define buffer buf_temp-stk-tot      for temp-stk-tot .
  define buffer buf_stk-tot           for ub.stk-tot .

  do
  on error undo, return error return-value
  :
    for each buf_temp-stk-tot
    on error undo, return error return-value
    :
      create buf_stk-tot .
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


procedure update-tot :

  define buffer buf_temp-stk-line for temp-stk-line .
  define buffer buf_temp-stk-tot  for temp-stk-tot .

  do
  on error undo, return error return-value
  :
    for each buf_temp-stk-line
    on error undo, return error return-value
    :
      find first buf_temp-stk-tot
        where buf_temp-stk-tot.obj-type   = p-obj-type
          and buf_temp-stk-tot.obj-code   = p-obj-code
          and buf_temp-stk-tot.fact-order = v-day-end-fact-order
          and buf_temp-stk-tot.sum-type   = buf_temp-stk-line.sum-type
          and buf_temp-stk-tot.cat-id     = buf_temp-stk-line.cat-id
        no-error .
      if not available buf_temp-stk-tot
      then do:
        create buf_temp-stk-tot .
        assign
          buf_temp-stk-tot.obj-type   = p-obj-type
          buf_temp-stk-tot.obj-code   = p-obj-code
          buf_temp-stk-tot.sum-type   = buf_temp-stk-line.sum-type
          buf_temp-stk-tot.cat-id     = buf_temp-stk-line.cat-id
          buf_temp-stk-tot.fact-order = v-day-end-fact-order
          buf_temp-stk-tot.fact-date  = p-new-start-date
          buf_temp-stk-tot.shift-date = ?
          buf_temp-stk-tot.shift-num  = 0
        .
      end.
      assign
        &scop FT1    buf_temp-stk-tot.new-
        &scop FTs1
        &scop FT2    = buf_temp-stk-tot.new-
        &scop FTs2
        &scop FT3    + buf_temp-stk-line.new-
        &scop FTs3
        &scop FT4
        &scop FT5
        {&price-trio-list}
      .

      if v-shift-on = true
      then do:
        find first buf_temp-stk-tot
          where buf_temp-stk-tot.obj-type   = p-obj-type
            and buf_temp-stk-tot.obj-code   = p-obj-code
            and buf_temp-stk-tot.fact-order = v-shift-end-fact-order
            and buf_temp-stk-tot.sum-type   = buf_temp-stk-line.sum-type
            and buf_temp-stk-tot.cat-id     = buf_temp-stk-line.cat-id
          no-error .
        if not available buf_temp-stk-tot
        then do:
          create buf_temp-stk-tot .
          assign
            buf_temp-stk-tot.obj-type   = p-obj-type
            buf_temp-stk-tot.obj-code   = p-obj-code
            buf_temp-stk-tot.sum-type   = buf_temp-stk-line.sum-type
            buf_temp-stk-tot.cat-id     = buf_temp-stk-line.cat-id
            buf_temp-stk-tot.fact-order = v-shift-end-fact-order
            buf_temp-stk-tot.fact-date  = p-new-start-date
            buf_temp-stk-tot.shift-date = v-shift-date
            buf_temp-stk-tot.shift-num  = v-shift-num
          .
        end.
        assign
          &scop FT1    buf_temp-stk-tot.new-
          &scop FTs1
          &scop FT2    = buf_temp-stk-tot.new-
          &scop FTs2
          &scop FT3    + buf_temp-stk-line.new-
          &scop FTs3
          &scop FT4
          &scop FT5
          {&price-trio-list}
        .
      end.

      if buf_temp-stk-line.sum-type = {&arh-crsa}
      then do:
        define variable v-sum-type as character no-undo .
        define variable v-cat-id   as character no-undo .

        assign
          v-sum-type = {&arh-crsa} + {&arh-VAT}
          v-cat-id   = trim(string(v-crsa-vat-pc, ">99")) + "," + {&single-cat-id}
        .

        if v-cat-id = ?
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестная категория налога" skip
            view-as alert-box error .
          undo, return error return-value .
        end.

        find first buf_temp-stk-tot
          where buf_temp-stk-tot.obj-type   = p-obj-type
            and buf_temp-stk-tot.obj-code   = p-obj-code
            and buf_temp-stk-tot.fact-order = v-day-end-fact-order
            and buf_temp-stk-tot.sum-type   = v-sum-type
            and buf_temp-stk-tot.cat-id     = v-cat-id
          no-error .
        if not available buf_temp-stk-tot
        then do:
          create buf_temp-stk-tot .
          assign
            buf_temp-stk-tot.obj-type   = p-obj-type
            buf_temp-stk-tot.obj-code   = p-obj-code
            buf_temp-stk-tot.sum-type   = v-sum-type
            buf_temp-stk-tot.cat-id     = v-cat-id
            buf_temp-stk-tot.fact-order = v-day-end-fact-order
            buf_temp-stk-tot.fact-date  = p-new-start-date
            buf_temp-stk-tot.shift-date = ?
            buf_temp-stk-tot.shift-num  = 0
          .
        end.
        assign
          &scop FT1    buf_temp-stk-tot.new-
          &scop FTs1
          &scop FT2    = buf_temp-stk-tot.new-
          &scop FTs2
          &scop FT3    + buf_temp-stk-line.new-
          &scop FTs3
          &scop FT4
          &scop FT5
          {&price-trio-list}
        .

        if v-shift-on = true
        then do:
          find first buf_temp-stk-tot
            where buf_temp-stk-tot.obj-type   = p-obj-type
              and buf_temp-stk-tot.obj-code   = p-obj-code
              and buf_temp-stk-tot.fact-order = v-shift-end-fact-order
              and buf_temp-stk-tot.sum-type   = v-sum-type
              and buf_temp-stk-tot.cat-id     = v-cat-id
            no-error .
          if not available buf_temp-stk-tot
          then do:
            create buf_temp-stk-tot .
            assign
              buf_temp-stk-tot.obj-type   = p-obj-type
              buf_temp-stk-tot.obj-code   = p-obj-code
              buf_temp-stk-tot.sum-type   = v-sum-type
              buf_temp-stk-tot.cat-id     = v-cat-id
              buf_temp-stk-tot.fact-order = v-shift-end-fact-order
              buf_temp-stk-tot.fact-date  = p-new-start-date
              buf_temp-stk-tot.shift-date = v-shift-date
              buf_temp-stk-tot.shift-num  = v-shift-num
            .
          end.
          assign
            &scop FT1    buf_temp-stk-tot.new-
            &scop FTs1
            &scop FT2    = buf_temp-stk-tot.new-
            &scop FTs2
            &scop FT3    + buf_temp-stk-line.new-
            &scop FTs3
            &scop FT4
            &scop FT5
            {&price-trio-list}
          .
        end.

        assign
          v-sum-type = {&arh-crsa} + {&arh-SLT}
          v-cat-id   = {&single-cat-id} + "," + trim(string(v-crsa-slt-pc, ">99"))
        .

        if v-cat-id = ?
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестная категория налога" skip
            view-as alert-box error .
          undo, return error return-value .
        end.

        find first buf_temp-stk-tot
          where buf_temp-stk-tot.obj-type   = p-obj-type
            and buf_temp-stk-tot.obj-code   = p-obj-code
            and buf_temp-stk-tot.fact-order = v-day-end-fact-order
            and buf_temp-stk-tot.sum-type   = v-sum-type
            and buf_temp-stk-tot.cat-id     = v-cat-id
          no-error .
        if not available buf_temp-stk-tot
        then do:
          create buf_temp-stk-tot .
          assign
            buf_temp-stk-tot.obj-type   = p-obj-type
            buf_temp-stk-tot.obj-code   = p-obj-code
            buf_temp-stk-tot.sum-type   = v-sum-type
            buf_temp-stk-tot.cat-id     = v-cat-id
            buf_temp-stk-tot.fact-order = v-day-end-fact-order
            buf_temp-stk-tot.fact-date  = p-new-start-date
            buf_temp-stk-tot.shift-date = ?
            buf_temp-stk-tot.shift-num  = 0
          .
        end.
        assign
          &scop FT1    buf_temp-stk-tot.new-
          &scop FTs1
          &scop FT2    = buf_temp-stk-tot.new-
          &scop FTs2
          &scop FT3    + buf_temp-stk-line.new-
          &scop FTs3
          &scop FT4
          &scop FT5
          {&price-trio-list}
        .

        if v-shift-on = true
        then do:
          find first buf_temp-stk-tot
            where buf_temp-stk-tot.obj-type   = p-obj-type
              and buf_temp-stk-tot.obj-code   = p-obj-code
              and buf_temp-stk-tot.fact-order = v-shift-end-fact-order
              and buf_temp-stk-tot.sum-type   = v-sum-type
              and buf_temp-stk-tot.cat-id     = v-cat-id
            no-error .
          if not available buf_temp-stk-tot
          then do:
            create buf_temp-stk-tot .
            assign
              buf_temp-stk-tot.obj-type   = p-obj-type
              buf_temp-stk-tot.obj-code   = p-obj-code
              buf_temp-stk-tot.sum-type   = v-sum-type
              buf_temp-stk-tot.cat-id     = v-cat-id
              buf_temp-stk-tot.fact-order = v-shift-end-fact-order
              buf_temp-stk-tot.fact-date  = p-new-start-date
              buf_temp-stk-tot.shift-date = v-shift-date
              buf_temp-stk-tot.shift-num  = v-shift-num
            .
          end.
          assign
            &scop FT1    buf_temp-stk-tot.new-
            &scop FTs1
            &scop FT2    = buf_temp-stk-tot.new-
            &scop FTs2
            &scop FT3    + buf_temp-stk-line.new-
            &scop FTs3
            &scop FT4
            &scop FT5
            {&price-trio-list}
          .
        end.

        assign
          v-sum-type = {&arh-crsa} + {&arh-VATSLT}
          v-cat-id   = trim(string(v-crsa-vat-pc, ">99")) + "," + trim(string(v-crsa-slt-pc, ">99"))
        .

        if v-cat-id = ?
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестная категория налога" skip
            view-as alert-box error .
          undo, return error return-value .
        end.

        find first buf_temp-stk-tot
          where buf_temp-stk-tot.obj-type   = p-obj-type
            and buf_temp-stk-tot.obj-code   = p-obj-code
            and buf_temp-stk-tot.fact-order = v-day-end-fact-order
            and buf_temp-stk-tot.sum-type   = v-sum-type
            and buf_temp-stk-tot.cat-id     = v-cat-id
          no-error .
        if not available buf_temp-stk-tot
        then do:
          create buf_temp-stk-tot .
          assign
            buf_temp-stk-tot.obj-type   = p-obj-type
            buf_temp-stk-tot.obj-code   = p-obj-code
            buf_temp-stk-tot.sum-type   = v-sum-type
            buf_temp-stk-tot.cat-id     = v-cat-id
            buf_temp-stk-tot.fact-order = v-day-end-fact-order
            buf_temp-stk-tot.fact-date  = p-new-start-date
            buf_temp-stk-tot.shift-date = ?
            buf_temp-stk-tot.shift-num  = 0
          .
        end.
        assign
          &scop FT1    buf_temp-stk-tot.new-
          &scop FTs1
          &scop FT2    = buf_temp-stk-tot.new-
          &scop FTs2
          &scop FT3    + buf_temp-stk-line.new-
          &scop FTs3
          &scop FT4
          &scop FT5
          {&price-trio-list}
        .

        if v-shift-on = true
        then do:
          find first buf_temp-stk-tot
            where buf_temp-stk-tot.obj-type   = p-obj-type
              and buf_temp-stk-tot.obj-code   = p-obj-code
              and buf_temp-stk-tot.fact-order = v-shift-end-fact-order
              and buf_temp-stk-tot.sum-type   = v-sum-type
              and buf_temp-stk-tot.cat-id     = v-cat-id
            no-error .
          if not available buf_temp-stk-tot
          then do:
            create buf_temp-stk-tot .
            assign
              buf_temp-stk-tot.obj-type   = p-obj-type
              buf_temp-stk-tot.obj-code   = p-obj-code
              buf_temp-stk-tot.sum-type   = v-sum-type
              buf_temp-stk-tot.cat-id     = v-cat-id
              buf_temp-stk-tot.fact-order = v-shift-end-fact-order
              buf_temp-stk-tot.fact-date  = p-new-start-date
              buf_temp-stk-tot.shift-date = v-shift-date
              buf_temp-stk-tot.shift-num  = v-shift-num
            .
          end.
          assign
            &scop FT1    buf_temp-stk-tot.new-
            &scop FTs1
            &scop FT2    = buf_temp-stk-tot.new-
            &scop FTs2
            &scop FT3    + buf_temp-stk-line.new-
            &scop FTs3
            &scop FT4
            &scop FT5
            {&price-trio-list}
          .
        end.
      end.
    end.
  end.

end procedure. /* update-tot */


procedure ahrstutl-tot-sum-type-list :

  define output parameter p-sum-type-list as character no-undo .

  do
  on error undo, return error return-value
  :
    define variable v-ind                    as integer   no-undo .
    define variable v-num-entries-TDEDT_List as integer   no-undo .

    assign
      v-num-entries-TDEDT_List = num-entries({&TDEDT_List})
    .
    assign
      p-sum-type-list = {&arh-crsa}
                      + {&comma-char}
                      + {&arh-cost}
    .
    do v-ind = 1 to v-num-entries-TDEDT_List
    :
      assign
        p-sum-type-list = p-sum-type-list
                        + {&comma-char}
                        + {&arh-sadt} + entry(v-ind, {&TDEDT_List})
      .
    end.
    do v-ind = 1 to v-num-entries-TDEDT_List
    :
      assign
        p-sum-type-list = p-sum-type-list
                        + {&comma-char}
                        + {&arh-cgdt} + entry(v-ind, {&TDEDT_List})
      .
    end.
    do v-ind = 1 to v-num-entries-TDEDT_List
    :
      assign
        p-sum-type-list = p-sum-type-list
                        + {&comma-char}
                        + {&arh-csdt} + entry(v-ind, {&TDEDT_List})
      .
    end.
    do v-ind = 1 to v-num-entries-TDEDT_List
    :
      assign
        p-sum-type-list = p-sum-type-list
                        + {&comma-char}
                        + {&arh-sadt-service} + entry(v-ind, {&TDEDT_List})
      .
    end.
    do v-ind = 1 to v-num-entries-TDEDT_List
    :
      assign
        p-sum-type-list = p-sum-type-list
                        + {&comma-char}
                        + {&arh-cgdt-service} + entry(v-ind, {&TDEDT_List})
      .
    end.
    do v-ind = 1 to v-num-entries-TDEDT_List
    :
      assign
        p-sum-type-list = p-sum-type-list
                        + {&comma-char}
                        + {&arh-csdt-service} + entry(v-ind, {&TDEDT_List})
      .
    end.
  end.

end procedure. /* ahrstutl-tot-sum-type-list */


procedure ahrstutl-line-sum-type-list :

  define input  parameter p-gds-goods     as logical   no-undo .
  define output parameter p-sum-type-list as character no-undo .

  do
  on error undo, return error return-value
  :
    define variable v-ind                    as integer   no-undo .
    define variable v-num-entries-TDEDT_List as integer   no-undo .

    assign
      v-num-entries-TDEDT_List = num-entries({&TDEDT_List})
    .

    if p-gds-goods
    then do:
      assign
        p-sum-type-list = {&arh-crsa}
                        + {&comma-char}
                        + {&arh-cost}
      .
      do v-ind = 1 to v-num-entries-TDEDT_List
      :
        assign
          p-sum-type-list = p-sum-type-list
                          + {&comma-char}
                          + {&arh-sadt} + entry(v-ind, {&TDEDT_List})
        .
      end.
      do v-ind = 1 to v-num-entries-TDEDT_List
      :
        assign
          p-sum-type-list = p-sum-type-list
                          + {&comma-char}
                          + {&arh-cgdt} + entry(v-ind, {&TDEDT_List})
        .
      end.
      do v-ind = 1 to v-num-entries-TDEDT_List
      :
        assign
          p-sum-type-list = p-sum-type-list
                          + {&comma-char}
                          + {&arh-csdt} + entry(v-ind, {&TDEDT_List})
        .
      end.
    end.
    else do:
      assign
        p-sum-type-list = {&arh-crsa-service}
                        + {&comma-char}
                        + {&arh-cost-service}
      .
      do v-ind = 1 to v-num-entries-TDEDT_List
      :
        assign
          p-sum-type-list = p-sum-type-list
                          + {&comma-char}
                          + {&arh-sadt-service} + entry(v-ind, {&TDEDT_List})
        .
      end.
      do v-ind = 1 to v-num-entries-TDEDT_List
      :
        assign
          p-sum-type-list = p-sum-type-list
                          + {&comma-char}
                          + {&arh-cgdt-service} + entry(v-ind, {&TDEDT_List})
        .
      end.
      do v-ind = 1 to v-num-entries-TDEDT_List
      :
        assign
          p-sum-type-list = p-sum-type-list
                          + {&comma-char}
                          + {&arh-csdt-service} + entry(v-ind, {&TDEDT_List})
        .
      end.
    end.
  end.

end procedure. /* ahrstutl-line-sum-type-list */