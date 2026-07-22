block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: aht-prc.p $
$Archive: trg/aht-prc.p $

Создание складского архива по типам приобретения для документа переоценки

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 11/11/02

Общее описание информационных потоков:

Рассчитываются doc-line,parts,aht-stk-line -> temp-ot-line
temp-ot-line -> temp-aht-ot-tot
Сохраняются в БД  temp-ot-line -> ot-line
                  temp-aht-ot-tot  -> aht-ot-tot
Обновляются таблицы temp-ot-line,aht-stk-line -> aht-stk-line
                    temp-aht-ot-tot,aht-stk-tot   -> aht-stk-tot

*/

define input  parameter p-doc-code as character no-undo .
define input  parameter p-cut-date as date      no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: aht-prc.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: trg/aht-prc.p $":U .
define variable vss-description as character no-undo initial "Создание складского архива по типам приобретения по переоценке".
{ cmp/vssrevis.i "substitute('&1|&2':u,p-doc-code,p-cut-date)" }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ trg/factord.i  }
{ trg/prdoclib.i }
{ str/prl-vat.i  }
{ gbl/aht.i      }
{ str/clcprtsl.i }

define variable v-ind                       as integer   no-undo .
define variable v-doc-date                  as date      no-undo .
define variable v-start-time                as integer   no-undo .
define variable v-current-time              as character no-undo .
define variable v-current-action            as character no-undo .

