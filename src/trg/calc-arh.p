block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Расчет складского архива по товарам по документу

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 08/22/00

*/

define input  parameter p-doc-code as character no-undo .
define input  parameter p-cut-date as date      no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Расчет складского архива по товарам по документу".
{ cmp/vssrevis.i "substitute('&1|&2':u,p-doc-code,p-cut-date)" }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/arh.i      }
{ trg/factord.i  }
{ str/prl-vat.i  }
{ gbl/cur-time.i }
{ str/clcprtsl.i }

define stream slog .

define variable ind                         as integer no-undo .
define variable start-time                  as integer   no-undo .
define variable current-time                as character no-undo .
define variable current-action              as character no-undo .
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

define variable ind-ext    as integer no-undo .
define variable v-cat-id   as character no-undo extent 4 .
define variable v-sum-type as character no-undo extent 4 .

define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.

{&def-temp-ot-tot}
{&def-temp-ot-line}
{&def-temp-stk-tot}
{&def-temp-stk-line}
{&def-temp-shift-stk-tot}
{&def-temp-shift-stk-line}
{&def-var-list}

main-block :
do transaction
on error undo main-block, return error
:
  find first ub.trn-doc share-lock
    where ub.trn-doc.doc-code = p-doc-code
    no-error .
  if not available ub.trn-doc
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найден документ" p-doc-code skip
      view-as alert-box error .
    undo main-block, return error . /* --->>>--- */
  end.

  if ub.trn-doc.status_ <> {&fact}
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Нельзя рассчитать складской архив по товарам для складского документа не закрытого до статуса" {&fact} skip
      "Документ" p-doc-code skip
      view-as alert-box error .
    undo main-block, return error . /* --->>>--- */
  end.

  { gbl/objat.i
    ub.trn-doc.obj-type
    ub.trn-doc.obj-code
    "'shift-on=request'"
    v-shift-on
    no-error
  }

  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при запуске процедуры objat" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error .
  end.

  define variable v-curr-r-b as character no-undo .
  { gbl/curr-r-b.i
    v-curr-r-b
  }

  run factord in this-procedure
    (input  ub.trn-doc.fact-date   /* p-fact-date            */
    ,input  ub.trn-doc.fact-time   /* p-fact-time            */
    ,input  ub.trn-doc.fact-num    /* p-fact-num             */
    ,input  ub.trn-doc.shift-date  /* p-shift-date           */
    ,input  ub.trn-doc.shift-num   /* p-shift-num            */
    ,input  v-shift-on             /* p-shift-on             */
    ,output v-fact-order           /* p-fact-order           */
    ,output v-shift-end-fact-order /* p-shift-end-fact-order */
    ,output v-day-end-fact-order   /* p-day-end-fact-order   */
    ) no-error .
  if error-status :error
  or v-fact-order = ?
  or v-fact-order = 0
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении фактического номера складского документа" skip
      "doc-code"                ub.trn-doc.doc-code    skip
      "fact-date"               ub.trn-doc.fact-date   skip
      "fact-time"               ub.trn-doc.fact-time   skip
      "fact-num"                ub.trn-doc.fact-num    skip
      "shift-date"              ub.trn-doc.shift-date  skip
      "shift-num"               ub.trn-doc.shift-num   skip
      "v-fact-order"            v-fact-order           skip
      "v-shift-end-fact-order"  v-shift-end-fact-order skip
      "v-day-end-fact-order"    v-day-end-fact-order   skip
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
    if p-cut-date = ub.trn-doc.fact-date
    then do:
      assign
        v-day-end-fact-order = v-day-end-fact-order - {&arh-delta}
      .
      if v-shift-on = true
      then do:
        define buffer buf_shift-obj for ub.shift-obj .
        find last buf_shift-obj
          where buf_shift-obj.obj-type    = ub.trn-doc.obj-type
            and buf_shift-obj.obj-code    = ub.trn-doc.obj-code
            and buf_shift-obj.shift-date <= p-cut-date
          use-index pi
          no-error .
        if not available buf_shift-obj
        or buf_shift-obj.status_ <> {&sht-closed}
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при поиске последней смены" skip
            "Объект" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
            "Дата" p-cut-date skip
            view-as alert-box error .
          undo, return error return-value .
        end.

        if  ub.trn-doc.shift-date = buf_shift-obj.shift-date
        and ub.trn-doc.shift-num  = buf_shift-obj.shift-num
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
    ub.trn-doc.doc-code                      label "Документ" skip
    ub.trn-doc.obj-type                      label "Объект"
    ub.trn-doc.obj-code                      no-label skip
    ub.trn-doc.fact-date format "99/99/9999" label "Дата закрытия" skip
    current-action       format "x(40)"      no-label skip
    ind                  format ">>>>>>>9"   label "Обработано артикулов" skip
    ub.doc-line.artic                        label "Текущий артикул" skip
    current-time         format "x(8)"       label "Время расчета документа" skip
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
        ub.trn-doc.doc-code
        ub.trn-doc.obj-type
        ub.trn-doc.obj-code
        ub.trn-doc.fact-date
     with frame inf .
  end.
  run show-action in this-procedure
    (input "Обработка строк документа"
    ).

  assign
    v-ot-fact-order             = v-fact-order
    v-stk-tot-fact-order        = v-day-end-fact-order
    v-stk-line-fact-order       = v-day-end-fact-order
    v-shift-stk-tot-fact-order  = v-shift-end-fact-order
    v-shift-stk-line-fact-order = v-shift-end-fact-order
  .

/*  { gbl/baserate.i*/
/*    ub.trn-doc.host-code*/
/*    ub.trn-doc.fact-date*/
/*    v-base-rate*/
/*    v-base-scale*/
/*    no-error*/
/*  }*/
/*  if error-status :error */
/*  then do:*/
/*    message*/
/*      vss-workfile vss-revision vss-description skip*/
/*      "Ошибка при определении текущего курса" skip*/
/*      error-status :get-message(1) skip*/
/*      return-value skip*/
/*      view-as alert-box error .*/
/*    undo main-block, return error . /* --->>>--- */ */
/*  end.*/
  /*
    TODO ???
    Возможно здесь надо считывать текущий курс
  */
  assign
    v-base-rate  = ub.trn-doc.base-rate
    v-base-scale = ub.trn-doc.base-scale
  .

  run init-temp-tables in this-procedure no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры init-temp-tables" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error . /* --->>>--- */
  end.


  for each ub.doc-line no-lock
    where ub.doc-line.doc-code = ub.trn-doc.doc-code
  on error undo main-block, return error
  :
    run process-doc-line in this-procedure no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры process-doc-line" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo main-block, return error . /* --->>>--- */
    end.

    assign
      ind  = ind + 1
    .
    if ind mod 10 = 0
    then do:
      run cur-time in this-procedure ( output v-today
                                     , output v-time
                                     ).
      assign
        current-time = string(v-time - start-time, "HH:MM:SS")
      .
      if mFrameView
      then display
        ind
        ub.doc-line.artic
        current-time
        with frame inf .
    end.
  end.

  run update-ot-tot in this-procedure no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры update-ot-tot" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error . /* --->>>--- */
  end.


  run update-stk-table in this-procedure no-error .
  if error-status :error
  then do:
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
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры store-temp-table" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error . /* --->>>--- */
  end.

  if v-shift-on
  then do:
    run check-valid-archives in this-procedure
      no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при проверке целостности складского архива по товарам" skip
        "Дополнительная информация выведена в файл calc-arh.err" skip
        "Переоценка" ub.trn-doc.doc-code skip
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
    define variable v-root-sum-type                  as character no-undo extent 8 .
    define variable v-line-sum-type                  as character no-undo extent 8 .
    define variable v-root-sum-type-ind-ext          as integer   no-undo .
    define variable v-prev-stk-tot-fact-order        like ub.stk-tot.fact-order     no-undo .
    define variable v-prev-stk-line-fact-order       like ub.stk-line.fact-order    no-undo .
    define variable v-prev-shift-stk-tot-fact-order  like ub.stk-tot.fact-order     no-undo .
    define variable v-prev-shift-stk-line-fact-order like ub.stk-line.fact-order    no-undo .

    define variable v-goods-vat-pc                   like ub.doc-line.vat-pc           no-undo.
    define variable v-goods-slt-pc                   like ub.doc-line.slt-pc           no-undo.
    define variable v-host-code                      like ub.sysconf.host-code         no-undo.

    { gbl/hostcode.i ub.trn-doc.obj-type ub.trn-doc.obj-code v-host-code }

    if ub.trn-doc.ext-doc-type = ""
    or ub.trn-doc.ext-doc-type = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не задан расширенный тип документа" skip
        "Документ" ub.trn-doc.doc-code skip
        "Тип документа" ub.trn-doc.ext-doc-type skip
        "doc-type" ub.trn-doc.doc-type skip
        "internal" ub.trn-doc.internal skip
        "discnt-type" ub.trn-doc.discnt-type skip
        "ret-supp" ub.trn-doc.ret-supp skip
        "pay-code" ub.trn-doc.pay-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    assign
      v-root-sum-type[1] = {&arh-crsa}
      v-root-sum-type[2] = {&arh-cost}
      v-root-sum-type[3] = {&arh-sadt}         + ub.trn-doc.ext-doc-type
      v-root-sum-type[4] = {&arh-cgdt}         + ub.trn-doc.ext-doc-type
      v-root-sum-type[5] = {&arh-csdt}         + ub.trn-doc.ext-doc-type
      v-root-sum-type[6] = {&arh-sadt-service} + ub.trn-doc.ext-doc-type
      v-root-sum-type[7] = {&arh-cgdt-service} + ub.trn-doc.ext-doc-type
      v-root-sum-type[8] = {&arh-csdt-service} + ub.trn-doc.ext-doc-type
    .

    run show-action in this-procedure
      (input "Считывается оборот по документу"
      ).

    /* считываем предыдущее значение оборота по документу */
    find first ub.ot-tot no-lock
      where ub.ot-tot.doc-code = ub.trn-doc.doc-code
        and ub.ot-tot.sum-type = {&arh-crsa}
        and ub.ot-tot.cat-id   = {&root-cat-id}
      no-error .
    if available ub.ot-tot
    then do:
      do v-root-sum-type-ind-ext = 1 to extent(v-root-sum-type)
      :
        for each ub.ot-tot no-lock
          where ub.ot-tot.doc-code = ub.trn-doc.doc-code
            and ub.ot-tot.sum-type begins v-root-sum-type[v-root-sum-type-ind-ext]
        on error undo, return error
        :
          create temp-ot-tot .
  /*        buffer-copy ub.ot-tot to temp-ot-tot*/
          &scop fp1   temp-ot-tot.
          &scop fp2   = ub.ot-tot.
          assign
            {&ot-tot-pair-list}
          .
          assign
            &scop fp1   temp-ot-tot.
            &scop fps1
            &scop fp2   = ub.ot-tot.
            &scop fps2
            &scop fp3
            &scop fp4
            {&price-pair-list}
          .
        end.
      end.
    end.
    else do:
      create temp-ot-tot .
      assign
        temp-ot-tot.doc-code     = ub.trn-doc.doc-code
        temp-ot-tot.sum-type     = {&arh-crsa}
        temp-ot-tot.cat-id       = {&root-cat-id}
        temp-ot-tot.ext-doc-type = ub.trn-doc.ext-doc-type
        temp-ot-tot.obj-type     = ub.trn-doc.obj-type
        temp-ot-tot.obj-code     = ub.trn-doc.obj-code
        temp-ot-tot.fact-order   = v-ot-fact-order
      .
    end.

    run show-action in this-procedure
      (input "Считывается оборот по строкам документа"
      ).

    /* считываем предыдущее значение оборота по строке */
    for each ub.doc-line
      where ub.doc-line.doc-code = ub.trn-doc.doc-code no-lock
    on error undo, return error
    :
      define buffer buf_goods for ub.goods .
      find first buf_goods no-lock
        where buf_goods.artic     = ub.doc-line.artic
          and buf_goods.prod-type = ub.doc-line.prod-type
          and buf_goods.prod-code = ub.doc-line.prod-code
        no-error .
      if not available buf_goods
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найден товар" skip
          "Документ" ub.doc-line.doc-code skip
          "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
          view-as alert-box error .
        undo, return error .
      end.

      define variable v-doc-line-ot-sum-type as character no-undo extent 3 .
      define variable v-doc-line-ot-sum-type-ind-ext as integer   no-undo .

      define variable v-sum-type as character no-undo .
      if buf_goods.gds-type = {&gds-goods}
      then do:
        assign
          v-sum-type = {&arh-crsa}
          v-doc-line-ot-sum-type[1] = {&arh-sale}
          v-doc-line-ot-sum-type[2] = {&arh-crsa}
          v-doc-line-ot-sum-type[3] = {&arh-cost}
        .
      end.
      else do:
        assign
          v-sum-type = {&arh-crsa-service}
          v-doc-line-ot-sum-type[1] = {&arh-sale-service}
          v-doc-line-ot-sum-type[2] = {&arh-crsa-service}
          v-doc-line-ot-sum-type[3] = {&arh-cost-service}
        .
      end.

      find first ub.ot-line no-lock
        where ub.ot-line.doc-code  = ub.doc-line.doc-code
          and ub.ot-line.artic     = ub.doc-line.artic
          and ub.ot-line.prod-type = ub.doc-line.prod-type
          and ub.ot-line.prod-code = ub.doc-line.prod-code
          and ub.ot-line.sum-type  = v-sum-type
        no-error .
      if available ub.ot-line
      then do:
        do v-doc-line-ot-sum-type-ind-ext = 1 to extent(v-doc-line-ot-sum-type)
        :
          for each ub.ot-line no-lock
            where ub.ot-line.doc-code  = ub.doc-line.doc-code
              and ub.ot-line.artic     = ub.doc-line.artic
              and ub.ot-line.prod-type = ub.doc-line.prod-type
              and ub.ot-line.prod-code = ub.doc-line.prod-code
              and ub.ot-line.sum-type  begins v-doc-line-ot-sum-type[v-doc-line-ot-sum-type-ind-ext]
          on error undo, return error
          :
            create temp-ot-line .
  /*          buffer-copy ub.ot-line to temp-ot-line*/
  /*            .*/
            &scop fp1   temp-ot-line.
            &scop fp2   = ub.ot-line.
            assign
              {&ot-line-pair-list}
            .
            assign
              &scop fp1   temp-ot-line.
              &scop fps1
              &scop fp2   = ub.ot-line.
              &scop fps2
              &scop fp3
              &scop fp4
              {&price-pair-list}
            .
          end.
        end.
      end.
      else do:
        create temp-ot-line .
        assign
          temp-ot-line.doc-code  = ub.doc-line.doc-code
          temp-ot-line.artic     = ub.doc-line.artic
          temp-ot-line.prod-type = ub.doc-line.prod-type
          temp-ot-line.prod-code = ub.doc-line.prod-code
          temp-ot-line.sum-type  = v-sum-type
        .

        define variable v-gds-code   as integer   no-undo .
        define variable v-b-code     as integer   no-undo .
        define variable v-doc-num    as character no-undo .
        define variable v-price-sale as decimal   no-undo .
        define variable v-road-tax   as decimal   no-undo .
        define variable v-excise     as decimal   no-undo .

