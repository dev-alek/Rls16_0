/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Оборот в валюте поставщика обработка одного документа

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/20/06
Author: Bakhtadze Natalya
Creation date: 03/20/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "def" &then
  define {2} temp-table temp-goods no-undo
  FIELD supp-type like ub.parts.supp-type
  FIELD supp-code like ub.parts.supp-code
  FIELD exch-code like ub.parts.exch-code
  FIELD obj-type like ub.parts.obj-type
  FIELD obj-code like ub.parts.obj-code
  FIELD artic like ub.goods.artic
  FIELD prod-type like ub.goods.prod-type
  FIELD prod-code like ub.goods.prod-code
  FIELD in-code like ub.parts.in-code
  FIELD part-code like ub.parts.part-code
  FIELD curr-name like ub.currency.curr-abbr
  FIELD unit like ub.goods.unit-base
  FIELD gds-name like ub.goods.gds-name
  FIELD VAT-PC like ub.parts.vat-pc
  FIELD SLT-PC like ub.parts.slt-pc
  FIELD in-date like ub.trn-doc.fact-date
  FIELD qnty-all like ub.parts.fact-qnty
  FIELD obj-in-type like ub.clients.obj-type
  FIELD obj-in-code like ub.clients.obj-code
  FIELD qnty-in like ub.parts.fact-qnty
  FIELD qnty-out like ub.parts.fact-qnty /* хранится со знаком минус потому что умньшает кол-во на объекте печатать с плюсом*/
  FIELD qnty-rest like ub.parts.fact-qnty /* сколько осталось - не печатается нужно ли ?*/
  FIELD price-cli-in-brutto like ub.parts.price-cli
  FIELD price-cli-in like ub.parts.price-cli
  FIELD vat-type like ub.parts.vat-type
  FIELD slt-type like ub.parts.slt-type
  FIELD price-cli-in-sum as decimal
  FIELD price-cli-out-sum as decimal /* хранится со знаком минус  печатать с плюсом*/
  index pi is UNIQUE PRIMARY
  supp-type
  supp-code
  exch-code
  artic
  prod-type
  prod-code
  in-code
  part-code
  obj-type
  obj-code
  .
&else


