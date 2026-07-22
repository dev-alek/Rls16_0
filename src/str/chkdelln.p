/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка линии документа закрытого на факт на возможность удалени

Автор: Чернова Светлана Александровна
Дата создания: 10/15/07
Author: Svetlana Chernova
Creation date: 10/15/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 03/25/05

Анализ ведется от текущей даты до даты удаляемого документа.
Основное требование: в свободной и расходной зонах
по обычным партиям должно быть неотрицательное количество.
по порождённым партиям количество не должно превышать
оригинальное оприходованное количество по партии
и не должно быть положительного количества в зоне, где было
отрицательное количество.

*/

define input  parameter p-db-num        as integer   no-undo .
define input  parameter p-user-id       as character no-undo .
define input  parameter p-obj-type      as character no-undo .
define input  parameter p-obj-code      as integer   no-undo .
define input  parameter p-artic         as character no-undo .
define input  parameter p-prod-type     as character no-undo .
define input  parameter p-prod-code     as integer   no-undo .
define input  parameter p-doc-code      as character no-undo .
define input  parameter p-phdoc-code    as character no-undo .
define input  parameter p-fact-order    as decimal   no-undo .
define input  parameter p-doc-type      as character no-undo .
define input  parameter p-ext-doc-type  as character no-undo .
define input  parameter p-shift-date    as date      no-undo .
define input  parameter p-shift-num     as integer   no-undo .
define input  parameter p-fact-qnty     as decimal   no-undo .
define input  parameter p-file-name-err as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверка линии документа закрытого на факт на возможность удаления".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ str/lib-trn.i  }

define stream str-err .

define variable v-flag-err              as logical   no-undo .
define variable v-str-err               as char   no-undo .
define variable v-shift-on              as logical   no-undo .
define variable v-is-petrolium          as logical   no-undo .
define variable v-is-pieces             as logical   no-undo .
define variable v-ok                    as logical   no-undo .
define variable v-gds-code              as integer   no-undo .
define variable v-free-qnty             as decimal   no-undo .
define variable v-total-free-qnty       as decimal   no-undo .
define variable v-output-qnty           as decimal   no-undo .
define variable v-total-output-qnty     as decimal   no-undo .
define variable v-new-free-qnty         as decimal   no-undo .
define variable v-new-total-free-qnty   as decimal   no-undo .
define variable v-new-output-qnty       as decimal   no-undo .
define variable v-new-total-output-qnty as decimal   no-undo .
define variable v-min-free-qnty         as decimal   no-undo .
define variable v-max-free-qnty         as decimal   no-undo .
define variable v-min-output-qnty       as decimal   no-undo .
define variable v-max-output-qnty       as decimal   no-undo .

define variable v-create-part       as logical   no-undo .
define variable v-old-return        as logical   no-undo .
define variable v-create-obj        as logical   no-undo .
define variable v-is-hold           as logical   no-undo .
define variable v-rsrv-code         as character no-undo .
define variable v-unrv-code         as character no-undo .
define variable v-need-rsrv         as logical   no-undo .
define variable v-need-unrv         as logical   no-undo .
define variable v-rsrv-sign         as integer   no-undo .
define variable v-unrv-sign         as integer   no-undo .
define variable v-action            as character no-undo .

define temp-table temp-archive-parts no-undo
  field doc-code            as character
  field fact-order          as decimal
  field fact-qnty           as decimal
  field new-total-free-qnty as decimal
  field new-total-out-qnty  as decimal
  field error-flag          as logical
  field parts-recid         as recid
  field ext-doc-type        as character
  index xpk is primary unique doc-code
  index xfact-order fact-order descending
  .

define buffer cdlinv_doc-line        for ub.doc-line .
define buffer cdl_shift-obj          for ub.shift-obj .
define buffer cdl_rvs-doc            for ub.rvs-doc .
define buffer cdl_rvs-line           for ub.rvs-line .
define buffer cdl_doc-line           for ub.doc-line .
define buffer buf_trn-doc            for ub.trn-doc .
define buffer buf_doc-line           for ub.doc-line .
define buffer buf_parts              for ub.parts .
define buffer free_buf_parts         for ub.parts .
define buffer output_buf_parts       for ub.parts .
define buffer archive_parts          for ub.parts .
define buffer buf_parts-attr         for ub.parts-attr .
define buffer buf_temp-archive-parts for temp-archive-parts .

