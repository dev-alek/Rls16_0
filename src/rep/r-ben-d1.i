/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет по продажам ниже учетной цены

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

  find first temp-BenetTov
      where temp-BenetTov.artic        = buf_goods.artic
        and temp-BenetTov.prod-type    = buf_goods.prod-type
        and temp-BenetTov.prod-code    = buf_goods.prod-code
    no-error .
  if available temp-BenetTov then next .

  create temp-BenetTov .
  run grplib-get-full-name in this-procedure ( input buf_goods.grp-code,output temp-BenetTov.full-grp-name) .
  if g#gds-engl then assign temp-BenetTov.gds-name = buf_goods.engl-name.
  else               assign temp-BenetTov.gds-name = buf_goods.gds-name.
  assign
    temp-BenetTov.artic     = buf_goods.artic
    temp-BenetTov.prod-type = buf_goods.prod-type
    temp-BenetTov.prod-code = buf_goods.prod-code
    temp-BenetTov.grp-name  = entry ( num-entries( right-trim(buf_goods.grp-name, {&delim-grp}), {&delim-grp} ), buf_goods.grp-name, {&delim-grp} )
    temp-BenetTov.sort-qnty = 0
    temp-BenetTov.sum-prov  = 0
    temp-BenetTov.sum-beg   = 0
    temp-BenetTov.sum-end   = 0
    tmp-fact-order  = 0
    tmp-fact-order1 = 0
    is-zapr = no
  .

  /* считаем цену поставщика */
  for each buf_obj-list :
    for each buf_doc-line no-lock
      where buf_doc-line.obj-type   = buf_obj-list.obj-type
        and buf_doc-line.obj-code   = buf_obj-list.obj-code
        and buf_doc-line.prod-type  = buf_gds-obj.prod-type
        and buf_doc-line.prod-code  = buf_gds-obj.prod-code
        and buf_doc-line.artic      = buf_gds-obj.artic
        and buf_doc-line.status_    = {&inquiry}
      :
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code  = buf_doc-line.doc-code
      .
      assign TypeValCli = buf_trn-doc.exch-code .

      if buf_trn-doc.doc-date < x-date-start or buf_trn-doc.doc-date > x-date-end or buf_trn-doc.doc-date = ?  or buf_trn-doc.flag_ <> yes or buf_trn-doc.internal = yes then next .

      if is-zapr = no or tmp-date-start > buf_trn-doc.doc-date then do:
        assign
          is-zapr = yes
          tmp-date-start = buf_trn-doc.doc-date
          tmp-fact-order = buf_doc-line.fact-order
          temp-BenetTov.sum-prov = buf_doc-line.price-cli
          v-base-rate-z  = buf_trn-doc.exch-rate
          v-base-scale-z = buf_trn-doc.exch-scale
        .
        if x-SET_val_TYPE = 1 then do: /* надо пересчитывать в р_у_бли по курсу */
          assign  temp-BenetTov.sum-prov = temp-BenetTov.sum-prov * v-base-rate-z / v-base-scale-z  .
        end.
      end.
    end.
  end.

  if is-zapr = no then do: /* запросов не было, надо искать в приходах  */
    for each buf_obj-list :
      /* приход со склада офис 2 скл, скада отложка 6 скл и магазинов */
      for each buf_doc-line no-lock
        where buf_doc-line.obj-type     = buf_obj-list.obj-type
          and buf_doc-line.obj-code     = buf_obj-list.obj-code
          and buf_doc-line.prod-type    = buf_gds-obj.prod-type
          and buf_doc-line.prod-code    = buf_gds-obj.prod-code
          and buf_doc-line.artic        = buf_gds-obj.artic
          and buf_doc-line.ext-doc-type = {&TDEDT_Pri_Perem}
          and buf_doc-line.status_      = {&fact}
          and buf_doc-line.fact-order   >= v-fact-order-start
          and buf_doc-line.fact-order   <  v-fact-order-end
          WHILE is-zapr = no
        :
        find first buf_trn-doc no-lock
          where buf_trn-doc.doc-code  = buf_doc-line.doc-code
        .
        if buf_trn-doc.cli-type = {&shop} then do: /* приходы из магазинов */
          if is-zapr = no or tmp-date-start > buf_trn-doc.fact-date then do:
            assign
              is-zapr = yes
              tmp-date-start = buf_trn-doc.fact-date
              tmp-fact-order = buf_doc-line.fact-order
              temp-BenetTov.sum-prov = buf_doc-line.price-cli
            .
          end.
        end.
        else do:
          if buf_trn-doc.cli-type = {&stock} then do: /* приходы со складов */
            if buf_trn-doc.cli-code = 2 or buf_trn-doc.cli-code = 6 then do: /* приход со склада офис и отложка */
              if is-zapr = no or tmp-date-start > buf_trn-doc.fact-date then do:
                assign
                  is-zapr = yes
                  tmp-date-start = buf_trn-doc.fact-date
                  tmp-fact-order = buf_doc-line.fact-order
                  temp-BenetTov.sum-prov = buf_doc-line.price-cli
                .
              end.
            end.
          end.
        end.
      end.
    end.
    /* ищем курс на дату tmp-date-start */
    find last curr-accnt no-lock
      where curr-accnt.curr-code = TypeValCli
        and curr-accnt.exch-date <= tmp-date-start
        use-index pi no-error .
    if available curr-accnt then do:
      assign
        v-base-rate-z  = curr-accnt.exch-rate
        v-base-scale-z = curr-accnt.exch-scale
      .
      if x-SET_val_TYPE = 1 then do: /* надо пересчитывать в р_у_бли по курсу */
        assign  temp-BenetTov.sum-prov = temp-BenetTov.sum-prov * v-base-rate-z / v-base-scale-z  .
      end.
    end.
  end.

  assign
    tmp-fact-order  = 0
    tmp-fact-order1 = 0
  .
  { gbl/gdsbcode.i  buf_goods.gds-code  ?  b-code  no-error }
  /* ищем первую и последнюю розничную цену за период */
  if g#db-num = 0 then do:
    for each buf_obj-list :
      find last price-list no-lock
        where price-list.obj-type  = buf_obj-list.obj-type
          and price-list.obj-code  = buf_obj-list.obj-code
          and price-list.b-code    = b-code
          and price-list.fact-order < v-fact-order-end
        use-index fact-close no-error .
      if available price-list then do:
        find first price-doc no-lock
          where price-doc.doc-num  = price-list.doc-num
        .
        if tmp-fact-order1 = 0 or tmp-fact-order1 < price-list.fact-order then do:
          assign
            tmp-date-end    = price-doc.fact-date
            tmp-fact-order1 = price-list.fact-order
            temp-BenetTov.sum-end = price-list.price-sale
          .
        end .
      end .
    end .

    find first price-list no-lock
      where price-list.obj-type  = {&stock}
        and price-list.obj-code  = 2
        and price-list.b-code    = b-code
        and price-list.fact-order >= v-fact-order-start
      use-index fact-close no-error .
    if available price-list then do:
      find first price-doc no-lock
        where price-doc.doc-num  = price-list.doc-num
      .
      assign temp-BenetTov.sum-beg = price-list.price-sale .
    end .
    else do:
      find last price-list no-lock
        where price-list.obj-type  = {&stock}
          and price-list.obj-code  = 2
          and price-list.b-code    = b-code
        use-index fact-close no-error .
      if available price-list then assign temp-BenetTov.sum-beg = price-list.price-sale .
    end.
  end.
  else do:
   for each buf_obj-list :
    find last price-list no-lock
      where price-list.obj-type  = buf_obj-list.obj-type
        and price-list.obj-code  = buf_obj-list.obj-code
        and price-list.b-code    = b-code
        and price-list.fact-order < v-fact-order-end
      use-index fact-close no-error .
    if available price-list then do:
      find first price-doc no-lock
        where price-doc.doc-num  = price-list.doc-num
      .
      if tmp-fact-order1 = 0 or tmp-fact-order1 < price-list.fact-order then do:
        assign
          tmp-date-end    = price-doc.fact-date
          tmp-fact-order1 = price-list.fact-order
          temp-BenetTov.sum-end = price-list.price-sale
        .
      end .
    end .
    find first price-list no-lock
      where price-list.obj-type  = buf_obj-list.obj-type
        and price-list.obj-code  = buf_obj-list.obj-code
        and price-list.b-code    = b-code
        and price-list.fact-order >= v-fact-order-start
      use-index fact-close no-error .
    if available price-list then do:
      find first price-doc no-lock
        where price-doc.doc-num  = price-list.doc-num
      .
      if tmp-fact-order = 0 or tmp-fact-order > price-list.fact-order then do:
        assign
          tmp-date-start  = price-doc.fact-date
          tmp-fact-order  = price-list.fact-order
          temp-BenetTov.sum-beg = price-list.price-sale
        .
      end .
    end .
   end .
  end .

  if x-SET_val_TYPE = 2 then do: /* надо пересчитывать в валюту по курсу */
    /* ищем курс на дату tmp-date-start */
    find last curr-accnt no-lock
      where curr-accnt.curr-code = TypeValCli
        and curr-accnt.exch-date <= tmp-date-start
        use-index pi no-error .
    if available curr-accnt then do:
      assign temp-BenetTov.sum-beg = temp-BenetTov.sum-beg * curr-accnt.exch-scale / curr-accnt.exch-rate .
    end.
    /* ищем курс на дату tmp-date-end */
    find last curr-accnt no-lock
      where curr-accnt.curr-code = TypeValCli
        and curr-accnt.exch-date <= tmp-date-end
        use-index pi no-error .
    if available curr-accnt then do:
      assign temp-BenetTov.sum-end = temp-BenetTov.sum-end * curr-accnt.exch-scale / curr-accnt.exch-rate .
    end.
  end.

/* $Workfile$ e n d */