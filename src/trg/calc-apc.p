block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание складского архива по товарам для документа переоценки

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 08/22/00

*/

define input  parameter p-doc-num  as character no-undo .
define input  parameter p-cut-date as date      no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Расчет складского архива по товарам по переоценке".
{ cmp/vssrevis.i "substitute('&1|&2':u,p-doc-num,p-cut-date)" }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ gbl/arh.i      }
{ trg/factord.i  }
{ trg/prdoclib.i }
{ str/prl-vat.i  }
{ str/clcprtsl.i }

define stream slog .

define variable ind                         as integer no-undo .
define variable start-time                  as integer   no-undo .
define variable current-time                as character no-undo .
define variable current-action              as character no-undo .
define variable v-ext-doc-type              as character no-undo .
define variable v-ot-fact-order             like ub.ot-tot.fact-order  no-undo .
define variable v-stk-tot-fact-order        like ub.stk-tot.fact-order no-undo .
define variable v-stk-line-fact-order       like ub.stk-line.fact-order no-undo .
define variable v-shift-stk-tot-fact-order  like ub.stk-tot.fact-order no-undo .
define variable v-shift-stk-line-fact-order like ub.stk-line.fact-order no-undo .
define variable l-need-create-record        as logical no-undo .
define variable v-base-rate                 like ub.curr-accnt.exch-rate no-undo .
define variable v-base-scale                like ub.curr-accnt.exch-scale no-undo .
define variable v-shift-on                  as logical   no-undo .
define variable v-fact-order                as decimal   no-undo .
define variable v-shift-end-fact-order      as decimal   no-undo .
define variable v-day-end-fact-order        as decimal   no-undo .
define variable v-shift-cut-fact-order      as decimal   no-undo .
define variable v-day-cut-fact-order        as decimal   no-undo .

define variable ind-ext                     as integer              no-undo .
define variable v-cat-id                    as character  extent 4  no-undo .
define variable v-sum-type                  as character  extent 4  no-undo .

define variable v-today                     as date                 no-undo.
define variable v-time                      as integer              no-undo.

{&def-temp-ot-tot}
{&def-temp-ot-line}
{&def-temp-stk-tot}
{&def-temp-stk-line}
{&def-temp-shift-ot-tot}
{&def-temp-shift-ot-line}
{&def-temp-shift-stk-tot}
{&def-temp-shift-stk-line}
{&def-var-list}

main-block :
do transaction
on error undo main-block, return error
:

  find first ub.price-doc share-lock
    where ub.price-doc.doc-num = p-doc-num
    no-error .
  if not available ub.price-doc then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найдена переоценка" p-doc-num skip
      view-as alert-box error .
    undo main-block, return error . /* --->>>--- */
  end.

  if ub.price-doc.status_ <> {&act-overvalue} then do:
    message
      vss-workfile vss-revision vss-description skip
      "Нельзя рассчитать складской архив по товарам для документа переоценки не закрытого до статуса" {&act} skip
      "Переоценка" p-doc-num skip
      view-as alert-box error .
    undo main-block, return error . /* --->>>--- */
  end.

  assign
    v-shift-on = false
  .
  { gbl/objat.i
    ub.price-doc.obj-type
    ub.price-doc.obj-code
    "'shift-on=request'"
    v-shift-on
    no-error
  }
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при запуске процедуры objat" skip
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
    (input  ub.price-doc.fact-date  /* p-fact-date            */
    ,input  ub.price-doc.fact-time  /* p-fact-time            */
    ,input  ub.price-doc.fact-num   /* p-fact-num             */
    ,input  ub.price-doc.shift-date /* p-shift-date           */
    ,input  ub.price-doc.shift-num  /* p-shift-num            */
    ,input  v-shift-on              /* p-shift-on             */
    ,output v-fact-order            /* p-fact-order           */
    ,output v-shift-end-fact-order  /* p-shift-end-fact-order */
    ,output v-day-end-fact-order    /* p-day-end-fact-order   */
    ) no-error .
  if error-status :error
  or v-fact-order = ?
  or v-fact-order = 0 then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении фактического номера переоценки" skip
      "doc-num"                 ub.price-doc.doc-num    skip
      "fact-date"               ub.price-doc.fact-date  skip
      "fact-time"               ub.price-doc.fact-time  skip
      "fact-num"                ub.price-doc.fact-num   skip
      "shift-date"              ub.price-doc.shift-date skip
      "shift-num"               ub.price-doc.shift-num  skip
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
      (output v-shift-cut-fact-order /* p-max-fact-order */
      ) .
    run factord-max-fact-order in this-procedure
      (output v-day-cut-fact-order /* p-max-fact-order */
      ) .
  end.
  else do:
    if p-cut-date = ub.price-doc.fact-date
    then do:
      assign
        v-day-end-fact-order = v-day-end-fact-order - {&arh-delta}
      .
      if v-shift-on = true
      then do:
        define buffer buf_shift-obj for ub.shift-obj .
        find last buf_shift-obj
          where buf_shift-obj.obj-type    = ub.price-doc.obj-type
            and buf_shift-obj.obj-code    = ub.price-doc.obj-code
            and buf_shift-obj.shift-date <= p-cut-date
          use-index pi
          no-error .
        if not available buf_shift-obj
        or buf_shift-obj.status_ <> {&sht-closed}
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при поиске последней смены" skip
            "Объект" ub.price-doc.obj-type ub.price-doc.obj-code skip
            "Дата" p-cut-date skip
            view-as alert-box error .
          undo, return error return-value .
        end.

        if  ub.price-doc.shift-date = buf_shift-obj.shift-date
        and ub.price-doc.shift-num  = buf_shift-obj.shift-num
        then do:
          assign
            v-shift-end-fact-order = v-shift-end-fact-order - {&arh-delta}
          .
        end.
      end.
    end.
    assign
      v-shift-cut-fact-order = v-shift-end-fact-order
      v-day-cut-fact-order   = v-day-end-fact-order
    .
  end.

  def frame inf
    ub.price-doc.doc-num                       label "Переоценка" skip
    ub.price-doc.obj-type                      label "Объект"
    ub.price-doc.obj-code                      no-label skip
    ub.price-doc.fact-date format "99/99/9999" label "Дата закрытия" skip
    current-action         format "x(40)"      no-label skip
    ind                    format ">>>>>>>9"   label "Обработано артикулов" skip
    ub.price-list.artic                        label "Текущий артикул" skip
    current-time           format "x(8)"       label "Время расчета документа" skip
    with view-as dialog-box side-labels three-d
    title "Расчет складского архива по товарам"
    .
  define variable mFrameView      as logical   no-undo init yes.
  define variable mFramHandle as handle no-undo.      
  mFramHandle = frame inf:handle.

  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameArhError"). 
      log-manager:write-message("visible-frame-mod=" + string(mFramHandle:visible), "frameArhError"). 
  end.
  mFrameView = not session:batch-mode and mFramHandle:visible.
  run cur-time in this-procedure ( output v-today
                                 , output start-time
                                 ).
  if mFrameView
  then do:
     view frame inf .
     display
        ub.price-doc.doc-num
        ub.price-doc.obj-type
        ub.price-doc.obj-code
        ub.price-doc.fact-date
     with frame inf .
  end.
  run show-action in this-procedure
    (input "Обработка строк документа"
    ).

  assign
    v-ext-doc-type = {&TDEDT_Overturn}
  .

  assign
    v-ot-fact-order             = v-fact-order
    v-stk-tot-fact-order        = v-day-end-fact-order
    v-stk-line-fact-order       = v-day-end-fact-order
    v-shift-stk-tot-fact-order  = v-shift-end-fact-order
    v-shift-stk-line-fact-order = v-shift-end-fact-order
  .

  { gbl/baserate.i
    ub.price-doc.host-code
    ub.price-doc.fact-date
    v-base-rate
    v-base-scale
    no-error
  }
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении текущего курса" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error . /* --->>>--- */
  end.

  run init-temp-tables in this-procedure no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры init-temp-tables" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error . /* --->>>--- */
  end.

  define variable l-gds-goods as logical   no-undo .

  for each ub.price-list no-lock
    where ub.price-list.doc-num    = ub.price-doc.doc-num
      and ub.price-list.main-price = true
  on error undo main-block, return error
  :
