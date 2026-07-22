/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Копирование партий для документов межфирменного перемещени

Автор: Чернова Светлана Александровна
Дата создания: 02/14/07
Author: Svetlana Chernova
Creation date: 02/14/07

create: Перваков Михаил Сергеевич
Дата создания: 09/06/02

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure holdprts-create-parts-supp :

  define input  parameter p-orig-in-code   like ub.parts-supp.orig-in-code   no-undo .
  define input  parameter p-orig-part-code like ub.parts-supp.orig-part-code no-undo .
  define input  parameter p-in-code        like ub.parts-supp.in-code        no-undo .
  define input  parameter p-artic          like ub.parts-supp.artic          no-undo .
  define input  parameter p-prod-type      like ub.parts-supp.prod-type      no-undo .
  define input  parameter p-prod-code      like ub.parts-supp.prod-code      no-undo .
  define input  parameter p-part-code      like ub.parts-supp.part-code      no-undo .

  define variable vss-description as character no-undo init "holdprts-create-parts-supp-01: скопировать атрибут партии".

  define buffer buf_parent_trn-doc  for ub.trn-doc .
  define buffer buf_child_trn-doc   for ub.trn-doc .
  define buffer buf_parts           for ub.parts .
  define buffer buf_parts-supp      for ub.parts-supp .
  define buffer buf_orig_parts-supp for ub.parts-supp .
  define buffer buf_income_trn-doc  for ub.trn-doc .
  define buffer buf_income_doc-line for ub.doc-line .
  define buffer buf_goods           for ub.goods .

  { str/in-vatp.i def }

  do
  on error undo, return error return-value
  :
    find first buf_child_trn-doc no-lock
      where buf_child_trn-doc.doc-code = p-in-code
      no-error .
    if not available buf_child_trn-doc
    then do:
      return substitute("Не найден исходный документ &1", p-in-code) .
    end.

    find first buf_parent_trn-doc no-lock
      where buf_parent_trn-doc.doc-code = buf_child_trn-doc.hold-doc-code-parent
      no-error .
    if not available buf_parent_trn-doc
    then do:
      return substitute("Не найден приходный документ &1", buf_child_trn-doc.hold-doc-code-parent) .
    end.

    /* ищем атрибут партии, если он есть, то ничего копировать не надо */
    find first buf_parts-supp exclusive-lock
      where buf_parts-supp.in-code   = p-in-code
        and buf_parts-supp.artic     = p-artic
        and buf_parts-supp.prod-type = p-prod-type
        and buf_parts-supp.prod-code = p-prod-code
        and buf_parts-supp.part-code = p-part-code
      no-error .
    if available buf_parts-supp
    then do:
      /* такая запись уже есть */
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info{&vssseq} skip
        "Попытка повторного создания партии атрибутов" skip
        "Документ прихода" p-in-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Код партии" p-part-code skip
        "Исходный код партии" p-orig-in-code skip
        "Исходный код документа" p-orig-part-code skip
        view-as alert-box error .
      undo, return error .
    end.

    create buf_parts-supp .
    assign
      buf_parts-supp.in-code   = p-in-code
      buf_parts-supp.artic     = p-artic
      buf_parts-supp.prod-type = p-prod-type
      buf_parts-supp.prod-code = p-prod-code
      buf_parts-supp.part-code = p-part-code
    .
    assign
      buf_parts-supp.orig-in-code   = p-orig-in-code
      buf_parts-supp.orig-part-code = p-orig-part-code
    .

    find first buf_orig_parts-supp share-lock
      where buf_orig_parts-supp.in-code   = p-orig-in-code
        and buf_orig_parts-supp.artic     = p-artic
        and buf_orig_parts-supp.prod-type = p-prod-type
        and buf_orig_parts-supp.prod-code = p-prod-code
        and buf_orig_parts-supp.part-code = p-orig-part-code
      no-error .
    if available buf_orig_parts-supp
    then do:
      /* у исходной партии заданы атрибуты */
      /* именно их требуется скопировать   */
      buffer-copy buf_orig_parts-supp
      except
        buf_orig_parts-supp.in-code
        buf_orig_parts-supp.artic
        buf_orig_parts-supp.prod-type
        buf_orig_parts-supp.prod-code
        buf_orig_parts-supp.part-code
        buf_orig_parts-supp.orig-in-code
        buf_orig_parts-supp.orig-part-code
      to buf_parts-supp.
    end.
    else do:
      find first buf_parts share-lock
        where buf_parts.obj-type  = buf_parent_trn-doc.obj-type
          and buf_parts.obj-code  = buf_parent_trn-doc.obj-code
          and buf_parts.artic     = p-artic
          and buf_parts.prod-type = p-prod-type
          and buf_parts.prod-code = p-prod-code
          and buf_parts.in-code   = p-orig-in-code
          and buf_parts.out-code  = buf_parent_trn-doc.doc-code
          and buf_parts.part-code = p-orig-part-code
        no-error .
      if not available buf_parts
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info{&vssseq} skip
          "Ошибка задания входных параметров" skip
          "Не найдена исходная партия" skip
          "Исходный документ" p-orig-in-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "Код партии" p-orig-part-code skip
          view-as alert-box error .
        undo, return error .
      end.

      define variable v-base-rate         as decimal   no-undo .
      define variable v-base-scale        as integer   no-undo .
      define variable v-exch-rate         as decimal   no-undo .
      define variable v-exch-scale        as integer   no-undo .
      define variable v-extended-doc-type as character no-undo .
      define variable v-unit-cli          as character no-undo .

      find first buf_income_trn-doc no-lock
        where buf_income_trn-doc.doc-code = p-orig-in-code
        no-error .
      if available buf_income_trn-doc
      then do:
        find first buf_income_doc-line no-lock
          where buf_income_doc-line.doc-code  = p-orig-in-code
            and buf_income_doc-line.artic     = p-artic
            and buf_income_doc-line.prod-type = p-prod-type
            and buf_income_doc-line.prod-code = p-prod-code
          no-error .
        if not available buf_income_doc-line
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info{&vssseq} skip
            "Не найдена исходная строка документа прихода" skip
            "Исходный документ" p-orig-in-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            "Код партии" p-orig-part-code skip
            view-as alert-box error .
          undo, return error .
        end.

        assign
          v-base-rate         = buf_income_trn-doc.base-rate
          v-base-scale        = buf_income_trn-doc.base-scale
          v-exch-rate         = buf_income_trn-doc.exch-rate
          v-exch-scale        = buf_income_trn-doc.exch-scale
          v-extended-doc-type = buf_income_trn-doc.ext-doc-type
          v-unit-cli          = buf_income_doc-line.unit-cli
        .
      end.
      else do:
        find first buf_goods no-lock
          where buf_goods.artic     = buf_parts.artic
            and buf_goods.prod-type = buf_parts.prod-type
            and buf_goods.prod-code = buf_parts.prod-code
          .
        assign
          v-base-rate         = buf_parts.price-rubl / buf_parts.price-base
          v-base-scale        = 1
          v-exch-rate         = buf_parts.price-rubl / (buf_parts.price-cli * buf_parts.cli-base-rate)
          v-exch-scale        = 1
          v-extended-doc-type = {&TDEDT_Pri_Vnesh}
          v-unit-cli          = buf_goods.unit-cli
        .
      end.
       if v-base-rate = ? then v-base-rate = 1.
       if v-exch-rate = ? then v-exch-rate = 1.
      { str/in-vatp.i calc-parts buf_parts. " " loc }

      assign
        buf_parts-supp.PS                = buf_parts.PS
        buf_parts-supp.SLT-type          = buf_parts.SLT-type
        buf_parts-supp.VAT-type          = buf_parts.VAT-type
        buf_parts-supp.base-rate         = v-base-rate
        buf_parts-supp.base-scale        = v-base-scale
        buf_parts-supp.cli-qnty          = buf_parts.cli-qnty
        buf_parts-supp.cst-code          = buf_parts.cst-code
        buf_parts-supp.doc-qnty          = buf_parts.qnty
        buf_parts-supp.exch-code         = buf_parts.exch-code
        buf_parts-supp.exch-rate         = v-exch-rate
        buf_parts-supp.exch-scale        = v-exch-scale
        buf_parts-supp.extended-doc-type = v-extended-doc-type
        buf_parts-supp.fact-date         = buf_parts.fact-date
        buf_parts-supp.fact-qnty         = buf_parts.fact-qnty
        buf_parts-supp.last-date         = buf_parts.last-date
        buf_parts-supp.pay-code          = buf_parts.pay-code
        buf_parts-supp.price-cli         = buf_parts.price-cli
        buf_parts-supp.purch-code        = buf_parts.purch-code
        buf_parts-supp.supp-code         = buf_parts.supp-code
        buf_parts-supp.supp-type         = buf_parts.supp-type
        buf_parts-supp.unit-cli          = v-unit-cli
      .

      assign
        buf_parts-supp.vat-pc         = vat-pc-loc
        buf_parts-supp.slt-pc         = slt-pc-loc
        buf_parts-supp.price-base     = price-base-with-tax-loc
        buf_parts-supp.price-rubl     = price-rubl-with-tax-loc
        buf_parts-supp.vat-base       = vat-base-loc
        buf_parts-supp.vat-rubl       = vat-rubl-loc
        buf_parts-supp.slt-base       = slt-base-loc
        buf_parts-supp.slt-rubl       = slt-rubl-loc
        buf_parts-supp.road-tax-base  = road-tax-base-loc
        buf_parts-supp.road-tax-rubl  = road-tax-rubl-loc
        buf_parts-supp.transport-base = transport-base-loc
        buf_parts-supp.transport-rubl = transport-rubl-loc
        buf_parts-supp.other-base     = other-base-loc
        buf_parts-supp.other-rubl     = other-rubl-loc
      .
    end.
  end.

