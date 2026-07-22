/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

для прогр r-gtd2.p

Автор: Демин Алексей Сергеевич
Дата создания: 03/22/06
Author: Alexey Demin
Creation date: 03/22/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

  assign Counter1 = Counter1 + 1.
  { rep/repfrm.i disp Counter1 }

  /*  ищем партиии на конец и заполняем тт */
  run partslib-init-temp-parts-by-factord (input buf_gds-obj.obj-type,
                                           input buf_gds-obj.obj-code,
                                           input buf_gds-obj.artic,
                                           input buf_gds-obj.prod-type,
                                           input buf_gds-obj.prod-code,
                                           input v-fact-order-end,
                                           false) .
  assign is-new = no .
  for each temp-parts :
/*    if temp-parts.fact-qnty = 0 then next .*/
    find first temp-goods
      where temp-goods.artic     = temp-parts.artic
        and temp-goods.prod-code = temp-parts.prod-code
        and temp-goods.prod-type = temp-parts.prod-type
        and temp-goods.part-code = temp-parts.part-code
        and temp-goods.in-code   = temp-parts.in-code
      no-error .
    if not available temp-goods then do:
      if is-new = no then do:
        assign is-new = yes .
        find first buf_goods no-lock where buf_goods.gds-code = buf_gds-obj.gds-code .
      end.
      create temp-goods .
      assign
        temp-goods.artic     = buf_gds-obj.artic
        temp-goods.prod-code = buf_gds-obj.prod-code
        temp-goods.prod-type = buf_gds-obj.prod-type
        temp-goods.grp-name  = buf_goods.grp-name
        temp-goods.part-code = temp-parts.part-code
        temp-goods.in-code   = temp-parts.in-code
        temp-goods.gtd-code  = temp-parts.cst-code
      .
      if g#gds-engl then assign temp-goods.gds-name = buf_goods.engl-name.
      else               assign temp-goods.gds-name = buf_goods.gds-name.
    end.
  end.

  /* теперь ищем остатки на начало */
  run partslib-init-temp-parts-by-factord (input buf_gds-obj.obj-type,
                                           input buf_gds-obj.obj-code,
                                           input buf_gds-obj.artic,
                                           input buf_gds-obj.prod-type,
                                           input buf_gds-obj.prod-code,
                                           input v-fact-order-start,
                                           false) .
  for each temp-parts :
