block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание складского архива по поставщикам

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 05/29/01

*/

define input  parameter p-doc-code       as character no-undo .
define input  parameter p-cut-date       as date      no-undo .
define input  parameter p-check-only     as logical   no-undo .
define output parameter p-need-process   as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Создание складского архива по поставщикам".
{ cmp/vssrevis.i "substitute('&1|&2|&3':u,p-doc-code,p-cut-date,p-check-only)" }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/ah-csp.i   }
{ trg/factord.i  }
{ str/prl-vat.i  }
{ gbl/cur-time.i }
{ str/clcprtsl.i }

define stream slog .

define variable v-ind                            as integer   no-undo .
define variable start-time                       as integer   no-undo .
define variable current-time                     as character no-undo .
define variable current-action                   as character no-undo .
define variable v-ot-fact-order                  as decimal   no-undo .
define variable v-stk-supp-tot-fact-order        as decimal   no-undo .
define variable v-stk-supp-line-fact-order       as decimal   no-undo .
define variable v-shift-stk-supp-tot-fact-order  as decimal   no-undo .
define variable v-shift-stk-supp-line-fact-order as decimal   no-undo .
define variable v-shift-on                       as logical   no-undo .
define variable v-fact-order                     as decimal   no-undo .
define variable v-shift-end-fact-order           as decimal   no-undo .
define variable v-day-end-fact-order             as decimal   no-undo .
define variable v-shift-cut-fact-order           as decimal   no-undo .
define variable v-day-cut-fact-order             as decimal   no-undo .
define variable v-cons-pay                       as integer   no-undo .
define variable v-cons-type                      as character no-undo .
define variable v-today                          as date      no-undo .
define variable v-time                           as integer   no-undo .

{&def-temp-stk-supp-tot}
{&def-temp-shift-stk-supp-tot}
{&def-temp-stk-supp-line}
{&def-temp-shift-stk-supp-line}
{&def-temp-ot-supp-tot}
{&def-temp-ot-supp-line}
{&def-temp-init-stk-supp-tot}
{&def-temp-init-stk-supp-line}
{&def-var-supp-list}
{&def-var-sale-list}

define buffer buf_trn-doc for ub.trn-doc .
define buffer buf_doc-line for ub.doc-line .