end procedure. /* copy-parts */


procedure holdprts-get-part-code :

  define input  parameter p-doc-code       as character no-undo .
  define output parameter p-hold-part-code as integer   no-undo .

  define variable vss-description as character no-undo init "holdprts-get-part-code-01: создать уникальный код партии внутри документа".

  define variable v-attr-value as character no-undo .
  define variable v-attr-type  as character no-undo .

  define buffer buf_trn-doc for ub.trn-doc .

  do
  on error undo, return error return-value
  :
    find first buf_trn-doc exclusive-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info{&vssseq} skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" p-doc-code skip
        view-as alert-box error .
      undo, return error .
    end.

    { str/tdat-val.i
        p-doc-code
        {&trdcattr-hold-part-code}
        v-attr-value
        v-attr-type
    }
    assign
      p-hold-part-code = integer(v-attr-value) + 1
    .
    { str/tdat-wrt.i
        p-doc-code
        {&trdcattr-hold-part-code}
        string(p-hold-part-code)
    }

  end.

end procedure. /* holdprts-get-part-code */


procedure holdprts-validate-document :

  define input  parameter p-doc-code as character no-undo .

  define variable vss-description as character no-undo init "holdprts-validate-document-01: проверить правильность документа".

  define buffer buf_trn-doc    for ub.trn-doc .
  define buffer parent_trn-doc for ub.trn-doc .
  define buffer buf_parts      for ub.parts .
  define buffer buf_parts-supp for ub.parts-supp .

  do
  on error undo, return error return-value
  :
    find first buf_trn-doc exclusive-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info{&vssseq} skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" p-doc-code skip
        view-as alert-box error .
      undo, return error .
    end.

    find first parent_trn-doc exclusive-lock
      where parent_trn-doc.doc-code = buf_trn-doc.hold-doc-code-parent
      no-error .
    if not available parent_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info{&vssseq} skip
        "Не найден родительский документ" skip
        "Документ" buf_trn-doc.doc-code skip
        "Родительский документ" buf_trn-doc.hold-doc-code-parent skip
        view-as alert-box error .
      undo, return error .
    end.

    if buf_trn-doc.ext-doc-type <> {&TDEDT_Pri_Vnesh}
    then do:
      /* проверяем правильность только для внешнего прихода */

      /* todo - сделать для возврата другую проверку */
      return .
    end.

    for each buf_parts share-lock
      where buf_parts.out-code = buf_trn-doc.doc-code
    on error undo, return error
    :
      find first buf_parts-supp share-lock
        where buf_parts-supp.in-code   = buf_parts.in-code
          and buf_parts-supp.artic     = buf_parts.artic
          and buf_parts-supp.prod-type = buf_parts.prod-type
          and buf_parts-supp.prod-code = buf_parts.prod-code
          and buf_parts-supp.part-code = buf_parts.part-code
        no-error .
      if not available buf_parts-supp
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info{&vssseq} skip
          "Не найдена информация о поставщике" skip
          "Документ" buf_trn-doc.doc-code skip
          "Родительский документ" buf_trn-doc.hold-doc-code-parent skip
          "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
          "Номер партии" buf_parts.part-code skip
          view-as alert-box error .
        undo, return error .
      end.
    end.

    for each buf_parts-supp share-lock
      where buf_parts-supp.in-code = buf_trn-doc.doc-code
    on error undo, return error
    :
      find first buf_parts share-lock
        where buf_parts.out-code  = buf_parts-supp.in-code
          and buf_parts.obj-type  = buf_trn-doc.obj-type
          and buf_parts.obj-code  = buf_trn-doc.obj-code
          and buf_parts.artic     = buf_parts-supp.artic
          and buf_parts.prod-type = buf_parts-supp.prod-type
          and buf_parts.prod-code = buf_parts-supp.prod-code
          and buf_parts.part-code = buf_parts-supp.part-code
        no-error .
      if not available buf_parts
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info{&vssseq} skip
          "Задана информация о поставщике для неизвестной партии" skip
          "Документ" buf_trn-doc.doc-code skip
          "Родительский документ" buf_trn-doc.hold-doc-code-parent skip
          "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
          "Номер партии" buf_parts.part-code skip
          view-as alert-box error .
        undo, return error .
      end.
    end.

    /* и проверять, что для всех исходных партий имеются партии в приходной накладной */
    for each buf_parts share-lock
      where buf_parts.out-code = buf_trn-doc.hold-doc-code-parent
    on error undo, return error
    :
      if  buf_trn-doc.doc-type = {&income}
      and buf_parts.qnty = buf_parts.fact-qnty
      then do:
        /* эта партия приходуется - для неё не надо создавать партию в приходной накладной */
        next. /* --->>>--- */
      end.
      find first buf_parts-supp share-lock
        where buf_parts-supp.orig-in-code   = buf_parts.in-code
          and buf_parts-supp.artic          = buf_parts.artic
          and buf_parts-supp.prod-type      = buf_parts.prod-type
          and buf_parts-supp.prod-code      = buf_parts.prod-code
          and buf_parts-supp.orig-part-code = buf_parts.part-code
        no-error .
      if not available buf_parts-supp
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info{&vssseq} skip
          "Не найдена информация о поставщике для исходной накладной" skip
          "Документ" buf_trn-doc.doc-code skip
          "Родительский документ" buf_trn-doc.hold-doc-code-parent skip
          "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
          "Номер партии" buf_parts.part-code skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
  end.