if ub.price-list.doc-num = "51382-2280м" and ub.price-list.artic = "04631140033624"
and ub.price-list.prod-type = "орг" and ub.price-list.prod-code = 236092022 then run gbl/inidebug.p .
    { gbl/gdsat.i
      ub.price-list.artic
      ub.price-list.prod-type
      ub.price-list.prod-code
      "'gds-goods=request':u"
      l-gds-goods
      no-error
    }
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" ub.price-list.artic ub.price-list.prod-type ub.price-list.prod-code skip
        'gds-goods=request':u
        view-as alert-box error .
      undo, return error .
    end.

    if l-gds-goods then do:
      define buffer buf_tt-clcparts for tt-clcparts .

      for each buf_tt-clcparts
      on error undo, return error return-value
      :
        delete buf_tt-clcparts .
      end.

      /* просматриваем архивные партии, привязанные к переоценке */
      define buffer buf_parts for ub.parts .

      for each buf_parts no-lock
        where buf_parts.out-code  = ub.price-list.doc-num
          and buf_parts.obj-type  = ub.price-list.obj-type
          and buf_parts.obj-code  = ub.price-list.obj-code
          and buf_parts.artic     = ub.price-list.artic
          and buf_parts.prod-type = ub.price-list.prod-type
          and buf_parts.prod-code = ub.price-list.prod-code
          and buf_parts.status_   = true
      on error undo, return error return-value
      :
        create buf_tt-clcparts .
        buffer-copy buf_parts to buf_tt-clcparts .
      end.

      define variable v-total-crsa-fact-qnty as decimal   no-undo .
      define variable v-cur-base           as decimal   no-undo .
      define variable v-cur-VAT-base       as decimal   no-undo .
      define variable v-cur-SLT-base       as decimal   no-undo .
      define variable v-cur-road-tax-base  as decimal   no-undo .
      define variable v-cur-excise-base    as decimal   no-undo .


      /* определяем общую сумму товара в продажных ценах после переоценки */
      run prdoclib-calc-fact-sale in this-procedure
        (input  recid(ub.price-list) /* p-price-list-recid  */
        ,output v-total-crsa-fact-qnty /* p-fact-qnty         */
        ,output v-cur-base           /* p-cur-base          */
        ,output v-cur-VAT-base       /* p-cur-VAT-base      */
        ,output v-cur-SLT-base       /* p-cur-SLT-base      */
        ,output v-cur-road-tax-base  /* v-cur-road-tax-base */
        ,output v-cur-excise-base    /* v-cur-excise-base   */
        ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вычислении общей суммы переоценки" skip
          "Переоценка" ub.price-list.doc-num skip
          "Артикул" ub.price-list.artic ub.price-list.prod-type ub.price-list.prod-code skip
          view-as alert-box error .
        undo, return error .
      end.

      define variable v-host-code   as integer   no-undo .
      define variable v-crsa-vat-pc as decimal   no-undo .
      define variable v-crsa-slt-pc as decimal   no-undo .

      { gbl/hostcode.i
        ub.price-list.obj-type
        ub.price-list.obj-code
        v-host-code
      }
      define variable v-gds-code as integer   no-undo .

      { gbl/gds-code.i
        ub.price-list.artic
        ub.price-list.prod-type
        ub.price-list.prod-code
        v-gds-code
      }
      assign
        v-crsa-vat-pc = ub.price-list.vat-pc
        v-crsa-slt-pc = ub.price-list.slt-pc
      .

      if v-crsa-vat-pc = ?
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не задан налог товара на дату" skip
          "Налог" "НДС" skip
          "Переоценка" ub.price-doc.doc-num skip
          "Код товара" v-gds-code skip
          "Тип налога" {&vat-tax-code} skip
          "Дата" ub.price-doc.fact-date skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      if v-crsa-slt-pc = ?
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не задан налог товара на дату" skip
          "Налог" "НП" skip
          "Переоценка" ub.price-doc.doc-num skip
          "Код товара" v-gds-code skip
          "Тип налога" {&slt-tax-code} skip
          "Дата" ub.price-doc.fact-date skip
          view-as alert-box error .
        undo, return error return-value .
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

      run clcprtsl_calc-ttable in this-procedure
        (input false                /* paris-doc         */
        ,input true                 /* paris-cur         */
        ,input ?                    /* parroad-tax       */
        ,input ?                    /* parexcise         */
        ,input ?                    /* parvat-pc         */
        ,input ?                    /* parcons-vat-pc    */
        ,input ?                    /* parslt-pc         */
        ,input v-base-rate          /* parbase-rate      */
        ,input v-base-scale         /* parbase-scale     */
        ,input v-curr-r-b           /* parr-b            */
        ,input v-cur-price-sale     /* parcur-base       */
        ,input v-cur-price-road-tax /* parcur-road-tax   */
        ,input v-cur-price-excise   /* parcur-excise     */
        ,input v-crsa-vat-pc        /* parcur-vat-pc     */
        ,input v-cons-vat-pc        /* parcurcons-vat-pc */
        ,input v-crsa-slt-pc        /* parcurslt-pc      */
        ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при расчете учетных цен по партии"
          view-as alert-box error .
        undo, return error .
      end.

      define buffer buf_tt-allsum-line for tt-allsum-line .
      find first buf_tt-allsum-line
        where buf_tt-allsum-line.sum-type = {&sum-general-sign}
        no-error .
      if available buf_tt-allsum-line then do:
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
          v-other-base     = 0
          v-other-rubl     = 0
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
          "Расчет складского архива по товарам невозможен" skip
          "Переоценка" ub.price-list.doc-num skip
          "Артикул" ub.price-list.artic ub.price-list.prod-type ub.price-list.prod-code skip
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

      find first temp-stk-line
        where temp-stk-line.obj-type   = ub.price-list.obj-type
          and temp-stk-line.obj-code   = ub.price-list.obj-code
          and temp-stk-line.artic      = ub.price-list.artic
          and temp-stk-line.prod-type  = ub.price-list.prod-type
          and temp-stk-line.prod-code  = ub.price-list.prod-code
          and temp-stk-line.fact-order = v-stk-line-fact-order
          and temp-stk-line.sum-type   = {&arh-crsa}
          and temp-stk-line.cat-id     = {&root-cat-id}
        no-error .
      if not available temp-stk-line then do:
        create temp-stk-line .

        assign
          temp-stk-line.obj-type   = ub.price-list.obj-type
          temp-stk-line.obj-code   = ub.price-list.obj-code
          temp-stk-line.artic      = ub.price-list.artic
          temp-stk-line.prod-type  = ub.price-list.prod-type
          temp-stk-line.prod-code  = ub.price-list.prod-code
          temp-stk-line.fact-order = v-stk-line-fact-order
          temp-stk-line.sum-type   = {&arh-crsa}
          temp-stk-line.cat-id     = {&root-cat-id}
          temp-stk-line.fact-date    = ub.price-doc.fact-date
          temp-stk-line.shift-date   = ?
          temp-stk-line.shift-num    = 0
        .
      end.

      assign
        &scop FT1    temp-stk-line.new-
        &scop FTs1
        &scop FT2    = temp-stk-line.new-
        &scop FTs2
        &scop FT3    + v-
        &scop FTs3
        &scop FT4
        &scop FT5
        {&price-trio-list}
      .

      if temp-stk-line.new-fact-qnty <> temp-stk-line.fact-qnty then do:
        output stream slog to fix-arh.err append .
        export stream slog
          "error_price-list.doc-qnty"
          ub.price-list.doc-num
          ub.price-list.artic
          ub.price-list.prod-type
          ub.price-list.prod-code
          temp-stk-line.fact-qnty
          temp-stk-line.new-fact-qnty
          ub.price-list.doc-qnty
          .
        output stream slog close .

        /* todo - выводить сообщение об ошибке */
/*        message*/
/*          vss-workfile vss-revision vss-description skip*/
/*          "Ошибка в количестве товара по переоценке" skip*/
/*          "Переоценка" ub.price-list.doc-num skip*/
/*          "Товар" ub.price-list.artic ub.price-list.prod-type ub.price-list.prod-code skip*/
/*          "temp-stk-line.fact-qnty" temp-stk-line.fact-qnty skip*/
/*          "temp-stk-line.new-fact-qnty" temp-stk-line.new-fact-qnty skip*/
/*          view-as alert-box error .*/
/*        undo main-block, return error . /* --->>>--- */ */
      end.

      if v-shift-on then do:
        find first temp-shift-stk-line
          where temp-shift-stk-line.obj-type   = ub.price-list.obj-type
            and temp-shift-stk-line.obj-code   = ub.price-list.obj-code
            and temp-shift-stk-line.artic      = ub.price-list.artic
            and temp-shift-stk-line.prod-type  = ub.price-list.prod-type
            and temp-shift-stk-line.prod-code  = ub.price-list.prod-code
            and temp-shift-stk-line.fact-order = v-shift-stk-line-fact-order
            and temp-shift-stk-line.sum-type   = {&arh-crsa}
            and temp-shift-stk-line.cat-id     = {&root-cat-id}
          no-error .
        if not available temp-shift-stk-line then do:
          create temp-shift-stk-line .

          assign
            temp-shift-stk-line.obj-type   = ub.price-list.obj-type
            temp-shift-stk-line.obj-code   = ub.price-list.obj-code
            temp-shift-stk-line.artic      = ub.price-list.artic
            temp-shift-stk-line.prod-type  = ub.price-list.prod-type
            temp-shift-stk-line.prod-code  = ub.price-list.prod-code
            temp-shift-stk-line.fact-order = v-shift-stk-line-fact-order
            temp-shift-stk-line.sum-type   = {&arh-crsa}
            temp-shift-stk-line.cat-id     = {&root-cat-id}
            temp-shift-stk-line.fact-date    = ub.price-doc.fact-date
            temp-shift-stk-line.shift-date   = ub.price-doc.shift-date
            temp-shift-stk-line.shift-num    = ub.price-doc.shift-num
          .
        end.
        assign
          &scop FT1    temp-shift-stk-line.new-
          &scop FTs1
          &scop FT2    = temp-shift-stk-line.new-
          &scop FTs2
          &scop FT3    + v-
          &scop FTs3
          &scop FT4
          &scop FT5
          {&price-trio-list}
        .

        if temp-shift-stk-line.new-fact-qnty <> temp-shift-stk-line.fact-qnty then do:
          output stream slog to fix-arh.err append .
          export stream slog
            "error_price-list.doc-qnty"
            ub.price-list.doc-num
            ub.price-list.artic
            ub.price-list.prod-type
            ub.price-list.prod-code
            temp-shift-stk-line.fact-qnty
            temp-shift-stk-line.new-fact-qnty
            ub.price-list.doc-qnty
            .
          output stream slog close .

          /* todo - выводить сообщение об ошибке */
  /*        message*/
  /*          vss-workfile vss-revision vss-description skip*/
  /*          "Ошибка в количестве товара по переоценке" skip*/
  /*          "Переоценка" ub.price-list.doc-num skip*/
  /*          "Товар" ub.price-list.artic ub.price-list.prod-type ub.price-list.prod-code skip*/
  /*          "temp-shift-stk-line.fact-qnty" temp-shift-stk-line.fact-qnty skip*/
  /*          "temp-shift-stk-line.new-fact-qnty" temp-shift-stk-line.new-fact-qnty skip*/
  /*          view-as alert-box error .*/
  /*        undo main-block, return error . /* --->>>--- */ */
        end.
      end.

      assign
        ind  = ind + 1
      .
      if ind mod 10 = 0 then do:
        run cur-time in this-procedure ( output v-today
                                       , output v-time
                                       ).
        assign
          current-time = string(v-time - start-time, "HH:MM:SS")
        .
        if mFrameView
        then do:
     
           display
              ind
              ub.price-list.artic
              current-time
           with frame inf .
        end.
      end.
    end.
  end.

  run update-ot-line in this-procedure no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры update-ot-line" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error . /* --->>>--- */
  end.

  if v-shift-on then do:
    run update-shift-ot-line in this-procedure no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры update-shift-ot-line" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo main-block, return error . /* --->>>--- */
    end.
  end.

  run update-ot-tot in this-procedure no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры update-ot-tot" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error . /* --->>>--- */
  end.

  if v-shift-on then do:
    run update-shift-ot-tot in this-procedure no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры update-shift-ot-tot" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo main-block, return error . /* --->>>--- */
    end.
  end.

  run update-stk-table in this-procedure no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры update-stk-table" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error . /* --->>>--- */
  end.

  run show-action in this-procedure
    (input "Сохранение складского архива по товарам в базу данных"
    ).

  run store-temp-table in this-procedure no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры store-temp-table" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error . /* --->>>--- */
  end.

  if v-shift-on then do:
    run check-valid-archives in this-procedure
      no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при проверке целостности складского архива по товарам" skip
        "Дополнительная информация выведена в файл calc-apc.err" skip
        "Переоценка" ub.price-doc.doc-num skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo main-block, return error . /* --->>>--- */
    end.
  end.

  run show-action in this-procedure
    (input "Расчет документа закончен"
    ).
end.


procedure init-temp-tables :

  do
  on error undo, return error
  :

    define variable v-root-sum-type                  as character no-undo extent 2 .
    define variable v-line-sum-type                  as character no-undo extent 2 .
    define variable v-root-sum-type-ind-ext          as integer   no-undo .
    define variable v-prev-stk-tot-fact-order        like ub.stk-tot.fact-order     no-undo .
    define variable v-prev-stk-line-fact-order       like ub.stk-line.fact-order    no-undo .
    define variable v-prev-shift-stk-tot-fact-order  like ub.stk-tot.fact-order     no-undo .
    define variable v-prev-shift-stk-line-fact-order like ub.stk-line.fact-order    no-undo .

    define variable v-crsa-vat-pc like doc-line.vat-pc           no-undo.
    define variable v-crsa-slt-pc like doc-line.slt-pc           no-undo.
    define variable v-host-code   like sysconf.host-code         no-undo.

    { gbl/hostcode.i ub.price-doc.obj-type ub.price-doc.obj-code v-host-code }

    assign
      v-root-sum-type[1] = {&arh-crsa}
      v-root-sum-type[2] = {&arh-cgdt} + v-ext-doc-type
    .

    run show-action in this-procedure
      (input "Считывается оборот по документу"
      ).

    /* считываем предыдущее значение оборота по документу */
    find first ub.ot-tot no-lock
      where ub.ot-tot.doc-code = ub.price-doc.doc-num
      no-error .
    if available ub.ot-tot then do:
      for each ub.ot-tot no-lock
        where ub.ot-tot.doc-code = ub.price-doc.doc-num
      on error undo, return error
      :
        create temp-ot-tot .
        buffer-copy ub.ot-tot to temp-ot-tot
        assign
          &scop fp1   temp-ot-tot.new-
          &scop fps1
          &scop fp2   = ub.ot-tot.
          &scop fps2
          &scop fp3
          &scop fp4
          {&price-pair-list}
        .
      end.
    end.
    else do:
      create temp-ot-tot .
      assign
        temp-ot-tot.doc-code = ub.price-doc.doc-num
        temp-ot-tot.sum-type = {&arh-crsa}
        temp-ot-tot.cat-id   = {&root-cat-id}
        temp-ot-tot.ext-doc-type = v-ext-doc-type
        temp-ot-tot.obj-type     = ub.price-doc.obj-type
        temp-ot-tot.obj-code     = ub.price-doc.obj-code
        temp-ot-tot.fact-order   = v-ot-fact-order
      .
    end.

    if v-shift-on then do:
      /* считываем предыдущее значение оборота по документу */
      find first ub.ot-tot no-lock
        where ub.ot-tot.doc-code = ub.price-doc.doc-num
        no-error .
      if available ub.ot-tot then do:
        for each ub.ot-tot no-lock
          where ub.ot-tot.doc-code = ub.price-doc.doc-num
        on error undo, return error
        :
          create temp-shift-ot-tot .
          buffer-copy ub.ot-tot to temp-shift-ot-tot
          assign
            &scop fp1   temp-shift-ot-tot.new-
            &scop fps1
            &scop fp2   = ub.ot-tot.
            &scop fps2
            &scop fp3
            &scop fp4
            {&price-pair-list}
          .
        end.
      end.
      else do:
        create temp-shift-ot-tot .
        assign
          temp-shift-ot-tot.doc-code = ub.price-doc.doc-num
          temp-shift-ot-tot.sum-type = {&arh-crsa}
          temp-shift-ot-tot.cat-id   = {&root-cat-id}
          temp-shift-ot-tot.ext-doc-type = v-ext-doc-type
          temp-shift-ot-tot.obj-type     = ub.price-doc.obj-type
          temp-shift-ot-tot.obj-code     = ub.price-doc.obj-code
          temp-shift-ot-tot.fact-order   = v-ot-fact-order
        .
      end.
    end.

    run show-action in this-procedure
      (input "Считывается оборот по строкам документа"
      ).

    /* считываем предыдущее значение оборота по строке */
    for each ub.price-list no-lock
      where ub.price-list.doc-num = ub.price-doc.doc-num
        and ub.price-list.main-price = true
    on error undo, return error
    :
      { gbl/gdsat.i
        ub.price-list.artic
        ub.price-list.prod-type
        ub.price-list.prod-code
        "'gds-goods=request':u"
        l-gds-goods
        no-error
      }

      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении атрибута товара" skip
          "Артикул" ub.price-list.artic ub.price-list.prod-type ub.price-list.prod-code skip
          'gds-goods=request':u
          view-as alert-box error .
        undo, return error .
      end.

      if l-gds-goods then do:
        find first ub.ot-line no-lock
          where ub.ot-line.doc-code  = ub.price-list.doc-num
            and ub.ot-line.artic     = ub.price-list.artic
            and ub.ot-line.prod-type = ub.price-list.prod-type
            and ub.ot-line.prod-code = ub.price-list.prod-code
          no-error .
        if available ub.ot-line then do:
          for each ub.ot-line no-lock
            where ub.ot-line.doc-code  = ub.price-list.doc-num
              and ub.ot-line.artic     = ub.price-list.artic
              and ub.ot-line.prod-type = ub.price-list.prod-type
              and ub.ot-line.prod-code = ub.price-list.prod-code
          on error undo, return error
          :
            create temp-ot-line .
            buffer-copy ub.ot-line to temp-ot-line
              .
          end.
        end.
        else do:
          create temp-ot-line .
          assign
            temp-ot-line.doc-code  = ub.price-list.doc-num
            temp-ot-line.artic     = ub.price-list.artic
            temp-ot-line.prod-type = ub.price-list.prod-type
            temp-ot-line.prod-code = ub.price-list.prod-code
            temp-ot-line.sum-type  = v-root-sum-type[1]
          .
          assign
            v-crsa-vat-pc = ub.price-list.vat-pc
            v-crsa-slt-pc = ub.price-list.slt-pc
          .
          if v-crsa-vat-pc = ?
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Не задан налог товара на дату" skip
              "Налог" "НДС" skip
              "Переоценка" ub.price-doc.doc-num skip
              "Код товара" v-gds-code skip
              "Тип налога" {&vat-tax-code} skip
              "Дата" ub.price-doc.fact-date skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          if v-crsa-slt-pc = ?
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Не задан налог товара на дату" skip
              "Налог" "НП" skip
              "Переоценка" ub.price-doc.doc-num skip
              "Код товара" v-gds-code skip
              "Тип налога" {&slt-tax-code} skip
              "Дата" ub.price-doc.fact-date skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            temp-ot-line.cat-id = trim(string(v-crsa-vat-pc, ">99")) + ","
                                + trim(string(v-crsa-slt-pc, ">99"))
            temp-ot-line.ext-doc-type = v-ext-doc-type
            temp-ot-line.obj-type     = ub.price-doc.obj-type
            temp-ot-line.obj-code     = ub.price-doc.obj-code
            temp-ot-line.fact-order   = v-ot-fact-order
          .
        end.

        if v-shift-on then do:
          find first ub.ot-line no-lock
            where ub.ot-line.doc-code  = ub.price-list.doc-num
              and ub.ot-line.artic     = ub.price-list.artic
              and ub.ot-line.prod-type = ub.price-list.prod-type
              and ub.ot-line.prod-code = ub.price-list.prod-code
            no-error .
          if available ub.ot-line then do:
            for each ub.ot-line no-lock
              where ub.ot-line.doc-code  = ub.price-list.doc-num
                and ub.ot-line.artic     = ub.price-list.artic
                and ub.ot-line.prod-type = ub.price-list.prod-type
                and ub.ot-line.prod-code = ub.price-list.prod-code
            on error undo, return error
            :
              create temp-shift-ot-line .
              buffer-copy ub.ot-line to temp-shift-ot-line
                .
            end.
          end.
          else do:
            create temp-shift-ot-line .
            assign
              temp-shift-ot-line.doc-code  = ub.price-list.doc-num
              temp-shift-ot-line.artic     = ub.price-list.artic
              temp-shift-ot-line.prod-type = ub.price-list.prod-type
              temp-shift-ot-line.prod-code = ub.price-list.prod-code
              temp-shift-ot-line.sum-type  = v-root-sum-type[1]
            .
            assign
              v-crsa-vat-pc = ub.price-list.vat-pc
              v-crsa-slt-pc = ub.price-list.slt-pc
            .
            if v-crsa-vat-pc = ?
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Не задан налог товара на дату" skip
                "Налог" "НДС" skip
                "Переоценка" ub.price-doc.doc-num skip
                "Код товара" v-gds-code skip
                "Тип налога" {&vat-tax-code} skip
                "Дата" ub.price-doc.fact-date skip
                view-as alert-box error .
              undo, return error return-value .
            end.
            if v-crsa-slt-pc = ?
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Не задан налог товара на дату" skip
                "Налог" "НП" skip
                "Переоценка" ub.price-doc.doc-num skip
                "Код товара" v-gds-code skip
                "Тип налога" {&slt-tax-code} skip
                "Дата" ub.price-doc.fact-date skip
                view-as alert-box error .
              undo, return error return-value .
            end.
            assign
              temp-shift-ot-line.cat-id = trim(string(v-crsa-vat-pc, ">99")) + ","
                                        + trim(string(v-crsa-slt-pc, ">99"))
              temp-shift-ot-line.ext-doc-type = v-ext-doc-type
              temp-shift-ot-line.obj-type     = ub.price-doc.obj-type
              temp-shift-ot-line.obj-code     = ub.price-doc.obj-code
              temp-shift-ot-line.fact-order   = v-ot-fact-order
            .
          end.
        end.
      end.
    end.

    run show-action in this-procedure
      (input "Считывается остаток по объекту"
      ).

    /* считываем предыдущее (текущее) и все более поздние значения остатка по объекту */
    do v-root-sum-type-ind-ext = 1 to extent(v-root-sum-type)
    :
      assign
        v-prev-stk-tot-fact-order = 0
      .
      find last ub.stk-tot no-lock
        where ub.stk-tot.obj-type   = ub.price-doc.obj-type
          and ub.stk-tot.obj-code   = ub.price-doc.obj-code
          and ub.stk-tot.sum-type   = v-root-sum-type[v-root-sum-type-ind-ext]
          and ub.stk-tot.cat-id     = {&root-cat-id}
          and ub.stk-tot.fact-order <= v-stk-tot-fact-order
          and ub.stk-tot.shift-date = ?
        use-index category
        no-error .
      if available ub.stk-tot then do:
        assign
          v-prev-stk-tot-fact-order = ub.stk-tot.fact-order
        .
      end.
      if v-prev-stk-tot-fact-order > 0 then do:
        /* считывание текущего или предыдущего остатка */
        for each ub.stk-tot no-lock
          where ub.stk-tot.obj-type   = ub.price-doc.obj-type
            and ub.stk-tot.obj-code   = ub.price-doc.obj-code
            and ub.stk-tot.fact-order = v-prev-stk-tot-fact-order
            and ub.stk-tot.sum-type   begins v-root-sum-type[v-root-sum-type-ind-ext]
        on error undo, return error
        :
          create temp-stk-tot .
/*          buffer-copy ub.stk-tot to temp-stk-tot .*/
          &scop fp1   temp-stk-tot.
          &scop fp2   = ub.stk-tot.
          assign
            {&stk-tot-pair-list}
          .

          if v-stk-tot-fact-order = v-prev-stk-tot-fact-order then do:
            assign
              &scop fp1   temp-stk-tot.
              &scop fps1
              &scop fp2   = ub.stk-tot.
              &scop fps2
              &scop fp3
              &scop fp4
              {&price-pair-list}
            .
          end.

          assign
            temp-stk-tot.fact-order = v-stk-tot-fact-order
            temp-stk-tot.fact-date  = ub.price-doc.fact-date
            temp-stk-tot.shift-date = ?
            temp-stk-tot.shift-num  = 0
            &scop fp1   temp-stk-tot.new-
            &scop fps1
            &scop fp2   = ub.stk-tot.
            &scop fps2
            &scop fp3
            &scop fp4
            {&price-pair-list}
          .
        end.

        /* считывание всех более поздних остатков */
        for each ub.stk-tot no-lock
          where ub.stk-tot.obj-type   = ub.price-doc.obj-type
            and ub.stk-tot.obj-code   = ub.price-doc.obj-code
            and ub.stk-tot.fact-order > v-stk-tot-fact-order
            and ub.stk-tot.fact-order <= v-day-cut-fact-order
        on error undo, return error
        :
          if ub.stk-tot.sum-type   begins v-root-sum-type[v-root-sum-type-ind-ext]
          and ub.stk-tot.shift-date = ?
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Обнаружены более поздние данные складского архива по товарам" skip
              "Данная версия программы не рассчитана на закрытие переоценок задним числом" skip
              "Существует складской архив по товарам" skip
              "ub.stk-tot.obj-type"      ub.stk-tot.obj-type    skip
              "ub.stk-tot.obj-code"      ub.stk-tot.obj-code    skip
              "ub.stk-tot.fact-order"    ub.stk-tot.fact-order  skip
              "ub.stk-tot.sum-type"      ub.stk-tot.sum-type    skip
              "v-stk-tot-fact-order"     v-stk-tot-fact-order   skip
              "Документ переоценки"      ub.price-doc.doc-num   skip
              "Объект"                   ub.price-doc.obj-type ub.price-doc.obj-code skip
              "Дата закрытия переоценки" ub.price-doc.fact-date skip
              "Смена переоценки"         ub.price-doc.shift-date "Номер" ub.price-doc.shift-num skip
              view-as alert-box error .
            undo, return error .

    /*        create temp-stk-tot .*/
    /*        buffer-copy ub.stk-tot to temp-stk-tot*/
    /*        assign*/
    /*          &scop fp1   temp-stk-tot.new-*/
    /*          &scop fps1*/
    /*          &scop fp2   = ub.stk-tot.*/
    /*          &scop fps2*/
    /*          &scop fp3*/
    /*          &scop fp4*/
    /*          {&price-pair-list}*/
    /*        .*/
          end.
        end.
      end.
      else do:
        create temp-stk-tot.
        assign
          temp-stk-tot.obj-type   = ub.price-doc.obj-type
          temp-stk-tot.obj-code   = ub.price-doc.obj-code
          temp-stk-tot.fact-order = v-stk-tot-fact-order
          temp-stk-tot.sum-type   = v-root-sum-type[v-root-sum-type-ind-ext]
          temp-stk-tot.cat-id     = {&root-cat-id}
          temp-stk-tot.fact-date  = ub.price-doc.fact-date
          temp-stk-tot.shift-date = ?
          temp-stk-tot.shift-num  = 0
        .
      end.

      if v-shift-on then do:
        assign
          v-prev-shift-stk-tot-fact-order = 0
        .

        find last ub.stk-tot no-lock
          where ub.stk-tot.obj-type   = ub.price-doc.obj-type
            and ub.stk-tot.obj-code   = ub.price-doc.obj-code
            and ub.stk-tot.sum-type   = v-root-sum-type[v-root-sum-type-ind-ext]
            and ub.stk-tot.cat-id     = {&root-cat-id}
            and ub.stk-tot.fact-order <= v-shift-stk-tot-fact-order
            and ub.stk-tot.shift-date <> ?
          use-index category
          no-error .
        if available ub.stk-tot then do:
          assign
            v-prev-shift-stk-tot-fact-order = ub.stk-tot.fact-order
          .
        end.

        if v-prev-shift-stk-tot-fact-order > 0 then do:
          /* считывание текущего или предыдущего остатка */
          for each ub.stk-tot no-lock
            where ub.stk-tot.obj-type   = ub.price-doc.obj-type
              and ub.stk-tot.obj-code   = ub.price-doc.obj-code
              and ub.stk-tot.fact-order = v-prev-shift-stk-tot-fact-order
              and ub.stk-tot.sum-type   begins v-root-sum-type[v-root-sum-type-ind-ext]
          on error undo, return error
          :
            create temp-shift-stk-tot .
/*            buffer-copy ub.stk-tot to temp-shift-stk-tot.*/
            &scop fp1   temp-shift-stk-tot.
            &scop fp2   = ub.stk-tot.
            assign
              {&stk-tot-pair-list}
            .

            if v-shift-stk-tot-fact-order = v-prev-shift-stk-tot-fact-order then do:
              assign
                &scop fp1   temp-shift-stk-tot.
                &scop fps1
                &scop fp2   = ub.stk-tot.
                &scop fps2
                &scop fp3
                &scop fp4
                {&price-pair-list}
              .
            end.

            assign
              temp-shift-stk-tot.fact-order = v-shift-stk-tot-fact-order
              temp-shift-stk-tot.fact-date  = ub.price-doc.fact-date
              temp-shift-stk-tot.shift-date = ub.price-doc.shift-date
              temp-shift-stk-tot.shift-num  = ub.price-doc.shift-num
              &scop fp1   temp-shift-stk-tot.new-
              &scop fps1
              &scop fp2   = ub.stk-tot.
              &scop fps2
              &scop fp3
              &scop fp4
              {&price-pair-list}
            .
          end.

          /* считывание всех более поздних остатков */
          for each ub.stk-tot no-lock
            where ub.stk-tot.obj-type   = ub.price-doc.obj-type
              and ub.stk-tot.obj-code   = ub.price-doc.obj-code
              and ub.stk-tot.fact-order > v-shift-stk-tot-fact-order
              and ub.stk-tot.fact-order <= v-shift-cut-fact-order
          on error undo, return error
          :
            if  ub.stk-tot.sum-type   begins v-root-sum-type[v-root-sum-type-ind-ext]
            and ub.stk-tot.shift-date <> ?
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Обнаружены более поздние данные складского архива по товарам" skip
                "Данная версия программы не рассчитана на закрытие переоценок задним числом" skip
                "Существует складской архив по товарам" skip
                "ub.stk-tot.obj-type"      ub.stk-tot.obj-type    skip
                "ub.stk-tot.obj-code"      ub.stk-tot.obj-code    skip
                "ub.stk-tot.fact-order"    ub.stk-tot.fact-order  skip
                "ub.stk-tot.sum-type"      ub.stk-tot.sum-type    skip
                "v-shift-stk-tot-fact-order"     v-shift-stk-tot-fact-order   skip
                "Документ переоценки"      ub.price-doc.doc-num   skip
                "Объект"                   ub.price-doc.obj-type ub.price-doc.obj-code skip
                "Дата закрытия переоценки" ub.price-doc.fact-date skip
                "Смена переоценки"         ub.price-doc.shift-date "Номер" ub.price-doc.shift-num skip
                view-as alert-box error .
              undo, return error .

      /*        create temp-shift-stk-tot .*/
      /*        buffer-copy ub.stk-tot to temp-shift-stk-tot*/
      /*        assign*/
      /*          &scop fp1   temp-shift-stk-tot.new-*/
      /*          &scop fps1*/
      /*          &scop fp2   = ub.stk-tot.*/
      /*          &scop fps2*/
      /*          &scop fp3*/
      /*          &scop fp4*/
      /*          {&price-pair-list}*/
      /*        .*/
            end.
          end.
        end.
        else do:
          create temp-shift-stk-tot.
          assign
            temp-shift-stk-tot.obj-type   = ub.price-doc.obj-type
            temp-shift-stk-tot.obj-code   = ub.price-doc.obj-code
            temp-shift-stk-tot.fact-order = v-shift-stk-tot-fact-order
            temp-shift-stk-tot.sum-type   = v-root-sum-type[v-root-sum-type-ind-ext]
            temp-shift-stk-tot.cat-id     = {&root-cat-id}
            temp-shift-stk-tot.fact-date  = ub.price-doc.fact-date
            temp-shift-stk-tot.shift-date = ub.price-doc.shift-date
            temp-shift-stk-tot.shift-num  = ub.price-doc.shift-num
          .
        end.
      end.
    end.

    run show-action in this-procedure
      (input "Считывается остаток по товарам документа"
      ).

    /* считываем предыдущее (текущее) и все более поздние значения остатка по строке */
    for each ub.price-list no-lock
      where ub.price-list.doc-num = ub.price-doc.doc-num
        and ub.price-list.main-price = true
    on error undo, return error
    :
      { gbl/gdsat.i
        ub.price-list.artic
        ub.price-list.prod-type
        ub.price-list.prod-code
        "'gds-goods=request':u"
        l-gds-goods
        no-error
      }
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении атрибута товара" skip
          "Артикул" ub.price-list.artic ub.price-list.prod-type ub.price-list.prod-code skip
          'gds-goods=request':u
          view-as alert-box error .
        undo, return error .
      end.

      if l-gds-goods then do:
        do v-root-sum-type-ind-ext = 1 to extent(v-root-sum-type)
        :
          find last ub.stk-line no-lock
            where ub.stk-line.obj-type   = ub.price-list.obj-type
              and ub.stk-line.obj-code   = ub.price-list.obj-code
              and ub.stk-line.artic      = ub.price-list.artic
              and ub.stk-line.prod-type  = ub.price-list.prod-type
              and ub.stk-line.prod-code  = ub.price-list.prod-code
              and ub.stk-line.sum-type   = v-root-sum-type[v-root-sum-type-ind-ext]
    /*          and ub.stk-line.cat-id     = {&root-cat-id}*/
              and ub.stk-line.fact-order <= v-stk-line-fact-order
              and ub.stk-line.shift-date = ?
            use-index category
            no-error .
          if available ub.stk-line then do:
            assign
              v-prev-stk-line-fact-order = ub.stk-line.fact-order
            .
            /* считывание текущего или предыдущего остатка */
            for each ub.stk-line no-lock
              where ub.stk-line.obj-type   = ub.price-list.obj-type
                and ub.stk-line.obj-code   = ub.price-list.obj-code
                and ub.stk-line.artic      = ub.price-list.artic
                and ub.stk-line.prod-type  = ub.price-list.prod-type
                and ub.stk-line.prod-code  = ub.price-list.prod-code
                and ub.stk-line.fact-order = v-prev-stk-line-fact-order
                and ub.stk-line.sum-type   begins v-root-sum-type[v-root-sum-type-ind-ext]
            on error undo, return error
            :
              create temp-stk-line .
              buffer-copy ub.stk-line to temp-stk-line
              assign
                temp-stk-line.fact-order = v-stk-line-fact-order
                temp-stk-line.fact-date  = ub.price-doc.fact-date
                temp-stk-line.shift-date = ?
                temp-stk-line.shift-num  = 0
              .
              if v-root-sum-type-ind-ext = 2 then do:
                /* поля new надо заполнять только для нарастающего итога */
                assign
                  &scop fp1   temp-stk-line.new-
                  &scop fps1
                  &scop fp2   = ub.stk-line.
                  &scop fps2
                  &scop fp3
                  &scop fp4
                  {&price-pair-list}
                .
              end.
            end.

            /* считывание всех более поздних остатков */
            for each ub.stk-line no-lock
              where ub.stk-line.obj-type   = ub.price-list.obj-type
                and ub.stk-line.obj-code   = ub.price-list.obj-code
                and ub.stk-line.artic      = ub.price-list.artic
                and ub.stk-line.prod-type  = ub.price-list.prod-type
                and ub.stk-line.prod-code  = ub.price-list.prod-code
                and ub.stk-line.fact-order > v-stk-line-fact-order
                and ub.stk-line.fact-order <= v-day-cut-fact-order
            on error undo, return error
            :
              if ub.stk-line.sum-type   begins v-root-sum-type[v-root-sum-type-ind-ext]
              and ub.stk-line.shift-date = ?
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Обнаружены более поздние данные складского архива по товарам" skip
                  "Данная версия программы не рассчитана на закрытие переоценок задним числом" skip
                  "ub.stk-line.obj-type"     ub.stk-line.obj-type   skip
                  "ub.stk-line.obj-code"     ub.stk-line.obj-code   skip
                  "ub.stk-line.artic"        ub.stk-line.artic      skip
                  "ub.stk-line.prod-type"    ub.stk-line.prod-type  skip
                  "ub.stk-line.prod-code"    ub.stk-line.prod-code  skip
                  "ub.stk-line.fact-order"   ub.stk-line.fact-order skip
                  "ub.stk-line.sum-type"     ub.stk-line.sum-type   skip
                  "Документ переоценки"      ub.price-doc.doc-num   skip
                  "Объект"                   ub.price-doc.obj-type ub.price-doc.obj-code skip
                  "Дата закрытия переоценки" ub.price-doc.fact-date skip
                  "Артикул"                  ub.price-list.artic ub.price-list.prod-type ub.price-list.prod-code skip
                  "Смена переоценки"         ub.price-doc.shift-date "Номер" ub.price-doc.shift-num skip
                  view-as alert-box error .
                undo, return error .

    /*            create temp-stk-line .*/
    /*            buffer-copy ub.stk-line to temp-stk-line*/
    /*            assign*/
    /*              &scop fp1   temp-stk-line.new-*/
    /*              &scop fps1*/
    /*              &scop fp2   = ub.stk-line.*/
    /*              &scop fps2*/
    /*              &scop fp3*/
    /*              &scop fp4*/
    /*              {&price-pair-list}*/
    /*            .*/
              end.
            end.
          end.
          else do:
            create temp-stk-line.
            assign
              temp-stk-line.obj-type   = ub.price-list.obj-type
              temp-stk-line.obj-code   = ub.price-list.obj-code
              temp-stk-line.artic      = ub.price-list.artic
              temp-stk-line.prod-type  = ub.price-list.prod-type
              temp-stk-line.prod-code  = ub.price-list.prod-code
              temp-stk-line.fact-order = v-stk-line-fact-order
              temp-stk-line.sum-type   = v-root-sum-type[v-root-sum-type-ind-ext]
              temp-stk-line.cat-id     = {&root-cat-id}
              temp-stk-line.fact-date  = ub.price-doc.fact-date
              temp-stk-line.shift-date = ?
              temp-stk-line.shift-num  = 0
            .
          end.

          if v-shift-on then do:
            assign
              v-prev-shift-stk-line-fact-order = 0
            .
            find last ub.stk-line no-lock
              where ub.stk-line.obj-type   = ub.price-list.obj-type
                and ub.stk-line.obj-code   = ub.price-list.obj-code
                and ub.stk-line.artic      = ub.price-list.artic
                and ub.stk-line.prod-type  = ub.price-list.prod-type
                and ub.stk-line.prod-code  = ub.price-list.prod-code
                and ub.stk-line.sum-type   = v-root-sum-type[v-root-sum-type-ind-ext]
      /*          and ub.stk-line.cat-id     = {&root-cat-id}*/
                and ub.stk-line.fact-order <= v-shift-stk-line-fact-order
                and ub.stk-line.shift-date <> ?
              use-index category
              no-error .
            if available ub.stk-line then do:
              assign
                v-prev-shift-stk-line-fact-order = ub.stk-line.fact-order
              .
            end.
            if v-prev-shift-stk-line-fact-order > 0 then do:
              /* считывание текущего или предыдущего остатка */
              for each ub.stk-line no-lock
                where ub.stk-line.obj-type   = ub.price-list.obj-type
                  and ub.stk-line.obj-code   = ub.price-list.obj-code
                  and ub.stk-line.artic      = ub.price-list.artic
                  and ub.stk-line.prod-type  = ub.price-list.prod-type
                  and ub.stk-line.prod-code  = ub.price-list.prod-code
                  and ub.stk-line.fact-order = v-prev-shift-stk-line-fact-order
                  and ub.stk-line.sum-type   begins v-root-sum-type[v-root-sum-type-ind-ext]
              on error undo, return error
              :
                create temp-shift-stk-line .
                buffer-copy ub.stk-line to temp-shift-stk-line
                assign
                  temp-shift-stk-line.fact-order = v-shift-stk-line-fact-order
                  temp-shift-stk-line.fact-date  = ub.price-doc.fact-date
                  temp-shift-stk-line.shift-date = ub.price-doc.shift-date
                  temp-shift-stk-line.shift-num  = ub.price-doc.shift-num
                .
                if v-root-sum-type-ind-ext = 2 then do:
                  /* поля new надо заполнять только для нарастающего итога */
                  assign
                    &scop fp1   temp-shift-stk-line.new-
                    &scop fps1
                    &scop fp2   = ub.stk-line.
                    &scop fps2
                    &scop fp3
                    &scop fp4
                    {&price-pair-list}
                  .
                end.
              end.

              /* считывание всех более поздних остатков */
              for each ub.stk-line no-lock
                where ub.stk-line.obj-type   = ub.price-list.obj-type
                  and ub.stk-line.obj-code   = ub.price-list.obj-code
                  and ub.stk-line.artic      = ub.price-list.artic
                  and ub.stk-line.prod-type  = ub.price-list.prod-type
                  and ub.stk-line.prod-code  = ub.price-list.prod-code
                  and ub.stk-line.fact-order > v-shift-stk-line-fact-order
                  and ub.stk-line.fact-order <= v-shift-cut-fact-order
              on error undo, return error
              :
                if ub.stk-line.sum-type   begins v-root-sum-type[v-root-sum-type-ind-ext]
                and ub.stk-line.shift-date <> ?
                then do:
                  message
                    vss-workfile vss-revision vss-description skip
                    "Обнаружены более поздние данные складского архива по товарам" skip
                    "Данная версия программы не рассчитана на закрытие переоценок задним числом" skip
                    "ub.stk-line.obj-type"     ub.stk-line.obj-type   skip
                    "ub.stk-line.obj-code"     ub.stk-line.obj-code   skip
                    "ub.stk-line.artic"        ub.stk-line.artic      skip
                    "ub.stk-line.prod-type"    ub.stk-line.prod-type  skip
                    "ub.stk-line.prod-code"    ub.stk-line.prod-code  skip
                    "ub.stk-line.fact-order"   ub.stk-line.fact-order skip
                    "ub.stk-line.sum-type"     ub.stk-line.sum-type   skip
                    "Документ переоценки"      ub.price-doc.doc-num   skip
                    "Объект"                   ub.price-doc.obj-type ub.price-doc.obj-code skip
                    "Дата закрытия переоценки" ub.price-doc.fact-date skip
                    "Артикул"                  ub.price-list.artic ub.price-list.prod-type ub.price-list.prod-code skip
                    "Смена переоценки"         ub.price-doc.shift-date "Номер" ub.price-doc.shift-num skip
                    view-as alert-box error .
                  undo, return error .

      /*            create temp-shift-stk-line .*/
      /*            buffer-copy ub.stk-line to temp-shift-stk-line*/
      /*            assign*/
      /*              &scop fp1   temp-shift-stk-line.new-*/
      /*              &scop fps1*/
      /*              &scop fp2   = ub.stk-line.*/
      /*              &scop fps2*/
      /*              &scop fp3*/
      /*              &scop fp4*/
      /*              {&price-pair-list}*/
      /*            .*/
                end.
              end.
            end.
            else do:
              create temp-shift-stk-line.
              assign
                temp-shift-stk-line.obj-type   = ub.price-list.obj-type
                temp-shift-stk-line.obj-code   = ub.price-list.obj-code
                temp-shift-stk-line.artic      = ub.price-list.artic
                temp-shift-stk-line.prod-type  = ub.price-list.prod-type
                temp-shift-stk-line.prod-code  = ub.price-list.prod-code
                temp-shift-stk-line.fact-order = v-shift-stk-line-fact-order
                temp-shift-stk-line.sum-type   = v-root-sum-type[v-root-sum-type-ind-ext]
                temp-shift-stk-line.cat-id     = {&root-cat-id}
                temp-shift-stk-line.fact-date  = ub.price-doc.fact-date
                temp-shift-stk-line.shift-date = ub.price-doc.shift-date
                temp-shift-stk-line.shift-num  = ub.price-doc.shift-num
              .
            end.
          end.
        end.
      end.
    end.
  end.
end procedure. /* init-temp-tables */





procedure update-ot-line :

  define variable v-crsa-vat-pc like doc-line.vat-pc   no-undo .
  define variable v-crsa-slt-pc like doc-line.slt-pc   no-undo .
  define variable v-host-code   like sysconf.host-code no-undo .

  define buffer buf_goods for ub.goods .
  define buffer buf_price-list for ub.price-list .

  do
  on error undo, return error
  :

    { gbl/hostcode.i ub.price-doc.obj-type ub.price-doc.obj-code v-host-code }

    for each temp-stk-line
      where (
      &scop fp1   temp-stk-line.
      &scop fps1
      &scop fp2   <> temp-stk-line.new-
      &scop fps2
      &scop fp3
      &scop fp4   or
      {&price-pair-list}
            )
        and temp-stk-line.sum-type = {&arh-crsa}
    on error undo, return error
    :
      find first temp-ot-line
        where temp-ot-line.doc-code  = ub.price-doc.doc-num
          and temp-ot-line.artic     = temp-stk-line.artic
          and temp-ot-line.prod-type = temp-stk-line.prod-type
          and temp-ot-line.prod-code = temp-stk-line.prod-code
          and temp-ot-line.sum-type  = temp-stk-line.sum-type
  /*        and temp-ot-line.cat-id    = temp-stk-line.cat-id*/
        no-error .
      if not available temp-ot-line then do:
        create temp-ot-line .
        assign
          temp-ot-line.doc-code  = ub.price-doc.doc-num
          temp-ot-line.artic     = temp-stk-line.artic
          temp-ot-line.prod-type = temp-stk-line.prod-type
          temp-ot-line.prod-code = temp-stk-line.prod-code
          temp-ot-line.sum-type  = temp-stk-line.sum-type
        .
        find first buf_goods no-lock
          where buf_goods.artic     = temp-stk-line.artic
            and buf_goods.prod-type = temp-stk-line.prod-type
            and buf_goods.prod-code = temp-stk-line.prod-code
          .

        /* находим налоги для товара */
        find first buf_price-list no-lock
          where buf_price-list.doc-num    = ub.price-doc.doc-num
            and buf_price-list.main-price = true
            and buf_price-list.artic      = temp-stk-line.artic
            and buf_price-list.prod-type  = temp-stk-line.prod-type
            and buf_price-list.prod-code  = temp-stk-line.prod-code
          .
        assign
          v-crsa-vat-pc = buf_price-list.vat-pc
          v-crsa-slt-pc = buf_price-list.slt-pc
        .
        if v-crsa-vat-pc = ?
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Не задан налог товара на дату" skip
            "Налог" "НДС" skip
            "Переоценка" ub.price-doc.doc-num skip
            "Код товара" buf_goods.gds-code skip
            "Тип налога" {&vat-tax-code} skip
            "Дата" ub.price-doc.fact-date skip
            view-as alert-box error .
          undo, return error return-value .
        end.

        if v-crsa-slt-pc = ?
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Не задан налог товара на дату" skip
            "Налог" "НП" skip
            "Переоценка" ub.price-doc.doc-num skip
            "Код товара" buf_goods.gds-code skip
            "Тип налога" {&slt-tax-code} skip
            "Дата" ub.price-doc.fact-date skip
            view-as alert-box error .
          undo, return error return-value .
        end.

        assign
          temp-ot-line.cat-id    = trim(string(v-crsa-vat-pc, ">99")) + ","
                                + trim(string(v-crsa-slt-pc, ">99"))
          temp-ot-line.ext-doc-type = v-ext-doc-type
          temp-ot-line.obj-type     = ub.price-doc.obj-type
          temp-ot-line.obj-code     = ub.price-doc.obj-code
          temp-ot-line.fact-order   = v-ot-fact-order
        .
      end.
      assign
        &scop fq1    temp-ot-line.new-
        &scop fqs1
        &scop fq2    = temp-ot-line.new-
        &scop fqs2
        &scop fq3    + temp-stk-line.new-
        &scop fqs3
        &scop fq4    - temp-stk-line.
        &scop fqs4
        &scop fq5
        &scop fq6
        {&price-quadro-list}
      .
    end.
  end.

end procedure. /* update-ot-line */


procedure update-shift-ot-line :

  define variable v-crsa-vat-pc like doc-line.vat-pc   no-undo .
  define variable v-crsa-slt-pc like doc-line.slt-pc   no-undo .
  define variable v-host-code   like sysconf.host-code no-undo .

  define buffer buf_goods for ub.goods .
  define buffer buf_price-list for ub.price-list .

  do
  on error undo, return error
  :

    { gbl/hostcode.i ub.price-doc.obj-type ub.price-doc.obj-code v-host-code }

    for each temp-shift-stk-line
      where (
      &scop fp1   temp-shift-stk-line.
      &scop fps1
      &scop fp2   <> temp-shift-stk-line.new-
      &scop fps2
      &scop fp3
      &scop fp4   or
      {&price-pair-list}
            )
        and temp-shift-stk-line.sum-type = {&arh-crsa}
    on error undo, return error
    :
      find first temp-shift-ot-line
        where temp-shift-ot-line.doc-code  = ub.price-doc.doc-num
          and temp-shift-ot-line.artic     = temp-shift-stk-line.artic
          and temp-shift-ot-line.prod-type = temp-shift-stk-line.prod-type
          and temp-shift-ot-line.prod-code = temp-shift-stk-line.prod-code
          and temp-shift-ot-line.sum-type  = temp-shift-stk-line.sum-type
  /*        and temp-shift-ot-line.cat-id    = temp-shift-stk-line.cat-id*/
        no-error .
      if not available temp-shift-ot-line then do:
        create temp-shift-ot-line .
        assign
          temp-shift-ot-line.doc-code  = ub.price-doc.doc-num
          temp-shift-ot-line.artic     = temp-shift-stk-line.artic
          temp-shift-ot-line.prod-type = temp-shift-stk-line.prod-type
          temp-shift-ot-line.prod-code = temp-shift-stk-line.prod-code
          temp-shift-ot-line.sum-type  = temp-shift-stk-line.sum-type
        .
        find first buf_goods no-lock
          where buf_goods.artic     = temp-shift-stk-line.artic
            and buf_goods.prod-type = temp-shift-stk-line.prod-type
            and buf_goods.prod-code = temp-shift-stk-line.prod-code
          .
        /* находим налоги для товара */
        find first buf_price-list no-lock
          where buf_price-list.doc-num    = ub.price-doc.doc-num
            and buf_price-list.main-price = true
            and buf_price-list.artic      = temp-stk-line.artic
            and buf_price-list.prod-type  = temp-stk-line.prod-type
            and buf_price-list.prod-code  = temp-stk-line.prod-code
          .
        assign
          v-crsa-vat-pc = buf_price-list.vat-pc
          v-crsa-slt-pc = buf_price-list.slt-pc
        .
        if v-crsa-vat-pc = ?
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Не задан налог товара на дату" skip
            "Налог" "НДС" skip
            "Переоценка" ub.price-doc.doc-num skip
            "Код товара" buf_goods.gds-code skip
            "Тип налога" {&vat-tax-code} skip
            "Дата" ub.price-doc.fact-date skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        if v-crsa-slt-pc = ?
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Не задан налог товара на дату" skip
            "Налог" "НП" skip
            "Переоценка" ub.price-doc.doc-num skip
            "Код товара" buf_goods.gds-code skip
            "Тип налога" {&slt-tax-code} skip
            "Дата" ub.price-doc.fact-date skip
            view-as alert-box error .
          undo, return error return-value .
        end.

        assign
          temp-shift-ot-line.cat-id = trim(string(v-crsa-vat-pc, ">99")) + ","
                                    + trim(string(v-crsa-slt-pc, ">99"))
          temp-shift-ot-line.ext-doc-type = v-ext-doc-type
          temp-shift-ot-line.obj-type     = ub.price-doc.obj-type
          temp-shift-ot-line.obj-code     = ub.price-doc.obj-code
          temp-shift-ot-line.fact-order   = v-ot-fact-order
        .
      end.
      assign
        &scop fq1    temp-shift-ot-line.new-
        &scop fqs1
        &scop fq2    = temp-shift-ot-line.new-
        &scop fqs2
        &scop fq3    + temp-shift-stk-line.new-
        &scop fqs3
        &scop fq4    - temp-shift-stk-line.
        &scop fqs4
        &scop fq5
        &scop fq6
        {&price-quadro-list}
      .
    end.
  end.

end procedure. /* update-shift-ot-line */


procedure update-ot-tot :

  for each temp-ot-line
    where (
    &scop fp1   temp-ot-line.
    &scop fps1
    &scop fp2   <> temp-ot-line.new-
    &scop fps2
    &scop fp3
    &scop fp4   or
    {&price-pair-list}
          )
  on error undo, return error
  :
    case temp-ot-line.sum-type :
      when {&arh-crsa} then do:
        assign
          v-sum-type[1] = temp-ot-line.sum-type
          v-cat-id[1]   = {&root-cat-id}
          v-sum-type[2] = temp-ot-line.sum-type + {&arh-VAT}
          v-cat-id[2]   = entry(1, temp-ot-line.cat-id) + "," + {&single-cat-id}
          v-sum-type[3] = temp-ot-line.sum-type + {&arh-SLT}
          v-cat-id[3]   = {&single-cat-id} + "," + entry(2, temp-ot-line.cat-id)
          v-sum-type[4] = temp-ot-line.sum-type + {&arh-VATSLT}
          v-cat-id[4]   = temp-ot-line.cat-id
        .

        do ind-ext = 1 to 4
        :
          find first temp-ot-tot
            where temp-ot-tot.doc-code = temp-ot-line.doc-code
              and temp-ot-tot.sum-type = v-sum-type[ind-ext]
              and temp-ot-tot.cat-id   = v-cat-id[ind-ext]
            no-error .
          if not available temp-ot-tot then do:
            create temp-ot-tot .
            assign
              temp-ot-tot.doc-code = temp-ot-line.doc-code
              temp-ot-tot.sum-type = v-sum-type[ind-ext]
              temp-ot-tot.cat-id   = v-cat-id[ind-ext]
              temp-ot-tot.ext-doc-type = v-ext-doc-type
              temp-ot-tot.obj-type     = ub.price-doc.obj-type
              temp-ot-tot.obj-code     = ub.price-doc.obj-code
              temp-ot-tot.fact-order   = v-ot-fact-order
            .
          end.
          assign
            &scop fq1    temp-ot-tot.new-
            &scop fqs1
            &scop fq2    = temp-ot-tot.new-
            &scop fqs2
            &scop fq3    + temp-ot-line.new-
            &scop fqs3
            &scop fq4    - temp-ot-line.
            &scop fqs4
            &scop fq5
            &scop fq6
            {&price-quadro-list}
          .
        end.
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестный тип оборота по строке" temp-ot-line.sum-type skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
  end.

end procedure. /* update-ot-tot */


procedure update-shift-ot-tot :

  for each temp-shift-ot-line
    where (
    &scop fp1   temp-shift-ot-line.
    &scop fps1
    &scop fp2   <> temp-shift-ot-line.new-
    &scop fps2
    &scop fp3
    &scop fp4   or
    {&price-pair-list}
          )
  on error undo, return error
  :
    case temp-shift-ot-line.sum-type :
      when {&arh-crsa} then do:
        assign
          v-sum-type[1] = temp-shift-ot-line.sum-type
          v-cat-id[1]   = {&root-cat-id}
          v-sum-type[2] = temp-shift-ot-line.sum-type + {&arh-VAT}
          v-cat-id[2]   = entry(1, temp-shift-ot-line.cat-id) + "," + {&single-cat-id}
          v-sum-type[3] = temp-shift-ot-line.sum-type + {&arh-SLT}
          v-cat-id[3]   = {&single-cat-id} + "," + entry(2, temp-shift-ot-line.cat-id)
          v-sum-type[4] = temp-shift-ot-line.sum-type + {&arh-VATSLT}
          v-cat-id[4]   = temp-shift-ot-line.cat-id
        .

        do ind-ext = 1 to 4
        :
          find first temp-shift-ot-tot
            where temp-shift-ot-tot.doc-code = temp-shift-ot-line.doc-code
              and temp-shift-ot-tot.sum-type = v-sum-type[ind-ext]
              and temp-shift-ot-tot.cat-id   = v-cat-id[ind-ext]
            no-error .
          if not available temp-shift-ot-tot then do:
            create temp-shift-ot-tot .
            assign
              temp-shift-ot-tot.doc-code = temp-shift-ot-line.doc-code
              temp-shift-ot-tot.sum-type = v-sum-type[ind-ext]
              temp-shift-ot-tot.cat-id   = v-cat-id[ind-ext]
              temp-shift-ot-tot.ext-doc-type = v-ext-doc-type
              temp-shift-ot-tot.obj-type     = ub.price-doc.obj-type
              temp-shift-ot-tot.obj-code     = ub.price-doc.obj-code
              temp-shift-ot-tot.fact-order   = v-ot-fact-order
            .
          end.
          assign
            &scop fq1    temp-shift-ot-tot.new-
            &scop fqs1
            &scop fq2    = temp-shift-ot-tot.new-
            &scop fqs2
            &scop fq3    + temp-shift-ot-line.new-
            &scop fqs3
            &scop fq4    - temp-shift-ot-line.
            &scop fqs4
            &scop fq5
            &scop fq6
            {&price-quadro-list}
          .
        end.
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестный тип оборота по строке" temp-shift-ot-line.sum-type skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
  end.

end procedure. /* update-shift-ot-tot */



procedure update-stk-table :

  define buffer root-temp-stk-tot        for temp-stk-tot  .
  define buffer root-temp-stk-line       for temp-stk-line .
  define buffer root-temp-shift-stk-tot  for temp-shift-stk-tot  .
  define buffer root-temp-shift-stk-line for temp-shift-stk-line .

  for each temp-ot-tot
    where temp-ot-tot.sum-type begins {&arh-crsa}
      and (
    &scop fp1   temp-ot-tot.
    &scop fps1
    &scop fp2   <> temp-ot-tot.new-
    &scop fps2
    &scop fp3
    &scop fp4   or
    {&price-pair-list}
          )
  on error undo, return error
  :
    for each root-temp-stk-tot
      where root-temp-stk-tot.obj-type = temp-ot-tot.obj-type
        and root-temp-stk-tot.obj-code = temp-ot-tot.obj-code
        and root-temp-stk-tot.sum-type = {&arh-crsa}
        and root-temp-stk-tot.cat-id   = {&root-cat-id}
    on error undo, return error
    :
      find first temp-stk-tot
        where temp-stk-tot.obj-type   = temp-ot-tot.obj-type
          and temp-stk-tot.obj-code   = temp-ot-tot.obj-code
          and temp-stk-tot.fact-order = root-temp-stk-tot.fact-order
          and temp-stk-tot.sum-type   = temp-ot-tot.sum-type
          and temp-stk-tot.cat-id     = temp-ot-tot.cat-id
        no-error .
      if not available temp-stk-tot then do:
        create temp-stk-tot .
        assign
          temp-stk-tot.obj-type   = temp-ot-tot.obj-type
          temp-stk-tot.obj-code   = temp-ot-tot.obj-code
          temp-stk-tot.fact-order = root-temp-stk-tot.fact-order
          temp-stk-tot.sum-type   = temp-ot-tot.sum-type
          temp-stk-tot.cat-id     = temp-ot-tot.cat-id
          temp-stk-tot.fact-date  = root-temp-stk-tot.fact-date
          temp-stk-tot.shift-date = root-temp-stk-tot.shift-date
          temp-stk-tot.shift-num  = root-temp-stk-tot.shift-num
        .
      end.
      assign
        &scop fq1    temp-stk-tot.new-
        &scop fqs1
        &scop fq2    = temp-stk-tot.new-
        &scop fqs2
        &scop fq3    + temp-ot-tot.new-
        &scop fqs3
        &scop fq4    - temp-ot-tot.
        &scop fqs4
        &scop fq5
        &scop fq6
        {&price-quadro-list}
      .
    end.
  end.

  if v-shift-on then do:
    for each temp-shift-ot-tot
      where temp-shift-ot-tot.sum-type begins {&arh-crsa}
        and (
      &scop fp1   temp-shift-ot-tot.
      &scop fps1
      &scop fp2   <> temp-shift-ot-tot.new-
      &scop fps2
      &scop fp3
      &scop fp4   or
      {&price-pair-list}
            )
    on error undo, return error
    :
      for each root-temp-shift-stk-tot
        where root-temp-shift-stk-tot.obj-type = temp-shift-ot-tot.obj-type
          and root-temp-shift-stk-tot.obj-code = temp-shift-ot-tot.obj-code
          and root-temp-shift-stk-tot.sum-type = {&arh-crsa}
          and root-temp-shift-stk-tot.cat-id   = {&root-cat-id}
      on error undo, return error
      :
        find first temp-shift-stk-tot
          where temp-shift-stk-tot.obj-type   = temp-shift-ot-tot.obj-type
            and temp-shift-stk-tot.obj-code   = temp-shift-ot-tot.obj-code
            and temp-shift-stk-tot.fact-order = root-temp-shift-stk-tot.fact-order
            and temp-shift-stk-tot.sum-type   = temp-shift-ot-tot.sum-type
            and temp-shift-stk-tot.cat-id     = temp-shift-ot-tot.cat-id
          no-error .
        if not available temp-shift-stk-tot then do:
          create temp-shift-stk-tot .
          assign
            temp-shift-stk-tot.obj-type   = temp-shift-ot-tot.obj-type
            temp-shift-stk-tot.obj-code   = temp-shift-ot-tot.obj-code
            temp-shift-stk-tot.fact-order = root-temp-shift-stk-tot.fact-order
            temp-shift-stk-tot.sum-type   = temp-shift-ot-tot.sum-type
            temp-shift-stk-tot.cat-id     = temp-shift-ot-tot.cat-id
            temp-shift-stk-tot.fact-date  = root-temp-shift-stk-tot.fact-date
            temp-shift-stk-tot.shift-date = root-temp-shift-stk-tot.shift-date
            temp-shift-stk-tot.shift-num  = root-temp-shift-stk-tot.shift-num
          .
        end.
        assign
          &scop fq1    temp-shift-stk-tot.new-
          &scop fqs1
          &scop fq2    = temp-shift-stk-tot.new-
          &scop fqs2
          &scop fq3    + temp-shift-ot-tot.new-
          &scop fqs3
          &scop fq4    - temp-shift-ot-tot.
          &scop fqs4
          &scop fq5
          &scop fq6
          {&price-quadro-list}
        .
      end.
    end.
  end.

  for each temp-ot-tot
    where temp-ot-tot.sum-type = {&arh-crsa}
      and (
    &scop fp1   temp-ot-tot.
    &scop fps1
    &scop fp2   <> temp-ot-tot.new-
    &scop fps2
    &scop fp3
    &scop fp4   or
    {&price-pair-list}
          )
  on error undo, return error
  :
    for each root-temp-stk-tot
      where root-temp-stk-tot.obj-type = temp-ot-tot.obj-type
        and root-temp-stk-tot.obj-code = temp-ot-tot.obj-code
        and root-temp-stk-tot.sum-type = {&arh-cgdt} + v-ext-doc-type
        and root-temp-stk-tot.cat-id   = {&root-cat-id}
    on error undo, return error
    :
      find first temp-stk-tot
        where temp-stk-tot.obj-type   = temp-ot-tot.obj-type
          and temp-stk-tot.obj-code   = temp-ot-tot.obj-code
          and temp-stk-tot.fact-order = root-temp-stk-tot.fact-order
          and temp-stk-tot.sum-type   = {&arh-cgdt} + v-ext-doc-type
          and temp-stk-tot.cat-id     = temp-ot-tot.cat-id
        no-error .
      if not available temp-stk-tot then do:
        create temp-stk-tot .
        assign
          temp-stk-tot.obj-type   = temp-ot-tot.obj-type
          temp-stk-tot.obj-code   = temp-ot-tot.obj-code
          temp-stk-tot.fact-order = root-temp-stk-tot.fact-order
          temp-stk-tot.sum-type   = temp-stk-tot.sum-type
          temp-stk-tot.cat-id     = temp-ot-tot.cat-id
          temp-stk-tot.fact-date  = root-temp-stk-tot.fact-date
          temp-stk-tot.shift-date = root-temp-stk-tot.shift-date
          temp-stk-tot.shift-num  = root-temp-stk-tot.shift-num
        .
      end.
      assign
        &scop fq1    temp-stk-tot.new-
        &scop fqs1
        &scop fq2    = temp-stk-tot.new-
        &scop fqs2
        &scop fq3    + temp-ot-tot.new-
        &scop fqs3
        &scop fq4    - temp-ot-tot.
        &scop fqs4
        &scop fq5
        &scop fq6
        {&price-quadro-list}
      .
    end.
  end.

  if v-shift-on then do:
    for each temp-shift-ot-tot
      where temp-shift-ot-tot.sum-type = {&arh-crsa}
        and (
      &scop fp1   temp-shift-ot-tot.
      &scop fps1
      &scop fp2   <> temp-shift-ot-tot.new-
      &scop fps2
      &scop fp3
      &scop fp4   or
      {&price-pair-list}
            )
    on error undo, return error
    :
      for each root-temp-shift-stk-tot
        where root-temp-shift-stk-tot.obj-type = temp-shift-ot-tot.obj-type
          and root-temp-shift-stk-tot.obj-code = temp-shift-ot-tot.obj-code
          and root-temp-shift-stk-tot.sum-type = {&arh-cgdt} + v-ext-doc-type
          and root-temp-shift-stk-tot.cat-id   = {&root-cat-id}
      on error undo, return error
      :
        find first temp-shift-stk-tot
          where temp-shift-stk-tot.obj-type   = temp-shift-ot-tot.obj-type
            and temp-shift-stk-tot.obj-code   = temp-shift-ot-tot.obj-code
            and temp-shift-stk-tot.fact-order = root-temp-shift-stk-tot.fact-order
            and temp-shift-stk-tot.sum-type   = {&arh-cgdt} + v-ext-doc-type
            and temp-shift-stk-tot.cat-id     = temp-shift-ot-tot.cat-id
          no-error .
        if not available temp-shift-stk-tot then do:
          create temp-shift-stk-tot .
          assign
            temp-shift-stk-tot.obj-type   = temp-shift-ot-tot.obj-type
            temp-shift-stk-tot.obj-code   = temp-shift-ot-tot.obj-code
            temp-shift-stk-tot.fact-order = root-temp-shift-stk-tot.fact-order
            temp-shift-stk-tot.sum-type   = temp-shift-stk-tot.sum-type
            temp-shift-stk-tot.cat-id     = temp-shift-ot-tot.cat-id
            temp-shift-stk-tot.fact-date  = root-temp-shift-stk-tot.fact-date
            temp-shift-stk-tot.shift-date = root-temp-shift-stk-tot.shift-date
            temp-shift-stk-tot.shift-num  = root-temp-shift-stk-tot.shift-num
          .
        end.
        assign
          &scop fq1    temp-shift-stk-tot.new-
          &scop fqs1
          &scop fq2    = temp-shift-stk-tot.new-
          &scop fqs2
          &scop fq3    + temp-shift-ot-tot.new-
          &scop fqs3
          &scop fq4    - temp-shift-ot-tot.
          &scop fqs4
          &scop fq5
          &scop fq6
          {&price-quadro-list}
        .
      end.
    end.
  end.

  for each temp-ot-line
    where temp-ot-line.sum-type = {&arh-crsa}
      and (
    &scop fp1   temp-ot-line.
    &scop fps1
    &scop fp2   <> temp-ot-line.new-
    &scop fps2
    &scop fp3
    &scop fp4   or
    {&price-pair-list}
          )
  on error undo, return error
  :
    for each root-temp-stk-line
      where root-temp-stk-line.obj-type  = temp-ot-line.obj-type
        and root-temp-stk-line.obj-code  = temp-ot-line.obj-code
        and root-temp-stk-line.artic     = temp-ot-line.artic
        and root-temp-stk-line.prod-type = temp-ot-line.prod-type
        and root-temp-stk-line.prod-code = temp-ot-line.prod-code
        and root-temp-stk-line.sum-type  = {&arh-cgdt} + v-ext-doc-type
        and root-temp-stk-line.cat-id    = {&root-cat-id}
    on error undo, return error
    :
      find first temp-stk-line
        where temp-stk-line.obj-type   = temp-ot-line.obj-type
          and temp-stk-line.obj-code   = temp-ot-line.obj-code
          and temp-stk-line.artic      = temp-ot-line.artic
          and temp-stk-line.prod-type  = temp-ot-line.prod-type
          and temp-stk-line.prod-code  = temp-ot-line.prod-code
          and temp-stk-line.fact-order = root-temp-stk-line.fact-order
          and temp-stk-line.sum-type   = root-temp-stk-line.sum-type
          and temp-stk-line.cat-id     = {&root-cat-id}
        no-error .
      if not available temp-stk-line then do:
        create temp-stk-line .
        assign
          temp-stk-line.obj-type   = temp-ot-line.obj-type
          temp-stk-line.obj-code   = temp-ot-line.obj-code
          temp-stk-line.artic      = temp-ot-line.artic
          temp-stk-line.prod-type  = temp-ot-line.prod-type
          temp-stk-line.prod-code  = temp-ot-line.prod-code
          temp-stk-line.fact-order = root-temp-stk-line.fact-order
          temp-stk-line.sum-type   = root-temp-stk-line.sum-type
          temp-stk-line.cat-id     = {&root-cat-id}
          temp-stk-line.fact-date  = root-temp-stk-line.fact-date
          temp-stk-line.shift-date = root-temp-stk-line.shift-date
          temp-stk-line.shift-num  = root-temp-stk-line.shift-num
        .
      end.
      assign
        &scop fq1    temp-stk-line.new-
        &scop fqs1
        &scop fq2    = temp-stk-line.new-
        &scop fqs2
        &scop fq3    + temp-ot-line.new-
        &scop fqs3
        &scop fq4    - temp-ot-line.
        &scop fqs4
        &scop fq5
        &scop fq6
        {&price-quadro-list}
      .
    end.
  end.

  if v-shift-on then do:
    for each temp-shift-ot-line
      where temp-shift-ot-line.sum-type = {&arh-crsa}
        and (
      &scop fp1   temp-shift-ot-line.
      &scop fps1
      &scop fp2   <> temp-shift-ot-line.new-
      &scop fps2
      &scop fp3
      &scop fp4   or
      {&price-pair-list}
            )
    on error undo, return error
    :
      for each root-temp-shift-stk-line
        where root-temp-shift-stk-line.obj-type  = temp-shift-ot-line.obj-type
          and root-temp-shift-stk-line.obj-code  = temp-shift-ot-line.obj-code
          and root-temp-shift-stk-line.artic     = temp-shift-ot-line.artic
          and root-temp-shift-stk-line.prod-type = temp-shift-ot-line.prod-type
          and root-temp-shift-stk-line.prod-code = temp-shift-ot-line.prod-code
          and root-temp-shift-stk-line.sum-type  = {&arh-cgdt} + v-ext-doc-type
          and root-temp-shift-stk-line.cat-id    = {&root-cat-id}
      on error undo, return error
      :
        find first temp-shift-stk-line
          where temp-shift-stk-line.obj-type   = temp-shift-ot-line.obj-type
            and temp-shift-stk-line.obj-code   = temp-shift-ot-line.obj-code
            and temp-shift-stk-line.artic      = temp-shift-ot-line.artic
            and temp-shift-stk-line.prod-type  = temp-shift-ot-line.prod-type
            and temp-shift-stk-line.prod-code  = temp-shift-ot-line.prod-code
            and temp-shift-stk-line.fact-order = root-temp-shift-stk-line.fact-order
            and temp-shift-stk-line.sum-type   = root-temp-shift-stk-line.sum-type
            and temp-shift-stk-line.cat-id     = {&root-cat-id}
          no-error .
        if not available temp-shift-stk-line then do:
          create temp-shift-stk-line .
          assign
            temp-shift-stk-line.obj-type   = temp-shift-ot-line.obj-type
            temp-shift-stk-line.obj-code   = temp-shift-ot-line.obj-code
            temp-shift-stk-line.artic      = temp-shift-ot-line.artic
            temp-shift-stk-line.prod-type  = temp-shift-ot-line.prod-type
            temp-shift-stk-line.prod-code  = temp-shift-ot-line.prod-code
            temp-shift-stk-line.fact-order = root-temp-shift-stk-line.fact-order
            temp-shift-stk-line.sum-type   = root-temp-shift-stk-line.sum-type
            temp-shift-stk-line.cat-id     = {&root-cat-id}
            temp-shift-stk-line.fact-date  = root-temp-shift-stk-line.fact-date
            temp-shift-stk-line.shift-date = root-temp-shift-stk-line.shift-date
            temp-shift-stk-line.shift-num  = root-temp-shift-stk-line.shift-num
          .
        end.
        assign
          &scop fq1    temp-shift-stk-line.new-
          &scop fqs1
          &scop fq2    = temp-shift-stk-line.new-
          &scop fqs2
          &scop fq3    + temp-shift-ot-line.new-
          &scop fqs3
          &scop fq4    - temp-shift-ot-line.
          &scop fqs4
          &scop fq5
          &scop fq6
          {&price-quadro-list}
        .
      end.
    end.
  end.

end procedure. /* update-stk-table */




procedure store-temp-table :
  for each temp-ot-tot
  on error undo, return error
  :
    if
    &scop fp1   temp-ot-tot.
    &scop fps1
    &scop fp2   <> temp-ot-tot.new-
    &scop fps2
    &scop fp3
    &scop fp4   or
    {&price-pair-list}
    or ( temp-ot-tot.cat-id = {&root-cat-id} )
    then do:

      assign
        l-need-create-record =
                                &scop fl1  temp-ot-tot.new-
                                &scop fls1
                                &scop fl2  <> 0
                                &scop fl3  or
                                {&price-single-list}
                             or ( temp-ot-tot.cat-id = {&root-cat-id} )
      .

      find first ub.ot-tot exclusive-lock
        where ub.ot-tot.doc-code = temp-ot-tot.doc-code
          and ub.ot-tot.sum-type = temp-ot-tot.sum-type
          and ub.ot-tot.cat-id   = temp-ot-tot.cat-id
        no-error .
      if l-need-create-record then do:
        if not available ub.ot-tot then do:
          create ub.ot-tot .
        end.
        buffer-copy temp-ot-tot to ub.ot-tot
        assign
          &scop fp1   ub.ot-tot.
          &scop fps1
          &scop fp2   = temp-ot-tot.new-
          &scop fps2
          &scop fp3
          &scop fp4
          {&price-pair-list}
        .
      end.
      else do:
        if available ub.ot-tot then do:
          delete ub.ot-tot .
        end.
      end.
    end. /*если было изменение*/
  end. /*each tt-ot-tot*/


  for each temp-ot-line
  on error undo, return error
  :
    if
    &scop fp1   temp-ot-line.
    &scop fps1
    &scop fp2   <> temp-ot-line.new-
    &scop fps2
    &scop fp3
    &scop fp4   or
    {&price-pair-list}
    or ( temp-ot-line.sum-type = {&arh-crsa} )
    then do:

      assign
        l-need-create-record =
                                &scop fl1  temp-ot-line.new-
                                &scop fls1
                                &scop fl2  <> 0
                                &scop fl3  or
                                {&price-single-list}
                             or ( temp-ot-line.sum-type = {&arh-crsa} )
      .

      find first ub.ot-line exclusive-lock
        where ub.ot-line.doc-code  = temp-ot-line.doc-code
          and ub.ot-line.artic     = temp-ot-line.artic
          and ub.ot-line.prod-type = temp-ot-line.prod-type
          and ub.ot-line.prod-code = temp-ot-line.prod-code
          and ub.ot-line.sum-type  = temp-ot-line.sum-type
          and ub.ot-line.cat-id    = temp-ot-line.cat-id
        no-error .
      if l-need-create-record then do:
        if not available ub.ot-line then do:
          create ub.ot-line .
        end.
        buffer-copy temp-ot-line to ub.ot-line
        assign
          &scop fp1   ub.ot-line.
          &scop fps1
          &scop fp2   = temp-ot-line.new-
          &scop fps2
          &scop fp3
          &scop fp4
          {&price-pair-list}
        .
      end.
      else do:
        if available ub.ot-line then do:
          delete ub.ot-line .
        end.
      end.
    end. /*если было изменение*/
  end. /*each tt-ot-line*/

  for each temp-stk-tot
  on error undo, return error
  :
    if
    &scop fp1   temp-stk-tot.
    &scop fps1
    &scop fp2   <> temp-stk-tot.new-
    &scop fps2
    &scop fp3
    &scop fp4   or
    {&price-pair-list}
    or ( temp-stk-tot.cat-id = {&root-cat-id} )
    then do:

      assign
        l-need-create-record =
                                &scop fl1  temp-stk-tot.new-
                                &scop fls1
                                &scop fl2  <> 0
                                &scop fl3  or
                                {&price-single-list}
                             or ( temp-stk-tot.cat-id = {&root-cat-id} )
      .

      find first ub.stk-tot exclusive-lock
        where ub.stk-tot.obj-type   = temp-stk-tot.obj-type
          and ub.stk-tot.obj-code   = temp-stk-tot.obj-code
          and ub.stk-tot.fact-order = temp-stk-tot.fact-order
          and ub.stk-tot.sum-type   = temp-stk-tot.sum-type
          and ub.stk-tot.cat-id     = temp-stk-tot.cat-id
        no-error .
      if l-need-create-record then do:
        if not available ub.stk-tot then do:
          create ub.stk-tot .
        end.
        buffer-copy temp-stk-tot to ub.stk-tot
        assign
          &scop fp1   ub.stk-tot.
          &scop fps1
          &scop fp2   = temp-stk-tot.new-
          &scop fps2
          &scop fp3
          &scop fp4
          {&price-pair-list}
        .
      end.
      else do:
        if available ub.stk-tot then do:
          delete ub.stk-tot .
        end.
      end.
    end. /*если было изменение*/
  end. /*each tt-stk-tot*/

  if v-shift-on then do:
    for each temp-shift-stk-tot
    on error undo, return error
    :
      if
      &scop fp1   temp-shift-stk-tot.
      &scop fps1
      &scop fp2   <> temp-shift-stk-tot.new-
      &scop fps2
      &scop fp3
      &scop fp4   or
      {&price-pair-list}
      or ( temp-shift-stk-tot.cat-id = {&root-cat-id} )
      then do:

        assign
          l-need-create-record =
                                  &scop fl1  temp-shift-stk-tot.new-
                                  &scop fls1
                                  &scop fl2  <> 0
                                  &scop fl3  or
                                  {&price-single-list}
                              or ( temp-shift-stk-tot.cat-id = {&root-cat-id} )
        .

        find first ub.stk-tot exclusive-lock
          where ub.stk-tot.obj-type   = temp-shift-stk-tot.obj-type
            and ub.stk-tot.obj-code   = temp-shift-stk-tot.obj-code
            and ub.stk-tot.fact-order = temp-shift-stk-tot.fact-order
            and ub.stk-tot.sum-type   = temp-shift-stk-tot.sum-type
            and ub.stk-tot.cat-id     = temp-shift-stk-tot.cat-id
          no-error .
        if l-need-create-record then do:
          if not available ub.stk-tot then do:
            create ub.stk-tot .
          end.
          buffer-copy temp-shift-stk-tot to ub.stk-tot
          assign
            &scop fp1   ub.stk-tot.
            &scop fps1
            &scop fp2   = temp-shift-stk-tot.new-
            &scop fps2
            &scop fp3
            &scop fp4
            {&price-pair-list}
          .
        end.
        else do:
          if available ub.stk-tot then do:
            delete ub.stk-tot .
          end.
        end.
      end. /*если было изменение*/
    end. /*each tt-stk-tot*/
  end.

  for each temp-stk-line
  on error undo, return error
  :
    if
    &scop fp1   temp-stk-line.
    &scop fps1
    &scop fp2   <> temp-stk-line.new-
    &scop fps2
    &scop fp3
    &scop fp4   or
    {&price-pair-list}
    or ( temp-stk-line.cat-id = {&root-cat-id} )
    then do:

      assign
        l-need-create-record =
                                &scop fl1  temp-stk-line.new-
                                &scop fls1
                                &scop fl2  <> 0
                                &scop fl3  or
                                {&price-single-list}
                             or ( temp-stk-line.cat-id = {&root-cat-id} )
      .

      find first ub.stk-line exclusive-lock
        where ub.stk-line.obj-type   = temp-stk-line.obj-type
          and ub.stk-line.obj-code   = temp-stk-line.obj-code
          and ub.stk-line.artic      = temp-stk-line.artic
          and ub.stk-line.prod-type  = temp-stk-line.prod-type
          and ub.stk-line.prod-code  = temp-stk-line.prod-code
          and ub.stk-line.fact-order = temp-stk-line.fact-order
          and ub.stk-line.sum-type   = temp-stk-line.sum-type
          and ub.stk-line.cat-id     = temp-stk-line.cat-id
        no-error .
      if l-need-create-record then do:
        if not available ub.stk-line then do:
          create ub.stk-line .
        end.
        buffer-copy temp-stk-line to ub.stk-line
        assign
          &scop fp1   ub.stk-line.
          &scop fps1
          &scop fp2   = temp-stk-line.new-
          &scop fps2
          &scop fp3
          &scop fp4
          {&price-pair-list}
        .
      end.
      else do:
        if available ub.stk-line then do:
          delete ub.stk-line .
        end.
      end.
    end. /*если было изменение*/
  end. /*each tt-stk-line*/

  if v-shift-on then do:
    for each temp-shift-stk-line
    on error undo, return error
    :
      if
      &scop fp1   temp-shift-stk-line.
      &scop fps1
      &scop fp2   <> temp-shift-stk-line.new-
      &scop fps2
      &scop fp3
      &scop fp4   or
      {&price-pair-list}
      or ( temp-shift-stk-line.cat-id = {&root-cat-id} )
      then do:

        assign
          l-need-create-record =
                                  &scop fl1  temp-shift-stk-line.new-
                                  &scop fls1
                                  &scop fl2  <> 0
                                  &scop fl3  or
                                  {&price-single-list}
                              or ( temp-shift-stk-line.cat-id = {&root-cat-id} )
        .

        find first ub.stk-line exclusive-lock
          where ub.stk-line.obj-type   = temp-shift-stk-line.obj-type
            and ub.stk-line.obj-code   = temp-shift-stk-line.obj-code
            and ub.stk-line.artic      = temp-shift-stk-line.artic
            and ub.stk-line.prod-type  = temp-shift-stk-line.prod-type
            and ub.stk-line.prod-code  = temp-shift-stk-line.prod-code
            and ub.stk-line.fact-order = temp-shift-stk-line.fact-order
            and ub.stk-line.sum-type   = temp-shift-stk-line.sum-type
            and ub.stk-line.cat-id     = temp-shift-stk-line.cat-id
          no-error .
        if l-need-create-record then do:
          if not available ub.stk-line then do:
            create ub.stk-line .
          end.
          buffer-copy temp-shift-stk-line to ub.stk-line
          assign
            &scop fp1   ub.stk-line.
            &scop fps1
            &scop fp2   = temp-shift-stk-line.new-
            &scop fps2
            &scop fp3
            &scop fp4
            {&price-pair-list}
          .
        end.
        else do:
          if available ub.stk-line then do:
            delete ub.stk-line .
          end.
        end.
      end. /*если было изменение*/
    end. /*each tt-stk-line*/
  end.

end procedure. /* store-temp-table */



procedure check-valid-archives :

  define buffer day_stk-tot   for ub.stk-tot .
  define buffer shift_stk-tot for ub.stk-tot .
  define variable v-different-fields as character no-undo .

  do
  on error undo, return error
  :
    find last day_stk-tot no-lock
      where day_stk-tot.obj-type   = ub.price-doc.obj-type
        and day_stk-tot.obj-code   = ub.price-doc.obj-code
        and day_stk-tot.sum-type   = {&arh-crsa}
        and day_stk-tot.shift-date = ?
      .
    find last shift_stk-tot no-lock
      where shift_stk-tot.obj-type   = ub.price-doc.obj-type
        and shift_stk-tot.obj-code   = ub.price-doc.obj-code
        and shift_stk-tot.sum-type   = {&arh-crsa}
        and shift_stk-tot.shift-date <> ?
      .

    buffer-compare
      day_stk-tot
      except fact-order shift-date shift-num
      to shift_stk-tot
      CASE-SENSITIVE
      save result in v-different-fields .

    if v-different-fields <> "" then do:
      output stream slog to calc-apc.err append .
      export stream slog v-different-fields .
      export stream slog "day_stk-tot" .
      export stream slog day_stk-tot .
      export stream slog "shift_stk-tot" .
      export stream slog shift_stk-tot .
      output stream slog close .

      message
        vss-workfile vss-revision vss-description skip
        "Внутренняя ошибка расчета складского архива по товарам" skip
        v-different-fields
        view-as alert-box error .
      undo, return error .
    end.
  end.

end procedure. /* check-valid-archives */

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
      current-time = string(v-time - start-time, "HH:MM:SS")
      current-action = p-action
    .
    if mFrameView
    then do:
       display
          current-time
          current-action
       with frame inf.
    end.
  end.
end procedure. /* show-action */