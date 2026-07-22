block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание складского архива по типам приобретения по документу

Автор: Белоусов Илья Александрович
Дата создания: 07/16/07
Author: Ilia Belousov
Creation date: 07/16/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 11/11/02

Общее описание информационных потоков:

Рассчитываются doc-line,parts -> temp-aht-ot-line
temp-aht-ot-line -> temp-aht-ot-tot
Сохраняются в БД  temp-aht-ot-line -> aht-ot-line
                  temp-aht-ot-tot  -> aht-ot-tot
Обновляются таблицы temp-aht-ot-line,aht-stk-line -> aht-stk-line
                    temp-aht-ot-tot,aht-stk-tot -> aht-stk-tot

*/

define input  parameter p-doc-code   as character no-undo .
define input  parameter p-cut-date   as date      no-undo .

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Создание складского архива по типам приобретения по документу".
{ cmp/vssrevis.i "substitute('&1|&2':u,p-doc-code,p-cut-date)" }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/trg-def.i  }
{ gbl/aht.i      }
{ trg/factord.i  }
{ gbl/cur-time.i }
{ rep/r-sale.i   }
{ trg/r-crsa.i   }
{ str/clcprtsl.i }
{ str/prl-vat.i  }

define variable v-ind                       as integer   no-undo .
define variable v-doc-date                  as date      no-undo .
define variable v-start-time                as integer   no-undo .
define variable v-current-time              as character no-undo .
define variable v-current-action            as character no-undo .
define variable v-message-on                as logical   no-undo . /* true - отображать message на экране, false - возвращать message в return-value ("Молчаливый режим") */
define variable v-msgstr                    as character no-undo .