end procedure. /* holdprts-validate-document */


procedure holdprts-doc-type :

  define input  parameter p-cat-code as integer   no-undo .
  define input  parameter p-doc-code as character no-undo .
  define output parameter p-is-sale  as logical   no-undo .
  define output parameter p-is-purch as logical   no-undo .

  define variable vss-description as character no-undo init "holdprts-doc-type-01: определение типа документа для межфирменного архива".

  define buffer buf_trn-doc for ub.trn-doc .

  do
  on error undo, return error return-value
  :
    /* определяем атрибуты документов для межфирменного архива */
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info{&vssseq} skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Документ" p-doc-code skip
        "Тип архива" p-cat-code skip
        view-as alert-box error .
      undo, return error .
    end.

    case p-cat-code :
      when {&hold-main-cat-code}
      then do:
        define variable v-is-hold as logical   no-undo .
        { gbl/hold-doc.i
          buf_trn-doc.doc-code
          v-is-hold
        }

        if v-is-hold = true
        then do:
          /* межфирменные документы не попадают в Межфирменный архив по приходам и расхоадм */
          assign
            p-is-sale  = false
            p-is-purch = false
          .
        end.
        else do:
          case buf_trn-doc.ext-doc-type :
            when {&TDEDT_Pri_Vnesh} or
            when {&TDEDT_Ras_Vnesh_VP}
            then do:
              assign
                p-is-sale  = false
                p-is-purch = true
              .
            end.
            when {&TDEDT_Ras_Vnesh} or
            when {&TDEDT_Ras_Vnesh_Kass} or
            when {&TDEDT_Vozvrat_Vnesh} or
            when {&TDEDT_Vozvrat_Vnesh_Kass}
            then do:
              assign
                p-is-sale  = true
                p-is-purch = false
              .
            end.
            when {&TDEDT_Spi_Vnesh} or
            when {&TDEDT_Inv} or
            when {&TDEDT_Peresort} or
            when {&TDEDT_Corr_Acc_Price} or
            when {&TDEDT_Corr_Minus_Parts} or
            when {&TDEDT_Chg_Purch_Code} or
            when {&TDEDT_Pri_Perem} or
            when {&TDEDT_Ras_Perem} or
            when {&TDEDT_Pri_Object} or
            when {&TDEDT_Ras_Object} or
            when {&TDEDT_Vozvrat_Perem} or
            when {&TDEDT_Ras_Prvo} or
            when {&TDEDT_Spi_Prvo} or
            when {&TDEDT_Pri_Prvo}
            then do:
              assign
                p-is-sale  = false
                p-is-purch = false
              .
            end.
            otherwise do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info{&vssseq} skip
                "Неизвестный тип документа" skip
                "Документ" buf_trn-doc.doc-code skip
                "Тип документа" buf_trn-doc.ext-doc-type skip
                "Тип архива" p-cat-code skip
                view-as alert-box error .
              undo, return error .
            end.
          end.
        end.
      end.
      when {&hold-inv-cat-code}
      then do:
        case buf_trn-doc.ext-doc-type :
          when {&TDEDT_Inv} or
          when {&TDEDT_Peresort}
          then do:
            assign
              p-is-sale  = false
              p-is-purch = true
            .
          end.
          otherwise do:
            assign
              p-is-sale  = false
              p-is-purch = false
            .
          end.
        end.
      end.
      when {&hold-spi-cat-code}
      then do:
        case buf_trn-doc.ext-doc-type :
          when {&TDEDT_Spi_Vnesh}
          then do:
            assign
              p-is-sale  = false
              p-is-purch = true
            .
          end.
          otherwise do:
            assign
              p-is-sale  = false
              p-is-purch = false
            .
          end.
        end.
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестный тип архивов" skip
          "Документ" buf_trn-doc.doc-code skip
          "Тип документа" buf_trn-doc.ext-doc-type skip
          "Тип архива" p-cat-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.

