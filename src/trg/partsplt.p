block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Разбиение партий в свободной зоне

Автор: Чернова Светлана Александровна
Дата создания: 09/24/07
Author: Svetlana Chernova
Creation date: 09/24/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/11/01

Используется для ювелирных изделий (товары с двумя ед.изм.)

*/

{ trg/partsplt.i }

define input parameter p-obj-type  like ub.parts.obj-type  no-undo .
define input parameter p-obj-code  like ub.parts.obj-code  no-undo .
define input parameter p-artic     like ub.parts.artic     no-undo .
define input parameter p-prod-type like ub.parts.prod-type no-undo .
define input parameter p-prod-code like ub.parts.prod-code no-undo .
define input parameter p-in-code   like ub.parts.in-code   no-undo .
define input parameter p-out-code  like ub.parts.out-code  no-undo .
define input parameter p-part-code like ub.parts.part-code no-undo .
define input parameter table for temp-parts-qnty .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Разбиение партий в свободной зоне".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }


define variable v-cmd-proc-handle as handle    no-undo .
define variable v-cmd-code1       as integer   no-undo .
define variable v-cur-db-num      as integer   no-undo .
define variable v-rec-ord         as integer   no-undo .
define variable v-spacial-doc     as logical   no-undo .

define temp-table temp-parts no-undo like ub.parts .

define buffer buf_goods      for ub.goods .
define buffer buf_bar-code   for ub.bar-code .
define buffer buf_trn-doc    for ub.trn-doc .
define buffer buf_temp-parts for temp-parts .
define buffer buf_parts-attr for ub.parts-attr .
define buffer new_parts-attr for ub.parts-attr .

