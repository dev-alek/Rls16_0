block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Пересчет цен разного типа друг в друга

Автор: Чернова Светлана Александровна
Дата создания: 09/24/07
Author: Svetlana Chernova
Creation date: 09/24/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/05/06

*/

define input  parameter p-calc-method    as character                no-undo .
define input  parameter p-doc-code       as character                no-undo .
define input  parameter p-gds-code       as integer                  no-undo .
define input  parameter p-price-cli      like ub.doc-line.price-cli  no-undo .
define input  parameter p-price-base     like ub.doc-line.price-base no-undo .
define input  parameter p-price-rubl     like ub.doc-line.price-rubl no-undo .
define output parameter p-new-price-cli  like ub.doc-line.price-cli  no-undo .
define output parameter p-new-price-base like ub.doc-line.price-base no-undo .
define output parameter p-new-price-rubl like ub.doc-line.price-rubl no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Пересчет цен разного типа друг в друга".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6':u,p-calc-method,p-doc-code,p-gds-code,p-price-cli,p-price-base,p-price-rubl)" }
{ cmp/trg-def.i  }
{ str/lib-trn.i  }

define variable p-new-price-cli-unit-base      like ub.doc-line.price-rubl no-undo.
define variable p-new-price-road-tax           like ub.doc-line.price-rubl no-undo.
define variable p-new-price-other-exp          like ub.doc-line.price-rubl no-undo.
define variable p-new-price-transport-exp      like ub.doc-line.price-rubl no-undo.
define variable p-new-price-without-abs        like ub.doc-line.price-rubl no-undo.
define variable p-new-price-slt                like ub.doc-line.price-rubl no-undo.
define variable p-new-price-no-slt             like ub.doc-line.price-rubl no-undo.
define variable p-new-price-vat                like ub.doc-line.price-rubl no-undo.
define variable p-new-price-no-vat-slt         like ub.doc-line.price-rubl no-undo.
define variable p-new-price-road-tax-rubl      like ub.doc-line.price-rubl no-undo.
define variable p-new-price-other-exp-rubl     like ub.doc-line.price-rubl no-undo.
define variable p-new-price-transport-exp-rubl like ub.doc-line.price-rubl no-undo.
define variable p-new-price-without-abs-rubl   like ub.doc-line.price-rubl no-undo.
define variable p-new-price-slt-rubl           like ub.doc-line.price-rubl no-undo.
define variable p-new-price-no-slt-rubl        like ub.doc-line.price-rubl no-undo.
define variable p-new-price-vat-rubl           like ub.doc-line.price-rubl no-undo.
define variable p-new-price-no-vat-slt-rubl    like ub.doc-line.price-rubl no-undo.
define variable p-new-price-road-tax-base      like ub.doc-line.price-base no-undo.
define variable p-new-price-other-exp-base     like ub.doc-line.price-base no-undo.
define variable p-new-price-transport-exp-base like ub.doc-line.price-base no-undo.
define variable p-new-price-without-abs-base   like ub.doc-line.price-base no-undo.
define variable p-new-price-slt-base           like ub.doc-line.price-base no-undo.
define variable p-new-price-no-slt-base        like ub.doc-line.price-base no-undo.
define variable p-new-price-vat-base           like ub.doc-line.price-base no-undo.
define variable p-new-price-no-vat-slt-base    like ub.doc-line.price-base no-undo.

define buffer buf_doc-line for ub.doc-line .
define buffer t-doc        for ub.trn-doc .
define buffer buf_goods    for ub.goods .

find first t-doc no-lock
  where t-doc.doc-code = p-doc-code
  .
find first buf_goods no-lock
  where buf_goods.gds-code = p-gds-code
  .
find first buf_doc-line no-lock
  where buf_doc-line.doc-code  = p-doc-code
    and buf_doc-line.artic     = buf_goods.artic
    and buf_doc-line.prod-type = buf_goods.prod-type
    and buf_doc-line.prod-code = buf_goods.prod-code
  .