/*        { gbl/gds-code.i
          ub.doc-line.artic
          ub.doc-line.prod-type
          ub.doc-line.prod-code
          v-gds-code
          no-error
        }
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при поиске кода товара" skip
            "Документ" ub.doc-line.doc-code skip
            "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.  */

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
            "Документ" ub.doc-line.doc-code skip
            "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.

        { gbl/bcprcex.i
          ub.trn-doc.obj-type
          ub.trn-doc.obj-code
          v-b-code
          0
          ub.trn-doc.fact-order
          v-doc-num
          v-price-sale
          v-road-tax
          v-excise
          v-goods-vat-pc
          v-goods-slt-pc
          no-error
        }
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при поиске цены товара" skip
            "Документ" ub.doc-line.doc-code skip
            "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
            "Бар-код" v-b-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        if v-doc-num = ?
        then do:
          assign
            v-goods-vat-pc = 0
            v-goods-slt-pc = 0
          .
        end.
        { gbl/pftxvalg.i
            buf_goods.gds-code
            {&vat-tax-code}
            ub.trn-doc.fact-date
            ub.trn-doc.host-code
            ub.trn-doc.obj-type
            ub.trn-doc.obj-code
            v-goods-vat-pc
            no-error
          }
          
    
        if v-goods-vat-pc = ?
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при поиске НДС для товара на дату" skip
            "Документ" ub.doc-line.doc-code skip
            "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
            "Переоценка" v-doc-num skip
            "Дата" ub.trn-doc.fact-date skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.

        if v-goods-slt-pc = ?
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при поиске НП для товара на дату" skip
            "Документ" ub.doc-line.doc-code skip
            "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
            "Переоценка" v-doc-num skip
            "Дата" ub.trn-doc.fact-date skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.

        assign
          temp-ot-line.cat-id    = trim(string(v-goods-vat-pc, ">99")) + ","
                                 + trim(string(v-goods-slt-pc, ">99"))
        .
        if temp-ot-line.cat-id = ?
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при расчете складского архива по товарам" skip
            "Не определены налоги товара" skip
            "Документ" ub.doc-line.doc-code skip
            "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
            "НДС" v-goods-vat-pc skip
            "НсП" v-goods-slt-pc skip
            view-as alert-box error .
          undo, return error .
        end.
        assign
          temp-ot-line.ext-doc-type = ub.trn-doc.ext-doc-type
          temp-ot-line.obj-type     = ub.trn-doc.obj-type
          temp-ot-line.obj-code     = ub.trn-doc.obj-code
          temp-ot-line.fact-order   = v-ot-fact-order
        .
      end.
    end.


    run show-action in this-procedure
      (input "Считывается остаток по объекту"
      ).

    /* считываем предыдущее (текущее) и все более поздние значения оборота по объекту */

    do v-root-sum-type-ind-ext = 1 to extent(v-root-sum-type)
    :
      find last ub.stk-tot no-lock
        where ub.stk-tot.obj-type   = ub.trn-doc.obj-type
          and ub.stk-tot.obj-code   = ub.trn-doc.obj-code
          and ub.stk-tot.sum-type   = v-root-sum-type[v-root-sum-type-ind-ext]
          and ub.stk-tot.cat-id     = {&root-cat-id}
          and ub.stk-tot.fact-order <= v-stk-tot-fact-order
          and ub.stk-tot.shift-date = ?
        use-index category
        no-error .
      if available ub.stk-tot
      then do:
        assign
          v-prev-stk-tot-fact-order = ub.stk-tot.fact-order
        .
        /* считывание текущего или предыдущего остатка */
        for each ub.stk-tot no-lock
          where ub.stk-tot.obj-type   = ub.trn-doc.obj-type
            and ub.stk-tot.obj-code   = ub.trn-doc.obj-code
            and ub.stk-tot.fact-order = v-prev-stk-tot-fact-order
            and ub.stk-tot.sum-type   begins v-root-sum-type[v-root-sum-type-ind-ext]
        on error undo, return error
        :
          create temp-stk-tot .
/*          buffer-copy ub.stk-tot to temp-stk-tot*/
          &scop fp1   temp-stk-tot.
          &scop fp2   = ub.stk-tot.
          assign
            {&stk-tot-pair-list}
          .

          if v-stk-tot-fact-order = v-prev-stk-tot-fact-order
          then do:
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
            temp-stk-tot.fact-date  = ub.trn-doc.fact-date
            temp-stk-tot.shift-num  = 0
            temp-stk-tot.shift-date = ?
            &scop fp1   temp-stk-tot.new-
            &scop fps1
            &scop fp2   = ub.stk-tot.
            &scop fps2
            &scop fp3
            &scop fp4
            {&price-pair-list}
          .
        end.
      end.
      else do:
        create temp-stk-tot.
        assign
          temp-stk-tot.obj-type   = ub.trn-doc.obj-type
          temp-stk-tot.obj-code   = ub.trn-doc.obj-code
          temp-stk-tot.fact-order = v-stk-tot-fact-order
          temp-stk-tot.sum-type   = v-root-sum-type[v-root-sum-type-ind-ext]
          temp-stk-tot.cat-id     = {&root-cat-id}
          temp-stk-tot.fact-date  = ub.trn-doc.fact-date
          temp-stk-tot.shift-num  = 0
          temp-stk-tot.shift-date = ?
        .
      end.

      /* считывание всех более поздних остатков */
      for each ub.stk-tot no-lock
        where ub.stk-tot.obj-type   = ub.trn-doc.obj-type
          and ub.stk-tot.obj-code   = ub.trn-doc.obj-code
          and ub.stk-tot.fact-order > v-stk-tot-fact-order
          and ub.stk-tot.fact-order <= v-day-cut-fact-order
      on error undo, return error
      :
        if ub.stk-tot.sum-type   begins v-root-sum-type[v-root-sum-type-ind-ext]
        and ub.stk-tot.shift-date = ?
        then do:
          create temp-stk-tot .
  /*          buffer-copy ub.stk-tot to temp-stk-tot*/
          &scop fp1   temp-stk-tot.
          &scop fp2   = ub.stk-tot.
          assign
            {&stk-tot-pair-list}
          .
          assign
            &scop fp1   temp-stk-tot.
            &scop fps1
            &scop fp2   = ub.stk-tot.
            &scop fps2
            &scop fp3
            &scop fp4
            {&price-pair-list}
            &scop fp1   temp-stk-tot.new-
            &scop fps1
            &scop fp2   = ub.stk-tot.
            &scop fps2
            &scop fp3
            &scop fp4
            {&price-pair-list}
          .
        end.
      end.


      if v-shift-on
      then do:
        /* ищем последний складской архив по смене */
        assign
          v-prev-shift-stk-tot-fact-order = 0
        .
        find last ub.stk-tot no-lock
          where ub.stk-tot.obj-type   = ub.trn-doc.obj-type
            and ub.stk-tot.obj-code   = ub.trn-doc.obj-code
            and ub.stk-tot.sum-type   = v-root-sum-type[v-root-sum-type-ind-ext]
            and ub.stk-tot.cat-id     = {&root-cat-id}
            and ub.stk-tot.fact-order <= v-shift-stk-tot-fact-order
            and ub.stk-tot.shift-date <> ?
          use-index category
          no-error .
        if available ub.stk-tot
        then do:
          assign
            v-prev-shift-stk-tot-fact-order = ub.stk-tot.fact-order
          .
        end.

        if v-prev-shift-stk-tot-fact-order > 0
        then do:
          /* считывание текущего или предыдущего остатка */
          for each ub.stk-tot no-lock
            where ub.stk-tot.obj-type   = ub.trn-doc.obj-type
              and ub.stk-tot.obj-code   = ub.trn-doc.obj-code
              and ub.stk-tot.fact-order = v-prev-shift-stk-tot-fact-order
              and ub.stk-tot.sum-type   begins v-root-sum-type[v-root-sum-type-ind-ext]
          on error undo, return error
          :
            create temp-shift-stk-tot .
/*            buffer-copy ub.stk-tot to temp-shift-stk-tot*/
            &scop fp1   temp-shift-stk-tot.
            &scop fp2   = ub.stk-tot.
            assign
              {&stk-tot-pair-list}
            .
            if v-shift-stk-tot-fact-order = v-prev-shift-stk-tot-fact-order
            then do:
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
              temp-shift-stk-tot.fact-date  = ub.trn-doc.fact-date
              temp-shift-stk-tot.shift-date = ub.trn-doc.shift-date
              temp-shift-stk-tot.shift-num  = ub.trn-doc.shift-num
              &scop fp1   temp-shift-stk-tot.new-
              &scop fps1
              &scop fp2   = ub.stk-tot.
              &scop fps2
              &scop fp3
              &scop fp4
              {&price-pair-list}
            .
          end.
        end.
        else do:
          create temp-shift-stk-tot.
          assign
            temp-shift-stk-tot.obj-type   = ub.trn-doc.obj-type
            temp-shift-stk-tot.obj-code   = ub.trn-doc.obj-code
            temp-shift-stk-tot.fact-order = v-shift-stk-tot-fact-order
            temp-shift-stk-tot.sum-type   = v-root-sum-type[v-root-sum-type-ind-ext]
            temp-shift-stk-tot.cat-id     = {&root-cat-id}
            temp-shift-stk-tot.fact-date  = ub.trn-doc.fact-date
            temp-shift-stk-tot.shift-date = ub.trn-doc.shift-date
            temp-shift-stk-tot.shift-num  = ub.trn-doc.shift-num
          .
        end.

        /* считывание всех более поздних остатков */
        for each ub.stk-tot no-lock
          where ub.stk-tot.obj-type   = ub.trn-doc.obj-type
            and ub.stk-tot.obj-code   = ub.trn-doc.obj-code
            and ub.stk-tot.fact-order > v-shift-stk-tot-fact-order
            and ub.stk-tot.fact-order <= v-shift-cut-fact-order
        on error undo, return error
        :
          if ub.stk-tot.sum-type   begins v-root-sum-type[v-root-sum-type-ind-ext]
          and ub.stk-tot.shift-date <> ?
          then do:
            /* todo - возможно надо запретить расчет документов задним числом */
            create temp-shift-stk-tot .
  /*            buffer-copy ub.stk-tot to temp-shift-stk-tot*/
            &scop fp1   temp-shift-stk-tot.
            &scop fp2   = ub.stk-tot.
            assign
              {&stk-tot-pair-list}
            .
            assign
              &scop fp1   temp-shift-stk-tot.
              &scop fps1
              &scop fp2   = ub.stk-tot.
              &scop fps2
              &scop fp3
              &scop fp4
              {&price-pair-list}
              &scop fp1   temp-shift-stk-tot.new-
              &scop fps1
              &scop fp2   = ub.stk-tot.
              &scop fps2
              &scop fp3
              &scop fp4
              {&price-pair-list}
            .
          end.
        end.
      end.
    end.


    run show-action in this-procedure
      (input "Считывается остаток по товарам на объекте"
      ).

    define variable v-doc-line-root-sum-type as character no-undo extent 5 .
    define variable v-doc-line-root-sum-type-ind-ext as integer   no-undo .

    /* считываем предыдущее (текущее) и все более поздние значения оборота по строке */
    for each ub.doc-line
      where ub.doc-line.doc-code = ub.trn-doc.doc-code no-lock
    on error undo, return error
    :
      find first ub.goods no-lock
        where ub.goods.artic     = ub.doc-line.artic
          and ub.goods.prod-type = ub.doc-line.prod-type
          and ub.goods.prod-code = ub.doc-line.prod-code
        .
      if ub.goods.gds-type = {&gds-goods}
      then do:
        assign
          v-doc-line-root-sum-type[1] = {&arh-crsa}
          v-doc-line-root-sum-type[2] = {&arh-cost}
          v-doc-line-root-sum-type[3] = {&arh-sadt}         + ub.trn-doc.ext-doc-type
          v-doc-line-root-sum-type[4] = {&arh-cgdt}         + ub.trn-doc.ext-doc-type
          v-doc-line-root-sum-type[5] = {&arh-csdt}         + ub.trn-doc.ext-doc-type
        .
      end.
      else do:
        assign
          v-doc-line-root-sum-type[1] = {&arh-crsa-service}
          v-doc-line-root-sum-type[2] = {&arh-cost-service}
          v-doc-line-root-sum-type[3] = {&arh-sadt-service} + ub.trn-doc.ext-doc-type
          v-doc-line-root-sum-type[4] = {&arh-cgdt-service} + ub.trn-doc.ext-doc-type
          v-doc-line-root-sum-type[5] = {&arh-csdt-service} + ub.trn-doc.ext-doc-type
        .
      end.

      do v-doc-line-root-sum-type-ind-ext = 1 to extent(v-doc-line-root-sum-type)
      :
        find last ub.stk-line no-lock
          where ub.stk-line.obj-type   = ub.doc-line.obj-type
            and ub.stk-line.obj-code   = ub.doc-line.obj-code
            and ub.stk-line.artic      = ub.doc-line.artic
            and ub.stk-line.prod-type  = ub.doc-line.prod-type
            and ub.stk-line.prod-code  = ub.doc-line.prod-code
            and ub.stk-line.sum-type   = v-doc-line-root-sum-type[v-doc-line-root-sum-type-ind-ext]
            and ub.stk-line.fact-order <= v-stk-line-fact-order
            and ub.stk-line.shift-date = ?
          use-index category
          no-error .
        if available ub.stk-line
        then do:
          assign
            v-prev-stk-line-fact-order = ub.stk-line.fact-order
          .
          /* считывание текущего или предыдущего остатка */
          for each ub.stk-line no-lock
            where ub.stk-line.obj-type   = ub.doc-line.obj-type
              and ub.stk-line.obj-code   = ub.doc-line.obj-code
              and ub.stk-line.artic      = ub.doc-line.artic
              and ub.stk-line.prod-type  = ub.doc-line.prod-type
              and ub.stk-line.prod-code  = ub.doc-line.prod-code
              and ub.stk-line.fact-order = v-prev-stk-line-fact-order
              and ub.stk-line.sum-type   begins v-doc-line-root-sum-type[v-doc-line-root-sum-type-ind-ext]
          on error undo, return error
          :
            create temp-stk-line .
