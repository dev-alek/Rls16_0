block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание атрибутов партий для документа

Автор: Чернова Светлана Александровна
Дата создания: 07/09/07
Author: Svetlana Chernova
Creation date: 07/09/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 05/23/03

*/

define input  parameter p-doc-code   as character no-undo .
define input  parameter p-create-all as logical   no-undo .

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Создание атрибутов партий для документа".
{ cmp/vssrevis.i "substitute('&1':u,p-doc-code)"}
{ cmp/trg-def.i  }
{ gbl/lineattr.i }

define buffer buf_trn-doc        for ub.trn-doc .
define buffer buf_parts          for ub.parts .
define buffer buf_doc-line       for ub.doc-line .
define buffer buf_parts-attr     for ub.parts-attr .
define buffer new_parts-attr     for ub.parts-attr .
define buffer buf_parts-root     for ub.parts-root .
define buffer buf_income_trn-doc for ub.trn-doc .

{ str/in-vatp.i def }

define stream sout .

do
on error undo, return error return-value
:
  find first buf_trn-doc
    where buf_trn-doc.doc-code = p-doc-code
    no-error .
  if not available buf_trn-doc
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден документ" skip
      "Документ" p-doc-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  /* анализируем порожденные партии */
  for each buf_doc-line
    where buf_doc-line.doc-code = p-doc-code
  on error undo, return error return-value
  :
    define variable v-gds-code as integer   no-undo .
    { gbl/doclicod.i
      recid(buf_doc-line)
      v-gds-code
    }

    /* определяем код страны */
    define variable v-country-code as integer   no-undo .
    run get-country-code in this-procedure
      (input  buf_trn-doc.doc-code     /* p-doc-code     */
      ,input  buf_trn-doc.ext-doc-type /* p-ext-doc-type */
      ,input  v-gds-code               /* p-gds-code     */
      ,output v-country-code           /* p-country-code */
      ) .

    define variable v-obj-type  as character no-undo .
    define variable v-obj-code  as integer   no-undo .
    define variable v-artic     as character no-undo .
    define variable v-prod-type as character no-undo .
    define variable v-prod-code as integer   no-undo .


    assign
      v-obj-type  = buf_doc-line.obj-type
      v-obj-code  = buf_doc-line.obj-code
      v-artic     = buf_doc-line.artic
      v-prod-type = buf_doc-line.prod-type
      v-prod-code = buf_doc-line.prod-code
    .


    /* просматриваем все порожденные партии */
    for each buf_parts
      where buf_parts.out-code  = p-doc-code
        and buf_parts.obj-type  = v-obj-type
        and buf_parts.obj-code  = v-obj-code
        and buf_parts.artic     = v-artic
        and buf_parts.prod-type = v-prod-type
        and buf_parts.prod-code = v-prod-code
        and buf_parts.status_   = true
    on error undo, return error return-value
    :
      /* создаем атрибут партии при необходимости */
      find first buf_parts-attr no-lock
        where buf_parts-attr.in-code   = buf_parts.in-code
          and buf_parts-attr.gds-code  = v-gds-code
          and buf_parts-attr.part-code = buf_parts.part-code
        no-error .
      if not available buf_parts-attr
      then do:
        if buf_parts.in-code = buf_parts.out-code
        or (buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} and index(buf_trn-doc.doc-code, "=") > 0 and p-create-all = false) /* При закрытии Внутреннего прихода для него тоже создаём атрибут партии */
        then do:
          /* если это порожденная партия, */
          /* то создаем ее атрибут */
          if buf_trn-doc.ext-doc-type = {&TDEDT_Corr_Acc_Price}
          or buf_trn-doc.ext-doc-type = {&TDEDT_Chg_Purch_Code}
          then do:
            /* если это документ преобразования свойств партий */
            /* то копируем атрибут исходной партии */
            find first buf_parts-root
              where buf_parts-root.in-code   = buf_parts.in-code
                and buf_parts-root.gds-code  = v-gds-code
                and buf_parts-root.part-code = buf_parts.part-code
              no-error .
            if not available buf_parts-root
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Не найдена информация об исходной партии" skip
                "Документ" p-doc-code skip
                "Код товара" v-gds-code skip
                "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
                "Код партии" buf_parts.in-code buf_parts.part-code skip
                view-as alert-box error .
              undo, return error return-value .
            end.
            find first buf_parts-attr
              where buf_parts-attr.in-code   = buf_parts-root.orig-in-code
                and buf_parts-attr.gds-code  = buf_parts-root.orig-gds-code
                and buf_parts-attr.part-code = buf_parts-root.orig-part-code
              no-error .
            if not available buf_parts-attr
            then do:
              /* делаем рекурсивный вызов */
              /* создаем атрибуты партий для исходной накладной */
              find first buf_income_trn-doc no-lock
                where buf_income_trn-doc.doc-code = buf_parts-root.orig-in-code
                no-error .
              if available buf_income_trn-doc
              then do:
                run trg/prtatrcr.p
                  (input buf_income_trn-doc.doc-code /* p-doc-code   */
                  ,input true                        /* p-create-all */
                  ) .
              end.
              /* переискиваем партию - она могла создастся */
              find first buf_parts-attr
                where buf_parts-attr.in-code   = buf_parts-root.orig-in-code
                  and buf_parts-attr.gds-code  = buf_parts-root.orig-gds-code
                  and buf_parts-attr.part-code = buf_parts-root.orig-part-code
                no-error .
            end.

            if available buf_parts-attr
            then do:
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
              if buf_trn-doc.ext-doc-type = {&TDEDT_Corr_Acc_Price}
              then do:
                /* вычисляем курс на основании */
                assign
                  new_parts-attr.base-scale = 1
                .
                if buf_parts.price-base <> 0
                then do:
                  assign
                    new_parts-attr.base-rate = (buf_parts.price-rubl * new_parts-attr.base-scale) / buf_parts.price-base
                  .
                end.
                else do:
                  /* цена в базовой валюте равна нулю */
                  /* полагаем курс равным единице */
                  assign
                    new_parts-attr.base-rate = 1
                  .
                end.
                assign
                  new_parts-attr.cli-qnty         = buf_parts.cli-qnty
                  new_parts-attr.price-cli        = buf_parts.price-cli
                  new_parts-attr.price-base       = buf_parts.price-base
                  new_parts-attr.price-rubl       = buf_parts.price-rubl
                  new_parts-attr.vat-type         = buf_parts.vat-type
                  new_parts-attr.vat-pc           = buf_parts.vat-pc
                  new_parts-attr.SLT-type         = buf_parts.SLT-type
                  new_parts-attr.SLT-pc           = buf_parts.SLT-pc
                  new_parts-attr.road-tax-base    = buf_parts.road-tax-base
                  new_parts-attr.road-tax-rubl    = buf_parts.road-tax-rubl
                  new_parts-attr.transport-base   = buf_parts.transport-base
                  new_parts-attr.transport-rubl   = buf_parts.transport-rubl
                  new_parts-attr.other-base       = buf_parts.other-base
                  new_parts-attr.other-rubl       = buf_parts.other-rubl
                .

                { str/in-vatp.i calc-parts buf_parts. " " loc}

                assign
                  new_parts-attr.vat-base         = vat-base-loc
                  new_parts-attr.vat-rubl         = vat-rubl-loc
                  new_parts-attr.slt-base         = slt-base-loc
                  new_parts-attr.slt-rubl         = slt-rubl-loc
                  new_parts-attr.discnt-base      = 0
                  new_parts-attr.discnt-rubl      = 0
                .
              end.
              if buf_trn-doc.ext-doc-type = {&TDEDT_Chg_Purch_Code}
              then do:
                assign
                  new_parts-attr.purch-code       = buf_parts.purch-code
                .
              end.
            end.
            else do:
              output stream sout to prtatrcr.err append .
              export stream sout
                p-doc-code
                v-gds-code
                buf_doc-line.artic
                buf_doc-line.prod-type
                buf_doc-line.prod-code
                buf_parts.in-code
                buf_parts.part-code
                buf_parts-root.orig-gds-code
                buf_parts-root.orig-in-code
                buf_parts-root.orig-part-code
                .
              output stream sout close .

              undo, return error substitute("Документ &1" + {&new-line} + "Не найден атрибут партии" + {&new-line} + "&2 &3 &4"
                ,p-doc-code
                ,buf_parts-root.orig-gds-code
                ,buf_parts-root.orig-in-code
                ,buf_parts-root.orig-part-code
                ) .
            end.
          end.
          else do:
            create new_parts-attr .

            assign
              new_parts-attr.in-code              = buf_parts.in-code
              new_parts-attr.gds-code             = v-gds-code
              new_parts-attr.part-code            = buf_parts.part-code
              new_parts-attr.orig-in-code         = buf_parts.in-code
              new_parts-attr.orig-gds-code        = v-gds-code
              new_parts-attr.orig-part-code       = buf_parts.part-code
              new_parts-attr.income-in-code       = buf_parts.in-code
              new_parts-attr.income-gds-code      = v-gds-code
              new_parts-attr.income-part-code     = buf_parts.part-code
              new_parts-attr.supp-type            = buf_parts.supp-type
              new_parts-attr.supp-code            = buf_parts.supp-code
              new_parts-attr.pay-code             = buf_parts.pay-code
              new_parts-attr.purch-code           = buf_parts.purch-code
              new_parts-attr.cli-qnty             = buf_parts.cli-qnty
              new_parts-attr.price-cli            = buf_parts.price-cli
              new_parts-attr.unit-cli             = buf_doc-line.unit-cli
              new_parts-attr.exch-code            = buf_parts.exch-code
              new_parts-attr.exch-rate            = buf_trn-doc.exch-rate
              new_parts-attr.exch-scale           = buf_trn-doc.exch-scale
              new_parts-attr.cli-base-rate        = buf_parts.cli-base-rate
              new_parts-attr.doc-qnty             = buf_parts.qnty
              new_parts-attr.fact-qnty            = buf_parts.fact-qnty
              new_parts-attr.real-qnty            = buf_parts.real-qnty
              new_parts-attr.price-base           = buf_parts.price-base
              new_parts-attr.price-rubl           = buf_parts.price-rubl
              new_parts-attr.base-rate            = buf_trn-doc.base-rate
              new_parts-attr.base-scale           = buf_trn-doc.base-scale
              new_parts-attr.vat-type             = buf_parts.vat-type
              new_parts-attr.vat-pc               = buf_parts.vat-pc
              new_parts-attr.SLT-type             = buf_parts.SLT-type
              new_parts-attr.SLT-pc               = buf_parts.SLT-pc
              new_parts-attr.road-tax-base        = buf_parts.road-tax-base
              new_parts-attr.road-tax-rubl        = buf_parts.road-tax-rubl
              new_parts-attr.transport-base       = buf_parts.transport-base
              new_parts-attr.transport-rubl       = buf_parts.transport-rubl
              new_parts-attr.other-base           = buf_parts.other-base
              new_parts-attr.other-rubl           = buf_parts.other-rubl
              new_parts-attr.density              = buf_doc-line.doc-density
              new_parts-attr.temperature          = buf_doc-line.temperature
              new_parts-attr.is-supp              = buf_parts.is-supp
              new_parts-attr.cst-code             = buf_parts.cst-code
              new_parts-attr.last-date            = buf_parts.last-date
              new_parts-attr.line-cli-qnty        = buf_doc-line.cli-qnty
              new_parts-attr.line-doc-qnty        = buf_doc-line.doc-qnty
              new_parts-attr.line-fact-qnty       = buf_doc-line.fact-qnty
              new_parts-attr.wt-brutto            = buf_doc-line.wt-brutto
              new_parts-attr.num-place            = buf_doc-line.num-place
              new_parts-attr.country-code         = v-country-code
              new_parts-attr.obj-type             = buf_trn-doc.obj-type
              new_parts-attr.obj-code             = buf_trn-doc.obj-code
              new_parts-attr.PS                   = buf_parts.PS
              new_parts-attr.fact-date            = buf_trn-doc.fact-date
              new_parts-attr.fact-time            = buf_trn-doc.fact-time
              new_parts-attr.fact-order           = buf_trn-doc.fact-order
              new_parts-attr.shift-num            = buf_trn-doc.shift-num
              new_parts-attr.shift-name           = buf_trn-doc.shift-name
              new_parts-attr.shift-date           = buf_trn-doc.shift-date
              new_parts-attr.ext-doc-type         = buf_trn-doc.ext-doc-type
              new_parts-attr.wrkr                 = buf_trn-doc.wrkr
              new_parts-attr.agnt                 = buf_trn-doc.agnt
              new_parts-attr.boss                 = buf_trn-doc.boss
              new_parts-attr.creid                = buf_trn-doc.creid
              new_parts-attr.out-code             = buf_trn-doc.out-code
              new_parts-attr.inv-num              = buf_trn-doc.inv-num
              new_parts-attr.cli-name             = buf_trn-doc.cli-name
              new_parts-attr.ord-num              = buf_trn-doc.ord-num
              new_parts-attr.is-back-date         = buf_trn-doc.is-back-date
              new_parts-attr.is-corr              = buf_trn-doc.is-corr
              new_parts-attr.is-del               = buf_trn-doc.is-del
              new_parts-attr.contract-code        = buf_parts.contract-code
              new_parts-attr.hold-doc-code-child  = buf_trn-doc.hold-doc-code-child
              new_parts-attr.hold-doc-code-parent = buf_trn-doc.hold-doc-code-parent
            .

            { str/in-vatp.i calc-parts buf_parts. " " loc}

            assign
              new_parts-attr.vat-base         = vat-base-loc
              new_parts-attr.vat-rubl         = vat-rubl-loc
              new_parts-attr.slt-base         = slt-base-loc
              new_parts-attr.slt-rubl         = slt-rubl-loc
              new_parts-attr.discnt-base      = 0
              new_parts-attr.discnt-rubl      = 0
            .
          end.
        end.
        else do:
          if p-create-all = true
          then do:
            /* для расходных документов - создаем партии при необходимости */
            find first buf_income_trn-doc no-lock
              where buf_income_trn-doc.doc-code = buf_parts.in-code
              no-error .
            if available buf_income_trn-doc
            then do:
              run trg/prtatrcr.p
                (input buf_income_trn-doc.doc-code /* p-doc-code   */
                ,input p-create-all                /* p-create-all */
                ) .
            end.
          end.
        end.
      end.
    end.
  end.
