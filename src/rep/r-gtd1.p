block-level on error undo, throw.

/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-gtd1.p $
$Archive: rep/r-gtd1.p $

Отчет о товарах в магазине беспошлинной торговли

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/27/06
Author: Michael Kochetkov
Creation date: 03/27/06

*/

do
on error undo, return error
:
  define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
  define variable vss-author      as character no-undo init "$Author: expertek $":U .
  define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
  define variable vss-workfile    as character no-undo init "$Workfile: r-gtd1.p $":U .
  define variable vss-archive     as character no-undo init "$Archive: rep/r-gtd1.p $":U .
  define variable vss-description as character no-undo init "Отчет о товарах в магазине беспошлинной торговли".
  { cmp/vssrevis.i }

  { cmp/str-glbl.i }
  { cmp/r-page1.i }
  { rep/r-sym.i }
  { cmp/r-pril.i }
  { rep/r-cost.i }
  { rep/r-sale.i }
  { rep/f-fdec.i }   /* Функции для форматирования полей для передачи в EXcel         */
  { gbl/paramls.i }
  { trg/factord.i }
  { trg/partslib.i }
  { ref/grplibfn.i }
  { rep/lkp-font.i }

  DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
  ASSIGN parParentProc =  my-handle .

  define variable g#report-num as integer   no-undo .
  run get-report-num  in parParentProc ( output g#report-num ).

  define variable g#gds-engl as logical   no-undo .
  run get-gds-engl  in parParentProc ( output g#gds-engl ).

  { rep/mcrexcel.i }

&scop P-X     198 /* 233*/
&scop P-X0    196 /* длина внутренней линии = {&P-X} - 2*/
&scop P-X1    35
&scop P-C1-S  8
&scop P-C2-S  35
&scop P-C21-S 50
&scop P-C3-S  83
&scop P-C4-S  96
&scop P-C5-S  112
&scop P-C6-S  128
&scop P-C7-S  144
&scop P-C8-S  162
&scop P-C9-S  171
&scop P-C10-S 180
&scop P-E     198

&scop F1      ">>>>>9"
&scop F2      "X(26)"
&scop F3      "X(32)"
&scop F4      "X(12)"
&scop F5      "X(14)"
&scop F6      "->>,>>>,>>9.999"
/*&scop F6      "->>>>,>>>,>>9.999"*/

  define Stream OutStream.
  define Stream macr_excel.

  define var    v-fact-order-start     as decimal   no-undo .
  define var    v-fact-order-end       as decimal   no-undo .
  run day-begin-fact-order in this-procedure ( input x-date-start, output v-fact-order-start ). /*Поиск нач fact-order*/
  run day-begin-fact-order in this-procedure ( input ( x-date-end + 1 ),   output v-fact-order-end ). /*Поиск посл fact-order*/

  define temp-table temp-gds-obj no-undo  /* для списка товаров */
    field obj-code  like gds-obj.obj-code
    field obj-type  like gds-obj.obj-type
    field artic     like goods.artic
    field prod-code like goods.prod-code
    field prod-type like goods.prod-type
    field gds-name  like goods.gds-name
    field grp-name  like goods.grp-name
/*    field unit-base like goods.unit-base*/
    field nat       like goods.nationality
    INDEX pi  IS PRIMARY obj-type obj-code artic  prod-type  prod-code
  .

  define temp-table temp-goods no-undo  /* для списка партий */
    field artic     like goods.artic
    field prod-code like goods.prod-code
    field prod-type like goods.prod-type
    field gds-name  like goods.gds-name
    field grp-name  like goods.grp-name
/*    field unit-base like goods.unit-base*/
    field nat       like goods.nationality
    field part-code like parts.part-code
    field in-code   like parts.in-code
    field gtd-code  like parts.cst-code
    field is-new    as logical initial no
    field gtd-date      as date
    field p-ost         as decimal
    field p-ves         as decimal
    field p-prod        as decimal
    field p-spis        as decimal
    INDEX pi  IS PRIMARY artic  prod-type  prod-code  in-code part-code
    INDEX pi1   grp-name
    INDEX pi2   gtd-code
    INDEX pi3   gtd-date
  .

  define buffer buf_goods    for goods.
  define buffer buf_clients  for clients.
  define buffer buf_trn-doc for  trn-doc .
  define buffer buf_doc-line for doc-line.
  define buffer buf_parts    for parts.
  define buffer buf_gds-obj  for gds-obj .
  define buffer buf_gds-grp  for gds-grp .

  define variable  Counter1    as integer initial 0  no-undo .
  define variable  ii          as integer   no-undo .
  define variable  CurrGrpName as character no-undo .
  define variable  Line        as character no-undo .
  define variable  v-row       as integer   no-undo .
  define variable  v-col       as integer   no-undo .
  define variable  v-ind       as integer   no-undo initial 1 .
  define variable  str         as character no-undo .

  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 10 } /* Показать окно информации о текущем процессе */

  if x-SelectGood = {&g-all} then do: /* все товары */
    for each buf_goods no-lock :
      for each obj-list :
        find first buf_gds-obj no-lock
          where buf_gds-obj.gds-code  = buf_goods.gds-code
            and buf_gds-obj.obj-type  = obj-list.obj-type
            and buf_gds-obj.obj-code  = obj-list.obj-code
        no-error .
        if not available buf_gds-obj then next.
        assign Counter1 = Counter1 + 1.
        { rep/repfrm.i disp Counter1 }
        create temp-gds-obj .
        assign
          temp-gds-obj.obj-code  = buf_gds-obj.obj-code
          temp-gds-obj.obj-type  = buf_gds-obj.obj-type
          temp-gds-obj.artic     = buf_goods.artic
          temp-gds-obj.prod-code = buf_goods.prod-code
          temp-gds-obj.prod-type = buf_goods.prod-type
          temp-gds-obj.grp-name  = buf_goods.grp-name
          temp-gds-obj.nat       = buf_goods.nationality
        .
        if g#gds-engl then assign temp-gds-obj.gds-name = buf_goods.engl-name.
        else               assign temp-gds-obj.gds-name = buf_goods.gds-name.
      end.
    end.
  end.
  else do:
    for each obj-list :                /* встать на объект */
      case x-SelectGood :
        when {&g-choice}   or
        when {&g-one}      or
        when {&g-spis}     or
        when {&g-grp-prod}
        then do: /* список товаров */
          for each gds-list ,
              each buf_gds-obj no-lock
            where buf_gds-obj.obj-type  = obj-list.obj-type
              and buf_gds-obj.obj-code  = obj-list.obj-code
              and buf_gds-obj.artic     = gds-list.artic
              and buf_gds-obj.prod-type = gds-list.prod-type
              and buf_gds-obj.prod-code = gds-list.prod-code
            :
            find first buf_goods no-lock where buf_goods.gds-code = buf_gds-obj.gds-code .
            assign Counter1 = Counter1 + 1.
            { rep/repfrm.i disp Counter1 }
            create temp-gds-obj .
            assign
              temp-gds-obj.obj-code  = buf_gds-obj.obj-code
              temp-gds-obj.obj-type  = buf_gds-obj.obj-type
              temp-gds-obj.artic     = buf_goods.artic
              temp-gds-obj.prod-code = buf_goods.prod-code
              temp-gds-obj.prod-type = buf_goods.prod-type
              temp-gds-obj.grp-name  = buf_goods.grp-name
              temp-gds-obj.nat       = buf_goods.nationality
            .
            if g#gds-engl then assign temp-gds-obj.gds-name = buf_goods.engl-name.
            else               assign temp-gds-obj.gds-name = buf_goods.gds-name.
          end.
        end.
        when {&g-prod} then do:    /* не все производители */
          for each G#cli : /* встать на производителя */
            find first  buf_clients no-lock
              where buf_clients.obj-type = G#cli.obj-type
                and buf_clients.obj-code = G#cli.obj-code
            .
            for each buf_gds-obj  no-lock
              where buf_gds-obj.obj-type  = obj-list.obj-type
                and buf_gds-obj.obj-code  = obj-list.obj-code
                and buf_gds-obj.prod-type = buf_clients.obj-type
                and buf_gds-obj.prod-code = buf_clients.obj-code
              use-index pi  :
              find first buf_goods no-lock where buf_goods.gds-code = buf_gds-obj.gds-code .
              assign Counter1 = Counter1 + 1.
              { rep/repfrm.i disp Counter1 }
              create temp-gds-obj .
              assign
                temp-gds-obj.obj-code  = buf_gds-obj.obj-code
                temp-gds-obj.obj-type  = buf_gds-obj.obj-type
                temp-gds-obj.artic     = buf_goods.artic
                temp-gds-obj.prod-code = buf_goods.prod-code
                temp-gds-obj.prod-type = buf_goods.prod-type
                temp-gds-obj.grp-name  = buf_goods.grp-name
                temp-gds-obj.nat       = buf_goods.nationality
              .
              if g#gds-engl then assign temp-gds-obj.gds-name = buf_goods.engl-name.
              else               assign temp-gds-obj.gds-name = buf_goods.gds-name.
            end .
          end.                /* do ... по производителям */
        end .
        when {&g-grp} then do:    /* не все группы товаров */
          for each tmp#grp :
            find first buf_gds-grp no-lock where buf_gds-grp.node-code = tmp#grp.node-code .
            run grplib-get-full-name in this-procedure (
                                                         input buf_gds-grp.node-code
                                                       , output CurrGrpName).

            for each buf_gds-obj no-lock
              where buf_gds-obj.obj-type = obj-list.obj-type
                and buf_gds-obj.obj-code = obj-list.obj-code
                and buf_gds-obj.grp-name begins CurrGrpName
              use-index obj-grp :
              find first buf_goods no-lock where buf_goods.gds-code = buf_gds-obj.gds-code   .
              assign Counter1 = Counter1 + 1.
              { rep/repfrm.i disp Counter1 }
              create temp-gds-obj .
              assign
                temp-gds-obj.obj-code  = buf_gds-obj.obj-code
                temp-gds-obj.obj-type  = buf_gds-obj.obj-type
                temp-gds-obj.artic     = buf_goods.artic
                temp-gds-obj.prod-code = buf_goods.prod-code
                temp-gds-obj.prod-type = buf_goods.prod-type
                temp-gds-obj.grp-name  = buf_goods.grp-name
                temp-gds-obj.nat       = buf_goods.nationality
              .
              if g#gds-engl then assign temp-gds-obj.gds-name = buf_goods.engl-name.
              else               assign temp-gds-obj.gds-name = buf_goods.gds-name.
            end .
          end.    /* do i = 1 to num-entries ( gdsgrp_recids ) : */
        end.
      end case.
    end.                    /* for each ... по объектам */
  end.

  /* теперь ищем партиии на начало и заполняем тт */
  for each temp-gds-obj :
    run partslib-init-temp-parts-by-factord (input temp-gds-obj.obj-type,
                                             input temp-gds-obj.obj-code,
                                             input temp-gds-obj.artic,
                                             input temp-gds-obj.prod-type,
                                             input temp-gds-obj.prod-code,
                                             input v-fact-order-start,
                                             false) .
    for each temp-parts :
      if temp-parts.fact-qnty = 0 then next .
      assign  Counter1 = Counter1 + 1 .
      { rep/repfrm.i disp Counter1 }
      find first temp-goods
        where temp-goods.artic     = temp-parts.artic
          and temp-goods.prod-code = temp-parts.prod-code
          and temp-goods.prod-type = temp-parts.prod-type
          and temp-goods.part-code = temp-parts.part-code
          and temp-goods.in-code   = temp-parts.in-code
        no-error .
      if not available temp-goods then do:
        create temp-goods .
        assign
          temp-goods.artic     = temp-gds-obj.artic
          temp-goods.prod-code = temp-gds-obj.prod-code
          temp-goods.prod-type = temp-gds-obj.prod-type
          temp-goods.gds-name  = temp-gds-obj.gds-name
          temp-goods.grp-name  = temp-gds-obj.grp-name
          temp-goods.nat       = temp-gds-obj.nat
          temp-goods.part-code = temp-parts.part-code
          temp-goods.in-code   = temp-parts.in-code
          temp-goods.gtd-code  = temp-parts.cst-code
          temp-goods.p-ost     = temp-parts.fact-qnty
          temp-goods.p-ves     = 0
          temp-goods.p-prod    = 0
          temp-goods.p-spis    = 0
        .
        run GetDateGTD (input temp-goods.gtd-code, output temp-goods.gtd-date) .
        /* ищем приходную накладную */
        find first buf_doc-line no-lock
          where buf_doc-line.doc-code  = temp-parts.in-code
            and buf_doc-line.artic     = temp-gds-obj.artic
            and buf_doc-line.prod-type = temp-gds-obj.prod-type
            and buf_doc-line.prod-code = temp-gds-obj.prod-code
        no-error .
        if available buf_doc-line then assign temp-goods.p-ves = buf_doc-line.wt-brutto / buf_doc-line.fact-qnty .
      end.
      else assign temp-goods.p-ost = temp-goods.p-ost + temp-parts.fact-qnty .
    end.
  end.

  /* теперь ищем приходы в интервале */
  for each temp-gds-obj :
    for each buf_doc-line no-lock
      where buf_doc-line.obj-type  = temp-gds-obj.obj-type
        and buf_doc-line.obj-code  = temp-gds-obj.obj-code
        and buf_doc-line.artic     = temp-gds-obj.artic
        and buf_doc-line.prod-type = temp-gds-obj.prod-type
        and buf_doc-line.prod-code = temp-gds-obj.prod-code
        and buf_doc-line.status_   = {&fact}
        and buf_doc-line.fact-order >= v-fact-order-start
        and buf_doc-line.fact-order < v-fact-order-end
      :
      for each buf_parts no-lock
        where buf_parts.out-code  = buf_doc-line.doc-code
          and buf_parts.obj-type  = buf_doc-line.obj-type
          and buf_parts.obj-code  = buf_doc-line.obj-code
          and buf_parts.artic     = buf_doc-line.artic
          and buf_parts.prod-type = buf_doc-line.prod-type
          and buf_parts.prod-code = buf_doc-line.prod-code
        :
        assign Counter1 = Counter1 + 1.
        { rep/repfrm.i disp Counter1 }

        if buf_doc-line.ext-doc-type = {&TDEDT_Pri_Vnesh} or
/*           buf_doc-line.ext-doc-type = {&TDEDT_Pri_Perem} or*/
           buf_parts.in-code = buf_parts.out-code then do:
          find first temp-goods
            where temp-goods.artic     = temp-parts.artic
              and temp-goods.prod-code = temp-parts.prod-code
              and temp-goods.prod-type = temp-parts.prod-type
              and temp-goods.part-code = temp-parts.part-code
              and temp-goods.in-code   = temp-parts.in-code
            no-error .
          if not available temp-goods then do:
            create temp-goods .
            assign
              temp-goods.artic     = temp-gds-obj.artic
              temp-goods.prod-code = temp-gds-obj.prod-code
              temp-goods.prod-type = temp-gds-obj.prod-type
              temp-goods.gds-name  = temp-gds-obj.gds-name
              temp-goods.grp-name  = temp-gds-obj.grp-name
              temp-goods.nat       = temp-gds-obj.nat
              temp-goods.part-code = buf_parts.part-code
              temp-goods.in-code   = buf_parts.in-code
              temp-goods.gtd-code  = buf_parts.cst-code
              temp-goods.p-prod    = 0
              temp-goods.p-spis    = 0
            .
            if buf_doc-line.ext-doc-type = {&TDEDT_Pri_Vnesh} /* or
               buf_doc-line.ext-doc-type = {&TDEDT_Pri_Perem}*/ then assign temp-goods.p-ves = buf_doc-line.wt-brutto / buf_doc-line.fact-qnty .
            else assign temp-goods.is-new = yes .
            run GetDateGTD (input temp-goods.gtd-code, output temp-goods.gtd-date) .
          end.
          assign temp-goods.p-ost = temp-goods.p-ost + buf_parts.fact-qnty .
        end.
      end.
    end.
  end.

  /* теперь ищем расходы в интервале */
  for each temp-gds-obj :
    for each buf_doc-line no-lock
      where buf_doc-line.obj-type  = temp-gds-obj.obj-type
        and buf_doc-line.obj-code  = temp-gds-obj.obj-code
        and buf_doc-line.artic     = temp-gds-obj.artic
        and buf_doc-line.prod-type = temp-gds-obj.prod-type
        and buf_doc-line.prod-code = temp-gds-obj.prod-code
        and buf_doc-line.status_   = {&fact}
        and buf_doc-line.fact-order >= v-fact-order-start
        and buf_doc-line.fact-order < v-fact-order-end
        and ( buf_doc-line.ext-doc-type  = {&TDEDT_Ras_Vnesh_VP}       or
              buf_doc-line.ext-doc-type  = {&TDEDT_Inv}                or
              buf_doc-line.ext-doc-type  = {&TDEDT_Peresort}           or
              buf_doc-line.ext-doc-type  = {&TDEDT_Spi_Vnesh}          or
              buf_doc-line.ext-doc-type  = {&TDEDT_Ras_Vnesh_Kass}     or
              buf_doc-line.ext-doc-type  = {&TDEDT_Ras_Vnesh}          or
              buf_doc-line.ext-doc-type  = {&TDEDT_Vozvrat_Vnesh_Kass} or
              buf_doc-line.ext-doc-type  = {&TDEDT_Vozvrat_Vnesh} )
      :
      for each buf_parts no-lock
        where buf_parts.out-code  = buf_doc-line.doc-code
          and buf_parts.obj-type  = buf_doc-line.obj-type
          and buf_parts.obj-code  = buf_doc-line.obj-code
          and buf_parts.artic     = buf_doc-line.artic
          and buf_parts.prod-type = buf_doc-line.prod-type
          and buf_parts.prod-code = buf_doc-line.prod-code
        :
        assign Counter1 = Counter1 + 1.
        { rep/repfrm.i disp Counter1 }

        find first temp-goods
          where temp-goods.artic     = buf_parts.artic
            and temp-goods.prod-code = buf_parts.prod-code
            and temp-goods.prod-type = buf_parts.prod-type
            and temp-goods.part-code = buf_parts.part-code
            and temp-goods.in-code   = buf_parts.in-code
          no-error .
        if not available temp-goods then next .
        case buf_doc-line.ext-doc-type :
          when {&TDEDT_Ras_Vnesh_VP}  then assign  temp-goods.p-ost  = temp-goods.p-ost  - buf_parts.fact-qnty .
/*          when {&TDEDT_Spi_Prvo}           or*/
          when {&TDEDT_Inv}           then assign  temp-goods.p-spis = temp-goods.p-spis - buf_parts.fact-qnty .
          when {&TDEDT_Peresort}      then assign  temp-goods.p-spis = temp-goods.p-spis - buf_parts.fact-qnty .
          when {&TDEDT_Spi_Vnesh}     then assign  temp-goods.p-spis = temp-goods.p-spis + buf_parts.fact-qnty .
/*          when {&TDEDT_Ras_Perem}          or*/
          when {&TDEDT_Ras_Vnesh_Kass}     or
          when {&TDEDT_Ras_Vnesh}     then assign  temp-goods.p-prod = temp-goods.p-prod + buf_parts.fact-qnty .
/*          when {&TDEDT_Vozvrat_Perem}      or*/
          when {&TDEDT_Vozvrat_Vnesh_Kass} or
          when {&TDEDT_Vozvrat_Vnesh} then assign  temp-goods.p-prod = temp-goods.p-prod - buf_parts.fact-qnty .
        end.
      end.
    end.
  end.

  /* macr_excel - для экселя */
  assign
    make-excel = yes
    v-file-name = string(session :temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt"
  .
  output stream macr_excel to value(v-file-name) .
  assign v-ind = v-ind + 1 .

  { gbl/working.i }

  assign  Line = fill("-", 250) .

  { cmp/open-out.i stream OutStream " " ReportPageHeight }

  FORM HEADER
      Line format "X({&P-X})" AT 1 SKIP
      "Продолжение - на следующей странице" AT 30 SKIP
      with FRAME BottomFrame width {&DOS_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW stream OutStream FRAME BottomFrame .

  PUT stream OutStream
    SPACE(20) "Отчет о товарах, помещенных под таможенный режим магазина беспошлинной"  format "X(100)" SKIP
    SPACE(26) "торговли и реализованных в магазине беспошлинной торговли"  format "X(100)" SKIP
    SPACE(36) String( "за период с " + String(x-Date-Start,"99.99.9999") + " по " + String(x-Date-End,"99.99.9999") )  format "X(100)" SKIP .

  run PutColumnTitul in this-procedure .
  run PutColumnTitulExcel in this-procedure .

  assign ii = 1 .
  for each temp-goods break by temp-goods.gtd-date by temp-goods.gtd-code by temp-goods.gds-name by temp-goods.artic :
    run end-page in this-procedure .
    if first-of(temp-goods.gtd-date ) then do:
      if temp-goods.gtd-date = date(1,1,1900) then assign str =  "Без даты ГТД" .
      else assign str = "Дата ГТД: " + string(temp-goods.gtd-date,"99.99.9999") .
      run macr_excel_char( str,  v-row, 2) .
      run macr_cell_format ( 10, yes, no, ?, v-row , 2, v-row, 2) .
      assign v-row = v-row + 1 .
      put stream outstream      "|"  "|" at {&P-C1-S}  str format {&F2}   "|"   at {&P-C2-S}  "|"   at {&P-C21-S}
         "|"   at {&P-C3-S}     "|"   at {&P-C4-S}     "|"   at {&P-C5-S}    "|"   at {&P-C6-S}
         "|"   at {&P-C7-S}     "|"   at {&P-C8-S}     "|"   at {&P-C9-S}    "|"   at {&P-C10-S}    "|"   at {&P-E}  skip
      .
    end.
    run  PrintString in this-procedure .
  end.

  PUT stream OutStream
    "|"    Line format "X({&P-X0})"   "|"    skip
    SPACE(10) "Наименование владельца"  format "X(50)" SKIP
    SPACE(10) "магазина беспошлинной торговли"  format "X(50)" SKIP (2)
    SPACE(10) "Ф.И.О. руководителя" format "X(20)" SPACE(20)  "Подпись" format "X(20)" SPACE(20) "Печать" format "X(20)" SPACE(20)  SKIP .

  output stream macr_excel close .
  run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name) .
  run end-proc .

  HIDE stream OutStream FRAME BottomFrame .
  OUTPUT stream OutStream CLOSE.

  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */
  { gbl/stopwork.i }

  define variable v-user-action as character no-undo .
  define variable v-printed as logical   no-undo .
  define variable v-orient-page as character no-undo .
  define variable DisabledOptions as integer   no-undo .
  run How-name in this-procedure (
      input ReportPageHeight,
      input ReportPageWidth,
      output v-orient-page )
      .
  if v-orient-page = "A4-lans":U then DisabledOptions = 8 .
                                 else DisabledOptions = 0 .


  run gbl/prnfilen.w
    (input  ""
    ,input  DisabledOptions
    ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
    ,input  ReportFontNum
    ,output v-user-action
    ,output v-printed
    ) .

end.


procedure PrintString :
  do
  on error undo, return error return-value
  :
    define variable ost-end as decimal initial 0  no-undo .
    assign ost-end = temp-goods.p-ost  .
    if temp-goods.p-prod > 0 or temp-goods.is-new = no then assign ost-end = ost-end - temp-goods.p-prod .
    if temp-goods.p-spis > 0 or temp-goods.is-new = no then assign ost-end = ost-end - temp-goods.p-spis .

    run macr_excel_char(String(ii), v-row, 1) .
    run macr_excel_char(temp-goods.gtd-code, v-row, 2) .
    run macr_excel_char(temp-goods.artic,    v-row, 3) .
    run macr_excel_char(temp-goods.gds-name, v-row, 4) .
    run macr_excel_char(temp-goods.nat,      v-row, 5) .
    run macr_excel_sum (temp-goods.p-ost,    v-row, 6,   3) .
    run macr_excel_sum (temp-goods.p-ost * temp-goods.p-ves,  v-row, 7,  2) .
    run macr_excel_sum (temp-goods.p-prod,   v-row, 8,  2) .
    run macr_excel_sum (temp-goods.p-spis,   v-row, 9,  2) .
    run macr_excel_sum (ost-end,  v-row, 12,  2) .

    put stream outstream
      "|"   ii                                          format {&F1}
      "|"   temp-goods.gtd-code                         format {&F2}
      "|"   temp-goods.artic                            format {&F5}
      "|"   temp-goods.gds-name                         format {&F3}
      "|"   temp-goods.nat                              format {&F4}
      "|"   temp-goods.p-ost                            format {&F6}
      "|"   (temp-goods.p-ost * temp-goods.p-ves)       format {&F6}
      "|"   temp-goods.p-prod                           format {&F6}
      "|"   temp-goods.p-spis                           format {&F6}
      "|"   at {&P-C8-S}
      "|"   at {&P-C9-S}
      "|"   at {&P-C10-S}  ost-end   format {&F6}
      "|"   at {&P-E}  skip
    .

    assign
      v-row = v-row + 1
      ii = ii + 1
    .
  end.
end procedure. /* PrintTitul */



/* ******************************************************* */

procedure PutColumnTitulExcel : /* заголовки для колонок экселя */
  do
  on error undo, return error return-value
  :
  assign
    v-row = 4
    v-col = 1
  .
  run macr_excel_char ("Отчет о товарах, помещенных под таможенный режим магазина беспошлинной торговли", 1, 3) .
  run macr_excel_char ("и реализованных в магазине беспошлинной торговли", 2, 3) .
  run macr_excel_char (String( "за период с " + String(x-Date-Start,"99.99.9999") + " по " + String(x-Date-End,"99.99.9999") ) , 3, 3) .
  run macr_cell_format( 11, yes, no, ?, 1, 3, 3, 5) .

  run macr_excel_char("№ п/п", v-row, v-col) .
  run macr_cell_size (4,?, v-row, v-col,?,?).       assign v-col = v-col + 1 .
  run macr_excel_char("№ ГТД", v-row, v-col) .
  run macr_cell_size (20,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Артикул", v-row, v-col) .
  run macr_cell_size (20,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Краткое наименование товара", v-row, v-col) .
  run macr_cell_size (40,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Статус товаров", v-row, v-col) .
  run macr_cell_size (10,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Кол-во в ед. измер.", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Вес брутто", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).       assign v-col = v-col + 1 .
  run macr_excel_char("Кол-во, реализованное на дату отчета в ед. измер.", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Товары, в отношении которых таможенный режим магазина беспошлинной торговли изменен на иной", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 3 .
  run macr_excel_char("Остаток товаров, помещенных под таможенный режим магазина беспошлинной торговли на дату отчета в ед. измер.", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  assign  v-row = v-row + 1   v-col = 8 .
  run macr_excel_char("Кол-во в ед. измер.", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("таможенный режим", v-row, v-col) .
  run macr_cell_size (8,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("№ ГТД", v-row, v-col) .
  run macr_cell_size (8,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .

  run macr_cell_bordur ( v-row - 1, 1, v-row, 12) .
  run macr_cell_format ( 10, yes, no, 35, v-row - 1, 1, v-row, 12) .
  assign
    v-row = v-row + 1
    v-col = 1
  .
  end.
end procedure. /* PutColumnTitulExcel */


procedure PutColumnTitul : /* заголовки для колонок экселя */
  do
  on error undo, return error return-value
  :
    put stream outstream skip Line format "X({&P-X})" skip
        "|"                  "№ п/п"                       format "X(6)"
        "| "   at {&P-C1-S}  "№ ГТД"                       format "X(6)"
        "| "   at {&P-C2-S}  "Артикул"                     format "X(10)"
        "| "   at {&P-C21-S} "Краткое наименование товара" format "X(30)"
        "| "   at {&P-C3-S}  "Статус "                     format "X(10)"
        "|"    at {&P-C4-S}  "   Кол-во в"                 format "X(15)"
        "| "   at {&P-C5-S}  "Вес брутто"                  format "X(11)"
        "|"    at {&P-C6-S}  "Реализованное"               format "X(15)"
        "|"    at {&P-C7-S}  "Товары, в отнош. кот-х тамож. режим"  format "X(35)"
        "|"    at {&P-C10-S} "Остаток товаров"             format "X(15)"
        "|"    at {&P-E} skip
        "| "
        "| "   at {&P-C1-S}
        "| "   at {&P-C2-S}
        "| "   at {&P-C21-S}
        "| "   at {&P-C3-S}  "товаров"                              format "X(10)"
        "|"    at {&P-C4-S}  " ед. измер."                          format "X(15)"
        "| "   at {&P-C5-S}
        "|"    at {&P-C6-S}  "кол-во"                                format "X(15)"
        "|"    at {&P-C7-S}  "маг. беспошл. торг. изменен на иной"   format "X(35)"
        "|"    at {&P-C10-S} "кол-во"                                format "X(15)"
        "|"    at {&P-E} skip
        "| "
        "| "   at {&P-C1-S}
        "| "   at {&P-C2-S}
        "| "   at {&P-C21-S}
        "| "   at {&P-C3-S}
        "|"    at {&P-C4-S}
        "| "   at {&P-C5-S}
        "|"    at {&P-C6-S}
        "|"    at {&P-C7-S}  Line  format "X({&P-X1})"
        "|"    at {&P-C10-S}
        "|"    at {&P-E} skip
        "| "
        "| "   at {&P-C1-S}
        "| "   at {&P-C2-S}
        "| "   at {&P-C21-S}
        "| "   at {&P-C3-S}
        "|"    at {&P-C4-S}
        "| "   at {&P-C5-S}
        "|"    at {&P-C6-S}
        "|"    at {&P-C7-S}  "Кол-во в"                  format "X(11)"
        "|"    at {&P-C8-S}  "тамож"                     format "X(8)"
        "|"    at {&P-C9-S}  "№ ГТД"                     format "X(8)"
        "|"    at {&P-C10-S} "в ед. изм."                     format "X(15)"
        "|"    at {&P-E} skip
        "| "
        "| "   at {&P-C1-S}
        "| "   at {&P-C2-S}
        "| "   at {&P-C21-S}
        "| "   at {&P-C3-S}
        "|"    at {&P-C4-S}
        "| "   at {&P-C5-S}
        "|"    at {&P-C6-S}
        "|"    at {&P-C7-S}  "ед. измер."                format "X(15)"
        "|"    at {&P-C8-S}  "режим"                     format "X(8)"
        "|"    at {&P-C9-S}
        "|"    at {&P-C10-S}
        "|"    at {&P-E} skip
        "|"    Line format "X({&P-X0})"   "|"    skip
    .
  end.
end procedure. /* PutColumnTitulExcel */



procedure end-page :
  do
  on error undo, return error return-value
  :
    if  ( v-row ) >= 63000 then do:
      Output stream Macr_Excel  close .
      run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name ) .
      run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
      output stream  Macr_Excel to value(v-file-name) .
      v-ind = v-ind + 1 .
      run PutColumnTitulExcel in this-procedure .
    end.
    if line-counter( Outstream ) > page-size( Outstream ) then do:
      page stream OutStream .
      run PutColumnTitul in this-procedure .
    end.

  end.

end procedure. /* end-page */


procedure GetDateGTD :

  do
  on error undo, return error return-value
  :
    define input  parameter num as character no-undo .
    define output parameter dat as date      no-undo .

    if num-entries(num, '/') > 1 then assign dat = date(ENTRY(2, num, '/')) .
    else                              assign dat = date(1,1,1900) .
  end.

end procedure. /* GetDateGTD */