/*    if temp-parts.fact-qnty = 0 then next .*/
    find first temp-goods
      where temp-goods.artic     = temp-parts.artic
        and temp-goods.prod-code = temp-parts.prod-code
        and temp-goods.prod-type = temp-parts.prod-type
        and temp-goods.part-code = temp-parts.part-code
        and temp-goods.in-code   = temp-parts.in-code
      no-error .
    if available temp-goods then do:
      assign
        temp-goods.p-ost     = temp-parts.fact-qnty
        temp-goods.p-ost-sum = (if var-report-r-b = "rubl" then temp-parts.price-rubl else temp-parts.price-base) * temp-parts.fact-qnty
      .
    end.
    else do:
      find first buf_goods no-lock where buf_goods.gds-code = buf_gds-obj.gds-code .
      create temp-goods .
      assign
        temp-goods.artic     = buf_gds-obj.artic
        temp-goods.prod-code = buf_gds-obj.prod-code
        temp-goods.prod-type = buf_gds-obj.prod-type
        temp-goods.grp-name  = buf_goods.grp-name
        temp-goods.part-code = temp-parts.part-code
        temp-goods.in-code   = temp-parts.in-code
        temp-goods.gtd-code  = temp-parts.cst-code
        temp-goods.p-ost     = temp-parts.fact-qnty
        temp-goods.p-ost-sum = (if var-report-r-b = "rubl" then temp-parts.price-rubl else temp-parts.price-base) * temp-parts.fact-qnty
      .
      if g#gds-engl then assign temp-goods.gds-name = buf_goods.engl-name.
      else               assign temp-goods.gds-name = buf_goods.gds-name.
    end.

  end.

  /* теперь ищем док-ты в интервале */
  for each buf_doc-line no-lock
    where buf_doc-line.obj-type  = buf_gds-obj.obj-type
      and buf_doc-line.obj-code  = buf_gds-obj.obj-code
      and buf_doc-line.artic     = buf_gds-obj.artic
      and buf_doc-line.prod-type = buf_gds-obj.prod-type
      and buf_doc-line.prod-code = buf_gds-obj.prod-code
      and buf_doc-line.status_   = {&fact}
      and buf_doc-line.fact-order >= v-fact-order-start
      and buf_doc-line.fact-order < v-fact-order-end
    :
    if ( buf_doc-line.ext-doc-type <> {&TDEDT_Ras_Vnesh_VP}       and
         buf_doc-line.ext-doc-type  = {&TDEDT_Pri_Vnesh}          and
         buf_doc-line.ext-doc-type  = {&TDEDT_Inv}                and
         buf_doc-line.ext-doc-type  = {&TDEDT_Peresort}           and
         buf_doc-line.ext-doc-type  = {&TDEDT_Spi_Vnesh}          and
         buf_doc-line.ext-doc-type  = {&TDEDT_Ras_Vnesh_Kass}     and
         buf_doc-line.ext-doc-type  = {&TDEDT_Ras_Vnesh}          and
         buf_doc-line.ext-doc-type  = {&TDEDT_Spi_Prvo}           and
         buf_doc-line.ext-doc-type  = {&TDEDT_Pri_Prvo}           and
         buf_doc-line.ext-doc-type  = {&TDEDT_Vozvrat_Vnesh_Kass} and
         buf_doc-line.ext-doc-type  = {&TDEDT_Vozvrat_Vnesh} ) then next.

    for each buf_parts no-lock
      where buf_parts.out-code  = buf_doc-line.doc-code
        and buf_parts.obj-type  = buf_doc-line.obj-type
        and buf_parts.obj-code  = buf_doc-line.obj-code
        and buf_parts.artic     = buf_doc-line.artic
        and buf_parts.prod-type = buf_doc-line.prod-type
        and buf_parts.prod-code = buf_doc-line.prod-code
      :

      find first temp-goods
        where temp-goods.artic     = buf_parts.artic
          and temp-goods.prod-code = buf_parts.prod-code
          and temp-goods.prod-type = buf_parts.prod-type
          and temp-goods.part-code = buf_parts.part-code
          and temp-goods.in-code   = buf_parts.in-code
        no-error .
      if not available temp-goods then do:
        find first buf_goods no-lock
          where buf_goods.artic     = buf_parts.artic
            and buf_goods.prod-code = buf_parts.prod-code
            and buf_goods.prod-type = buf_parts.prod-type
          .
        create temp-goods .
        assign
          temp-goods.artic     = buf_parts.artic
          temp-goods.prod-code = buf_parts.prod-code
          temp-goods.prod-type = buf_parts.prod-type
          temp-goods.grp-name  = buf_goods.grp-name
          temp-goods.part-code = buf_parts.part-code
          temp-goods.in-code   = buf_parts.in-code
          temp-goods.gtd-code  = buf_parts.cst-code
        .
        if g#gds-engl then assign temp-goods.gds-name = buf_goods.engl-name.
        else               assign temp-goods.gds-name = buf_goods.gds-name.
      end.

      case buf_doc-line.ext-doc-type :
        when {&TDEDT_Pri_Prvo}      or
        when {&TDEDT_Pri_Vnesh}     then
          assign
            temp-goods.p-prih     = temp-goods.p-prih     + buf_parts.fact-qnty
            temp-goods.p-prih-sum = temp-goods.p-prih-sum + (if var-report-r-b = "rubl" then buf_parts.price-rubl else buf_parts.price-base) * buf_parts.fact-qnty
          .
        when {&TDEDT_Spi_Prvo}      or
        when {&TDEDT_Spi_Vnesh}     or
        when {&TDEDT_Ras_Vnesh_VP}  then
          assign
            temp-goods.p-sum1     = temp-goods.p-sum1     + buf_parts.fact-qnty
            temp-goods.p-sum1-sum = temp-goods.p-sum1-sum + (if var-report-r-b = "rubl" then buf_parts.price-rubl else buf_parts.price-base) * buf_parts.fact-qnty
          .
        when {&TDEDT_Ras_Vnesh_Kass}     or
        when {&TDEDT_Ras_Vnesh}     then
          assign
            temp-goods.p-prod     = temp-goods.p-prod     + buf_parts.fact-qnty
            temp-goods.p-prod-sum = temp-goods.p-prod-sum + (if var-report-r-b = "rubl" then buf_parts.price-rubl else buf_parts.price-base) * buf_parts.fact-qnty
          .
        when {&TDEDT_Vozvrat_Vnesh_Kass} or
        when {&TDEDT_Vozvrat_Vnesh} then
          assign
            temp-goods.p-vozv     = temp-goods.p-vozv     + buf_parts.fact-qnty
            temp-goods.p-vozv-sum = temp-goods.p-vozv-sum + (if var-report-r-b = "rubl" then buf_parts.price-rubl else buf_parts.price-base) * buf_parts.fact-qnty
          .
        when {&TDEDT_Inv}      or
        when {&TDEDT_Peresort} then  do:
          if buf_parts.fact-qnty > 0 then
            assign
              temp-goods.p-sum2     = temp-goods.p-sum2     + buf_parts.fact-qnty
              temp-goods.p-sum2-sum = temp-goods.p-sum2-sum + (if var-report-r-b = "rubl" then buf_parts.price-rubl else buf_parts.price-base) * buf_parts.fact-qnty
            .
          else
            assign
              temp-goods.p-sum1     = temp-goods.p-sum1     - buf_parts.fact-qnty
              temp-goods.p-sum1-sum = temp-goods.p-sum1-sum - (if var-report-r-b = "rubl" then buf_parts.price-rubl else buf_parts.price-base) * buf_parts.fact-qnty
            .
        end.
      end.
    end.
  end.


/* $Workfile$ e n d */