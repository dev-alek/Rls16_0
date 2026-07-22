/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет по закончившимся наименованиям

Автор: Демин Алексей Сергеевич
Дата создания: 09/14/05
Author: Alexey Demin
Creation date: 09/14/05

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

  if buf_gds-obj.last-doc = ?  then next .

  find first buf_goods no-lock  where buf_goods.gds-code = buf_gds-obj.gds-code .

  assign Counter1 = Counter1 + 1.
  { rep/repfrm.i disp Counter1 }

  /* нужны остатки на контрольную дату */
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = {&arh-crsa}
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order  <= v-fact-order
    use-index category no-error .

  if available buf_stk-line and buf_stk-line.fact-qnty = 0 then do:
    find first temp-DiscSales
      where temp-DiscSales.artic        = buf_goods.artic
        and temp-DiscSales.prod-type    = buf_goods.prod-type
        and temp-DiscSales.prod-code    = buf_goods.prod-code
    no-error .
    if not available temp-DiscSales then do:
      create temp-DiscSales .
      assign
        temp-DiscSales.artic     = buf_goods.artic
        temp-DiscSales.prod-type = buf_goods.prod-type
        temp-DiscSales.prod-code = buf_goods.prod-code
        temp-DiscSales.grp-name  = trim( buf_goods.grp-name )
        temp-DiscSales.unit-base = buf_goods.unit-base
        temp-DiscSales.grp-code  = buf_goods.grp-code
        temp-DiscSales.sum-cost  = 0
        temp-DiscSales.sum-sale  = 0
      .
      if g#gds-engl then assign temp-DiscSales.gds-name = buf_goods.engl-name.
      else               assign temp-DiscSales.gds-name = buf_goods.gds-name.

      { gbl/gdsbcode.i  buf_goods.gds-code  ?  ii  no-error }

    /* последний приход */
      assign fo = 0 .
      do ii = 1 to 6 :
        case ii :
          when 1 then assign str-find = {&TDEDT_Pri_Vnesh} .
          when 2 then assign str-find = {&TDEDT_Pri_Perem} .
          when 3 then assign str-find = {&TDEDT_Vozvrat_Vnesh} .
          when 4 then assign str-find = {&TDEDT_Vozvrat_Vnesh_Kass} .
          when 5 then assign str-find = {&TDEDT_Pri_Prvo} .
          when 6 then assign str-find = {&TDEDT_Vozvrat_Perem} .
        end.
        find last doc-line no-lock
          where doc-line.obj-type     = buf_gds-obj.obj-type
            and doc-line.obj-code     = buf_gds-obj.obj-code
            and doc-line.artic        = buf_gds-obj.artic
            and doc-line.prod-type    = buf_gds-obj.prod-type
            and doc-line.prod-code    = buf_gds-obj.prod-code
            and doc-line.ext-doc-type = str-find
            and doc-line.status_      =  {&fact}
            and doc-line.fact-order  <= v-fact-order
        no-error .
        if available doc-line then do:
          if doc-line.fact-order > fo then do:
            assign  fo = doc-line.fact-order .
            find first trn-doc no-lock where trn-doc.doc-code = doc-line.doc-code .
            assign temp-DiscSales.Last-Post = trn-doc.fact-date  .
          end.
        end.
      end.

      /* ищем дни отсутствия */
      assign
        stat = no
        fo   = buf_stk-line.fact-order
      .
      do while stat = no :
        find last buf_stk-line no-lock
          where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_goods.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = {&arh-crsa}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order  < fo
        use-index category no-error .
        if not available buf_stk-line then assign stat = yes .
        else do:
          assign fo   = buf_stk-line.fact-order .
          if buf_stk-line.fact-qnty <> 0 then do:
            assign
              temp-DiscSales.day = x-date - buf_stk-line.fact-date
              stat = yes
            .
          end.
        end.
      end.
    end.

    /* продажи за рабочий период */
    do ii = 1 to 8 :
      case ii :
        when 1 then assign str-find = {&arh-sadt} + {&TDEDT_Ras_Vnesh} .                 /* продажа */
        when 2 then assign str-find = {&arh-sadt} + {&TDEDT_Ras_Vnesh_Kass} .
        when 3 then assign str-find = {&arh-sadt} + {&TDEDT_Vozvrat_Vnesh} .
        when 4 then assign str-find = {&arh-sadt} + {&TDEDT_Vozvrat_Vnesh_Kass} .
        when 5 then assign str-find = {&arh-csdt} + {&TDEDT_Ras_Vnesh} .                 /* закупка */
        when 6 then assign str-find = {&arh-csdt} + {&TDEDT_Ras_Vnesh_Kass} .
        when 7 then assign str-find = {&arh-csdt} + {&TDEDT_Vozvrat_Vnesh} .
        when 8 then assign str-find = {&arh-csdt} + {&TDEDT_Vozvrat_Vnesh_Kass} .
      end.

      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_goods.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order  <= v-fact-order-start
      use-index category no-error .

      if available buf_stk-line then do:
        case ii :
          when 1 or when 2 then assign temp-DiscSales.sum-sale = temp-DiscSales.sum-sale + buf_stk-line.sum-rubl .
          when 3 or when 4 then assign temp-DiscSales.sum-sale = temp-DiscSales.sum-sale - buf_stk-line.sum-rubl .
          when 5 or when 6 then assign temp-DiscSales.sum-cost = temp-DiscSales.sum-cost + buf_stk-line.sum-rubl .
          when 7 or when 8 then assign temp-DiscSales.sum-cost = temp-DiscSales.sum-cost - buf_stk-line.sum-rubl .
        end.
      end.

      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_goods.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order  < v-fact-order-end
      use-index category no-error .

      if available buf_stk-line then do:
        case ii :
          when 1 or when 2 then assign temp-DiscSales.sum-sale = temp-DiscSales.sum-sale - buf_stk-line.sum-rubl .
          when 3 or when 4 then assign temp-DiscSales.sum-sale = temp-DiscSales.sum-sale + buf_stk-line.sum-rubl .
          when 5 or when 6 then assign temp-DiscSales.sum-cost = temp-DiscSales.sum-cost - buf_stk-line.sum-rubl .
          when 7 or when 8 then assign temp-DiscSales.sum-cost = temp-DiscSales.sum-cost + buf_stk-line.sum-rubl .
        end.
      end.
    end.
  end.

/* $Workfile$ e n d */