define variable p-artic          like ub.doc-line.artic         no-undo.
define variable p-prod-type      like ub.doc-line.prod-type     no-undo.
define variable p-prod-code      like ub.doc-line.prod-code     no-undo.
define variable p-SLT-PC         like ub.doc-line.SLT-PC        no-undo.
define variable p-VAT-PC         like ub.doc-line.VAT-PC        no-undo.
define variable p-cli-base-rate  like ub.doc-line.cli-base-rate no-undo.
define variable p-doc-qnty       like ub.doc-line.doc-qnty      no-undo.
define variable p-fact-qnty      like ub.doc-line.fact-qnty     no-undo.
define variable p-road-tax       like ub.doc-line.road-tax      no-undo.
define variable p-other-base     like ub.doc-line.road-tax      no-undo.
define variable p-other-rubl     like ub.doc-line.road-tax      no-undo.
define variable p-transport-base like ub.doc-line.road-tax      no-undo.
define variable p-transport-rubl like ub.doc-line.road-tax      no-undo.

case p-calc-method :
  when "price-cli":U then do:

   assign
     p-artic          = buf_doc-line.artic
     p-prod-type      = buf_doc-line.prod-type
     p-prod-code      = buf_doc-line.prod-code
     p-new-price-cli  = p-price-cli
     p-SLT-PC         = buf_doc-line.SLT-pc
     p-VAT-PC         = buf_doc-line.VAT-pc
     p-cli-base-rate  = buf_doc-line.cli-base-rate
     p-doc-qnty       = buf_doc-line.doc-qnty
     p-fact-qnty      = buf_doc-line.fact-qnty
     p-road-tax       = buf_doc-line.road-tax
   .
    { str/in-vat.i
      t-doc.doc-code
      t-doc.base-rate
      t-doc.base-scale
      t-doc.exch-rate
      t-doc.exch-scale
      t-doc.vat-type
      t-doc.slt-type
      buf_doc-line.artic
      buf_doc-line.prod-type
      buf_doc-line.prod-code
      p-price-cli
      buf_doc-line.cli-base-rate
      buf_doc-line.price-rubl
      buf_doc-line.vat-pc
      buf_doc-line.slt-pc
      buf_doc-line.road-tax
      buf_doc-line.transport-rubl
      buf_doc-line.other-rubl
      p-new-price-cli
      p-new-price-cli-unit-base
      p-new-price-road-tax
      p-new-price-other-exp
      p-new-price-transport-exp
      p-new-price-without-abs
      p-new-price-slt
      p-new-price-no-slt
      p-new-price-vat
      p-new-price-no-vat-slt
      p-new-price-rubl
      p-new-price-road-tax-rubl
      p-new-price-other-exp-rubl
      p-new-price-transport-exp-rubl
      p-new-price-without-abs-rubl
      p-new-price-slt-rubl
      p-new-price-no-slt-rubl
      p-new-price-vat-rubl
      p-new-price-no-vat-slt-rubl
      p-new-price-base
      p-new-price-road-tax-base
      p-new-price-other-exp-base
      p-new-price-transport-exp-base
      p-new-price-without-abs-base
      p-new-price-slt-base
      p-new-price-no-slt-base
      p-new-price-vat-base
      p-new-price-no-vat-slt-base
      no-error
    }
    if error-status:error then do:
      return error "Ошибка при пересчете линии документа".
    end.
  end.

  when "price-base":U then do:
    assign
      p-new-price-cli  = p-price-cli
      p-new-price-base = p-price-base
    .

    assign
      p-new-price-rubl = p-price-base * t-doc.base-rate / t-doc.base-scale
    .

  end.

  when "price-rubl":U then do:
    assign
      p-new-price-cli  = p-price-cli
      p-new-price-rubl = p-price-rubl
    .

    assign
      p-new-price-base = p-price-rubl / t-doc.base-rate * t-doc.base-scale
    .

  end.

  otherwise do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестное значение параметра" skip
      "p-calc-method":U p-calc-method skip
      view-as alert-box error .
    undo, return error .
  end.

end case . /* p-calc-method */