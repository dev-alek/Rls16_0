block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-isp-zf.p $
$Archive: cus/r-isp-zf.p $

Отчет по исполнению заказов - расчет и печать

Автор: Чернова Светлана Александровна
Дата создания: 12/11/08
Author: Svetlana Chernova
Creation date: 12/11/08

*/

define input parameter p-post       as integer   no-undo .
define input parameter p_cli-list   as character no-undo .
define input parameter p-tg-zay     as logical   no-undo .
define input parameter p-otkl       as integer   no-undo .
define input parameter p-proc       as integer   no-undo .
define input parameter p-time       as integer   no-undo .
define input parameter p-post-2     as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-isp-zf.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-isp-zf.p $":U .
define variable vss-description as character no-undo init "Отчет по исполнению заказов - расчет и печать".
{ cmp/vssrevis.i }

/* Local Variable Definitions ---                                       */
{ cmp/str-glbl.i }
{ cmp/r-pril.i }
{ rep/r-sym.i }
{ cmp/r-page1.i }
{ gbl/cmptime.i }
{ gbl/prn-lib.i }

do
on error undo, return error
:

  DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
  ASSIGN parParentProc =  my-handle .

  define variable g#report-num as integer   no-undo .
  run get-report-num  in parParentProc ( output g#report-num ).

  define variable g#host-code as integer   no-undo .
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get  }
{ gbl/hostcode.i v-cntxt-obj-type v-cntxt-obj-code  g#host-code }

  define buffer buf_ord-doc      for ub.ord-doc.
  define buffer buf_ord-line     for ub.ord-line.
  define buffer buf_ord-doc-rcv  for ub.ord-doc-rcv.
  define buffer buf_ord-line-rcv for ub.ord-line-rcv.
  define buffer buf_goods        for ub.goods.
  define buffer buf_trn-doc      for ub.trn-doc.
  define buffer buf_doc-line     for ub.doc-line.
  define buffer buf_clients      for ub.clients.

  define temp-table Temp-i no-undo   /* для подсчета итоговых сумм */
    field i-num-doc    like ub.ord-doc-rcv.doc-code
    field i-num-rcv    like ub.ord-doc-rcv.rcv-code
    field i-val-nakl   as decimal
    field i-date-nakl  as date
    field i-time-nakl  as char
    field i-cost-nakl  as decimal
    index PI IS PRIMARY i-num-doc  i-num-rcv
  .

  define variable Counter as integer .
  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 1 } /* Показать окно информации о текущем процессе */

  define variable  Line as char no-undo.

  define variable  v-bar-code            as integer                  no-undo.
  define variable  v-goods-artic         as char                     no-undo.
  define variable  v-goods-name          as char                     no-undo.
  define variable  v-goods-unit          as char                     no-undo.
  define variable  v-val-post            as decimal                  no-undo.
  define variable  v-date-post           as date                     no-undo.
  define variable  v-time-post           as char                     no-undo.
  define variable  v-cost-post           as decimal                  no-undo.
  define variable  v-val-nakl            as decimal                  no-undo.
  define variable  v-date-nakl           as date                     no-undo.
  define variable  v-time-nakl           as char                     no-undo.
  define variable  v-cost-nakl           as decimal                  no-undo.
  define variable  v-otkl                as decimal                  no-undo.
  define variable  v-otkl-prc            as decimal                  no-undo.

  define variable  sum-doc-val-post      as decimal  initial 0       no-undo.
  define variable  sum-doc-val-nakl      as decimal  initial 0       no-undo.
  define variable  sum-all-val-post      as decimal  initial 0       no-undo.
  define variable  sum-all-val-nakl      as decimal  initial 0       no-undo.

  define variable  v-fact-order-start    as decimal   no-undo .
  define variable  v-fact-order-end      as decimal   no-undo .

  define variable  StatOtkl              as integer   no-undo .
  define variable  NumPost               as integer   no-undo .
  define variable  PrnNum                as logical   no-undo .
  define variable  v-difference          as decimal      no-undo.

