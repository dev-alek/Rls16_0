block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-isp-po.p $
$Archive: cus/r-isp-po.p $

Отчет по исполнению поставок - расчет и печать

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

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-isp-po.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-isp-po.p $":U .
define variable vss-description as character no-undo init "Отчет по исполнению поставок - расчет и печать".
{ cmp/vssrevis.i }

/* Local Variable Definitions ---                                       */
{ cmp/str-glbl.i }
{ cmp/r-pril.i }
{ rep/r-sym.i }
{ cmp/r-page1.i }
{ trg/factord.i }
{ gbl/cmptime.i }
{ cmp/showinf.i }
{ gbl/prn-lib.i }

do
on error undo, return error
:

define temp-table temp-gds no-undo
  FIELD gds-name  as character
  FIELD prod-code as integer
  FIELD prod-type as character
  FIELD artic     as character
  FIELD gds-code  as integer
  FIELD b-code    as integer
  FIELD unit      as character
  FIELD qnty1     as decimal
  FIELD price1    as decimal
  FIELD sum1      as decimal
  FIELD qnty2     as decimal
  FIELD price2    as decimal
  FIELD sum2      as decimal
  INDEX ii IS UNIQUE artic prod-type prod-code
.


  DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
  ASSIGN parParentProc =  my-handle .

  define variable g#report-num as integer   no-undo .
  run get-report-num  in parParentProc ( output g#report-num ).

  define buffer buf_ord-doc-rcv  for ub.ord-doc-rcv.
  define buffer buf_ord-line-rcv for ub.ord-line-rcv.
  define buffer buf_goods        for ub.goods.
  define buffer buf_trn-doc      for ub.trn-doc.
  define buffer buf1_trn-doc     for ub.trn-doc.
  define buffer buf_doc-line     for ub.doc-line.
  define buffer buf_clients      for ub.clients.

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

  define variable  sum-doc-val-post      as decimal  initial 0       no-undo.
  define variable  sum-doc-val-nakl      as decimal  initial 0       no-undo.
  define variable  sum-obj-val-post      as decimal  initial 0       no-undo.
  define variable  sum-obj-val-nakl      as decimal  initial 0       no-undo.
  define variable  sum-all-val-post      as decimal  initial 0       no-undo.
  define variable  sum-all-val-nakl      as decimal  initial 0       no-undo.

  define variable  v-fact-order-start     as decimal   no-undo .
  define variable  v-fact-order-end       as decimal   no-undo .

  define variable  PrnNum as logical   no-undo .
  define variable  PrnObj as logical   no-undo .
  define variable v-difference   as decimal      no-undo.

  run day-begin-fact-order in this-procedure ( input x-date-start, output v-fact-order-start ). /*Поиск нач fact-order*/
  run day-begin-fact-order in this-procedure ( input ( x-date-end + 1 ),   output v-fact-order-end ). /*Поиск посл fact-order*/

  { gbl/working.i }

  Line = fill("-", 196).

  DEFINE frame f-doc
        sym1  v-bar-code     column-label " Код!        "          format ">>>>>>>>>>>>>>>9"  space(0)
        sym2  v-goods-artic  column-label " Артикул! "             format "X(16)"             space(0)
        sym3  v-goods-name   column-label " Наименование товара! " format "X(40)"             space(0)
        sym4  v-goods-unit   column-label "Ед.!изм!"               format "X(3)"              space(0)
        sym5  v-val-post     column-label "Кол-во по!поставке"     format ">>>,>>>,>>9.999"   space(0)
        sym6  v-date-post    column-label "Дата!поставки"          format "99.99.9999"        space(0)
        sym7  v-time-post    column-label "Время!поставки"         format "X(9)"              space(0)
        sym8  v-cost-post    column-label "Цена!поставки"          format ">>>,>>>,>>9.99"    space(0)
        sym9  v-val-nakl     column-label "Кол-во по!накладной"    format ">>>,>>>,>>9.999"   space(0)
        sym10 v-date-nakl    column-label "Дата!накладной"         format "99.99.9999"        space(0)
        sym11 v-time-nakl    column-label "Время!накладной"        format "X(9)"              space(0)
        sym12 v-cost-nakl    column-label "Цена!накладной"         format ">>>,>>>,>>9.99"    space(0)
        sym13
  HEADER
        string( "Дата печати : " + string(TODAY , "99.99.9999") + " , " + string(TIME, "HH:MM") ) AT 5 format "X(100)"
        string( "Страница " + string( PAGE-NUMBER( PrnLibStream )  , ">>9") ) AT 170 format "X(15)" SKIP
        Line format "X(196)" AT 1
  with width {&DOS_CW} down stream-io.

  run prn-lib-open-stream  in this-procedure (input parParentProc,input {&LS_PS_A4},input yes,input no).

  FORM HEADER
      Line format "X(196)" AT 1 SKIP
      "Продолжение - на следующей странице" AT 30 SKIP
      with FRAME BottomFrame width {&DOS_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW stream PrnLibStream FRAME BottomFrame .

  FORM with FRAME f-doc .

  PUT stream PrnLibStream
    SPACE(30) "Отчет по исполнению поставок за период с: " x-date-start format "99/99/9999" "г. по: "  x-date-end format "99/99/9999" "г." SKIP .
  PUT stream PrnLibStream   str1 format "X(100)" SKIP  str2 format "X(100)"SKIP .

  for each obj-list no-lock :
    assign
      PrnObj = no
      sum-obj-val-post = 0
      sum-obj-val-nakl = 0
    .

    for each buf_ord-doc-rcv no-lock
      where buf_ord-doc-rcv.obj-type  = obj-list.obj-type
        and buf_ord-doc-rcv.obj-code  = obj-list.obj-code
        and buf_ord-doc-rcv.status_   = {&fact}
        and buf_ord-doc-rcv.fact-order >= v-fact-order-start
        and buf_ord-doc-rcv.fact-order < v-fact-order-end
      :

      case p-post :
        when 2 then do: /* только внутренние */
          if buf_ord-doc-rcv.doc-type <> "in":U then next .
        end.
        when 3 then do: /* от всех поставщиков */
          if buf_ord-doc-rcv.doc-type <> "out":U then next .
        end.
        when 4 then do:  /* от списка поставщиков */
          if buf_ord-doc-rcv.doc-type <> "out":U then next .
          find buf_clients no-lock
            where buf_clients.obj-type = buf_ord-doc-rcv.cli-type
              and buf_clients.obj-code = buf_ord-doc-rcv.cli-code .
          if not can-do( p_cli-list, string( recid( buf_clients ) ) ) then next.
        end.
        otherwise do:
        end.
      end case.

      assign
        PrnNum = no
        sum-doc-val-post = 0
        sum-doc-val-nakl = 0
        v-date-post      = buf_ord-doc-rcv.ship-date
        v-time-post      = string(buf_ord-doc-rcv.ship-time, "HH:MM")
        v-time-nakl      = string(buf_ord-doc-rcv.fact-ship-time, "HH:MM")
      .
      assign
        v-val-nakl  = 0
        v-cost-nakl = 0
      .

      for each temp-gds : delete temp-gds. end.
      for each buf_ord-line-rcv no-lock
        where buf_ord-line-rcv.doc-code  = buf_ord-doc-rcv.doc-code
          and buf_ord-line-rcv.rcv-code  = buf_ord-doc-rcv.rcv-code
        :
        assign Counter = Counter + 1.
        { rep/repfrm.i disp Counter }

        if x-SelectGood <> {&g-all} then do: /* выбраны не все товары */
          find first gds-list
            where gds-list.artic     = buf_ord-line-rcv.artic
              and gds-list.prod-type = buf_ord-line-rcv.prod-type
              and gds-list.prod-code = buf_ord-line-rcv.prod-code
          no-error .
          if not available gds-list then next.
        end.
        find first buf_goods  no-lock
          where buf_goods.artic     = buf_ord-line-rcv.artic
            and buf_goods.prod-type = buf_ord-line-rcv.prod-type
            and buf_goods.prod-code = buf_ord-line-rcv.prod-code
        no-error .
        if not available buf_goods then do:
          message vss-workfile + ". Не найден товар с артикулом " + buf_ord-line-rcv.artic view-as alert-box error.
          next .
        end.
        create temp-gds .
        assign
          temp-gds.unit      = buf_goods.unit-base
          temp-gds.gds-name  = buf_goods.gds-name
          temp-gds.gds-code  = buf_goods.gds-code
          temp-gds.artic     = buf_ord-line-rcv.artic
          temp-gds.prod-type = buf_ord-line-rcv.prod-type
          temp-gds.prod-code = buf_ord-line-rcv.prod-code
          temp-gds.qnty1     = buf_ord-line-rcv.qnty
        .
        if x-SET_val_TYPE = 1 then assign temp-gds.price1 = buf_ord-line-rcv.price-rubl .
        else                       assign temp-gds.price1 = buf_ord-line-rcv.price-base .
        assign temp-gds.sum1 = buf_ord-line-rcv.qnty * temp-gds.price1 .
        { gbl/gdsbcode.i buf_goods.gds-code ? temp-gds.b-code no-error}.
        if error-status:error then do:
          message vss-workfile + ". Не найден бар-код товара " + buf_goods.artic view-as alert-box error.
          next .
        end.
      end.

      find first temp-gds no-error .
      if not available temp-gds then next .  /* нет подходящих строк */

      /* Этот кусок правилен для 1:1 (Поставка -Накладная)  При отношении 1:М будет браться по последней накладной */
      /* Надо расширить и печатать по несколько строк (по накладным) */
      for each ub.ord-chain no-lock
        where ub.ord-chain.doc-code = buf_ord-doc-rcv.rcv-code
          and ub.ord-chain.doc-type = 'rcv'
          and ub.ord-chain.rel-doc-type = 'trn'
        :
        find first buf_trn-doc no-lock where buf_trn-doc.doc-code  = ub.ord-chain.rel-doc-code no-error .
        if not available buf_trn-doc then next.
        /* если внутренние поставки - ищем приход наклад */
        if buf_ord-doc-rcv.doc-type = "in":U then do:
          find first buf1_trn-doc no-lock where buf1_trn-doc.out-code  = buf_trn-doc.doc-code no-error .
          if available buf1_trn-doc then do:
            if p-otkl = 3 or p-otkl = 4 then do: /* надо проверять отклонения дат и врем */
              run cmptime-time-diff ( buf1_trn-doc.fact-date, buf_ord-doc-rcv.fact-ship-time, buf_ord-doc-rcv.ship-date, buf_ord-doc-rcv.ship-time,output v-difference) .
              if p-time >= ABSOLUTE( v-difference ) then next .
            end.
            assign v-date-nakl = buf1_trn-doc.fact-date  .
            run CreateGoods (input buf1_trn-doc.doc-code) .
          end.
        end.
        else do:
          if p-otkl = 3 or p-otkl = 4 then do: /* надо проверять отклонения дат и врем */
            run cmptime-time-diff ( buf_trn-doc.fact-date, buf_ord-doc-rcv.fact-ship-time, buf_ord-doc-rcv.ship-date, buf_ord-doc-rcv.ship-time,output v-difference) .
            if p-time >= ABSOLUTE( v-difference ) then next .
          end.
          assign v-date-nakl = buf_trn-doc.fact-date  .
          run CreateGoods (input buf_trn-doc.doc-code) .
        end.
      end.

      for each temp-gds :
        if p-otkl = 2 or p-otkl = 4 then do: /* надо проверять процент отклонения кол-ва */
          if ABSOLUTE((( temp-gds.qnty1 - temp-gds.qnty2 ) * 100 / temp-gds.qnty1 )) <= p-proc then next .
        end.
        if PrnObj = no then do:
          assign
            PrnObj = yes
            v-goods-name = string( " Объект: " + obj-list.obj-name) /*+ " (" + obj-list.obj-type + '#' + string(obj-list.obj-code)  + ") " ) format "X(100)"*/
          .
          display stream PrnLibStream  sym1  v-goods-name  sym13  with frame f-doc.
          down stream PrnLibStream with frame f-doc .
        end.
        if p-tg-zay = yes then do: /* раздельно по поставкам */
          if PrnNum = no then do:
            assign
              PrnNum = yes
              v-goods-name = string( " Поставка " + buf_ord-doc-rcv.rcv-code + " по заказу " + buf_ord-doc-rcv.doc-code )
            .
            display stream PrnLibStream  sym1  v-goods-name sym13  with frame f-doc.
            down stream PrnLibStream with frame f-doc .
          end.
        end.

        assign
          v-goods-artic   = temp-gds.artic
          v-goods-name    = temp-gds.gds-name
          v-goods-unit    = temp-gds.unit
          v-bar-code      = temp-gds.b-code
          v-val-post      = temp-gds.qnty1
          v-cost-post     = temp-gds.price1
          v-val-nakl      = temp-gds.qnty2
          v-cost-nakl     = temp-gds.sum2 / temp-gds.qnty2

          sum-doc-val-post = sum-doc-val-post + v-val-post
          sum-doc-val-nakl = sum-doc-val-nakl + v-val-nakl
          sum-obj-val-post = sum-obj-val-post + v-val-post
          sum-obj-val-nakl = sum-obj-val-nakl + v-val-nakl
          sum-all-val-post = sum-all-val-post + v-val-post
          sum-all-val-nakl = sum-all-val-nakl + v-val-nakl
        .

        display stream PrnLibStream
          sym1  v-bar-code
          sym2  v-goods-artic
          sym3  v-goods-name
          sym4  v-goods-unit
          sym5  v-val-post
          sym6  v-date-post
          sym7  v-time-post
          sym8  v-cost-post
          sym9  v-val-nakl
          sym10 v-date-nakl
          sym11 v-time-nakl
          sym12 v-cost-nakl
          sym13
        with frame f-doc.
        down stream PrnLibStream with frame f-doc .
      end.

      if p-tg-zay = yes then do: /* раздельно по поставкам  - итого */
        if PrnNum = yes then do:
          assign
            v-goods-name = "Всего по поставке:"
            v-val-post   = sum-doc-val-post
            v-val-nakl   = sum-doc-val-nakl
          .

          display stream PrnLibStream
            sym1
            sym2
            sym3   v-goods-name
            sym4
            sym5   v-val-post
            sym6
            sym7
            sym8
            sym9   v-val-nakl
            sym10
            sym11
            sym12
            sym13
          with frame f-doc.
          down stream PrnLibStream with frame f-doc .
        end.
      end.
    end.

    if PrnObj = yes then do:
      assign
        v-goods-name = "Всего по объекту:"
        v-val-post   = sum-obj-val-post
        v-val-nakl   = sum-obj-val-nakl
      .

      display stream PrnLibStream sym1 sym2 sym3   v-goods-name sym4 sym5   v-val-post sym6 sym7 sym8 sym9   v-val-nakl sym10 sym11 sym12 sym13 with frame f-doc.
      down stream PrnLibStream with frame f-doc .

      display stream PrnLibStream  sym1   sym13  with frame f-doc.
      down stream PrnLibStream with frame f-doc .
    end.

  end. /* for each obj-list  */

  assign
    v-goods-name = "ИТОГО:"
    v-val-post   = sum-all-val-post
    v-val-nakl   = sum-all-val-nakl
  .

  display stream PrnLibStream sym1 sym2 sym3   v-goods-name sym4 sym5   v-val-post sym6 sym7 sym8 sym9   v-val-nakl sym10 sym11 sym12 sym13 with frame f-doc.
  down stream PrnLibStream with frame f-doc .

  PUT STREAM PrnLibStream Line format "X(196)".

  HIDE stream PrnLibStream FRAME BottomFrame .
  OUTPUT stream PrnLibStream CLOSE.

  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */
  { gbl/stopwork.i }

  run prn-lib-prn-file in this-procedure (input parParentProc,input 8).
END.


procedure CreateGoods :
  do on error undo, return error return-value :
  define input  parameter p-code as character no-undo .
    define buffer buf_doc-line for ub.doc-line.

    for each buf_doc-line no-lock where buf_doc-line.doc-code = p-code :
      find first temp-gds
          where temp-gds.artic     = buf_doc-line.artic
            and temp-gds.prod-type = buf_doc-line.prod-type
            and temp-gds.prod-code = buf_doc-line.prod-code
      no-error .
      if not available temp-gds then next.
      if x-SET_val_TYPE = 1 then assign temp-gds.sum2 = temp-gds.sum2 + buf_doc-line.price-rubl * buf_doc-line.fact-qnty  .
      else                       assign temp-gds.sum2 = temp-gds.sum2 + buf_doc-line.price-base * buf_doc-line.fact-qnty  .
      assign temp-gds.qnty2 = temp-gds.qnty2 + buf_doc-line.fact-qnty .
    end.
  end.
end procedure. /* CreateGoods */