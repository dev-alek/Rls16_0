block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Резервирования товара по партиям

Автор: Чернова Светлана Александровна
Дата создания: 02/26/07
Author: Svetlana Chernova
Creation date: 02/26/07

create: Перваков Михаил Сергеевич
Дата создания: 04/11/06

Основное назначение процедуры
а)изменить doc-line, gds-dtl (возможно создать gds-dtl)
  с тем, чтобы они стали соответствовать партиям

  в случае, если менялось количество зарезервированное из свободной зоны
  и документ имеет определенный статус, то произвести изменение свободного количества
  по товару, признакам и изменить соответствующие значения в архивах.

  В случае невозможности резервирования всего указанного количества
  необходимо откатить все сделанные операции резервирование

б)в определенных случаях - ничего не делать

Основной вопрос - откуда берутся указанные количества,
на которые необходимо зарезервировать

Будет применен инкрементный механизм по партиям

  а. Запоминаются количества по партиям, зарезервированными за документом
     до операций с партиями (раздельно по партиям, зарезервированным
     из свободной зоны, и партиям, зарезервированными из расходной зоны)

  б. Считываются количество по партиям, зарезервированными за документом
     после операций с партиями (раздельно по партиям, зарезервированным
     из свободной зоны, и партиям, зарезервированными из расходной зоны)

  в. Производится коррекция doc-line
     и если существует корневой gds-dtl, то и gds-dtl

  г. Если существует корневой gds-dtl или на объекте не учитываются признаки
     и изменилось общее количество по признакам, то
     производится коррекция свободного количества gds-obj, архивов art-month,
     и для первого терминального признака
     производится коррекция свободного количества prt-obj и архивов invr-month.

     Если товар со шкалой и на объекте включены признаки, то
     изменение gds-dtl не производится. Процедура возвращает ошибку.

*/

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Резервирования товара по партиям":U .

{ cmp/trg-def.i  }
{ str/lib-trn.i  }
{ trg/partrqst.i }
{ trg/trndocrs.i }
{ str/lib-calc.i }

define input parameter parparentproc AS WIDGET-HANDLE NO-UNDO.
/* редактируемая строка документа */
define parameter buffer buf_doc-line        for ub.doc-line.
/* величина, на которую изменилось количество зарезервированное из свободной зоны */
define input parameter  v-chg-free-qnty as decimal no-undo .
/* величина, на которую изменилось количество зарезервированное из расходной зоны */
define input parameter  v-chg-out-qnty  as decimal no-undo .
/* величина, на которую изменилось количество по признакам */
/* зарезервированное из свободной зоны */
define input parameter table for temp-trndocrs-gds-dtl-rsrv .
/* величина, на которую изменилось количество по складским местам */
/* зарезервированное из свободной зоны */
define input parameter table for temp-trndocrs-pl-gds-rsrv .

{ cmp/vssrevis.i "substitute('&1|&2',v-chg-free-qnty,v-chg-out-qnty)" }

define variable v-root-node             like ub.gds-dtl.prt-code no-undo .
define variable l-cr-root-gds-dtl       as   logical             no-undo .
define variable l-need-update-inventory as   logical             no-undo .
define variable l-goods-twounit         as   logical             no-undo .

