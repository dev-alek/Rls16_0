block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обновление информации в партиях на основании doc-line

Автор: Чернова Светлана Александровна
Дата создания: 12/21/07
Author: Svetlana Chernova
Creation date: 12/21/07

Creation date: 04/05/06

p-update-doc-line   обновлять ли информацию в партиях

p-update-parts-info указывает какую дополнительную информацию
                    необходимо обновлять в партиях

*/
define input parameter parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter p-doc-code  like ub.doc-line.doc-code  no-undo .
define input parameter p-obj-type  like ub.doc-line.obj-type  no-undo .
define input parameter p-obj-code  like ub.doc-line.obj-code  no-undo .
define input parameter p-artic     like ub.doc-line.artic     no-undo .
define input parameter p-prod-type like ub.doc-line.prod-type no-undo .
define input parameter p-prod-code like ub.doc-line.prod-code no-undo .
define input parameter p-update-doc-line as logical no-undo .
define input parameter p-update-parts-info as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Обновление информации в партиях на основании doc-line".
{ cmp/vssrevis.i "substitute('&1|&2|&3',p-doc-code,p-update-doc-line,p-update-parts-info)" }
{ str/in-vatp.i def }
{ cmp/trg-def.i  }
{ trg/trndocrs.i }
{ cmp/strcodec.i }

define buffer buf_doc-line for ub.doc-line .
define buffer buf_trn-doc  for ub.trn-doc .

define variable v-goods-twounit                  as logical   no-undo .
define variable v-update-cst-code                as logical   no-undo .
define variable v-cst-code                       as character no-undo .
define variable v-update-last-date               as logical   no-undo .
define variable v-last-date                      as date      no-undo .
define variable v-update-contract-code           as logical   no-undo .
define variable v-contract-code                  as integer   no-undo .
define variable v-update-mark-code               as logical   no-undo .
define variable v-mark-db-num                    as integer   no-undo .
define variable v-mark-code                      as integer   no-undo .
define variable v-update-alc-bottling-date       as logical   no-undo .
define variable v-alc-bottling-date              as date      no-undo .
define variable v-update-alc-ref-ab-path         as logical   no-undo .
define variable v-alc-ref-ab-path                as character no-undo .
define variable v-update-alc-quality-certif-path as logical   no-undo .
define variable v-alc-quality-certif-path        as character no-undo .
define variable v-update-alc-certif-path         as logical   no-undo .
define variable v-alc-certif-path                as character no-undo .
define variable v-update-alc-imp-type            as logical   no-undo .
define variable v-alc-imp-type                   as character no-undo .
define variable v-update-alc-imp-code            as logical   no-undo .
define variable v-alc-imp-code                   as integer   no-undo .

define variable v-update-dop                     as logical   no-undo .
define variable v-dop                            as character   no-undo .


