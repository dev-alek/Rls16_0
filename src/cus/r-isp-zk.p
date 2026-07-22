block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-isp-zk.p $
$Archive: cus/r-isp-zk.p $

Отчет по исполнению заказов - расчет и печать

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/27/06
Author: Michael Kochetkov
Creation date: 03/27/06

*/

define input parameter p-post       as integer   no-undo .
define input parameter p_cli-list   as character no-undo .
define input parameter p-tg-zay     as logical   no-undo .
define input parameter p-otkl       as integer   no-undo .
define input parameter p-proc       as integer   no-undo .
define input parameter p-time       as integer   no-undo .
define input parameter p-post-2     as integer   no-undo .
define input parameter p-status_    as integer   no-undo .
define input parameter p-ext-art   as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-isp-zk.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-isp-zk.p $":U .
define variable vss-description as character no-undo init "Отчет по исполнению заказов - расчет и печать".
{ cmp/vssrevis.i }

/* Local Variable Definitions ---                                       */
{ cmp/str-glbl.i }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ cmp/r-page1.i  }
{ gbl/cmptime.i  }
{ gbl/prn-lib.i  }
{ rep/f-fdec.i }
{ gbl/cur-time.i }
{ gbl/paramls.i  }
{ rep/lkp-font.i }


define variable v-file-name as character no-undo .
define variable v-ind       as integer   no-undo .
define variable num#col# as integer no-undo .
define variable var-1 as integer no-undo .
define variable var-2 as integer no-undo .
define variable C-c    as integer no-undo .
define variable C-str  as character no-undo .
define variable str--1 as character Format "x(60)" no-undo.
define variable str--2 as integer no-undo .
define variable C-i    as integer no-undo .
define variable p-var  as integer no-undo .
define stream  macr_excel .

