/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

ќтчет по продажам ниже учетной цены

јвтор: ƒемин јлексей —ергеевич
ƒата создани€: 03/22/06
Author: Alexey Demin
Creation date: 03/22/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


   /* 1-заказ, 2-прих. офис, 3-прих.отлож, 4-прих маг., 5-расх маг., 6-факт остат, 7-реал.,8-реал.,9-сред,10-инвент */

  for each buf_obj-list :  /* приходный блок */
    /* считаем заказы */
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
      if buf_trn-doc.doc-date < x-date-start or buf_trn-doc.doc-date > x-date-end or buf_trn-doc.doc-date = ?  or buf_trn-doc.flag_ <> yes or buf_trn-doc.internal = yes then next .

      find first temp-value
        where temp-value.artic     = buf_gds-obj.artic
          and temp-value.prod-type = buf_gds-obj.prod-type
          and temp-value.prod-code = buf_gds-obj.prod-code
          and temp-value.data      = buf_trn-doc.doc-date
          and temp-value.obj-type  = buf_obj-list.obj-type
          and temp-value.obj-code  = buf_obj-list.obj-code
          and temp-value.type      = 1
        no-error .
      if available temp-value then do: /* суммируем */
        assign
          temp-value.qnty  = temp-value.qnty + buf_doc-line.fact-qnty
        .
        if x-SET_val_TYPE = 1 then do: /* надо пересчитывать в р_у_бли по курсу */
          assign temp-value.sum = temp-value.sum + buf_doc-line.fact-qnty * buf_doc-line.price-cli * v-base-rate-z / v-base-scale-z .
        end.
        else assign temp-value.sum   = temp-value.sum + buf_doc-line.fact-qnty * buf_doc-line.price-base .
      end.
      else do:
        create temp-value .
        assign
          temp-value.type      = 1
          temp-value.obj-type  = buf_obj-list.obj-type
          temp-value.obj-code  = buf_obj-list.obj-code
          temp-value.data      = buf_trn-doc.doc-date
          temp-value.qnty      = buf_doc-line.fact-qnty
          temp-value.sum       = temp-value.qnty * buf_doc-line.price-cli
          temp-value.prod-type = buf_gds-obj.prod-type
          temp-value.prod-code = buf_gds-obj.prod-code
          temp-value.artic     = buf_gds-obj.artic
        .
         if x-SET_val_TYPE = 1 then do: /* надо пересчитывать в р_у_бли по курсу */
          assign temp-value.sum = temp-value.sum * v-base-rate-z / v-base-scale-z .
        end.
      end.
    end.

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
      :
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code  = buf_doc-line.doc-code
      .
      if buf_trn-doc.cli-type = {&shop} then do: /* приходы из магазинов */
        find first temp-value
          where temp-value.artic     = buf_gds-obj.artic
            and temp-value.prod-type = buf_gds-obj.prod-type
            and temp-value.prod-code = buf_gds-obj.prod-code
/*          and temp-value.data      = buf_trn-doc.fact-date*/
            and temp-value.obj-type  = buf_obj-list.obj-type
            and temp-value.obj-code  = buf_obj-list.obj-code
            and temp-value.type      = 4
          no-error .
        if available temp-value then do: /* суммируем */
          assign
            temp-value.qnty  = temp-value.qnty + buf_doc-line.fact-qnty
            temp-value.sum   = temp-value.sum  + buf_doc-line.fact-qnty * temp-BenetTov.sum-beg
          .
/*          if x-SET_val_TYPE = 2 then do: /* надо пересчитывать в р_у_бли по курсу */*/
/*            assign temp-value.sum = temp-value.sum + buf_doc-line.fact-qnty * temp-BenetTov.sum-prov .*/
/*          end.*/
/*          else assign temp-value.sum   = temp-value.sum + buf_doc-line.fact-qnty * buf_doc-line.price-rubl .*/
        end.
        else do:
          create temp-value .
          assign
            temp-value.type      = 4
            temp-value.obj-type  = buf_obj-list.obj-type
            temp-value.obj-code  = buf_obj-list.obj-code
            temp-value.data      = buf_trn-doc.fact-date
            temp-value.qnty      = buf_doc-line.fact-qnty
            temp-value.sum       = buf_doc-line.fact-qnty * temp-BenetTov.sum-beg
            temp-value.prod-type = buf_gds-obj.prod-type
            temp-value.prod-code = buf_gds-obj.prod-code
            temp-value.artic     = buf_gds-obj.artic
          .