main-block :
do transaction
on error undo main-block, return error
:
  find first buf_trn-doc share-lock
    where buf_trn-doc.doc-code = p-doc-code
    no-error .
  if not available buf_trn-doc
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найден документ" p-doc-code skip
      view-as alert-box error .
    undo main-block, return error . /* --->>>--- */
  end.

  if buf_trn-doc.status_ <> {&fact}
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Нельзя рассчитать складской архив по поставщикам" skip
      "для складского документа не закрытого до статуса" {&fact} skip
      "Документ" p-doc-code skip
      view-as alert-box error .
    undo main-block, return error . /* --->>>--- */
  end.

  { gbl/objat.i
    buf_trn-doc.obj-type
    buf_trn-doc.obj-code
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

  { gbl/objatext.i
    buf_trn-doc.obj-type
    buf_trn-doc.obj-code
    "'cons-pay=request'"
    v-cons-pay
    v-cons-type
    no-error
  }
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при запуске процедуры objatext" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error .
  end.

  run factord in this-procedure
    (input  buf_trn-doc.fact-date   /* p-fact-date            */
    ,input  buf_trn-doc.fact-time   /* p-fact-time            */
    ,input  buf_trn-doc.fact-num    /* p-fact-num             */
    ,input  buf_trn-doc.shift-date  /* p-shift-date           */
    ,input  buf_trn-doc.shift-num   /* p-shift-num            */
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
      "doc-code"                buf_trn-doc.doc-code    skip
      "fact-date"               buf_trn-doc.fact-date   skip
      "fact-time"               buf_trn-doc.fact-time   skip
      "fact-num"                buf_trn-doc.fact-num    skip
      "shift-date"              buf_trn-doc.shift-date  skip
      "shift-num"               buf_trn-doc.shift-num   skip
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
    if p-cut-date = buf_trn-doc.fact-date
    then do:
      assign
        v-day-end-fact-order = v-day-end-fact-order - {&arh-delta}
      .
      if v-shift-on = true
      then do:
        define buffer buf_shift-obj for ub.shift-obj .
        find last buf_shift-obj
          where buf_shift-obj.obj-type    = buf_trn-doc.obj-type
            and buf_shift-obj.obj-code    = buf_trn-doc.obj-code
            and buf_shift-obj.shift-date <= p-cut-date
          use-index pi
          no-error .
        if not available buf_shift-obj
        or buf_shift-obj.status_ <> {&sht-closed}
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при поиске последней смены" skip
            "Объект" buf_trn-doc.obj-type buf_trn-doc.obj-code skip
            "Дата" p-cut-date skip
            view-as alert-box error .
          undo, return error return-value .
        end.

        if  buf_trn-doc.shift-date = buf_shift-obj.shift-date
        and buf_trn-doc.shift-num  = buf_shift-obj.shift-num
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

  def frame infa
    ub.trn-doc.doc-code                      label "Документ" skip
    ub.trn-doc.obj-type                      label "Объект"
    ub.trn-doc.obj-code                      no-label skip
    ub.trn-doc.fact-date format "99/99/9999" label "Дата закрытия" skip
    current-action       format "x(40)"      no-label skip
    v-ind                format ">>>>>>>9"   label "Обработано артикулов" skip
    ub.doc-line.artic                        label "Текущий артикул" skip
    current-time         format "x(8)"       label "Время расчета документа" skip
    with view-as dialog-box side-labels three-d
    title "Расчет складского архива по поставщикам"
    .
  define variable mFrameView      as logical   no-undo init yes.
  define variable mFramHandle as handle no-undo.      
  mFramHandle = frame infa:handle.

  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameoxmError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameoxmError"). 
      log-manager:write-message("visible-frame-mod=" + string(mFramHandle:visible), "frameoxmError"). 
  end.
  mFrameView = not session:batch-mode and mFramHandle:visible.
  run cur-time in this-procedure ( output v-today
                                 , output start-time
                                 ).

  if mFrameView
  then do:
     view frame infa .
  display
    buf_trn-doc.doc-code @ ub.trn-doc.doc-code
    buf_trn-doc.obj-type @ ub.trn-doc.obj-type
    buf_trn-doc.obj-code @ ub.trn-doc.obj-code
    buf_trn-doc.fact-date @ ub.trn-doc.fact-date
    with frame infa .
  end.
  run show-action in this-procedure
    (input "Обработка строк документа"
    ).

  assign
    v-ot-fact-order                  = v-fact-order
    v-stk-supp-tot-fact-order        = v-day-end-fact-order
    v-stk-supp-line-fact-order       = v-day-end-fact-order
    v-shift-stk-supp-tot-fact-order  = v-shift-end-fact-order
    v-shift-stk-supp-line-fact-order = v-shift-end-fact-order
  .

  if p-check-only <> true
  then do:
    run init-ot-table in this-procedure no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры init-ot-table" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo main-block, return error . /* --->>>--- */
    end.
  end.


  for each buf_doc-line no-lock
    where buf_doc-line.doc-code = buf_trn-doc.doc-code
  on error undo main-block, return error
  :
    run process-doc-line in this-procedure
      (input buf_doc-line.doc-code  /* p-doc-code  */
      ,input buf_doc-line.obj-type  /* p-obj-type  */
      ,input buf_doc-line.obj-code  /* p-obj-code  */
      ,input buf_doc-line.artic     /* p-artic     */
      ,input buf_doc-line.prod-type /* p-prod-type */
      ,input buf_doc-line.prod-code /* p-prod-code */
      ) no-error .
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
      v-ind = v-ind + 1
    .
    if v-ind modulo 10 = 0
    then do:
      run cur-time in this-procedure ( output v-today
                                     , output v-time
                                     ).
      assign
        current-time = string(v-time - start-time, "HH:MM:SS")
      .
      if mFrameView
      then do:
     
      display
        v-ind
        buf_doc-line.artic
        current-time
        with frame infa .
      end.
    end.
  end.

  if p-check-only <> true
  then do:

    run update-ot-supp-tot in this-procedure no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры update-ot-supp-tot" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo main-block, return error . /* --->>>--- */
    end.

    run init-stk-table in this-procedure no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры init-stk-table" skip
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
      (input "Сохранение складского архива по поставщикам в базу данных"
      ).

    run store-ot-table in this-procedure no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры store-ot-table" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo main-block, return error . /* --->>>--- */
    end.

    run store-stk-temp-table in this-procedure no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры store-stk-temp-table" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo main-block, return error . /* --->>>--- */
    end.

    run show-action in this-procedure
      (input "Расчет документа закончен"
      ).
  end.
  else do:
    run check-need-process in this-procedure
      (output p-need-process
      ) .
  end.
end.


procedure init-ot-table :

  define buffer buf_ot-supp-tot for ub.ot-supp-tot .
  define buffer buf_ot-supp-line for ub.ot-supp-line .
  define buffer buf_temp-ot-supp-tot for temp-ot-supp-tot .
  define buffer buf_temp-ot-supp-line for temp-ot-supp-line .

  do
  on error undo, return error
  :
    /* считываем предыдущее значение оборота по документу */
    for each buf_ot-supp-tot no-lock
      where buf_ot-supp-tot.doc-code = buf_trn-doc.doc-code
    on error undo, return error
    :
      create buf_temp-ot-supp-tot .
      buffer-copy buf_ot-supp-tot to buf_temp-ot-supp-tot
        .
    end.

    /* считываем предыдущее значение оборота по строке */
    for each buf_ot-supp-line no-lock
      where buf_ot-supp-line.doc-code  = buf_trn-doc.doc-code
    on error undo, return error
    :
      create buf_temp-ot-supp-line .
      buffer-copy buf_ot-supp-line to buf_temp-ot-supp-line
        .
    end.
  end.
end procedure. /* init-ot-table */


procedure process-doc-line :

  define input  parameter p-doc-code  as character no-undo .
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-artic     as character no-undo .
  define input  parameter p-prod-type as character no-undo .
  define input  parameter p-prod-code as integer   no-undo .

  define buffer buf_tt-clcparts for tt-clcparts .
  define buffer buf_parts for ub.parts .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_tt-allsum-line for tt-allsum-line .
  define buffer buf_temp-ot-supp-line for temp-ot-supp-line .

  do
  on error undo, return error
  :

    define variable ind-ext    as integer no-undo .
    define variable v-cat-id   as character no-undo extent 2 .
    define variable v-sum-type as character no-undo extent 2 .

    define variable v-curr-r-b as character no-undo .
    { gbl/curr-r-b.i
      v-curr-r-b
    }

    define variable v-gds-goods as logical   no-undo .
    { gbl/gdsat.i
      p-artic
      p-prod-type
      p-prod-code
      "'gds-goods=request':u"
      v-gds-goods
      no-error
    }
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Переоценка" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        'gds-goods=request':u
        view-as alert-box error .
      undo, return error .
    end.

    if v-gds-goods <> true
    then do:
      /* услуги не учитываются */
      next . /* --->>>--- */
    end.

    define variable v-doc-sign as integer   no-undo .

    if buf_trn-doc.doc-type = {&expense}
    or buf_trn-doc.doc-type = {&write-off}
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

    /* --------------------------------------------------------------------- */
    /* расчет учетной цены по партиям                                        */
    /* --------------------------------------------------------------------- */
    for each buf_parts no-lock
      where buf_parts.out-code  = p-doc-code
        and buf_parts.obj-type  = p-obj-type
        and buf_parts.obj-code  = p-obj-code
        and buf_parts.artic     = p-artic
        and buf_parts.prod-type = p-prod-type
        and buf_parts.prod-code = p-prod-code
    on error undo, return error
    :
      for each buf_tt-clcparts
      on error undo, return error return-value
      :
        delete buf_tt-clcparts .
      end.

      create buf_tt-clcparts .
      buffer-copy buf_parts to buf_tt-clcparts .

      find first buf_doc-line no-lock
        where buf_doc-line.doc-code  = p-doc-code
          and buf_doc-line.artic     = p-artic
          and buf_doc-line.prod-type = p-prod-type
          and buf_doc-line.prod-code = p-prod-code
        no-error .
      if not available buf_doc-line
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найдена строка документа" skip
          "Складской документ" p-doc-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      run clcprtsl_calc-ttable in this-procedure
        (input true                     /* paris-doc         */
        ,input false                    /* paris-cur         */
        ,input buf_doc-line.road-tax    /* parroad-tax       */
        ,input buf_doc-line.excise      /* parexcise         */
        ,input buf_doc-line.vat-pc      /* parvat-pc         */
        ,input buf_doc-line.cons-vat-pc /* parcons-vat-pc    */
        ,input buf_doc-line.slt-pc      /* parslt-pc         */
        ,input buf_trn-doc.base-rate    /* parbase-rate      */
        ,input buf_trn-doc.base-scale   /* parbase-scale     */
        ,input v-curr-r-b               /* parr-b            */
        ,input ?                        /* parcur-base       */
        ,input ?                        /* parcur-road-tax   */
        ,input ?                        /* parcur-excise     */
        ,input ?                        /* parcur-vat-pc     */
        ,input ?                        /* parcurcons-vat-pc */
        ,input ?                        /* parcurslt-pc      */
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

      define variable v-ahsp-type-ind        as integer   no-undo .
      define variable v-ahsp-type-list       as character extent 5 no-undo
        initial [{&arh-repayment}, {&arh-cons_acc}, {&arh-cons_benf}, {&arh-resp_stor}, {&arh-old_cons}] .
      define variable v-allsum-sum-type-list as character extent 5 no-undo
        initial [{&sum-repayment-sign}, {&sum-cons_acc-sign}, {&sum-cons_benf-sign}, {&sum-resp_stor-sign}, {&sum-old-cons-sign} ] .
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
          /* здесь надо брать суммы с тем знаком, */
          /* который возвращается процедурой clcprtsl */
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
          assign
            v-sale-fact-qnty      = buf_tt-allsum-line.fact-qnty
            v-sale-sum-base       = buf_tt-allsum-line.sum-dsc-base-doc
            v-sale-sum-rubl       = buf_tt-allsum-line.sum-dsc-rubl-doc
            v-sale-vat-base       = buf_tt-allsum-line.vat-base-doc
            v-sale-vat-rubl       = buf_tt-allsum-line.vat-rubl-doc
            v-sale-slt-base       = buf_tt-allsum-line.slt-base-doc
            v-sale-slt-rubl       = buf_tt-allsum-line.slt-rubl-doc
            v-sale-road-tax-base  = buf_tt-allsum-line.road-tax-base-doc
            v-sale-road-tax-rubl  = buf_tt-allsum-line.road-tax-rubl-doc
            v-sale-excise-base    = buf_tt-allsum-line.excise-base-doc
            v-sale-excise-rubl    = buf_tt-allsum-line.excise-rubl-doc
            v-sale-transport-base = buf_tt-allsum-line.transport-base-acc
            v-sale-transport-rubl = buf_tt-allsum-line.transport-rubl-acc
            v-sale-other-base     = buf_tt-allsum-line.dsc-base-doc
            v-sale-other-rubl     = buf_tt-allsum-line.dsc-rubl-doc
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
          assign
            v-sale-fact-qnty      = 0
            v-sale-sum-base       = 0
            v-sale-sum-rubl       = 0
            v-sale-vat-base       = 0
            v-sale-vat-rubl       = 0
            v-sale-slt-base       = 0
            v-sale-slt-rubl       = 0
            v-sale-road-tax-base  = 0
            v-sale-road-tax-rubl  = 0
            v-sale-excise-base    = 0
            v-sale-excise-rubl    = 0
            v-sale-transport-base = 0
            v-sale-transport-rubl = 0
            v-sale-other-base     = 0
            v-sale-other-rubl     = 0
          .
        end.

        if v-ahsp-type = {&arh-cons_benf}
        then do:
          assign
            v-fact-qnty      = 0
            v-sale-fact-qnty = 0
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
            "Программа clcprtsl.i вернула неопределенные значения" skip
            "Расчет складского архива по поставщикам невозможен" skip
            "Документ" p-doc-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
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

        if
        &scop fl1  v-sale-
        &scop fls1
        &scop fl2  = ?
        &scop fl3  or
        {&price-single-list}
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Программа clcprtsl.i вернула неопределенные значения" skip
            "Расчет складского архива по поставщикам невозможен" skip
            "Документ" p-doc-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            &scop fp1   "v-sale-
            &scop fps1  "
            &scop fp2   v-sale-
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
          v-cat-id[1]   = {&single-cat-id}
          v-sum-type[2] = {&arh-cost} + {&arh-supp}
          v-cat-id[2]   = v-ahsp-type
        .
        do ind-ext = 1 to 2
        :
          find first buf_temp-ot-supp-line
            where buf_temp-ot-supp-line.doc-code  = p-doc-code
              and buf_temp-ot-supp-line.cli-type  = buf_parts.supp-type
              and buf_temp-ot-supp-line.cli-code  = buf_parts.supp-code
              and buf_temp-ot-supp-line.artic     = buf_parts.artic
              and buf_temp-ot-supp-line.prod-type = buf_parts.prod-type
              and buf_temp-ot-supp-line.prod-code = buf_parts.prod-code
              and buf_temp-ot-supp-line.sum-type  = v-sum-type[ind-ext]
              and buf_temp-ot-supp-line.cat-id    = v-cat-id[ind-ext]
            no-error .
          if not available buf_temp-ot-supp-line
          then do:
            create buf_temp-ot-supp-line .
            assign
              buf_temp-ot-supp-line.doc-code  = p-doc-code
              buf_temp-ot-supp-line.cli-type  = buf_parts.supp-type
              buf_temp-ot-supp-line.cli-code  = buf_parts.supp-code
              buf_temp-ot-supp-line.artic     = buf_parts.artic
              buf_temp-ot-supp-line.prod-type = buf_parts.prod-type
              buf_temp-ot-supp-line.prod-code = buf_parts.prod-code
              buf_temp-ot-supp-line.sum-type  = v-sum-type[ind-ext]
              buf_temp-ot-supp-line.cat-id    = v-cat-id[ind-ext]
              buf_temp-ot-supp-line.ext-doc-type = buf_trn-doc.ext-doc-type
              buf_temp-ot-supp-line.obj-type     = buf_trn-doc.obj-type
              buf_temp-ot-supp-line.obj-code     = buf_trn-doc.obj-code
              buf_temp-ot-supp-line.fact-order   = v-ot-fact-order
            .
          end.
          assign
            &scop FT1    buf_temp-ot-supp-line.new-
            &scop FTs1
            &scop FT2    = buf_temp-ot-supp-line.new-
            &scop FTs2
            &scop FT3    + v-
            &scop FTs3
            &scop FT4
            &scop FT5
            {&price-trio-list}
          .
        end.

        /* запись информации в ценах документа */
        find first buf_temp-ot-supp-line
          where buf_temp-ot-supp-line.doc-code  = p-doc-code
            and buf_temp-ot-supp-line.cli-type  = buf_parts.supp-type
            and buf_temp-ot-supp-line.cli-code  = buf_parts.supp-code
            and buf_temp-ot-supp-line.artic     = buf_parts.artic
            and buf_temp-ot-supp-line.prod-type = buf_parts.prod-type
            and buf_temp-ot-supp-line.prod-code = buf_parts.prod-code
            and buf_temp-ot-supp-line.sum-type  = {&arh-sale}
            and buf_temp-ot-supp-line.cat-id    = {&single-cat-id}
          no-error .
        if not available buf_temp-ot-supp-line
        then do:
          create buf_temp-ot-supp-line .
          assign
            buf_temp-ot-supp-line.doc-code  = p-doc-code
            buf_temp-ot-supp-line.cli-type  = buf_parts.supp-type
            buf_temp-ot-supp-line.cli-code  = buf_parts.supp-code
            buf_temp-ot-supp-line.artic     = buf_parts.artic
            buf_temp-ot-supp-line.prod-type = buf_parts.prod-type
            buf_temp-ot-supp-line.prod-code = buf_parts.prod-code
            buf_temp-ot-supp-line.sum-type  = {&arh-sale}
            buf_temp-ot-supp-line.cat-id    = {&single-cat-id}
            buf_temp-ot-supp-line.ext-doc-type = buf_trn-doc.ext-doc-type
            buf_temp-ot-supp-line.obj-type     = buf_trn-doc.obj-type
            buf_temp-ot-supp-line.obj-code     = buf_trn-doc.obj-code
            buf_temp-ot-supp-line.fact-order   = v-ot-fact-order
          .
        end.
        assign
          &scop FT1    buf_temp-ot-supp-line.new-
          &scop FTs1
          &scop FT2    = buf_temp-ot-supp-line.new-
          &scop FTs2
          &scop FT3    + v-sale-
          &scop FTs3
          &scop FT4
          &scop FT5
          {&price-trio-list}
        .
      end.
    end.
  end.
end procedure. /* process-doc-line */


procedure update-ot-supp-tot :

  define buffer buf_temp-ot-supp-line for temp-ot-supp-line .
  define buffer buf_temp-ot-supp-tot  for temp-ot-supp-tot .

  do
  on error undo, return error
  :

    for each buf_temp-ot-supp-line
    on error undo, return error
    :
      find first buf_temp-ot-supp-tot
        where buf_temp-ot-supp-tot.doc-code = buf_temp-ot-supp-line.doc-code
          and buf_temp-ot-supp-tot.cli-type = buf_temp-ot-supp-line.cli-type
          and buf_temp-ot-supp-tot.cli-code = buf_temp-ot-supp-line.cli-code
          and buf_temp-ot-supp-tot.sum-type = buf_temp-ot-supp-line.sum-type
          and buf_temp-ot-supp-tot.cat-id   = buf_temp-ot-supp-line.cat-id
        no-error .
      if not available buf_temp-ot-supp-tot
      then do:
        create buf_temp-ot-supp-tot .
        assign
          buf_temp-ot-supp-tot.doc-code = buf_temp-ot-supp-line.doc-code
          buf_temp-ot-supp-tot.cli-type = buf_temp-ot-supp-line.cli-type
          buf_temp-ot-supp-tot.cli-code = buf_temp-ot-supp-line.cli-code
          buf_temp-ot-supp-tot.sum-type = buf_temp-ot-supp-line.sum-type
          buf_temp-ot-supp-tot.cat-id   = buf_temp-ot-supp-line.cat-id
          buf_temp-ot-supp-tot.ext-doc-type = buf_trn-doc.ext-doc-type
          buf_temp-ot-supp-tot.obj-type     = buf_trn-doc.obj-type
          buf_temp-ot-supp-tot.obj-code     = buf_trn-doc.obj-code
          buf_temp-ot-supp-tot.fact-order   = v-ot-fact-order
        .
      end.
      assign
        &scop FT1    buf_temp-ot-supp-tot.new-
        &scop FTs1
        &scop FT2    = buf_temp-ot-supp-tot.new-
        &scop FTs2
        &scop FT3    + buf_temp-ot-supp-line.new-
        &scop FTs3
        &scop FT4
        &scop FT5
        {&price-trio-list}
      .
    end.
  end.

end procedure. /* update-ot-supp-tot */


procedure init-stk-table :

  define buffer buf_temp-ot-supp-tot  for temp-ot-supp-tot .
  define buffer buf_temp-ot-supp-line for temp-ot-supp-line .

  do
  on error undo, return error
  :
    for each buf_temp-ot-supp-tot
    on error undo, return error
    :
      run init-stk-supp-tot-table in this-procedure
        (input buf_temp-ot-supp-tot.cli-type
        ,input buf_temp-ot-supp-tot.cli-code
        ) .
    end.

    for each buf_temp-ot-supp-line
    on error undo, return error
    :
      run init-stk-supp-line-table in this-procedure
        (input buf_temp-ot-supp-line.cli-type
        ,input buf_temp-ot-supp-line.cli-code
        ,input buf_temp-ot-supp-line.artic
        ,input buf_temp-ot-supp-line.prod-type
        ,input buf_temp-ot-supp-line.prod-code
        ) .
    end.
  end.

end procedure. /* init-stk-table */


procedure init-stk-supp-tot-table :

  define input parameter p-cli-type as character no-undo .
  define input parameter p-cli-code as integer   no-undo .

  define buffer buf_temp-init-stk-supp-tot for temp-init-stk-supp-tot .
  define buffer buf_stk-supp-tot for ub.stk-supp-tot .
  define buffer buf_temp-stk-supp-tot for temp-stk-supp-tot .
  define buffer buf_temp-shift-stk-supp-tot for temp-shift-stk-supp-tot .

  do
  on error undo, return error
  :
    /* регистрируем факт инициализации временных таблиц для данного клиента */
    /* предотвращает повторную инициализацию таблиц */
    find first buf_temp-init-stk-supp-tot
      where buf_temp-init-stk-supp-tot.cli-type = p-cli-type
        and buf_temp-init-stk-supp-tot.cli-code = p-cli-code
      no-error .
    if not available buf_temp-init-stk-supp-tot
    then do:
      create buf_temp-init-stk-supp-tot .
      assign
        buf_temp-init-stk-supp-tot.cli-type = p-cli-type
        buf_temp-init-stk-supp-tot.cli-code = p-cli-code
      .
    end.
    else do:
      return . /* --->>>--- */
    end.

    define variable v-root-sum-type                  as character no-undo extent 3 .
    define variable v-line-sum-type                  as character no-undo extent 3 .
    define variable v-root-sum-type-ind-ext          as integer   no-undo .
    define variable v-prev-stk-supp-tot-fact-order   as decimal   no-undo .
    define variable v-prev-stk-supp-line-fact-order  as decimal   no-undo .
    define variable v-prsh-stk-supp-tot-fact-order   as decimal   no-undo .
    define variable v-prsh-stk-supp-line-fact-order  as decimal   no-undo .

    assign
      v-root-sum-type[1] = {&arh-cost}
      v-root-sum-type[2] = {&arh-csdt}         + buf_trn-doc.ext-doc-type
      v-root-sum-type[3] = {&arh-sadt}         + buf_trn-doc.ext-doc-type
    .

    /* считываем предыдущее (текущее) и все более поздние значения оборота по объекту */
    do v-root-sum-type-ind-ext = 1 to extent(v-root-sum-type)
    :
      find last buf_stk-supp-tot no-lock
        where buf_stk-supp-tot.obj-type   = buf_trn-doc.obj-type
          and buf_stk-supp-tot.obj-code   = buf_trn-doc.obj-code
          and buf_stk-supp-tot.cli-type   = p-cli-type
          and buf_stk-supp-tot.cli-code   = p-cli-code
          and buf_stk-supp-tot.sum-type   = v-root-sum-type[v-root-sum-type-ind-ext]
          and buf_stk-supp-tot.cat-id     = {&single-cat-id}
          and buf_stk-supp-tot.fact-order <= v-stk-supp-tot-fact-order
          and buf_stk-supp-tot.shift-date = ?
        use-index category
        no-error .
      if available buf_stk-supp-tot
      then do:
        assign
          v-prev-stk-supp-tot-fact-order = buf_stk-supp-tot.fact-order
        .
        /* считывание текущего или предыдущего остатка */
        for each buf_stk-supp-tot no-lock
          where buf_stk-supp-tot.obj-type   = buf_trn-doc.obj-type
            and buf_stk-supp-tot.obj-code   = buf_trn-doc.obj-code
            and buf_stk-supp-tot.cli-type   = p-cli-type
            and buf_stk-supp-tot.cli-code   = p-cli-code
            and buf_stk-supp-tot.fact-order = v-prev-stk-supp-tot-fact-order
            and buf_stk-supp-tot.sum-type   begins v-root-sum-type[v-root-sum-type-ind-ext]
        on error undo, return error
        :
          create buf_temp-stk-supp-tot .
/*          buffer-copy buf_stk-supp-tot to buf_temp-stk-supp-tot*/
          &scop fp1   buf_temp-stk-supp-tot.
          &scop fp2   = buf_stk-supp-tot.
          assign
            {&stk-supp-tot-pair-list}
          .

          if v-stk-supp-tot-fact-order = v-prev-stk-supp-tot-fact-order
          then do:
            assign
              &scop fp1   buf_temp-stk-supp-tot.
              &scop fps1
              &scop fp2   = buf_stk-supp-tot.
              &scop fps2
              &scop fp3
              &scop fp4
              {&price-pair-list}
            .
          end.

          assign
            buf_temp-stk-supp-tot.fact-order = v-stk-supp-tot-fact-order
            buf_temp-stk-supp-tot.fact-date  = buf_trn-doc.fact-date
            buf_temp-stk-supp-tot.shift-num  = 0
            buf_temp-stk-supp-tot.shift-date = ?
          .
          assign
            &scop fp1   buf_temp-stk-supp-tot.new-
            &scop fps1
            &scop fp2   = buf_stk-supp-tot.
            &scop fps2
            &scop fp3
            &scop fp4
            {&price-pair-list}
          .
        end.
      end.
      else do:
        create buf_temp-stk-supp-tot.
        assign
          buf_temp-stk-supp-tot.obj-type   = buf_trn-doc.obj-type
          buf_temp-stk-supp-tot.obj-code   = buf_trn-doc.obj-code
          buf_temp-stk-supp-tot.cli-type   = p-cli-type
          buf_temp-stk-supp-tot.cli-code   = p-cli-code
          buf_temp-stk-supp-tot.fact-order = v-stk-supp-tot-fact-order
          buf_temp-stk-supp-tot.sum-type   = v-root-sum-type[v-root-sum-type-ind-ext]
          buf_temp-stk-supp-tot.cat-id     = {&single-cat-id}
          buf_temp-stk-supp-tot.fact-date  = buf_trn-doc.fact-date
          buf_temp-stk-supp-tot.shift-num  = 0
          buf_temp-stk-supp-tot.shift-date = ?
        .
      end.

      /* считывание всех более поздних остатков */
      for each buf_stk-supp-tot no-lock
        where buf_stk-supp-tot.obj-type   = buf_trn-doc.obj-type
          and buf_stk-supp-tot.obj-code   = buf_trn-doc.obj-code
          and buf_stk-supp-tot.cli-type   = p-cli-type
          and buf_stk-supp-tot.cli-code   = p-cli-code
          and buf_stk-supp-tot.fact-order > v-stk-supp-tot-fact-order
          and buf_stk-supp-tot.fact-order <= v-day-cut-fact-order
      on error undo, return error
      :
        if buf_stk-supp-tot.sum-type   begins v-root-sum-type[v-root-sum-type-ind-ext]
        and buf_stk-supp-tot.shift-date = ?
        then do:
          create buf_temp-stk-supp-tot .
  /*          buffer-copy buf_stk-supp-tot to buf_temp-stk-supp-tot*/
          &scop fp1   buf_temp-stk-supp-tot.
          &scop fp2   = buf_stk-supp-tot.
          assign
            {&stk-supp-tot-pair-list}
          .
          assign
            &scop fp1   buf_temp-stk-supp-tot.new-
            &scop fps1
            &scop fp2   = buf_stk-supp-tot.
            &scop fps2
            &scop fp3
            &scop fp4
            {&price-pair-list}
            &scop fp1   buf_temp-stk-supp-tot.
            &scop fps1
            &scop fp2   = buf_stk-supp-tot.
            &scop fps2
            &scop fp3
            &scop fp4
            {&price-pair-list}
          .
        end.
      end.



      if v-shift-on
      then do:
        /* ищем последний складской архив по поставщикам по смене */
        assign
          v-prsh-stk-supp-tot-fact-order = 0
        .
        find last buf_stk-supp-tot no-lock
          where buf_stk-supp-tot.obj-type   = buf_trn-doc.obj-type
            and buf_stk-supp-tot.obj-code   = buf_trn-doc.obj-code
            and buf_stk-supp-tot.cli-type   = p-cli-type
            and buf_stk-supp-tot.cli-code   = p-cli-code
            and buf_stk-supp-tot.sum-type   = v-root-sum-type[v-root-sum-type-ind-ext]
            and buf_stk-supp-tot.cat-id     = {&single-cat-id}
            and buf_stk-supp-tot.fact-order <= v-shift-stk-supp-tot-fact-order
            and buf_stk-supp-tot.shift-date <> ?
          use-index category
          no-error .
        if available buf_stk-supp-tot
        then do:
          assign
            v-prsh-stk-supp-tot-fact-order = buf_stk-supp-tot.fact-order
          .
        end.

        if v-prsh-stk-supp-tot-fact-order > 0
        then do:
          /* считывание текущего или предыдущего остатка */
          for each buf_stk-supp-tot no-lock
            where buf_stk-supp-tot.obj-type   = buf_trn-doc.obj-type
              and buf_stk-supp-tot.obj-code   = buf_trn-doc.obj-code
              and buf_stk-supp-tot.cli-type   = p-cli-type
              and buf_stk-supp-tot.cli-code   = p-cli-code
              and buf_stk-supp-tot.fact-order = v-prsh-stk-supp-tot-fact-order
              and buf_stk-supp-tot.sum-type   begins v-root-sum-type[v-root-sum-type-ind-ext]
          on error undo, return error
          :
            create buf_temp-shift-stk-supp-tot .
/*            buffer-copy buf_stk-supp-tot to buf_temp-shift-stk-supp-tot*/
            &scop fp1   buf_temp-shift-stk-supp-tot.
            &scop fp2   = buf_stk-supp-tot.
            assign
              {&stk-supp-tot-pair-list}
            .
            if v-shift-stk-supp-tot-fact-order = v-prsh-stk-supp-tot-fact-order
            then do:
              assign
                &scop fp1   buf_temp-shift-stk-supp-tot.
                &scop fps1
                &scop fp2   = buf_stk-supp-tot.
                &scop fps2
                &scop fp3
                &scop fp4
                {&price-pair-list}
              .
            end.
            assign
              buf_temp-shift-stk-supp-tot.fact-order = v-shift-stk-supp-tot-fact-order
              buf_temp-shift-stk-supp-tot.fact-date  = buf_trn-doc.fact-date
              buf_temp-shift-stk-supp-tot.shift-date = buf_trn-doc.shift-date
              buf_temp-shift-stk-supp-tot.shift-num  = buf_trn-doc.shift-num
            .
            assign
              &scop fp1   buf_temp-shift-stk-supp-tot.new-
              &scop fps1
              &scop fp2   = buf_stk-supp-tot.
              &scop fps2
              &scop fp3
              &scop fp4
              {&price-pair-list}
            .
          end.
        end.
        else do:
          create buf_temp-shift-stk-supp-tot.
          assign
            buf_temp-shift-stk-supp-tot.obj-type   = buf_trn-doc.obj-type
            buf_temp-shift-stk-supp-tot.obj-code   = buf_trn-doc.obj-code
            buf_temp-shift-stk-supp-tot.cli-type   = p-cli-type
            buf_temp-shift-stk-supp-tot.cli-code   = p-cli-code
            buf_temp-shift-stk-supp-tot.fact-order = v-shift-stk-supp-tot-fact-order
            buf_temp-shift-stk-supp-tot.sum-type   = v-root-sum-type[v-root-sum-type-ind-ext]
            buf_temp-shift-stk-supp-tot.cat-id     = {&single-cat-id}
            buf_temp-shift-stk-supp-tot.fact-date  = buf_trn-doc.fact-date
            buf_temp-shift-stk-supp-tot.shift-date = buf_trn-doc.shift-date
            buf_temp-shift-stk-supp-tot.shift-num  = buf_trn-doc.shift-num
          .
        end.

        /* считывание всех более поздних остатков */
        for each buf_stk-supp-tot no-lock
          where buf_stk-supp-tot.obj-type   = buf_trn-doc.obj-type
            and buf_stk-supp-tot.obj-code   = buf_trn-doc.obj-code
            and buf_stk-supp-tot.cli-type   = p-cli-type
            and buf_stk-supp-tot.cli-code   = p-cli-code
            and buf_stk-supp-tot.fact-order > v-shift-stk-supp-tot-fact-order
            and buf_stk-supp-tot.fact-order <= v-shift-cut-fact-order
        on error undo, return error
        :
          if buf_stk-supp-tot.sum-type   begins v-root-sum-type[v-root-sum-type-ind-ext]
          and buf_stk-supp-tot.shift-date <> ?
          then do:
            create buf_temp-shift-stk-supp-tot .
  /*            buffer-copy buf_stk-supp-tot to buf_temp-shift-stk-supp-tot*/
            &scop fp1   buf_temp-shift-stk-supp-tot.
            &scop fp2   = buf_stk-supp-tot.
            assign
              {&stk-supp-tot-pair-list}
            .
            assign
              &scop fp1   buf_temp-shift-stk-supp-tot.new-
              &scop fps1
              &scop fp2   = buf_stk-supp-tot.
              &scop fps2
              &scop fp3
              &scop fp4
              {&price-pair-list}
              &scop fp1   buf_temp-shift-stk-supp-tot.
              &scop fps1
              &scop fp2   = buf_stk-supp-tot.
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
end procedure. /* init-stk-supp-tot-table */


procedure init-stk-supp-line-table :

  define input parameter p-cli-type  as character no-undo .
  define input parameter p-cli-code  as integer   no-undo .
  define input parameter p-artic     as character no-undo .
  define input parameter p-prod-type as character no-undo .
  define input parameter p-prod-code as integer   no-undo .

  define buffer buf_temp-stk-supp-line for temp-stk-supp-line .
  define buffer buf_temp-init-stk-supp-line for temp-init-stk-supp-line .
  define buffer buf_stk-supp-line for ub.stk-supp-line .
  define buffer buf_temp-shift-stk-supp-line for temp-shift-stk-supp-line .

  do
  on error undo, return error
  :

    /* регистрирует факт инициализации временных таблиц для данного клиента для данного товара */
    /* предотвращает повторную инициализацию таблиц */
    find first buf_temp-init-stk-supp-line
      where buf_temp-init-stk-supp-line.cli-type  = p-cli-type
        and buf_temp-init-stk-supp-line.cli-code  = p-cli-code
        and buf_temp-init-stk-supp-line.artic     = p-artic
        and buf_temp-init-stk-supp-line.prod-type = p-prod-type
        and buf_temp-init-stk-supp-line.prod-code = p-prod-code
      no-error .
    if not available buf_temp-init-stk-supp-line
    then do:
      create buf_temp-init-stk-supp-line .
      assign
        buf_temp-init-stk-supp-line.cli-type = p-cli-type
        buf_temp-init-stk-supp-line.cli-code = p-cli-code
        buf_temp-init-stk-supp-line.artic     = p-artic
        buf_temp-init-stk-supp-line.prod-type = p-prod-type
        buf_temp-init-stk-supp-line.prod-code = p-prod-code
      .
    end.
    else do:
      return . /* --->>>--- */
    end.

    define variable v-root-sum-type                  as character no-undo extent 3 .
    define variable v-line-sum-type                  as character no-undo extent 3 .
    define variable v-root-sum-type-ind-ext          as integer   no-undo .
    define variable v-prev-stk-supp-line-fact-order  as decimal   no-undo .
    define variable v-prsh-stk-supp-line-fact-order  as decimal   no-undo .

    assign
      v-root-sum-type[1] = {&arh-cost}
      v-root-sum-type[2] = {&arh-csdt}         + buf_trn-doc.ext-doc-type
      v-root-sum-type[3] = {&arh-sadt}         + buf_trn-doc.ext-doc-type
    .

    /* считываем предыдущее (текущее) и все более поздние значения оборота по объекту */
    do v-root-sum-type-ind-ext = 1 to extent(v-root-sum-type)
    :
      find last buf_stk-supp-line no-lock
        where buf_stk-supp-line.obj-type   = buf_trn-doc.obj-type
          and buf_stk-supp-line.obj-code   = buf_trn-doc.obj-code
          and buf_stk-supp-line.cli-type   = p-cli-type
          and buf_stk-supp-line.cli-code   = p-cli-code
          and buf_stk-supp-line.artic      = p-artic
          and buf_stk-supp-line.prod-type  = p-prod-type
          and buf_stk-supp-line.prod-code  = p-prod-code
          and buf_stk-supp-line.sum-type   = v-root-sum-type[v-root-sum-type-ind-ext]
          and buf_stk-supp-line.cat-id     = {&single-cat-id}
          and buf_stk-supp-line.fact-order <= v-stk-supp-line-fact-order
          and buf_stk-supp-line.shift-date = ?
        use-index category
        no-error .
      if available buf_stk-supp-line
      then do:
        assign
          v-prev-stk-supp-line-fact-order = buf_stk-supp-line.fact-order
        .
        /* считывание текущего или предыдущего остатка */
        for each buf_stk-supp-line no-lock
          where buf_stk-supp-line.obj-type   = buf_trn-doc.obj-type
            and buf_stk-supp-line.obj-code   = buf_trn-doc.obj-code
            and buf_stk-supp-line.cli-type   = p-cli-type
            and buf_stk-supp-line.cli-code   = p-cli-code
            and buf_stk-supp-line.artic      = p-artic
            and buf_stk-supp-line.prod-type  = p-prod-type
            and buf_stk-supp-line.prod-code  = p-prod-code
            and buf_stk-supp-line.fact-order = v-prev-stk-supp-line-fact-order
            and buf_stk-supp-line.sum-type   begins v-root-sum-type[v-root-sum-type-ind-ext]
        on error undo, return error
        :
          create buf_temp-stk-supp-line .
/*          buffer-copy buf_stk-supp-line to buf_temp-stk-supp-line*/
          &scop fp1   buf_temp-stk-supp-line.
          &scop fp2   = buf_stk-supp-line.
          assign
            {&stk-supp-line-pair-list}
          .

          if v-stk-supp-line-fact-order = v-prev-stk-supp-line-fact-order
          then do:
            assign
              &scop fp1   buf_temp-stk-supp-line.
              &scop fps1
              &scop fp2   = buf_stk-supp-line.
              &scop fps2
              &scop fp3
              &scop fp4
              {&price-pair-list}
            .
          end.

          assign
            buf_temp-stk-supp-line.fact-order = v-stk-supp-line-fact-order
            buf_temp-stk-supp-line.fact-date  = buf_trn-doc.fact-date
            buf_temp-stk-supp-line.shift-num  = 0
            buf_temp-stk-supp-line.shift-date = ?
          .
          assign
            &scop fp1   buf_temp-stk-supp-line.new-
            &scop fps1
            &scop fp2   = buf_stk-supp-line.
            &scop fps2
            &scop fp3
            &scop fp4
            {&price-pair-list}
          .
        end.
      end.
      else do:
        create buf_temp-stk-supp-line.
        assign
          buf_temp-stk-supp-line.obj-type   = buf_trn-doc.obj-type
          buf_temp-stk-supp-line.obj-code   = buf_trn-doc.obj-code
          buf_temp-stk-supp-line.cli-type   = p-cli-type
          buf_temp-stk-supp-line.cli-code   = p-cli-code
          buf_temp-stk-supp-line.artic      = p-artic
          buf_temp-stk-supp-line.prod-type  = p-prod-type
          buf_temp-stk-supp-line.prod-code  = p-prod-code
          buf_temp-stk-supp-line.fact-order = v-stk-supp-line-fact-order
          buf_temp-stk-supp-line.sum-type   = v-root-sum-type[v-root-sum-type-ind-ext]
          buf_temp-stk-supp-line.cat-id     = {&single-cat-id}
          buf_temp-stk-supp-line.fact-date  = buf_trn-doc.fact-date
          buf_temp-stk-supp-line.shift-num  = 0
          buf_temp-stk-supp-line.shift-date = ?
        .
      end.

      /* считывание всех более поздних остатков */
      for each buf_stk-supp-line no-lock
        where buf_stk-supp-line.obj-type   = buf_trn-doc.obj-type
          and buf_stk-supp-line.obj-code   = buf_trn-doc.obj-code
          and buf_stk-supp-line.cli-type   = p-cli-type
          and buf_stk-supp-line.cli-code   = p-cli-code
          and buf_stk-supp-line.artic      = p-artic
          and buf_stk-supp-line.prod-type  = p-prod-type
          and buf_stk-supp-line.prod-code  = p-prod-code
          and buf_stk-supp-line.fact-order > v-stk-supp-line-fact-order
          and buf_stk-supp-line.fact-order <= v-day-cut-fact-order
      on error undo, return error
      :
        if buf_stk-supp-line.sum-type   begins v-root-sum-type[v-root-sum-type-ind-ext]
        and buf_stk-supp-line.shift-date = ?
        then do:
          create buf_temp-stk-supp-line .
  /*          buffer-copy buf_stk-supp-line to buf_temp-stk-supp-line*/
          &scop fp1   buf_temp-stk-supp-line.
          &scop fp2   = buf_stk-supp-line.
          assign
            {&stk-supp-line-pair-list}
          .
          assign
            &scop fp1   buf_temp-stk-supp-line.new-
            &scop fps1
            &scop fp2   = buf_stk-supp-line.
            &scop fps2
            &scop fp3
            &scop fp4
            {&price-pair-list}
            &scop fp1   buf_temp-stk-supp-line.
            &scop fps1
            &scop fp2   = buf_stk-supp-line.
            &scop fps2
            &scop fp3
            &scop fp4
            {&price-pair-list}
          .
        end.
      end.



      if v-shift-on
      then do:
        /* ищем последний складской архив по поставщикам по смене */
        assign
          v-prsh-stk-supp-line-fact-order = 0
        .
        find last buf_stk-supp-line no-lock
          where buf_stk-supp-line.obj-type   = buf_trn-doc.obj-type
            and buf_stk-supp-line.obj-code   = buf_trn-doc.obj-code
            and buf_stk-supp-line.cli-type   = p-cli-type
            and buf_stk-supp-line.cli-code   = p-cli-code
            and buf_stk-supp-line.artic      = p-artic
            and buf_stk-supp-line.prod-type  = p-prod-type
            and buf_stk-supp-line.prod-code  = p-prod-code
            and buf_stk-supp-line.sum-type   = v-root-sum-type[v-root-sum-type-ind-ext]
            and buf_stk-supp-line.cat-id     = {&single-cat-id}
            and buf_stk-supp-line.fact-order <= v-shift-stk-supp-line-fact-order
            and buf_stk-supp-line.shift-date <> ?
          use-index category
          no-error .
        if available buf_stk-supp-line
        then do:
          assign
            v-prsh-stk-supp-line-fact-order = buf_stk-supp-line.fact-order
          .
        end.

        if v-prsh-stk-supp-line-fact-order > 0
        then do:
          /* считывание текущего или предыдущего остатка */
          for each buf_stk-supp-line no-lock
            where buf_stk-supp-line.obj-type   = buf_trn-doc.obj-type
              and buf_stk-supp-line.obj-code   = buf_trn-doc.obj-code
              and buf_stk-supp-line.cli-type   = p-cli-type
              and buf_stk-supp-line.cli-code   = p-cli-code
              and buf_stk-supp-line.artic      = p-artic
              and buf_stk-supp-line.prod-type  = p-prod-type
              and buf_stk-supp-line.prod-code  = p-prod-code
              and buf_stk-supp-line.fact-order = v-prsh-stk-supp-line-fact-order
              and buf_stk-supp-line.sum-type   begins v-root-sum-type[v-root-sum-type-ind-ext]
          on error undo, return error
          :
            create buf_temp-shift-stk-supp-line .
/*            buffer-copy buf_stk-supp-line to buf_temp-shift-stk-supp-line*/
            &scop fp1   buf_temp-shift-stk-supp-line.
            &scop fp2   = buf_stk-supp-line.
            assign
              {&stk-supp-line-pair-list}
            .

            if v-shift-stk-supp-line-fact-order = v-prsh-stk-supp-line-fact-order
            then do:
              assign
                &scop fp1   buf_temp-shift-stk-supp-line.
                &scop fps1
                &scop fp2   = buf_stk-supp-line.
                &scop fps2
                &scop fp3
                &scop fp4
                {&price-pair-list}
              .
            end.

            assign
              buf_temp-shift-stk-supp-line.fact-order = v-shift-stk-supp-line-fact-order
              buf_temp-shift-stk-supp-line.fact-date  = buf_trn-doc.fact-date
              buf_temp-shift-stk-supp-line.shift-date = buf_trn-doc.shift-date
              buf_temp-shift-stk-supp-line.shift-num  = buf_trn-doc.shift-num
            .
            assign
              &scop fp1   buf_temp-shift-stk-supp-line.new-
              &scop fps1
              &scop fp2   = buf_stk-supp-line.
              &scop fps2
              &scop fp3
              &scop fp4
              {&price-pair-list}
            .
          end.
        end.
        else do:
          create buf_temp-shift-stk-supp-line.
          assign
            buf_temp-shift-stk-supp-line.obj-type   = buf_trn-doc.obj-type
            buf_temp-shift-stk-supp-line.obj-code   = buf_trn-doc.obj-code
            buf_temp-shift-stk-supp-line.cli-type   = p-cli-type
            buf_temp-shift-stk-supp-line.cli-code   = p-cli-code
            buf_temp-shift-stk-supp-line.artic      = p-artic
            buf_temp-shift-stk-supp-line.prod-type  = p-prod-type
            buf_temp-shift-stk-supp-line.prod-code  = p-prod-code
            buf_temp-shift-stk-supp-line.fact-order = v-shift-stk-supp-line-fact-order
            buf_temp-shift-stk-supp-line.sum-type   = v-root-sum-type[v-root-sum-type-ind-ext]
            buf_temp-shift-stk-supp-line.cat-id     = {&single-cat-id}
            buf_temp-shift-stk-supp-line.fact-date  = buf_trn-doc.fact-date
            buf_temp-shift-stk-supp-line.shift-date = buf_trn-doc.shift-date
            buf_temp-shift-stk-supp-line.shift-num  = buf_trn-doc.shift-num
          .
        end.

        /* считывание всех более поздних остатков */
        for each buf_stk-supp-line no-lock
          where buf_stk-supp-line.obj-type   = buf_trn-doc.obj-type
            and buf_stk-supp-line.obj-code   = buf_trn-doc.obj-code
            and buf_stk-supp-line.cli-type   = p-cli-type
            and buf_stk-supp-line.cli-code   = p-cli-code
            and buf_stk-supp-line.artic      = p-artic
            and buf_stk-supp-line.prod-type  = p-prod-type
            and buf_stk-supp-line.prod-code  = p-prod-code
            and buf_stk-supp-line.fact-order > v-shift-stk-supp-line-fact-order
            and buf_stk-supp-line.fact-order <= v-shift-cut-fact-order
        on error undo, return error
        :
          if buf_stk-supp-line.sum-type   begins v-root-sum-type[v-root-sum-type-ind-ext]
          and buf_stk-supp-line.shift-date <> ?
          then do:
            create buf_temp-shift-stk-supp-line .
  /*            buffer-copy buf_stk-supp-line to buf_temp-shift-stk-supp-line*/
            &scop fp1   buf_temp-shift-stk-supp-line.
            &scop fp2   = buf_stk-supp-line.
            assign
              {&stk-supp-line-pair-list}
            .
            assign
              &scop fp1   buf_temp-shift-stk-supp-line.new-
              &scop fps1
              &scop fp2   = buf_stk-supp-line.
              &scop fps2
              &scop fp3
              &scop fp4
              {&price-pair-list}
              &scop fp1   buf_temp-shift-stk-supp-line.
              &scop fps1
              &scop fp2   = buf_stk-supp-line.
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

end procedure. /* init-stk-supp-line-table */


procedure update-stk-table :

  define buffer root_temp-stk-supp-tot  for temp-stk-supp-tot  .
  define buffer root_temp-stk-supp-line for temp-stk-supp-line .
  define buffer root_temp-shift-stk-supp-tot  for temp-shift-stk-supp-tot  .
  define buffer root_temp-shift-stk-supp-line for temp-shift-stk-supp-line .
  define buffer buf_temp-ot-supp-tot for temp-ot-supp-tot .
  define buffer buf_temp-stk-supp-tot for temp-stk-supp-tot .
  define buffer buf_temp-shift-stk-supp-tot for temp-shift-stk-supp-tot .
  define buffer buf_temp-ot-supp-line for temp-ot-supp-line .
  define buffer buf_temp-stk-supp-line for temp-stk-supp-line .
  define buffer buf_temp-shift-stk-supp-line for temp-shift-stk-supp-line .

  do
  on error undo, return error
  :

    for each buf_temp-ot-supp-tot
      where buf_temp-ot-supp-tot.sum-type begins {&arh-cost}
        and (
      &scop fp1   buf_temp-ot-supp-tot.
      &scop fps1
      &scop fp2   <> buf_temp-ot-supp-tot.new-
      &scop fps2
      &scop fp3
      &scop fp4   or
      {&price-pair-list}
            )
    on error undo, return error
    :
      for each root_temp-stk-supp-tot
        where root_temp-stk-supp-tot.obj-type = buf_temp-ot-supp-tot.obj-type
          and root_temp-stk-supp-tot.obj-code = buf_temp-ot-supp-tot.obj-code
          and root_temp-stk-supp-tot.cli-type = buf_temp-ot-supp-tot.cli-type
          and root_temp-stk-supp-tot.cli-code = buf_temp-ot-supp-tot.cli-code
          and root_temp-stk-supp-tot.sum-type = {&arh-cost}
          and root_temp-stk-supp-tot.cat-id   = {&single-cat-id}
      on error undo, return error
      :
        find first buf_temp-stk-supp-tot
          where buf_temp-stk-supp-tot.obj-type   = buf_temp-ot-supp-tot.obj-type
            and buf_temp-stk-supp-tot.obj-code   = buf_temp-ot-supp-tot.obj-code
            and buf_temp-stk-supp-tot.cli-type   = buf_temp-ot-supp-tot.cli-type
            and buf_temp-stk-supp-tot.cli-code   = buf_temp-ot-supp-tot.cli-code
            and buf_temp-stk-supp-tot.fact-order = root_temp-stk-supp-tot.fact-order
            and buf_temp-stk-supp-tot.sum-type   = buf_temp-ot-supp-tot.sum-type
            and buf_temp-stk-supp-tot.cat-id     = buf_temp-ot-supp-tot.cat-id
          no-error .
        if not available buf_temp-stk-supp-tot
        then do:
          create buf_temp-stk-supp-tot .
          assign
            buf_temp-stk-supp-tot.obj-type   = buf_temp-ot-supp-tot.obj-type
            buf_temp-stk-supp-tot.obj-code   = buf_temp-ot-supp-tot.obj-code
            buf_temp-stk-supp-tot.cli-type   = buf_temp-ot-supp-tot.cli-type
            buf_temp-stk-supp-tot.cli-code   = buf_temp-ot-supp-tot.cli-code
            buf_temp-stk-supp-tot.fact-order = root_temp-stk-supp-tot.fact-order
            buf_temp-stk-supp-tot.sum-type   = buf_temp-ot-supp-tot.sum-type
            buf_temp-stk-supp-tot.cat-id     = buf_temp-ot-supp-tot.cat-id
            buf_temp-stk-supp-tot.fact-date  = root_temp-stk-supp-tot.fact-date
            buf_temp-stk-supp-tot.shift-num  = root_temp-stk-supp-tot.shift-num
            buf_temp-stk-supp-tot.shift-date = root_temp-stk-supp-tot.shift-date
          .
        end.
        assign
          &scop fq1    buf_temp-stk-supp-tot.new-
          &scop fqs1
          &scop fq2    = buf_temp-stk-supp-tot.new-
          &scop fqs2
          &scop fq3    + buf_temp-ot-supp-tot.new-
          &scop fqs3
          &scop fq4    - buf_temp-ot-supp-tot.
          &scop fqs4
          &scop fq5
          &scop fq6
          {&price-quadro-list}
        .
      end.
      if v-shift-on
      then do:
        for each root_temp-shift-stk-supp-tot
          where root_temp-shift-stk-supp-tot.obj-type = buf_temp-ot-supp-tot.obj-type
            and root_temp-shift-stk-supp-tot.obj-code = buf_temp-ot-supp-tot.obj-code
            and root_temp-shift-stk-supp-tot.cli-type = buf_temp-ot-supp-tot.cli-type
            and root_temp-shift-stk-supp-tot.cli-code = buf_temp-ot-supp-tot.cli-code
            and root_temp-shift-stk-supp-tot.sum-type = {&arh-cost}
            and root_temp-shift-stk-supp-tot.cat-id   = {&single-cat-id}
        on error undo, return error
        :
          find first buf_temp-shift-stk-supp-tot
            where buf_temp-shift-stk-supp-tot.obj-type   = buf_temp-ot-supp-tot.obj-type
              and buf_temp-shift-stk-supp-tot.obj-code   = buf_temp-ot-supp-tot.obj-code
              and buf_temp-shift-stk-supp-tot.cli-type   = buf_temp-ot-supp-tot.cli-type
              and buf_temp-shift-stk-supp-tot.cli-code   = buf_temp-ot-supp-tot.cli-code
              and buf_temp-shift-stk-supp-tot.fact-order = root_temp-shift-stk-supp-tot.fact-order
              and buf_temp-shift-stk-supp-tot.sum-type   = buf_temp-ot-supp-tot.sum-type
              and buf_temp-shift-stk-supp-tot.cat-id     = buf_temp-ot-supp-tot.cat-id
            no-error .
          if not available buf_temp-shift-stk-supp-tot
          then do:
            create buf_temp-shift-stk-supp-tot .
            assign
              buf_temp-shift-stk-supp-tot.obj-type   = buf_temp-ot-supp-tot.obj-type
              buf_temp-shift-stk-supp-tot.obj-code   = buf_temp-ot-supp-tot.obj-code
              buf_temp-shift-stk-supp-tot.cli-type   = buf_temp-ot-supp-tot.cli-type
              buf_temp-shift-stk-supp-tot.cli-code   = buf_temp-ot-supp-tot.cli-code
              buf_temp-shift-stk-supp-tot.fact-order = root_temp-shift-stk-supp-tot.fact-order
              buf_temp-shift-stk-supp-tot.sum-type   = buf_temp-ot-supp-tot.sum-type
              buf_temp-shift-stk-supp-tot.cat-id     = buf_temp-ot-supp-tot.cat-id
              buf_temp-shift-stk-supp-tot.fact-date  = root_temp-shift-stk-supp-tot.fact-date
              buf_temp-shift-stk-supp-tot.shift-num  = root_temp-shift-stk-supp-tot.shift-num
              buf_temp-shift-stk-supp-tot.shift-date = root_temp-shift-stk-supp-tot.shift-date
            .
          end.
          assign
            &scop fq1    buf_temp-shift-stk-supp-tot.new-
            &scop fqs1
            &scop fq2    = buf_temp-shift-stk-supp-tot.new-
            &scop fqs2
            &scop fq3    + buf_temp-ot-supp-tot.new-
            &scop fqs3
            &scop fq4    - buf_temp-ot-supp-tot.
            &scop fqs4
            &scop fq5
            &scop fq6
            {&price-quadro-list}
          .
        end.
      end.
    end.

    for each buf_temp-ot-supp-tot
      where buf_temp-ot-supp-tot.sum-type = {&arh-sale}
        and (
      &scop fp1   buf_temp-ot-supp-tot.
      &scop fps1
      &scop fp2   <> buf_temp-ot-supp-tot.new-
      &scop fps2
      &scop fp3
      &scop fp4   or
      {&price-pair-list}
            )
    on error undo, return error
    :
      for each root_temp-stk-supp-tot
        where root_temp-stk-supp-tot.obj-type = buf_temp-ot-supp-tot.obj-type
          and root_temp-stk-supp-tot.obj-code = buf_temp-ot-supp-tot.obj-code
          and root_temp-stk-supp-tot.cli-type = buf_temp-ot-supp-tot.cli-type
          and root_temp-stk-supp-tot.cli-code = buf_temp-ot-supp-tot.cli-code
          and root_temp-stk-supp-tot.sum-type = {&arh-sadt} + buf_trn-doc.ext-doc-type
          and root_temp-stk-supp-tot.cat-id   = {&single-cat-id}
      on error undo, return error
      :
        find first buf_temp-stk-supp-tot
          where buf_temp-stk-supp-tot.obj-type   = buf_temp-ot-supp-tot.obj-type
            and buf_temp-stk-supp-tot.obj-code   = buf_temp-ot-supp-tot.obj-code
            and buf_temp-stk-supp-tot.cli-type   = buf_temp-ot-supp-tot.cli-type
            and buf_temp-stk-supp-tot.cli-code   = buf_temp-ot-supp-tot.cli-code
            and buf_temp-stk-supp-tot.fact-order = root_temp-stk-supp-tot.fact-order
            and buf_temp-stk-supp-tot.sum-type   = root_temp-stk-supp-tot.sum-type
            and buf_temp-stk-supp-tot.cat-id     = {&single-cat-id}
          no-error .
        if not available buf_temp-stk-supp-tot
        then do:
          create buf_temp-stk-supp-tot .
          assign
            buf_temp-stk-supp-tot.obj-type   = buf_temp-ot-supp-tot.obj-type
            buf_temp-stk-supp-tot.obj-code   = buf_temp-ot-supp-tot.obj-code
            buf_temp-stk-supp-tot.cli-type   = buf_temp-ot-supp-tot.cli-type
            buf_temp-stk-supp-tot.cli-code   = buf_temp-ot-supp-tot.cli-code
            buf_temp-stk-supp-tot.fact-order = root_temp-stk-supp-tot.fact-order
            buf_temp-stk-supp-tot.sum-type   = root_temp-stk-supp-tot.sum-type
            buf_temp-stk-supp-tot.cat-id     = {&single-cat-id}
            buf_temp-stk-supp-tot.fact-date  = root_temp-stk-supp-tot.fact-date
            buf_temp-stk-supp-tot.shift-num  = root_temp-stk-supp-tot.shift-num
            buf_temp-stk-supp-tot.shift-date = root_temp-stk-supp-tot.shift-date
          .
        end.
        assign
          &scop fq1    buf_temp-stk-supp-tot.new-
          &scop fqs1
          &scop fq2    = buf_temp-stk-supp-tot.new-
          &scop fqs2
          &scop fq3    + buf_temp-ot-supp-tot.new-
          &scop fqs3
          &scop fq4    - buf_temp-ot-supp-tot.
          &scop fqs4
          &scop fq5
          &scop fq6
          {&price-quadro-list}
        .
      end.
      if v-shift-on
      then do:
        for each root_temp-shift-stk-supp-tot
          where root_temp-shift-stk-supp-tot.obj-type = buf_temp-ot-supp-tot.obj-type
            and root_temp-shift-stk-supp-tot.obj-code = buf_temp-ot-supp-tot.obj-code
            and root_temp-shift-stk-supp-tot.cli-type = buf_temp-ot-supp-tot.cli-type
            and root_temp-shift-stk-supp-tot.cli-code = buf_temp-ot-supp-tot.cli-code
            and root_temp-shift-stk-supp-tot.sum-type = {&arh-sadt} + buf_trn-doc.ext-doc-type
            and root_temp-shift-stk-supp-tot.cat-id   = {&single-cat-id}
        on error undo, return error
        :
          find first buf_temp-shift-stk-supp-tot
            where buf_temp-shift-stk-supp-tot.obj-type   = buf_temp-ot-supp-tot.obj-type
              and buf_temp-shift-stk-supp-tot.obj-code   = buf_temp-ot-supp-tot.obj-code
              and buf_temp-shift-stk-supp-tot.cli-type   = buf_temp-ot-supp-tot.cli-type
              and buf_temp-shift-stk-supp-tot.cli-code   = buf_temp-ot-supp-tot.cli-code
              and buf_temp-shift-stk-supp-tot.fact-order = root_temp-shift-stk-supp-tot.fact-order
              and buf_temp-shift-stk-supp-tot.sum-type   = root_temp-shift-stk-supp-tot.sum-type
              and buf_temp-shift-stk-supp-tot.cat-id     = {&single-cat-id}
            no-error .
          if not available buf_temp-shift-stk-supp-tot
          then do:
            create buf_temp-shift-stk-supp-tot .
            assign
              buf_temp-shift-stk-supp-tot.obj-type   = buf_temp-ot-supp-tot.obj-type
              buf_temp-shift-stk-supp-tot.obj-code   = buf_temp-ot-supp-tot.obj-code
              buf_temp-shift-stk-supp-tot.cli-type   = buf_temp-ot-supp-tot.cli-type
              buf_temp-shift-stk-supp-tot.cli-code   = buf_temp-ot-supp-tot.cli-code
              buf_temp-shift-stk-supp-tot.fact-order = root_temp-shift-stk-supp-tot.fact-order
              buf_temp-shift-stk-supp-tot.sum-type   = root_temp-shift-stk-supp-tot.sum-type
              buf_temp-shift-stk-supp-tot.cat-id     = {&single-cat-id}
              buf_temp-shift-stk-supp-tot.fact-date  = root_temp-shift-stk-supp-tot.fact-date
              buf_temp-shift-stk-supp-tot.shift-num  = root_temp-shift-stk-supp-tot.shift-num
              buf_temp-shift-stk-supp-tot.shift-date = root_temp-shift-stk-supp-tot.shift-date
            .
          end.
          assign
            &scop fq1    buf_temp-shift-stk-supp-tot.new-
            &scop fqs1
            &scop fq2    = buf_temp-shift-stk-supp-tot.new-
            &scop fqs2
            &scop fq3    + buf_temp-ot-supp-tot.new-
            &scop fqs3
            &scop fq4    - buf_temp-ot-supp-tot.
            &scop fqs4
            &scop fq5
            &scop fq6
            {&price-quadro-list}
          .
        end.
      end.
    end.


    for each buf_temp-ot-supp-tot
      where buf_temp-ot-supp-tot.sum-type = {&arh-cost}
        and (
      &scop fp1   buf_temp-ot-supp-tot.
      &scop fps1
      &scop fp2   <> buf_temp-ot-supp-tot.new-
      &scop fps2
      &scop fp3
      &scop fp4   or
      {&price-pair-list}
            )
    on error undo, return error
    :
      for each root_temp-stk-supp-tot
        where root_temp-stk-supp-tot.obj-type = buf_temp-ot-supp-tot.obj-type
          and root_temp-stk-supp-tot.obj-code = buf_temp-ot-supp-tot.obj-code
          and root_temp-stk-supp-tot.cli-type = buf_temp-ot-supp-tot.cli-type
          and root_temp-stk-supp-tot.cli-code = buf_temp-ot-supp-tot.cli-code
          and root_temp-stk-supp-tot.sum-type = {&arh-csdt} + buf_trn-doc.ext-doc-type
          and root_temp-stk-supp-tot.cat-id   = {&single-cat-id}
      on error undo, return error
      :
        find first buf_temp-stk-supp-tot
          where buf_temp-stk-supp-tot.obj-type   = buf_temp-ot-supp-tot.obj-type
            and buf_temp-stk-supp-tot.obj-code   = buf_temp-ot-supp-tot.obj-code
            and buf_temp-stk-supp-tot.cli-type   = buf_temp-ot-supp-tot.cli-type
            and buf_temp-stk-supp-tot.cli-code   = buf_temp-ot-supp-tot.cli-code
            and buf_temp-stk-supp-tot.fact-order = root_temp-stk-supp-tot.fact-order
            and buf_temp-stk-supp-tot.sum-type   = root_temp-stk-supp-tot.sum-type
            and buf_temp-stk-supp-tot.cat-id     = {&single-cat-id}
          no-error .
        if not available buf_temp-stk-supp-tot
        then do:
          create buf_temp-stk-supp-tot .
          assign
            buf_temp-stk-supp-tot.obj-type   = buf_temp-ot-supp-tot.obj-type
            buf_temp-stk-supp-tot.obj-code   = buf_temp-ot-supp-tot.obj-code
            buf_temp-stk-supp-tot.cli-type   = buf_temp-ot-supp-tot.cli-type
            buf_temp-stk-supp-tot.cli-code   = buf_temp-ot-supp-tot.cli-code
            buf_temp-stk-supp-tot.fact-order = root_temp-stk-supp-tot.fact-order
            buf_temp-stk-supp-tot.sum-type   = root_temp-stk-supp-tot.sum-type
            buf_temp-stk-supp-tot.cat-id     = {&single-cat-id}
            buf_temp-stk-supp-tot.fact-date  = root_temp-stk-supp-tot.fact-date
            buf_temp-stk-supp-tot.shift-num  = root_temp-stk-supp-tot.shift-num
            buf_temp-stk-supp-tot.shift-date = root_temp-stk-supp-tot.shift-date
          .
        end.
        assign
          &scop fq1    buf_temp-stk-supp-tot.new-
          &scop fqs1
          &scop fq2    = buf_temp-stk-supp-tot.new-
          &scop fqs2
          &scop fq3    + buf_temp-ot-supp-tot.new-
          &scop fqs3
          &scop fq4    - buf_temp-ot-supp-tot.
          &scop fqs4
          &scop fq5
          &scop fq6
          {&price-quadro-list}
        .
      end.
      if v-shift-on
      then do:
        for each root_temp-shift-stk-supp-tot
          where root_temp-shift-stk-supp-tot.obj-type = buf_temp-ot-supp-tot.obj-type
            and root_temp-shift-stk-supp-tot.obj-code = buf_temp-ot-supp-tot.obj-code
            and root_temp-shift-stk-supp-tot.cli-type = buf_temp-ot-supp-tot.cli-type
            and root_temp-shift-stk-supp-tot.cli-code = buf_temp-ot-supp-tot.cli-code
            and root_temp-shift-stk-supp-tot.sum-type = {&arh-csdt} + buf_trn-doc.ext-doc-type
            and root_temp-shift-stk-supp-tot.cat-id   = {&single-cat-id}
        on error undo, return error
        :
          find first buf_temp-shift-stk-supp-tot
            where buf_temp-shift-stk-supp-tot.obj-type   = buf_temp-ot-supp-tot.obj-type
              and buf_temp-shift-stk-supp-tot.obj-code   = buf_temp-ot-supp-tot.obj-code
              and buf_temp-shift-stk-supp-tot.cli-type   = buf_temp-ot-supp-tot.cli-type
              and buf_temp-shift-stk-supp-tot.cli-code   = buf_temp-ot-supp-tot.cli-code
              and buf_temp-shift-stk-supp-tot.fact-order = root_temp-shift-stk-supp-tot.fact-order
              and buf_temp-shift-stk-supp-tot.sum-type   = root_temp-shift-stk-supp-tot.sum-type
              and buf_temp-shift-stk-supp-tot.cat-id     = {&single-cat-id}
            no-error .
          if not available buf_temp-shift-stk-supp-tot
          then do:
            create buf_temp-shift-stk-supp-tot .
            assign
              buf_temp-shift-stk-supp-tot.obj-type   = buf_temp-ot-supp-tot.obj-type
              buf_temp-shift-stk-supp-tot.obj-code   = buf_temp-ot-supp-tot.obj-code
              buf_temp-shift-stk-supp-tot.cli-type   = buf_temp-ot-supp-tot.cli-type
              buf_temp-shift-stk-supp-tot.cli-code   = buf_temp-ot-supp-tot.cli-code
              buf_temp-shift-stk-supp-tot.fact-order = root_temp-shift-stk-supp-tot.fact-order
              buf_temp-shift-stk-supp-tot.sum-type   = root_temp-shift-stk-supp-tot.sum-type
              buf_temp-shift-stk-supp-tot.cat-id     = {&single-cat-id}
              buf_temp-shift-stk-supp-tot.fact-date  = root_temp-shift-stk-supp-tot.fact-date
              buf_temp-shift-stk-supp-tot.shift-num  = root_temp-shift-stk-supp-tot.shift-num
              buf_temp-shift-stk-supp-tot.shift-date = root_temp-shift-stk-supp-tot.shift-date
            .
          end.
          assign
            &scop fq1    buf_temp-shift-stk-supp-tot.new-
            &scop fqs1
            &scop fq2    = buf_temp-shift-stk-supp-tot.new-
            &scop fqs2
            &scop fq3    + buf_temp-ot-supp-tot.new-
            &scop fqs3
            &scop fq4    - buf_temp-ot-supp-tot.
            &scop fqs4
            &scop fq5
            &scop fq6
            {&price-quadro-list}
          .
        end.
      end.
    end.


    for each buf_temp-ot-supp-line
      where buf_temp-ot-supp-line.sum-type begins {&arh-cost}
        and (
      &scop fp1   buf_temp-ot-supp-line.
      &scop fps1
      &scop fp2   <> buf_temp-ot-supp-line.new-
      &scop fps2
      &scop fp3
      &scop fp4   or
      {&price-pair-list}
            )
    on error undo, return error
    :
      for each root_temp-stk-supp-line
        where root_temp-stk-supp-line.obj-type  = buf_temp-ot-supp-line.obj-type
          and root_temp-stk-supp-line.obj-code  = buf_temp-ot-supp-line.obj-code
          and root_temp-stk-supp-line.cli-type  = buf_temp-ot-supp-line.cli-type
          and root_temp-stk-supp-line.cli-code  = buf_temp-ot-supp-line.cli-code
          and root_temp-stk-supp-line.artic     = buf_temp-ot-supp-line.artic
          and root_temp-stk-supp-line.prod-type = buf_temp-ot-supp-line.prod-type
          and root_temp-stk-supp-line.prod-code = buf_temp-ot-supp-line.prod-code
          and root_temp-stk-supp-line.sum-type  = {&arh-cost}
          and root_temp-stk-supp-line.cat-id    = {&single-cat-id}
      on error undo, return error
      :
        find first buf_temp-stk-supp-line
          where buf_temp-stk-supp-line.obj-type   = buf_temp-ot-supp-line.obj-type
            and buf_temp-stk-supp-line.obj-code   = buf_temp-ot-supp-line.obj-code
            and buf_temp-stk-supp-line.cli-type   = buf_temp-ot-supp-line.cli-type
            and buf_temp-stk-supp-line.cli-code   = buf_temp-ot-supp-line.cli-code
            and buf_temp-stk-supp-line.artic      = buf_temp-ot-supp-line.artic
            and buf_temp-stk-supp-line.prod-type  = buf_temp-ot-supp-line.prod-type
            and buf_temp-stk-supp-line.prod-code  = buf_temp-ot-supp-line.prod-code
            and buf_temp-stk-supp-line.fact-order = root_temp-stk-supp-line.fact-order
            and buf_temp-stk-supp-line.sum-type   = buf_temp-ot-supp-line.sum-type
            and buf_temp-stk-supp-line.cat-id     = buf_temp-ot-supp-line.cat-id
          no-error .
        if not available buf_temp-stk-supp-line
        then do:
          create buf_temp-stk-supp-line .
          assign
            buf_temp-stk-supp-line.obj-type   = buf_temp-ot-supp-line.obj-type
            buf_temp-stk-supp-line.obj-code   = buf_temp-ot-supp-line.obj-code
            buf_temp-stk-supp-line.cli-type   = buf_temp-ot-supp-line.cli-type
            buf_temp-stk-supp-line.cli-code   = buf_temp-ot-supp-line.cli-code
            buf_temp-stk-supp-line.artic      = buf_temp-ot-supp-line.artic
            buf_temp-stk-supp-line.prod-type  = buf_temp-ot-supp-line.prod-type
            buf_temp-stk-supp-line.prod-code  = buf_temp-ot-supp-line.prod-code
            buf_temp-stk-supp-line.fact-order = root_temp-stk-supp-line.fact-order
            buf_temp-stk-supp-line.sum-type   = buf_temp-ot-supp-line.sum-type
            buf_temp-stk-supp-line.cat-id     = buf_temp-ot-supp-line.cat-id
            buf_temp-stk-supp-line.fact-date  = root_temp-stk-supp-line.fact-date
            buf_temp-stk-supp-line.shift-num  = root_temp-stk-supp-line.shift-num
            buf_temp-stk-supp-line.shift-date = root_temp-stk-supp-line.shift-date
          .
        end.
        assign
          &scop fq1    buf_temp-stk-supp-line.new-
          &scop fqs1
          &scop fq2    = buf_temp-stk-supp-line.new-
          &scop fqs2
          &scop fq3    + buf_temp-ot-supp-line.new-
          &scop fqs3
          &scop fq4    - buf_temp-ot-supp-line.
          &scop fqs4
          &scop fq5
          &scop fq6
          {&price-quadro-list}
        .
      end.
      if v-shift-on
      then do:
        for each root_temp-shift-stk-supp-line
          where root_temp-shift-stk-supp-line.obj-type  = buf_temp-ot-supp-line.obj-type
            and root_temp-shift-stk-supp-line.obj-code  = buf_temp-ot-supp-line.obj-code
            and root_temp-shift-stk-supp-line.cli-type  = buf_temp-ot-supp-line.cli-type
            and root_temp-shift-stk-supp-line.cli-code  = buf_temp-ot-supp-line.cli-code
            and root_temp-shift-stk-supp-line.artic     = buf_temp-ot-supp-line.artic
            and root_temp-shift-stk-supp-line.prod-type = buf_temp-ot-supp-line.prod-type
            and root_temp-shift-stk-supp-line.prod-code = buf_temp-ot-supp-line.prod-code
            and root_temp-shift-stk-supp-line.sum-type  = {&arh-cost}
            and root_temp-shift-stk-supp-line.cat-id    = {&single-cat-id}
        on error undo, return error
        :
          find first buf_temp-shift-stk-supp-line
            where buf_temp-shift-stk-supp-line.obj-type   = buf_temp-ot-supp-line.obj-type
              and buf_temp-shift-stk-supp-line.obj-code   = buf_temp-ot-supp-line.obj-code
              and buf_temp-shift-stk-supp-line.cli-type   = buf_temp-ot-supp-line.cli-type
              and buf_temp-shift-stk-supp-line.cli-code   = buf_temp-ot-supp-line.cli-code
              and buf_temp-shift-stk-supp-line.artic      = buf_temp-ot-supp-line.artic
              and buf_temp-shift-stk-supp-line.prod-type  = buf_temp-ot-supp-line.prod-type
              and buf_temp-shift-stk-supp-line.prod-code  = buf_temp-ot-supp-line.prod-code
              and buf_temp-shift-stk-supp-line.fact-order = root_temp-shift-stk-supp-line.fact-order
              and buf_temp-shift-stk-supp-line.sum-type   = buf_temp-ot-supp-line.sum-type
              and buf_temp-shift-stk-supp-line.cat-id     = buf_temp-ot-supp-line.cat-id
            no-error .
          if not available buf_temp-shift-stk-supp-line
          then do:
            create buf_temp-shift-stk-supp-line .
            assign
              buf_temp-shift-stk-supp-line.obj-type   = buf_temp-ot-supp-line.obj-type
              buf_temp-shift-stk-supp-line.obj-code   = buf_temp-ot-supp-line.obj-code
              buf_temp-shift-stk-supp-line.cli-type   = buf_temp-ot-supp-line.cli-type
              buf_temp-shift-stk-supp-line.cli-code   = buf_temp-ot-supp-line.cli-code
              buf_temp-shift-stk-supp-line.artic      = buf_temp-ot-supp-line.artic
              buf_temp-shift-stk-supp-line.prod-type  = buf_temp-ot-supp-line.prod-type
              buf_temp-shift-stk-supp-line.prod-code  = buf_temp-ot-supp-line.prod-code
              buf_temp-shift-stk-supp-line.fact-order = root_temp-shift-stk-supp-line.fact-order
              buf_temp-shift-stk-supp-line.sum-type   = buf_temp-ot-supp-line.sum-type
              buf_temp-shift-stk-supp-line.cat-id     = buf_temp-ot-supp-line.cat-id
              buf_temp-shift-stk-supp-line.fact-date  = root_temp-shift-stk-supp-line.fact-date
              buf_temp-shift-stk-supp-line.shift-num  = root_temp-shift-stk-supp-line.shift-num
              buf_temp-shift-stk-supp-line.shift-date = root_temp-shift-stk-supp-line.shift-date
            .
          end.
          assign
            &scop fq1    buf_temp-shift-stk-supp-line.new-
            &scop fqs1
            &scop fq2    = buf_temp-shift-stk-supp-line.new-
            &scop fqs2
            &scop fq3    + buf_temp-ot-supp-line.new-
            &scop fqs3
            &scop fq4    - buf_temp-ot-supp-line.
            &scop fqs4
            &scop fq5
            &scop fq6
            {&price-quadro-list}
          .
        end.
      end.
    end.


    for each buf_temp-ot-supp-line
      where buf_temp-ot-supp-line.sum-type = {&arh-sale}
        and (
      &scop fp1   buf_temp-ot-supp-line.
      &scop fps1
      &scop fp2   <> buf_temp-ot-supp-line.new-
      &scop fps2
      &scop fp3
      &scop fp4   or
      {&price-pair-list}
            )
    on error undo, return error
    :
      for each root_temp-stk-supp-line
        where root_temp-stk-supp-line.obj-type  = buf_temp-ot-supp-line.obj-type
          and root_temp-stk-supp-line.obj-code  = buf_temp-ot-supp-line.obj-code
          and root_temp-stk-supp-line.cli-type  = buf_temp-ot-supp-line.cli-type
          and root_temp-stk-supp-line.cli-code  = buf_temp-ot-supp-line.cli-code
          and root_temp-stk-supp-line.artic     = buf_temp-ot-supp-line.artic
          and root_temp-stk-supp-line.prod-type = buf_temp-ot-supp-line.prod-type
          and root_temp-stk-supp-line.prod-code = buf_temp-ot-supp-line.prod-code
          and root_temp-stk-supp-line.sum-type  = {&arh-sadt} + buf_trn-doc.ext-doc-type
          and root_temp-stk-supp-line.cat-id    = {&single-cat-id}
      on error undo, return error
      :
        find first buf_temp-stk-supp-line
          where buf_temp-stk-supp-line.obj-type   = buf_temp-ot-supp-line.obj-type
            and buf_temp-stk-supp-line.obj-code   = buf_temp-ot-supp-line.obj-code
            and buf_temp-stk-supp-line.cli-type   = buf_temp-ot-supp-line.cli-type
            and buf_temp-stk-supp-line.cli-code   = buf_temp-ot-supp-line.cli-code
            and buf_temp-stk-supp-line.artic      = buf_temp-ot-supp-line.artic
            and buf_temp-stk-supp-line.prod-type  = buf_temp-ot-supp-line.prod-type
            and buf_temp-stk-supp-line.prod-code  = buf_temp-ot-supp-line.prod-code
            and buf_temp-stk-supp-line.fact-order = root_temp-stk-supp-line.fact-order
            and buf_temp-stk-supp-line.sum-type   = root_temp-stk-supp-line.sum-type
            and buf_temp-stk-supp-line.cat-id     = {&single-cat-id}
          no-error .
        if not available buf_temp-stk-supp-line
        then do:
          create buf_temp-stk-supp-line .
          assign
            buf_temp-stk-supp-line.obj-type   = buf_temp-ot-supp-line.obj-type
            buf_temp-stk-supp-line.obj-code   = buf_temp-ot-supp-line.obj-code
            buf_temp-stk-supp-line.cli-type   = buf_temp-ot-supp-line.cli-type
            buf_temp-stk-supp-line.cli-code   = buf_temp-ot-supp-line.cli-code
            buf_temp-stk-supp-line.artic      = buf_temp-ot-supp-line.artic
            buf_temp-stk-supp-line.prod-type  = buf_temp-ot-supp-line.prod-type
            buf_temp-stk-supp-line.prod-code  = buf_temp-ot-supp-line.prod-code
            buf_temp-stk-supp-line.fact-order = root_temp-stk-supp-line.fact-order
            buf_temp-stk-supp-line.sum-type   = root_temp-stk-supp-line.sum-type
            buf_temp-stk-supp-line.cat-id     = {&single-cat-id}
            buf_temp-stk-supp-line.fact-date  = root_temp-stk-supp-line.fact-date
            buf_temp-stk-supp-line.shift-num  = root_temp-stk-supp-line.shift-num
            buf_temp-stk-supp-line.shift-date = root_temp-stk-supp-line.shift-date
          .
        end.
        assign
          &scop fq1    buf_temp-stk-supp-line.new-
          &scop fqs1
          &scop fq2    = buf_temp-stk-supp-line.new-
          &scop fqs2
          &scop fq3    + buf_temp-ot-supp-line.new-
          &scop fqs3
          &scop fq4    - buf_temp-ot-supp-line.
          &scop fqs4
          &scop fq5
          &scop fq6
          {&price-quadro-list}
        .
      end.
      if v-shift-on
      then do:
        for each root_temp-shift-stk-supp-line
          where root_temp-shift-stk-supp-line.obj-type  = buf_temp-ot-supp-line.obj-type
            and root_temp-shift-stk-supp-line.obj-code  = buf_temp-ot-supp-line.obj-code
            and root_temp-shift-stk-supp-line.cli-type  = buf_temp-ot-supp-line.cli-type
            and root_temp-shift-stk-supp-line.cli-code  = buf_temp-ot-supp-line.cli-code
            and root_temp-shift-stk-supp-line.artic     = buf_temp-ot-supp-line.artic
            and root_temp-shift-stk-supp-line.prod-type = buf_temp-ot-supp-line.prod-type
            and root_temp-shift-stk-supp-line.prod-code = buf_temp-ot-supp-line.prod-code
            and root_temp-shift-stk-supp-line.sum-type  = {&arh-sadt} + buf_trn-doc.ext-doc-type
            and root_temp-shift-stk-supp-line.cat-id    = {&single-cat-id}
        on error undo, return error
        :
          find first buf_temp-shift-stk-supp-line
            where buf_temp-shift-stk-supp-line.obj-type   = buf_temp-ot-supp-line.obj-type
              and buf_temp-shift-stk-supp-line.obj-code   = buf_temp-ot-supp-line.obj-code
              and buf_temp-shift-stk-supp-line.cli-type   = buf_temp-ot-supp-line.cli-type
              and buf_temp-shift-stk-supp-line.cli-code   = buf_temp-ot-supp-line.cli-code
              and buf_temp-shift-stk-supp-line.artic      = buf_temp-ot-supp-line.artic
              and buf_temp-shift-stk-supp-line.prod-type  = buf_temp-ot-supp-line.prod-type
              and buf_temp-shift-stk-supp-line.prod-code  = buf_temp-ot-supp-line.prod-code
              and buf_temp-shift-stk-supp-line.fact-order = root_temp-shift-stk-supp-line.fact-order
              and buf_temp-shift-stk-supp-line.sum-type   = root_temp-shift-stk-supp-line.sum-type
              and buf_temp-shift-stk-supp-line.cat-id     = {&single-cat-id}
            no-error .
          if not available buf_temp-shift-stk-supp-line
          then do:
            create buf_temp-shift-stk-supp-line .
            assign
              buf_temp-shift-stk-supp-line.obj-type   = buf_temp-ot-supp-line.obj-type
              buf_temp-shift-stk-supp-line.obj-code   = buf_temp-ot-supp-line.obj-code
              buf_temp-shift-stk-supp-line.cli-type   = buf_temp-ot-supp-line.cli-type
              buf_temp-shift-stk-supp-line.cli-code   = buf_temp-ot-supp-line.cli-code
              buf_temp-shift-stk-supp-line.artic      = buf_temp-ot-supp-line.artic
              buf_temp-shift-stk-supp-line.prod-type  = buf_temp-ot-supp-line.prod-type
              buf_temp-shift-stk-supp-line.prod-code  = buf_temp-ot-supp-line.prod-code
              buf_temp-shift-stk-supp-line.fact-order = root_temp-shift-stk-supp-line.fact-order
              buf_temp-shift-stk-supp-line.sum-type   = root_temp-shift-stk-supp-line.sum-type
              buf_temp-shift-stk-supp-line.cat-id     = {&single-cat-id}
              buf_temp-shift-stk-supp-line.fact-date  = root_temp-shift-stk-supp-line.fact-date
              buf_temp-shift-stk-supp-line.shift-num  = root_temp-shift-stk-supp-line.shift-num
              buf_temp-shift-stk-supp-line.shift-date = root_temp-shift-stk-supp-line.shift-date
            .
          end.
          assign
            &scop fq1    buf_temp-shift-stk-supp-line.new-
            &scop fqs1
            &scop fq2    = buf_temp-shift-stk-supp-line.new-
            &scop fqs2
            &scop fq3    + buf_temp-ot-supp-line.new-
            &scop fqs3
            &scop fq4    - buf_temp-ot-supp-line.
            &scop fqs4
            &scop fq5
            &scop fq6
            {&price-quadro-list}
          .
        end.
      end.
    end.


    for each buf_temp-ot-supp-line
      where buf_temp-ot-supp-line.sum-type = {&arh-cost}
        and (
      &scop fp1   buf_temp-ot-supp-line.
      &scop fps1
      &scop fp2   <> buf_temp-ot-supp-line.new-
      &scop fps2
      &scop fp3
      &scop fp4   or
      {&price-pair-list}
            )
    on error undo, return error
    :
      for each root_temp-stk-supp-line
        where root_temp-stk-supp-line.obj-type  = buf_temp-ot-supp-line.obj-type
          and root_temp-stk-supp-line.obj-code  = buf_temp-ot-supp-line.obj-code
          and root_temp-stk-supp-line.cli-type  = buf_temp-ot-supp-line.cli-type
          and root_temp-stk-supp-line.cli-code  = buf_temp-ot-supp-line.cli-code
          and root_temp-stk-supp-line.artic     = buf_temp-ot-supp-line.artic
          and root_temp-stk-supp-line.prod-type = buf_temp-ot-supp-line.prod-type
          and root_temp-stk-supp-line.prod-code = buf_temp-ot-supp-line.prod-code
          and root_temp-stk-supp-line.sum-type  = {&arh-csdt} + buf_trn-doc.ext-doc-type
          and root_temp-stk-supp-line.cat-id    = {&single-cat-id}
      on error undo, return error
      :
        find first buf_temp-stk-supp-line
          where buf_temp-stk-supp-line.obj-type   = buf_temp-ot-supp-line.obj-type
            and buf_temp-stk-supp-line.obj-code   = buf_temp-ot-supp-line.obj-code
            and buf_temp-stk-supp-line.cli-type   = buf_temp-ot-supp-line.cli-type
            and buf_temp-stk-supp-line.cli-code   = buf_temp-ot-supp-line.cli-code
            and buf_temp-stk-supp-line.artic      = buf_temp-ot-supp-line.artic
            and buf_temp-stk-supp-line.prod-type  = buf_temp-ot-supp-line.prod-type
            and buf_temp-stk-supp-line.prod-code  = buf_temp-ot-supp-line.prod-code
            and buf_temp-stk-supp-line.fact-order = root_temp-stk-supp-line.fact-order
            and buf_temp-stk-supp-line.sum-type   = root_temp-stk-supp-line.sum-type
            and buf_temp-stk-supp-line.cat-id     = {&single-cat-id}
          no-error .
        if not available buf_temp-stk-supp-line
        then do:
          create buf_temp-stk-supp-line .
          assign
            buf_temp-stk-supp-line.obj-type   = buf_temp-ot-supp-line.obj-type
            buf_temp-stk-supp-line.obj-code   = buf_temp-ot-supp-line.obj-code
            buf_temp-stk-supp-line.cli-type   = buf_temp-ot-supp-line.cli-type
            buf_temp-stk-supp-line.cli-code   = buf_temp-ot-supp-line.cli-code
            buf_temp-stk-supp-line.artic      = buf_temp-ot-supp-line.artic
            buf_temp-stk-supp-line.prod-type  = buf_temp-ot-supp-line.prod-type
            buf_temp-stk-supp-line.prod-code  = buf_temp-ot-supp-line.prod-code
            buf_temp-stk-supp-line.fact-order = root_temp-stk-supp-line.fact-order
            buf_temp-stk-supp-line.sum-type   = root_temp-stk-supp-line.sum-type
            buf_temp-stk-supp-line.cat-id     = {&single-cat-id}
            buf_temp-stk-supp-line.fact-date  = root_temp-stk-supp-line.fact-date
            buf_temp-stk-supp-line.shift-num  = root_temp-stk-supp-line.shift-num
            buf_temp-stk-supp-line.shift-date = root_temp-stk-supp-line.shift-date
          .
        end.
        assign
          &scop fq1    buf_temp-stk-supp-line.new-
          &scop fqs1
          &scop fq2    = buf_temp-stk-supp-line.new-
          &scop fqs2
          &scop fq3    + buf_temp-ot-supp-line.new-
          &scop fqs3
          &scop fq4    - buf_temp-ot-supp-line.
          &scop fqs4
          &scop fq5
          &scop fq6
          {&price-quadro-list}
        .
      end.
      if v-shift-on
      then do:
        for each root_temp-shift-stk-supp-line
          where root_temp-shift-stk-supp-line.obj-type  = buf_temp-ot-supp-line.obj-type
            and root_temp-shift-stk-supp-line.obj-code  = buf_temp-ot-supp-line.obj-code
            and root_temp-shift-stk-supp-line.cli-type  = buf_temp-ot-supp-line.cli-type
            and root_temp-shift-stk-supp-line.cli-code  = buf_temp-ot-supp-line.cli-code
            and root_temp-shift-stk-supp-line.artic     = buf_temp-ot-supp-line.artic
            and root_temp-shift-stk-supp-line.prod-type = buf_temp-ot-supp-line.prod-type
            and root_temp-shift-stk-supp-line.prod-code = buf_temp-ot-supp-line.prod-code
            and root_temp-shift-stk-supp-line.sum-type  = {&arh-csdt} + buf_trn-doc.ext-doc-type
            and root_temp-shift-stk-supp-line.cat-id    = {&single-cat-id}
        on error undo, return error
        :
          find first buf_temp-shift-stk-supp-line
            where buf_temp-shift-stk-supp-line.obj-type   = buf_temp-ot-supp-line.obj-type
              and buf_temp-shift-stk-supp-line.obj-code   = buf_temp-ot-supp-line.obj-code
              and buf_temp-shift-stk-supp-line.cli-type   = buf_temp-ot-supp-line.cli-type
              and buf_temp-shift-stk-supp-line.cli-code   = buf_temp-ot-supp-line.cli-code
              and buf_temp-shift-stk-supp-line.artic      = buf_temp-ot-supp-line.artic
              and buf_temp-shift-stk-supp-line.prod-type  = buf_temp-ot-supp-line.prod-type
              and buf_temp-shift-stk-supp-line.prod-code  = buf_temp-ot-supp-line.prod-code
              and buf_temp-shift-stk-supp-line.fact-order = root_temp-shift-stk-supp-line.fact-order
              and buf_temp-shift-stk-supp-line.sum-type   = root_temp-shift-stk-supp-line.sum-type
              and buf_temp-shift-stk-supp-line.cat-id     = {&single-cat-id}
            no-error .
          if not available buf_temp-shift-stk-supp-line
          then do:
            create buf_temp-shift-stk-supp-line .
            assign
              buf_temp-shift-stk-supp-line.obj-type   = buf_temp-ot-supp-line.obj-type
              buf_temp-shift-stk-supp-line.obj-code   = buf_temp-ot-supp-line.obj-code
              buf_temp-shift-stk-supp-line.cli-type   = buf_temp-ot-supp-line.cli-type
              buf_temp-shift-stk-supp-line.cli-code   = buf_temp-ot-supp-line.cli-code
              buf_temp-shift-stk-supp-line.artic      = buf_temp-ot-supp-line.artic
              buf_temp-shift-stk-supp-line.prod-type  = buf_temp-ot-supp-line.prod-type
              buf_temp-shift-stk-supp-line.prod-code  = buf_temp-ot-supp-line.prod-code
              buf_temp-shift-stk-supp-line.fact-order = root_temp-shift-stk-supp-line.fact-order
              buf_temp-shift-stk-supp-line.sum-type   = root_temp-shift-stk-supp-line.sum-type
              buf_temp-shift-stk-supp-line.cat-id     = {&single-cat-id}
              buf_temp-shift-stk-supp-line.fact-date  = root_temp-shift-stk-supp-line.fact-date
              buf_temp-shift-stk-supp-line.shift-num  = root_temp-shift-stk-supp-line.shift-num
              buf_temp-shift-stk-supp-line.shift-date = root_temp-shift-stk-supp-line.shift-date
            .
          end.
          assign
            &scop fq1    buf_temp-shift-stk-supp-line.new-
            &scop fqs1
            &scop fq2    = buf_temp-shift-stk-supp-line.new-
            &scop fqs2
            &scop fq3    + buf_temp-ot-supp-line.new-
            &scop fqs3
            &scop fq4    - buf_temp-ot-supp-line.
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


procedure store-ot-table :

  define buffer buf_temp-ot-supp-tot for temp-ot-supp-tot .
  define buffer buf_ot-supp-tot for ub.ot-supp-tot .
  define buffer buf_temp-ot-supp-line for temp-ot-supp-line .
  define buffer buf_ot-supp-line for ub.ot-supp-line .

  do
  on error undo, return error
  :

    define variable l-need-create-record             as logical no-undo .

    for each buf_temp-ot-supp-tot
    on error undo, return error
    :
      if
      &scop fl1  buf_temp-ot-supp-tot.new-
      &scop fls1
      &scop fl2  = ?
      &scop fl3  or
      {&price-single-list}
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "При расчета складского архива по поставщикам получено неопределенное значение" skip
          "Документ" p-doc-code skip
          "Дополнительная информация выведена в файл ah-csptr.err" skip
          view-as alert-box error .

        output stream slog to ah-csptr.err append .
        export stream slog "ot-supp-tot" .
        export stream slog buf_temp-ot-supp-tot .
        output stream slog close .

        undo, return error .
      end.

      if
      &scop fp1   buf_temp-ot-supp-tot.
      &scop fps1
      &scop fp2   <> buf_temp-ot-supp-tot.new-
      &scop fps2
      &scop fp3
      &scop fp4   or
      {&price-pair-list}
      then do:
        assign
          l-need-create-record =
                                  &scop fl1  buf_temp-ot-supp-tot.new-
                                  &scop fls1
                                  &scop fl2  <> 0
                                  &scop fl3  or
                                  {&price-single-list}
        .

        find first buf_ot-supp-tot exclusive-lock
          where buf_ot-supp-tot.doc-code = buf_temp-ot-supp-tot.doc-code
            and buf_ot-supp-tot.cli-type = buf_temp-ot-supp-tot.cli-type
            and buf_ot-supp-tot.cli-code = buf_temp-ot-supp-tot.cli-code
            and buf_ot-supp-tot.sum-type = buf_temp-ot-supp-tot.sum-type
            and buf_ot-supp-tot.cat-id   = buf_temp-ot-supp-tot.cat-id
          no-error .
        if l-need-create-record
        then do:
          if not available buf_ot-supp-tot
          then do:
            create buf_ot-supp-tot .
          end.
/*          buffer-copy buf_temp-ot-supp-tot to buf_ot-supp-tot*/
          &scop fp1   buf_ot-supp-tot.
          &scop fp2   = buf_temp-ot-supp-tot.
          assign
            {&ot-supp-tot-pair-list}
          .
          assign
            &scop fp1   buf_ot-supp-tot.
            &scop fps1
            &scop fp2   = buf_temp-ot-supp-tot.new-
            &scop fps2
            &scop fp3
            &scop fp4
            {&price-pair-list}
          .
        end.
        else do:
          if available buf_ot-supp-tot
          then do:
            delete buf_ot-supp-tot .
          end.
        end.
      end. /*если было изменение*/
    end. /*each tt-ot-supp-tot*/


    for each buf_temp-ot-supp-line
    on error undo, return error
    :
      if
      &scop fp1   buf_temp-ot-supp-line.
      &scop fps1
      &scop fp2   <> buf_temp-ot-supp-line.new-
      &scop fps2
      &scop fp3
      &scop fp4   or
      {&price-pair-list}
      then do:

        assign
          l-need-create-record =
                                  &scop fl1  buf_temp-ot-supp-line.new-
                                  &scop fls1
                                  &scop fl2  <> 0
                                  &scop fl3  or
                                  {&price-single-list}
        .

        find first buf_ot-supp-line exclusive-lock
          where buf_ot-supp-line.doc-code  = buf_temp-ot-supp-line.doc-code
            and buf_ot-supp-line.cli-type  = buf_temp-ot-supp-line.cli-type
            and buf_ot-supp-line.cli-code  = buf_temp-ot-supp-line.cli-code
            and buf_ot-supp-line.artic     = buf_temp-ot-supp-line.artic
            and buf_ot-supp-line.prod-type = buf_temp-ot-supp-line.prod-type
            and buf_ot-supp-line.prod-code = buf_temp-ot-supp-line.prod-code
            and buf_ot-supp-line.sum-type  = buf_temp-ot-supp-line.sum-type
            and buf_ot-supp-line.cat-id    = buf_temp-ot-supp-line.cat-id
          no-error .
        if l-need-create-record
        then do:
          if not available buf_ot-supp-line
          then do:
            create buf_ot-supp-line .
          end.
/*          buffer-copy buf_temp-ot-supp-line to buf_ot-supp-line*/
          &scop fp1   buf_ot-supp-line.
          &scop fp2   = buf_temp-ot-supp-line.
          assign
            {&ot-supp-line-pair-list}
          .

          assign
            &scop fp1   buf_ot-supp-line.
            &scop fps1
            &scop fp2   = buf_temp-ot-supp-line.new-
            &scop fps2
            &scop fp3
            &scop fp4
            {&price-pair-list}
          .
        end.
        else do:
          if available buf_ot-supp-line
          then do:
            delete buf_ot-supp-line .
          end.
        end.
      end. /*если было изменение*/
    end. /*each tt-ot-supp-line*/

  end.

end procedure. /* store-temp-table */


procedure store-stk-temp-table :

  define buffer buf_temp-stk-supp-tot for temp-stk-supp-tot .
  define buffer buf_stk-supp-tot for ub.stk-supp-tot .
  define buffer buf_temp-stk-supp-line for temp-stk-supp-line .
  define buffer buf_stk-supp-line for ub.stk-supp-line .

  do
  on error undo, return error
  :

    define variable l-need-create-record             as logical no-undo .

    for each buf_temp-stk-supp-tot
    on error undo, return error
    :
      if
      &scop fp1   buf_temp-stk-supp-tot.
      &scop fps1
      &scop fp2   <> buf_temp-stk-supp-tot.new-
      &scop fps2
      &scop fp3
      &scop fp4   or
      {&price-pair-list}
      or ( lookup(buf_temp-stk-supp-tot.sum-type
                 ,{&arh-sale} + "," + {&arh-cost}
                 ) > 0
           and buf_temp-stk-supp-tot.cat-id = {&single-cat-id}
         )
      or ( buf_temp-stk-supp-tot.sum-type begins {&arh-sadt} )
      or ( buf_temp-stk-supp-tot.sum-type begins {&arh-csdt} )
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
/*          buffer-copy buf_temp-stk-supp-tot to buf_stk-supp-tot*/
          &scop fp1   buf_stk-supp-tot.
          &scop fp2   = buf_temp-stk-supp-tot.
          assign
            {&stk-supp-tot-pair-list}
          .
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

    for each buf_temp-stk-supp-line
    on error undo, return error
    :
      if
      &scop fp1   buf_temp-stk-supp-line.
      &scop fps1
      &scop fp2   <> buf_temp-stk-supp-line.new-
      &scop fps2
      &scop fp3
      &scop fp4   or
      {&price-pair-list}
      or ( lookup(buf_temp-stk-supp-line.sum-type
                 ,{&arh-sale} + "," + {&arh-cost}
                 ) > 0
           and buf_temp-stk-supp-line.cat-id = {&single-cat-id}
         )
      or ( buf_temp-stk-supp-line.sum-type begins {&arh-sadt} )
      or ( buf_temp-stk-supp-line.sum-type begins {&arh-csdt} )
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
/*          buffer-copy buf_temp-stk-supp-line to buf_stk-supp-line*/
          &scop fp1 buf_stk-supp-line.
          &scop fp2 = buf_temp-stk-supp-line.
          assign
            {&stk-supp-line-pair-list}
          .
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
    end.

    if v-shift-on
    then do:
      run store-stk-shift-temp-table in this-procedure .
    end.
  end.

end procedure. /* store-temp-table */



procedure store-stk-shift-temp-table :

  define buffer buf_stk-supp-tot  for ub.stk-supp-tot .
  define buffer buf_stk-supp-line for ub.stk-supp-line .
  define buffer buf_temp-shift-stk-supp-tot for temp-shift-stk-supp-tot .
  define buffer buf_temp-shift-stk-supp-line for temp-shift-stk-supp-line .

  do
  on error undo, return error
  :

    define variable l-need-create-record             as logical no-undo .

    for each buf_temp-shift-stk-supp-tot
    on error undo, return error
    :
      if
      &scop fp1   buf_temp-shift-stk-supp-tot.
      &scop fps1
      &scop fp2   <> buf_temp-shift-stk-supp-tot.new-
      &scop fps2
      &scop fp3
      &scop fp4   or
      {&price-pair-list}
      or ( lookup(buf_temp-shift-stk-supp-tot.sum-type
                 ,{&arh-sale} + "," + {&arh-cost}
                 ) > 0
           and buf_temp-shift-stk-supp-tot.cat-id = {&single-cat-id}
         )
      or ( buf_temp-shift-stk-supp-tot.sum-type begins {&arh-sadt} )
      or ( buf_temp-shift-stk-supp-tot.sum-type begins {&arh-csdt} )
      then do:

        assign
          l-need-create-record =
                                  &scop fl1  buf_temp-shift-stk-supp-tot.new-
                                  &scop fls1
                                  &scop fl2  <> 0
                                  &scop fl3  or
                                  {&price-single-list}
                              or ( buf_temp-shift-stk-supp-tot.cat-id = {&single-cat-id} )
        .

        find first buf_stk-supp-tot exclusive-lock
          where buf_stk-supp-tot.obj-type   = buf_temp-shift-stk-supp-tot.obj-type
            and buf_stk-supp-tot.obj-code   = buf_temp-shift-stk-supp-tot.obj-code
            and buf_stk-supp-tot.cli-type   = buf_temp-shift-stk-supp-tot.cli-type
            and buf_stk-supp-tot.cli-code   = buf_temp-shift-stk-supp-tot.cli-code
            and buf_stk-supp-tot.fact-order = buf_temp-shift-stk-supp-tot.fact-order
            and buf_stk-supp-tot.sum-type   = buf_temp-shift-stk-supp-tot.sum-type
            and buf_stk-supp-tot.cat-id     = buf_temp-shift-stk-supp-tot.cat-id
          no-error .
        if l-need-create-record
        then do:
          if not available buf_stk-supp-tot
          then do:
            create buf_stk-supp-tot .
          end.
          /* buffer-copy - не компилируется - приходится перечислять поля вручную */
          /* buffer-copy buf_temp-shift-stk-supp-tot to buf_stk-supp-tot .*/
          &scop fp1   buf_stk-supp-tot.
          &scop fp2   = buf_temp-shift-stk-supp-tot.
          assign
            {&stk-supp-tot-pair-list}
          .
          assign
            &scop fp1   buf_stk-supp-tot.
            &scop fps1
            &scop fp2   = buf_temp-shift-stk-supp-tot.new-
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

    for each buf_temp-shift-stk-supp-line
    on error undo, return error
    :
      if
      &scop fp1   buf_temp-shift-stk-supp-line.
      &scop fps1
      &scop fp2   <> buf_temp-shift-stk-supp-line.new-
      &scop fps2
      &scop fp3
      &scop fp4   or
      {&price-pair-list}
      or ( lookup(buf_temp-shift-stk-supp-line.sum-type
                 ,{&arh-sale} + "," + {&arh-cost}
                 ) > 0
           and buf_temp-shift-stk-supp-line.cat-id = {&single-cat-id}
         )
      or ( buf_temp-shift-stk-supp-line.sum-type begins {&arh-sadt} )
      or ( buf_temp-shift-stk-supp-line.sum-type begins {&arh-csdt} )
      then do:

        assign
          l-need-create-record =
                                  &scop fl1  buf_temp-shift-stk-supp-line.new-
                                  &scop fls1
                                  &scop fl2  <> 0
                                  &scop fl3  or
                                  {&price-single-list}
                              or ( buf_temp-shift-stk-supp-line.cat-id = {&single-cat-id} )
        .

        find first buf_stk-supp-line exclusive-lock
          where buf_stk-supp-line.obj-type   = buf_temp-shift-stk-supp-line.obj-type
            and buf_stk-supp-line.obj-code   = buf_temp-shift-stk-supp-line.obj-code
            and buf_stk-supp-line.cli-type   = buf_temp-shift-stk-supp-line.cli-type
            and buf_stk-supp-line.cli-code   = buf_temp-shift-stk-supp-line.cli-code
            and buf_stk-supp-line.artic      = buf_temp-shift-stk-supp-line.artic
            and buf_stk-supp-line.prod-type  = buf_temp-shift-stk-supp-line.prod-type
            and buf_stk-supp-line.prod-code  = buf_temp-shift-stk-supp-line.prod-code
            and buf_stk-supp-line.fact-order = buf_temp-shift-stk-supp-line.fact-order
            and buf_stk-supp-line.sum-type   = buf_temp-shift-stk-supp-line.sum-type
            and buf_stk-supp-line.cat-id     = buf_temp-shift-stk-supp-line.cat-id
          no-error .
        if l-need-create-record
        then do:
          if not available buf_stk-supp-line
          then do:
            create buf_stk-supp-line .
          end.
          /* buffer-copy - не компилируется - приходится перечислять поля вручную */
          /* buffer-copy buf_temp-shift-stk-supp-line to buf_stk-supp-line .*/
          &scop fp1   buf_stk-supp-line.
          &scop fp2   = buf_temp-shift-stk-supp-line.
          assign
            {&stk-supp-line-pair-list}
          .
          assign
            &scop fp1   buf_stk-supp-line.
            &scop fps1
            &scop fp2   = buf_temp-shift-stk-supp-line.new-
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
    end.
  end.

end procedure. /* store-stk-shift-temp-table */


procedure check-need-process :

  define output parameter p-need-process as logical   no-undo .

  define buffer buf_temp-ot-supp-line for temp-ot-supp-line .

  do
  on error undo, return error return-value
  :
    if can-find (
     first buf_temp-ot-supp-line
      where
        &scop fl1  buf_temp-ot-supp-line.new-
        &scop fls1
        &scop fl2  <> 0
        &scop fl3  or
        {&price-single-list}
      )
    then do:
      /* все суммы по документу нулевые */
      /* документ не нужно сохранять в складском архиве по поставщикам */
      assign
        p-need-process = true
      .
    end.
    else do:
      /* по документу имеются ненулевые суммы */
      /* документ необходимо сохранить в складском архиве по поставщикам */
      assign
        p-need-process = false
      .
    end.
  end.

end procedure. /* check-need-process */


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
      with frame infa.
     end.
  end.
end procedure. /* show-action */