end procedure. /* holdprts-doc-type */


procedure holdprts-purch-values :

  define input  parameter p-doc-code             like ub.doc-line.doc-code  no-undo .
  define input  parameter p-artic                like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type            like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code            like ub.doc-line.prod-code no-undo .
  define output parameter p-fact-qnty            as decimal   no-undo .
  define output parameter p-purch-sum-base       as decimal   no-undo .
  define output parameter p-purch-sum-rubl       as decimal   no-undo .
  define output parameter p-purch-VAT-base       as decimal   no-undo .
  define output parameter p-purch-VAT-rubl       as decimal   no-undo .
  define output parameter p-purch-SLT-base       as decimal   no-undo .
  define output parameter p-purch-SLT-rubl       as decimal   no-undo .
  define output parameter p-purch-road-tax-base  as decimal   no-undo .
  define output parameter p-purch-road-tax-rubl  as decimal   no-undo .
  define output parameter p-purch-excise-base    as decimal   no-undo .
  define output parameter p-purch-excise-rubl    as decimal   no-undo .
  define output parameter p-purch-transport-base as decimal   no-undo .
  define output parameter p-purch-transport-rubl as decimal   no-undo .
  define output parameter p-purch-other-base     as decimal   no-undo .
  define output parameter p-purch-other-rubl     as decimal   no-undo .
  define output parameter p-purch-discnt-base    as decimal   no-undo .
  define output parameter p-purch-discnt-rubl    as decimal   no-undo .

  define variable vss-description as character no-undo init "holdprts-purch-values-01: параметры закупки товара".

  define variable v-price-base     as decimal   no-undo .
  define variable v-price-rubl     as decimal   no-undo .
  define variable v-VAT-base       as decimal   no-undo .
  define variable v-VAT-rubl       as decimal   no-undo .
  define variable v-SLT-base       as decimal   no-undo .
  define variable v-SLT-rubl       as decimal   no-undo .
  define variable v-road-tax-base  as decimal   no-undo .
  define variable v-road-tax-rubl  as decimal   no-undo .
  define variable v-transport-base as decimal   no-undo .
  define variable v-transport-rubl as decimal   no-undo .
  define variable v-other-base     as decimal   no-undo .
  define variable v-other-rubl     as decimal   no-undo .

  define buffer buf_trn-doc        for ub.trn-doc .
  define buffer buf_parts          for ub.parts .
  define buffer buf_parts-supp     for ub.parts-supp .
  define buffer buf_doc-line       for ub.doc-line .
  define buffer buf_income_trn-doc for ub.trn-doc .

  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info{&vssseq} skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Документ" p-doc-code skip
        view-as alert-box error .
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
        vss-include-info{&vssseq} skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.

    assign
      p-fact-qnty            = 0
      p-purch-sum-base       = 0
      p-purch-sum-rubl       = 0
      p-purch-VAT-base       = 0
      p-purch-VAT-rubl       = 0
      p-purch-SLT-base       = 0
      p-purch-SLT-rubl       = 0
      p-purch-road-tax-base  = 0
      p-purch-road-tax-rubl  = 0
      p-purch-excise-base    = 0
      p-purch-excise-rubl    = 0
      p-purch-transport-base = 0
      p-purch-transport-rubl = 0
      p-purch-other-base     = 0
      p-purch-other-rubl     = 0
      p-purch-discnt-base    = 0
      p-purch-discnt-rubl    = 0
    .

    for each buf_parts no-lock
      where buf_parts.out-code  = buf_doc-line.doc-code
        and buf_parts.obj-type  = buf_doc-line.obj-type
        and buf_parts.obj-code  = buf_doc-line.obj-code
        and buf_parts.artic     = buf_doc-line.artic
        and buf_parts.prod-type = buf_doc-line.prod-type
        and buf_parts.prod-code = buf_doc-line.prod-code
    on error undo, return error
    :
      define variable v-parts-qnty as decimal   no-undo .
      assign
        v-parts-qnty = buf_parts.fact-qnty
                     * ( if lookup(buf_trn-doc.doc-type, {&expense_write-off} ) > 0
                         then -1
                         else 1
                       )
      .

      find first buf_parts-supp no-lock
        where buf_parts-supp.in-code   = buf_parts.in-code
          and buf_parts-supp.artic     = buf_parts.artic
          and buf_parts-supp.prod-type = buf_parts.prod-type
          and buf_parts-supp.prod-code = buf_parts.prod-code
          and buf_parts-supp.part-code = buf_parts.part-code
        no-error .
      if available buf_parts-supp
      then do:
        assign
          v-price-base     = buf_parts-supp.price-base
          v-price-rubl     = buf_parts-supp.price-rubl
          v-VAT-base       = buf_parts-supp.VAT-base
          v-VAT-rubl       = buf_parts-supp.VAT-rubl
          v-SLT-base       = buf_parts-supp.SLT-base
          v-SLT-rubl       = buf_parts-supp.SLT-rubl
          v-road-tax-base  = buf_parts-supp.road-tax-base
          v-road-tax-rubl  = buf_parts-supp.road-tax-rubl
          v-transport-base = buf_parts-supp.transport-base
          v-transport-rubl = buf_parts-supp.transport-rubl
          v-other-base     = buf_parts-supp.other-base
          v-other-rubl     = buf_parts-supp.other-rubl
        .
      end.
      else do:
        { str/in-vatp.i def }
        { str/in-vatp.i calc-parts buf_parts. " " loc }

        assign
          v-price-base     = price-base-with-tax-loc
          v-price-rubl     = price-rubl-with-tax-loc
          v-VAT-base       = vat-base-loc
          v-VAT-rubl       = vat-rubl-loc
          v-SLT-base       = slt-base-loc
          v-SLT-rubl       = slt-rubl-loc
          v-road-tax-base  = road-tax-base-loc
          v-road-tax-rubl  = road-tax-rubl-loc
          v-transport-base = transport-base-loc
          v-transport-rubl = transport-rubl-loc
          v-other-base     = other-base-loc
          v-other-rubl     = other-rubl-loc
        .
      end.

      assign
        p-fact-qnty            = p-fact-qnty            + v-parts-qnty
        p-purch-sum-base       = p-purch-sum-base       + v-price-base     * v-parts-qnty
        p-purch-sum-rubl       = p-purch-sum-rubl       + v-price-rubl     * v-parts-qnty
        p-purch-VAT-base       = p-purch-VAT-base       + v-VAT-base       * v-parts-qnty
        p-purch-VAT-rubl       = p-purch-VAT-rubl       + v-VAT-rubl       * v-parts-qnty
        p-purch-SLT-base       = p-purch-SLT-base       + v-SLT-base       * v-parts-qnty
        p-purch-SLT-rubl       = p-purch-SLT-rubl       + v-SLT-rubl       * v-parts-qnty
        p-purch-road-tax-base  = p-purch-road-tax-base  + v-road-tax-base  * v-parts-qnty
        p-purch-road-tax-rubl  = p-purch-road-tax-rubl  + v-road-tax-rubl  * v-parts-qnty
        p-purch-excise-base    = p-purch-excise-base    + 0
        p-purch-excise-rubl    = p-purch-excise-rubl    + 0
        p-purch-transport-base = p-purch-transport-base + v-transport-base * v-parts-qnty
        p-purch-transport-rubl = p-purch-transport-rubl + v-transport-rubl * v-parts-qnty
        p-purch-other-base     = p-purch-other-base     + v-other-base     * v-parts-qnty
        p-purch-other-rubl     = p-purch-other-rubl     + v-other-rubl     * v-parts-qnty
        p-purch-discnt-base    = p-purch-discnt-base    + 0
        p-purch-discnt-rubl    = p-purch-discnt-rubl    + 0
      .
    end.
  end.