main-block:
do
on error undo main-block, return error
:
  run check-input-parameters in this-procedure
    (input p-update-parts-info
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Объект" p-obj-type p-obj-code skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      "p-update-parts-info" p-update-parts-info skip
      error-status :error skip
      return-value skip
      view-as alert-box .
    undo, return error .
  end.

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
      "Не найдена строка накладной" skip
      "Документ" p-doc-code skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      view-as alert-box error .
    undo, return error .
  end.

  find first buf_trn-doc no-lock
    where buf_trn-doc.doc-code = buf_doc-line.doc-code
    no-error .
  if not available buf_trn-doc
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найден складской документ" skip
      "Документ" buf_doc-line.doc-code skip
      view-as alert-box error .
    undo, return error .
  end.

  /* определяем тип товара - ювелирные изделия или нет */
  { gbl/gdsat.i
    buf_doc-line.artic
    buf_doc-line.prod-type
    buf_doc-line.prod-code
    "'twounit=request':u"
    v-goods-twounit
    no-error
  }
  if error-status :error
  then do:
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

  define variable v-same-price    as logical no-undo .

  /* определяем, какую информацию в партии прихода необходимо обновлять */
  run trg/doclnupd.p
    (input  buf_doc-line.doc-code
    ,input  buf_doc-line.obj-type
    ,input  buf_doc-line.obj-code
    ,input  buf_doc-line.artic
    ,input  buf_doc-line.prod-type
    ,input  buf_doc-line.prod-code
    ,output v-same-price
    ).

  if  v-goods-twounit   = true
  and p-update-doc-line = false
  then do:
    find ub.parts
      where ub.parts.obj-type  = buf_doc-line.obj-type
        and ub.parts.obj-code  = buf_doc-line.obj-code
        and ub.parts.artic     = buf_doc-line.artic
        and ub.parts.prod-type = buf_doc-line.prod-type
        and ub.parts.prod-code = buf_doc-line.prod-code
        and ub.parts.in-code   = buf_doc-line.doc-code
        and ub.parts.out-code  = buf_doc-line.doc-code
      no-error .
    if ambiguous ub.parts
    then do:
      message
        "Товар с двумя единицами измерения" skip
        "или в строке документа имеется более одной партии" skip
        /* "Воспользуйтесь интерфейсом партий для редактирования количества товара" skip */
        "Документ" buf_doc-line.doc-code skip
        "Товар" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box information .
      undo, return error .
    end.
  end.

  /* обновляем информацию в партиях на основании складского документа */
  for each ub.parts
    where ub.parts.out-code  = buf_doc-line.doc-code
      and ub.parts.obj-type  = buf_doc-line.obj-type
      and ub.parts.obj-code  = buf_doc-line.obj-code
      and ub.parts.artic     = buf_doc-line.artic
      and ub.parts.prod-type = buf_doc-line.prod-type
      and ub.parts.prod-code = buf_doc-line.prod-code
  on error undo, return error
  :

    { str/in-vatp.i calc buf_doc-line. buf_trn-doc. " " }

    if ub.parts.transport-base = ?
    then do:
      assign
        ub.parts.transport-base = 0
      .
    end.
    if ub.parts.other-base = ?
    then do:
      assign
        ub.parts.other-base = 0
      .
    end.
    if ub.parts.transport-rubl = ?
    then do:
      assign
        ub.parts.transport-rubl = 0
      .
    end.
    if ub.parts.other-rubl = ?
    then do:
      assign
        ub.parts.other-rubl = 0
      .
    end.

    /* Для того, чтобы программа могла вызываться несколько раз  */
    /* сначала вычитаем старые транспортные и другие расходы */
    assign
      ub.parts.price-base     = ub.parts.price-base
                              - ub.parts.transport-base
                              - ub.parts.other-base
      ub.parts.price-rubl     = ub.parts.price-rubl
                              - ub.parts.transport-rubl
                              - ub.parts.other-rubl
    .

    /* если у всех партий одна и та же учетная цена, */
    /* то копируем учетную цену (без учета транспортных расходов) из строки */
    if v-same-price
    then do:
      assign
        ub.parts.price-cli      = buf_doc-line.price-cli
        ub.parts.price-base     = buf_doc-line.price-base
                                - transport-base-loc
                                - other-base-loc
        ub.parts.price-rubl     = buf_doc-line.price-rubl
                                - transport-rubl-loc
                                - other-rubl-loc
      .

    end.

    /* копируем дорожный налог, траспортные и другие расходы из строки */
    assign
      ub.parts.road-tax-base  = road-tax-base-loc
      ub.parts.road-tax-rubl  = road-tax-rubl-loc
      ub.parts.transport-base = transport-base-loc
      ub.parts.transport-rubl = transport-rubl-loc
      ub.parts.other-base     = other-base-loc
      ub.parts.other-rubl     = other-rubl-loc
    .

    /* увеличиваем учетную цену на величину транспортных и других расходов */
    assign
      ub.parts.price-base     = ub.parts.price-base
                              + ub.parts.transport-base
                              + ub.parts.other-base
      ub.parts.price-rubl     = ub.parts.price-rubl
                              + ub.parts.transport-rubl
                              + ub.parts.other-rubl
    .
    assign
      ub.parts.pay-code      = buf_trn-doc.pay-code
      ub.parts.supp-code     = buf_trn-doc.cli-code
      ub.parts.supp-type     = buf_trn-doc.cli-type
      ub.parts.exch-code     = buf_trn-doc.exch-code
      ub.parts.VAT-type      = buf_trn-doc.vat-type
      ub.parts.VAT-pc        = buf_doc-line.vat-pc

      ub.parts.SLT-type      = buf_trn-doc.SLT-type
      ub.parts.SLt-pc        = buf_doc-line.SLT-pc
      ub.parts.host-code     = buf_trn-doc.host-code
    .

    if v-update-cst-code
    then do:
      assign
        ub.parts.cst-code = v-cst-code
      .
    end.
    else do:
      if trim(ub.parts.cst-code) = ""
      then do:
        assign
          ub.parts.cst-code = buf_trn-doc.cst-code
        .
      end.
    end.

    if v-update-last-date
    then do:
      assign
        ub.parts.last-date = v-last-date
      .
    end.

    if v-update-contract-code
    then do:
      assign
        ub.parts.contract-code = v-contract-code
      .
    end.

    if v-update-mark-code
    then do:
      assign
        ub.parts.mark-db-num = v-mark-db-num
        ub.parts.mark-code   = v-mark-code
      .
    end.

    if v-update-alc-bottling-date
    then do:
      assign
        ub.parts.alc-bottling-date = v-alc-bottling-date
      .
    end.

    if v-update-alc-ref-ab-path
    then do:
      assign
        ub.parts.alc-ref-ab-path = v-alc-ref-ab-path
      .
    end.

    if v-update-alc-quality-certif-path
    then do:
      assign
        ub.parts.alc-quality-certif-path = v-alc-quality-certif-path
      .
    end.

    if v-update-alc-certif-path
    then do:
      assign
        ub.parts.alc-certif-path = v-alc-certif-path
      .
    end.

    if v-update-alc-imp-type
    then do:
      assign
        ub.parts.alc-imp-type = v-alc-imp-type
      .
    end.

    if v-update-alc-imp-code
    then do:
      assign
        ub.parts.alc-imp-code = v-alc-imp-code
      .
    end.
    if v-update-dop
    then do:
      assign
        ub.parts.dop = v-dop
      .
    end.


    if v-goods-twounit = false
    then do:
      assign
        ub.parts.cli-base-rate = buf_doc-line.cli-base-rate
      .
      { gbl/qntycalc.i
        "'cli-qnty'"
        ub.parts.cli-base-rate
        ub.parts.cli-qnty
        ub.parts.qnty
        ub.parts.cli-qnty
        ub.parts.qnty
        no-error
      }
      if error-status :error
      then do:
        message
          "Невозможно пересчитать количество по ТТН" skip
          "Документ" ub.parts.out-code skip
          "Артикул" ub.parts.artic ub.parts.prod-type ub.parts.prod-code skip
          "Партия" + string(ub.parts.part-code) skip
          return-value skip
          view-as alert-box .
        undo, return error .
      end.
    end.
  end.


  if p-update-doc-line
  then do:
    find current buf_doc-line exclusive-lock .
    run trg/rsrv-gds.p
      (input parparentproc
      ,buffer buf_doc-line /* doc-line        */
      ,input  0            /* v-chg-free-qnty */
      ,input  0            /* v-chg-out-qnty  */
      ,input table temp-trndocrs-gds-dtl-rsrv
      ,input table temp-trndocrs-pl-gds-rsrv
      ) no-error .
    if error-status :error
    then do:
      message
        "Невозможно зарезервировать товар по признакам" skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        error-status :error skip
        return-value skip
        view-as alert-box .
      undo, return error .
    end.
  end.
end.


procedure check-input-parameters :
  define input parameter p-action as character no-undo .

  define variable ind                    as integer no-undo .
  define variable v-num-entries-p-action as integer no-undo .

  /* параметры создаваемой партии по умолчанию */
  assign
    v-update-cst-code                = false
    v-cst-code                       = ""
    v-update-last-date               = false
    v-last-date                      = ?
    v-update-contract-code           = false
    v-contract-code                  = 0
    v-update-mark-code               = false
    v-mark-db-num                    = 0
    v-mark-code                      = 0
    v-update-alc-bottling-date       = false
    v-alc-bottling-date              = ?
    v-update-alc-ref-ab-path         = false
    v-alc-ref-ab-path                = ""
    v-update-alc-quality-certif-path = false
    v-alc-quality-certif-path        = ""
    v-update-alc-certif-path         = false
    v-alc-certif-path                = ""
    v-update-alc-imp-type            = false
    v-alc-imp-type                   = ""
    v-update-alc-imp-code            = false
    v-alc-imp-code                   = 0
    v-dop                            = ""
  .

  assign
    v-num-entries-p-action = num-entries(p-action)
  .

  do ind = 1 to v-num-entries-p-action
  :
    define variable v-option       as character no-undo .
    define variable v-option-key   as character no-undo .
    define variable v-option-value as character no-undo .

    assign
      v-option = entry(ind, p-action)
    .
    if v-option = ""
    or v-option = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при задании параметров вызова резервирования" skip
        "В качестве параметров резервирования задана пустая или неопределенная опция" skip
        "v-option" v-option skip
        "p-action" p-action skip
        view-as alert-box error .
      undo, return error .
    end.

    assign
      v-option-key = entry(1, v-option, "=" )
    .

    case v-option-key :
      when {&rsrv-dtl_cst-code}
      then do:
        if num-entries(v-option, "=") <> 2
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при задании параметров вызова резервирования" skip
            "Для указания кода ГТД необходимо указать строку" skip
            "" {&rsrv-dtl_cst-code} + "=Код ГТД" skip
            "v-option" v-option skip
            "p-action" p-action skip
            view-as alert-box error .
          undo, return error .
        end.
        assign
          v-option-value = entry(2, v-option, "=" )
        .
        assign
          v-update-cst-code = true
          v-cst-code        = str-decode(v-option-value, "")
        .
      end.
      when {&rsrv-dtl_last-date}
      then do:
        if num-entries(v-option, "=") <> 2
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при задании параметров вызова резервирования" skip
            "Для указания списка типов приобретения необходимо указать строку" skip
            "" {&rsrv-dtl_last-date} + "=Дата срока годности до" skip
            "v-option" v-option skip
            "p-action" p-action skip
            view-as alert-box error .
          undo, return error .
        end.
        assign
          v-option-value = entry(2, v-option, "=" )
        .
        assign
          v-update-last-date = true
          v-last-date        = date(v-option-value)
        .
      end.
      when {&rsrv-dtl_contract-code}
      then do:
        if num-entries(v-option, "=") <> 2
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при задании параметров вызова резервирования" skip
            "Для указания кода ГТД необходимо указать строку" skip
            "" + {&rsrv-dtl_contract-code} + "=Код ГТД" skip
            "v-option" v-option skip
            "p-action" p-action skip
            view-as alert-box error .
          undo, return error .
        end.
        assign
          v-option-value = entry(2, v-option, "=" )
        .
        assign
          v-update-contract-code = true
          v-contract-code        = integer(v-option-value)
        .
      end.
      when {&rsrv-dtl_mark-db-num}
      then do:
        if num-entries(v-option, "=") <> 2
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при задании параметров вызова резервирования" skip
            "Для указания номера БД акцизной марки необходимо указать строку" skip
            "" + {&rsrv-dtl_mark-db-num} + "=Номер БД" skip
            "v-option" v-option skip
            "p-action" p-action skip
            view-as alert-box error .
          undo, return error .
        end.
        assign
          v-option-value = entry(2, v-option, "=" )
        .
        assign
          v-update-mark-code = true
          v-mark-db-num      = integer(v-option-value)
        .
      end.
      when {&rsrv-dtl_mark-code}
      then do:
        if num-entries(v-option, "=") <> 2
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при задании параметров вызова резервирования" skip
            "Для указания кода акцизной марки необходимо указать строку" skip
            "" + {&rsrv-dtl_mark-code} + "=Внутренний код марки" skip
            "v-option" v-option skip
            "p-action" p-action skip
            view-as alert-box error .
          undo, return error .
        end.
        assign
          v-option-value = entry(2, v-option, "=" )
        .
        assign
          v-update-mark-code = true
          v-mark-code        = integer(v-option-value)
        .
      end.
      when {&rsrv-dtl_alc-bottling-date}
      then do:
        if num-entries(v-option, "=") <> 2
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при задании параметров вызова резервирования" skip
            "Для указания даты разлива необходимо указать строку" skip
            "" + {&rsrv-dtl_alc-bottling-date} + "=Дата разлива" skip
            "v-option" v-option skip
            "p-action" p-action skip
            view-as alert-box error .
          undo, return error .
        end.
        assign
          v-option-value = entry(2, v-option, "=" )
        .
        assign
          v-update-alc-bottling-date = true
          v-alc-bottling-date        = date(v-option-value)
        .
      end.
      when {&rsrv-dtl_alc-ref-ab-path}
      then do:
        if num-entries(v-option, "=") <> 2
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при задании параметров вызова резервирования" skip
            "Для указания ссылки на справку А+Б необходимо указать строку" skip
            "" + {&rsrv-dtl_alc-ref-ab-path} + "=Файл справки А+Б" skip
            "v-option" v-option skip
            "p-action" p-action skip
            view-as alert-box error .
          undo, return error .
        end.
        assign
          v-option-value = entry(2, v-option, "=" )
        .
        assign
          v-update-alc-ref-ab-path = true
          v-alc-ref-ab-path        = str-decode(v-option-value, "")
        .
      end.
      when {&rsrv-dtl_alc-quality-certif-path}
      then do:
        if num-entries(v-option, "=") <> 2
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при задании параметров вызова резервирования" skip
            "Для указания ссылки на удостоверение качества необходимо указать строку" skip
            "" + {&rsrv-dtl_alc-quality-certif-path} + "=Файл удостоверения качества" skip
            "v-option" v-option skip
            "p-action" p-action skip
            view-as alert-box error .
          undo, return error .
        end.
        assign
          v-option-value = entry(2, v-option, "=" )
        .
        assign
          v-update-alc-quality-certif-path = true
          v-alc-quality-certif-path        = str-decode(v-option-value, "")
        .
      end.
      when {&rsrv-dtl_alc-certif-path}
      then do:
        if num-entries(v-option, "=") <> 2
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при задании параметров вызова резервирования" skip
            "Для указания ссылки на сертификат соответствия необходимо указать строку" skip
            "" + {&rsrv-dtl_alc-certif-path} + "=Файл сертификата соответствия" skip
            "v-option" v-option skip
            "p-action" p-action skip
            view-as alert-box error .
          undo, return error .
        end.
        assign
          v-option-value = entry(2, v-option, "=" )
        .
        assign
          v-update-alc-certif-path = true
          v-alc-certif-path        = str-decode(v-option-value, "")
        .
      end.
      when {&rsrv-dtl_alc-imp-type}
      then do:
        if num-entries(v-option, "=") <> 2
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при задании параметров вызова резервирования" skip
            "Для указания ссылки на сертификат соответствия необходимо указать строку" skip
            "" + {&rsrv-dtl_alc-imp-type} + "=Тип импортера" skip
            "v-option" v-option skip
            "p-action" p-action skip
            view-as alert-box error .
          undo, return error .
        end.
        assign
          v-option-value = entry(2, v-option, "=" )
        .
        assign
          v-update-alc-imp-type = true
          v-alc-imp-type        = str-decode(v-option-value, "")
        .
      end.
      when {&rsrv-dtl_alc-imp-code}
      then do:
        if num-entries(v-option, "=") <> 2
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при задании параметров вызова резервирования" skip
            "Для указания ссылки на сертификат соответствия необходимо указать строку" skip
            "" + {&rsrv-dtl_alc-imp-code} + "=Код импортера" skip
            "v-option" v-option skip
            "p-action" p-action skip
            view-as alert-box error .
          undo, return error .
        end.
        assign
          v-option-value = entry(2, v-option, "=" )
        .
        assign
          v-update-alc-imp-code = true
          v-alc-imp-code        = INTEGER(str-decode(v-option-value, ""))
        .
      end.

      when {&rsrv-dtl_dop} then do:
        if  v-option-value <> "" then do:
        assign
          v-update-dop = true
          v-dop        = str-decode(v-option-value, "")
        .
        end.

      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при задании параметров вызова резервирования" skip
          "Неизвестная опция." v-option skip
          "p-action" p-action skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
  end.
end.