do
on error undo, return error return-value
:

  assign
    v-spacial-doc = false
  .
  if p-out-code <> {&free-code}
  then do:
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-out-code
      no-error .
    if available buf_trn-doc
      and ( buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem}
            or buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Perem}
          )
    then do:
      assign
        v-spacial-doc = true
      .
    end.
    else do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Данная версия программы не может разделять партии" skip
        "зарезервированные за документами" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Партия" p-in-code p-part-code skip
        "Документ" p-out-code skip
        view-as alert-box error .
      undo, return error return-value . /* --->>>--- */
    end.
  end.

  find first ub.goods no-lock
    where ub.goods.artic     = p-artic
      and ub.goods.prod-type = p-prod-type
      and ub.goods.prod-code = p-prod-code
    no-error .
  if not available ub.goods
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден товар" skip
      "Объект" p-obj-type p-obj-code skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      "Партия" p-in-code p-part-code skip
      "Документ" p-out-code skip
      view-as alert-box error .
    undo, return error return-value . /* --->>>--- */
  end.

  define variable l-create-bar-code as logical no-undo .
  { gbl/gdsobjat.i
    p-obj-type
    p-obj-code
    p-artic
    p-prod-type
    p-prod-code
    "'create-bar-code=request'"
    l-create-bar-code
    no-error
  }
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении атрибута товара" skip
      "Объект" p-obj-type p-obj-code skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      "create-bar-code=request"
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  find first ub.units no-lock
    where ub.units.unit-name = ub.goods.unit-base
    .
  if lookup({&pieces}, ub.units.type) > 0
  then do:
    find first temp-parts-qnty
      where temp-parts-qnty.fact-qnty <> truncate(temp-parts-qnty.fact-qnty, 0)
      no-error .
    if available temp-parts-qnty
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Базовая единица измерения товара штучная" skip
        "Нельзя образовать партию товара с количеством" temp-parts-qnty.fact-qnty skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Партия" p-in-code p-part-code skip
        "Документ" p-out-code skip
        "Фактическое количество" temp-parts-qnty.fact-qnty skip
        "Количество по документу" temp-parts-qnty.qnty skip
        "Клиентское количество" temp-parts-qnty.cli-qnty skip
        view-as alert-box error .
      undo, return error return-value . /* --->>>--- */
    end.
  end.

  if lookup({&twounit}, ub.units.type) > 0
  then do:
    define buffer cli_units for ub.units .

    find first cli_units no-lock
      where cli_units.unit-name = ub.goods.unit-cli
      .
    if lookup({&pieces}, cli_units.type) > 0
    then do:
      find first temp-parts-qnty
        where temp-parts-qnty.cli-qnty <> 1
        no-error .
      if available temp-parts-qnty
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "При разбиении партий с двумя единицами измерения" skip
          "необходимо чтобы клиентское количество равнялось единице" skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "Партия" p-in-code p-part-code skip
          "Документ" p-out-code skip
          "Фактическое количество" temp-parts-qnty.fact-qnty skip
          "Количество по документу" temp-parts-qnty.qnty skip
          "Клиентское количество" temp-parts-qnty.cli-qnty skip
          view-as alert-box error .
        undo, return error return-value . /* --->>>--- */
      end.
    end.
  end.

  define variable v-total-qnty      like ub.parts.qnty      no-undo .
  define variable v-total-fact-qnty like ub.parts.fact-qnty no-undo .
  define variable v-total-cli-qnty  like ub.parts.cli-qnty  no-undo .

  for each temp-parts-qnty
  on error undo, return error return-value
  :
    if p-out-code = {&free-code}
    then do:
      if temp-parts-qnty.fact-qnty <> temp-parts-qnty.qnty
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Фактическое количество не равно количеству по документу" skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "Партия" p-in-code p-part-code skip
          "Документ" p-out-code skip
          "Фактическое количество" temp-parts-qnty.fact-qnty skip
          "Количество по документу" temp-parts-qnty.qnty skip
          "Клиентское количество" temp-parts-qnty.cli-qnty skip
          view-as alert-box error .
        undo, return error return-value . /* --->>>--- */
      end.
    end.

    assign
      v-total-qnty      = v-total-qnty      + temp-parts-qnty.qnty
      v-total-fact-qnty = v-total-fact-qnty + temp-parts-qnty.fact-qnty
      v-total-cli-qnty  = v-total-cli-qnty  + temp-parts-qnty.cli-qnty
    .
  end.

  find first ub.parts exclusive-lock
    where ub.parts.obj-type  = p-obj-type
      and ub.parts.obj-code  = p-obj-code
      and ub.parts.artic     = p-artic
      and ub.parts.prod-type = p-prod-type
      and ub.parts.prod-code = p-prod-code
      and ub.parts.in-code   = p-in-code
      and ub.parts.out-code  = p-out-code
      and ub.parts.part-code = p-part-code
    no-error .
  if not available ub.parts
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найдена партия для разбиения" skip
      "Объект" p-obj-type p-obj-code skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      "Партия" p-in-code p-part-code skip
      "Документ" p-out-code skip
      view-as alert-box error .
    undo, return error return-value . /* --->>>--- */
  end.

  /* блокируем товар на объекте */
  define buffer buf_gds-obj for ub.gds-obj .
  { gbl/gdsobjcr.i
    p-obj-type
    p-obj-code
    p-artic
    p-prod-type
    p-prod-code
    buf_gds-obj
  }

  find current buf_gds-obj exclusive-lock .

  { gbl/curdbnum.i
    v-cur-db-num
  }

  if v-cur-db-num <> 0
  then do:
    /* инициализируем библиотеку формирования команды */
    run nws/cmd-bush.p persistent set v-cmd-proc-handle
      no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute("Ошибка при запуске процедуры cmd-bush.p") skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      delete procedure v-cmd-proc-handle .
      undo, return error return-value .
    end.

    /* начало формирования команды */
    run begin-create-command in v-cmd-proc-handle
      (input  {&cmd-parts-split} /* p-command-name */
      ,input "":U                /* p-db-list      */
      ,output v-cmd-code1        /* p-command-code */
      ) no-error.
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при создании команды &1", {&cmd-transfer-goods} ) skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      delete procedure v-cmd-proc-handle .
      undo, return error return-value .
    end.

    run add-dump in v-cmd-proc-handle
      (input v-cmd-code1                  /* p-command-code */
      ,input {&table_gds-obj}             /* p-dump-name    */
      ,input '+update':U
      ,input (buffer buf_gds-obj :handle) /* p-tbl-handle   */
      ,input '':U
      ,output v-rec-ord
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при добавлении записи &1 в команду с кодом &2", {&table_gds-obj}, v-cmd-code1 ) skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      delete procedure v-cmd-proc-handle .
      undo, return error return-value .
    end.
  end.


  /* Проверяем целостность товара до разбиения */
  { gbl/gdscheck.i
    p-obj-type
    p-obj-code
    p-artic
    p-prod-type
    p-prod-code
    ?
    "''"
    no-error
  }
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка проверки целостности товара до операции разбиения" skip
      "Объект" p-obj-type p-obj-code skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      "Партия" p-in-code p-part-code skip
      "Документ" p-out-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value . /* --->>>--- */
  end.

  if v-total-qnty      > ub.parts.qnty
  or v-total-fact-qnty > ub.parts.fact-qnty
  or v-total-cli-qnty  > ub.parts.cli-qnty
  or v-total-qnty      = ?
  or v-total-fact-qnty = ?
  or v-total-cli-qnty  = ?
  or v-total-qnty      < 0
  or v-total-fact-qnty < 0
  or v-total-cli-qnty  < 0
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Общее количество по разбиению не соответствует количеству в партии" skip
      "Объект" p-obj-type p-obj-code skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      "Партия" p-in-code p-part-code skip
      "Документ" p-out-code skip
      "v-total-qnty"       v-total-qnty       skip
      "v-total-fact-qnty"  v-total-fact-qnty  skip
      "v-total-cli-qnty "  v-total-cli-qnty   skip
      "ub.parts.qnty"      ub.parts.qnty      skip
      "ub.parts.fact-qnty" ub.parts.fact-qnty skip
      "ub.parts.cli-qnty"  ub.parts.cli-qnty  skip
      view-as alert-box error .
    undo, return error return-value . /* --->>>--- */
  end.

  define buffer buf_parts for ub.parts .

  define variable v-ind as integer no-undo .
  define variable v-new-part-code like ub.parts.part-code no-undo .
  define variable v-part-code-format as character no-undo .

  /* todo - необходимо создавать уникальный номер разбиения партий */
  /* todo 1 - дробить можно только на том же самом объекте */
  /* todo 2 - передавать можно только раздробленную партию */
  /* todo 3 - определять ind последнего дробления */
  /* todo 4 - если обнаруживается партия с таким же номером, то номер пропускается */
  /* todo 5 - необходимо ограничить в приходном интерфейсе заведение кода партии */
  /*          он должен быть меньше или равен 10 символов */

  assign
    v-new-part-code = substring(parts.part-code, 1, 10) + {&part-split}
  .

  define variable v-ind-part-code as integer no-undo .
  for each buf_parts no-lock
    where buf_parts.obj-type  = p-obj-type
      and buf_parts.obj-code  = p-obj-code
      and buf_parts.artic     = p-artic
      and buf_parts.prod-type = p-prod-type
      and buf_parts.prod-code = p-prod-code
      and buf_parts.in-code   = p-in-code
  on error undo, return error return-value
  :
    if substring(buf_parts.part-code, 1, length(v-new-part-code)) = v-new-part-code
    then do:
      assign
        v-ind-part-code
          = integer(substring(buf_parts.part-code, length(v-new-part-code) + 1 ) )
        no-error
      .
      if error-status :error = false
      then do:
        if v-ind-part-code > v-ind
        then do:
          assign
            v-ind = v-ind-part-code
          .
        end.
      end.
    end.
  end.

  define variable v-gds-code as integer   no-undo .

  { gbl/gds-code.i
    p-artic
    p-prod-type
    p-prod-code
    v-gds-code
  }

  for each buf_parts-attr no-lock
    where buf_parts-attr.in-code   = p-in-code
      and buf_parts-attr.gds-code  = v-gds-code
  on error undo, return error return-value
  :
    if substring(buf_parts-attr.part-code, 1, length(v-new-part-code)) = v-new-part-code
    then do:
      assign
        v-ind-part-code
          = integer(substring(buf_parts-attr.part-code, length(v-new-part-code) + 1 ) )
        no-error
      .
      if error-status :error = false
      then do:
        if v-ind-part-code > v-ind
        then do:
          assign
            v-ind = v-ind-part-code
          .
        end.
      end.
    end.
  end.

  run gbl/fldfrmt.p
    (input  "parts"
    ,input  "part-code"
    ,output v-part-code-format
    ) .

  for each temp-parts-qnty
  on error undo, return error return-value
  :
    assign
      v-ind = v-ind + 1
    .

    find first buf_parts-attr no-lock
      where buf_parts-attr.in-code   = ub.parts.in-code
        and buf_parts-attr.gds-code  = v-gds-code
        and buf_parts-attr.part-code = ub.parts.part-code
      no-error .
    if not available buf_parts-attr
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден атрибут партии" skip
        "Невозможно произвести разбиение партии" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Партия" p-in-code p-part-code skip
        "Документ" p-out-code skip
        view-as alert-box error .
      undo, return error return-value . /* --->>>--- */
    end.

    define variable v-cli-base-rate as decimal   no-undo .

    if v-spacial-doc = true then do:
      assign
        v-cli-base-rate = ub.parts.cli-base-rate
      .
    end.
    else do:
      assign
        v-cli-base-rate = temp-parts-qnty.fact-qnty / temp-parts-qnty.cli-qnty
      .
    end.

    if v-cli-base-rate = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении v-cli-base-rate" skip
        "Невозможно произвести разбиение партии" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Партия" p-in-code p-part-code skip
        "Документ" p-out-code skip
        "Фактическое количество" temp-parts-qnty.fact-qnty skip
        "Количество поставщика" temp-parts-qnty.cli-qnty skip
        view-as alert-box error .
      undo, return error return-value . /* --->>>--- */
    end.
    create buf_parts .
    buffer-copy ub.parts to buf_parts
    assign
      buf_parts.part-code     = string(v-new-part-code + string(v-ind), v-part-code-format)
      buf_parts.out-code      = ub.parts.out-code
      buf_parts.status_       = ub.parts.status_
      buf_parts.doc-type      = ub.parts.doc-type
      buf_parts.rsrv-free     = ub.parts.rsrv-free
      buf_parts.qnty          = temp-parts-qnty.qnty
      buf_parts.fact-qnty     = temp-parts-qnty.fact-qnty
      buf_parts.cli-qnty      = temp-parts-qnty.cli-qnty
      buf_parts.cli-base-rate = v-cli-base-rate
    .
    if temp-parts-qnty.pl-code <> ?
      and temp-parts-qnty.pl-code <> 0
    then do:
      assign
        buf_parts.pl-code = temp-parts-qnty.pl-code
      .
    end.

    validate buf_parts .

    if v-cur-db-num <> 0
      and v-spacial-doc <> true
    then do:
      run add-dump in v-cmd-proc-handle
        (input v-cmd-code1                /* p-command-code */
        ,input {&table_parts}             /* p-dump-name    */
        ,input '+update':U
        ,input (buffer buf_parts :handle) /* p-tbl-handle   */
        ,input '':U
        ,output v-rec-ord
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          substitute( "Ошибка при добавлении записи &1 в команду с кодом &2", {&table_parts}, v-cmd-code1 ) skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        delete procedure v-cmd-proc-handle .
        undo, return error return-value .
      end.
    end.

    create new_parts-attr .
    buffer-copy buf_parts-attr to new_parts-attr
    assign
      new_parts-attr.in-code        = buf_parts.in-code
      new_parts-attr.gds-code       = v-gds-code
      new_parts-attr.part-code      = buf_parts.part-code
      new_parts-attr.orig-in-code   = buf_parts-attr.in-code
      new_parts-attr.orig-gds-code  = buf_parts-attr.gds-code
      new_parts-attr.orig-part-code = buf_parts-attr.part-code
    .
    validate new_parts-attr .


    if l-create-bar-code
    then do:
      define variable v-bar-code-is-new as logical no-undo .

      define variable v-root-node like ub.gds-prt.node-code no-undo .

      /* определяем корневой признак товара */
      { gbl/rootnode.i
        p-artic
        p-prod-type
        p-prod-code
        v-root-node
      }

      find first buf_goods no-lock
        where buf_goods.artic     = p-artic
          and buf_goods.prod-type = p-prod-type
          and buf_goods.prod-code = p-prod-code
        .

      /* бар-код необходимо создать */
      /* проверяем, что разрешена генерация бар-кодов */
      { gbl/barcodcr.i
        buf_goods.gds-code
        v-root-node
        buf_parts.part-code
        buf_parts.in-code
        buf_goods.unit-base
        ?
        v-bar-code-is-new
        buf_bar-code
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при создании бар-кода партии" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.

  create buf_temp-parts .
  buffer-copy ub.parts to buf_temp-parts
  assign
    buf_temp-parts.qnty      = - v-total-qnty
    buf_temp-parts.fact-qnty = - v-total-fact-qnty
    buf_temp-parts.cli-qnty  = - v-total-cli-qnty
  .

  if v-cur-db-num <> 0
    and v-spacial-doc <> true
  then do:
    run add-dump in v-cmd-proc-handle
      (input v-cmd-code1                     /* p-command-code */
      ,input {&table_parts}                  /* p-dump-name    */
      ,input '+update':U
      ,input (buffer buf_temp-parts :handle) /* p-tbl-handle   */
      ,input '':U
      ,output v-rec-ord
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при добавлении записи &1 в команду с кодом &2", {&table_parts}, v-cmd-code1 ) skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      delete procedure v-cmd-proc-handle .
      undo, return error return-value .
    end.
  end.

  /* уменьшаем количество товара в исходной партии */
  assign
    ub.parts.qnty      = ub.parts.qnty      - v-total-qnty
    ub.parts.fact-qnty = ub.parts.fact-qnty - v-total-fact-qnty
    ub.parts.cli-qnty  = ub.parts.cli-qnty  - v-total-cli-qnty
  .

  if  ub.parts.qnty      = 0
  and ub.parts.fact-qnty = 0
  and ub.parts.cli-qnty  = 0
  then do:
    /* удаляем исходную партию */
    delete ub.parts .
  end.
  else do:
    if ub.parts.qnty      = 0
    or ub.parts.fact-qnty = 0
    or ub.parts.cli-qnty  = 0
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "После разбиения или все количества в партии должны равняться нулю" skip
        "или все количества должны быть отличны от нуля" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Партия" p-in-code p-part-code skip
        "Документ" p-out-code skip
        "ub.parts.qnty"      ub.parts.qnty      skip
        "ub.parts.fact-qnty" ub.parts.fact-qnty skip
        "ub.parts.cli-qnty"  ub.parts.cli-qnty  skip
        view-as alert-box error .
      undo, return error return-value . /* --->>>--- */
    end.
  end.

  if v-cur-db-num <> 0
    and v-spacial-doc <> true
  then do:
    /* завершить формирование команды и отправить информацию по новостям */
    run send-command in v-cmd-proc-handle
      ( input v-cmd-code1 /* p-command-code */
      ,input "0"          /* p-db-list      */
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при отправке в новости команды с кодом &1", v-cmd-code1 ) skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      delete procedure v-cmd-proc-handle .
      undo, return error return-value .
    end.

    delete procedure v-cmd-proc-handle .
  end.


  { gbl/gdscheck.i
    p-obj-type
    p-obj-code
    p-artic
    p-prod-type
    p-prod-code
    ?
    "''"
    no-error
  }
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка проверки целостности товара после операции разбиения" skip
      "Объект" p-obj-type p-obj-code skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      "Партия" p-in-code p-part-code skip
      "Документ" p-out-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value . /* --->>>--- */
  end.
end.