main-block :
do transaction
on error undo main-block, return error
:
  define frame a
    v-current-action format 'x(40)':u      no-labels skip
    v-ind            format '>>>>>>>9':u   label "Обработано артикулов" skip
    v-current-time   format 'x(8)':u       label "Время расчета документа" skip
    p-doc-code       format 'x(14)':u      label "Переоценка" skip
    v-doc-date       format '99/99/9999':u label "Дата закрытия документа" skip
    with view-as dialog-box side-labels three-d
    title "Расчет складского архива по типам приобретения"
    .

  define variable mFrameView  as logical no-undo init yes.
  define variable mFramHandle as handle  no-undo.      
  mFramHandle = frame a:handle.

  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameoxmError"). 
      log-manager:write-message("visible-frame-mod=" + string(mFramHandle:visible), "frameoxmError"). 
  end.
  mFrameView = not session:batch-mode and mFramHandle:visible.
  if mFrameView
  then do:
    view frame a .
    display
      p-doc-code
      with frame a .
  end.

  run process-price-doc in this-procedure
    (input p-doc-code
    ,input p-cut-date
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при обработке документа" skip
      "Переоценка" p-doc-code skip
      "Ограничение на обновление складского архива" p-cut-date skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.

end.


procedure process-price-doc :

  define input  parameter p-doc-code as character no-undo .
  define input  parameter p-cut-date as date      no-undo .

  define variable v-fact-order                as decimal   no-undo .
  define variable v-shift-end-fact-order      as decimal   no-undo .
  define variable v-day-end-fact-order        as decimal   no-undo .
  define variable v-day-cut-fact-order        as decimal   no-undo .

  define variable v-today as date      no-undo .
  define variable v-time  as integer   no-undo .

  define buffer buf_price-doc for ub.price-doc .
  define buffer buf_price-list for ub.price-list .

  do
  on error undo, return error return-value
  :
    find first buf_price-doc share-lock
      where buf_price-doc.doc-num = p-doc-code
      no-error .
    if not available buf_price-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найдена переоценка" p-doc-code skip
        view-as alert-box error .
      undo, return error . /* --->>>--- */
    end.

    assign
      v-doc-date = buf_price-doc.fact-date
    .
    if mFrameView
    then display
      v-doc-date
      with frame a .

    if buf_price-doc.status_ <> {&act-overvalue}
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Нельзя рассчитать складской архив по типам приобретения для документа переоценки не закрытого до статуса" {&act-overvalue} skip
        "Переоценка" p-doc-code skip
        view-as alert-box error .
      undo, return error . /* --->>>--- */
    end.

    define variable v-shift-on as logical   no-undo .
    { gbl/objat.i
      buf_price-doc.obj-type
      buf_price-doc.obj-code
      "'shift-on=request'"
      v-shift-on
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при запуске процедуры objat" skip
        "Объект" buf_price-doc.obj-type buf_price-doc.obj-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    define variable v-curr-r-b as character no-undo .
    { gbl/curr-r-b.i
      v-curr-r-b
    }

    run factord in this-procedure
      (input  buf_price-doc.fact-date  /* p-fact-date            */
      ,input  buf_price-doc.fact-time  /* p-fact-time            */
      ,input  buf_price-doc.fact-num   /* p-fact-num             */
      ,input  buf_price-doc.shift-date /* p-shift-date           */
      ,input  buf_price-doc.shift-num  /* p-shift-num            */
      ,input  v-shift-on               /* p-shift-on             */
      ,output v-fact-order             /* p-fact-order           */
      ,output v-shift-end-fact-order   /* p-shift-end-fact-order */
      ,output v-day-end-fact-order     /* p-day-end-fact-order   */
      ) no-error .
    if error-status :error
    or v-fact-order = ?
    or v-fact-order = 0
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении фактического номера переоценки" skip
        "doc-num"                 buf_price-doc.doc-num    skip
        "fact-date"               buf_price-doc.fact-date  skip
        "fact-time"               buf_price-doc.fact-time  skip
        "fact-num"                buf_price-doc.fact-num   skip
        "shift-date"              buf_price-doc.shift-date skip
        "shift-num"               buf_price-doc.shift-num  skip
        "v-fact-order"            v-fact-order            skip
        "v-shift-end-fact-order"  v-shift-end-fact-order  skip
        "v-day-end-fact-order"    v-day-end-fact-order    skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    if p-cut-date = ?
    then do:
      /* по умолчанию обрабатываем весь складской архив */
      /* поэтому необходимо взять число, которое заведомо больше, */
      /* чем любая возможная дата в системе */
      run factord-max-fact-order in this-procedure
        (output v-day-cut-fact-order /* p-max-fact-order */
        ) .
    end.
    else do:
      if p-cut-date = buf_price-doc.fact-date
      then do:
        assign
          v-day-end-fact-order   = v-day-end-fact-order   - {&arh-delta}
        .
      end.
      assign
        v-day-cut-fact-order   = v-day-end-fact-order
      .
    end.

    run show-action in this-procedure
      (input "Обработка строк документа"
      ).

    define variable v-ext-doc-type as character no-undo .
    assign
      v-ext-doc-type = {&TDEDT_Overturn}
    .

    define variable v-base-rate  as decimal   no-undo .
    define variable v-base-scale as decimal   no-undo .
    { gbl/baserate.i
      buf_price-doc.host-code
      buf_price-doc.fact-date
      v-base-rate
      v-base-scale
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении текущего курса" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error . /* --->>>--- */
    end.

    run aht_add-document in this-procedure
      (input buf_price-doc.doc-num    /* p-doc-code     */
      ,input buf_price-doc.obj-type   /* p-obj-type     */
      ,input buf_price-doc.obj-code   /* p-obj-code     */
      ,input v-ext-doc-type           /* p-ext-doc-type */
      ,input false                    /* p-is-trn-doc   */
      ,input buf_price-doc.fact-order /* p-fact-order   */
      ,input buf_price-doc.fact-date  /* p-fact-date    */
      ,input buf_price-doc.shift-date /* p-shift-date   */
      ,input buf_price-doc.shift-num  /* p-shift-num    */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при добавлении документа в складской архив по типам приобретения" skip
        "Переоценка" p-doc-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if p-cut-date = ?
    then do:
      run aht_add-date in this-procedure
        (input buf_price-doc.obj-type   /* p-obj-type   */
        ,input buf_price-doc.obj-code   /* p-obj-code   */
        ,input {&aht-stk-normal}        /* p-stk-type   */
        ,input v-day-end-fact-order     /* p-fact-order */
        ,input buf_price-doc.fact-date  /* p-fact-date  */
        ,input ?                        /* p-shift-date */
        ,input 0                        /* p-shift-num  */
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при добавлении даты в складской архив по типам приобретения" skip
          "Объект" buf_price-doc.obj-type buf_price-doc.obj-code skip
          "Дата" buf_price-doc.fact-date skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.

    define variable v-host-code   as integer   no-undo .
    define variable v-cons-vat-pc as decimal   no-undo .
    { gbl/hostcode.i
      buf_price-doc.obj-type
      buf_price-doc.obj-code
      v-host-code
    }
    { gbl/consvtpc.i
      v-host-code
      v-cons-vat-pc
    }

    run cur-time in this-procedure ( output v-today
                                  , output v-start-time
                                  ).
    run show-action in this-procedure
      (input "Расчет строк переоценки"
      ).

    for each buf_price-list no-lock
      where buf_price-list.doc-num    = buf_price-doc.doc-num
        and buf_price-list.main-price = true
    on error undo, return error
    :
      define variable v-gds-code           as integer   no-undo .
      { gbl/gds-code.i
        buf_price-list.artic
        buf_price-list.prod-type
        buf_price-list.prod-code
        v-gds-code
      }

      run process-price-list in this-procedure
        (input recid(buf_price-list)      /* p-price-list-recid   */
        ,input buf_price-list.doc-num     /* p-doc-code           */
        ,input buf_price-list.artic       /* p-artic              */
        ,input buf_price-list.prod-type   /* p-prod-type          */
        ,input buf_price-list.prod-code   /* p-prod-code          */
        ,input v-gds-code                 /* p-gds-code           */
        ,input buf_price-list.obj-type    /* p-obj-type           */
        ,input buf_price-list.obj-code    /* p-obj-code           */
        ,input v-fact-order               /* p-fact-order         */
        ,input v-day-end-fact-order       /* p-day-end-fact-order */
        ,input buf_price-doc.fact-date    /* p-fact-date          */
        ,input v-ext-doc-type             /* p-ext-doc-type       */
        ,input buf_price-list.vat-pc      /* p-crsa-vat-pc        */
        ,input v-cons-vat-pc              /* p-cons-vat-pc        */
        ,input buf_price-list.slt-pc      /* p-crsa-slt-pc        */
        ,input v-curr-r-b                 /* p-curr-r-b           */
        ,input v-base-rate                /* p-base-rate          */
        ,input v-base-scale               /* p-base-scale         */
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры process-price-list" skip
          "Переоценка" buf_price-list.doc-num skip
          "Артикул" buf_price-list.artic buf_price-list.prod-type buf_price-list.prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.

      assign
        v-ind  = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run cur-time in this-procedure ( output v-today
                                      , output v-time
                                      ).
        assign
          v-current-time = string(v-time - v-start-time, "HH:MM:SS")
        .
        if mFrameView
        then display
          v-ind
          v-current-time
          with frame a .
      end.
    end.

    run show-action in this-procedure
      (input "Расчет шапки документа"
      ).

    run aht_update-ot-tot in this-procedure
      (input buf_price-doc.obj-type     /* p-obj-type     */
      ,input buf_price-doc.obj-code     /* p-obj-code     */
      ,input buf_price-doc.fact-order   /* p-fact-order   */
      ,input v-ext-doc-type             /* p-ext-doc-type */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры update-aht-ot-tot" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    run show-action in this-procedure
      (input "Сохранение оборота"
      ).

    run aht_store-ot-table in this-procedure no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры store-ot-table" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    run show-action in this-procedure
      (input "Сохранение остатков"
      ).

    run aht_update-stk-table in this-procedure
      (input v-day-end-fact-order /* p-fact-order     */
      ,input v-day-cut-fact-order /* p-cut-fact-order */
      ,input v-ext-doc-type       /* p-ext-doc-type   */
      ,input false                /* p-trn-doc        */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры update-stk-table" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    run show-action in this-procedure
      (input "Расчет документа закончен"
      ).
  end.

end procedure. /* process-price-doc */


procedure process-price-list :

  define input  parameter p-price-list-recid   as recid     no-undo .
  define input  parameter p-doc-code           like ub.doc-line.doc-code  no-undo .
  define input  parameter p-artic              like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type          like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code          like ub.doc-line.prod-code no-undo .
  define input  parameter p-gds-code           like ub.goods.gds-code  no-undo .
  define input  parameter p-obj-type           like ub.trn-doc.obj-type     no-undo .
  define input  parameter p-obj-code           like ub.trn-doc.obj-code     no-undo .
  define input  parameter p-fact-order         like ub.trn-doc.fact-order   no-undo .
  define input  parameter p-end-day-fact-order like ub.trn-doc.fact-order   no-undo .
  define input  parameter p-fact-date          as date      no-undo .
  define input  parameter p-ext-doc-type       like ub.trn-doc.ext-doc-type no-undo .
  define input  parameter p-crsa-vat-pc        as decimal   no-undo .
  define input  parameter p-cons-vat-pc        as decimal   no-undo .
  define input  parameter p-crsa-slt-pc        as decimal   no-undo .
  define input  parameter p-curr-r-b           as character no-undo .
  define input  parameter p-base-rate          as decimal   no-undo .
  define input  parameter p-base-scale         as decimal   no-undo .

  define buffer buf_parts for ub.parts .
  define buffer buf_aht-stk-line for ub.aht-stk-line .

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
    { gbl/gdsat.i
      p-artic
      p-prod-type
      p-prod-code
      "'gds-goods=request':u"
      v-gds-goods
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Переоценка" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        'gds-goods=request':u
        view-as alert-box error .
      undo, return error .
    end.

    if v-gds-goods
    then do:
      define buffer buf_tt-clcparts for tt-clcparts .

      for each buf_tt-clcparts
      on error undo, return error return-value
      :
        delete buf_tt-clcparts .
      end.

      /* просматриваем архивные партии, привязанные к переоценке */
      for each buf_parts no-lock
        where buf_parts.out-code  = p-doc-code
          and buf_parts.obj-type  = p-obj-type
          and buf_parts.obj-code  = p-obj-code
          and buf_parts.artic     = p-artic
          and buf_parts.prod-type = p-prod-type
          and buf_parts.prod-code = p-prod-code
          and buf_parts.status_   = true
      on error undo, return error return-value
      :
        create buf_tt-clcparts .
        buffer-copy buf_parts to buf_tt-clcparts .
      end.

      define variable v-cur-base           as decimal   no-undo .
      define variable v-cur-VAT-base       as decimal   no-undo .
      define variable v-cur-SLT-base       as decimal   no-undo .
      define variable v-cur-road-tax-base  as decimal   no-undo .
      define variable v-cur-excise-base    as decimal   no-undo .

      /* определяем общую сумму товара в продажных ценах после переоценки */
      run prdoclib-calc-fact-sale in this-procedure
        (input  p-price-list-recid     /* p-price-list-recid  */
        ,output v-total-crsa-fact-qnty /* p-fact-qnty         */
        ,output v-cur-base             /* p-cur-base          */
        ,output v-cur-VAT-base         /* p-cur-VAT-base      */
        ,output v-cur-SLT-base         /* p-cur-SLT-base      */
        ,output v-cur-road-tax-base    /* v-cur-road-tax-base */
        ,output v-cur-excise-base      /* v-cur-excise-base   */
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вычислении общей суммы переоценки" skip
          "Переоценка" p-doc-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "Код строки" p-price-list-recid skip
          view-as alert-box error .
        undo, return error .
      end.

      if p-crsa-vat-pc = ?
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не задан НДС товара в переоценке" skip
          "Переоценка" p-doc-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "Код товара" p-gds-code skip
          "НДС" p-crsa-vat-pc skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      if p-crsa-slt-pc = ?
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не задан НП товара в переоценке" skip
          "Переоценка" p-doc-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "Код товара" p-gds-code skip
          "НП" p-crsa-slt-pc skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      if p-cons-vat-pc = ?
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не задан налог на услуги по продаже консигнационного товара" skip
          "Переоценка" p-doc-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "Код товара" p-gds-code skip
          "Налог на услуги по продаже консигнационного товара" p-cons-vat-pc skip
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
        ,input p-crsa-vat-pc        /* parcur-vat-pc     */
        ,input p-cons-vat-pc        /* parcurcons-vat-pc */
        ,input p-crsa-slt-pc        /* parcurslt-pc      */
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при расчете учетных цен по партии"
          view-as alert-box error .
        undo, return error .
      end.

      do v-aht-type-ind = 1 to extent(v-aht-type-list)
      :
        assign
          v-aht-type = v-aht-type-list[v-aht-type-ind]
        .

        /* находим последний остаток в учётных ценах */
        find last buf_aht-stk-line exclusive-lock
          where buf_aht-stk-line.obj-type   = p-obj-type
            and buf_aht-stk-line.obj-code   = p-obj-code
            and buf_aht-stk-line.gds-code   = p-gds-code
            and buf_aht-stk-line.sum-type   = v-aht-type
            and buf_aht-stk-line.fact-order <= p-end-day-fact-order
          use-index category
          no-error .
        define variable v-cost-aht-stk-line-exist as logical   no-undo .
        assign
          v-cost-aht-stk-line-exist = false
        .
        if  available buf_aht-stk-line
        and (
          buf_aht-stk-line.fact-qnty <> 0
          or
          &scop fl1  buf_aht-stk-line.cost-
          &scop fls1
          &scop fl2  <> 0
          &scop fl3  or
          {&price-single-list}
          or
          &scop fl1  buf_aht-stk-line.crsa-
          &scop fls1
          &scop fl2  <> 0
          &scop fl3  or
          {&price-single-list}
          or
          &scop fl1  buf_aht-stk-line.sale-
          &scop fls1
          &scop fl2  <> 0
          &scop fl3  or
          {&price-single-list}
            )
        then do:
          /* существуют ненулевые остатки */
          assign
            v-cost-aht-stk-line-exist = true
          .
        end.

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
            "Документ" p-doc-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            "Тип суммы" v-allsum-sum-type skip
            &scop fp1   "cost-
            &scop fps1  "
            &scop fp2   v-cost-
            &scop fps2
            &scop fp3   skip
            &scop fp4
            {&price-pair-list}
            view-as alert-box error .
          undo, return error .
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
            "Документ" p-doc-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            &scop fp1   "v-crsa-
            &scop fps1  "
            &scop fp2   v-crsa-
            &scop fps2
            &scop fp3   skip
            &scop fp4
            {&price-pair-list}
            view-as alert-box error .
          undo, return error .
        end.

        assign
          v-fact-qnty = v-cost-fact-qnty
        .

        if available buf_aht-stk-line
        then do:
          assign
            v-fact-qnty = v-fact-qnty - buf_aht-stk-line.fact-qnty
            &scop FT1    v-cost-
            &scop FTs1
            &scop FT2    = v-cost-
            &scop FTs2
            &scop FT3    - buf_aht-stk-line.cost-
            &scop FTs3
            &scop FT4
            &scop FT5
            {&price-trio-list}
            &scop FT1    v-crsa-
            &scop FTs1
            &scop FT2    = v-crsa-
            &scop FTs2
            &scop FT3    - buf_aht-stk-line.crsa-
            &scop FTs3
            &scop FT4
            &scop FT5
            {&price-trio-list}
            &scop FT1    v-sale-
            &scop FTs1
            &scop FT2    = v-sale-
            &scop FTs2
            &scop FT3    - buf_aht-stk-line.sale-
            &scop FTs3
            &scop FT4
            &scop FT5
            {&price-trio-list}
          .
        end.

        define variable v-err-doc-file-name as character no-undo init "aht-doc.err" .
        define variable v-err-file-name as character no-undo init "aht.err" .
        define variable v-log-file-name as character no-undo init "aht.log" .

        define variable v-log-error as logical   no-undo .
        define variable v-log-diff  as logical   no-undo .

        assign
          v-log-error = false
          v-log-diff  = false
        .

        if v-fact-qnty <> 0
        then do:
          assign
            v-log-error = true
          .
        end.

        if v-fact-qnty <> 0
        then do:
          assign
            v-log-error = true
          .
        end.

        if
        &scop fl1  v-cost-
        &scop fls1
        &scop fl2  <> 0
        &scop fl3  or
        {&price-single-list}
        then do:
          if
          &scop fl1  abs(v-cost-
          &scop fls1 )
          &scop fl2  > 0.0000000005
          &scop fl3  or
          {&price-single-list}
          then do:
            assign
              v-log-error = true
            .
          end.
          else do:
            assign
              v-log-diff  = true
            .
          end.
        end.

        if v-log-error = true
        then do:
          { gbl/file-wr.i
            v-err-doc-file-name
            p-doc-code
          }
          { gbl/file-wr.i
            v-err-doc-file-name
            {&new-line}
          }
          { gbl/file-wr.i
            v-err-file-name
            substitute('"&1","&2","&3","&4","&5","&6","&7","&8","&9"':u,'cost':u,p-doc-code,p-artic,p-prod-type,p-prod-code,p-gds-code,p-obj-type,p-obj-code,v-fact-qnty)
          }
          { gbl/file-wr.i
            v-err-file-name
            {&new-line}
          }
          { gbl/file-wr.i
            v-err-file-name
            substitute('"&1","&2","&3","&4","&5","&6","&7","&8","&9"':u,'base':u,v-cost-sum-base,v-cost-vat-base,v-cost-slt-base,v-cost-road-tax-base,v-cost-excise-base,v-cost-transport-base,v-cost-other-base,v-cost-discnt-base)
          }
          { gbl/file-wr.i
            v-err-file-name
            {&new-line}
          }
          { gbl/file-wr.i
            v-err-file-name
            substitute('"&1","&2","&3","&4","&5","&6","&7","&8","&9"':u,'rubl':u,v-cost-sum-rubl,v-cost-vat-rubl,v-cost-slt-rubl,v-cost-road-tax-rubl,v-cost-excise-rubl,v-cost-transport-rubl,v-cost-other-rubl,v-cost-discnt-rubl)
          }
          { gbl/file-wr.i
            v-err-file-name
            {&new-line}
          }
        end.

        if v-log-diff  = true
        then do:
          { gbl/file-wr.i
            v-log-file-name
            substitute('"&1","&2","&3","&4","&5","&6","&7","&8","&9"':u,'cost':u,p-doc-code,p-artic,p-prod-type,p-prod-code,p-gds-code,p-obj-type,p-obj-code,v-fact-qnty)
          }
          { gbl/file-wr.i
            v-log-file-name
            {&new-line}
          }
          { gbl/file-wr.i
            v-log-file-name
            substitute('"&1","&2","&3","&4","&5","&6","&7","&8","&9"':u,'base':u,v-cost-sum-base,v-cost-vat-base,v-cost-slt-base,v-cost-road-tax-base,v-cost-excise-base,v-cost-transport-base,v-cost-other-base,v-cost-discnt-base)
          }
          { gbl/file-wr.i
            v-log-file-name
            {&new-line}
          }
          { gbl/file-wr.i
            v-log-file-name
            substitute('"&1","&2","&3","&4","&5","&6","&7","&8","&9"':u,'rubl':u,v-cost-sum-rubl,v-cost-vat-rubl,v-cost-slt-rubl,v-cost-road-tax-rubl,v-cost-excise-rubl,v-cost-transport-rubl,v-cost-other-rubl,v-cost-discnt-rubl)
          }
          { gbl/file-wr.i
            v-log-file-name
            {&new-line}
          }
        end.

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
          run aht_store-ot-line in this-procedure
            (input p-doc-code     /* p-doc-code      */
            ,input p-gds-code     /* p-artic         */
            ,input v-aht-type     /* p-sum-type      */
            ,input p-ext-doc-type /* p-ext-doc-type  */
            ,input p-obj-type     /* p-obj-type      */
            ,input p-obj-code     /* p-obj-code      */
            ,input p-fact-order   /* p-fact-order    */
            ,input v-fact-qnty    /* p-fact-qnty     */
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
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при сохранении сумм по документу" skip
              "Тип приобретения" v-aht-type skip
              "Переоценка" p-doc-code skip
              "Артикул" p-artic p-prod-type p-prod-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error .
          end.
        end.
      end.
    end.
  end.
end procedure. /* process-price-list */


procedure show-action :
  do
  on error undo, return error
  :
    define input parameter p-action as character no-undo .

    define variable v-today as date      no-undo.
    define variable v-time  as integer   no-undo.

    run cur-time in this-procedure ( output v-today
                                   , output v-time
                                   ).
    assign
      v-current-time = string(v-time - v-start-time, "HH:MM:SS")
      v-current-action = p-action
    .
    if mFrameView
    then display
      v-current-time
      v-current-action
      with frame a .
  end.
end procedure. /* show-action */