/*            buffer-copy ub.stk-line to temp-stk-line*/
            &scop fp1 temp-stk-line.
            &scop fp2 = ub.stk-line.
            assign
              {&stk-line-pair-list}
            .
            if v-stk-line-fact-order = v-prev-stk-line-fact-order
            then do:
              assign
                &scop fp1   temp-stk-line.
                &scop fps1
                &scop fp2   = ub.stk-line.
                &scop fps2
                &scop fp3
                &scop fp4
                {&price-pair-list}
              .
            end.
            assign
              temp-stk-line.fact-order = v-stk-line-fact-order
              temp-stk-line.fact-date  = ub.trn-doc.fact-date
              temp-stk-line.shift-num  = 0
              temp-stk-line.shift-date = ?
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
        else do:
          create temp-stk-line.
          assign
            temp-stk-line.obj-type   = ub.doc-line.obj-type
            temp-stk-line.obj-code   = ub.doc-line.obj-code
            temp-stk-line.artic      = ub.doc-line.artic
            temp-stk-line.prod-type  = ub.doc-line.prod-type
            temp-stk-line.prod-code  = ub.doc-line.prod-code
            temp-stk-line.fact-order = v-stk-line-fact-order
            temp-stk-line.sum-type   = v-doc-line-root-sum-type[v-doc-line-root-sum-type-ind-ext]
            temp-stk-line.cat-id     = {&root-cat-id}
            temp-stk-line.fact-date  = ub.trn-doc.fact-date
            temp-stk-line.shift-num  = 0
            temp-stk-line.shift-date = ?
          .
        end.

        /* считывание всех более поздних остатков */
        for each ub.stk-line no-lock
          where ub.stk-line.obj-type   = ub.doc-line.obj-type
            and ub.stk-line.obj-code   = ub.doc-line.obj-code
            and ub.stk-line.artic      = ub.doc-line.artic
            and ub.stk-line.prod-type  = ub.doc-line.prod-type
            and ub.stk-line.prod-code  = ub.doc-line.prod-code
            and ub.stk-line.fact-order > v-stk-line-fact-order
            and ub.stk-line.fact-order <= v-day-cut-fact-order
        on error undo, return error
        :
          if ub.stk-line.sum-type   begins v-doc-line-root-sum-type[v-doc-line-root-sum-type-ind-ext]
          and ub.stk-line.shift-date = ?
          then do:
            create temp-stk-line .
  /*            buffer-copy ub.stk-line to temp-stk-line*/
            &scop fp1 temp-stk-line.
            &scop fp2 = ub.stk-line.
            assign
              {&stk-line-pair-list}
            .
            assign
              &scop fp1   temp-stk-line.
              &scop fps1
              &scop fp2   = ub.stk-line.
              &scop fps2
              &scop fp3
              &scop fp4
              {&price-pair-list}
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

        if v-shift-on
        then do:
          assign
            v-prev-shift-stk-line-fact-order = 0
          .
          find last ub.stk-line no-lock
            where ub.stk-line.obj-type   = ub.doc-line.obj-type
              and ub.stk-line.obj-code   = ub.doc-line.obj-code
              and ub.stk-line.artic      = ub.doc-line.artic
              and ub.stk-line.prod-type  = ub.doc-line.prod-type
              and ub.stk-line.prod-code  = ub.doc-line.prod-code
              and ub.stk-line.sum-type   = v-doc-line-root-sum-type[v-doc-line-root-sum-type-ind-ext]
              and ub.stk-line.fact-order <= v-shift-stk-line-fact-order
              and ub.stk-line.shift-date <> ?
            use-index category
            no-error .
          if available ub.stk-line
          then do:
            assign
              v-prev-shift-stk-line-fact-order = ub.stk-line.fact-order
            .
          end.
          if v-prev-shift-stk-line-fact-order > 0
          then do:
            /* считывание текущего или предыдущего остатка */
            for each ub.stk-line no-lock
              where ub.stk-line.obj-type   = ub.doc-line.obj-type
                and ub.stk-line.obj-code   = ub.doc-line.obj-code
                and ub.stk-line.artic      = ub.doc-line.artic
                and ub.stk-line.prod-type  = ub.doc-line.prod-type
                and ub.stk-line.prod-code  = ub.doc-line.prod-code
                and ub.stk-line.fact-order = v-prev-shift-stk-line-fact-order
                and ub.stk-line.sum-type   begins v-doc-line-root-sum-type[v-doc-line-root-sum-type-ind-ext]
            on error undo, return error
            :
              create temp-shift-stk-line .
/*              buffer-copy ub.stk-line to temp-shift-stk-line*/
              &scop fp1 temp-shift-stk-line.
              &scop fp2 = ub.stk-line.
              assign
                {&stk-line-pair-list}
              .
              if v-shift-stk-line-fact-order = v-prev-shift-stk-line-fact-order
              then do:
                assign
                  &scop fp1   temp-shift-stk-line.
                  &scop fps1
                  &scop fp2   = ub.stk-line.
                  &scop fps2
                  &scop fp3
                  &scop fp4
                  {&price-pair-list}
                .
              end.
              assign
                temp-shift-stk-line.fact-order = v-shift-stk-line-fact-order
                temp-shift-stk-line.fact-date  = ub.trn-doc.fact-date
                temp-shift-stk-line.shift-date = ub.trn-doc.shift-date
                temp-shift-stk-line.shift-num  = ub.trn-doc.shift-num
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
          else do:
            create temp-shift-stk-line.
            assign
              temp-shift-stk-line.obj-type   = ub.doc-line.obj-type
              temp-shift-stk-line.obj-code   = ub.doc-line.obj-code
              temp-shift-stk-line.artic      = ub.doc-line.artic
              temp-shift-stk-line.prod-type  = ub.doc-line.prod-type
              temp-shift-stk-line.prod-code  = ub.doc-line.prod-code
              temp-shift-stk-line.fact-order = v-shift-stk-line-fact-order
              temp-shift-stk-line.sum-type   = v-doc-line-root-sum-type[v-doc-line-root-sum-type-ind-ext]
              temp-shift-stk-line.cat-id     = {&root-cat-id}
              temp-shift-stk-line.fact-date  = ub.trn-doc.fact-date
              temp-shift-stk-line.shift-date = ub.trn-doc.shift-date
              temp-shift-stk-line.shift-num  = ub.trn-doc.shift-num
            .
          end.

          /* считывание всех более поздних остатков */
          for each ub.stk-line no-lock
            where ub.stk-line.obj-type   = ub.doc-line.obj-type
              and ub.stk-line.obj-code   = ub.doc-line.obj-code
              and ub.stk-line.artic      = ub.doc-line.artic
              and ub.stk-line.prod-type  = ub.doc-line.prod-type
              and ub.stk-line.prod-code  = ub.doc-line.prod-code
              and ub.stk-line.fact-order > v-shift-stk-line-fact-order
              and ub.stk-line.fact-order <= v-shift-cut-fact-order
          on error undo, return error
          :
            if ub.stk-line.sum-type   begins v-doc-line-root-sum-type[v-doc-line-root-sum-type-ind-ext]
            and ub.stk-line.shift-date <> ?
            then do:
              create temp-shift-stk-line .
  /*              buffer-copy ub.stk-line to temp-shift-stk-line*/
              &scop fp1 temp-shift-stk-line.
              &scop fp2 = ub.stk-line.
              assign
                {&stk-line-pair-list}
              .
              assign
                &scop fp1   temp-shift-stk-line.
                &scop fps1
                &scop fp2   = ub.stk-line.
                &scop fps2
                &scop fp3
                &scop fp4
                {&price-pair-list}
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
        end.
      end.
    end.
  end.
end procedure. /* init-temp-tables */