FOR  each for-line NO-LOCk WHERE
          for-line.doc-code = doc-num:
 { gbl/doclicod.i recid(for-line) v-gds-code no-error }
  if error-status:error then do:
    next.
  end.

  my-accum = my-accum + 1.
  IF my-accum MODULO 50  = 0 then do:
    run waitfram-show in this-procedure ("Обработано " + string(my-accum) + " партий ").
  end.
  FOR EACH ub.parts NO-LOCK WHERE
          ub.parts.artic = for-line.artic AND
          ub.parts.prod-type = for-line.prod-type AND
          ub.parts.prod-code = for-line.prod-code AND
          ub.parts.out-code = doc-num AND
          ub.parts.obj-type = for-line.obj-type AND
          ub.parts.obj-code = for-line.obj-code :
    first-find = yes.
    FIND FIRST ub.goods No-LOCK WHERE
                ub.goods.artic = for-line.artic AND
                ub.goods.prod-type = for-line.prod-type AND
                ub.goods.prod-code = for-line.prod-code No-ERROR.
    find first buf_parts-attr no-lock where
               buf_parts-attr.in-code = ub.parts.in-code
           AND buf_parts-attr.gds-code = v-gds-code
           AND buf_parts-attr.part-code = ub.parts.part-code no-error .
    if avail buf_parts-attr then do:
      IF buf_parts-attr.is-supp = no /*только партии внешнего прихода*/ then NEXT.
      if not can-find(FIRST cli-list where
                            cli-list.obj-type = buf_parts-attr.supp-type AND
                            cli-list.obj-code = buf_parts-attr.supp-code) then NEXT.
      assign
      v-in-code = buf_parts-attr.income-in-code
      v-part-code = buf_parts-attr.income-part-code
      v-supp-type = buf_parts-attr.supp-type
      v-supp-code = buf_parts-attr.supp-code
      v-inv       = (buf_parts-attr.ext-doc-type = {&TDEDT_Inv} or buf_parts-attr.ext-doc-type = {&TDEDT_Peresort})
      .
    end.
    else do:
      IF ub.parts.is-supp = no /*только партии внешнего прихода*/ then NEXT.
      if not can-find(FIRST cli-list where
                            cli-list.obj-type = ub.parts.supp-type AND
                            cli-list.obj-code = ub.parts.supp-code) then NEXT.
      assign
      v-in-code = ub.parts.in-code
      v-part-code = ub.parts.part-code
      v-supp-type = buf_parts-attr.supp-type
      v-supp-code = buf_parts-attr.supp-code
      v-inv       = ub.parts.doc-type = {&inventory}
      .
    end.

    /*если не приход то*/
    if v-in-code <> ub.parts.out-code then do:
      /*веточка для двуедизма*/
      find first ub.units No-LOCK WHERE
                  ub.units.unit-name = ub.goods.unit-base NO-ERROR.
      if avail ub.units and lookup({&twounit}, ub.units.type ) > 0
      then do:
        assign
        is-twounit = yes
        /*символьный номер приходной партии должен начинаться также как кусок перед # у расходной*/
        for-part-code = substr(v-part-code, 1, index(v-part-code, {&part-split}) - 1)
        .
        /**/
      end.
      else do:
        assign
        is-twounit = no
        for-part-code = v-part-code
        .
      end.
    end.
    else do:  /*первый встретившийся как раз внешний приход чего же искать зря*/
      assign
      is-twounit = no
      FOR-PART-CODE = v-PART-CODE.
    end.
    /* сведения о данном приходе отражали ли мы на каком-нибудь объекте?  */
    FIND FIRST b-temp-goods WHERE
              b-temp-goods.artic = for-line.artic AND
              b-temp-goods.prod-type = for-line.prod-type AND
              b-temp-goods.prod-code = for-line.prod-code AND
              b-temp-goods.supp-type = v-supp-type AND
              b-temp-goods.supp-code = v-supp-code AND
              b-temp-goods.in-code = v-in-code AND
              b-temp-goods.part-code = FOR-part-code AND
              b-temp-goods.obj-type = all-obj-type AND
              b-temp-goods.obj-code = all-obj-code
              No-error.
    IF not avail b-temp-goods then do:
      /* не отражали - надо найти цену прихода  */
      if avail buf_parts-attr then do:
        if ( (pcurr-code <> ?) AND (buf_parts-attr.exch-code <> pcurr-code) ) then NEXT.
        FIND FIRST ub.currency No-LOCK WHERE
                  ub.currency.curr-code = buf_parts-attr.exch-code No-ERROR.
        assign
        v-price-cli = buf_parts-attr.price-cli
        v-cli-base-rate = buf_parts-attr.cli-base-rate
        v-obj-type = buf_parts-attr.obj-type
        v-obj-code = buf_parts-attr.obj-code
        v-vat-type = buf_parts-attr.vat-type
        v-slt-type = buf_parts-attr.slt-type
        v-vat-pc   = buf_parts-attr.vat-pc
        v-slt-pc   = buf_parts-attr.slt-pc
        v-fact-qnty = buf_parts-attr.fact-qnty
        v-qnty      = buf_parts-attr.doc-qnty
        v-exch-code = buf_parts-attr.exch-code
        v-fact-date = buf_parts-attr.fact-date
        .
        { cus/r-obvat.i calc buf_parts-attr. loc- buf_parts-attr. }
      end.
      else do: /*нет атрибутов партий*/
        FIND FIRST ub.trn-doc No-LOCK WHERE
                  ub.trn-doc.doc-code = v-in-code No-ERROR.
        if not avail ub.trn-doc then do:
          message "Не найдена ПН " v-in-code
          view-as alert-box WARNING.
          NEXT.
        end.
        assign
        v-exch-code = ub.trn-doc.exch-code
        v-fact-date = ub.trn-doc.fact-date
        .
        if ( (pcurr-code <> ?) AND (ub.trn-doc.exch-code <> pcurr-code) ) then NEXT.
        FIND FIRST ub.currency No-LOCK WHERE
                  ub.currency.curr-code = ub.trn-doc.exch-code No-ERROR.
        /*если не приход то*/
        if v-in-code <> ub.parts.out-code then do:
          FIND FIRST in-parts No-LOCK WHERE
                    in-parts.artic = ub.parts.artic AND
                    in-parts.prod-type = ub.parts.prod-type AND
                    in-parts.prod-code = ub.parts.prod-code AND
                    in-parts.supp-type = v-supp-type AND
                    in-parts.supp-code = v-supp-code AND
                    in-parts.in-code = ub.trn-doc.doc-code AND
                    in-parts.out-code = ub.trn-doc.doc-code AND
                    in-parts.part-code = for-part-code
                    No-ERROR.
          IF not avail in-parts then do:
            message "Не найдена партия по ПН " v-in-code
            ub.parts.artic ub.parts.prod-type ub.parts.prod-code
            "Поставщик" v-supp-type v-supp-code
            "Код партии" for-part-code
            view-as alert-box WARNING.
            NEXT.
          END.
        end.
        else do:  /*первый встретившийся как раз внешний приход чего же искать зря*/
          find first in-parts No-LOCK WHERE
                      recid(in-parts) = recid(ub.parts) No-ERROR.
        end.

        { cus/r-obvat.i calc in-parts. loc- ub.trn-doc. }
        assign
        v-price-cli = in-parts.price-cli
        v-cli-base-rate = in-parts.cli-base-rate
        v-obj-type = in-parts.obj-type
        v-obj-code = in-parts.obj-code
        v-vat-type = in-parts.vat-type
        v-slt-type = in-parts.slt-type
        v-vat-pc   = in-parts.vat-pc
        v-slt-pc   = in-parts.slt-pc
        v-fact-qnty = in-parts.fact-qnty
        v-qnty = in-parts.qnty
        .
      end.  /*нет атрибутов партий*/


      create temp-goods.
      assign
      temp-goods.supp-type = v-supp-type
      temp-goods.supp-code = v-supp-code
      temp-goods.exch-code = v-exch-code
      temp-goods.artic = for-line.artic
      temp-goods.prod-type = for-line.prod-type
      temp-goods.prod-code = for-line.prod-code
      temp-goods.in-code =  v-in-code
      temp-goods.part-code = for-part-code
      temp-goods.obj-code = ub.parts.obj-code
      temp-goods.obj-type = ub.parts.obj-type

      temp-goods.unit = ub.goods.unit-base
      temp-goods.gds-name = ub.goods.gds-name
      temp-goods.IN-date =  v-fact-date /*дата прихода*/
      temp-goods.price-cli-in-brutto = v-price-cli / v-cli-base-rate
      temp-goods.price-cli-in = loc-price-cli-netto
      temp-goods.obj-in-type = v-obj-type
      temp-goods.obj-in-code = v-obj-code
      temp-goods.qnty-all = v-fact-qnty
      temp-goods.vat-type = v-vat-type
      temp-goods.slt-type = v-slt-type
      temp-goods.curr-name = (if avail ub.currency then ub.currency.curr-abbr else string(temp-goods.exch-code))
      temp-goods.slt-pc = v-slt-pc
      temp-goods.vat-pc = v-vat-pc
      .
      if all-obj-code = 0 then do: /* в выборке несколько объектов - сделаем общую запись*/
        create b-temp-goods.
        assign
        b-temp-goods.supp-type = v-supp-type
        b-temp-goods.supp-code = v-supp-code
        b-temp-goods.exch-code = v-exch-code
        b-temp-goods.artic = for-line.artic
        b-temp-goods.prod-type = for-line.prod-type
        b-temp-goods.prod-code = for-line.prod-code
        b-temp-goods.in-code =  v-in-code
        b-temp-goods.part-code = for-part-code
        b-temp-goods.obj-code = all-obj-code
        b-temp-goods.obj-type = all-obj-type

        b-temp-goods.unit = ub.goods.unit-base
        b-temp-goods.gds-name = ub.goods.gds-name
        b-temp-goods.IN-date =  v-fact-date /*дата прихода*/
        b-temp-goods.price-cli-in-brutto = v-price-cli / v-cli-base-rate
        b-temp-goods.price-cli-in = loc-price-cli-netto
        b-temp-goods.qnty-all = v-qnty
        b-temp-goods.obj-in-type = v-obj-type
        b-temp-goods.obj-in-code = v-obj-code
        b-temp-goods.qnty-rest = v-qnty
        b-temp-goods.vat-type = v-vat-type
        b-temp-goods.slt-type = v-slt-type
        b-temp-goods.curr-name = (if avail ub.currency then ub.currency.curr-abbr else string(b-temp-goods.exch-code))
        b-temp-goods.slt-pc = v-slt-pc
        b-temp-goods.vat-pc = v-vat-pc
        .
      end.
    END. /*if not avail b-temp-goods*/
    else do:
      first-find = no.
      /* для какого-то объекта партия уже у нас засветилась*/
      /* ЭТО МОЖЕТ ТОЛЬКО когда по многим объектам -  all-obj-code = 0*/
      if NOT (b-temp-goods.obj-type = obj-list.obj-type AND
              b-temp-goods.obj-code = obj-list.obj-code) then do:
        /* это было на другом объекте */
        /* а на текущем тоже было ? */
        FIND FIRST temp-goods WHERE
              temp-goods.supp-type = v-supp-type AND
              temp-goods.supp-code = v-supp-code AND
              temp-goods.artic = for-line.artic AND
              temp-goods.prod-type = for-line.prod-type AND
              temp-goods.prod-code = for-line.prod-code AND
              temp-goods.in-code = v-in-code AND
              temp-goods.part-code = for-part-code AND
              temp-goods.obj-type = obj-list.obj-type AND
              temp-goods.obj-code = obj-list.obj-code
              No-error.
        if not avail temp-goods then do:
          create temp-goods.
          buffer-copy b-temp-goods
          except
          b-temp-goods.obj-type
          b-temp-goods.obj-code
          b-temp-goods.qnty-in
          b-temp-goods.qnty-out
          b-temp-goods.price-cli-in-sum
          b-temp-goods.price-cli-out-sum
          to temp-goods
          assign
          temp-goods.obj-type = obj-list.obj-type
          temp-goods.obj-code = obj-list.obj-code
          .
        end. /* not avail temp-goods */
      end. /*  if NOT (b-temp-goods.obj-type = obj-list.obj-ty  ... */
      /*else do:
        FIND FIRST temp-goods WHERE
                  recid(temp-goods) = recid(b-temp-goods) no-error.
      end.*/
    end.  /* avail b-temp-goods */
    assign
    prt-qnty =  is-out * ub.parts.fact-qnty
    v-real-is-prihod = (if v-inv
                        then (if prt-qnty >=0
                              then yes
                              else no)
                        else is-prihod)
    v-real-is-rashod = (if v-inv
                        then (if prt-qnty < 0
                              then yes
                              else no)
                        else is-rashod)
    .
    if all-obj-code = 0 or first-find then do:
      assign
      temp-goods.qnty-in = temp-goods.qnty-in +  (if v-real-is-prihod then prt-qnty else 0)
      temp-goods.qnty-out = temp-goods.qnty-out +  (if v-real-is-rashod then prt-qnty else 0)
      temp-goods.price-cli-in-sum = temp-goods.price-cli-in-sum +
                                    (if v-real-is-prihod
                                    then temp-goods.price-cli-in * prt-qnty
                                    else 0)
      temp-goods.price-cli-out-sum = temp-goods.price-cli-out-sum +
                                    (if v-real-is-rashod
                                    then temp-goods.price-cli-in * prt-qnty
                                    else 0)
      .
    end.
    if all-obj-code = 0 or not first-find then do:
      assign
      b-temp-goods.qnty-in = b-temp-goods.qnty-in +  (if v-real-is-prihod then prt-qnty else 0)
      b-temp-goods.qnty-out = b-temp-goods.qnty-out +  (if v-real-is-rashod then prt-qnty else 0)
      b-temp-goods.price-cli-in-sum = b-temp-goods.price-cli-in-sum +
                                    (if v-real-is-prihod
                                    then b-temp-goods.price-cli-in * prt-qnty
                                    else 0)
      b-temp-goods.price-cli-out-sum = b-temp-goods.price-cli-out-sum +
                                    (if v-real-is-rashod
                                    then b-temp-goods.price-cli-in * prt-qnty
                                    else 0)
      b-temp-goods.qnty-rest = b-temp-goods.qnty-rest + prt-qnty
      .
    end.
  END. /*FOR EACH parts*/
END. /*FOR EACH for-line*/
&endif
/* $Workfile$ e n d */