do
on error undo, return error return-value
:
  assign
    v-flag-err = false
  .

  { gbl/gds-code.i
    p-artic
    p-prod-type
    p-prod-code
    v-gds-code
    no-error
  }
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении кода товара" skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error "CRITICAL" .
  end.
  /*for each cdlinv_doc-line no-lock
    where cdlinv_doc-line.obj-type     = p-obj-type
      and cdlinv_doc-line.obj-code     = p-obj-code
      and cdlinv_doc-line.artic        = p-artic
      and cdlinv_doc-line.prod-type    = p-prod-type
      and cdlinv_doc-line.prod-code    = p-prod-code
      and cdlinv_doc-line.ext-doc-type = {&TDEDT_Peresort}
      and cdlinv_doc-line.status_      = {&fact}
      and cdlinv_doc-line.fact-order   > p-fact-order
  on error undo, return error return-value
  :
    output stream str-err to value(p-file-name-err) append .
    put stream str-err unformatted
      substitute ("На объекте &1 &2 существует пересортица (Документ № &3 ) по товару &4 &5 &6 с большим логическим номером &7. Невозможно удалить документ &8.",
                  cdlinv_doc-line.obj-type,
                  cdlinv_doc-line.obj-code,
                  cdlinv_doc-line.doc-code,
                  p-artic,
                  p-prod-type,
                  p-prod-code,
                  cdlinv_doc-line.fact-order,
                  p-doc-code).
    output stream str-err close.
    undo, return error "CRITICAL".
  end.*/

  { str/is-petrl.i
    p-artic
    p-prod-type
    p-prod-code
    v-is-petrolium
    v-is-pieces
    no-error
  }
  if error-status :error
  then do:
    output stream str-err to value(p-file-name-err) append .
    put stream str-err unformatted return-value.
    output stream str-err close.
    undo, return error "CRITICAL".
  end.

  if  v-is-petrolium = yes
  and v-is-pieces    = no
  then do:
    { gbl/objat.i
      p-obj-type
      p-obj-code
      "'shift-on=request'"
      v-shift-on
    }
    if v-shift-on
    then do:
      find first cdl_shift-obj
        where cdl_shift-obj.obj-type = p-obj-type
          and cdl_shift-obj.obj-code = p-obj-code
          and cdl_shift-obj.status_  = {&sht-current}
        use-index pi
        no-error.
      if not available cdl_shift-obj
      or cdl_shift-obj.shift-date <> p-shift-date
      or cdl_shift-obj.shift-num  <> p-shift-num
      then do:
        define variable v-chk-act-host-code as integer   no-undo .
        { gbl/hostcode.i
          p-obj-type
          p-obj-code
          v-chk-act-host-code
        }

        case p-doc-type :
          when {&income} then do:
            assign
              v-action = 'actn_income_del-ptrl-prev-shft':U
            .
          end.
          when {&expense} then do:
            assign
              v-action = 'actn_expense_del-ptrl-prev-shft':U
            .
          end.
          when {&write-off} then do:
            assign
              v-action = 'actn_write-off_del-ptrl-prev-shft':U
            .
          end.
          when {&return} then do:
            assign
              v-action = 'actn_return_del-ptrl-prev-shft':U
            .
          end.
          when {&inventory} then do:
            assign
              v-action = 'actn_inventory_del-ptrl-prev-shft':U
            .
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              "Неизвестный тип документа" skip
              "Тип документа" p-doc-type skip
              "Код документа" p-doc-code skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end case .
        { gbl/chk-actg.i
          p-db-num
          p-user-id
          {&action-head-code-main}
          v-action
          {&cntxt-object}
          v-chk-act-host-code
          p-obj-type
          p-obj-code
          0
          0
          0
          true
          v-ok
        }

        if not v-ok
        then do:
          output stream str-err to value(p-file-name-err) append .
          put stream str-err unformatted substitute ("Товар &1 &2 &3 - топливо. Вы не имеете прав на удаление документов по топливу в предыдущих сменах. Документы можно удалить только в текущей смене."
                                    , p-artic
                                    , p-prod-type
                                    , p-prod-code
                                    ).
          output stream str-err close.
          undo, return error "CRITICAL".
        end.
      end.
    end.

    /*Не должно быть открытых сверок по топливу*/
    &scop open-rvs-doc ~
    for each cdl_rvs-doc no-lock ~
      where cdl_rvs-doc.obj-type = p-obj-type  ~
        and cdl_rvs-doc.obj-code = p-obj-code  ~
        and cdl_rvs-doc.rvs-type ne ~{&test-asi} ~
        and cdl_rvs-doc.status_  ~{&znak} {&fact} ~
    ,first cdl_rvs-line no-lock ~
      where cdl_rvs-line.gds-code = v-gds-code ~
        and cdl_rvs-line.rvs-code = cdl_rvs-doc.rvs-code ~
        and cdl_rvs-line.obj-type = p-obj-type ~
        and cdl_rvs-line.obj-code = p-obj-code ~
    on error undo, return error return-value ~
    : ~
      output stream str-err to value(p-file-name-err) append . ~
      put stream str-err unformatted ~
        substitute ("&1По товару &2 &3 &4 есть незакрытая сверка &5.&1" ~
                   ,{&new-line} ~
                   ,p-artic ~
                   ,p-prod-type ~
                   ,p-prod-code ~
                   ,cdl_rvs-line.rvs-code ~
                   ). ~
      output stream str-err close . ~
      assign ~
        v-flag-err = yes ~
        v-str-err = substitute ("По товару &2 &3 &4 есть незакрытая сверка &5.&1" ~
                   ,{&new-line} ~
                   ,p-artic ~
                   ,p-prod-type ~
                   ,p-prod-code ~
                   ,cdl_rvs-line.rvs-code ~
                   ) ~
      . ~
    end.
    &scop znak >
    {&open-rvs-doc}
    &scop znak <
    {&open-rvs-doc}
  end.

  /* Не должно быть открытых инвентаризаций */
  &scop open-trn-doc ~
  for each cdl_doc-line no-lock ~
    where cdl_doc-line.obj-type     = p-obj-type     ~
      and cdl_doc-line.obj-code     = p-obj-code     ~
      and cdl_doc-line.prod-type    = p-prod-type    ~
      and cdl_doc-line.prod-code    = p-prod-code    ~
      and cdl_doc-line.artic        = p-artic        ~
      and cdl_doc-line.ext-doc-type = {&TDEDT_Inv}   ~
      and cdl_doc-line.status_      ~{&znak} {&fact} ~
      and cdl_doc-line.doc-code     <> p-doc-code    ~
  on error undo, return error return-value ~
  : ~
      output stream str-err to value(p-file-name-err) append . ~
      put stream str-err unformatted  substitute ("По товару &1 &2 &3 есть открытый документ &4.", ~
                                                  p-artic,                    ~
                                                  p-prod-type,                ~
                                                  p-prod-code,                ~
                                                  cdl_doc-line.doc-code) skip.~
      output stream str-err close . ~
      assign ~
        v-flag-err = yes ~
        v-str-err  = substitute ("По товару &1 &2 &3 есть открытый документ &4.", ~
                                                  p-artic,                    ~
                                                  p-prod-type,                ~
                                                  p-prod-code,                ~
                                                  cdl_doc-line.doc-code)  ~
      . ~
  end.
  &scop znak >
  {&open-trn-doc}
  &scop znak <
  {&open-trn-doc}

  /* Не должно быть открытых пересортиц */
  &scop open-trn-doc ~
  for each cdl_doc-line no-lock ~
    where cdl_doc-line.obj-type     = p-obj-type     ~
      and cdl_doc-line.obj-code     = p-obj-code     ~
      and cdl_doc-line.prod-type    = p-prod-type    ~
      and cdl_doc-line.prod-code    = p-prod-code    ~
      and cdl_doc-line.artic        = p-artic        ~
      and cdl_doc-line.ext-doc-type = {&TDEDT_Peresort}   ~
      and cdl_doc-line.status_      ~{&znak} {&fact} ~
      and cdl_doc-line.doc-code     <> p-doc-code    ~
  on error undo, return error return-value ~
  : ~
      output stream str-err to value(p-file-name-err) append . ~
      put stream str-err unformatted  substitute ("По товару &1 &2 &3 есть открытый документ &4.", ~
                                                  p-artic,                    ~
                                                  p-prod-type,                ~
                                                  p-prod-code,                ~
                                                  cdl_doc-line.doc-code) skip.~
      output stream str-err close . ~
      assign ~
        v-flag-err = yes ~
      . ~
  end.
  &scop znak >
  {&open-trn-doc}
  &scop znak <
  {&open-trn-doc}


  /* для всех архивных партий документа                                  */
  /* определяем состояние свободной и расходной зоны после закрытия       */
  /* каждого документа, в случае как если бы удаляемого документа не было */
  for each buf_parts exclusive-lock
    where buf_parts.out-code  = p-doc-code
      and buf_parts.obj-type  = p-obj-type
      and buf_parts.obj-code  = p-obj-code
      and buf_parts.artic     = p-artic
      and buf_parts.prod-type = p-prod-type
      and buf_parts.prod-code = p-prod-code
  on error undo, return error return-value
  :
    /* определяем первоначальное количество по партии */
    find first buf_parts-attr
      where buf_parts-attr.in-code   = buf_parts.in-code
        and buf_parts-attr.gds-code  = v-gds-code
        and buf_parts-attr.part-code = buf_parts.part-code
      no-error .
    if not available buf_parts-attr
    then do:
      output stream str-err to value(p-file-name-err) append .
      put stream str-err unformatted
        substitute("&1У партии отсутствует атрибут. Приходный документ: &2. Код товара: &3. Код партии &4. Артикул &5 &6 &7.&1"
                  ,{&new-line}         /* 1 */
                  ,buf_parts.in-code   /* 2 */
                  ,v-gds-code          /* 3 */
                  ,buf_parts.part-code /* 4 */
                  ,p-artic             /* 5 */
                  ,p-prod-type         /* 6 */
                  ,p-prod-code         /* 7 */
                  ) .
      output stream str-err close.
      undo, return error "CRITICAL".
    end.

    if  buf_parts-attr.supp-type = buf_parts-attr.obj-type
    and buf_parts-attr.supp-code = buf_parts-attr.obj-code
    then do:

      define variable v-doc-type as character no-undo .
      { gbl/trnextdt.i
        buf_parts-attr.ext-doc-type
        v-doc-type
      }
      if { trg/partsprm.i "part-rsrv-free" v- buf_parts-attr.fact-qnty }
      then do:
        assign
          v-min-free-qnty   = - abs(buf_parts-attr.fact-qnty)
          v-max-free-qnty   = 0
          v-min-output-qnty = 0
          v-max-output-qnty = abs(buf_parts-attr.fact-qnty)
        .
      end.
      else do:
        assign
          v-min-free-qnty   = 0
          v-max-free-qnty   =   abs(buf_parts-attr.fact-qnty)
          v-min-output-qnty = - abs(buf_parts-attr.fact-qnty)
          v-max-output-qnty = 0
        .
      end.
    end.
    else do:
      if p-ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass} or p-ext-doc-type = {&TDEDT_Vozvrat_Vnesh}  then do:
        assign
          v-min-free-qnty   = - abs(buf_parts-attr.fact-qnty)
          v-max-free-qnty   = abs(buf_parts-attr.fact-qnty)
          v-min-output-qnty = - abs(buf_parts-attr.fact-qnty)
          v-max-output-qnty = abs(buf_parts-attr.fact-qnty)
        .
      end.
      else do:
        assign
          v-min-free-qnty   = 0
          v-max-free-qnty   = buf_parts-attr.fact-qnty
          v-min-output-qnty = 0
          v-max-output-qnty = buf_parts-attr.fact-qnty
        .
       end.
    end.



    /* определяем каким образом была создана партия на данном объекте */
    /* возможны следующие случаи    */
    /*   приход_внешний             */
    /*   приход_внутренний          */
    /*   расход_порожденная_партия  */
    /*   возврат_порожденная_партия */
    /*   партия_старого_возврата    */

    /* определяем первоначальные параметры партии */
    { gbl/partparm.i
      recid(buf_parts)
      v-create-part
      v-old-return
      v-create-obj
    }
    { gbl/hold-doc.i
      p-doc-code
      v-is-hold
    }
    { gbl/partcond.i
      p-ext-doc-type
      v-is-hold
      buf_parts.fact-qnty
      v-create-part
      v-old-return
      v-rsrv-code
      v-unrv-code
      v-need-rsrv
      v-need-unrv
      v-rsrv-sign
      v-unrv-sign
    }

    assign
      v-free-qnty       = 0
      v-total-free-qnty = 0
    .
    for each free_buf_parts exclusive-lock
      where free_buf_parts.obj-type  = buf_parts.obj-type
        and free_buf_parts.obj-code  = buf_parts.obj-code
        and free_buf_parts.artic     = buf_parts.artic
        and free_buf_parts.prod-type = buf_parts.prod-type
        and free_buf_parts.prod-code = buf_parts.prod-code
        and free_buf_parts.in-code   = buf_parts.in-code
        and free_buf_parts.part-code = buf_parts.part-code
        and free_buf_parts.rsrv-free = yes
        and free_buf_parts.status_   = no
        and free_buf_parts.in-code   <> free_buf_parts.out-code
    on error undo, return error return-value
    :
      if free_buf_parts.out-code = {&free-code}
      then do:
        assign
          v-free-qnty       = v-free-qnty       + free_buf_parts.qnty
          v-total-free-qnty = v-total-free-qnty + free_buf_parts.qnty
        .
      end.
      else do:
        assign
          v-total-free-qnty = v-total-free-qnty + abs(free_buf_parts.qnty)
        .
      end.
    end.

    assign
      v-output-qnty       = 0
      v-total-output-qnty = 0
    .
    for each output_buf_parts exclusive-lock
      where output_buf_parts.obj-type  = buf_parts.obj-type
        and output_buf_parts.obj-code  = buf_parts.obj-code
        and output_buf_parts.artic     = buf_parts.artic
        and output_buf_parts.prod-type = buf_parts.prod-type
        and output_buf_parts.prod-code = buf_parts.prod-code
        and output_buf_parts.in-code   = buf_parts.in-code
        and output_buf_parts.part-code = buf_parts.part-code
        and output_buf_parts.rsrv-free = no
        and output_buf_parts.status_   = no
        and output_buf_parts.in-code   <> output_buf_parts.out-code
    on error undo, return error return-value
    :
      if output_buf_parts.out-code = {&output-code}
      then do:
        assign
          v-output-qnty       = v-output-qnty       + output_buf_parts.qnty
          v-total-output-qnty = v-total-output-qnty + output_buf_parts.qnty
        .
      end.
      else do:
        assign
          v-total-output-qnty = v-total-output-qnty + abs(output_buf_parts.qnty)
        .
      end.
    end.

    /* Не должно быть архивных партий по партиям, порожденным данным документом */
    if buf_parts.in-code = buf_parts.out-code
    then do:
      for each archive_parts
        where archive_parts.obj-type  = buf_parts.obj-type
          and archive_parts.obj-code  = buf_parts.obj-code
          and archive_parts.artic     = buf_parts.artic
          and archive_parts.prod-type = buf_parts.prod-type
          and archive_parts.prod-code = buf_parts.prod-code
          and archive_parts.in-code   = buf_parts.in-code
          and archive_parts.part-code = buf_parts.part-code
          and archive_parts.out-code <> buf_parts.out-code
          and archive_parts.out-code <> {&free-code}
          and archive_parts.out-code <> {&output-code}
          and archive_parts.doc-type <> {&act-overvalue}
      on error undo, return error return-value
      :
        if  p-phdoc-code <> ?
        and p-phdoc-code <> '0'
        then do:
          if archive_parts.out-code = p-phdoc-code
          then do:
            next.
          end.
        end.
        output stream str-err to value(p-file-name-err) append .
        put stream str-err unformatted
          substitute("&1Найдены архивные партии товара &2 &3 &4 в документе &5.&1Порожденная партия не может быть удалена.&1"
                    ,{&new-line}
                    ,p-artic
                    ,p-prod-type
                    ,p-prod-code
                    ,archive_parts.out-code
                    ).
        output stream str-err close.
        assign
          v-flag-err = yes
        .
      end.
    end.

    assign
      v-new-free-qnty         = v-free-qnty
      v-new-total-free-qnty   = v-total-free-qnty
      v-new-output-qnty       = v-output-qnty
      v-new-total-output-qnty = v-total-output-qnty
    .

    if v-need-rsrv = true
    then do:
      case v-rsrv-code
      :
        when {&free-code}
        then do:
          assign
            v-new-free-qnty         = v-new-free-qnty
                                    + v-rsrv-sign * buf_parts.fact-qnty
            v-new-total-free-qnty   = v-new-total-free-qnty
                                    + v-rsrv-sign * buf_parts.fact-qnty
          .
        end.
        when {&output-code}
        then do:
          assign
            v-new-output-qnty       = v-new-output-qnty
                                    + v-rsrv-sign * buf_parts.fact-qnty
            v-new-total-output-qnty = v-new-total-output-qnty
                                    + v-rsrv-sign * buf_parts.fact-qnty
          .
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Внутренняя ошибка" skip
            "Неизвестное значение v-rsrv-code" v-rsrv-code skip
            view-as alert-box error .
          undo, return error "CRITICAL".
        end.
      end case .
    end.
    if v-need-unrv = true
    then do:
      case v-unrv-code
      :
        when {&free-code}
        then do:
          assign
            v-new-free-qnty         = v-new-free-qnty
                                    + v-unrv-sign * buf_parts.fact-qnty
            v-new-total-free-qnty   = v-new-total-free-qnty
                                    + v-unrv-sign * buf_parts.fact-qnty
          .
        end.
        when {&output-code}
        then do:
          assign
            v-new-output-qnty       = v-new-output-qnty
                                    + v-unrv-sign * buf_parts.fact-qnty
            v-new-total-output-qnty = v-new-total-output-qnty
                                    + v-unrv-sign * buf_parts.fact-qnty
          .
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Внутренняя ошибка" skip
            "Неизвестное значение v-unrv-code" v-unrv-code skip
            view-as alert-box error .
          undo, return error "CRITICAL".
        end.
      end case .
    end.

    for each buf_temp-archive-parts
    on error undo, return error return-value
    :
      delete buf_temp-archive-parts .
    end.

    /* анализ всех архивных партий, кроме партии, зарезервированной за текущим документом */
    for each archive_parts
      where archive_parts.obj-type  = buf_parts.obj-type
        and archive_parts.obj-code  = buf_parts.obj-code
        and archive_parts.artic     = buf_parts.artic
        and archive_parts.prod-type = buf_parts.prod-type
        and archive_parts.prod-code = buf_parts.prod-code
        and archive_parts.in-code   = buf_parts.in-code
        and archive_parts.part-code = buf_parts.part-code
        and archive_parts.out-code <> buf_parts.out-code
        and archive_parts.out-code <> {&free-code}
        and archive_parts.out-code <> {&output-code}
        and archive_parts.doc-type <> {&act-overvalue}
    on error undo, return error return-value
    :

      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = archive_parts.out-code
        no-error .
      if not available buf_trn-doc
      then do:
        output stream str-err to value(p-file-name-err) append .
        put stream str-err unformatted
          substitute ("&1Не найден документ &7 у которого зарезервирована партия. Приходный документ &1. Код товара &2. Код партии &3. Артикул &4 &5 &6."
                    ,{&new-line}                     /* 1 */
                    ,buf_parts.in-code               /* 2 */
                    ,v-gds-code                      /* 3 */
                    ,buf_parts.part-code             /* 4 */
                    ,p-artic                         /* 5 */
                    ,p-prod-type                     /* 6 */
                    ,p-prod-code                     /* 7 */
                    ,buf_temp-archive-parts.doc-code /* 8 */
                    ).
        output stream str-err close.
        undo, return error "CRITICAL".
      end.

      if buf_trn-doc.status_ = {&fact}
      then do:
        /* для архивных партий документа, закрытых до статуса {&fact} */
        create buf_temp-archive-parts .
        assign
          buf_temp-archive-parts.doc-code     = buf_trn-doc.doc-code
          buf_temp-archive-parts.fact-order   = buf_trn-doc.fact-order
          buf_temp-archive-parts.fact-qnty    = archive_parts.fact-qnty
          buf_temp-archive-parts.parts-recid  = recid(archive_parts)
          buf_temp-archive-parts.ext-doc-type = buf_trn-doc.ext-doc-type
        .
      end.
    end.
    if p-ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass} or p-ext-doc-type = {&TDEDT_Vozvrat_Vnesh}  then do:
       if ( v-new-free-qnty +  v-new-output-qnty ) <> buf_parts-attr.fact-qnty then do:
          output stream str-err to value(p-file-name-err) append .
          put stream str-err unformatted
            substitute("&1После удаления документа свободное количество в приходной или расходной зоне&1выйдет за допустимые пределы.&1Приходный документ: &2.&1Код товара: &3.&1Код партии: &4.&1Артикул: &5 &6 &7 &8 &9 &10 .&1 "
                      ,{&new-line}         /* 1 */
                      ,buf_parts.in-code   /* 2 */
                      ,v-gds-code          /* 3 */
                      ,buf_parts.part-code /* 4 */
                      ,p-artic             /* 5 */
                      ,buf_parts.out-code   /* 6 */
                      ,p-ext-doc-type
                      ,( v-new-free-qnty  +  v-new-output-qnty  - buf_parts-attr.fact-qnty )
                      ) .
          put stream str-err unformatted
            "Первоначальное количество в партии:                 " buf_parts-attr.fact-qnty skip
            "Свободное количество по партии в свободной зоне:    " v-new-free-qnty          skip
            "Свободное количество по партии в расходной зоне:    " v-new-output-qnty
            .
          output stream str-err close.
          

          assign
            v-flag-err = yes
            v-str-err  = substitute("После удаления документа свободное количество в приходной или расходной зоне 
                       выйдет за допустимые пределы.&1
                       Приходный документ: &2.&1Код товара: &3.&1Код партии: &4.&1Артикул: &5 &6 &7 &8 &9 &10 .&1 "
                      ,{&new-line}         /* 1 */
                      ,buf_parts.in-code   /* 2 */
                      ,v-gds-code          /* 3 */
                      ,buf_parts.part-code /* 4 */
                      ,p-artic             /* 5 */
                      ,buf_parts.out-code   /* 6 */
                      ,p-ext-doc-type
                      ,string( v-new-free-qnty  +  v-new-output-qnty  - buf_parts-attr.fact-qnty )
                      ) 
          .
       end.
    end.
    else do:
        if v-new-free-qnty          < v-min-free-qnty
        or v-new-free-qnty          > v-max-free-qnty
        or v-new-output-qnty        < v-min-output-qnty
        or v-new-output-qnty        > v-max-output-qnty
        then do:
          output stream str-err to value(p-file-name-err) append .
          put stream str-err unformatted
            substitute("&1-После удаления документа свободное количество в приходной или расходной зоне&1выйдет за допустимые пределы.&1Приходный документ: &2.&1Код товара: &3.&1Код партии: &4.&1Артикул: &5 &6 &7.&1"
                      ,{&new-line}         /* 1 */
                      ,buf_parts.in-code   /* 2 */
                      ,v-gds-code          /* 3 */
                      ,buf_parts.part-code /* 4 */
                      ,p-artic             /* 5 */
                      ,p-prod-type         /* 6 */
                      ,p-prod-code         /* 7 */
                      ) .
          put stream str-err unformatted
            "Первоначальное количество в партии:                 " buf_parts-attr.fact-qnty skip
            "Свободное количество по партии в свободной зоне:    " v-new-free-qnty          skip
            "Свободное количество по партии в расходной зоне:    " v-new-output-qnty        skip
            "Минимально допустимое количество в свободной зоне:  " v-min-free-qnty          skip
            "Максимально допустимое количество в свободной зоне: " v-max-free-qnty          skip
            "Минимально допустимое количество в расходной зоне:  " v-min-output-qnty        skip
            "Максимально допустимое количество в расходной зоне: " v-max-output-qnty        skip
            .
          output stream str-err close.
          assign
            v-flag-err = yes
          .
        end.
    end.

    find first buf_temp-archive-parts
      where buf_temp-archive-parts.fact-order > p-fact-order
      no-error .
    if not available buf_temp-archive-parts
    then do:
      if ( v-new-total-free-qnty    < v-min-free-qnty
      or v-new-total-free-qnty    > v-max-free-qnty
      or v-new-total-output-qnty  < v-min-output-qnty
      or v-new-total-output-qnty  > v-max-output-qnty ) and
         ( p-ext-doc-type <> {&TDEDT_Vozvrat_Vnesh_Kass} and
           p-ext-doc-type <> {&TDEDT_Vozvrat_Vnesh})
      then do:
        output stream str-err to value(p-file-name-err) append .
        put stream str-err unformatted
          substitute("&1+После удаления документа общее количество в приходной или расходной зоне&1выйдет за допустимые пределы.&1Приходный документ: &2.&1Код товара: &3.&1Код партии: &4.&1Артикул: &5 &6 &7.&1"
                    ,{&new-line}         /* 1 */
                    ,buf_parts.in-code   /* 2 */
                    ,v-gds-code          /* 3 */
                    ,buf_parts.part-code /* 4 */
                    ,p-artic             /* 5 */
                    ,p-prod-type         /* 6 */
                    ,p-prod-code         /* 7 */
                    ) .
        put stream str-err unformatted
          "Первоначальное количество в партии:                 " buf_parts-attr.fact-qnty skip
          "Общее количество по партии в свободной зоне:        " v-new-total-free-qnty    skip
          "Общее количество по партии в расходной зоне:        " v-new-total-output-qnty  skip
          "Минимально допустимое количество в свободной зоне:  " v-min-free-qnty          skip
          "Максимально допустимое количество в свободной зоне: " v-max-free-qnty          skip
          "Минимально допустимое количество в расходной зоне:  " v-min-output-qnty        skip
          "Максимально допустимое количество в расходной зоне: " v-max-output-qnty        skip
          .
        output stream str-err close.
        assign
          v-flag-err = yes
          v-str-err = substitute("+После удаления документа общее количество 
          в приходной или расходной зоне выйдет за допустимые пределы.
          &1Приходный документ: &2.&1Код товара: &3.&1Код партии: &4.&1Артикул: &5 &6 &7.&1"
                    ,{&new-line}         /* 1 */
                    ,buf_parts.in-code   /* 2 */
                    ,v-gds-code          /* 3 */
                    ,buf_parts.part-code /* 4 */
                    ,p-artic             /* 5 */
                    ,p-prod-type         /* 6 */
                    ,p-prod-code         /* 7 */
                    )
        .
      end.
    end.


    for each buf_temp-archive-parts
      by buf_temp-archive-parts.fact-order descending
    on error undo, return error return-value
    :
      assign
        buf_temp-archive-parts.new-total-free-qnty = v-new-total-free-qnty
        buf_temp-archive-parts.new-total-out-qnty  = v-new-total-output-qnty
      .
      if buf_temp-archive-parts.fact-order > p-fact-order
      and ( v-new-total-free-qnty      < v-min-free-qnty
            or v-new-total-free-qnty   > v-max-free-qnty
            or v-new-total-output-qnty < v-min-output-qnty
            or v-new-total-output-qnty > v-max-output-qnty
          ) and
         ( p-ext-doc-type <> {&TDEDT_Vozvrat_Vnesh_Kass} and
           p-ext-doc-type <> {&TDEDT_Vozvrat_Vnesh})

      then do:
        assign
          buf_temp-archive-parts.error-flag = true
        .
        output stream str-err to value(p-file-name-err) append .
        put stream str-err unformatted
          substitute("&1=После удаления документа количество в свободной или расходной зоне&1на момент после закрытия документа &8&1выйдет за допустимые пределы.&1Приходный документ: &2.&1Код товара: &3.&1Код партии: &4.&1Артикул: &5 &6 &7 &1 &8.&1"
                    ,{&new-line}                     /* 1 */
                    ,buf_parts.in-code               /* 2 */
                    ,v-gds-code                      /* 3 */
                    ,buf_parts.part-code             /* 4 */
                    ,p-artic                         /* 5 */
                    ,p-prod-type                     /* 6 */
                    ,p-prod-code                     /* 7 */
                    ,buf_temp-archive-parts.doc-code /* 8 */
                    ) .


        put stream str-err unformatted
          "Первоначальное количество в партии:                 " buf_parts-attr.fact-qnty skip
          "Общее количество по партии в свободной зоне:        " v-new-total-free-qnty    skip
          "Общее количество по партии в расходной зоне:        " v-new-total-output-qnty  skip
          "Минимально допустимое количество в свободной зоне:  " v-min-free-qnty          skip
          "Максимально допустимое количество в свободной зоне: " v-max-free-qnty          skip
          "Минимально допустимое количество в расходной зоне:  " v-min-output-qnty        skip
          "Максимально допустимое количество в расходной зоне: " v-max-output-qnty        skip
          .
        output stream str-err close.
        assign
          v-flag-err = yes
          v-str-err  =  substitute("=После удаления документа количество в 
                     свободной или расходной зоне&1на момент после закрытия документа &8&1выйдет за допустимые пределы.&1Приходный документ: &2.&1Код товара: &3.&1Код партии: &4.&1Артикул: &5 &6 &7 &1 &8.&1"
                    ,{&new-line}                     /* 1 */
                    ,buf_parts.in-code               /* 2 */
                    ,v-gds-code                      /* 3 */
                    ,buf_parts.part-code             /* 4 */
                    ,p-artic                         /* 5 */
                    ,p-prod-type                     /* 6 */
                    ,p-prod-code                     /* 7 */
                    ,buf_temp-archive-parts.doc-code /* 8 */
                    ) 

        .
      end.

      { gbl/partparm.i
        buf_temp-archive-parts.parts-recid
        v-create-part
        v-old-return
        v-create-obj
      }
      { gbl/hold-doc.i
        buf_temp-archive-parts.doc-code
        v-is-hold
      }
      { gbl/partcond.i
        buf_temp-archive-parts.ext-doc-type
        v-is-hold
        buf_temp-archive-parts.fact-qnty
        v-create-part
        v-old-return
        v-rsrv-code
        v-unrv-code
        v-need-rsrv
        v-need-unrv
        v-rsrv-sign
        v-unrv-sign
      }

      if v-need-rsrv = true
      then do:
        case v-rsrv-code
        :
          when {&free-code}
          then do:
            assign
              v-new-free-qnty         = v-new-free-qnty
                                      + v-rsrv-sign * buf_temp-archive-parts.fact-qnty
              v-new-total-free-qnty   = v-new-total-free-qnty
                                      + v-rsrv-sign * buf_temp-archive-parts.fact-qnty
            .
          end.
          when {&output-code}
          then do:
            assign
              v-new-output-qnty       = v-new-output-qnty
                                      + v-rsrv-sign * buf_temp-archive-parts.fact-qnty
              v-new-total-output-qnty = v-new-total-output-qnty
                                      + v-rsrv-sign * buf_temp-archive-parts.fact-qnty
            .
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              "Внутренняя ошибка" skip
              "Неизвестное значение v-rsrv-code" v-rsrv-code skip
              view-as alert-box error .
            undo, return error "CRITICAL".
          end.
        end case .
      end.
      if v-need-unrv = true
      then do:
        case v-unrv-code
        :
          when {&free-code}
          then do:
            assign
              v-new-free-qnty         = v-new-free-qnty
                                      + v-unrv-sign * buf_temp-archive-parts.fact-qnty
              v-new-total-free-qnty   = v-new-total-free-qnty
                                      + v-unrv-sign * buf_temp-archive-parts.fact-qnty
            .
          end.
          when {&output-code}
          then do:
            assign
              v-new-output-qnty       = v-new-output-qnty
                                      + v-unrv-sign * buf_temp-archive-parts.fact-qnty
              v-new-total-output-qnty = v-new-total-output-qnty
                                      + v-unrv-sign * buf_temp-archive-parts.fact-qnty
            .
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              "Внутренняя ошибка" skip
              "Неизвестное значение v-unrv-code" v-unrv-code skip
              view-as alert-box error .
            undo, return error "CRITICAL".
          end.
        end case .
      end.
    end.

    if v-flag-err = true
    then do:
      output stream str-err to value(p-file-name-err) append .
      put stream str-err unformatted "История движения партии в случае удаления документа" + {&new-line}
        + "Документ       :Тип :     По документу :   Свободная зона :   Расходная зона"
        + {&new-line}
        .

      for each buf_temp-archive-parts
        by buf_temp-archive-parts.fact-order
      :
        put stream str-err unformatted
          substitute("&2 : &3 : &4 : &5 : &6 : &7&1"
                    ,{&new-line}
                    ,string(buf_temp-archive-parts.doc-code           , 'x(14)':u)
                    ,string(buf_temp-archive-parts.ext-doc-type       , 'x(2)':u)
                    ,string(buf_temp-archive-parts.fact-qnty          , '->>>,>>>,>>9.999':u )
                    ,string(buf_temp-archive-parts.new-total-free-qnty, '->>>,>>>,>>9.999':u )
                    ,string(buf_temp-archive-parts.new-total-out-qnty , '->>>,>>>,>>9.999':u )
                    ,string(buf_temp-archive-parts.error-flag, 'Количество вышло за допустимые пределы/')
                    )
          .

      end.
      output stream str-err close.
    end.
  end.

  if v-flag-err = yes
  then do:
    /* message "Невозможно удалить документ " {&new-line} v-str-err view-as alert-box information . */
    return .
  end.

end.