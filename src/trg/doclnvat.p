block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Изменение НДС поставщика в строке документа

Автор: Чернова Светлана Александровна
Дата создания: 09/24/07
Author: Svetlana Chernova
Creation date: 09/24/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 09/10/03

*/

define input parameter p-doc-code   like ub.doc-line.doc-code  no-undo .
define input parameter p-artic      like ub.doc-line.artic     no-undo .
define input parameter p-prod-type  like ub.doc-line.prod-type no-undo .
define input parameter p-prod-code  like ub.doc-line.prod-code no-undo .
define input parameter p-new-VAT-pc as decimal no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Изменение НДС поставщика в строке документа".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ trg/partrqst.i }
{ str/in-cli.i def }
{ str/in-vatp.i def }

&scop partrqst-prefix v-total-parts-
{&partrqst-var}

find first ub.doc-line no-lock
  where ub.doc-line.doc-code   = p-doc-code
    and ub.doc-line.artic      = p-artic
    and ub.doc-line.prod-type  = p-prod-type
    and ub.doc-line.prod-code  = p-prod-code
  no-error .
if not available ub.doc-line then do:
  message
    vss-workfile vss-revision vss-description skip
    "Не найдена запись doc-line" skip
    "p-doc-code"  p-doc-code  skip
    "p-artic"     p-artic     skip
    "p-prod-type" p-prod-type skip
    "p-prod-code" p-prod-code skip
    view-as alert-box error .
end.

if p-new-VAT-pc = ub.doc-line.VAT-pc then do:
  /* НДС поставщика не меняется - ничего не надо делать */
  return . /* --->>>--- */
end.

trans-block:
do transaction
on error undo trans-block, return error
:
  find first ub.trn-doc exclusive-lock
    where ub.trn-doc.doc-code = p-doc-code
    .

  if ub.trn-doc.doc-type <> {&income}
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "У данного документа нельзя менять процент НДС" skip
      "Указанный документ не является документом внешнего прихода" skip
      "Документ" p-doc-code skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      "Тип документа" ub.trn-doc.doc-type skip
      view-as alert-box .
    undo, return error return-value .
  end.

  if ub.trn-doc.status_ <> {&fact}
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "У данного документа нельзя менять процент НДС" skip
      "Статус документа отличен от статуса" {&fact} skip
      "Статус документа" ub.trn-doc.status_ skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      "Статус документа" ub.trn-doc.status_ skip
      view-as alert-box .
    undo, return error return-value .
  end.

  if  ub.trn-doc.VAT-type = {&without-VAT}
  and p-new-VAT-pc <> 0
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "У документа с типом заведения НДС" {&without-VAT} skip
      "можно задать только нулевой процент НДС" skip
      "Статус документа" ub.trn-doc.status_ skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      "Статус документа" ub.trn-doc.status_ skip
      "Процент НДС" p-new-VAT-pc skip
      view-as alert-box .
    undo, return error return-value .
  end.

  find current ub.doc-line exclusive-lock .
  assign
    ub.doc-line.VAT-pc = p-new-VAT-pc
  .

  for each parts exclusive-lock
    where parts.in-code   = p-doc-code
      and parts.artic     = p-artic
      and parts.prod-type = p-prod-type
      and parts.prod-code = p-prod-code
  on error undo trans-block, return error
  :
    { str/in-cli.i calc ub.parts. ub.trn-doc. }

    assign
      parts.VAT-pc    = p-new-VAT-pc
      parts.price-cli = price-cli-loc
    .

    define variable v-gds-code as integer   no-undo .
    { gbl/pargocod.i
      recid(parts)
      v-gds-code
    }

    /* обновляем информацию о цене в атрибутах */
    for each parts-attr exclusive-lock
      where parts-attr.in-code   = parts.in-code
        and parts-attr.gds-code  = v-gds-code
        and parts-attr.part-code = parts.part-code
    on error undo trans-block, return error
    :
      assign
        parts-attr.VAT-pc    = parts.VAT-pc
        parts-attr.price-cli = parts.price-cli
      .

      { str/in-vatp.i calc-parts parts. " " loc}

      assign
        parts-attr.vat-base         = vat-base-loc
        parts-attr.vat-rubl         = vat-rubl-loc
        parts-attr.slt-base         = slt-base-loc
        parts-attr.slt-rubl         = slt-rubl-loc
        parts-attr.discnt-base      = 0
        parts-attr.discnt-rubl      = 0
      .
    end.

    /* если партия привязана к документу */
    /* то помечаем документ изменившимся */
    define buffer buf_trn-doc for ub.trn-doc .
    find first buf_trn-doc exclusive-lock
      where buf_trn-doc.doc-code = parts.out-code
      no-error .
    if available buf_trn-doc
    and buf_trn-doc.status_ = {&fact}
    then do:
      run trg/markdoc.p
        (input buf_trn-doc.doc-code /* p-doc-code */
        ,input 'doc-change':u       /* p-action   */
        ) no-error .
      if error-status :error
      then do:
        message
          "Не удалось зарегистрировать изменение документа" skip
          "Документ" parts.out-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
  end.

  run partrqst in this-procedure
    (input  ub.doc-line.doc-code        /* p-doc-code               */
    ,input  ub.doc-line.obj-type        /* p-obj-type               */
    ,input  ub.doc-line.obj-code        /* p-obj-code               */
    ,input  ub.doc-line.artic           /* p-artic                  */
    ,input  ub.doc-line.prod-type       /* p-prod-type              */
    ,input  ub.doc-line.prod-code       /* p-prod-code              */
    &scop partrqst-prefix v-total-parts-
    {&partrqst-param}
    ).
  if  trn-doc.doc-type = {&income}
  and trn-doc.internal = no
  then do:
    if v-total-parts-cli-qnty <> 0 then do:
      assign
        ub.doc-line.price-cli = v-total-parts-price-cli / v-total-parts-cli-qnty
      .
    end.
  end.

  run trg/markdoc.p
    (input ub.trn-doc.doc-code /* p-doc-code */
    ,input 'doc-change':u      /* p-action   */
    ) no-error .
  if error-status :error
  then do:
    message
      "Не удалось зарегистрировать изменение документа" skip
      "Документ" ub.trn-doc.doc-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.

end.