main-block:
do
on error undo main-block, return error
:

  /* проверка того, что не было передано "дробное" количество для резервирования */
  /* точность передаваемого количества должна быть не выше, чем точность
    количества в документах
  */
  define variable v-check-qnty like ub.doc-line.doc-qnty no-undo .

  assign
    v-check-qnty = v-chg-free-qnty
  .

  if v-check-qnty <> v-chg-free-qnty then do:
    message
      vss-workfile vss-revision vss-description skip
      "Запрошено резервирование дробного количества" skip
      "Запрошено резервирование v-chg-free-qnty" v-chg-free-qnty skip
      "После округления это составит" v-check-qnty skip
      view-as alert-box .
    undo, return error .
  end.

  assign
    v-check-qnty = v-chg-out-qnty
  .

  if v-check-qnty <> v-chg-out-qnty then do:
    message
      vss-workfile vss-revision vss-description skip
      "Запрошено резервирование дробного количества" skip
      "Запрошено резервирование v-chg-out-qnty" v-chg-out-qnty skip
      "После округления это составит" v-check-qnty skip
      view-as alert-box .
    undo, return error .
  end.

  find first ub.goods no-lock
    where ub.goods.artic     = buf_doc-line.artic
      and ub.goods.prod-type = buf_doc-line.prod-type
      and ub.goods.prod-code = buf_doc-line.prod-code
    .

  find first ub.trn-doc no-lock
    where ub.trn-doc.doc-code = buf_doc-line.doc-code
    .

  /* определяем корневой узел шкалы */
  { gbl/rootnode.i
    ub.goods.artic
    ub.goods.prod-type
    ub.goods.prod-code
    v-root-node
    no-error
  }
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении корневого признака шкалы" skip
      "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.

  { gbl/gdsobjat.i
    ub.trn-doc.obj-type
    ub.trn-doc.obj-code
    ub.goods.artic
    ub.goods.prod-type
    ub.goods.prod-code
    "'cr-root-gds-dtl=request':u"
    l-cr-root-gds-dtl
    no-error
  }
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении признака товара на объекте" skip
      "Объект" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
      "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
      "Запрашиваемый атрибут" 'cr-root-gds-dtl=request':u skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.

  /* запрос */
  if ub.trn-doc.status_ = {&inquiry} then do:
    if v-chg-free-qnty <> 0
    or v-chg-out-qnty <> 0
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Резервирование товара недопустимо для документов в статусе" {&inquiry} skip
        view-as alert-box error .
      undo, return error .
    end.
    else do:
      return .
    end.
  end.

  &scop partrqst-prefix v-total-parts-
  {&partrqst-var}

  run partrqst in this-procedure
    (input  buf_doc-line.doc-code
    ,input  buf_doc-line.obj-type
    ,input  buf_doc-line.obj-code
    ,input  buf_doc-line.artic
    ,input  buf_doc-line.prod-type
    ,input  buf_doc-line.prod-code
    &scop partrqst-prefix v-total-parts-
    {&partrqst-param}
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при выполнении процедуры partrqst" skip
      "buf_doc-line.doc-code"  buf_doc-line.doc-code  skip
      "buf_doc-line.obj-type"  buf_doc-line.obj-type  skip
      "buf_doc-line.obj-code"  buf_doc-line.obj-code  skip
      "buf_doc-line.artic"     buf_doc-line.artic     skip
      "buf_doc-line.prod-type" buf_doc-line.prod-type skip
      "buf_doc-line.prod-code" buf_doc-line.prod-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.

  assign
    l-need-update-inventory = (buf_doc-line.fact-qnty <> v-total-parts-fact-qnty)
  .

  if  (trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}
      or ub.trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
      )
  and (v-chg-free-qnty <> 0
       or v-chg-out-qnty <> 0
      )
  then do:
    message
      "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
      "Документ" ub.trn-doc.doc-code skip
      "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
      "Было запрошено изменение общего количества, зарезервированного по партиям." skip
      "Зарезервированное из свободной зоны должно измениться на" v-chg-free-qnty skip
      "Зарезервированное из расходной зоны должно измениться на " v-chg-out-qnty skip
      "Для документа продажи через кассу и документа возврата через кассу" skip
      "общее количество зарезервированного товара следует менять из документа продажи" skip
      view-as alert-box information .
    undo, return error .
  end.

  if not l-cr-root-gds-dtl
  and (v-chg-free-qnty <> 0
      or v-chg-out-qnty <> 0
      )
  then do:
    if  ub.trn-doc.doc-type = {&inventory}
    and l-need-update-inventory = false
    then do:
      /* в инвентаризации не производится резервирование свободного количества */
      /* по признакам, поэтому мы можем количество в свободной и расхоной зоне */
      /* без изменения общего колчества */

      /* todo - данный фрагмент необходимо передалать в случае реализации */
      /* честного резервирования по инвентаризации */
    end.
    else do:
      message
        "На объекте" buf_doc-line.obj-type buf_doc-line.obj-code "включены признаки" skip
        "Товар с артикулом" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        "имеет шкалу с признаками." skip
        "Было запрошено изменение общего количества, зарезервированного по партиям." skip
        "Зарезервированное из свободной зоны должно измениться на" v-chg-free-qnty skip
        "Зарезервированное из расходной зоны должно измениться на " v-chg-out-qnty skip
        "Общее количество зарезервированного товара необходимо изменять через редактирование шкалы." skip
        view-as alert-box information .
      undo, return error .
    end.
  end.

  if l-cr-root-gds-dtl then do:
    /* ищем/создаем корневой признак */
    { gbl/gdsdtlcr.i
      v-root-node
      buf_doc-line
      ub.gds-dtl
      no-error
    }
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ощибка при создании корневого признака" skip
        "Документ" buf_doc-line.doc-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box information .
      undo, return error .
    end.

    if not available ub.gds-dtl then do:
      message
        vss-workfile vss-revision vss-description skip
        "В документе отсутствует корневой признак" skip
        "Документ" buf_doc-line.doc-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box information .
      undo, return error .
    end.
  end.

  if l-cr-root-gds-dtl then do:

    { gbl/gdsat.i
      buf_doc-line.artic
      buf_doc-line.prod-type
      buf_doc-line.prod-code
      "'twounit=request':u"
      l-goods-twounit
      no-error
    }
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        'twounit=request':u skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    /* -------------------- ВНЕШНИЙ ПРИХОД ------------------------- */
    if  ub.trn-doc.doc-type = {&income}
    and ub.trn-doc.internal = no
    then do:

      if ub.trn-doc.flag_ = no then do:
        if buf_doc-line.cli-qnty <> v-total-parts-cli-qnty and
           abs( buf_doc-line.cli-qnty - v-total-parts-cli-qnty ) > 0.001
        then do:
          assign
            buf_doc-line.cli-qnty  = v-total-parts-cli-qnty
          .
        end.
        if l-goods-twounit = true then do:
          if buf_doc-line.cli-qnty <> 0 then do:
            assign
              buf_doc-line.cli-base-rate = buf_doc-line.doc-qnty / buf_doc-line.cli-qnty
            .
          end.
        end.
      end.
      assign
        buf_doc-line.doc-qnty  = v-total-parts-qnty
        buf_doc-line.fact-qnty = v-total-parts-fact-qnty
        ub.gds-dtl.doc-qnty   = buf_doc-line.doc-qnty
        ub.gds-dtl.fact-qnty  = buf_doc-line.fact-qnty
      .
      /*Проверка фактического количества в топливных товарах*/
      { str/lnfactqt.i
        parparentproc
        recid(buf_doc-line)
        no
        ub.trn-doc.status_
        ub.trn-doc.flag_
        no-error
      }
      if error-status:error then do:
        undo, return error substitute("Ошибка при изменении &1 фактического количества по товару: &2 &3 &4 ",
                                return-value,
                                buf_doc-line.artic,
                                buf_doc-line.prod-type,
                                buf_doc-line.prod-code).
      end.
    end.

    /* все остальные документы */
    /* кроме инвентаризации */
    if not ((trn-doc.doc-type = {&income} and internal = no)
            or (trn-doc.doc-type = {&inventory})
            )
    then do:
      if ub.trn-doc.status_ = {&permitted}
      or (trn-doc.doc-type = {&income} and internal = yes)
      then do:
        assign
          buf_doc-line.fact-qnty = v-total-parts-fact-qnty
          ub.gds-dtl.fact-qnty  = buf_doc-line.fact-qnty
        .
      end.
      else do:
        if ub.trn-doc.status_ <> {&cash-desk} then do:
          /* Для всех документов, кроме продажи */
          assign
            buf_doc-line.fact-qnty  = v-total-parts-fact-qnty
            ub.gds-dtl.fact-qnty   = buf_doc-line.fact-qnty
          .
        end.
        assign
          buf_doc-line.doc-qnty = v-total-parts-qnty
          ub.gds-dtl.doc-qnty      = buf_doc-line.doc-qnty
        .
        if l-goods-twounit = true then do:
          assign
            buf_doc-line.cli-qnty      = v-total-parts-cli-qnty
          .
          if buf_doc-line.cli-qnty <> 0 then do:
            assign
              buf_doc-line.cli-base-rate = buf_doc-line.doc-qnty / buf_doc-line.cli-qnty
            .
          end.
        end.
      end.
    end.

    /* документ инвентаризации */
    if ub.trn-doc.doc-type = {&inventory}
    and l-need-update-inventory
    then do:
      assign
        /* buf_doc-line.doc-qnty - меняем на такое же количество, что и buf_doc-line.fact-qnty */
        buf_doc-line.doc-qnty  = buf_doc-line.doc-qnty - buf_doc-line.fact-qnty + v-total-parts-fact-qnty
        buf_doc-line.fact-qnty = v-total-parts-fact-qnty
        ub.gds-dtl.doc-qnty       = buf_doc-line.fact-qnty
        ub.gds-dtl.fact-qnty      = buf_doc-line.doc-qnty
      .
      if l-goods-twounit = true then do:
        assign
          buf_doc-line.cli-qnty      = v-total-parts-cli-qnty
        .
        if buf_doc-line.cli-qnty <> 0 then do:
          assign
            buf_doc-line.cli-base-rate = buf_doc-line.fact-qnty / buf_doc-line.cli-qnty
          .
        end.
      end.
    end.
  end.

  /* записываем новую учетную цену и цену клиента в строку документа */

  /* для внешнего прихода записываем новую среднюю цену клиента */
  if  ub.trn-doc.doc-type = {&income}
  and ub.trn-doc.internal = no
  then do:
    if v-total-parts-cli-qnty <> 0 then do:
      assign
        buf_doc-line.price-cli = v-total-parts-price-cli / v-total-parts-cli-qnty
      .
    end.
  end.

  /* для всех документов записываем новую среднюю учетную цену */
  if v-total-parts-fact-qnty <> 0 then do:

    assign
      buf_doc-line.price-base     = v-total-parts-price-base     / v-total-parts-fact-qnty
      buf_doc-line.price-rubl     = v-total-parts-price-rubl     / v-total-parts-fact-qnty
      buf_doc-line.transport-base = v-total-parts-transport-base / v-total-parts-fact-qnty
      buf_doc-line.transport-rubl = v-total-parts-transport-rubl / v-total-parts-fact-qnty
      buf_doc-line.other-base     = v-total-parts-other-base     / v-total-parts-fact-qnty
      buf_doc-line.other-rubl     = v-total-parts-other-rubl     / v-total-parts-fact-qnty
    .

    /* новая учетная цена не записывается в признаки */
    /* она должна быть записана в интерефейсе редактирования документа */
  end.

  /* производим резервирование */
  if l-cr-root-gds-dtl then do:
    if can-do ({&expense_write-off},trn-doc.doc-type)
    and ub.goods.gds-type      = {&gds-goods}
    and ((trn-doc.status_   = {&wayb}
          and ub.trn-doc.flag_  = no
          )
          or ub.trn-doc.status_ = {&cash-desk}
        )
    then do:

      define variable v-new-free-qnty as decimal no-undo .
      define variable v-old-free-qnty as decimal no-undo .

      /* получаем предыдущее свободное количество товара на объекте */
      run trg/free-prt.p
        (input  buf_doc-line.obj-type  /* p-obj-type  */
        ,input  buf_doc-line.obj-code  /* p-obj-code  */
        ,input  buf_doc-line.artic     /* p-artic     */
        ,input  buf_doc-line.prod-type /* p-prod-type */
        ,input  buf_doc-line.prod-code /* p-prod-code */
        ,input  v-root-node        /* p-node-code */
        ,output v-old-free-qnty    /* p-free-qnty */
        ) .

      /* todo - разрешить менять общее количество по отдельным складским местам */
      /* в текущей версии я не позволяю менять общее количество  */
      define variable l-need-create-doc-pl as logical no-undo .

      run trndocrs-need-create-doc-pl
        (input  ub.trn-doc.ext-doc-type  /* p-extended-doc-type  */
        ,input  false                /* p-news               */
        ,input  no                  /* p-sale-auto - пока это место продажа не использует*/
        ,output l-need-create-doc-pl /* p-need-create-doc-pl */
        ) .

      if not l-need-create-doc-pl then do:
        /* триггер не отвечает за создание информации о складских местах */
        /* нельзя менять общее количество по складским местам */
        for each temp-trndocrs-pl-gds-rsrv
          where temp-trndocrs-pl-gds-rsrv.rsrv-qnty    <> 0
            or temp-trndocrs-pl-gds-rsrv.rsrv-out-qnty <> 0
        on error undo, return error
        :
          message
            "Товар учитывается по складским местам" skip
            "Было запрошено изменение количества, зарезервированного по складскому месту." skip
            "Общее количество необходимо изменять через редактирование документа." skip
            "Зарезервированное из свободной зоны должно измениться на" temp-trndocrs-pl-gds-rsrv.rsrv-qnty skip
            "Зарезервированное из расходной зоны должно измениться на" temp-trndocrs-pl-gds-rsrv.rsrv-out-qnty skip
            "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
            "Артикулом" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
            "Складское место" temp-trndocrs-pl-gds-rsrv.pl-code skip
            view-as alert-box information .
          undo, return error .
        end.
      end.

      /* todo - разрешить менять количество по признакам */
      /* в данный момент резервирование работает только для */
      /* товара без шкалы или объекта без учета признаков */
      run trndocrs-gds-dtl-clear in this-procedure  .
      run trndocrs-gds-dtl-accum in this-procedure
        (input ub.gds-dtl.prt-code
        ,input v-chg-free-qnty
        ) .

      run trndocrs in this-procedure
        (input buf_doc-line.doc-code
        ,input buf_doc-line.obj-type
        ,input buf_doc-line.obj-code
        ,input buf_doc-line.artic
        ,input buf_doc-line.prod-type
        ,input buf_doc-line.prod-code
        ,input v-chg-free-qnty
        ) .

      /* получаем текущее свободное количество товара на объекте */
      run trg/free-prt.p
        (input  buf_doc-line.obj-type  /* p-obj-type  */
        ,input  buf_doc-line.obj-code  /* p-obj-code  */
        ,input  buf_doc-line.artic     /* p-artic     */
        ,input  buf_doc-line.prod-type /* p-prod-type */
        ,input  buf_doc-line.prod-code /* p-prod-code */
        ,input  v-root-node        /* p-node-code */
        ,output v-new-free-qnty    /* p-free-qnty */
        ) .

      /* контроль свободного количества */
      if  ub.goods.negative-rest = false
      and v-new-free-qnty < 0 then do:
        message
          "Отрицательные остатки недопустимы" skip
          "Объект"  buf_doc-line.obj-type buf_doc-line.obj-code skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          "Было свободно" v-old-free-qnty  skip
          "Стало свободно" v-new-free-qnty skip
          view-as alert-box.
        undo, return error .
      end.
    end.

    run str/chk-prt.p
      (input recid(buf_doc-line)
      ,input false
      ,buffer ub.trn-doc
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при установке флага разнесения по строке" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
  end.

  { gbl/gdscheck.i
    buf_doc-line.obj-type
    buf_doc-line.obj-code
    buf_doc-line.artic
    buf_doc-line.prod-type
    buf_doc-line.prod-code
    v-root-node
    "''"
    no-error
  }
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке целостности товара" skip
      "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
      "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
      "Проверка целостности товара до резервирования" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box .
    undo, return error .
  end.
end.