end.


procedure get-country-code :

  define input  parameter p-trn-doc      as character no-undo .
  define input  parameter p-ext-doc-type as character no-undo .
  define input  parameter p-gds-code     as integer   no-undo .
  define output parameter p-country-code as integer   no-undo .

  define buffer buf_goods   for ub.goods .
  define buffer buf_country for ub.country .

  define variable v-read-default-code as logical   no-undo .
  define variable v-attr-value        as character no-undo .
  define variable v-attr-type         as character no-undo .

  do
  on error undo, return error return-value
  :
    assign
      v-read-default-code = true
    .

    if p-ext-doc-type = {&TDEDT_Pri_Vnesh}
    then do:
      run lineattr-value in this-procedure
        (input  p-doc-code               /* p-doc-code */
        ,input  p-gds-code               /* p-gds-code */
        ,input  {&lineattr-country-code} /* p-code     */
        ,output v-attr-value             /* p-value    */
        ,output v-attr-type              /* p-type     */
        ) .
      if v-attr-value <> ""
      then do:
        assign
          v-read-default-code = false
          p-country-code      = integer(v-attr-value)
        .
      end.
    end.

    if v-read-default-code = true
    then do:
      find first buf_goods no-lock
        where buf_goods.gds-code = p-gds-code
        no-error .
      find first buf_country no-lock
        where buf_country.alpha1 = buf_goods.alpha1
        no-error .
      if available buf_country
      then do:
        assign
          p-country-code = buf_country.num-code
        .
      end.
      else do:
        assign
          p-country-code = 0
        .
      end.
    end.
  end.

end procedure. /* get-country-code */