do
on error undo, return error
:

  DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
  ASSIGN parParentProc =  my-handle .

  define variable g#report-num as integer   no-undo .
  run get-report-num  in parParentProc ( output g#report-num ).

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
  define variable  v-prc                 as decimal                  no-undo.
  define variable v-cli-art              as character                no-undo .

  define variable  sum-doc1-post     as decimal  initial 0       no-undo.
  define variable  sum-doc1-nakl     as decimal  initial 0       no-undo.
  define variable  sum-doc-post      as decimal  initial 0       no-undo.
  define variable  sum-doc-nakl      as decimal  initial 0       no-undo.
  define variable  sum-obj-post      as decimal  initial 0       no-undo.
  define variable  sum-obj-nakl      as decimal  initial 0       no-undo.
  define variable  sum-all-post      as decimal  initial 0       no-undo.
  define variable  sum-all-nakl      as decimal  initial 0       no-undo.

  define variable  v-fact-order-start     as decimal   no-undo .
  define variable  v-fact-order-end       as decimal   no-undo .

  define variable  StatOtkl as integer   no-undo .
  define variable  NumPost as integer   no-undo .
  define variable  PrnNum  as logical   no-undo .
  define variable  PrnObj  as logical   no-undo .
  define variable  v-difference   as decimal      no-undo.

  { gbl/working.i }

  Line = fill("-", 190).

    DEFINE frame f-doc
        sym1  v-bar-code     column-label " Код!        "          format ">>>>>>>>>>>>>>>9"  space(0)
        sym2  v-goods-artic  column-label " Артикул! "             format "X(16)"             space(0)
        sym3  v-goods-name   column-label " Наименование товара! " format "X(40)"             space(0)
        sym4  v-goods-unit   column-label "Ед.!изм!"               format "X(3)"              space(0)
        sym5  v-val-post     column-label "Кол-во по!заказу"       format ">>,>>9.999"        space(0)
        sym6  v-date-post    column-label "Дата!заказа"            format "99.99.9999"        space(0)
        sym7  v-time-post    column-label "Время!заказа"           format "X(9)"              space(0)
        sym8  v-cost-post    column-label "Цена!заказа"            format ">,>>>,>>9.99"      space(0)
        sym9  v-val-nakl     column-label "Кол-во по!накладной"    format ">>,>>9.999"        space(0)
        sym10 v-date-nakl    column-label "Дата!накладной"         format "99.99.9999"        space(0)
        sym11 v-time-nakl    column-label "Время!накладной"        format "X(9)"              space(0)
        sym12 v-cost-nakl    column-label "Цена!накладной"         format ">,>>>,>>9.99"      space(0)
        sym13 v-prc          column-label "%!отгр"                 format ">>9.99"            space(0)
        sym14
    with width {&DOS_CW} down stream-io.

    DEFINE frame f-doc1
        sym1  v-bar-code     column-label " Код!        "          format ">>>>>>>>>>>>>>>9"  space(0)
        sym2  v-goods-artic  column-label " Артикул! "             format "X(16)"             space(0)
        sym3  v-goods-name   column-label " Наименование товара! " format "X(40)"             space(0)
        sym4  v-goods-unit   column-label "Ед.!изм!"               format "X(3)"              space(0)
        sym5  v-val-post     column-label "Кол-во по!заказу"       format ">>,>>9.999"        space(0)
        sym6  v-date-post    column-label "Дата!заказа"            format "99.99.9999"        space(0)
        sym7  v-time-post    column-label "Время!заказа"           format "X(9)"              space(0)
        sym8  v-cost-post    column-label "Цена!заказа"            format ">,>>>,>>9.99"      space(0)
        sym9  v-val-nakl     column-label "Кол-во по!поставке"     format ">>,>>9.999"        space(0)
        sym10 v-date-nakl    column-label "Дата!поставки"          format "99.99.9999"        space(0)
        sym11 v-time-nakl    column-label "Время!поставки"         format "X(9)"              space(0)
        sym12 v-cost-nakl    column-label "Цена!поставки"          format ">,>>>,>>9.99"      space(0)
        sym13 v-prc          column-label "%!отгр"                 format ">>9.99"            space(0)
        sym14

    with width {&DOS_CW} down stream-io.

  run prn-lib-open-stream  in this-procedure (input parParentProc,input {&LS_PS_A4},input yes,input no).

  /* создаем временный файл */
  run gbl/_tmpfile.p ( "wb", ".txt", output v-file-name) .
  output stream macr_excel to value(v-file-name)   .
  v-ind = 1    .
  num#str# = 0 .


  FORM HEADER
      Line format "X(190)" AT 1 SKIP
      "Продолжение - на следующей странице" AT 30 SKIP
      with FRAME BottomFrame width {&DOS_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW stream PrnLibStream FRAME BottomFrame .

  if p-post-2 = 2 then do: /* надо сравнивать с накладными */
    FORM HEADER
        string( "Дата печати : " + string(TODAY , "99.99.9999") + " , " + string(TIME, "HH:MM") ) AT 5 format "X(100)"
        string( "Страница " + string( PAGE-NUMBER( PrnLibStream )  , ">>9") ) AT 170 format "X(15)" SKIP
        Line format "X(190)" AT 1 with FRAME f-doc .
  end.
  else do :
    FORM HEADER
        string( "Дата печати : " + string(TODAY , "99.99.9999") + " , " + string(TIME, "HH:MM") ) AT 5 format "X(100)"
        string( "Страница " + string( PAGE-NUMBER( PrnLibStream )  , ">>9") ) AT 170 format "X(15)" SKIP
        Line format "X(190)" AT 1 with FRAME f-doc1 .
  end.

  PUT stream PrnLibStream SPACE(30) "Отчет по исполнению заказов за период с: " x-date-start format "99/99/9999" "г. по: "  x-date-end format "99/99/9999" "г." SKIP .
  PUT stream PrnLibStream str1 format "X(100)" SKIP  str2 format "X(100)" SKIP  str3 format "X(100)" SKIP .


if p-ext-art then do:

   v-goods-artic:label  in frame f-doc = "Артикул Пост-ка" .
   v-goods-artic:label  in frame f-doc1 = "Артикул Пост-ка" .
end.


      num#str# = num#str# + 1 .
      num#col# =  1 .

      run macr_excel_char_with_format ( ReportNAme , num#str# , num#col#  ).
      run macr_cell_format
          ( 12    ,     /* p-size */
            true  ,     /*p-bold   */
            false ,     /*p-italic */
            ?     ,     /*p-color  */
            num#str# ,  /*p-row    */
            num#col# ,  /*p-col    */
            ? ,         /*p-row-2  */
            ?         ) . /*p-col-2 */
define variable l-ii  as integer no-undo .
define variable l-jj  as integer no-undo .
define variable l-len as integer no-undo .
define variable l-m   as integer no-undo .

&scop var-print-n    do l-ii = 1 to num-entries( ~{&var-str-n} , "~{&new-line}"  )    :  ~
      l-len = length (entry( l-ii , ~{&var-str-n}  , "~{&new-line}")) .                 ~
      l-m = integer( l-len / 220 ) + 1 .                                                ~
      do l-jj = 1 to  l-m  :                                                            ~
          num#str# = num#str# + 1 .                                                     ~
          run macr_excel_char_with_format (                                             ~
              substring(entry( l-ii , ~{&var-str-n}  , "~{&new-line}") , (( 220 * l-jj ) - 219 )  , 220 )  , num#str# , num#col# ) .~
      end.                                                                                                       ~
  end.

&scop var-str-n  str1
{&var-print-n }
&scop var-str-n  str2
{&var-print-n }
&scop var-str-n  str3
{&var-print-n }
&scop var-str-n  str4
{&var-print-n }
&scop var-str-n  reportheader
{&var-print-n }


  num#str# = num#str# + 1.
  num#col# = 1.

  num#str# = num#str# + 1.
  num#col# = 1.
/*Печать шапки */
   run proc-print-header-my.


  for each obj-list no-lock :
    assign
      PrnObj = no
      sum-obj-post = 0
      sum-obj-nakl = 0
    .

    for each buf_ord-doc no-lock
      where buf_ord-doc.obj-type  = obj-list.obj-type
        and buf_ord-doc.obj-code  = obj-list.obj-code
        and buf_ord-doc.doc-type  = {&o-p}
        and buf_ord-doc.doc-date >= x-date-start
        and buf_ord-doc.doc-date <= x-date-end
      :
      if p-status_ = 2  then do:
         if buf_ord-doc.status_  <> {&fact} then next.
      end.

      if p-post = 2 then do: /* выбран поставщик */
        find buf_clients no-lock
          where buf_clients.obj-type = buf_ord-doc.cli-type
            and buf_clients.obj-code = buf_ord-doc.cli-code .
        if not can-do( p_cli-list, string( recid( buf_clients ) ) ) then next.
      end.

      assign
        PrnNum = no
        sum-doc-post = 0
        sum-doc-nakl = 0
        v-date-post = buf_ord-doc.ship-date
        v-time-post =  string(buf_ord-doc.ship-time, "HH:MM")
      .

TT:   for each buf_ord-line no-lock where buf_ord-line.doc-code  = buf_ord-doc.doc-code :
        assign Counter = Counter + 1.
        { rep/repfrm.i disp Counter }

        if x-SelectGood <> {&g-all} then do:  /* выбраны не все товары */
          find first gds-list no-lock where gds-list.artic     = buf_ord-line.artic and gds-list.prod-type = buf_ord-line.prod-type and gds-list.prod-code = buf_ord-line.prod-code no-error .
          if not available gds-list then next .
        end.

        assign
          v-val-post  = if buf_ord-line.order-cli-qnty = 0 then buf_ord-line.qnty else buf_ord-line.order-cli-qnty
          v-val-nakl  = 0
          v-cost-nakl = 0
          sum-doc1-post = 0
          sum-doc1-nakl = 0
        .

        if x-SET_val_TYPE = 1 then assign v-cost-post = buf_ord-line.price-rubl .
        else                       assign v-cost-post = buf_ord-line.price-base .

        for each Temp-i:  delete Temp-i .  end.

        for each buf_ord-doc-rcv no-lock where buf_ord-doc-rcv.doc-code  = buf_ord-doc.doc-code :
          if p-post-2 = 2 then do: /* надо сравнивать с накладными */
            /* Этот кусок правилен для 1:1 (Поставка -Накладная)  При отношении 1:М будет браться по последней накладной */
            /* Надо расширить и печатать по несколько строк (по накладным) */
            for each ub.ord-chain no-lock where
                      ub.ord-chain.doc-code = buf_ord-doc-rcv.rcv-code and
                      ub.ord-chain.doc-type = 'rcv'                  and
                      ub.ord-chain.rel-doc-type = 'trn'
                      :

            find first buf_trn-doc no-lock where buf_trn-doc.doc-code  = ub.ord-chain.rel-doc-code no-error .
            if not available buf_trn-doc then next TT . /* если это поставка по накладной  */

            if  p-otkl = 4 or p-otkl = 5 then do: /* надо проверять отклонения дат и врем */
              run cmptime-time-diff ( buf_trn-doc.fact-date, buf_ord-doc-rcv.fact-ship-time, buf_ord-doc.ship-date, buf_ord-doc.ship-time,output v-difference) .
              if p-time >= ABSOLUTE( v-difference ) then next TT .
            end.

            find first buf_doc-line no-lock
              where buf_doc-line.doc-code  = buf_trn-doc.doc-code
                and buf_doc-line.artic     = buf_ord-line.artic
                and buf_doc-line.prod-type = buf_ord-line.prod-type
                and buf_doc-line.prod-code = buf_ord-line.prod-code
                no-error
              .
            if available buf_doc-line then do: /* если это поставка по накладной и она одна */
              create Temp-i no-error .
              assign
                Temp-i.i-num-doc    = buf_ord-doc.doc-code
                Temp-i.i-num-rcv    = buf_ord-doc-rcv.rcv-code
                Temp-i.i-val-nakl   = buf_doc-line.fact-qnty
                Temp-i.i-date-nakl  = buf_trn-doc.fact-date
                Temp-i.i-time-nakl  = string(buf_ord-doc-rcv.fact-ship-time, "HH:MM")
              .
              if x-SET_val_TYPE = 1 then assign Temp-i.i-cost-nakl = buf_doc-line.price-rubl .
              else                       assign Temp-i.i-cost-nakl = buf_doc-line.price-base .
            end.
          end.
          end.
          else do:  /* надо сравнивать с поставками */
            if p-otkl = 4 or p-otkl = 5 then do: /* надо проверять отклонения дат и врем */
              run cmptime-time-diff ( buf_ord-doc-rcv.ship-date, buf_ord-doc-rcv.ship-time, buf_ord-doc.ship-date, buf_ord-doc.ship-time,output v-difference) .
              if p-time >= ABSOLUTE( v-difference ) then next TT .
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
              if x-SET_val_TYPE = 1 then assign Temp-i.i-cost-nakl = buf_ord-line-rcv.price-rubl .
              else                       assign Temp-i.i-cost-nakl = buf_ord-line-rcv.price-base .
            end.
          end.
        end. /* for each buf_ord-doc-rcv */

        /* смотрим, что насчитали в рез-те и печатаем */
        assign
          NumPost = 0
          StatOtkl = 0
        .
        if p-otkl = 1 or p-otkl = 4 or p-otkl = 5 then  assign StatOtkl = 1 . /* надо печатать */

        /* считаем кол-во поставок по заказу */
        for each Temp-i no-lock :
          assign NumPost = NumPost + 1 .
          case p-otkl :
            when 2 then do:
              if ABSOLUTE((( v-val-post - Temp-i.i-val-nakl ) * 100 / v-val-post )) > p-proc then assign StatOtkl = 1 . /* надо печатать */
            end.
            when 3 then do:
              if ABSOLUTE(((v-cost-post - Temp-i.i-cost-nakl) * 100 / v-cost-post )) > p-proc then assign StatOtkl = 1 . /* надо печатать */
            end.
            when 5 then do:
              if ABSOLUTE((( v-val-post - Temp-i.i-val-nakl ) * 100 / v-val-post )) > p-proc then assign StatOtkl = 1 . /* надо печатать */
              if ABSOLUTE((( v-cost-post - Temp-i.i-cost-nakl ) * 100 / v-cost-post )) > p-proc then assign StatOtkl = 1 . /* надо печатать */
            end.
          end.
        end.

        if StatOtkl = 0 then next .

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

       find first ub.ext-artic no-lock where
              ub.ext-artic.gds-code = buf_ord-line.gds-code and
              ub.ext-artic.cli-type = buf_ord-doc.Cli-type and
              ub.ext-artic.cli-code = buf_ord-doc.Cli-code and
              ub.ext-artic.status_  = {&current-status} no-error .
       if available ub.ext-artic then do:
            assign
             v-cli-art = ub.ext-artic.ext-artic
             .
       end.
       else do:
            assign
             v-cli-art = ""
             .
       end.

        if PrnObj = no then do:
          assign
            PrnObj = yes
            v-goods-name = string( " Объект: " + obj-list.obj-name) /*+ " (" + obj-list.obj-type + '#' + string(obj-list.obj-code)  + ") " ) format "X(100)"*/
          .
          if p-post-2 = 2 then do: /* надо сравнивать с накладными */
            display stream PrnLibStream sym1 v-goods-name sym13 sym14 with frame f-doc.
            down stream PrnLibStream with frame f-doc .
          end.
          else do:
            display stream PrnLibStream sym1 v-goods-name sym13 sym14 with frame f-doc1.
            down stream PrnLibStream with frame f-doc1 .
          end.
          num#str# = num#str# + 1.
          num#col# = 3.
          run macr_excel_char_with_format (v-goods-name , num#str# , num#col# ).
        end.

        if p-tg-zay = yes then do: /* раздельно по поставкам */
          if PrnNum = no then do:
            assign
              PrnNum = yes
              v-goods-name = string( " Заказ " + buf_ord-doc.doc-code + " " + buf_ord-doc.cli-name )
            .
            if p-post-2 = 2 then do: /* надо сравнивать с накладными */
              display stream PrnLibStream sym1 v-goods-name sym13 sym14 with frame f-doc.
              down stream PrnLibStream with frame f-doc .
            end.
            else do:
              display stream PrnLibStream sym1 v-goods-name sym13 sym14 with frame f-doc1.
              down stream PrnLibStream with frame f-doc1 .
            end.
            num#str# = num#str# + 1.
            num#col# = 3.
            run macr_excel_char_with_format (v-goods-name , num#str# , num#col# ).
            run macr_cell_format (
                11       , /*p-size-font */
                true     , /*p-bold      */
                false    , /*p-italic    */
                ?       , /*p-color-bg  */
                num#str# , /*p-row       */
                3        , /*p-col       */
                num#str# , /*p-row-2     */
                num#col# ) /*p-col-2     */
                .

          end.
        end.

        assign
          v-goods-artic   = string(buf_goods.artic)
          v-goods-name    = buf_goods.gds-name
          v-goods-unit    = buf_goods.unit-base

          sum-doc1-post = sum-doc1-post + v-val-post
          sum-doc-post = sum-doc-post + v-val-post
          sum-obj-post = sum-obj-post + v-val-post
          sum-all-post = sum-all-post + v-val-post
        .

        if p-ext-art then v-goods-artic =  v-cli-art .

        find first Temp-i no-lock no-error .
        if not available Temp-i then do:
          if p-post-2 = 2 then do: /* надо сравнивать с накладными */
            display stream PrnLibStream sym1  v-bar-code  sym2  v-goods-artic sym3  v-goods-name sym4  v-goods-unit sym5  v-val-post sym6  v-date-post sym7  v-time-post sym8  v-cost-post sym9 sym10 sym11 sym12 sym13 sym14 with frame f-doc.
            down stream PrnLibStream with frame f-doc .
          end.
          else do:
            display stream PrnLibStream sym1  v-bar-code  sym2  v-goods-artic sym3  v-goods-name sym4  v-goods-unit sym5  v-val-post sym6  v-date-post sym7  v-time-post sym8  v-cost-post sym9 sym10 sym11 sym12 sym13 sym14 with frame f-doc1.
            down stream PrnLibStream with frame f-doc1 .
          end.
          num#str# = num#str# + 1.
          num#col# = 1.
            run macr_excel_char_with_format (v-bar-code  , num#str# , num#col# ). assign  num#col# = num#col# + 1 .
            run macr_excel_char_with_format (v-goods-artic , num#str# , num#col# ). assign  num#col# = num#col# + 1 .
            run macr_excel_char_with_format (v-goods-name , num#str# , num#col# ). assign  num#col# = num#col# + 1 .
            run macr_excel_char_with_format (v-goods-unit , num#str# , num#col# ). assign  num#col# = num#col# + 1 .
            run macr_excel_dec         (v-val-post , num#str# , num#col# ). assign  num#col# = num#col# + 1 .
            run macr_excel_char_with_format (v-date-post , num#str# , num#col# ). assign  num#col# = num#col# + 1 .
            run macr_excel_char_with_format (v-time-post , num#str# , num#col# ). assign  num#col# = num#col# + 1 .
            run macr_excel_dec         (v-cost-post, num#str# , num#col# ). assign  num#col# = num#col# + 1 .
        end.
        else do:
          assign
            v-val-nakl  = Temp-i.i-val-nakl
            v-date-nakl = Temp-i.i-date-nakl
            v-time-nakl = Temp-i.i-time-nakl
            v-cost-nakl = Temp-i.i-cost-nakl
            v-prc = v-val-nakl * 100 / v-val-post

            sum-doc1-nakl = sum-doc1-nakl + v-val-nakl
            sum-doc-nakl = sum-doc-nakl + v-val-nakl
            sum-obj-nakl = sum-obj-nakl + v-val-nakl
            sum-all-nakl = sum-all-nakl + v-val-nakl
          .

          if p-post-2 = 2 then do: /* надо сравнивать с накладными */
            display stream PrnLibStream sym1  v-bar-code sym2  v-goods-artic sym3  v-goods-name sym4  v-goods-unit sym5  v-val-post sym6  v-date-post sym7  v-time-post sym8  v-cost-post sym9  v-val-nakl sym10 v-date-nakl sym11 v-time-nakl sym12 v-cost-nakl sym13 v-prc sym14 with frame f-doc.
            down stream PrnLibStream with frame f-doc .
          end.
          else do:
            display stream PrnLibStream sym1  v-bar-code sym2  v-goods-artic sym3  v-goods-name sym4  v-goods-unit sym5  v-val-post sym6  v-date-post sym7  v-time-post sym8  v-cost-post sym9  v-val-nakl sym10 v-date-nakl sym11 v-time-nakl sym12 v-cost-nakl sym13 v-prc sym14 with frame f-doc1.
            down stream PrnLibStream with frame f-doc1 .
          end.
          num#str# = num#str# + 1.
          num#col# = 1.
            run macr_excel_char_with_format (v-bar-code    , num#str# , num#col# ). assign  num#col# = num#col# + 1 .
            run macr_excel_char_with_format (v-goods-artic , num#str# , num#col# ). assign  num#col# = num#col# + 1 .
            run macr_excel_char_with_format (v-goods-name  , num#str# , num#col# ). assign  num#col# = num#col# + 1 .
            run macr_excel_char_with_format (v-goods-unit  , num#str# , num#col# ). assign  num#col# = num#col# + 1 .
            run macr_excel_dec         (v-val-post    , num#str# , num#col# ). assign  num#col# = num#col# + 1 .
            run macr_excel_char_with_format (v-date-post   , num#str# , num#col# ). assign  num#col# = num#col# + 1 .
            run macr_excel_char_with_format (v-time-post   , num#str# , num#col# ). assign  num#col# = num#col# + 1 .
            run macr_excel_dec         (v-cost-post   ,  num#str# , num#col# ). assign  num#col# = num#col# + 1 .
            run macr_excel_dec         (v-val-nakl    , num#str# , num#col# ). assign  num#col# = num#col# + 1 .
            run macr_excel_char_with_format (v-date-nakl   , num#str# , num#col# ). assign  num#col# = num#col# + 1 .
            run macr_excel_char_with_format (v-time-nakl   ,  num#str# , num#col# ). assign  num#col# = num#col# + 1 .
            run macr_excel_dec         (v-cost-nakl   , num#str# , num#col# ). assign  num#col# = num#col# + 1 .
            run macr_excel_dec         (v-prc,          num#str# , num#col# ). assign  num#col# = num#col# + 1 .

          if NumPost > 1 then do:
            assign  StatOtkl = 0  .
            for each Temp-i no-lock :
              if StatOtkl = 0 then assign StatOtkl = 1 .
              else do:
                assign
                  v-val-nakl  = Temp-i.i-val-nakl
                  v-date-nakl = Temp-i.i-date-nakl
                  v-time-nakl = Temp-i.i-time-nakl
                  v-cost-nakl = Temp-i.i-cost-nakl
                  v-prc = v-val-nakl * 100 / v-val-post

                  sum-doc1-nakl = sum-doc1-nakl + v-val-nakl
                  sum-doc-nakl = sum-doc-nakl + v-val-nakl
                  sum-obj-nakl = sum-obj-nakl + v-val-nakl
                  sum-all-nakl = sum-all-nakl + v-val-nakl
                .

                if p-post-2 = 2 then do: /* надо сравнивать с накладными */
                  display stream PrnLibStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 v-val-nakl sym10 v-date-nakl sym11 v-time-nakl sym12 v-cost-nakl sym13 v-prc sym14 with frame f-doc.
                  down stream PrnLibStream with frame f-doc .
                end.
                else do:
                  display stream PrnLibStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 v-val-nakl sym10 v-date-nakl sym11 v-time-nakl sym12 v-cost-nakl sym13 v-prc sym14 with frame f-doc1.
                  down stream PrnLibStream with frame f-doc1 .
                end.
                num#str# = num#str# + 1.
                num#col# = 9.
                  run macr_excel_dec         (v-val-nakl    , num#str# , num#col# ). assign  num#col# = num#col# + 1 .
                  run macr_excel_char_with_format (v-date-nakl   , num#str# , num#col# ). assign  num#col# = num#col# + 1 .
                  run macr_excel_char_with_format (v-time-nakl   ,  num#str# , num#col# ). assign  num#col# = num#col# + 1 .
                  run macr_excel_dec         (v-cost-nakl   , num#str# , num#col# ). assign  num#col# = num#col# + 1 .
                  run macr_excel_dec         (v-prc,          num#str# , num#col# ). assign  num#col# = num#col# + 1 .

              end.
            end.

            if p-post-2 = 2 then do: /* надо сравнивать с накладными */
              assign
                v-goods-name = "Всего по накладным:"
                v-val-nakl   = sum-doc1-nakl
                v-prc        = v-val-nakl * 100 / v-val-post
              .
              display stream PrnLibStream sym1 sym2 sym3 v-goods-name sym4 sym5 sym6 sym7 sym8 sym9 v-val-nakl sym10 sym11 sym12 sym13 v-prc sym14 with frame f-doc.
              down stream PrnLibStream with frame f-doc .
            end.
            else do:
              assign
                v-goods-name = "Всего по поставкам:"
                v-val-nakl   = sum-doc1-nakl
                v-prc        = v-val-nakl * 100 / v-val-post
              .
              display stream PrnLibStream sym1 sym2 sym3 v-goods-name sym4 sym5 sym6 sym7 sym8 sym9 v-val-nakl sym10 sym11 sym12 sym13 v-prc sym14 with frame f-doc1.
              down stream PrnLibStream with frame f-doc1 .
            end.
            num#str# = num#str# + 1.
            num#col# = 3.

              run macr_excel_char_with_format (v-goods-name  , num#str# , num#col# ). assign  num#col# = num#col# + 6 .
              run macr_excel_dec         (v-val-nakl    , num#str# , num#col# ). assign  num#col# = num#col# + 4 .
              run macr_excel_dec         (v-prc         , num#str# , num#col# ).
              run macr_cell_format (
                  10       , /*p-size-font */
                  true     , /*p-bold      */
                  false    , /*p-italic    */
                  36       , /*p-color-bg  */
                  num#str# , /*p-row       */
                  3        , /*p-col       */
                  num#str# , /*p-row-2     */
                  num#col# ) /*p-col-2     */
                  .
               assign  num#col# = num#col# + 1 .
          end.
        end.
      end.

      if p-tg-zay = yes then do: /* раздельно по поставкам  - итого */
        if PrnNum = yes then do:
          assign
            v-goods-name = "Всего по заказу:"
            v-val-post   = sum-doc-post
            v-val-nakl   = sum-doc-nakl
            v-prc        = v-val-nakl * 100 / v-val-post
          .
          if p-post-2 = 2 then do: /* надо сравнивать с накладными */
            display stream PrnLibStream sym1 sym2 sym3 v-goods-name sym4 sym5 v-val-post sym6 sym7 sym8 sym9 v-val-nakl sym10 sym11 sym12 sym13 v-prc sym14 with frame f-doc.
            down stream PrnLibStream with frame f-doc .
          end.
          else do:
            display stream PrnLibStream sym1 sym2 sym3 v-goods-name sym4 sym5 v-val-post sym6 sym7 sym8 sym9 v-val-nakl sym10 sym11 sym12 sym13 v-prc sym14 with frame f-doc1.
            down stream PrnLibStream with frame f-doc1 .
          end.
            num#str# = num#str# + 1.
            num#col# = 3.
              run macr_excel_char_with_format (v-goods-name  , num#str# , num#col# ). assign  num#col# = num#col# + 2 .
              run macr_excel_dec         (v-val-post    , num#str# , num#col# ). assign  num#col# = num#col# + 4 .
              run macr_excel_dec         (v-val-nakl    , num#str# , num#col# ). assign  num#col# = num#col# + 4 .
              run macr_excel_dec         (v-prc         , num#str# , num#col# ).
              run macr_cell_format (
                  11       , /*p-size-font */
                  true     , /*p-bold      */
                  false    , /*p-italic    */
                  37       , /*p-color-bg  */
                  num#str# , /*p-row       */
                  3        , /*p-col       */
                  num#str# , /*p-row-2     */
                  num#col# ) /*p-col-2     */
                  .
              assign  num#col# = num#col# + 1 .

        end.
      end.
    end.  /* for each buf_ord-doc */

    if PrnObj = yes then do:
      assign
        v-goods-name = "Всего по объекту:"
        v-val-post   = sum-obj-post
        v-val-nakl   = sum-obj-nakl
        v-prc        = v-val-nakl * 100 / v-val-post
      .

      if p-post-2 = 2 then do: /* надо сравнивать с накладными */
        display stream PrnLibStream sym1 sym2 sym3 v-goods-name sym4 sym5 v-val-post sym6 sym7 sym8 sym9 v-val-nakl sym10 sym11 sym12 sym13 v-prc sym14 with frame f-doc.
        down stream PrnLibStream with frame f-doc .
        display stream PrnLibStream sym1 sym13 sym14 with frame f-doc.
        down stream PrnLibStream with frame f-doc .
      end.
      else do:
        display stream PrnLibStream sym1 sym2 sym3 v-goods-name sym4 sym5 v-val-post sym6 sym7 sym8 sym9 v-val-nakl sym10 sym11 sym12 sym13 v-prc sym14 with frame f-doc1.
        down stream PrnLibStream with frame f-doc1 .
        display stream PrnLibStream sym1 sym13 sym14 with frame f-doc1.
        down stream PrnLibStream with frame f-doc1 .
      end.
      num#str# = num#str# + 1.
      num#col# = 3.
        run macr_excel_char_with_format (v-goods-name  , num#str# , num#col# ). assign  num#col# = num#col# + 2 .
        run macr_excel_dec         (v-val-post    , num#str# , num#col# ). assign  num#col# = num#col# + 4 .
        run macr_excel_dec         (v-val-nakl    , num#str# , num#col# ). assign  num#col# = num#col# + 4 .
        run macr_excel_dec         (v-prc,          num#str# , num#col# ).
        run macr_cell_format (
            10       , /*p-size-font */
            true     , /*p-bold      */
            false    , /*p-italic    */
            38       , /*p-color-bg  */
            num#str# , /*p-row       */
            3        , /*p-col       */
            num#str# , /*p-row-2     */
            num#col# ) /*p-col-2     */
            .
            assign  num#col# = num#col# + 1 .

    end.

  end. /* for each obj-list  */

  assign
    v-goods-name = "ИТОГО:"
    v-val-post   = sum-all-post
    v-val-nakl   = sum-all-nakl
    v-prc        = v-val-nakl * 100 / v-val-post
  .

  if p-post-2 = 2 then do: /* надо сравнивать с накладными */
    display stream PrnLibStream sym1 sym2 sym3 v-goods-name sym4 sym5 v-val-post sym6 sym7 sym8 sym9 v-val-nakl sym10 sym11 sym12 sym13 v-prc sym14 with frame f-doc.
    down stream PrnLibStream with frame f-doc .
  end.
  else do:
    display stream PrnLibStream sym1 sym2 sym3 v-goods-name sym4 sym5 v-val-post sym6 sym7 sym8 sym9 v-val-nakl sym10 sym11 sym12 sym13 v-prc sym14 with frame f-doc1.
    down stream PrnLibStream with frame f-doc1 .
  end.
  assign
    num#str# = num#str# + 1
    num#col# =  3
    var-1 = num#str#
    var-2 = num#col#
    .

    run macr_excel_char_with_format (v-goods-name , num#str# , num#col# ). assign   num#col# = num#col# + 2.
    run macr_excel_dec (v-val-post , num#str# , num#col# ). assign   num#col# = num#col# + 4.
    run macr_excel_dec (v-val-nakl , num#str# , num#col# ). assign   num#col# = num#col# + 4.
    run macr_excel_dec (round(v-prc,2) , num#str# , num#col# ).
    run macr_cell_format (
        10       , /*p-size-font */
        true     , /*p-bold      */
        false    , /*p-italic    */
        39       , /*p-color-bg  */
        num#str# , /*p-row       */
        3        , /*p-col       */
        num#str# , /*p-row-2     */
        num#col# ) /*p-col-2     */
        .


  PUT STREAM PrnLibStream Line format "X(190)".

  HIDE stream PrnLibStream FRAME BottomFrame .
  OUTPUT stream PrnLibStream CLOSE.
  Output stream Macr_Excel  close .

  run paramls-write in this-procedure
    (input "file"
    ,input string(v-ind)
    ,input v-file-name
    ) .

  run paramls-write in this-procedure
      (input "charcol"
      ,input ""
      ,input "2,3,4,6,7,10,11"
      ) .

  run end-proc .
  { rep/repfrm.i off } /* убрать окно информации о текущем процессе */

  { gbl/stopwork.i }

  run prn-lib-prn-file in this-procedure (input parParentProc,input 8).

END.

procedure proc-print-header-my :
 do
 on error undo, return error return-value
 :
/* Шапка */
   find first sheetf .
     sheetf.excel-row-heder =  num-entries( c-str ,{&new-line}) + 1.
     sheetf.excel-row-title =  num-entries( sheetf.excel-column-lable , {&new-line} ).
     var-1 =  num#str# .
     repeat c-c = 1 to sheetf.excel-row-title :
     num#str# = num#str# + 1 .

     p-var = num-entries( entry (c-c, sheetf.excel-column-lable, {&new-line}) , {&comma-char} ) .

     do c-i = 1 to p-var :
        str--1 = entry( c-i, entry (c-c,sheetf.excel-column-lable, {&new-line}) , {&comma-char}) .
        str--2 = integer(entry( c-i, sheetf.sizes )) .
        num#col# = c-i .
        run macr_excel_char ( str--1  , num#str# , num#col#  ) .
        run macr_cell_size ( str--2 , ? , num#str# , num#col# , ?, ? ) .
     end.

    c-i = 0.
    end.

    run macr_cell_format (
        10       , /*p-size-font */
        true     , /*p-bold      */
        false    , /*p-italic    */
        35       , /*p-color-bg  */
        var-1 + 1, /*p-row       */
        1        , /*p-col       */
        num#str# , /*p-row-2     */
        num#col# ) /*p-col-2     */
        .
  put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , var-1 + 1 , 1 , num#str# ,  num#col# ) + {&new-line}  +
        'BORDER( 2 , 2 , 2 , 2 , 2 , ,0,0,0,0,0) '  + {&new-line} +
       'ALIGNMENT(3 , , 4 , 4 ,)'  + {&new-line}
       .


 end. /* do */
end procedure. /* proc-print-header-my */

{ rep/r-libmcr.i macr_excel         }