/*          if x-SET_val_TYPE = 2 then do: /* надо пересчитывать в  р_у_бли по курсу */*/
/*            assign temp-value.sum = buf_doc-line.fact-qnty * temp-BenetTov.sum-prov .*/
/*          end.*/
        end.
      end.
      else do:
        if buf_trn-doc.cli-type = {&stock} then do: /* приходы со складов */
          if buf_trn-doc.cli-code = 2 then do: /* приход со склада офис  */
            find first temp-value
              where temp-value.artic     = buf_gds-obj.artic
                and temp-value.prod-type = buf_gds-obj.prod-type
                and temp-value.prod-code = buf_gds-obj.prod-code
                and temp-value.data      = buf_trn-doc.fact-date
                and temp-value.obj-type  = buf_obj-list.obj-type
                and temp-value.obj-code  = buf_obj-list.obj-code
                and temp-value.type      = 2
            no-error .
            if available temp-value then do: /* суммируем */
              assign
                temp-value.qnty  = temp-value.qnty + buf_doc-line.fact-qnty
                temp-value.sum = temp-value.sum + buf_doc-line.fact-qnty * temp-BenetTov.sum-beg
              .
/*              if x-SET_val_TYPE = 2 then do: /* надо пересчитывать в р_у_бли по курсу */*/
/*                assign temp-value.sum = temp-value.sum + buf_doc-line.fact-qnty * temp-BenetTov.sum-prov .*/
/*              end.*/
/*              else assign temp-value.sum   = temp-value.sum + buf_doc-line.fact-qnty * buf_doc-line.price-rubl .*/
            end.
            else do:
              create temp-value .
              assign
                temp-value.type      = 2
                temp-value.obj-type  = buf_obj-list.obj-type
                temp-value.obj-code  = buf_obj-list.obj-code
                temp-value.data      = buf_trn-doc.fact-date
                temp-value.qnty      = buf_doc-line.fact-qnty
                temp-value.sum       = buf_doc-line.fact-qnty * temp-BenetTov.sum-beg
                temp-value.prod-type = buf_gds-obj.prod-type
                temp-value.prod-code = buf_gds-obj.prod-code
                temp-value.artic     = buf_gds-obj.artic
              .
/*              if x-SET_val_TYPE = 2 then do: /* надо пересчитывать в р_у_бли по курсу */*/
/*                assign temp-value.sum = buf_doc-line.fact-qnty * temp-BenetTov.sum-prov .*/
/*              end.*/
            end.
          end.
          else if buf_trn-doc.cli-code = 6 then do: /* приход со склада отложка  */
            find first temp-value
              where temp-value.artic     = buf_gds-obj.artic
                and temp-value.prod-type = buf_gds-obj.prod-type
                and temp-value.prod-code = buf_gds-obj.prod-code
/*          and temp-value.data      = buf_trn-doc.fact-date*/
                and temp-value.obj-type  = buf_obj-list.obj-type
                and temp-value.obj-code  = buf_obj-list.obj-code
                and temp-value.type      = 3
              no-error .
            if available temp-value then do: /* суммируем */
              assign
                temp-value.qnty = temp-value.qnty + buf_doc-line.fact-qnty
                temp-value.sum  = temp-value.sum  + buf_doc-line.fact-qnty * temp-BenetTov.sum-beg
              .
/*              if x-SET_val_TYPE = 2 then do: /* надо пересчитывать в р_у_бли по курсу */*/
/*                assign temp-value.sum = temp-value.sum + buf_doc-line.fact-qnty * temp-BenetTov.sum-prov .*/
/*              end.*/
/*              else assign temp-value.sum   = temp-value.sum + buf_doc-line.fact-qnty * buf_doc-line.price-rubl .*/
            end.
            else do:
              create temp-value .
              assign
                temp-value.type      = 3
                temp-value.obj-type  = buf_obj-list.obj-type
                temp-value.obj-code  = buf_obj-list.obj-code
                temp-value.data      = buf_trn-doc.fact-date
                temp-value.qnty      = buf_doc-line.fact-qnty
                temp-value.sum       = buf_doc-line.fact-qnty * temp-BenetTov.sum-beg
                temp-value.prod-type = buf_gds-obj.prod-type
                temp-value.prod-code = buf_gds-obj.prod-code
                temp-value.artic     = buf_gds-obj.artic
              .
