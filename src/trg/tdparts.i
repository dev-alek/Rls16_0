/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка архивных партий документа

Автор: Чернова Светлана Александровна
Дата создания: 05/08/07
Author: Svetlana Chernova
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 01/20/03

Вычисляется на какое значение изменилась учетная цена товара
Вычисляется как изменились остатки по поставщикам

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure tdparts :

  define input parameter  p-trn-doc-host-code   like ub.trn-doc.host-code   no-undo .
  define input parameter  p-trn-doc-doc-type    like ub.trn-doc.doc-type    no-undo .
  define input parameter  p-trn-doc-internal    like ub.trn-doc.internal    no-undo .
  define input parameter  p-trn-doc-discnt-type like ub.trn-doc.discnt-type no-undo .
  define input parameter  p-trn-doc-doc-code    like ub.trn-doc.doc-code    no-undo .
  define input parameter  p-obj-type            like ub.doc-line.obj-type   no-undo .
  define input parameter  p-obj-code            like ub.doc-line.obj-code   no-undo .
  define input parameter  p-artic               like ub.doc-line.artic      no-undo .
  define input parameter  p-prod-type           like ub.doc-line.prod-type  no-undo .
  define input parameter  p-prod-code           like ub.doc-line.prod-code  no-undo .
  define input parameter  p-need-rsrv           as logical no-undo .
  define input parameter  p-place-rsrv          as logical no-undo .
  define input parameter  p-goods-twounit       as logical no-undo .
  define output parameter p-change-qnty         like ub.gds-obj.fact-qnty no-undo .
  define output parameter p-change-base-total   like ub.gds-obj.avrg-base no-undo .
  define output parameter p-change-rubl-total   like ub.gds-obj.avrg-rubl no-undo .
  define output parameter p-total-qnty          like ub.gds-obj.fact-qnty no-undo .
  define output parameter p-total-cli-qnty      like ub.gds-obj.fact-qnty no-undo .
  define output parameter p-total-base-total    like ub.gds-obj.avrg-base no-undo .
  define output parameter p-total-rubl-total    like ub.gds-obj.avrg-rubl no-undo .
  define output parameter p-return-qnty         like ub.gds-obj.fact-qnty no-undo .
  define output parameter p-return-base-total   like ub.gds-obj.avrg-base no-undo .
  define output parameter p-return-rubl-total   like ub.gds-obj.avrg-rubl no-undo .
  define output parameter p-expense-qnty        like ub.gds-obj.fact-qnty no-undo .
  define output parameter p-expense-base-total  like ub.gds-obj.avrg-base no-undo .
  define output parameter p-expense-rubl-total  like ub.gds-obj.avrg-rubl no-undo .
  define output parameter p-total-rsrv-qnty     like ub.gds-obj.fact-qnty no-undo .

  define variable vss-description as character no-undo initial "tdparts: Сбор информации по партиям".

  define buffer archive_parts                 for ub.parts .
  define buffer check_archive_parts           for ub.parts .
  define buffer buf_goods                     for ub.goods .
  define buffer buf_doc-pl                    for ub.doc-pl .
  define buffer buf_temp-trndocrs-pl-gds-rsrv for temp-trndocrs-pl-gds-rsrv .

  define variable v-change-price-base as decimal no-undo .
  define variable v-change-price-rubl as decimal no-undo .
  define variable v-change-qnty       as decimal no-undo .
  define variable v-rsrv-qnty         as decimal no-undo .
  define variable v-change-cli-qnty   as decimal no-undo .
  define variable v-pl-change-qnty    as decimal no-undo .
  define variable v-cli-change-qnty   as decimal no-undo .
  define variable v-cli-rsrv-qnty     as decimal no-undo .

  do
  on error undo, return error return-value
  :
    /* вычисляем информацию, необходимую для расчета средней учетной цены */

    assign
      p-change-qnty        = 0
      p-change-base-total  = 0
      p-change-rubl-total  = 0
      p-total-qnty         = 0
      p-total-cli-qnty     = 0
      p-total-base-total   = 0
      p-total-rubl-total   = 0
      p-return-qnty        = 0
      p-return-base-total  = 0
      p-return-rubl-total  = 0
      p-expense-qnty       = 0
      p-expense-base-total = 0
      p-expense-rubl-total = 0
      p-total-rsrv-qnty    = 0
    .

    /* в расчете средней цены участвуют партии, порожденные
      документами внешний приход,
      внутренний приход - производство
      и партии, которые перемещаются из/в свободную зону
      */
    define variable v-prihod  as logical no-undo .
    define variable v-vozvrat as logical no-undo .

    assign
      v-prihod = false
    .

    if (p-trn-doc-doc-type = {&income}
          and( p-trn-doc-internal = no
            or
            (p-trn-doc-internal = yes
                and p-trn-doc-discnt-type = {&manufactured}
            )
          )
      )
    then do:
      assign
        v-prihod = true
      .
    end.

    for each archive_parts no-lock
      where archive_parts.out-code  = p-trn-doc-doc-code
        and archive_parts.obj-type  = p-obj-type
        and archive_parts.obj-code  = p-obj-code
        and archive_parts.artic     = p-artic
        and archive_parts.prod-type = p-prod-type
        and archive_parts.prod-code = p-prod-code
    on error undo, return error return-value
    :
      assign
        v-change-qnty = archive_parts.fact-qnty
        v-rsrv-qnty   = archive_parts.qnty
      .

      if p-goods-twounit = true
      then do:
        if archive_parts.fact-qnty = 0
        then do:
          assign
            v-change-cli-qnty = 0
          .
        end.
        else do:
          if archive_parts.fact-qnty = archive_parts.qnty
          then do:
            assign
              v-change-cli-qnty = archive_parts.cli-qnty
            .
          end.
          else do:
            message
              vss-workfile vss-revision vss-description skip
              "Фактическое количество не совпадает с количеством по документу" skip
              "Документ" archive_parts.out-code skip
              "Артикул" archive_parts.artic archive_parts.prod-type archive_parts.prod-code skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.
      end.
      else do:
        /* todo - сделать более точный расчет клиентского количества */
        /* для  */
        assign
          v-change-cli-qnty = archive_parts.fact-qnty / archive_parts.cli-base-rate
        .
      end.

      if p-trn-doc-doc-type = {&expense}
      or p-trn-doc-doc-type = {&write-off}
      then do:
        assign
          v-change-qnty     = - v-change-qnty
          v-rsrv-qnty       = - v-rsrv-qnty
          v-change-cli-qnty = - v-change-cli-qnty
        .
      end.

      if p-place-rsrv = true then do:
        run trndocrs-pl-gds-accum in this-procedure
          (input archive_parts.pl-code                             /* p-pl-code       */
          ,input (if p-need-rsrv = true then v-rsrv-qnty else 0.0) /* p-rsrv-qnty     */
          ,input 0.0                                               /* p-cli-rsrv-qnty */
          ,input v-change-qnty                                     /* p-fact-qnty     */
          ,input 0.0                                               /* p-cli-fact-qnty */
          ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при изменении зарезервированных количеств trndocrs-pl-gds-accum" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.

      assign
        v-change-price-base = archive_parts.price-base * v-change-qnty
        v-change-price-rubl = archive_parts.price-rubl * v-change-qnty
      .

      /* вычисляем общую сумму по всем партиям */
      assign
        p-total-qnty       = p-total-qnty       + v-change-qnty
        p-total-cli-qnty   = p-total-cli-qnty   + v-change-cli-qnty
        p-total-base-total = p-total-base-total + v-change-price-base
        p-total-rubl-total = p-total-rubl-total + v-change-price-rubl
        p-total-rsrv-qnty  = p-total-rsrv-qnty  + v-rsrv-qnty
      .
      if v-change-qnty > 0
      then do:
        /* вычисляем общую сумму по приходным партиям */
        assign
          p-return-qnty        = p-return-qnty        + v-change-qnty
          p-return-base-total  = p-return-base-total  + v-change-price-base
          p-return-rubl-total  = p-return-rubl-total  + v-change-price-rubl
        .
      end.
      else do:
        /* вычисляем общую сумму по расходным партиям */
        assign
          p-expense-qnty       = p-expense-qnty       + v-change-qnty
          p-expense-base-total = p-expense-base-total + v-change-price-base
          p-expense-rubl-total = p-expense-rubl-total + v-change-price-rubl
        .
      end.

      assign
        v-vozvrat = false
      .

      if p-trn-doc-doc-type = {&return}
      or (p-trn-doc-doc-type = {&inventory}
          and archive_parts.fact-qnty > 0
         )
      then do:
        assign
          v-vozvrat = true
        .
      end.

      if  v-prihod  <> true
      and v-vozvrat <> true
      and archive_parts.in-code = archive_parts.out-code
      then do:
        next. /* --->>>--- */
      end.

      /* если это был возврат партии, созданной при расходе
        то мы не учитываем ее для изменения средней учетной цены
      */
      if v-vozvrat = true
      then do:
        find first check_archive_parts no-lock
          where check_archive_parts.obj-type   = archive_parts.obj-type
            and check_archive_parts.obj-code   = archive_parts.obj-code
            and check_archive_parts.artic      = archive_parts.artic
            and check_archive_parts.prod-type  = archive_parts.prod-type
            and check_archive_parts.prod-code  = archive_parts.prod-code
            and check_archive_parts.in-code    = archive_parts.in-code
            and check_archive_parts.out-code   = {&free-code}
            and check_archive_parts.part-code  = archive_parts.part-code
          no-error .
        if not available check_archive_parts
        or check_archive_parts.fact-qnty <= 0
        then do:
          next. /* --->>>--- */
        end.
      end.

      assign
        p-change-qnty       = p-change-qnty       + v-change-qnty
        p-change-base-total = p-change-base-total + v-change-price-base
        p-change-rubl-total = p-change-rubl-total + v-change-price-rubl
      .

    end.

    if p-place-rsrv = true then do:
      find first buf_goods no-lock
        where buf_goods.artic     = p-artic
          and buf_goods.prod-type = p-prod-type
          and buf_goods.prod-code = p-prod-code
        .
      for each buf_doc-pl no-lock
        where buf_doc-pl.obj-type = p-obj-type
          and buf_doc-pl.obj-code = p-obj-code
          and buf_doc-pl.out-code = p-trn-doc-doc-code
          and buf_doc-pl.gds-code = buf_goods.gds-code
      on error undo, return error return-value
      :
        assign
          v-pl-change-qnty  = buf_doc-pl.fact-qnty
          v-cli-change-qnty = buf_doc-pl.cli-fact-qnty
          v-cli-rsrv-qnty   = (if p-need-rsrv = true then buf_doc-pl.cli-doc-qnty else 0.0)
        .

        if p-trn-doc-doc-type = {&expense}
        or p-trn-doc-doc-type = {&write-off}
        then do:
          assign
            v-pl-change-qnty  = - v-pl-change-qnty
            v-cli-change-qnty = - v-cli-change-qnty
            v-cli-rsrv-qnty   = - v-cli-rsrv-qnty
          .
        end.
        run trndocrs-pl-gds-accum in this-procedure
          (input buf_doc-pl.pl-code  /* p-pl-code       */
          ,input 0.0                 /* p-rsrv-qnty     */
          ,input v-cli-rsrv-qnty     /* p-cli-rsrv-qnty */
          ,input 0.0                 /* p-fact-qnty     */
          ,input v-cli-change-qnty   /* p-cli-fact-qnty */
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при изменении зарезервированных количеств trndocrs-pl-gds-accum" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        find first buf_temp-trndocrs-pl-gds-rsrv
          where buf_temp-trndocrs-pl-gds-rsrv.pl-code = buf_doc-pl.pl-code
          .
        if v-pl-change-qnty <> buf_temp-trndocrs-pl-gds-rsrv.fact-qnty
          and v-pl-change-qnty <> 0.00
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Количество по партиям не совпадает с количеством по складским местам." skip
            substitute( "Документ: &1", p-trn-doc-doc-code ) skip
            substitute( "Товар: &1", buf_goods.gds-code )  skip
            substitute( "Место хранения: &1", buf_doc-pl.pl-code )  skip
            substitute( "Количество по партиям: &1 (&2)",  buf_temp-trndocrs-pl-gds-rsrv.fact-qnty , buf_goods.unit-base ) skip
            substitute( "Количество по местам хр.: &1 (&2)", buf_doc-pl.fact-qnty, buf_goods.unit-base ) skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
    end.
  end.

end procedure. /* tdparts */

/* $Workfile$   E n d */