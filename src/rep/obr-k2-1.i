/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

для детал. оборотки с признаками

Автор: Демин Алексей Сергеевич
Дата создания: 03/22/06
Author: Alexey Demin
Creation date: 03/22/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

  /* Было ли на этом объекте хотя бы какое-то движение данного товара */
  if buf_gds-obj.last-doc < x-date-start and buf_gds-obj.fact-qnty = 0 and buf_gds-obj.avrg-qnty = 0 and buf_gds-obj.fact-sale =0 and buf_gds-obj.fact-base = 0 then next .

  case RADIO-Nomenkl :
    when 2 then /* Текуща  */
      if buf_gds-obj.stts <> 0 then next .
    when 3 then /* "Удаленная" */
      if buf_gds-obj.stts = 0  then next .
  end case.

  assign Counter1 = Counter1 + 1.
  { rep/repfrm.i disp Counter1 }

  if tog-obj = true then do: /* раздельно по объектам */
    find first gds-prop
      where gds-prop.prod-type = buf_gds-obj.prod-type
        and gds-prop.prod-code = buf_gds-obj.prod-code
        and gds-prop.artic     = buf_gds-obj.artic
        and gds-prop.obj-type  = buf_gds-obj.obj-type
        and gds-prop.obj-code  = buf_gds-obj.obj-code
    no-error .
  end.
  else do:
    find first gds-prop
      where gds-prop.prod-type = buf_gds-obj.prod-type
        and gds-prop.prod-code = buf_gds-obj.prod-code
        and gds-prop.artic     = buf_gds-obj.artic
    no-error .
  end.
  if not available gds-prop  then do:
    find first buf_goods    no-lock where buf_goods.gds-code = buf_gds-obj.gds-code .
    find first buf1_clients no-lock where buf1_clients.obj-type = buf_gds-obj.prod-type and buf1_clients.obj-code = buf_gds-obj.prod-code .
    create gds-prop .

    { gbl/gdsbcode.i  buf_goods.gds-code  ?  ii  no-error }
    if error-status :error then do:
      message vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода товара" skip
        "Артикул товара" skip buf_gds-obj.artic   view-as alert-box error .
/*      undo, return error .*/
    end.

    { gbl/pftxvalg.i buf_gds-obj.gds-code {&vat-tax-code} ? g#host-code buf_gds-obj.obj-type buf_gds-obj.obj-code gds-prop.vat-pc no-error }

    assign
       gds-prop.prod-type = buf_goods.prod-type
       gds-prop.prod-code = buf_goods.prod-code
       gds-prop.artic     = buf_goods.artic
       gds-prop.gds-code  = buf_goods.gds-code
       gds-prop.grp-name  = trim( buf_goods.grp-name )
       gds-prop.grp-code  = buf_goods.grp-code
       gds-prop.prod-name = buf1_clients.obj-name
       gds-prop.unit-base = buf_goods.unit-base
       gds-prop.b-code    = string(ii,">>>>>>>>>>>>9")
       gds-prop.gds-name1 = buf_goods.engl-name
    .
    if tog-obj = true then do: /* раздельно по объектам */
      find first buf2_clients no-lock where buf2_clients.obj-type = obj-list.obj-type and buf2_clients.obj-code = obj-list.obj-code .
      assign
        gds-prop.obj-type  = buf2_clients.obj-type
        gds-prop.obj-code  = buf2_clients.obj-code
        gds-prop.obj-name  = buf2_clients.obj-name
      .
    end.
    else do:
      assign
        gds-prop.obj-type  = ""
        gds-prop.obj-code  = -1
        gds-prop.obj-name  = ""
      .
    end.

/*  if g#gds-engl then assign gds-prop.gds-name = buf_goods.engl-name.*/
    if name-tov = 2 then assign gds-prop.gds-name = buf_goods.engl-name.
    else                 assign gds-prop.gds-name = buf_goods.gds-name.

    { gbl/rootnode.i   buf_goods.artic   buf_goods.prod-type   buf_goods.prod-code  v-root-node }
    { gbl/prtat.i v-root-node  "'empty-scale=request'"  gds-prop.empty-scale }

    if x-SET_val_TYPE = 1  then assign gds-prop.Cost-Price = buf_gds-obj.last-rubl .
    else                        assign gds-prop.Cost-Price = buf_gds-obj.last-base .
  end.

  if use-column[5] = yes or use-column[6] = yes or use-column[8] = yes or use-column[9] = yes then do: /* дата и номер последней переоценки за пириод */

    find last price-list no-lock
      where price-list.obj-type  = buf_gds-obj.obj-type
        and price-list.obj-code  = buf_gds-obj.obj-code
        and price-list.b-code    = int(gds-prop.b-code)
        and price-list.fact-order < v-fact-order-end
      use-index fact-close no-error .

    if available price-list then do:
      find first price-doc no-lock where price-doc.doc-num  = price-list.doc-num .
      if tog-obj = true or price-doc.fact-order > gds-prop.Avrg-Sale-Price then do:
        assign
          gds-prop.Avrg-Sale-Price = price-list.fact-order
          gds-prop.Last-Sale-Price = price-list.price-sale
          gds-prop.LastPer-Date    = price-doc.doc-date
          gds-prop.LastPer-Num     = price-doc.doc-num
        .
      end .
    end .
  end.
/* $Workfile$   E n d */