/*              if x-SET_val_TYPE = 2 then do: /* надо пересчитывать в р_у_бли по курсу */*/
/*                assign temp-value.sum = buf_doc-line.fact-qnty * temp-BenetTov.sum-prov .*/
/*              end.*/
            end.
          end.
        end.
      end.
    end.

  end.

/* ******************************************************************************** */
  find first temp-value no-lock
    where temp-value.prod-type    = buf_gds-obj.prod-type
      and temp-value.prod-code    = buf_gds-obj.prod-code
      and temp-value.artic        = buf_gds-obj.artic
    no-error .
  if not available temp-value then do: /* а не было приходов и заказов - удал€ем */
    delete temp-BenetTov .
    next .
  end.
/* ******************************************************************************** */

  for each buf_obj-list :  /* расходный блок */
    /* расход перем на магазины */
    for each buf_doc-line no-lock
      where buf_doc-line.obj-type     = buf_obj-list.obj-type
        and buf_doc-line.obj-code     = buf_obj-list.obj-code
        and buf_doc-line.prod-type    = buf_gds-obj.prod-type
        and buf_doc-line.prod-code    = buf_gds-obj.prod-code
        and buf_doc-line.artic        = buf_gds-obj.artic
        and buf_doc-line.ext-doc-type = {&TDEDT_Ras_Perem}
        and buf_doc-line.status_      = {&fact}
        and buf_doc-line.fact-order   >= v-fact-order-start
        and buf_doc-line.fact-order   <  v-fact-order-end
      :
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code  = buf_doc-line.doc-code
      .
      if buf_trn-doc.cli-type = {&shop} then do: /* расходы на магазины */
        find first temp-value
          where temp-value.artic     = buf_gds-obj.artic
            and temp-value.prod-type = buf_gds-obj.prod-type
            and temp-value.prod-code = buf_gds-obj.prod-code
/*          and temp-value.data      = buf_trn-doc.fact-date*/
            and temp-value.obj-type  = buf_obj-list.obj-type
            and temp-value.obj-code  = buf_obj-list.obj-code
            and temp-value.type      = 5
          no-error .
        if available temp-value then do: /* суммируем */
          assign
            temp-value.qnty = temp-value.qnty + buf_doc-line.fact-qnty
            temp-value.sum  = temp-value.sum  + buf_doc-line.fact-qnty * temp-BenetTov.sum-beg
          .
/*          if x-SET_val_TYPE = 2 then do: /* надо пересчитывать в р_у_бли по курсу */*/
/*            assign temp-value.sum = temp-value.sum + buf_doc-line.fact-qnty * temp-BenetTov.sum-prov .*/
/*          end.*/
/*          else assign temp-value.sum   = temp-value.sum + buf_doc-line.fact-qnty * buf_doc-line.price-rubl .*/
        end.
        else do:
          create temp-value .
          assign
            temp-value.type      = 5
            temp-value.obj-type  = buf_obj-list.obj-type
            temp-value.obj-code  = buf_obj-list.obj-code
            temp-value.data      = buf_trn-doc.fact-date
            temp-value.qnty      = buf_doc-line.fact-qnty
            temp-value.sum       = buf_doc-line.fact-qnty * temp-BenetTov.sum-beg
            temp-value.prod-type = buf_gds-obj.prod-type
            temp-value.prod-code = buf_gds-obj.prod-code
            temp-value.artic     = buf_gds-obj.artic
          .