/*  run day-begin-fact-order in this-procedure ( input x-date-start, output v-fact-order-start ). /*Поиск нач fact-order*/*/
/*  run day-begin-fact-order in this-procedure ( input ( x-date-end + 1 ),   output v-fact-order-end ). /*Поиск посл fact-order*/*/

  { gbl/working.i }

  Line = fill("-", 198).

    DEFINE frame f-doc
        sym1  v-bar-code     column-label " Код!        "          format ">>>>>>>>>>>>>>9"  space(0)
        sym2  v-goods-artic  column-label " Артикул! "             format "X(15)"             space(0)
        sym3  v-goods-name   column-label " Наименование товара! " format "X(40)"             space(0)
        sym4  v-goods-unit   column-label "Ед.!изм!"               format "X(3)"              space(0)
        sym5  v-val-post     column-label "Кол-во по!заказу"       format "->>>>>>>9.999"     space(0)
        sym6  v-date-post    column-label "Дата!заказа"            format "99.99.99"          space(0)
        sym7  v-time-post    column-label "Время!заказа"           format "X(6)"              space(0)
        sym8  v-cost-post    column-label "Цена!заказа"            format ">>>>>>>>9.99"      space(0)
        sym9  v-val-nakl     column-label "Кол-во по!накладной"    format "->>>>>>>9.999"     space(0)
        sym10 v-date-nakl    column-label "Дата!накл-ой"           format "99.99.99"          space(0)
        sym11 v-time-nakl    column-label "Время!накл."            format "X(6)"              space(0)
        sym12 v-cost-nakl    column-label "Цена!накладной"         format ">>>>>>>>9.99"      space(0)
        sym13 v-otkl         column-label "Отклонение! "           format "->>>>>9.999"       space(0)
        sym14 v-otkl-prc     column-label "  %  ! откл."           format "->>9.99"           space(0)
        sym15
    with width {&DOS_CW} down stream-io.

    DEFINE frame f-doc1
        sym1  v-bar-code     column-label " Код!        "          format ">>>>>>>>>>>>>>9"   space(0)
        sym2  v-goods-artic  column-label " Артикул! "             format "X(15)"             space(0)
        sym3  v-goods-name   column-label " Наименование товара! " format "X(40)"             space(0)
        sym4  v-goods-unit   column-label "Ед.!изм!"               format "X(3)"              space(0)
        sym5  v-val-post     column-label "Кол-во по!заказу"       format "->>>>>>>9.999"     space(0)
        sym6  v-date-post    column-label "Дата!заказа"            format "99.99.99"          space(0)
        sym7  v-time-post    column-label "Время!заказа"           format "X(6)"              space(0)
        sym8  v-cost-post    column-label "Цена!заказа"            format ">>>>>>>>9.99"      space(0)
        sym9  v-val-nakl     column-label "Кол-во по!поставке"     format "->>>>>>>9.999"     space(0)
        sym10 v-date-nakl    column-label "Дата!поставки"          format "99.99.99"          space(0)
        sym11 v-time-nakl    column-label "Время!пост."            format "X(6)"              space(0)
        sym12 v-cost-nakl    column-label "Цена!поставки"          format ">>>>>>>>9.99"      space(0)
        sym13 v-otkl         column-label "Отклонение! "           format "->>>>>9.999"       space(0)
        sym14 v-otkl-prc     column-label " %  ! откл."            format "->>9.99"           space(0)
        sym15
    with width {&DOS_CW} down stream-io.

  run prn-lib-open-stream  in this-procedure (input parParentProc,input {&LS_PS_A4},input yes,input no).

  FORM HEADER
      Line format "X(198)" AT 1 SKIP
      "Продолжение - на следующей странице" AT 30 SKIP
      with FRAME BottomFrame width {&DOS_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW stream PrnLibStream FRAME BottomFrame .

  if p-post-2 = 2 then do: /* надо сравнивать с накладными */
    FORM HEADER
        string( "Дата печати : " + string(TODAY , "99.99.9999") + " , " + string(TIME, "HH:MM") ) AT 5 format "X(70)"
        string( "Страница " + string( PAGE-NUMBER( PrnLibStream )  , ">>9") ) AT 170 format "X(15)" SKIP
        Line format "X(198)" AT 1 with FRAME f-doc .
  end.
  else do:
    FORM HEADER
        string( "Дата печати : " + string(TODAY , "99.99.9999") + " , " + string(TIME, "HH:MM") ) AT 5 format "X(70)"
        string( "Страница " + string( PAGE-NUMBER( PrnLibStream )  , ">>9") ) AT 170 format "X(15)" SKIP
        Line format "X(198)" AT 1 with FRAME f-doc1 .
  end.

  PUT stream PrnLibStream SPACE(30) "Отчет по исполнению заказов по фирме за период с: " x-date-start format "99/99/9999" "г. по: "  x-date-end format "99/99/9999" "г." SKIP .
  PUT stream PrnLibStream  str1 format "X(100)" SKIP  str2 format "X(100)" SKIP str3 format "X(100)" SKIP .

    for each buf_ord-doc no-lock
      where buf_ord-doc.host-code = g#host-code
        and buf_ord-doc.doc-type  = {&f-p}
        and buf_ord-doc.doc-date >= x-date-start
        and buf_ord-doc.doc-date <= x-date-end
/*        and buf_ord-doc.fact-order >= v-fact-order-start*/
/*        and buf_ord-doc.fact-order < v-fact-order-end*/
      :
/*      if buf_ord-doc.status_  <> {&fact} then next.*/

      if p-post = 2 then do:  /* выбран поставщик */
        find buf_clients no-lock
          where buf_clients.obj-type = buf_ord-doc.cli-type
            and buf_clients.obj-code = buf_ord-doc.cli-code .
        if not can-do( p_cli-list, string( recid( buf_clients ) ) ) then next.
      end.

      assign
        PrnNum = no
        sum-doc-val-post = 0
        sum-doc-val-nakl = 0
        v-date-post = buf_ord-doc.ship-date
        v-time-post =  string(buf_ord-doc.ship-time, "HH:MM")
      .

      for each buf_ord-line no-lock
         where buf_ord-line.doc-code  = buf_ord-doc.doc-code
        :

        assign Counter = Counter + 1.
        { rep/repfrm.i disp Counter }

        if x-SelectGood <> {&g-all} then do:  /* выбраны не все товары */
          find first gds-list no-lock
            where gds-list.artic     = buf_ord-line.artic
              and gds-list.prod-type = buf_ord-line.prod-type
              and gds-list.prod-code = buf_ord-line.prod-code
              no-error
            .
          if not available gds-list then next .
        end.

        assign
          v-val-post  = buf_ord-line.qnty
          v-val-nakl  = 0
          v-cost-nakl = 0
        .

        if x-SET_val_TYPE = 1 then do:
          assign
            v-cost-post = buf_ord-line.price-rubl
          .
        end.
        else do:
          assign
            v-cost-post = buf_ord-line.price-base
          .
        end.

        for each Temp-i :   /* очищаем список поставок текущего заказа */
          delete Temp-i.
        end.

        for each buf_ord-doc-rcv no-lock
          where buf_ord-doc-rcv.doc-code  = buf_ord-doc.doc-code
          :

          if p-post-2 = 2 then do: /* надо сравнивать с накладными */

          /* Этот кусок правилен для 1:1 (Поставка -Накладная)  При отношении 1:М будет браться по последней накладной */
          /* Надо расширить и печатать по несколько строк (по накладным) */
          for each ub.ord-chain no-lock where
                    ub.ord-chain.doc-code = buf_ord-doc-rcv.rcv-code and
                    ub.ord-chain.doc-type = 'rcv'                  and
                    ub.ord-chain.rel-doc-type = 'trn'
                    :
            find first buf_trn-doc no-lock
              where buf_trn-doc.doc-code  = ub.ord-chain.rel-doc-code no-error
            .
            if not available buf_trn-doc then next . /* если это поставка по накладной  */

            if  p-otkl = 4 or p-otkl = 5 then do: /* надо проверять отклонения дат и врем */
              run cmptime-time-diff ( buf_trn-doc.fact-date, buf_ord-doc-rcv.fact-ship-time, buf_ord-doc.ship-date, buf_ord-doc.ship-time,output v-difference) .
              if p-time >= ABSOLUTE( v-difference ) then next .
            end.

            find first buf_doc-line no-lock
              where buf_doc-line.doc-code  = buf_trn-doc.doc-code
                and buf_doc-line.artic     = buf_ord-line.artic
                and buf_doc-line.prod-type = buf_ord-line.prod-type
                and buf_doc-line.prod-code = buf_ord-line.prod-code
                no-error
              .
            if available buf_doc-line then do: /* если есть накладные по заказу */
              create Temp-i no-error .
              assign
                Temp-i.i-num-doc    = buf_ord-doc.doc-code
                Temp-i.i-num-rcv    = buf_ord-doc-rcv.rcv-code
                Temp-i.i-val-nakl   = buf_doc-line.fact-qnty
                Temp-i.i-date-nakl  = buf_trn-doc.fact-date
                Temp-i.i-time-nakl  = string(buf_ord-doc-rcv.fact-ship-time, "HH:MM")
              .

              if x-SET_val_TYPE = 1 then do:
                assign
                  Temp-i.i-cost-nakl  = buf_doc-line.price-rubl
                .
              end.
              else do:
                assign
                  Temp-i.i-cost-nakl = buf_doc-line.price-base
                .
              end.
            end.
          end.
          end.
          else do:  /* надо сравнивать с поставками */
            if p-otkl = 4 or p-otkl = 5 then do: /* надо проверять отклонения дат и врем */
              run cmptime-time-diff ( buf_ord-doc-rcv.ship-date, buf_ord-doc-rcv.ship-time, buf_ord-doc.ship-date, buf_ord-doc.ship-time,output v-difference) .
              if p-time >= ABSOLUTE( v-difference ) then next .
            end.

            find first buf_ord-line-rcv no-lock
              where buf_ord-line-rcv.doc-code  = buf_ord-doc-rcv.doc-code
                and buf_ord-line-rcv.rcv-code  = buf_ord-doc-rcv.rcv-code
                and buf_ord-line-rcv.artic     = buf_ord-line.artic
                and buf_ord-line-rcv.prod-type = buf_ord-line.prod-type
                and buf_ord-line-rcv.prod-code = buf_ord-line.prod-code
                no-error
              .
            if available buf_ord-line-rcv then do: /* если есть поставка */
              create Temp-i no-error .
              assign
                Temp-i.i-num-doc    = buf_ord-doc-rcv.doc-code
                Temp-i.i-num-rcv    = buf_ord-doc-rcv.rcv-code
                Temp-i.i-val-nakl   = buf_ord-line-rcv.qnty
                Temp-i.i-date-nakl  = buf_ord-doc-rcv.ship-date
                Temp-i.i-time-nakl  = string(buf_ord-doc-rcv.ship-time, "HH:MM")
              .
              if x-SET_val_TYPE = 1 then do:
                assign
                  Temp-i.i-cost-nakl  = buf_ord-line-rcv.price-rubl
                .
              end.
              else do:
                assign
                  Temp-i.i-cost-nakl = buf_ord-line-rcv.price-base
                .
              end.
            end.
          end.
        end. /* for each buf_ord-doc-rcv */

        /* смотрим, что насчитали в рез-те и печатаем */
        assign
          NumPost = 0
          StatOtkl = 0
        .
        if p-otkl = 1 or p-otkl = 4 or p-otkl = 5 then do:
          assign
            StatOtkl = 1 /* надо печатать */
          .
        end.

        /* считаем кол-во поставок по заказу */
        for each Temp-i no-lock :
          assign
            NumPost = NumPost + 1
          .
          case p-otkl :
            when 2 then do:
              if ABSOLUTE((( v-val-post - Temp-i.i-val-nakl ) * 100 / v-val-post )) > p-proc then do:
                assign
                  StatOtkl = 1 /* надо печатать */
                .
              end.
            end.
            when 3 then do:
              if ABSOLUTE((( v-cost-post - Temp-i.i-cost-nakl ) * 100 / v-cost-post )) > p-proc then do:
                assign
                  StatOtkl = 1 /* надо печатать */
                .
              end.
            end.
            when 5 then do:
              if ABSOLUTE((( v-val-post - Temp-i.i-val-nakl ) * 100 / v-val-post )) > p-proc then do:
                assign
                  StatOtkl = 1 /* надо печатать */
                .
              end.
              if ABSOLUTE((( v-cost-post - Temp-i.i-cost-nakl ) * 100 / v-cost-post )) > p-proc then do:
                assign
                  StatOtkl = 1 /* надо печатать */
                .
              end.
            end.
          end.
        end.

        if StatOtkl = 0 then next . /* печатать не надо, отклонениям не удовл. */

        find first buf_goods  no-lock
          where buf_goods.artic     = buf_ord-line.artic
            and buf_goods.prod-type = buf_ord-line.prod-type
            and buf_goods.prod-code = buf_ord-line.prod-code
          .

        { gbl/gdsbcode.i buf_goods.gds-code ? v-bar-code no-error}.
        if error-status:error then do:
          message
            vss-workfile + ". Не найден бар-код товара " + buf_goods.artic
          view-as alert-box error.
          undo, return error .
        end.

        if p-tg-zay = yes then do: /* раздельно по поставкам */
          if PrnNum = no then do:
            assign
              PrnNum = yes
              v-goods-name = string( " Заказ " + buf_ord-doc.doc-code )
            .
            if p-post-2 = 2 then do: /* надо сравнивать с накладными */
              display stream PrnLibStream sym1 v-goods-name sym15 with frame f-doc.
              down stream PrnLibStream with frame f-doc .
            end.
            else do:
              display stream PrnLibStream sym1 v-goods-name sym15 with frame f-doc1.
              down stream PrnLibStream with frame f-doc1 .
            end.
          end.
        end.

        assign
          v-goods-artic   = string(buf_goods.artic)
          v-goods-name    = buf_goods.gds-name
          v-goods-unit    = buf_goods.unit-base

          sum-doc-val-post = sum-doc-val-post + v-val-post
          sum-all-val-post = sum-all-val-post + v-val-post
        .

        find first Temp-i no-lock no-error .
        if not available Temp-i then do:
          if p-post-2 = 2 then do: /* надо сравнивать с накладными */
            display stream PrnLibStream sym1  v-bar-code sym2  v-goods-artic sym3  v-goods-name sym4  v-goods-unit sym5  v-val-post sym6  v-date-post sym7  v-time-post sym8  v-cost-post sym9 sym10 sym11 sym12 sym13 sym14 sym15 with frame f-doc.
            down stream PrnLibStream with frame f-doc .
          end.
          else do:
            display stream PrnLibStream sym1  v-bar-code sym2  v-goods-artic sym3  v-goods-name sym4  v-goods-unit sym5  v-val-post sym6  v-date-post sym7  v-time-post sym8  v-cost-post sym9 sym10 sym11 sym12 sym13 sym14 sym15 with frame f-doc1.
            down stream PrnLibStream with frame f-doc1 .
          end.
        end.
        else do:
          assign
            v-val-nakl  = Temp-i.i-val-nakl
            v-date-nakl = Temp-i.i-date-nakl
            v-time-nakl = Temp-i.i-time-nakl
            v-cost-nakl = Temp-i.i-cost-nakl
            v-otkl      = v-val-nakl - v-val-post
            v-otkl-prc  = (v-val-nakl - v-val-post) * 100 / v-val-post

            sum-doc-val-nakl = sum-doc-val-nakl + v-val-nakl
            sum-all-val-nakl = sum-all-val-nakl + v-val-nakl
          .

          if p-post-2 = 2 then do: /* надо сравнивать с накладными */
            display stream PrnLibStream sym1  v-bar-code sym2  v-goods-artic sym3  v-goods-name sym4  v-goods-unit sym5  v-val-post sym6  v-date-post sym7  v-time-post sym8  v-cost-post sym9  v-val-nakl sym10 v-date-nakl sym11 v-time-nakl sym12 v-cost-nakl sym13 v-otkl sym14  v-otkl-prc sym15  with frame f-doc.
            down stream PrnLibStream with frame f-doc .
          end.
          else do:
            display stream PrnLibStream sym1  v-bar-code sym2  v-goods-artic sym3  v-goods-name sym4  v-goods-unit sym5  v-val-post sym6  v-date-post sym7  v-time-post sym8  v-cost-post sym9  v-val-nakl sym10 v-date-nakl sym11 v-time-nakl sym12 v-cost-nakl sym13 v-otkl sym14  v-otkl-prc sym15  with frame f-doc1.
            down stream PrnLibStream with frame f-doc1 .
          end.

          if NumPost > 1 then do:
            assign
              StatOtkl = 0
            .
            for each Temp-i no-lock :
              if StatOtkl = 0 then do:
                assign
                  StatOtkl = 1
                .
              end.
              else do:
                assign
                  v-val-nakl  = Temp-i.i-val-nakl
                  v-date-nakl = Temp-i.i-date-nakl
                  v-time-nakl = Temp-i.i-time-nakl
                  v-cost-nakl = Temp-i.i-cost-nakl
                  v-otkl      = v-val-nakl - v-val-post
                  v-otkl-prc  = (v-val-nakl - v-val-post) * 100 / v-val-post

                  sum-doc-val-nakl = sum-doc-val-nakl + v-val-nakl
                  sum-all-val-nakl = sum-all-val-nakl + v-val-nakl
                .

                if p-post-2 = 2 then do: /* надо сравнивать с накладными */
                  display stream PrnLibStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 v-val-nakl sym10 v-date-nakl sym11 v-time-nakl sym12 v-cost-nakl sym13 v-otkl sym14  v-otkl-prc sym15 with frame f-doc.
                  down stream PrnLibStream with frame f-doc .
                end.
                else do:
                  display stream PrnLibStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 v-val-nakl sym10 v-date-nakl sym11 v-time-nakl sym12 v-cost-nakl sym13 v-otkl sym14  v-otkl-prc sym15 with frame f-doc1.
                  down stream PrnLibStream with frame f-doc1 .
                end.
              end.
            end.

            if p-post-2 = 2 then do: /* надо сравнивать с накладными */
              assign
                v-goods-name = "Всего по накладным:"
                v-val-nakl   = sum-doc-val-nakl
              .
              display stream PrnLibStream sym1 sym2 sym3 v-goods-name sym4 sym5 sym6 sym7 sym8 sym9 v-val-nakl sym10 sym11 sym12 sym13 sym14  sym15 with frame f-doc.
              down stream PrnLibStream with frame f-doc .
            end.
            else do:
              assign
                v-goods-name = "Всего по поставкам:"
                v-val-nakl   = sum-doc-val-nakl
              .
              display stream PrnLibStream sym1 sym2 sym3 v-goods-name sym4 sym5 sym6 sym7 sym8 sym9 v-val-nakl sym10 sym11 sym12 sym13 sym14  sym15 with frame f-doc1.
              down stream PrnLibStream with frame f-doc1 .
            end.
          end.
        end.
      end.

      if p-tg-zay = yes then do: /* раздельно по поставкам  - итого */
        if PrnNum = yes then do:
          assign
            v-goods-name = "Всего по заказу:"
            v-val-post   = sum-doc-val-post
            v-val-nakl   = sum-doc-val-nakl
          .
          if p-post-2 = 2 then do: /* надо сравнивать с накладными */
            display stream PrnLibStream sym1 sym2 sym3 v-goods-name sym4 sym5 v-val-post sym6 sym7 sym8 sym9 v-val-nakl sym10 sym11 sym12 sym13 sym14  sym15 with frame f-doc.
            down stream PrnLibStream with frame f-doc .
          end.
          else do:
            display stream PrnLibStream sym1 sym2 sym3 v-goods-name sym4 sym5 v-val-post sym6 sym7 sym8 sym9 v-val-nakl sym10 sym11 sym12 sym13 sym14  sym15 with frame f-doc1.
            down stream PrnLibStream with frame f-doc1 .
          end.
        end.
      end.
    end.

  assign
    v-goods-name = "ИТОГО:"
    v-val-post   = sum-all-val-post
    v-val-nakl   = sum-all-val-nakl
  .

  if p-post-2 = 2 then do: /* надо сравнивать с накладными */
    display stream PrnLibStream sym1 sym2 sym3 v-goods-name sym4 sym5 v-val-post sym6 sym7 sym8 sym9 v-val-nakl sym10 sym11 sym12 sym13 sym14  sym15 with frame f-doc.
    down stream PrnLibStream with frame f-doc .
  end.
  else do:
    display stream PrnLibStream sym1 sym2 sym3 v-goods-name sym4 sym5 v-val-post sym6 sym7 sym8 sym9 v-val-nakl sym10 sym11 sym12 sym13 sym14  sym15 with frame f-doc1.
    down stream PrnLibStream with frame f-doc1 .
  end.

  PUT STREAM PrnLibStream Line format "X(198)".

  HIDE stream PrnLibStream FRAME BottomFrame .
  OUTPUT stream PrnLibStream CLOSE.

  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */
  { gbl/stopwork.i }

  run prn-lib-prn-file in this-procedure (input parParentProc,input 8).

END.