end procedure. /* holdprts-purch-values */


procedure holdprts-sale-values :

  define input  parameter p-doc-code            like ub.doc-line.doc-code  no-undo .
  define input  parameter p-artic               like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type           like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code           like ub.doc-line.prod-code no-undo .
  define output parameter p-fact-qnty           as decimal   no-undo .
  define output parameter p-sale-sum-base       as decimal   no-undo .
  define output parameter p-sale-sum-rubl       as decimal   no-undo .
  define output parameter p-sale-VAT-base       as decimal   no-undo .
  define output parameter p-sale-VAT-rubl       as decimal   no-undo .
  define output parameter p-sale-SLT-base       as decimal   no-undo .
  define output parameter p-sale-SLT-rubl       as decimal   no-undo .
  define output parameter p-sale-road-tax-base  as decimal   no-undo .
  define output parameter p-sale-road-tax-rubl  as decimal   no-undo .
  define output parameter p-sale-excise-base    as decimal   no-undo .
  define output parameter p-sale-excise-rubl    as decimal   no-undo .
  define output parameter p-sale-transport-base as decimal   no-undo .
  define output parameter p-sale-transport-rubl as decimal   no-undo .
  define output parameter p-sale-other-base     as decimal   no-undo .
  define output parameter p-sale-other-rubl     as decimal   no-undo .
  define output parameter p-sale-discnt-base    as decimal   no-undo .
  define output parameter p-sale-discnt-rubl    as decimal   no-undo .

  define variable vss-description as character no-undo init "holdprts-sale-values-01: параметры продажи товара".

  define variable v-gds-dtl-fact-qnty as decimal   no-undo .

  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_gds-dtl  for ub.gds-dtl.
  define buffer buf_goods    for ub.goods.
  define buffer buf_trn-doc  for ub.trn-doc.

  { str/out-vatp.i def }

  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
    no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info{&vssseq} skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
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
        vss-include-info{&vssseq} skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.

    /* расчет продажной цены документа с учетом скидок (ндс и нсп документа) */
    for each buf_gds-dtl no-lock
      where buf_gds-dtl.doc-code  = buf_doc-line.doc-code
        and buf_gds-dtl.artic     = buf_doc-line.artic
        and buf_gds-dtl.prod-type = buf_doc-line.prod-type
        and buf_gds-dtl.prod-code = buf_doc-line.prod-code
    on error undo, return error
    :
      if buf_trn-doc.doc-type <> {&inventory}
      then do:
        if buf_trn-doc.doc-type = {&income}
        or buf_trn-doc.doc-type = {&return}
        then do:
          assign
            v-gds-dtl-fact-qnty = buf_gds-dtl.fact-qnty
          .
        end.
        else do:
          assign
            v-gds-dtl-fact-qnty = - buf_gds-dtl.fact-qnty
          .
        end.
      end.
      else do:
        assign
          v-gds-dtl-fact-qnty = buf_gds-dtl.doc-qnty
        .
      end.

      if v-gds-dtl-fact-qnty <> 0
      then do:
        { str/out-vatp.i calc-gds-dtl buf_doc-line. buf_trn-doc. buf_gds-dtl. }

        assign
          p-fact-qnty           = p-fact-qnty          + v-gds-dtl-fact-qnty
          p-sale-sum-base       = p-sale-sum-base      + price-base-with-tax-sale  * v-gds-dtl-fact-qnty
          p-sale-sum-rubl       = p-sale-sum-rubl      + price-rubl-with-tax-sale  * v-gds-dtl-fact-qnty
          p-sale-vat-base       = p-sale-vat-base      + vat-base-sale             * v-gds-dtl-fact-qnty
          p-sale-vat-rubl       = p-sale-vat-rubl      + vat-rubl-sale             * v-gds-dtl-fact-qnty
          p-sale-slt-base       = p-sale-slt-base      + slt-base-sale             * v-gds-dtl-fact-qnty
          p-sale-slt-rubl       = p-sale-slt-rubl      + slt-rubl-sale             * v-gds-dtl-fact-qnty
          p-sale-road-tax-base  = p-sale-road-tax-base + road-tax-base-sale        * v-gds-dtl-fact-qnty
          p-sale-road-tax-rubl  = p-sale-road-tax-rubl + road-tax-rubl-sale        * v-gds-dtl-fact-qnty
          p-sale-excise-base    = p-sale-excise-base   + excise-base-sale          * v-gds-dtl-fact-qnty
          p-sale-excise-rubl    = p-sale-excise-rubl   + excise-rubl-sale          * v-gds-dtl-fact-qnty
          p-sale-discnt-base    = p-sale-discnt-base   + discnt-base-sale          * v-gds-dtl-fact-qnty
          p-sale-discnt-rubl    = p-sale-discnt-rubl   + discnt-rubl-sale          * v-gds-dtl-fact-qnty
        .
      end.
    end.
    assign
      p-sale-transport-base = 0
      p-sale-transport-rubl = 0
      p-sale-other-base     = 0
      p-sale-other-rubl     = 0
    .
  end.

end procedure. /* holdprts-sale-values */

/* $Workfile$   E n d */