/*          if x-SET_val_TYPE = 2 then do: /* надо пересчитывать в р_у_бли по курсу */*/
/*            assign temp-value.sum = buf_doc-line.fact-qnty * temp-BenetTov.sum-prov .*/
/*          end.*/
        end.
      end.
    end.

    /* нужны остатки на конец периода отчета в прод. ценах */
    if use-column1[12] = yes then do:
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_obj-list.obj-type
          and buf_stk-line.obj-code  = buf_obj-list.obj-code
          and buf_stk-line.artic     = buf_goods.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = {&arh-crsa}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-end
        use-index category no-error .

      if available buf_stk-line then do:
        create temp-value .
        assign
          temp-value.type      = 6
          temp-value.obj-type  = buf_obj-list.obj-type
          temp-value.obj-code  = buf_obj-list.obj-code
          temp-value.qnty      = buf_stk-line.fact-qnty
          temp-value.sum       = buf_stk-line.fact-qnty * temp-BenetTov.sum-beg
          temp-value.prod-type = buf_gds-obj.prod-type
          temp-value.prod-code = buf_gds-obj.prod-code
          temp-value.artic     = buf_gds-obj.artic
          temp-value.data      = x-date-end
        .
/*        if x-SET_val_TYPE = 2 then do: /* надо пересчитывать в р_у_бли по курсу */*/
/*          assign temp-value.sum = temp-BenetTov.sum-prov * buf_stk-line.fact-qnty .*/
/*        end.*/
      end.
    end.

    /* реализаци€ за период отчета */
    if use-column1[13] = yes then do:
      create temp-value .
      assign
        temp-value.type      = 7
        temp-value.obj-type  = buf_obj-list.obj-type
        temp-value.obj-code  = buf_obj-list.obj-code
        temp-value.data      = x-date-start
        temp-value.prod-type = buf_gds-obj.prod-type
        temp-value.prod-code = buf_gds-obj.prod-code
        temp-value.artic     = buf_gds-obj.artic
      .
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_obj-list.obj-type
          and buf_stk-line.obj-code  = buf_obj-list.obj-code
          and buf_stk-line.artic     = buf_goods.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = {&arh-sadt} + {&TDEDT_Ras_Vnesh_Kass}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-end
        use-index category no-error .

      if available buf_stk-line then do:
        assign
          temp-value.qnty = - buf_stk-line.fact-qnty
          temp-value.sum  = - buf_stk-line.sum-rubl
        .
      end.

      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_obj-list.obj-type
          and buf_stk-line.obj-code  = buf_obj-list.obj-code
          and buf_stk-line.artic     = buf_goods.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = {&arh-sadt} + {&TDEDT_Ras_Vnesh_Kass}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= v-fact-order-start
        use-index category no-error .

      if available buf_stk-line then do:
        assign
          temp-value.qnty = temp-value.qnty + buf_stk-line.fact-qnty
          temp-value.sum = temp-value.sum + buf_stk-line.sum-rubl
        .
      end.
      /* вычитаем возврат */
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_obj-list.obj-type
          and buf_stk-line.obj-code  = buf_obj-list.obj-code
          and buf_stk-line.artic     = buf_goods.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = {&arh-sadt} + {&TDEDT_Vozvrat_Vnesh_Kass}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-end
        use-index category no-error .

      if available buf_stk-line then do:
        assign
          temp-value.qnty = temp-value.qnty - buf_stk-line.fact-qnty
          temp-value.sum = temp-value.sum - buf_stk-line.sum-rubl
        .
      end.

      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_obj-list.obj-type
          and buf_stk-line.obj-code  = buf_obj-list.obj-code
          and buf_stk-line.artic     = buf_goods.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = {&arh-sadt} + {&TDEDT_Vozvrat_Vnesh_Kass}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= v-fact-order-start
        use-index category no-error .

      if available buf_stk-line then do:
        assign
          temp-value.qnty = temp-value.qnty + buf_stk-line.fact-qnty
          temp-value.sum = temp-value.sum + buf_stk-line.sum-rubl
         .
      end.
      if x-SET_val_TYPE = 2 then do: /* надо пересчитывать в валюту по курсу */
        assign temp-value.sum = temp-value.sum * v-base-scale-z / v-base-rate-z  .
      end.
    end.

    /* реализаци€ за период реализации  */
    if use-column1[14] = yes then do:
      create temp-value .
      assign
        temp-value.type      = 8
        temp-value.obj-type  = buf_obj-list.obj-type
        temp-value.obj-code  = buf_obj-list.obj-code
        temp-value.data      = x-date-start1
        temp-value.prod-type = buf_gds-obj.prod-type
        temp-value.prod-code = buf_gds-obj.prod-code
        temp-value.artic     = buf_gds-obj.artic
      .
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_obj-list.obj-type
          and buf_stk-line.obj-code  = buf_obj-list.obj-code
          and buf_stk-line.artic     = buf_goods.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = {&arh-sadt} + {&TDEDT_Ras_Vnesh_Kass}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-end1
        use-index category no-error .

      if available buf_stk-line then do:
        assign
          temp-value.qnty = - buf_stk-line.fact-qnty
          temp-value.sum = - buf_stk-line.sum-rubl
        .
      end.

      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_obj-list.obj-type
          and buf_stk-line.obj-code  = buf_obj-list.obj-code
          and buf_stk-line.artic     = buf_goods.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = {&arh-sadt} + {&TDEDT_Ras_Vnesh_Kass}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= v-fact-order-start1
        use-index category no-error .

      if available buf_stk-line then do:
        assign
          temp-value.qnty = temp-value.qnty + buf_stk-line.fact-qnty
          temp-value.sum = temp-value.sum + buf_stk-line.sum-rubl
        .
      end.
      /* вычитаем возврат */
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_obj-list.obj-type
          and buf_stk-line.obj-code  = buf_obj-list.obj-code
          and buf_stk-line.artic     = buf_goods.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = {&arh-sadt} + {&TDEDT_Vozvrat_Vnesh_Kass}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-end1
        use-index category no-error .

      if available buf_stk-line then do:
        assign
          temp-value.qnty = temp-value.qnty - buf_stk-line.fact-qnty
          temp-value.sum = temp-value.sum - buf_stk-line.sum-rubl
        .
      end.

      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_obj-list.obj-type
          and buf_stk-line.obj-code  = buf_obj-list.obj-code
          and buf_stk-line.artic     = buf_goods.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = {&arh-sadt} + {&TDEDT_Vozvrat_Vnesh_Kass}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= v-fact-order-start1
        use-index category no-error .

      if available buf_stk-line then do:
        assign
          temp-value.qnty = temp-value.qnty + buf_stk-line.fact-qnty
          temp-value.sum = temp-value.sum + buf_stk-line.sum-rubl
        .
      end.
      if x-SET_val_TYPE = 2 then do: /* надо пересчитывать в валюту по курсу */
        assign temp-value.sum = temp-value.sum * v-base-scale-z / v-base-rate-z  .
      end.
    end.


    /* реализаци€ за период реализации 1 недел€ */
    if use-column1[15] = yes then do:
      for each temp-month :
        create temp-value .
        assign
          temp-value.type      = 10 + temp-month.ind
          temp-value.obj-type  = buf_obj-list.obj-type
          temp-value.obj-code  = buf_obj-list.obj-code
          temp-value.data      = temp-month.dat-beg
          temp-value.prod-type = buf_gds-obj.prod-type
          temp-value.prod-code = buf_gds-obj.prod-code
          temp-value.artic     = buf_gds-obj.artic
        .
        find last buf_stk-line no-lock
          where buf_stk-line.obj-type  = buf_obj-list.obj-type
            and buf_stk-line.obj-code  = buf_obj-list.obj-code
            and buf_stk-line.artic     = buf_goods.artic
            and buf_stk-line.prod-type = buf_gds-obj.prod-type
            and buf_stk-line.prod-code = buf_gds-obj.prod-code
            and buf_stk-line.sum-type  = {&arh-sadt} + {&TDEDT_Ras_Vnesh_Kass}
            and buf_stk-line.cat-id    = '##,##'
            and buf_stk-line.fact-order < temp-month.v-fact-order-end
          use-index category no-error .

        if available buf_stk-line then do:
          assign
            temp-value.qnty = - buf_stk-line.fact-qnty
            temp-value.sum = - buf_stk-line.sum-rubl
          .
        end.

        find last buf_stk-line no-lock
          where buf_stk-line.obj-type  = buf_obj-list.obj-type
            and buf_stk-line.obj-code  = buf_obj-list.obj-code
            and buf_stk-line.artic     = buf_goods.artic
            and buf_stk-line.prod-type = buf_gds-obj.prod-type
            and buf_stk-line.prod-code = buf_gds-obj.prod-code
            and buf_stk-line.sum-type  = {&arh-sadt} + {&TDEDT_Ras_Vnesh_Kass}
            and buf_stk-line.cat-id    = '##,##'
            and buf_stk-line.fact-order <= temp-month.v-fact-order-start
          use-index category no-error .

        if available buf_stk-line then do:
          assign
            temp-value.qnty = temp-value.qnty + buf_stk-line.fact-qnty
            temp-value.sum = temp-value.sum + buf_stk-line.sum-rubl
          .
        end.
        /* вычитаем возврат */
        find last buf_stk-line no-lock
          where buf_stk-line.obj-type  = buf_obj-list.obj-type
            and buf_stk-line.obj-code  = buf_obj-list.obj-code
            and buf_stk-line.artic     = buf_goods.artic
            and buf_stk-line.prod-type = buf_gds-obj.prod-type
            and buf_stk-line.prod-code = buf_gds-obj.prod-code
            and buf_stk-line.sum-type  = {&arh-sadt} + {&TDEDT_Vozvrat_Vnesh_Kass}
            and buf_stk-line.cat-id    = '##,##'
            and buf_stk-line.fact-order < temp-month.v-fact-order-end
          use-index category no-error .

        if available buf_stk-line then do:
          assign
            temp-value.qnty = temp-value.qnty - buf_stk-line.fact-qnty
            temp-value.sum = temp-value.sum - buf_stk-line.sum-rubl
          .
        end.

        find last buf_stk-line no-lock
          where buf_stk-line.obj-type  = buf_obj-list.obj-type
            and buf_stk-line.obj-code  = buf_obj-list.obj-code
            and buf_stk-line.artic     = buf_goods.artic
            and buf_stk-line.prod-type = buf_gds-obj.prod-type
            and buf_stk-line.prod-code = buf_gds-obj.prod-code
            and buf_stk-line.sum-type  = {&arh-sadt} + {&TDEDT_Vozvrat_Vnesh_Kass}
            and buf_stk-line.cat-id    = '##,##'
            and buf_stk-line.fact-order <= temp-month.v-fact-order-start
          use-index category no-error .

        if available buf_stk-line then do:
          assign
            temp-value.qnty = temp-value.qnty + buf_stk-line.fact-qnty
            temp-value.sum = temp-value.sum + buf_stk-line.sum-rubl
          .
        end.
        if x-SET_val_TYPE = 2 then do: /* надо пересчитывать в валюту по курсу */
          assign temp-value.sum = temp-value.sum * v-base-scale-z / v-base-rate-z  .
        end.
      end.
    end.


    /* среднесуточна€  реализаци€ */
    if use-column1[16] = yes then do:
      create temp-value .
      assign
        temp-value.type      = 9
        temp-value.obj-type  = buf_obj-list.obj-type
        temp-value.obj-code  = buf_obj-list.obj-code
        temp-value.data      = x-date-start2
        temp-value.prod-type = buf_gds-obj.prod-type
        temp-value.prod-code = buf_gds-obj.prod-code
        temp-value.artic     = buf_gds-obj.artic
      .
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_obj-list.obj-type
          and buf_stk-line.obj-code  = buf_obj-list.obj-code
          and buf_stk-line.artic     = buf_goods.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = {&arh-sadt} + {&TDEDT_Ras_Vnesh_Kass}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-end2
        use-index category no-error .

      if available buf_stk-line then do:
        assign
          temp-value.qnty = - buf_stk-line.fact-qnty
          temp-value.sum = - buf_stk-line.sum-rubl
        .
      end.

      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_obj-list.obj-type
          and buf_stk-line.obj-code  = buf_obj-list.obj-code
          and buf_stk-line.artic     = buf_goods.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = {&arh-sadt} + {&TDEDT_Ras_Vnesh_Kass}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= v-fact-order-start2
        use-index category no-error .

      if available buf_stk-line then do:
        assign
          temp-value.qnty = temp-value.qnty + buf_stk-line.fact-qnty
          temp-value.sum = temp-value.sum + buf_stk-line.sum-rubl
        .
      end.
      /* вычитаем возврат */
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_obj-list.obj-type
          and buf_stk-line.obj-code  = buf_obj-list.obj-code
          and buf_stk-line.artic     = buf_goods.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = {&arh-sadt} + {&TDEDT_Vozvrat_Vnesh_Kass}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-end2
        use-index category no-error .

      if available buf_stk-line then do:
        assign
          temp-value.qnty = temp-value.qnty - buf_stk-line.fact-qnty
          temp-value.sum = temp-value.sum - buf_stk-line.sum-rubl
        .
      end.

      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_obj-list.obj-type
          and buf_stk-line.obj-code  = buf_obj-list.obj-code
          and buf_stk-line.artic     = buf_goods.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = {&arh-sadt} + {&TDEDT_Vozvrat_Vnesh_Kass}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= v-fact-order-start2
        use-index category no-error .

      if available buf_stk-line then do:
        assign
          temp-value.qnty = temp-value.qnty + buf_stk-line.fact-qnty
          temp-value.sum = temp-value.sum + buf_stk-line.sum-rubl
        .
      end.
      if x-SET_val_TYPE = 2 then do: /* надо пересчитывать в валюту по курсу */
        assign temp-value.sum = temp-value.sum * v-base-scale-z / v-base-rate-z  .
      end.
      /* а теперь делим на кол-во дней */
      assign
        temp-value.sum  = temp-value.sum  / (x-date-end2 - x-date-start2 + 1)
        temp-value.qnty = temp-value.qnty / (x-date-end2 - x-date-start2 + 1)
      .
    end.

    /* инвентаризаци€ */
    if use-column1[18] = yes then do:
      create temp-value .
      assign
        temp-value.type      = 10
        temp-value.obj-type  = buf_obj-list.obj-type
        temp-value.obj-code  = buf_obj-list.obj-code
        temp-value.data      = x-date-start
        temp-value.prod-type = buf_gds-obj.prod-type
        temp-value.prod-code = buf_gds-obj.prod-code
        temp-value.artic     = buf_gds-obj.artic
      .
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_obj-list.obj-type
          and buf_stk-line.obj-code  = buf_obj-list.obj-code
          and buf_stk-line.artic     = buf_goods.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = {&arh-csdt} + {&TDEDT_Inv}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-end
        use-index category no-error .

      if available buf_stk-line then do:
        assign
          temp-value.qnty = buf_stk-line.fact-qnty
          temp-value.sum = buf_stk-line.sum-rubl
        .
      end.

      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_obj-list.obj-type
          and buf_stk-line.obj-code  = buf_obj-list.obj-code
          and buf_stk-line.artic     = buf_goods.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = {&arh-csdt} + {&TDEDT_Inv}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= v-fact-order-start
        use-index category no-error .

      if available buf_stk-line then do:
        assign
          temp-value.qnty = temp-value.qnty - buf_stk-line.fact-qnty
          temp-value.sum = temp-value.sum - buf_stk-line.sum-rubl
        .
      end.

      if x-SET_val_TYPE = 2 then do: /* надо пересчитывать в валюту по курсу */
        assign temp-value.sum = temp-value.sum * v-base-scale-z / v-base-rate-z  .
      end.
    end.

  end.


/* ******************************************************************************** */
  case SortType1 :
    when 1 then  ind = 7 . /* сортировка по кол-ву реализ-ного */
    when 2 then  ind = 1 . /* сортировка по кол-ву заказанного */
    when 3 then  ind = 6 . /* сортировка по кол-ву остатков */
  end.
  for each temp-value
    where temp-value.artic     = temp-BenetTov.artic
      and temp-value.prod-type = temp-BenetTov.prod-type
      and temp-value.prod-code = temp-BenetTov.prod-code
      and temp-value.type      = ind
    :
    assign
      temp-BenetTov.sort-qnty = temp-BenetTov.sort-qnty + temp-value.qnty
    .
  end.
/* ******************************************************************************** */

/* $Workfile$ e n d */