procedure process-doc-line :

  define variable v-host-code like ub.sysconf.host-code         no-undo.
  define variable v-cur-dn  as character no-undo .
  define variable v-price as decimal   no-undo .
  define variable v-cur-rt as decimal   no-undo .
  define variable v-cur-ex as decimal   no-undo .
  define variable v-b-pcode as integer   no-undo .
  define variable v-is-part-price as logical   no-undo .

  define buffer buf_tt-clcparts for tt-clcparts .
  define buffer buf_tt-allsum-line for tt-allsum-line .

  do
  on error undo, return error
  :

    { gbl/hostcode.i ub.doc-line.obj-type ub.doc-line.obj-code v-host-code }

    find first ub.goods no-lock
      where ub.goods.artic     = ub.doc-line.artic
        and ub.goods.prod-type = ub.doc-line.prod-type
        and ub.goods.prod-code = ub.doc-line.prod-code
      no-error .
    if not available goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Документ" ub.doc-line.doc-code skip
        "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
        view-as alert-box error .
      undo, return error .
    end.

    /* определяем общее количество по строке */
    if ub.goods.gds-type = {&gds-goods}
    then do:
      /* расчет учетной цены для товара */

      define variable v-doc-sign as integer   no-undo .

      if ub.trn-doc.doc-type = {&expense}
      or ub.trn-doc.doc-type = {&write-off}
      then do:
        assign
          v-doc-sign = -1
        .
      end.
      else do:
        assign
          v-doc-sign = 1
        .
      end.

      for each ub.parts no-lock
        where ub.parts.out-code  = ub.trn-doc.doc-code
          and ub.parts.obj-type  = ub.trn-doc.obj-type
          and ub.parts.obj-code  = ub.trn-doc.obj-code
          and ub.parts.artic     = ub.doc-line.artic
          and ub.parts.prod-type = ub.doc-line.prod-type
          and ub.parts.prod-code = ub.doc-line.prod-code
      on error undo, return error
      :
        for each buf_tt-clcparts
        on error undo, return error return-value
        :
          delete buf_tt-clcparts .
        end.

        create buf_tt-clcparts .
        buffer-copy ub.parts to buf_tt-clcparts .
        v-is-part-price = false .

        if ub.doc-line.is-parts = true  then do:
          { gbl/partbcod.i
            ub.parts
            v-b-pcode
            no-error
          }
           /* старые партии на которых не было баркода */
           if error-status :error or v-b-pcode = 0  or v-b-pcode = ? then do:
              v-is-part-price = false .
           end.
           else do:
             v-is-part-price = true  .
           end.
           if v-is-part-price = true  then do:
              { gbl/bcodeprc.i
                  ub.parts.obj-type
                  ub.parts.obj-code
                  v-b-pcode
                  0
                  ub.trn-doc.fact-order
                  v-cur-dn
                  v-price
                  v-cur-rt
                  v-cur-ex
                  no-error
                  }
              if error-status :error then do:
                v-price = ? .
              end.
           end.
        end.

        run clcprtsl_calc-ttable in this-procedure
          (input false /* paris-doc         */
          ,input (if v-is-part-price = true  then true else false) /* paris-cur         */
          ,input ?     /* parroad-tax       */
          ,input ?     /* parexcise         */
          ,input ?     /* parvat-pc         */
          ,input ?     /* parcons-vat-pc    */
          ,input ?     /* parslt-pc         */
          ,input ?     /* parbase-rate      */
          ,input ?     /* parbase-scale     */
          ,input ?     /* parr-b            */
          ,input (if v-is-part-price = true  then v-price else ? )     /* parcur-base       */
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
            "Документ" ub.doc-line.doc-code skip
            "Артикул " ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
            "Партия  " ub.parts.part-code skip
            ub.parts.in-code   skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.

        define variable v-cost-vat-pc as decimal   no-undo .
        define variable v-cost-slt-pc as decimal   no-undo .

        assign
          v-cost-vat-pc = ub.parts.vat-pc
          v-cost-slt-pc = ub.parts.slt-pc
        .

        find first buf_tt-allsum-line
          where buf_tt-allsum-line.sum-type = {&sum-general-sign}
          no-error .
        if available buf_tt-allsum-line
        then do:
          /* надо брать суммы с обратным знаком */
          assign
            v-fact-qnty      = - buf_tt-allsum-line.fact-qnty          * v-doc-sign
            v-sum-base       = - buf_tt-allsum-line.sum-dsc-base-acc   * v-doc-sign
            v-sum-rubl       = - buf_tt-allsum-line.sum-dsc-rubl-acc   * v-doc-sign
            v-vat-base       = - buf_tt-allsum-line.vat-base-acc       * v-doc-sign
            v-vat-rubl       = - buf_tt-allsum-line.vat-rubl-acc       * v-doc-sign
            v-slt-base       = - buf_tt-allsum-line.slt-base-acc       * v-doc-sign
            v-slt-rubl       = - buf_tt-allsum-line.slt-rubl-acc       * v-doc-sign
            v-road-tax-base  = - buf_tt-allsum-line.road-tax-base-acc  * v-doc-sign
            v-road-tax-rubl  = - buf_tt-allsum-line.road-tax-rubl-acc  * v-doc-sign
            v-excise-base    = - buf_tt-allsum-line.excise-base-acc    * v-doc-sign
            v-excise-rubl    = - buf_tt-allsum-line.excise-rubl-acc    * v-doc-sign
            v-transport-base = - buf_tt-allsum-line.transport-base-acc * v-doc-sign
            v-transport-rubl = - buf_tt-allsum-line.transport-rubl-acc * v-doc-sign
            v-other-base     = - buf_tt-allsum-line.other-base-acc     * v-doc-sign
            v-other-rubl     = - buf_tt-allsum-line.other-rubl-acc     * v-doc-sign
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
            "Программа clcprtsl.i вернула неопределенные значения в учетных ценах по партиям" skip
            "Расчет складского архива по товарам невозможен" skip
            "Документ" ub.doc-line.doc-code skip
            "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
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
        if v-cat-id[1] = ?
        or v-cat-id[2] = ?
        or v-cat-id[3] = ?
        or v-cat-id[4] = ?
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при расчете складского архива по товарам" skip
            "Не заданы налоги учетных цен" skip
            "Документ" ub.doc-line.doc-code skip
            "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
            "НДС" v-cost-vat-pc skip
            "НсП" v-cost-slt-pc skip
            view-as alert-box error .
          undo, return error .
        end.

        do ind-ext = 1 to 4
        :
          find first temp-ot-line
            where temp-ot-line.doc-code  = ub.doc-line.doc-code
              and temp-ot-line.artic     = ub.doc-line.artic
              and temp-ot-line.prod-type = ub.doc-line.prod-type
              and temp-ot-line.prod-code = ub.doc-line.prod-code
              and temp-ot-line.sum-type  = v-sum-type[ind-ext]
              and temp-ot-line.cat-id    = v-cat-id[ind-ext]
            no-error .
          if not available temp-ot-line
          then do:
            create temp-ot-line .
            assign
              temp-ot-line.doc-code     = ub.doc-line.doc-code
              temp-ot-line.artic        = ub.doc-line.artic
              temp-ot-line.prod-type    = ub.doc-line.prod-type
              temp-ot-line.prod-code    = ub.doc-line.prod-code
              temp-ot-line.sum-type     = v-sum-type[ind-ext]
              temp-ot-line.cat-id       = v-cat-id[ind-ext]
              temp-ot-line.ext-doc-type = ub.trn-doc.ext-doc-type
              temp-ot-line.obj-type     = ub.trn-doc.obj-type
              temp-ot-line.obj-code     = ub.trn-doc.obj-code
              temp-ot-line.fact-order   = v-ot-fact-order
            .
          end.
          assign
            &scop FT1    temp-ot-line.new-
            &scop FTs1
            &scop FT2    = temp-ot-line.new-
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
    else do:
      assign
        v-cost-vat-pc              = ub.doc-line.vat-pc
        v-cost-slt-pc              = ub.doc-line.slt-pc
      .

      /* расчет учетной цены для услуги */
      run clcprtsl_calc-line in this-procedure
        (input recid(ub.doc-line)
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при расчете сумм по документу" skip
          "Документ" ub.doc-line.doc-code skip
          "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      find first buf_tt-allsum-line
        where buf_tt-allsum-line.sum-type = {&sum-general-sign}
        no-error .
      if available buf_tt-allsum-line
      then do:
        assign
          v-fact-qnty      = buf_tt-allsum-line.fact-qnty
          v-sum-base       = buf_tt-allsum-line.sum-dsc-base-acc
          v-sum-rubl       = buf_tt-allsum-line.sum-dsc-rubl-acc
          v-vat-base       = buf_tt-allsum-line.vat-base-acc
          v-vat-rubl       = buf_tt-allsum-line.vat-rubl-acc
          v-slt-base       = buf_tt-allsum-line.slt-base-acc
          v-slt-rubl       = buf_tt-allsum-line.slt-rubl-acc
          v-road-tax-base  = buf_tt-allsum-line.road-tax-base-acc
          v-road-tax-rubl  = buf_tt-allsum-line.road-tax-rubl-acc
          v-excise-base    = buf_tt-allsum-line.excise-base-acc
          v-excise-rubl    = buf_tt-allsum-line.excise-rubl-acc
          v-transport-base = buf_tt-allsum-line.transport-base-acc
          v-transport-rubl = buf_tt-allsum-line.transport-rubl-acc
          v-other-base     = buf_tt-allsum-line.other-base-acc
          v-other-rubl     = buf_tt-allsum-line.other-rubl-acc
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
          "Программа clcprtsl.i вернула неопределенные значения в учетных ценах по строке" skip
          "Расчет складского архива по товарам невозможен" skip
          "Документ" ub.doc-line.doc-code skip
          "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
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

      assign
        v-sum-type[1] = {&arh-cost-service}
        v-cat-id[1]   = trim(string(v-cost-VAT-pc, ">99")) + "," + trim(string(v-cost-SLT-pc, ">99"))
        ind-ext = 1
      .
      if v-cat-id[1] = ?
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при расчете складского архива по товарам" skip
          "Не заданы налоги для услуг" skip
          "Документ" ub.doc-line.doc-code skip
          "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
          "НДС" v-cost-VAT-pc skip
          "НсП" v-cost-SLT-pc skip
          view-as alert-box error .
        undo, return error .
      end.
      find first temp-ot-line
        where temp-ot-line.doc-code  = ub.doc-line.doc-code
          and temp-ot-line.artic     = ub.doc-line.artic
          and temp-ot-line.prod-type = ub.doc-line.prod-type
          and temp-ot-line.prod-code = ub.doc-line.prod-code
          and temp-ot-line.sum-type  = v-sum-type[ind-ext]
          and temp-ot-line.cat-id    = v-cat-id[ind-ext]
        no-error .
      if not available temp-ot-line
      then do:
        create temp-ot-line .
        assign
          temp-ot-line.doc-code     = ub.doc-line.doc-code
          temp-ot-line.artic        = ub.doc-line.artic
          temp-ot-line.prod-type    = ub.doc-line.prod-type
          temp-ot-line.prod-code    = ub.doc-line.prod-code
          temp-ot-line.sum-type     = v-sum-type[ind-ext]
          temp-ot-line.cat-id       = v-cat-id[ind-ext]
          temp-ot-line.ext-doc-type = ub.trn-doc.ext-doc-type
          temp-ot-line.obj-type     = ub.trn-doc.obj-type
          temp-ot-line.obj-code     = ub.trn-doc.obj-code
          temp-ot-line.fact-order   = v-ot-fact-order
        .
      end.
      assign
        &scop FT1    temp-ot-line.new-
        &scop FTs1
        &scop FT2    = temp-ot-line.new-
        &scop FTs2
        &scop FT3    + v-
        &scop FTs3
        &scop FT4
        &scop FT5
        {&price-trio-list}
      .
    end.

    define variable v-sale-vat-pc as decimal   no-undo .
    define variable v-sale-slt-pc as decimal   no-undo .
    assign
      v-sale-vat-pc = ub.doc-line.vat-pc
      v-sale-slt-pc = ub.doc-line.slt-pc
    .

    run clcprtsl_calc-line in this-procedure
      (input recid(ub.doc-line)
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при расчете сумм по документу" skip
        "Документ" ub.doc-line.doc-code skip
        "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.


    /* расчет продажной цены документа с учетом скидок (ндс и нсп документа) */
    find first buf_tt-allsum-line
      where buf_tt-allsum-line.sum-type = {&sum-general-sign}
      no-error .
    if available buf_tt-allsum-line
    then do:
      assign
        v-fact-qnty     = buf_tt-allsum-line.fact-qnty
        v-sum-base      = buf_tt-allsum-line.sum-dsc-base-doc
        v-sum-rubl      = buf_tt-allsum-line.sum-dsc-rubl-doc
        v-vat-base      = buf_tt-allsum-line.vat-base-doc
        v-vat-rubl      = buf_tt-allsum-line.vat-rubl-doc
        v-slt-base      = buf_tt-allsum-line.slt-base-doc
        v-slt-rubl      = buf_tt-allsum-line.slt-rubl-doc
        v-road-tax-base = buf_tt-allsum-line.road-tax-base-doc
        v-road-tax-rubl = buf_tt-allsum-line.road-tax-rubl-doc
        v-excise-base   = buf_tt-allsum-line.excise-base-doc
        v-excise-rubl   = buf_tt-allsum-line.excise-rubl-doc
        v-other-base    = buf_tt-allsum-line.dsc-base-doc
        v-other-rubl    = buf_tt-allsum-line.dsc-rubl-doc
      .
    end.
    else do:
      assign
        v-fact-qnty     = 0
        v-sum-base      = 0
        v-sum-rubl      = 0
        v-vat-base      = 0
        v-vat-rubl      = 0
        v-slt-base      = 0
        v-slt-rubl      = 0
        v-road-tax-base = 0
        v-road-tax-rubl = 0
        v-excise-base   = 0
        v-excise-rubl   = 0
        v-other-base    = 0
        v-other-rubl    = 0
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
        "Программа clcprtsl.i вернула неопределенные значения в ценах по документу" skip
        "Расчет складского архива по товарам невозможен" skip
        "Документ" ub.doc-line.doc-code skip
        "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
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

    if ub.goods.gds-type = {&gds-goods}
    then do:
      /* запись информации о продажной цене товара */
      assign
        v-sum-type[1] = {&arh-sale}
        v-cat-id[1]   = trim(string(v-sale-VAT-pc, ">99")) + "," + trim(string(v-sale-SLT-pc, ">99"))
        ind-ext = 1
      .
    end.
    else do:
      /* запись информации о продажной цене услуги */
      assign
        v-sum-type[1] = {&arh-sale-service}
        v-cat-id[1]   = trim(string(v-sale-VAT-pc, ">99")) + "," + trim(string(v-sale-SLT-pc, ">99"))
        ind-ext = 1
      .
    end.

    if v-cat-id[1] = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при расчете складского архива по товарам" skip
        "Не заданы налоги в ценах документа" skip
        "Документ" ub.doc-line.doc-code skip
        "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
        "НДС" v-sale-VAT-pc skip
        "НсП" v-sale-SLT-pc skip
        view-as alert-box error .
      undo, return error .
    end.

    find first temp-ot-line
      where temp-ot-line.doc-code  = ub.doc-line.doc-code
        and temp-ot-line.artic     = ub.doc-line.artic
        and temp-ot-line.prod-type = ub.doc-line.prod-type
        and temp-ot-line.prod-code = ub.doc-line.prod-code
        and temp-ot-line.sum-type  = v-sum-type[ind-ext]
        and temp-ot-line.cat-id    = v-cat-id[ind-ext]
      no-error .
    if not available temp-ot-line
    then do:
      create temp-ot-line .
      assign
        temp-ot-line.doc-code     = ub.doc-line.doc-code
        temp-ot-line.artic        = ub.doc-line.artic
        temp-ot-line.prod-type    = ub.doc-line.prod-type
        temp-ot-line.prod-code    = ub.doc-line.prod-code
        temp-ot-line.sum-type     = v-sum-type[ind-ext]
        temp-ot-line.cat-id       = v-cat-id[ind-ext]
        temp-ot-line.ext-doc-type = ub.trn-doc.ext-doc-type
        temp-ot-line.obj-type     = ub.trn-doc.obj-type
        temp-ot-line.obj-code     = ub.trn-doc.obj-code
        temp-ot-line.fact-order   = v-ot-fact-order
      .
    end.
    assign
      &scop FT1    temp-ot-line.new-
      &scop FTs1
      &scop FT2    = temp-ot-line.new-
      &scop FTs2
      &scop FT3    + v-
      &scop FTs3
      &scop FT4
      &scop FT5
      {&price-trio-list}
    .

    define variable v-crsa-vat-pc as decimal   no-undo .
    define variable v-crsa-slt-pc as decimal   no-undo .

    /* расчет сумм по документу в текущих продажных ценах */
    /* определяем налоги для разбивки по НДС и НП */
    define variable v-b-code     as integer   no-undo .
    define variable v-doc-num    as character no-undo .
    define variable v-price-sale as decimal   no-undo .
    define variable v-road-tax   as decimal   no-undo .
    define variable v-excise     as decimal   no-undo .

    { gbl/gdsbcode.i
      ub.goods.gds-code
      ?
      v-b-code
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при поиске первичного бар-кода товара" skip
        "Документ" ub.doc-line.doc-code skip
        "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    { gbl/bcprcex.i
      ub.trn-doc.obj-type
      ub.trn-doc.obj-code
      v-b-code
      0
      ub.trn-doc.fact-order
      v-doc-num
      v-price-sale
      v-road-tax
      v-excise
      v-crsa-VAT-pc
      v-crsa-SLT-pc
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при поиске цены товара" skip
        "Документ" ub.doc-line.doc-code skip
        "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
        "Бар-код" v-b-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if v-doc-num = ?
    then do:
      assign
        v-crsa-vat-pc = 0
        v-crsa-slt-pc = 0
      .
    end.
    { gbl/pftxvalg.i
            ub.goods.gds-code
            {&vat-tax-code}
            ub.trn-doc.fact-date
            ub.trn-doc.host-code
            ub.trn-doc.obj-type
            ub.trn-doc.obj-code
            v-crsa-vat-pc
            no-error
          }
          
    if v-crsa-vat-pc = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при поиске НДС для товара на дату" skip
        "Документ" ub.trn-doc.doc-code skip
        "Код товара" ub.goods.gds-code skip
        "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
        "Переоценка" v-doc-num skip
        "Дата" ub.trn-doc.fact-date skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if v-crsa-slt-pc = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при поиске НП для товара на дату" skip
        "Документ" ub.trn-doc.doc-code skip
        "Код товара" ub.goods.gds-code skip
        "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
        "Переоценка" v-doc-num skip
        "Дата" ub.trn-doc.fact-date skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    find first buf_tt-allsum-line
      where buf_tt-allsum-line.sum-type = {&sum-general-sign}
      no-error .
    if available buf_tt-allsum-line
    then do:
      assign
        v-fact-qnty      = buf_tt-allsum-line.fact-qnty
        v-sum-base       = buf_tt-allsum-line.sum-dsc-base-cur
        v-sum-rubl       = buf_tt-allsum-line.sum-dsc-rubl-cur
        v-vat-base       = buf_tt-allsum-line.vat-base-cur
        v-vat-rubl       = buf_tt-allsum-line.vat-rubl-cur
        v-slt-base       = buf_tt-allsum-line.slt-base-cur
        v-slt-rubl       = buf_tt-allsum-line.slt-rubl-cur
        v-road-tax-base  = buf_tt-allsum-line.road-tax-base-cur
        v-road-tax-rubl  = buf_tt-allsum-line.road-tax-rubl-cur
        v-excise-base    = buf_tt-allsum-line.excise-base-cur
        v-excise-rubl    = buf_tt-allsum-line.excise-rubl-cur
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


    if
    &scop fl1  v-
    &scop fls1
    &scop fl2  = ?
    &scop fl3  or
    {&price-single-list}
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "При расчете складского архива по товарам в продажных ценах clcprtsl.i вернул неопределенные значения" skip
        "Расчет складского архива по товарам невозможен" skip
        "Документ" ub.doc-line.doc-code skip
        "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
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


    if ub.goods.gds-type = {&gds-goods}
    then do:
      /* запись информации о текущих продажных ценах товара */
      assign
        v-sum-type[1] = {&arh-crsa}
        v-cat-id[1]   = trim(string(v-crsa-VAT-pc, ">99")) + "," + trim(string(v-crsa-SLT-pc, ">99"))
        ind-ext = 1
      .
    end.
    else do:
      /* запись информации о текущих продажных ценах услуги */
      assign
        v-sum-type[1] = {&arh-crsa-service}
        v-cat-id[1]   = trim(string(v-crsa-VAT-pc, ">99")) + "," + trim(string(v-crsa-SLT-pc, ">99"))
        ind-ext = 1
      .
    end.

    if v-cat-id[1] = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при расчете складского архива по товарам" skip
        "Не заданы налоги в текущих продажных ценах" skip
        "Документ" ub.doc-line.doc-code skip
        "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
        "НДС" v-crsa-VAT-pc skip
        "НсП" v-crsa-SLT-pc skip
        view-as alert-box error .
      undo, return error .
    end.


    find first temp-ot-line
      where temp-ot-line.doc-code  = ub.doc-line.doc-code
        and temp-ot-line.artic     = ub.doc-line.artic
        and temp-ot-line.prod-type = ub.doc-line.prod-type
        and temp-ot-line.prod-code = ub.doc-line.prod-code
        and temp-ot-line.sum-type  = v-sum-type[ind-ext]
        and temp-ot-line.cat-id    = v-cat-id[ind-ext]
      no-error .
    if not available temp-ot-line
    then do:
      create temp-ot-line .
      assign
        temp-ot-line.doc-code     = ub.doc-line.doc-code
        temp-ot-line.artic        = ub.doc-line.artic
        temp-ot-line.prod-type    = ub.doc-line.prod-type
        temp-ot-line.prod-code    = ub.doc-line.prod-code
        temp-ot-line.sum-type     = v-sum-type[ind-ext]
        temp-ot-line.cat-id       = v-cat-id[ind-ext]
        temp-ot-line.ext-doc-type = ub.trn-doc.ext-doc-type
        temp-ot-line.obj-type     = ub.trn-doc.obj-type
        temp-ot-line.obj-code     = ub.trn-doc.obj-code
        temp-ot-line.fact-order   = v-ot-fact-order
      .
    end.
    assign
      &scop FT1    temp-ot-line.new-
      &scop FTs1
      &scop FT2    = temp-ot-line.new-
      &scop FTs2
      &scop FT3    + v-
      &scop FTs3
      &scop FT4
      &scop FT5
      {&price-trio-list}
    .
  end.
end procedure. /* process-doc-line */




procedure update-ot-tot :

  do
  on error undo, return error
  :

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
      if temp-ot-line.sum-type begins {&arh-cost}
      then do:
        find first temp-ot-tot
          where temp-ot-tot.doc-code = temp-ot-line.doc-code
            and temp-ot-tot.sum-type = temp-ot-line.sum-type
            and temp-ot-tot.cat-id   = temp-ot-line.cat-id
          no-error .
        if not available temp-ot-tot
        then do:
          create temp-ot-tot .
          assign
            temp-ot-tot.doc-code     = temp-ot-line.doc-code
            temp-ot-tot.sum-type     = temp-ot-line.sum-type
            temp-ot-tot.cat-id       = temp-ot-line.cat-id
            temp-ot-tot.ext-doc-type = ub.trn-doc.ext-doc-type
            temp-ot-tot.obj-type     = ub.trn-doc.obj-type
            temp-ot-tot.obj-code     = ub.trn-doc.obj-code
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

      if temp-ot-line.sum-type = {&arh-crsa}
      or temp-ot-line.sum-type = {&arh-sale}
      or temp-ot-line.sum-type = {&arh-sale-service}
      or temp-ot-line.sum-type = {&arh-crsa-service}
      or temp-ot-line.sum-type = {&arh-cost-service}
      then do:
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
          if not available temp-ot-tot
          then do:
            create temp-ot-tot .
            assign
              temp-ot-tot.doc-code = temp-ot-line.doc-code
              temp-ot-tot.sum-type = v-sum-type[ind-ext]
              temp-ot-tot.cat-id   = v-cat-id[ind-ext]
              temp-ot-tot.ext-doc-type = ub.trn-doc.ext-doc-type
              temp-ot-tot.obj-type     = ub.trn-doc.obj-type
              temp-ot-tot.obj-code     = ub.trn-doc.obj-code
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
    end.
  end.

end procedure. /* update-ot-tot */


procedure update-stk-table :

  do
  on error undo, return error
  :
    define buffer root-temp-stk-tot  for temp-stk-tot  .
    define buffer root-temp-stk-line for temp-stk-line .
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
        if not available temp-stk-tot
        then do:
          create temp-stk-tot .
          assign
            temp-stk-tot.obj-type   = temp-ot-tot.obj-type
            temp-stk-tot.obj-code   = temp-ot-tot.obj-code
            temp-stk-tot.fact-order = root-temp-stk-tot.fact-order
            temp-stk-tot.sum-type   = temp-ot-tot.sum-type
            temp-stk-tot.cat-id     = temp-ot-tot.cat-id
            temp-stk-tot.fact-date  = root-temp-stk-tot.fact-date
            temp-stk-tot.shift-num  = root-temp-stk-tot.shift-num
            temp-stk-tot.shift-date = root-temp-stk-tot.shift-date
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
      if v-shift-on
      then do:
        for each root-temp-shift-stk-tot
          where root-temp-shift-stk-tot.obj-type = temp-ot-tot.obj-type
            and root-temp-shift-stk-tot.obj-code = temp-ot-tot.obj-code
            and root-temp-shift-stk-tot.sum-type = {&arh-crsa}
            and root-temp-shift-stk-tot.cat-id   = {&root-cat-id}
        on error undo, return error
        :
          find first temp-shift-stk-tot
            where temp-shift-stk-tot.obj-type   = temp-ot-tot.obj-type
              and temp-shift-stk-tot.obj-code   = temp-ot-tot.obj-code
              and temp-shift-stk-tot.fact-order = root-temp-shift-stk-tot.fact-order
              and temp-shift-stk-tot.sum-type   = temp-ot-tot.sum-type
              and temp-shift-stk-tot.cat-id     = temp-ot-tot.cat-id
            no-error .
          if not available temp-shift-stk-tot
          then do:
            create temp-shift-stk-tot .
            assign
              temp-shift-stk-tot.obj-type   = temp-ot-tot.obj-type
              temp-shift-stk-tot.obj-code   = temp-ot-tot.obj-code
              temp-shift-stk-tot.fact-order = root-temp-shift-stk-tot.fact-order
              temp-shift-stk-tot.sum-type   = temp-ot-tot.sum-type
              temp-shift-stk-tot.cat-id     = temp-ot-tot.cat-id
              temp-shift-stk-tot.fact-date  = root-temp-shift-stk-tot.fact-date
              temp-shift-stk-tot.shift-num  = root-temp-shift-stk-tot.shift-num
              temp-shift-stk-tot.shift-date = root-temp-shift-stk-tot.shift-date
            .
          end.
          assign
            &scop fq1    temp-shift-stk-tot.new-
            &scop fqs1
            &scop fq2    = temp-shift-stk-tot.new-
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
    end.


    for each temp-ot-tot
      where temp-ot-tot.sum-type begins {&arh-cost}
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
          and root-temp-stk-tot.sum-type = {&arh-cost}
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
        if not available temp-stk-tot
        then do:
          create temp-stk-tot .
          assign
            temp-stk-tot.obj-type   = temp-ot-tot.obj-type
            temp-stk-tot.obj-code   = temp-ot-tot.obj-code
            temp-stk-tot.fact-order = root-temp-stk-tot.fact-order
            temp-stk-tot.sum-type   = temp-ot-tot.sum-type
            temp-stk-tot.cat-id     = temp-ot-tot.cat-id
            temp-stk-tot.fact-date  = root-temp-stk-tot.fact-date
            temp-stk-tot.shift-num  = root-temp-stk-tot.shift-num
            temp-stk-tot.shift-date = root-temp-stk-tot.shift-date
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
      if v-shift-on
      then do:
        for each root-temp-shift-stk-tot
          where root-temp-shift-stk-tot.obj-type = temp-ot-tot.obj-type
            and root-temp-shift-stk-tot.obj-code = temp-ot-tot.obj-code
            and root-temp-shift-stk-tot.sum-type = {&arh-cost}
            and root-temp-shift-stk-tot.cat-id   = {&root-cat-id}
        on error undo, return error
        :
          find first temp-shift-stk-tot
            where temp-shift-stk-tot.obj-type   = temp-ot-tot.obj-type
              and temp-shift-stk-tot.obj-code   = temp-ot-tot.obj-code
              and temp-shift-stk-tot.fact-order = root-temp-shift-stk-tot.fact-order
              and temp-shift-stk-tot.sum-type   = temp-ot-tot.sum-type
              and temp-shift-stk-tot.cat-id     = temp-ot-tot.cat-id
            no-error .
          if not available temp-shift-stk-tot
          then do:
            create temp-shift-stk-tot .
            assign
              temp-shift-stk-tot.obj-type   = temp-ot-tot.obj-type
              temp-shift-stk-tot.obj-code   = temp-ot-tot.obj-code
              temp-shift-stk-tot.fact-order = root-temp-shift-stk-tot.fact-order
              temp-shift-stk-tot.sum-type   = temp-ot-tot.sum-type
              temp-shift-stk-tot.cat-id     = temp-ot-tot.cat-id
              temp-shift-stk-tot.fact-date  = root-temp-shift-stk-tot.fact-date
              temp-shift-stk-tot.shift-num  = root-temp-shift-stk-tot.shift-num
              temp-shift-stk-tot.shift-date = root-temp-shift-stk-tot.shift-date
            .
          end.
          assign
            &scop fq1    temp-shift-stk-tot.new-
            &scop fqs1
            &scop fq2    = temp-shift-stk-tot.new-
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
    end.

    for each temp-ot-tot
      where temp-ot-tot.sum-type = {&arh-sale}
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
          and root-temp-stk-tot.sum-type = {&arh-sadt} + ub.trn-doc.ext-doc-type
          and root-temp-stk-tot.cat-id   = {&root-cat-id}
      on error undo, return error
      :
        find first temp-stk-tot
          where temp-stk-tot.obj-type   = temp-ot-tot.obj-type
            and temp-stk-tot.obj-code   = temp-ot-tot.obj-code
            and temp-stk-tot.fact-order = root-temp-stk-tot.fact-order
            and temp-stk-tot.sum-type   = root-temp-stk-tot.sum-type
            and temp-stk-tot.cat-id     = {&root-cat-id}
          no-error .
        if not available temp-stk-tot
        then do:
          create temp-stk-tot .
          assign
            temp-stk-tot.obj-type   = temp-ot-tot.obj-type
            temp-stk-tot.obj-code   = temp-ot-tot.obj-code
            temp-stk-tot.fact-order = root-temp-stk-tot.fact-order
            temp-stk-tot.sum-type   = root-temp-stk-tot.sum-type
            temp-stk-tot.cat-id     = {&root-cat-id}
            temp-stk-tot.fact-date  = root-temp-stk-tot.fact-date
            temp-stk-tot.shift-num  = root-temp-stk-tot.shift-num
            temp-stk-tot.shift-date = root-temp-stk-tot.shift-date
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
      if v-shift-on
      then do:
        for each root-temp-shift-stk-tot
          where root-temp-shift-stk-tot.obj-type = temp-ot-tot.obj-type
            and root-temp-shift-stk-tot.obj-code = temp-ot-tot.obj-code
            and root-temp-shift-stk-tot.sum-type = {&arh-sadt} + ub.trn-doc.ext-doc-type
            and root-temp-shift-stk-tot.cat-id   = {&root-cat-id}
        on error undo, return error
        :
          find first temp-shift-stk-tot
            where temp-shift-stk-tot.obj-type   = temp-ot-tot.obj-type
              and temp-shift-stk-tot.obj-code   = temp-ot-tot.obj-code
              and temp-shift-stk-tot.fact-order = root-temp-shift-stk-tot.fact-order
              and temp-shift-stk-tot.sum-type   = root-temp-shift-stk-tot.sum-type
              and temp-shift-stk-tot.cat-id     = {&root-cat-id}
            no-error .
          if not available temp-shift-stk-tot
          then do:
            create temp-shift-stk-tot .
            assign
              temp-shift-stk-tot.obj-type   = temp-ot-tot.obj-type
              temp-shift-stk-tot.obj-code   = temp-ot-tot.obj-code
              temp-shift-stk-tot.fact-order = root-temp-shift-stk-tot.fact-order
              temp-shift-stk-tot.sum-type   = root-temp-shift-stk-tot.sum-type
              temp-shift-stk-tot.cat-id     = {&root-cat-id}
              temp-shift-stk-tot.fact-date  = root-temp-shift-stk-tot.fact-date
              temp-shift-stk-tot.shift-num  = root-temp-shift-stk-tot.shift-num
              temp-shift-stk-tot.shift-date = root-temp-shift-stk-tot.shift-date
            .
          end.
          assign
            &scop fq1    temp-shift-stk-tot.new-
            &scop fqs1
            &scop fq2    = temp-shift-stk-tot.new-
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
    end.

    for each temp-ot-tot
      where temp-ot-tot.sum-type = {&arh-sale-service}
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
          and root-temp-stk-tot.sum-type = {&arh-sadt-service} + ub.trn-doc.ext-doc-type
          and root-temp-stk-tot.cat-id   = {&root-cat-id}
      on error undo, return error
      :
        find first temp-stk-tot
          where temp-stk-tot.obj-type   = temp-ot-tot.obj-type
            and temp-stk-tot.obj-code   = temp-ot-tot.obj-code
            and temp-stk-tot.fact-order = root-temp-stk-tot.fact-order
            and temp-stk-tot.sum-type   = root-temp-stk-tot.sum-type
            and temp-stk-tot.cat-id     = {&root-cat-id}
          no-error .
        if not available temp-stk-tot
        then do:
          create temp-stk-tot .
          assign
            temp-stk-tot.obj-type   = temp-ot-tot.obj-type
            temp-stk-tot.obj-code   = temp-ot-tot.obj-code
            temp-stk-tot.fact-order = root-temp-stk-tot.fact-order
            temp-stk-tot.sum-type   = root-temp-stk-tot.sum-type
            temp-stk-tot.cat-id     = {&root-cat-id}
            temp-stk-tot.fact-date  = root-temp-stk-tot.fact-date
            temp-stk-tot.shift-num  = root-temp-stk-tot.shift-num
            temp-stk-tot.shift-date = root-temp-stk-tot.shift-date
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
      if v-shift-on
      then do:
        for each root-temp-shift-stk-tot
          where root-temp-shift-stk-tot.obj-type = temp-ot-tot.obj-type
            and root-temp-shift-stk-tot.obj-code = temp-ot-tot.obj-code
            and root-temp-shift-stk-tot.sum-type = {&arh-sadt-service} + ub.trn-doc.ext-doc-type
            and root-temp-shift-stk-tot.cat-id   = {&root-cat-id}
        on error undo, return error
        :
          find first temp-shift-stk-tot
            where temp-shift-stk-tot.obj-type   = temp-ot-tot.obj-type
              and temp-shift-stk-tot.obj-code   = temp-ot-tot.obj-code
              and temp-shift-stk-tot.fact-order = root-temp-shift-stk-tot.fact-order
              and temp-shift-stk-tot.sum-type   = root-temp-shift-stk-tot.sum-type
              and temp-shift-stk-tot.cat-id     = {&root-cat-id}
            no-error .
          if not available temp-shift-stk-tot
          then do:
            create temp-shift-stk-tot .
            assign
              temp-shift-stk-tot.obj-type   = temp-ot-tot.obj-type
              temp-shift-stk-tot.obj-code   = temp-ot-tot.obj-code
              temp-shift-stk-tot.fact-order = root-temp-shift-stk-tot.fact-order
              temp-shift-stk-tot.sum-type   = root-temp-shift-stk-tot.sum-type
              temp-shift-stk-tot.cat-id     = {&root-cat-id}
              temp-shift-stk-tot.fact-date  = root-temp-shift-stk-tot.fact-date
              temp-shift-stk-tot.shift-num  = root-temp-shift-stk-tot.shift-num
              temp-shift-stk-tot.shift-date = root-temp-shift-stk-tot.shift-date
            .
          end.
          assign
            &scop fq1    temp-shift-stk-tot.new-
            &scop fqs1
            &scop fq2    = temp-shift-stk-tot.new-
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
          and root-temp-stk-tot.sum-type = {&arh-cgdt} + ub.trn-doc.ext-doc-type
          and root-temp-stk-tot.cat-id   = {&root-cat-id}
      on error undo, return error
      :
        find first temp-stk-tot
          where temp-stk-tot.obj-type   = temp-ot-tot.obj-type
            and temp-stk-tot.obj-code   = temp-ot-tot.obj-code
            and temp-stk-tot.fact-order = root-temp-stk-tot.fact-order
            and temp-stk-tot.sum-type   = root-temp-stk-tot.sum-type
            and temp-stk-tot.cat-id     = {&root-cat-id}
          no-error .
        if not available temp-stk-tot
        then do:
          create temp-stk-tot .
          assign
            temp-stk-tot.obj-type   = temp-ot-tot.obj-type
            temp-stk-tot.obj-code   = temp-ot-tot.obj-code
            temp-stk-tot.fact-order = root-temp-stk-tot.fact-order
            temp-stk-tot.sum-type   = root-temp-stk-tot.sum-type
            temp-stk-tot.cat-id     = {&root-cat-id}
            temp-stk-tot.fact-date  = root-temp-stk-tot.fact-date
            temp-stk-tot.shift-num  = root-temp-stk-tot.shift-num
            temp-stk-tot.shift-date = root-temp-stk-tot.shift-date
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
      if v-shift-on
      then do:
        for each root-temp-shift-stk-tot
          where root-temp-shift-stk-tot.obj-type = temp-ot-tot.obj-type
            and root-temp-shift-stk-tot.obj-code = temp-ot-tot.obj-code
            and root-temp-shift-stk-tot.sum-type = {&arh-cgdt} + ub.trn-doc.ext-doc-type
            and root-temp-shift-stk-tot.cat-id   = {&root-cat-id}
        on error undo, return error
        :
          find first temp-shift-stk-tot
            where temp-shift-stk-tot.obj-type   = temp-ot-tot.obj-type
              and temp-shift-stk-tot.obj-code   = temp-ot-tot.obj-code
              and temp-shift-stk-tot.fact-order = root-temp-shift-stk-tot.fact-order
              and temp-shift-stk-tot.sum-type   = root-temp-shift-stk-tot.sum-type
              and temp-shift-stk-tot.cat-id     = {&root-cat-id}
            no-error .
          if not available temp-shift-stk-tot
          then do:
            create temp-shift-stk-tot .
            assign
              temp-shift-stk-tot.obj-type   = temp-ot-tot.obj-type
              temp-shift-stk-tot.obj-code   = temp-ot-tot.obj-code
              temp-shift-stk-tot.fact-order = root-temp-shift-stk-tot.fact-order
              temp-shift-stk-tot.sum-type   = root-temp-shift-stk-tot.sum-type
              temp-shift-stk-tot.cat-id     = {&root-cat-id}
              temp-shift-stk-tot.fact-date  = root-temp-shift-stk-tot.fact-date
              temp-shift-stk-tot.shift-num  = root-temp-shift-stk-tot.shift-num
              temp-shift-stk-tot.shift-date = root-temp-shift-stk-tot.shift-date
            .
          end.
          assign
            &scop fq1    temp-shift-stk-tot.new-
            &scop fqs1
            &scop fq2    = temp-shift-stk-tot.new-
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
    end.


    for each temp-ot-tot
      where temp-ot-tot.sum-type = {&arh-crsa-service}
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
          and root-temp-stk-tot.sum-type = {&arh-cgdt-service} + ub.trn-doc.ext-doc-type
          and root-temp-stk-tot.cat-id   = {&root-cat-id}
      on error undo, return error
      :
        find first temp-stk-tot
          where temp-stk-tot.obj-type   = temp-ot-tot.obj-type
            and temp-stk-tot.obj-code   = temp-ot-tot.obj-code
            and temp-stk-tot.fact-order = root-temp-stk-tot.fact-order
            and temp-stk-tot.sum-type   = root-temp-stk-tot.sum-type
            and temp-stk-tot.cat-id     = {&root-cat-id}
          no-error .
        if not available temp-stk-tot
        then do:
          create temp-stk-tot .
          assign
            temp-stk-tot.obj-type   = temp-ot-tot.obj-type
            temp-stk-tot.obj-code   = temp-ot-tot.obj-code
            temp-stk-tot.fact-order = root-temp-stk-tot.fact-order
            temp-stk-tot.sum-type   = root-temp-stk-tot.sum-type
            temp-stk-tot.cat-id     = {&root-cat-id}
            temp-stk-tot.fact-date  = root-temp-stk-tot.fact-date
            temp-stk-tot.shift-num  = root-temp-stk-tot.shift-num
            temp-stk-tot.shift-date = root-temp-stk-tot.shift-date
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
      if v-shift-on
      then do:
        for each root-temp-shift-stk-tot
          where root-temp-shift-stk-tot.obj-type = temp-ot-tot.obj-type
            and root-temp-shift-stk-tot.obj-code = temp-ot-tot.obj-code
            and root-temp-shift-stk-tot.sum-type = {&arh-cgdt-service} + ub.trn-doc.ext-doc-type
            and root-temp-shift-stk-tot.cat-id   = {&root-cat-id}
        on error undo, return error
        :
          find first temp-shift-stk-tot
            where temp-shift-stk-tot.obj-type   = temp-ot-tot.obj-type
              and temp-shift-stk-tot.obj-code   = temp-ot-tot.obj-code
              and temp-shift-stk-tot.fact-order = root-temp-shift-stk-tot.fact-order
              and temp-shift-stk-tot.sum-type   = root-temp-shift-stk-tot.sum-type
              and temp-shift-stk-tot.cat-id     = {&root-cat-id}
            no-error .
          if not available temp-shift-stk-tot
          then do:
            create temp-shift-stk-tot .
            assign
              temp-shift-stk-tot.obj-type   = temp-ot-tot.obj-type
              temp-shift-stk-tot.obj-code   = temp-ot-tot.obj-code
              temp-shift-stk-tot.fact-order = root-temp-shift-stk-tot.fact-order
              temp-shift-stk-tot.sum-type   = root-temp-shift-stk-tot.sum-type
              temp-shift-stk-tot.cat-id     = {&root-cat-id}
              temp-shift-stk-tot.fact-date  = root-temp-shift-stk-tot.fact-date
              temp-shift-stk-tot.shift-num  = root-temp-shift-stk-tot.shift-num
              temp-shift-stk-tot.shift-date = root-temp-shift-stk-tot.shift-date
            .
          end.
          assign
            &scop fq1    temp-shift-stk-tot.new-
            &scop fqs1
            &scop fq2    = temp-shift-stk-tot.new-
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
    end.


    for each temp-ot-tot
      where temp-ot-tot.sum-type = {&arh-cost}
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
          and root-temp-stk-tot.sum-type = {&arh-csdt} + ub.trn-doc.ext-doc-type
          and root-temp-stk-tot.cat-id   = {&root-cat-id}
      on error undo, return error
      :
        find first temp-stk-tot
          where temp-stk-tot.obj-type   = temp-ot-tot.obj-type
            and temp-stk-tot.obj-code   = temp-ot-tot.obj-code
            and temp-stk-tot.fact-order = root-temp-stk-tot.fact-order
            and temp-stk-tot.sum-type   = root-temp-stk-tot.sum-type
            and temp-stk-tot.cat-id     = {&root-cat-id}
          no-error .
        if not available temp-stk-tot
        then do:
          create temp-stk-tot .
          assign
            temp-stk-tot.obj-type   = temp-ot-tot.obj-type
            temp-stk-tot.obj-code   = temp-ot-tot.obj-code
            temp-stk-tot.fact-order = root-temp-stk-tot.fact-order
            temp-stk-tot.sum-type   = root-temp-stk-tot.sum-type
            temp-stk-tot.cat-id     = {&root-cat-id}
            temp-stk-tot.fact-date  = root-temp-stk-tot.fact-date
            temp-stk-tot.shift-num  = root-temp-stk-tot.shift-num
            temp-stk-tot.shift-date = root-temp-stk-tot.shift-date
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
      if v-shift-on
      then do:
        for each root-temp-shift-stk-tot
          where root-temp-shift-stk-tot.obj-type = temp-ot-tot.obj-type
            and root-temp-shift-stk-tot.obj-code = temp-ot-tot.obj-code
            and root-temp-shift-stk-tot.sum-type = {&arh-csdt} + ub.trn-doc.ext-doc-type
            and root-temp-shift-stk-tot.cat-id   = {&root-cat-id}
        on error undo, return error
        :
          find first temp-shift-stk-tot
            where temp-shift-stk-tot.obj-type   = temp-ot-tot.obj-type
              and temp-shift-stk-tot.obj-code   = temp-ot-tot.obj-code
              and temp-shift-stk-tot.fact-order = root-temp-shift-stk-tot.fact-order
              and temp-shift-stk-tot.sum-type   = root-temp-shift-stk-tot.sum-type
              and temp-shift-stk-tot.cat-id     = {&root-cat-id}
            no-error .
          if not available temp-shift-stk-tot
          then do:
            create temp-shift-stk-tot .
            assign
              temp-shift-stk-tot.obj-type   = temp-ot-tot.obj-type
              temp-shift-stk-tot.obj-code   = temp-ot-tot.obj-code
              temp-shift-stk-tot.fact-order = root-temp-shift-stk-tot.fact-order
              temp-shift-stk-tot.sum-type   = root-temp-shift-stk-tot.sum-type
              temp-shift-stk-tot.cat-id     = {&root-cat-id}
              temp-shift-stk-tot.fact-date  = root-temp-shift-stk-tot.fact-date
              temp-shift-stk-tot.shift-num  = root-temp-shift-stk-tot.shift-num
              temp-shift-stk-tot.shift-date = root-temp-shift-stk-tot.shift-date
            .
          end.
          assign
            &scop fq1    temp-shift-stk-tot.new-
            &scop fqs1
            &scop fq2    = temp-shift-stk-tot.new-
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
    end.

    for each temp-ot-tot
      where temp-ot-tot.sum-type = {&arh-cost-service}
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
          and root-temp-stk-tot.sum-type = {&arh-csdt-service} + ub.trn-doc.ext-doc-type
          and root-temp-stk-tot.cat-id   = {&root-cat-id}
      on error undo, return error
      :
        find first temp-stk-tot
          where temp-stk-tot.obj-type   = temp-ot-tot.obj-type
            and temp-stk-tot.obj-code   = temp-ot-tot.obj-code
            and temp-stk-tot.fact-order = root-temp-stk-tot.fact-order
            and temp-stk-tot.sum-type   = root-temp-stk-tot.sum-type
            and temp-stk-tot.cat-id     = {&root-cat-id}
          no-error .
        if not available temp-stk-tot
        then do:
          create temp-stk-tot .
          assign
            temp-stk-tot.obj-type   = temp-ot-tot.obj-type
            temp-stk-tot.obj-code   = temp-ot-tot.obj-code
            temp-stk-tot.fact-order = root-temp-stk-tot.fact-order
            temp-stk-tot.sum-type   = root-temp-stk-tot.sum-type
            temp-stk-tot.cat-id     = {&root-cat-id}
            temp-stk-tot.fact-date  = root-temp-stk-tot.fact-date
            temp-stk-tot.shift-num  = root-temp-stk-tot.shift-num
            temp-stk-tot.shift-date = root-temp-stk-tot.shift-date
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
      if v-shift-on
      then do:
        for each root-temp-shift-stk-tot
          where root-temp-shift-stk-tot.obj-type = temp-ot-tot.obj-type
            and root-temp-shift-stk-tot.obj-code = temp-ot-tot.obj-code
            and root-temp-shift-stk-tot.sum-type = {&arh-csdt-service} + ub.trn-doc.ext-doc-type
            and root-temp-shift-stk-tot.cat-id   = {&root-cat-id}
        on error undo, return error
        :
          find first temp-shift-stk-tot
            where temp-shift-stk-tot.obj-type   = temp-ot-tot.obj-type
              and temp-shift-stk-tot.obj-code   = temp-ot-tot.obj-code
              and temp-shift-stk-tot.fact-order = root-temp-shift-stk-tot.fact-order
              and temp-shift-stk-tot.sum-type   = root-temp-shift-stk-tot.sum-type
              and temp-shift-stk-tot.cat-id     = {&root-cat-id}
            no-error .
          if not available temp-shift-stk-tot
          then do:
            create temp-shift-stk-tot .
            assign
              temp-shift-stk-tot.obj-type   = temp-ot-tot.obj-type
              temp-shift-stk-tot.obj-code   = temp-ot-tot.obj-code
              temp-shift-stk-tot.fact-order = root-temp-shift-stk-tot.fact-order
              temp-shift-stk-tot.sum-type   = root-temp-shift-stk-tot.sum-type
              temp-shift-stk-tot.cat-id     = {&root-cat-id}
              temp-shift-stk-tot.fact-date  = root-temp-shift-stk-tot.fact-date
              temp-shift-stk-tot.shift-num  = root-temp-shift-stk-tot.shift-num
              temp-shift-stk-tot.shift-date = root-temp-shift-stk-tot.shift-date
            .
          end.
          assign
            &scop fq1    temp-shift-stk-tot.new-
            &scop fqs1
            &scop fq2    = temp-shift-stk-tot.new-
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
          and root-temp-stk-line.sum-type  = {&arh-crsa}
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
        if not available temp-stk-line
        then do:
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
            temp-stk-line.shift-num  = root-temp-stk-line.shift-num
            temp-stk-line.shift-date = root-temp-stk-line.shift-date
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
      if v-shift-on
      then do:
        for each root-temp-shift-stk-line
          where root-temp-shift-stk-line.obj-type  = temp-ot-line.obj-type
            and root-temp-shift-stk-line.obj-code  = temp-ot-line.obj-code
            and root-temp-shift-stk-line.artic     = temp-ot-line.artic
            and root-temp-shift-stk-line.prod-type = temp-ot-line.prod-type
            and root-temp-shift-stk-line.prod-code = temp-ot-line.prod-code
            and root-temp-shift-stk-line.sum-type  = {&arh-crsa}
            and root-temp-shift-stk-line.cat-id    = {&root-cat-id}
        on error undo, return error
        :
          find first temp-shift-stk-line
            where temp-shift-stk-line.obj-type   = temp-ot-line.obj-type
              and temp-shift-stk-line.obj-code   = temp-ot-line.obj-code
              and temp-shift-stk-line.artic      = temp-ot-line.artic
              and temp-shift-stk-line.prod-type  = temp-ot-line.prod-type
              and temp-shift-stk-line.prod-code  = temp-ot-line.prod-code
              and temp-shift-stk-line.fact-order = root-temp-shift-stk-line.fact-order
              and temp-shift-stk-line.sum-type   = root-temp-shift-stk-line.sum-type
              and temp-shift-stk-line.cat-id     = {&root-cat-id}
            no-error .
          if not available temp-shift-stk-line
          then do:
            create temp-shift-stk-line .
            assign
              temp-shift-stk-line.obj-type   = temp-ot-line.obj-type
              temp-shift-stk-line.obj-code   = temp-ot-line.obj-code
              temp-shift-stk-line.artic      = temp-ot-line.artic
              temp-shift-stk-line.prod-type  = temp-ot-line.prod-type
              temp-shift-stk-line.prod-code  = temp-ot-line.prod-code
              temp-shift-stk-line.fact-order = root-temp-shift-stk-line.fact-order
              temp-shift-stk-line.sum-type   = root-temp-shift-stk-line.sum-type
              temp-shift-stk-line.cat-id     = {&root-cat-id}
              temp-shift-stk-line.fact-date  = root-temp-shift-stk-line.fact-date
              temp-shift-stk-line.shift-num  = root-temp-shift-stk-line.shift-num
              temp-shift-stk-line.shift-date = root-temp-shift-stk-line.shift-date
            .
          end.
          assign
            &scop fq1    temp-shift-stk-line.new-
            &scop fqs1
            &scop fq2    = temp-shift-stk-line.new-
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
    end.

    for each temp-ot-line
      where temp-ot-line.sum-type begins {&arh-cost}
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
          and root-temp-stk-line.sum-type  = {&arh-cost}
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
            and temp-stk-line.sum-type   = temp-ot-line.sum-type
            and temp-stk-line.cat-id     = temp-ot-line.cat-id
          no-error .
        if not available temp-stk-line
        then do:
          create temp-stk-line .
          assign
            temp-stk-line.obj-type   = temp-ot-line.obj-type
            temp-stk-line.obj-code   = temp-ot-line.obj-code
            temp-stk-line.artic      = temp-ot-line.artic
            temp-stk-line.prod-type  = temp-ot-line.prod-type
            temp-stk-line.prod-code  = temp-ot-line.prod-code
            temp-stk-line.fact-order = root-temp-stk-line.fact-order
            temp-stk-line.sum-type   = temp-ot-line.sum-type
            temp-stk-line.cat-id     = temp-ot-line.cat-id
            temp-stk-line.fact-date  = root-temp-stk-line.fact-date
            temp-stk-line.shift-num  = root-temp-stk-line.shift-num
            temp-stk-line.shift-date = root-temp-stk-line.shift-date
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
      if v-shift-on
      then do:
        for each root-temp-shift-stk-line
          where root-temp-shift-stk-line.obj-type  = temp-ot-line.obj-type
            and root-temp-shift-stk-line.obj-code  = temp-ot-line.obj-code
            and root-temp-shift-stk-line.artic     = temp-ot-line.artic
            and root-temp-shift-stk-line.prod-type = temp-ot-line.prod-type
            and root-temp-shift-stk-line.prod-code = temp-ot-line.prod-code
            and root-temp-shift-stk-line.sum-type  = {&arh-cost}
            and root-temp-shift-stk-line.cat-id    = {&root-cat-id}
        on error undo, return error
        :
          find first temp-shift-stk-line
            where temp-shift-stk-line.obj-type   = temp-ot-line.obj-type
              and temp-shift-stk-line.obj-code   = temp-ot-line.obj-code
              and temp-shift-stk-line.artic      = temp-ot-line.artic
              and temp-shift-stk-line.prod-type  = temp-ot-line.prod-type
              and temp-shift-stk-line.prod-code  = temp-ot-line.prod-code
              and temp-shift-stk-line.fact-order = root-temp-shift-stk-line.fact-order
              and temp-shift-stk-line.sum-type   = temp-ot-line.sum-type
              and temp-shift-stk-line.cat-id     = temp-ot-line.cat-id
            no-error .
          if not available temp-shift-stk-line
          then do:
            create temp-shift-stk-line .
            assign
              temp-shift-stk-line.obj-type   = temp-ot-line.obj-type
              temp-shift-stk-line.obj-code   = temp-ot-line.obj-code
              temp-shift-stk-line.artic      = temp-ot-line.artic
              temp-shift-stk-line.prod-type  = temp-ot-line.prod-type
              temp-shift-stk-line.prod-code  = temp-ot-line.prod-code
              temp-shift-stk-line.fact-order = root-temp-shift-stk-line.fact-order
              temp-shift-stk-line.sum-type   = temp-ot-line.sum-type
              temp-shift-stk-line.cat-id     = temp-ot-line.cat-id
              temp-shift-stk-line.fact-date  = root-temp-shift-stk-line.fact-date
              temp-shift-stk-line.shift-num  = root-temp-shift-stk-line.shift-num
              temp-shift-stk-line.shift-date = root-temp-shift-stk-line.shift-date
            .
          end.
          assign
            &scop fq1    temp-shift-stk-line.new-
            &scop fqs1
            &scop fq2    = temp-shift-stk-line.new-
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
    end.


    for each temp-ot-line
      where temp-ot-line.sum-type = {&arh-sale}
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
          and root-temp-stk-line.sum-type  = {&arh-sadt} + ub.trn-doc.ext-doc-type
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
        if not available temp-stk-line
        then do:
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
            temp-stk-line.shift-num  = root-temp-stk-line.shift-num
            temp-stk-line.shift-date = root-temp-stk-line.shift-date
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
      if v-shift-on
      then do:
        for each root-temp-shift-stk-line
          where root-temp-shift-stk-line.obj-type  = temp-ot-line.obj-type
            and root-temp-shift-stk-line.obj-code  = temp-ot-line.obj-code
            and root-temp-shift-stk-line.artic     = temp-ot-line.artic
            and root-temp-shift-stk-line.prod-type = temp-ot-line.prod-type
            and root-temp-shift-stk-line.prod-code = temp-ot-line.prod-code
            and root-temp-shift-stk-line.sum-type  = {&arh-sadt} + ub.trn-doc.ext-doc-type
            and root-temp-shift-stk-line.cat-id    = {&root-cat-id}
        on error undo, return error
        :
          find first temp-shift-stk-line
            where temp-shift-stk-line.obj-type   = temp-ot-line.obj-type
              and temp-shift-stk-line.obj-code   = temp-ot-line.obj-code
              and temp-shift-stk-line.artic      = temp-ot-line.artic
              and temp-shift-stk-line.prod-type  = temp-ot-line.prod-type
              and temp-shift-stk-line.prod-code  = temp-ot-line.prod-code
              and temp-shift-stk-line.fact-order = root-temp-shift-stk-line.fact-order
              and temp-shift-stk-line.sum-type   = root-temp-shift-stk-line.sum-type
              and temp-shift-stk-line.cat-id     = {&root-cat-id}
            no-error .
          if not available temp-shift-stk-line
          then do:
            create temp-shift-stk-line .
            assign
              temp-shift-stk-line.obj-type   = temp-ot-line.obj-type
              temp-shift-stk-line.obj-code   = temp-ot-line.obj-code
              temp-shift-stk-line.artic      = temp-ot-line.artic
              temp-shift-stk-line.prod-type  = temp-ot-line.prod-type
              temp-shift-stk-line.prod-code  = temp-ot-line.prod-code
              temp-shift-stk-line.fact-order = root-temp-shift-stk-line.fact-order
              temp-shift-stk-line.sum-type   = root-temp-shift-stk-line.sum-type
              temp-shift-stk-line.cat-id     = {&root-cat-id}
              temp-shift-stk-line.fact-date  = root-temp-shift-stk-line.fact-date
              temp-shift-stk-line.shift-num  = root-temp-shift-stk-line.shift-num
              temp-shift-stk-line.shift-date = root-temp-shift-stk-line.shift-date
            .
          end.
          assign
            &scop fq1    temp-shift-stk-line.new-
            &scop fqs1
            &scop fq2    = temp-shift-stk-line.new-
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
    end.

    for each temp-ot-line
      where temp-ot-line.sum-type = {&arh-sale-service}
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
          and root-temp-stk-line.sum-type  = {&arh-sadt-service} + ub.trn-doc.ext-doc-type
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
        if not available temp-stk-line
        then do:
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
            temp-stk-line.shift-num  = root-temp-stk-line.shift-num
            temp-stk-line.shift-date = root-temp-stk-line.shift-date
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
      if v-shift-on
      then do:
        for each root-temp-shift-stk-line
          where root-temp-shift-stk-line.obj-type  = temp-ot-line.obj-type
            and root-temp-shift-stk-line.obj-code  = temp-ot-line.obj-code
            and root-temp-shift-stk-line.artic     = temp-ot-line.artic
            and root-temp-shift-stk-line.prod-type = temp-ot-line.prod-type
            and root-temp-shift-stk-line.prod-code = temp-ot-line.prod-code
            and root-temp-shift-stk-line.sum-type  = {&arh-sadt-service} + ub.trn-doc.ext-doc-type
            and root-temp-shift-stk-line.cat-id    = {&root-cat-id}
        on error undo, return error
        :
          find first temp-shift-stk-line
            where temp-shift-stk-line.obj-type   = temp-ot-line.obj-type
              and temp-shift-stk-line.obj-code   = temp-ot-line.obj-code
              and temp-shift-stk-line.artic      = temp-ot-line.artic
              and temp-shift-stk-line.prod-type  = temp-ot-line.prod-type
              and temp-shift-stk-line.prod-code  = temp-ot-line.prod-code
              and temp-shift-stk-line.fact-order = root-temp-shift-stk-line.fact-order
              and temp-shift-stk-line.sum-type   = root-temp-shift-stk-line.sum-type
              and temp-shift-stk-line.cat-id     = {&root-cat-id}
            no-error .
          if not available temp-shift-stk-line
          then do:
            create temp-shift-stk-line .
            assign
              temp-shift-stk-line.obj-type   = temp-ot-line.obj-type
              temp-shift-stk-line.obj-code   = temp-ot-line.obj-code
              temp-shift-stk-line.artic      = temp-ot-line.artic
              temp-shift-stk-line.prod-type  = temp-ot-line.prod-type
              temp-shift-stk-line.prod-code  = temp-ot-line.prod-code
              temp-shift-stk-line.fact-order = root-temp-shift-stk-line.fact-order
              temp-shift-stk-line.sum-type   = root-temp-shift-stk-line.sum-type
              temp-shift-stk-line.cat-id     = {&root-cat-id}
              temp-shift-stk-line.fact-date  = root-temp-shift-stk-line.fact-date
              temp-shift-stk-line.shift-num  = root-temp-shift-stk-line.shift-num
              temp-shift-stk-line.shift-date = root-temp-shift-stk-line.shift-date
            .
          end.
          assign
            &scop fq1    temp-shift-stk-line.new-
            &scop fqs1
            &scop fq2    = temp-shift-stk-line.new-
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
          and root-temp-stk-line.sum-type  = {&arh-cgdt} + ub.trn-doc.ext-doc-type
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
        if not available temp-stk-line
        then do:
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
            temp-stk-line.shift-num  = root-temp-stk-line.shift-num
            temp-stk-line.shift-date = root-temp-stk-line.shift-date
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
      if v-shift-on
      then do:
        for each root-temp-shift-stk-line
          where root-temp-shift-stk-line.obj-type  = temp-ot-line.obj-type
            and root-temp-shift-stk-line.obj-code  = temp-ot-line.obj-code
            and root-temp-shift-stk-line.artic     = temp-ot-line.artic
            and root-temp-shift-stk-line.prod-type = temp-ot-line.prod-type
            and root-temp-shift-stk-line.prod-code = temp-ot-line.prod-code
            and root-temp-shift-stk-line.sum-type  = {&arh-cgdt} + ub.trn-doc.ext-doc-type
            and root-temp-shift-stk-line.cat-id    = {&root-cat-id}
        on error undo, return error
        :
          find first temp-shift-stk-line
            where temp-shift-stk-line.obj-type   = temp-ot-line.obj-type
              and temp-shift-stk-line.obj-code   = temp-ot-line.obj-code
              and temp-shift-stk-line.artic      = temp-ot-line.artic
              and temp-shift-stk-line.prod-type  = temp-ot-line.prod-type
              and temp-shift-stk-line.prod-code  = temp-ot-line.prod-code
              and temp-shift-stk-line.fact-order = root-temp-shift-stk-line.fact-order
              and temp-shift-stk-line.sum-type   = root-temp-shift-stk-line.sum-type
              and temp-shift-stk-line.cat-id     = {&root-cat-id}
            no-error .
          if not available temp-shift-stk-line
          then do:
            create temp-shift-stk-line .
            assign
              temp-shift-stk-line.obj-type   = temp-ot-line.obj-type
              temp-shift-stk-line.obj-code   = temp-ot-line.obj-code
              temp-shift-stk-line.artic      = temp-ot-line.artic
              temp-shift-stk-line.prod-type  = temp-ot-line.prod-type
              temp-shift-stk-line.prod-code  = temp-ot-line.prod-code
              temp-shift-stk-line.fact-order = root-temp-shift-stk-line.fact-order
              temp-shift-stk-line.sum-type   = root-temp-shift-stk-line.sum-type
              temp-shift-stk-line.cat-id     = {&root-cat-id}
              temp-shift-stk-line.fact-date  = root-temp-shift-stk-line.fact-date
              temp-shift-stk-line.shift-num  = root-temp-shift-stk-line.shift-num
              temp-shift-stk-line.shift-date = root-temp-shift-stk-line.shift-date
            .
          end.
          assign
            &scop fq1    temp-shift-stk-line.new-
            &scop fqs1
            &scop fq2    = temp-shift-stk-line.new-
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
    end.

    for each temp-ot-line
      where temp-ot-line.sum-type = {&arh-crsa-service}
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
          and root-temp-stk-line.sum-type  = {&arh-cgdt-service} + ub.trn-doc.ext-doc-type
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
        if not available temp-stk-line
        then do:
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
            temp-stk-line.shift-num  = root-temp-stk-line.shift-num
            temp-stk-line.shift-date = root-temp-stk-line.shift-date
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
      if v-shift-on
      then do:
        for each root-temp-shift-stk-line
          where root-temp-shift-stk-line.obj-type  = temp-ot-line.obj-type
            and root-temp-shift-stk-line.obj-code  = temp-ot-line.obj-code
            and root-temp-shift-stk-line.artic     = temp-ot-line.artic
            and root-temp-shift-stk-line.prod-type = temp-ot-line.prod-type
            and root-temp-shift-stk-line.prod-code = temp-ot-line.prod-code
            and root-temp-shift-stk-line.sum-type  = {&arh-cgdt-service} + ub.trn-doc.ext-doc-type
            and root-temp-shift-stk-line.cat-id    = {&root-cat-id}
        on error undo, return error
        :
          find first temp-shift-stk-line
            where temp-shift-stk-line.obj-type   = temp-ot-line.obj-type
              and temp-shift-stk-line.obj-code   = temp-ot-line.obj-code
              and temp-shift-stk-line.artic      = temp-ot-line.artic
              and temp-shift-stk-line.prod-type  = temp-ot-line.prod-type
              and temp-shift-stk-line.prod-code  = temp-ot-line.prod-code
              and temp-shift-stk-line.fact-order = root-temp-shift-stk-line.fact-order
              and temp-shift-stk-line.sum-type   = root-temp-shift-stk-line.sum-type
              and temp-shift-stk-line.cat-id     = {&root-cat-id}
            no-error .
          if not available temp-shift-stk-line
          then do:
            create temp-shift-stk-line .
            assign
              temp-shift-stk-line.obj-type   = temp-ot-line.obj-type
              temp-shift-stk-line.obj-code   = temp-ot-line.obj-code
              temp-shift-stk-line.artic      = temp-ot-line.artic
              temp-shift-stk-line.prod-type  = temp-ot-line.prod-type
              temp-shift-stk-line.prod-code  = temp-ot-line.prod-code
              temp-shift-stk-line.fact-order = root-temp-shift-stk-line.fact-order
              temp-shift-stk-line.sum-type   = root-temp-shift-stk-line.sum-type
              temp-shift-stk-line.cat-id     = {&root-cat-id}
              temp-shift-stk-line.fact-date  = root-temp-shift-stk-line.fact-date
              temp-shift-stk-line.shift-num  = root-temp-shift-stk-line.shift-num
              temp-shift-stk-line.shift-date = root-temp-shift-stk-line.shift-date
            .
          end.
          assign
            &scop fq1    temp-shift-stk-line.new-
            &scop fqs1
            &scop fq2    = temp-shift-stk-line.new-
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
    end.


    for each temp-ot-line
      where temp-ot-line.sum-type = {&arh-cost}
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
          and root-temp-stk-line.sum-type  = {&arh-csdt} + ub.trn-doc.ext-doc-type
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
        if not available temp-stk-line
        then do:
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
            temp-stk-line.shift-num  = root-temp-stk-line.shift-num
            temp-stk-line.shift-date = root-temp-stk-line.shift-date
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
      if v-shift-on
      then do:
        for each root-temp-shift-stk-line
          where root-temp-shift-stk-line.obj-type  = temp-ot-line.obj-type
            and root-temp-shift-stk-line.obj-code  = temp-ot-line.obj-code
            and root-temp-shift-stk-line.artic     = temp-ot-line.artic
            and root-temp-shift-stk-line.prod-type = temp-ot-line.prod-type
            and root-temp-shift-stk-line.prod-code = temp-ot-line.prod-code
            and root-temp-shift-stk-line.sum-type  = {&arh-csdt} + ub.trn-doc.ext-doc-type
            and root-temp-shift-stk-line.cat-id    = {&root-cat-id}
        on error undo, return error
        :
          find first temp-shift-stk-line
            where temp-shift-stk-line.obj-type   = temp-ot-line.obj-type
              and temp-shift-stk-line.obj-code   = temp-ot-line.obj-code
              and temp-shift-stk-line.artic      = temp-ot-line.artic
              and temp-shift-stk-line.prod-type  = temp-ot-line.prod-type
              and temp-shift-stk-line.prod-code  = temp-ot-line.prod-code
              and temp-shift-stk-line.fact-order = root-temp-shift-stk-line.fact-order
              and temp-shift-stk-line.sum-type   = root-temp-shift-stk-line.sum-type
              and temp-shift-stk-line.cat-id     = {&root-cat-id}
            no-error .
          if not available temp-shift-stk-line
          then do:
            create temp-shift-stk-line .
            assign
              temp-shift-stk-line.obj-type   = temp-ot-line.obj-type
              temp-shift-stk-line.obj-code   = temp-ot-line.obj-code
              temp-shift-stk-line.artic      = temp-ot-line.artic
              temp-shift-stk-line.prod-type  = temp-ot-line.prod-type
              temp-shift-stk-line.prod-code  = temp-ot-line.prod-code
              temp-shift-stk-line.fact-order = root-temp-shift-stk-line.fact-order
              temp-shift-stk-line.sum-type   = root-temp-shift-stk-line.sum-type
              temp-shift-stk-line.cat-id     = {&root-cat-id}
              temp-shift-stk-line.fact-date  = root-temp-shift-stk-line.fact-date
              temp-shift-stk-line.shift-num  = root-temp-shift-stk-line.shift-num
              temp-shift-stk-line.shift-date = root-temp-shift-stk-line.shift-date
            .
          end.
          assign
            &scop fq1    temp-shift-stk-line.new-
            &scop fqs1
            &scop fq2    = temp-shift-stk-line.new-
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
    end.

    for each temp-ot-line
      where temp-ot-line.sum-type = {&arh-cost-service}
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
          and root-temp-stk-line.sum-type  = {&arh-csdt-service} + ub.trn-doc.ext-doc-type
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
        if not available temp-stk-line
        then do:
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
            temp-stk-line.shift-num  = root-temp-stk-line.shift-num
            temp-stk-line.shift-date = root-temp-stk-line.shift-date
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
      if v-shift-on
      then do:
        for each root-temp-shift-stk-line
          where root-temp-shift-stk-line.obj-type  = temp-ot-line.obj-type
            and root-temp-shift-stk-line.obj-code  = temp-ot-line.obj-code
            and root-temp-shift-stk-line.artic     = temp-ot-line.artic
            and root-temp-shift-stk-line.prod-type = temp-ot-line.prod-type
            and root-temp-shift-stk-line.prod-code = temp-ot-line.prod-code
            and root-temp-shift-stk-line.sum-type  = {&arh-csdt-service} + ub.trn-doc.ext-doc-type
            and root-temp-shift-stk-line.cat-id    = {&root-cat-id}
        on error undo, return error
        :
          find first temp-shift-stk-line
            where temp-shift-stk-line.obj-type   = temp-ot-line.obj-type
              and temp-shift-stk-line.obj-code   = temp-ot-line.obj-code
              and temp-shift-stk-line.artic      = temp-ot-line.artic
              and temp-shift-stk-line.prod-type  = temp-ot-line.prod-type
              and temp-shift-stk-line.prod-code  = temp-ot-line.prod-code
              and temp-shift-stk-line.fact-order = root-temp-shift-stk-line.fact-order
              and temp-shift-stk-line.sum-type   = root-temp-shift-stk-line.sum-type
              and temp-shift-stk-line.cat-id     = {&root-cat-id}
            no-error .
          if not available temp-shift-stk-line
          then do:
            create temp-shift-stk-line .
            assign
              temp-shift-stk-line.obj-type   = temp-ot-line.obj-type
              temp-shift-stk-line.obj-code   = temp-ot-line.obj-code
              temp-shift-stk-line.artic      = temp-ot-line.artic
              temp-shift-stk-line.prod-type  = temp-ot-line.prod-type
              temp-shift-stk-line.prod-code  = temp-ot-line.prod-code
              temp-shift-stk-line.fact-order = root-temp-shift-stk-line.fact-order
              temp-shift-stk-line.sum-type   = root-temp-shift-stk-line.sum-type
              temp-shift-stk-line.cat-id     = {&root-cat-id}
              temp-shift-stk-line.fact-date  = root-temp-shift-stk-line.fact-date
              temp-shift-stk-line.shift-num  = root-temp-shift-stk-line.shift-num
              temp-shift-stk-line.shift-date = root-temp-shift-stk-line.shift-date
            .
          end.
          assign
            &scop fq1    temp-shift-stk-line.new-
            &scop fqs1
            &scop fq2    = temp-shift-stk-line.new-
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
    end.

  end.

end procedure. /* update-stk-table */


procedure store-temp-table :

  do
  on error undo, return error
  :
    for each temp-ot-tot
    on error undo, return error
    :
      if
      &scop fl1  temp-ot-tot.new-
      &scop fls1
      &scop fl2  = ?
      &scop fl3  or
      {&price-single-list}
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "При расчете складского архива по товарам получено неопределенное значение" skip
          "Документ" p-doc-code skip
          "Дополнительная информация выведена в файл calc-arh.err" skip
          view-as alert-box error .
        output stream slog to calc-arh.err append .
        export stream slog "ot-tot" .
        export stream slog temp-ot-tot .
        output stream slog close .
        undo, return error .
      end.

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
        if l-need-create-record
        then do:
          if not available ub.ot-tot
          then do:
            create ub.ot-tot .
          end.
/*          buffer-copy temp-ot-tot to ub.ot-tot*/
          &scop fp1   ub.ot-tot.
          &scop fp2   = temp-ot-tot.
          assign
            {&ot-tot-pair-list}
          .
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
          if available ub.ot-tot
          then do:
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
        if l-need-create-record
        then do:
          if not available ub.ot-line
          then do:
            create ub.ot-line .
          end.
/*          buffer-copy temp-ot-line to ub.ot-line*/
          &scop fp1   ub.ot-line.
          &scop fp2   = temp-ot-line.
          assign
            {&ot-line-pair-list}
          .

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
          if available ub.ot-line
          then do:
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
      or temp-stk-tot.cat-id = {&root-cat-id}
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
        if l-need-create-record
        then do:
          if not available ub.stk-tot
          then do:
            create ub.stk-tot .
          end.
/*          buffer-copy temp-stk-tot to ub.stk-tot*/
          &scop fp1   ub.stk-tot.
          &scop fp2   = temp-stk-tot.
          assign
            {&stk-tot-pair-list}
          .
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
          if available ub.stk-tot
          then do:
            delete ub.stk-tot .
          end.
        end.
      end. /*если было изменение*/
    end. /*each tt-stk-tot*/

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
      or temp-stk-line.cat-id = {&root-cat-id}
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
        if l-need-create-record
        then do:
          if not available ub.stk-line
          then do:
            create ub.stk-line .
          end.
/*          buffer-copy temp-stk-line to ub.stk-line*/
          &scop fp1 ub.stk-line.
          &scop fp2 = temp-stk-line.
          assign
            {&stk-line-pair-list}
          .
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
          if available ub.stk-line
          then do:
            delete ub.stk-line .
          end.
        end.
      end. /*если было изменение*/
    end.

    if v-shift-on
    then do:
      run store-shift-temp-table .
    end.
  end.

end procedure. /* store-temp-table */



procedure store-shift-temp-table :

  define buffer buf_stk-tot  for ub.stk-tot .
  define buffer buf_stk-line for ub.stk-line .

  do
  on error undo, return error
  :
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
      or temp-shift-stk-tot.cat-id = {&root-cat-id}
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

        find first buf_stk-tot exclusive-lock
          where buf_stk-tot.obj-type   = temp-shift-stk-tot.obj-type
            and buf_stk-tot.obj-code   = temp-shift-stk-tot.obj-code
            and buf_stk-tot.fact-order = temp-shift-stk-tot.fact-order
            and buf_stk-tot.sum-type   = temp-shift-stk-tot.sum-type
            and buf_stk-tot.cat-id     = temp-shift-stk-tot.cat-id
          no-error .
        if l-need-create-record
        then do:
          if not available buf_stk-tot
          then do:
            create buf_stk-tot .
          end.
          /* buffer-copy - не компилируется - приходится перечислять поля вручную */
          /* buffer-copy temp-shift-stk-tot to buf_stk-tot .*/
          &scop fp1   buf_stk-tot.
          &scop fp2   = temp-shift-stk-tot.
          assign
            {&stk-tot-pair-list}
          .
          assign
            &scop fp1   buf_stk-tot.
            &scop fps1
            &scop fp2   = temp-shift-stk-tot.new-
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
      or temp-shift-stk-line.cat-id = {&root-cat-id}
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

        find first buf_stk-line exclusive-lock
          where buf_stk-line.obj-type   = temp-shift-stk-line.obj-type
            and buf_stk-line.obj-code   = temp-shift-stk-line.obj-code
            and buf_stk-line.artic      = temp-shift-stk-line.artic
            and buf_stk-line.prod-type  = temp-shift-stk-line.prod-type
            and buf_stk-line.prod-code  = temp-shift-stk-line.prod-code
            and buf_stk-line.fact-order = temp-shift-stk-line.fact-order
            and buf_stk-line.sum-type   = temp-shift-stk-line.sum-type
            and buf_stk-line.cat-id     = temp-shift-stk-line.cat-id
          no-error .
        if l-need-create-record
        then do:
          if not available buf_stk-line
          then do:
            create buf_stk-line .
          end.
          /* buffer-copy - не компилируется - приходится перечислять поля вручную */
          /* buffer-copy temp-shift-stk-line to buf_stk-line .*/
          &scop fp1   buf_stk-line.
          &scop fp2   = temp-shift-stk-line.
          assign
            {&stk-line-pair-list}
          .
          assign
            &scop fp1   buf_stk-line.
            &scop fps1
            &scop fp2   = temp-shift-stk-line.new-
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
    end.

  end.

end procedure. /* store-shift-temp-table */




procedure check-valid-archives :

  define buffer day_stk-tot   for ub.stk-tot .
  define buffer shift_stk-tot for ub.stk-tot .
  define variable v-different-fields as character no-undo .

  do
  on error undo, return error
  :
    find last day_stk-tot no-lock
      where day_stk-tot.obj-type   = ub.trn-doc.obj-type
        and day_stk-tot.obj-code   = ub.trn-doc.obj-code
        and day_stk-tot.sum-type   = {&arh-crsa}
        and day_stk-tot.shift-date = ?
      .
    find last shift_stk-tot no-lock
      where shift_stk-tot.obj-type   = ub.trn-doc.obj-type
        and shift_stk-tot.obj-code   = ub.trn-doc.obj-code
        and shift_stk-tot.sum-type   = {&arh-crsa}
        and shift_stk-tot.shift-date <> ?
      .

    buffer-compare
      day_stk-tot
      except fact-order shift-date shift-num
      to shift_stk-tot
      case-sensitive 
      save result in v-different-fields .

    if v-different-fields <> ""
    then do:
      output stream slog to calc-arh.err append .
      export stream slog v-different-fields .
      export stream slog "day_stk-tot" .
      export stream slog day_stk-tot .
      export stream slog "shift_stk-tot" .
      export stream slog shift_stk-tot .
      output stream slog close .

      message
        vss-workfile vss-revision vss-description skip
        "Внутренняя ошибка расчета складского архива по товарам" skip
        v-different-fields skip
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
    then display
      current-time
      current-action
      with frame inf.
  end.
end procedure. /* show-action */