do transaction
on error undo, return error
:
  define frame a
    v-current-action format 'x(40)':u      no-labels skip
    v-ind            format '>>>>>>>9':u   label "Обработано артикулов" skip
    v-current-time   format 'x(8)':u       label "Время расчета документа" skip
    p-doc-code       format 'x(14)':u      label "Документ" skip
    v-doc-date       format '99/99/9999':u label "Дата закрытия документа" skip
    with view-as dialog-box side-labels three-d
    title "Расчет складского архива по типам приобретения"
    .
   define variable mFrameView      as logical   no-undo init yes.
  define variable mFramHandle as handle no-undo.      
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
  v-message-on = (not g#auto) .

  run process-trn-doc in this-procedure
    (input p-doc-code /* p-doc-code */
    ,input p-cut-date /* p-cut-date */
    ) no-error .
  if error-status :error
  then do:
    v-msgstr = 
      vss-workfile + " " + vss-revision + " " + vss-description + {&new-line}
      + "Ошибка при обработке документа" + {&new-line}
      + "Документ " + p-doc-code + {&new-line}
      + "Ограничение на обновление складского архива " + string(p-cut-date) + {&new-line}
      + return-value
    .
    if v-message-on then
      message
        v-msgstr
        view-as alert-box error .
    undo, return error v-msgstr .
  end.
end.

procedure process-trn-doc :

  define input  parameter p-doc-code as character no-undo .
  define input  parameter p-cut-date as date      no-undo .

  define variable v-fact-order                as decimal   no-undo .
  define variable v-shift-end-fact-order      as decimal   no-undo .
  define variable v-day-end-fact-order        as decimal   no-undo .
  define variable v-day-cut-fact-order        as decimal   no-undo .

  define variable v-today as date      no-undo .
  define variable v-time  as integer   no-undo .
  define variable v-msgstr as character no-undo .

  define buffer buf_trn-doc for ub.trn-doc .

  do
  on error undo, return error return-value
  :
    find first buf_trn-doc share-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      v-msgstr = "Не найден документ " + p-doc-code .
      if v-message-on then 
        message
          vss-workfile vss-revision vss-description skip
          v-msgstr skip
          view-as alert-box error .
      undo, return error v-msgstr .
    end.

    assign
      v-doc-date = buf_trn-doc.fact-date
    .
  if mFrameView
  then display
      v-doc-date
      with frame a .

    if buf_trn-doc.status_ <> {&fact}
    then do:
      v-msgstr = 
        "Нельзя рассчитать складской архив по типам приобретения для складского документа не закрытого до статуса " + {&fact} + {&new-line}
        + "Документ " + p-doc-code
      .
      if v-message-on then
      message
        vss-workfile vss-revision vss-description skip
        v-msgstr
        view-as alert-box error .
      undo, return error v-msgstr .
    end.

    define variable v-shift-on as logical   no-undo .
    { gbl/objat.i
      buf_trn-doc.obj-type
      buf_trn-doc.obj-code
      "'shift-on=request'"
      v-shift-on
      no-error
    }
    if error-status :error
    then do:
      v-msgstr = 
        "Ошибка при запуске процедуры objat" + {&new-line}
        + "Объект " + buf_trn-doc.obj-type + " " + string(buf_trn-doc.obj-code) + {&new-line}
        + error-status:get-message (1) + {&new-line}
        + return-value
      .
      message
        vss-workfile vss-revision vss-description skip
        v-msgstr
        view-as alert-box error .
      undo, return error v-msgstr.
    end.

    define variable v-curr-r-b as character no-undo .
    { gbl/curr-r-b.i
      v-curr-r-b
    }

    run factord in this-procedure
      (input  buf_trn-doc.fact-date  /* p-fact-date            */
      ,input  buf_trn-doc.fact-time  /* p-fact-time            */
      ,input  buf_trn-doc.fact-num   /* p-fact-num             */
      ,input  buf_trn-doc.shift-date /* p-shift-date           */
      ,input  buf_trn-doc.shift-num  /* p-shift-num            */
      ,input  v-shift-on             /* p-shift-on             */
      ,output v-fact-order           /* p-fact-order           */
      ,output v-shift-end-fact-order /* p-shift-end-fact-order */
      ,output v-day-end-fact-order   /* p-day-end-fact-order   */
      ) no-error .
    if error-status :error
    or v-fact-order = ?
    or v-fact-order = 0
    then do:
      v-msgstr = 
        "Ошибка при определении фактического номера складского документа" + {&new-line}
        + "doc-code " +          buf_trn-doc.doc-code   + {&new-line}
        + "fact-date " +  string(buf_trn-doc.fact-date) + {&new-line}
        + "fact-time " +  string(buf_trn-doc.fact-time, "HH:MM") + {&new-line}
        + "fact-num " +   string(buf_trn-doc.fact-num)  + {&new-line}
        + "shift-date " + string(buf_trn-doc.shift-date) + {&new-line}
        + "shift-num " +  string(buf_trn-doc.shift-num) + {&new-line}
        + "v-fact-order " + string(v-fact-order)        + {&new-line}
        + "v-shift-end-fact-order " + string(v-shift-end-fact-order) + {&new-line}
        + "v-day-end-fact-order" + string(v-day-end-fact-order) + {&new-line}
        + error-status:get-message(1) + {&new-line}
        + return-value
      . 
      if v-message-on then
        message
          vss-workfile vss-revision vss-description skip
          v-msgstr
          view-as alert-box error .
      undo, return error v-msgstr .
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
      if p-cut-date = buf_trn-doc.fact-date
      then do:
        assign
          v-day-end-fact-order   = v-day-end-fact-order   - {&arh-delta}
        .
      end.
      assign
        v-day-cut-fact-order   = v-day-end-fact-order
      .
    end.

    run aht_add-document in this-procedure
      (input buf_trn-doc.doc-code     /* p-doc-code     */
      ,input buf_trn-doc.obj-type     /* p-obj-type     */
      ,input buf_trn-doc.obj-code     /* p-obj-code     */
      ,input buf_trn-doc.ext-doc-type /* p-ext-doc-type */
      ,input true                     /* p-is-trn-doc   */
      ,input buf_trn-doc.fact-order   /* p-fact-order   */
      ,input buf_trn-doc.fact-date    /* p-fact-date    */
      ,input buf_trn-doc.shift-date   /* p-shift-date   */
      ,input buf_trn-doc.shift-num    /* p-shift-num    */
      ) no-error .
    if error-status :error
    then do:
      v-msgstr =
        "Ошибка при добавлении документа в складской архив по типам приобретения" + {&new-line}
        + "Документ " + p-doc-code + {&new-line}
        + error-status:get-message(1) + {&new-line}
        + return-value
      . 
      if v-message-on then
        message
          vss-workfile vss-revision vss-description skip
          v-msgstr skip
          view-as alert-box error .
      undo, return error v-msgstr .
    end.

    run aht_add-date in this-procedure
      (input buf_trn-doc.obj-type   /* p-obj-type   */
      ,input buf_trn-doc.obj-code   /* p-obj-code   */
      ,input {&aht-stk-normal}      /* p-stk-type   */
      ,input v-day-end-fact-order   /* p-fact-order */
      ,input buf_trn-doc.fact-date  /* p-fact-date  */
      ,input ?                      /* p-shift-date */
      ,input 0                      /* p-shift-num  */
      ) no-error .
    if error-status :error
    then do:
      v-msgstr =
        "Ошибка при добавлении даты в складской архив по типам приобретения" + {&new-line}
        + "Документ " + p-doc-code + {&new-line}
        + error-status:get-message(1) + {&new-line}
        + return-value
      . 
      if v-message-on then
        message
          vss-workfile vss-revision vss-description skip
          v-msgstr skip
          view-as alert-box error .
      undo, return error v-msgstr .
    end.


    run cur-time in this-procedure ( output v-today
                                  , output v-start-time
                                  ).

    run show-action in this-procedure
      (input "Расчет строк документа"
      ).

    define buffer buf_doc-line for ub.doc-line .

    for each buf_doc-line no-lock
      where buf_doc-line.doc-code = buf_trn-doc.doc-code
    on error undo, return error
    :
      define variable v-gds-code           as integer   no-undo .
      { gbl/gds-code.i
        buf_doc-line.artic
        buf_doc-line.prod-type
        buf_doc-line.prod-code
        v-gds-code
      }

      run process-doc-line in this-procedure
        (input recid(buf_doc-line)      /* p-doc-line-recid */
        ,input buf_doc-line.doc-code    /* p-doc-code       */
        ,input buf_doc-line.artic       /* p-artic          */
        ,input buf_doc-line.prod-type   /* p-prod-type      */
        ,input buf_doc-line.prod-code   /* p-prod-code      */
        ,input v-gds-code               /* p-gds-code       */
        ,input buf_trn-doc.obj-type     /* p-obj-type       */
        ,input buf_trn-doc.obj-code     /* p-obj-code       */
        ,input buf_trn-doc.fact-order   /* p-fact-order     */
        ,input buf_trn-doc.ext-doc-type /* p-ext-doc-type   */
        ,input v-curr-r-b               /* p-curr-r-b       */
        ) no-error .
      if error-status :error
      then do:
        v-msgstr =
          "Ошибка при обработке строки документа" + {&new-line} 
          + "Документ " + buf_doc-line.doc-code + {&new-line}
          + "Артикул " + buf_doc-line.artic + " " + buf_doc-line.prod-type + " " + string(buf_doc-line.prod-code) + {&new-line}
          + error-status:get-message(1) + {&new-line}
          + return-value
        .
        if v-message-on then
          message
            vss-workfile vss-revision vss-description skip
            v-msgstr skip
            view-as alert-box error .
        undo, return error v-msgstr .
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
      (input buf_trn-doc.obj-type     /* p-obj-type     */
      ,input buf_trn-doc.obj-code     /* p-obj-code     */
      ,input buf_trn-doc.fact-order   /* p-fact-order   */
      ,input buf_trn-doc.ext-doc-type /* p-ext-doc-type */
      ) no-error .
    if error-status :error
    then do:
      v-msgstr =
        "Ошибка при расчете оборотов по документу" + {&new-line}
        + error-status:get-message(1) + {&new-line}
        + return-value
      . 
      if v-message-on then
        message
          vss-workfile vss-revision vss-description skip
          v-msgstr skip
          view-as alert-box error .
      undo, return error v-msgstr .
    end.

    run show-action in this-procedure
      (input "Сохранение оборота"
      ).

    run aht_store-ot-table in this-procedure no-error .
    if error-status :error
    then do:
      v-msgstr =
        "Ошибка при сохранении оборотов по документу" + {&new-line}
        + error-status:get-message(1) + {&new-line}
        + return-value
      . 
      if v-message-on then
        message
          vss-workfile vss-revision vss-description skip
          v-msgstr skip
          view-as alert-box error .
      undo, return error v-msgstr .
    end.

    run show-action in this-procedure
      (input "Сохранение остатков"
      ).

    run aht_update-stk-table in this-procedure
      (input v-day-end-fact-order     /* p-fact-order     */
      ,input v-day-cut-fact-order     /* p-cut-fact-order */
      ,input buf_trn-doc.ext-doc-type /* p-ext-doc-type   */
      ,input true                     /* p-trn-doc        */
      ) no-error .
    if error-status :error
    then do:
      v-msgstr =
        "Ошибка при расчете остатков" + {&new-line} 
        + error-status:get-message(1) + {&new-line}
        + return-value
      . 
      if v-message-on then
        message
          vss-workfile vss-revision vss-description skip
          v-msgstr skip
          view-as alert-box error .
      undo, return error v-msgstr .
    end.

    run show-action in this-procedure
      (input "Расчет документа закончен"
      ).

  end.

end procedure. /* process-trn-doc */



procedure process-doc-line :

  define input  parameter p-doc-line-recid as recid     no-undo .
  define input  parameter p-doc-code       like ub.doc-line.doc-code  no-undo .
  define input  parameter p-artic          like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type      like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code      like ub.doc-line.prod-code no-undo .
  define input  parameter p-gds-code       as integer   no-undo .
  define input  parameter p-obj-type       like ub.trn-doc.obj-type   no-undo .
  define input  parameter p-obj-code       like ub.trn-doc.obj-code   no-undo .
  define input  parameter p-fact-order     like ub.trn-doc.fact-order no-undo .
  define input  parameter p-ext-doc-type   like ub.trn-doc.ext-doc-type no-undo .
  define input  parameter p-curr-r-b       as character no-undo .

  define variable vss-description as character no-undo initial "process-doc-line-01: обработка строки документа".

  define variable v-aht-type-list   as character extent 6 no-undo
    initial [{&aht-repayment}, {&aht-cons_acc}, {&aht-cons_benf}, {&aht-resp_stor}, {&aht-old_cons}, {&aht-service}] .
  define variable v-aht-type        as character no-undo .
  define variable v-aht-type-ind    as integer   no-undo .

  define variable v-cost-fact-qnty     as decimal   no-undo .
  define variable v-allsum-sum-type    as character no-undo .

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

  do
  on error undo, return error
  :

    /* расчет учетной цены документа */
    run clcprtsl_calc-line in this-procedure
      (input p-doc-line-recid
      ) no-error .
    if error-status :error
    then do:
      v-msgstr = 
        "Ошибка при вызове процедуры clcprtsl_calc-line" + {&new-line}
        + "Документ " + p-doc-code + {&new-line}
        + "Артикул " + p-artic + " " + p-prod-type + " " + string(p-prod-code) + {&new-line}
        + error-status:get-message(1) + {&new-line}
        + return-value
      . 
      if v-message-on then
        message
          vss-workfile vss-revision vss-description skip
          v-msgstr skip
          view-as alert-box error .
      undo, return error v-msgstr .
    end.

    aht-type_block:
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
      if not available buf_tt-allsum-line
      then do:
        /* в накладной отсутствует товар с указанным типом приобретения */
        next aht-type_block .
      end.

      assign
        v-fact-qnty           = buf_tt-allsum-line.fact-qnty
        v-cost-fact-qnty      = buf_tt-allsum-line.fact-qnty
        v-cost-sum-base       = buf_tt-allsum-line.sum-dsc-base-acc
        v-cost-sum-rubl       = buf_tt-allsum-line.sum-dsc-rubl-acc
        v-cost-vat-base       = buf_tt-allsum-line.vat-base-acc
        v-cost-vat-rubl       = buf_tt-allsum-line.vat-rubl-acc
        v-cost-slt-base       = buf_tt-allsum-line.slt-base-acc
        v-cost-slt-rubl       = buf_tt-allsum-line.slt-rubl-acc
        v-cost-road-tax-base  = buf_tt-allsum-line.road-tax-base-acc
        v-cost-road-tax-rubl  = buf_tt-allsum-line.road-tax-rubl-acc
        v-cost-excise-base    = buf_tt-allsum-line.excise-base-acc
        v-cost-excise-rubl    = buf_tt-allsum-line.excise-rubl-acc
        v-cost-transport-base = buf_tt-allsum-line.transport-base-acc
        v-cost-transport-rubl = buf_tt-allsum-line.transport-rubl-acc
        v-cost-other-base     = buf_tt-allsum-line.other-base-acc
        v-cost-other-rubl     = buf_tt-allsum-line.other-rubl-acc
        v-cost-discnt-base    = buf_tt-allsum-line.dsc-base-acc
        v-cost-discnt-rubl    = buf_tt-allsum-line.dsc-rubl-acc
        v-crsa-sum-base       = buf_tt-allsum-line.sum-dsc-base-cur
        v-crsa-sum-rubl       = buf_tt-allsum-line.sum-dsc-rubl-cur
        v-crsa-vat-base       = buf_tt-allsum-line.vat-base-cur
        v-crsa-vat-rubl       = buf_tt-allsum-line.vat-rubl-cur
        v-crsa-slt-base       = buf_tt-allsum-line.slt-base-cur
        v-crsa-slt-rubl       = buf_tt-allsum-line.slt-rubl-cur
        v-crsa-road-tax-base  = buf_tt-allsum-line.road-tax-base-cur
        v-crsa-road-tax-rubl  = buf_tt-allsum-line.road-tax-rubl-cur
        v-crsa-excise-base    = buf_tt-allsum-line.excise-base-cur
        v-crsa-excise-rubl    = buf_tt-allsum-line.excise-rubl-cur
        v-crsa-transport-base = 0
        v-crsa-transport-rubl = 0
        v-crsa-other-base     = 0
        v-crsa-other-rubl     = 0
        v-crsa-discnt-base    = buf_tt-allsum-line.dsc-base-cur
        v-crsa-discnt-rubl    = buf_tt-allsum-line.dsc-rubl-cur
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
        v-sale-transport-base = 0
        v-sale-transport-rubl = 0
        v-sale-other-base     = 0
        v-sale-other-rubl     = 0
        v-sale-discnt-base    = buf_tt-allsum-line.dsc-base-doc
        v-sale-discnt-rubl    = buf_tt-allsum-line.dsc-rubl-doc
      .

      if
      &scop fl1  v-cost-
      &scop fls1
      &scop fl2  = ?
      &scop fl3  or
      {&price-single-list}
      then do:
        v-msgstr = "Программа clcprtsl.i вернула неопределенные значения" . 
        if v-message-on then
        message
          vss-workfile vss-revision vss-description skip
          v-msgstr skip
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
        undo, return error v-msgstr .
      end.

      if
      &scop fl1  v-crsa-
      &scop fls1
      &scop fl2  = ?
      &scop fl3  or
      {&price-single-list}
      then do:
        v-msgstr = "Программа clcprtsl.i вернула неопределенные значения" . 
        if v-message-on then
        message
          vss-workfile vss-revision vss-description skip
          v-msgstr skip
          "Документ" p-doc-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "Тип суммы" v-allsum-sum-type skip
          &scop fp1   "crsa-
          &scop fps1  "
          &scop fp2   v-crsa-
          &scop fps2
          &scop fp3   skip
          &scop fp4
          {&price-pair-list}
          view-as alert-box error .
        undo, return error v-msgstr .
      end.

      if
      &scop fl1  v-sale-
      &scop fls1
      &scop fl2  = ?
      &scop fl3  or
      {&price-single-list}
      then do:
        v-msgstr = "Программа clcprtsl.i вернула неопределенные значения" . 
        if v-message-on then
        message
          vss-workfile vss-revision vss-description skip
          v-msgstr skip
          "Документ" p-doc-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "Тип суммы" v-allsum-sum-type skip
          &scop fp1   "sale-
          &scop fps1  "
          &scop fp2   v-sale-
          &scop fps2
          &scop fp3   skip
          &scop fp4
          {&price-pair-list}
          view-as alert-box error .
        undo, return error v-msgstr .
      end.


      /* запись информации о продажной цене товара */
      run aht_store-ot-line in this-procedure
        (input p-doc-code     /* p-doc-code      */
        ,input p-gds-code     /* p-gds-code      */
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
        v-msgstr =
          "Ошибка при сохранении сумм по документу" + {&new-line}
          + "Тип приобретения " + v-aht-type + {&new-line}
          + "Документ " + p-doc-code + {&new-line}
          + "Артикул " + p-artic + " " + p-prod-type + " " + string(p-prod-code) + {&new-line}
          + error-status:get-message(1) + {&new-line}
          + return-value
        . 
        if v-message-on then
          message
            vss-workfile vss-revision vss-description skip
            v-msgstr skip
            view-as alert-box error .
        undo, return error v-msgstr .
      end.
    end.
  end.
end procedure. /* process-doc-line */


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
      with frame a.
  end.
end procedure. /* show-action */