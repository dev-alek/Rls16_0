/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Оборотная ведомость по покупателям (по товарам), расчет темп-таблицы

Автор: Комаров Иван Сергеевич
Дата создания: 12/03/09
Author: Ivan Komarov
Creation date: 12/03/09

*/

for each buf_doc-line no-lock
  where buf_doc-line.doc-code = buf_trn-doc.doc-code
:
  find first tt-goods no-lock
    where tt-goods.artic     = buf_doc-line.artic
      and tt-goods.prod-type = buf_doc-line.prod-type
      and tt-goods.prod-code = buf_doc-line.prod-code
    no-error .
  if available tt-goods then do :
    find first buy-data no-lock
      where buy-data.obj-type  = {1}.obj-type
        and buy-data.obj-code  = {1}.obj-code
        and buy-data.gds-code  = tt-goods.gds-code
      no-error .
    if NOT available buy-data then do:
      create buy-data .
      assign
        buy-data.obj-type    =  {1}.obj-type
        buy-data.obj-code    =  {1}.obj-code
        buy-data.obj-name    =  {1}.obj-name
        buy-data.gds-code    =  tt-goods.gds-code
        buy-data.artic       =  tt-goods.artic
      .
      find first buf_goods no-lock
        where buf_goods.artic     = buf_doc-line.artic
          and buf_goods.prod-type = buf_doc-line.prod-type
          and buf_goods.prod-code = buf_doc-line.prod-code
        no-error  .
      if available buf_goods then do:
        assign
          buy-data.name  =  buf_goods.gds-name
        .
      end.
    end.  /*if NOT avail buy-data */
    find first buf_ot-line
      where buf_ot-line.doc-code     = buf_trn-doc.doc-code
        and buf_ot-line.artic        = buf_doc-line.artic
        and buf_ot-line.prod-type    = buf_doc-line.prod-type
        and buf_ot-line.prod-code    = buf_doc-line.prod-code
        and buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
      no-error .
    if available buf_ot-line then do:
      assign
        buy-data.ras-qnty = buy-data.ras-qnty + abs(buf_ot-line.fact-qnty)
      .
    end.
    for each buf_ot-line no-lock
      where buf_ot-line.doc-code     = buf_trn-doc.doc-code
        and buf_ot-line.artic        = buf_doc-line.artic
        and buf_ot-line.prod-type    = buf_doc-line.prod-type
        and buf_ot-line.prod-code    = buf_doc-line.prod-code
        and buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
    :
      if buf_ot-line.sum-type = {&arh-cost}
        or buf_ot-line.sum-type = {&arh-cost-service}
      then do:
        assign
          buy-data.cost-sum-rubl-ras  =  buy-data.cost-sum-rubl-ras + ABS(buf_ot-line.sum-rubl)
          buy-data.cost-sum-base-ras  =  buy-data.cost-sum-base-ras + abs(buf_ot-line.sum-base)
        .
      end.
      if buf_ot-line.sum-type = {&arh-sale}
        or buf_ot-line.sum-type = {&arh-sale-service}
      then do:
        assign
          buy-data.sale-sum-rubl-ras  =  buy-data.sale-sum-rubl-ras + abs(buf_ot-line.sum-rubl)
          buy-data.sale-sum-base-ras  =  buy-data.sale-sum-base-ras + abs(buf_ot-line.sum-base)
        .
      end.
    end.
    find first buf_ot-line
      where buf_ot-line.doc-code     = buf_trn-doc.doc-code
        and buf_ot-line.artic        = buf_doc-line.artic
        and buf_ot-line.prod-type    = buf_doc-line.prod-type
        and buf_ot-line.prod-code    = buf_doc-line.prod-code
        and buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}
      no-error .
    if available buf_ot-line then do:
        assign
          buy-data.ret-qnty = buy-data.ret-qnty + abs(buf_ot-line.fact-qnty)
        .
    end.
    for each buf_ot-line no-lock
      where buf_ot-line.doc-code     = buf_trn-doc.doc-code
        and buf_ot-line.artic        = buf_doc-line.artic
        and buf_ot-line.prod-type    = buf_doc-line.prod-type
        and buf_ot-line.prod-code    = buf_doc-line.prod-code
        and buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}
    :
      if buf_ot-line.sum-type = {&arh-cost}
        or buf_ot-line.sum-type = {&arh-cost-service}
      then do:
        assign
          buy-data.cost-sum-rubl-ret  =  buy-data.cost-sum-rubl-ret + abs(buf_ot-line.sum-rubl)
          buy-data.cost-sum-base-ret  =  buy-data.cost-sum-base-ret + abs(buf_ot-line.sum-base)
        .
      end.
      if buf_ot-line.sum-type = {&arh-sale}
        or buf_ot-line.sum-type = {&arh-sale-service}
      then do:
        assign
          buy-data.sale-sum-rubl-ret  =  buy-data.sale-sum-rubl-ret + abs(buf_ot-line.sum-rubl)
          buy-data.sale-sum-base-ret  =  buy-data.sale-sum-base-ret + abs(buf_ot-line.sum-base)
        .
      end.
    end.
    assign
      buy-data.sale-sum-rubl-all  =  buy-data.sale-sum-rubl-ras - buy-data.sale-sum-rubl-ret
      buy-data.sale-sum-base-all  =  buy-data.sale-sum-base-ras - buy-data.sale-sum-base-ret
      buy-data.cost-sum-rubl-all  =  buy-data.cost-sum-rubl-ras - buy-data.cost-sum-rubl-ret
      buy-data.cost-sum-base-all  =  buy-data.cost-sum-base-ras - buy-data.cost-sum-base-ret
      buy-data.all-qnty           =  buy-data.ras-qnty          - buy-data.ret-qnty
    .
  end. /*if avail tt-goods*/
end. /*buf_doc-line*/