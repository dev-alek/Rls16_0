block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-slg-s.p $
$Archive: rep/r-slg-s.p $

Отчет Анализ продаж

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/23/06
Author: Michael Kochetkov
Creation date: 03/23/06

*/

define input parameter x-date-start1   as date      no-undo .
define input parameter x-date-end1     as date      no-undo .
define input parameter x-itog          as logical   no-undo .
define input parameter x-lavel         as integer   no-undo .
define input parameter x-return        as logical   no-undo .
define input parameter x-SumObj        as logical   no-undo .
define input parameter x-ShowNull      as logical   no-undo .
define input parameter x-RADIO-sel     as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-slg-s.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-slg-s.p $":U .
define variable vss-description as character no-undo init "Анализ продаж".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/r-page1.i  }
{ trg/factord.i  }
{ ref/grplib.i   }
{ rep/r-cost.i   }
{ rep/r-sale.i   }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ rep/rep-bt.i   }
{ rep/f-fdec.i }   /* Функции для форматирования полей для передачи в EXcel         */
{ gbl/paramls.i }
{ rep/mcrexcel.i }
{ rep/lkp-font.i }

&scop P-X     193 /* 233*/
&scop P-X0    191 /* длина внутренней линии = {&P-X} - 2*/
&scop P-X1    79
&scop P-X2    32
&scop P-C1-S  15
&scop P-C2-S  57
&scop P-C3-S  71
&scop P-C4-S  85
/*&scop P-C5-S  97*/
/*&scop P-C6-S  107*/
/*&scop P-C7-S  117*/
/*&scop P-C8-S  127*/
&scop P-C9-S  /*137*/  97
&scop P-C10-S /*151*/  111
&scop P-C11-S /*165*/  125
&scop P-C12-S /*177*/  137
&scop P-C13-S /*191*/  151
&scop P-C14-S /*205*/  162
&scop P-C15-S /*219*/  173
&scop P-C16-S /*219*/  184
&scop P-E     /*233*/  193

&scop F1      ">>>>>>>>>>>>9"
&scop F2      "X(40)"
&scop F3      "->,>>>,>>9.99"
&scop F4      "->,>>>,>>9.99"
&scop F5      "->>>,>>9.99"
&scop F6      "->,>>>,>>9.99"
&scop F7      "->,>>>,>>9.99"
&scop F8      "->>>,>>9.99"
&scop F9      "->,>>>,>>9.99"
&scop F10     "->>>>>>9"
&scop F11     ">>9.<<"

define Stream OutStream.

do
on error undo, return error
:

define buffer buf_goods    for goods.
define buffer buf_clients  for clients.
define buffer buf_gds-obj  for gds-obj.
define buffer buf_gds-grp  for gds-grp.
define buffer buf_trn-doc  for trn-doc.
define buffer buf_doc-line for doc-line.
define buffer buf_stk-line for stk-line.

DEFINE temp-table temp-DiscSales no-undo
    field   qnty             as decimal
    field   ostat            as decimal
    field   sum-sale         as decimal
    field   sum-cost         as decimal
    field   ostat1           as decimal
    field   qnty1            as decimal
    field   sum-sale1        as decimal
    field   sum-cost1        as decimal
    field   obj-type         as  char
    field   obj-code         as  integer
    field   prod-type        as  char
    field   prod-code        as  integer
    field   artic            as  char
    field   gds-name         as  char
    field   grp-name         as  char
    field   unit-base        as  char
    field   b-code           as  integer
    field   grp-code         as  integer
    field   full-grp-name    as  char
    INDEX pi  IS PRIMARY   obj-type obj-code artic  prod-type prod-code
    INDEX pi1              b-code
    INDEX pi2              full-grp-name
  .

  DEFINE temp-table temp-grp-sum no-undo
    field  qnty             as decimal
    field  ostat            as decimal
    field  sum-sale         as decimal
    field  sum-cost         as decimal
    field  qnty1            as decimal
    field  ostat1           as decimal
    field  sum-sale1        as decimal
    field  sum-cost1        as decimal
    field  grp              as character
    field  full_grp         as character
    field  num              as integer
    INDEX pi  IS PRIMARY unique num
    INDEX pi1 is unique full_grp
  .
  define variable  v-fact-order-start     as decimal   no-undo .
  define variable  v-fact-order-end       as decimal   no-undo .
  define variable  v-fact-order-start1    as decimal   no-undo .
  define variable  v-fact-order-end1      as decimal   no-undo .

  define variable p-fact-qnty     as decimal   no-undo .
  define variable p-cost-rubl     as decimal   no-undo .
  define variable p-sale-rubl     as decimal   no-undo .
  define variable t-dec           as decimal   no-undo .

  define variable v-row       as integer   no-undo .
  define variable v-col       as integer   no-undo .
  define variable v-ind       as integer   no-undo initial 1 .

  define variable titul           as logical   no-undo .
  define variable v-level         as integer   no-undo .
  define variable v-old-level as integer initial 0  no-undo .
  define variable ind             as integer   no-undo .
  define variable ret as logical   no-undo .
  define variable ii as integer initial 0  no-undo .
  define variable Counter1               as integer   no-undo .
  define variable CurrGrpName            as character no-undo .
  define variable Line                   as character no-undo .
  define variable sfind as character no-undo .
  define variable jj as integer   no-undo .
  define variable udel as decimal   no-undo .

  define variable v-NameString  as character no-undo .
  define variable v-qnty        as decimal   no-undo .
  define variable v-ostat       as decimal   no-undo .
  define variable v-sum-sale    as decimal   no-undo .
  define variable v-sum-cost    as decimal   no-undo .
  define variable v-qnty1       as decimal   no-undo .
  define variable v-ostat1      as decimal   no-undo .
  define variable v-sum-sale1   as decimal   no-undo .
  define variable v-sum-cost1   as decimal   no-undo .

  define variable  cur-qnty             as decimal initial 0  no-undo .
  define variable  cur-ostat            as decimal initial 0  no-undo .
  define variable  cur-sum-sale         as decimal initial 0  no-undo .
  define variable  cur-sum-cost         as decimal initial 0  no-undo .
  define variable  cur-qnty1            as decimal initial 0  no-undo .
  define variable  cur-ostat1           as decimal initial 0  no-undo .
  define variable  cur-sum-sale1        as decimal initial 0  no-undo .
  define variable  cur-sum-cost1        as decimal initial 0  no-undo .
  define variable  all-qnty             as decimal initial 0  no-undo .
  define variable  all-ostat            as decimal initial 0  no-undo .
  define variable  all-sum-sale         as decimal initial 0  no-undo .
  define variable  all-sum-cost         as decimal initial 0  no-undo .
  define variable  all-qnty1            as decimal initial 0  no-undo .
  define variable  all-ostat1           as decimal initial 0  no-undo .
  define variable  all-sum-sale1        as decimal initial 0  no-undo .
  define variable  all-sum-cost1        as decimal initial 0  no-undo .
  define variable  all1-qnty             as decimal initial 0  no-undo .
  define variable  all1-ostat            as decimal initial 0  no-undo .
  define variable  all1-sum-sale         as decimal initial 0  no-undo .
  define variable  all1-sum-cost         as decimal initial 0  no-undo .
  define variable  all1-qnty1            as decimal initial 0  no-undo .
  define variable  all1-ostat1           as decimal initial 0  no-undo .
  define variable  all1-sum-sale1        as decimal initial 0  no-undo .
  define variable  all1-sum-cost1        as decimal initial 0  no-undo .

  define variable  v-all-sum             as decimal initial 0  no-undo .
  define variable  v-all-qnty            as decimal initial 0  no-undo .

  run day-begin-fact-order in this-procedure ( input x-date-start,        output v-fact-order-start ). /*Поиск нач fact-order*/
  run day-begin-fact-order in this-procedure ( input ( x-date-end + 1 ),  output v-fact-order-end ). /*Поиск посл fact-order*/
  run day-begin-fact-order in this-procedure ( input x-date-start1,       output v-fact-order-start1 ). /*Поиск нач fact-order*/
  run day-begin-fact-order in this-procedure ( input ( x-date-end1 + 1 ), output v-fact-order-end1 ). /*Поиск посл fact-order*/

  assign
    Counter1 = 0 .
  .
  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */

  for each temp-DiscSales :
    delete temp-DiscSales .
  end.

  for each obj-list :
    case x-SelectGood :
      when {&g-all} then do: /* все товары */
        for each buf_gds-obj no-lock
          where buf_gds-obj.obj-type  = obj-list.obj-type
            and buf_gds-obj.obj-code  = obj-list.obj-code
        :
          find first buf_goods no-lock  where buf_goods.gds-code = buf_gds-obj.gds-code  .
          { rep/r-slg-s1.i } /* смотрим, были ли продажи и кладем в темп-тейбл  */
        end.
      end.
      when {&g-prod} then do:    /* не все производители */
        for each G#cli , /* встать на производителя */
            each buf_gds-obj  no-lock
          where buf_gds-obj.obj-type  = obj-list.obj-type
            and buf_gds-obj.obj-code  = obj-list.obj-code
            and buf_gds-obj.prod-type = G#cli.obj-type
            and buf_gds-obj.prod-code = G#cli.obj-code
           use-index pi  :

          find first buf_goods no-lock
            where buf_goods.gds-code = buf_gds-obj.gds-code
          .
          { rep/r-slg-s1.i } /* смотрим, были ли продажи и кладем в темп-тейбл  */

        end.                /* do ... по производителям */
      end .
      when {&g-grp} then do:    /* не все группы товаров */
        for each tmp#grp :
          find first buf_gds-grp no-lock
            where buf_gds-grp.node-code = tmp#grp.node-code
          .
          run grplib-get-full-name in this-procedure( input buf_gds-grp.node-code, output CurrGrpName ) .

          for each buf_gds-obj no-lock
            where buf_gds-obj.obj-type  = obj-list.obj-type
              and buf_gds-obj.obj-code  = obj-list.obj-code
              and buf_gds-obj.grp-name begins CurrGrpName
            use-index obj-grp :

            find first buf_goods no-lock
              where buf_goods.gds-code = buf_gds-obj.gds-code
            .
            { rep/r-slg-s1.i } /* смотрим, были ли продажи и кладем в темп-тейбл  */
          end .
        end.    /* do i = 1 to num-entries ( gdsgrp_recids ) : */
      end.
      otherwise do:
       /* список товаров */
        for each gds-list ,
            each buf_gds-obj no-lock
          where buf_gds-obj.obj-type  = obj-list.obj-type
            and buf_gds-obj.obj-code  = obj-list.obj-code
            and buf_gds-obj.artic     = gds-list.artic
            and buf_gds-obj.prod-type = gds-list.prod-type
            and buf_gds-obj.prod-code = gds-list.prod-code
          :

          find first buf_goods no-lock
            where buf_goods.gds-code = buf_gds-obj.gds-code
          .
          { rep/r-slg-s1.i } /* смотрим, были ли продажи и кладем в темп-тейбл  */
        end.
      end.

    end case.
  end.                    /* for each ... по объектам */
/*  { rep/repfrm.i off } /* убрать окно информации о текущем процессе */*/

  /* macr_excel - для экселя */
  assign
    make-excel = yes
    v-file-name = string(session :temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt"
  .
  output stream macr_excel to value(v-file-name) .
  assign v-ind = v-ind + 1 .

  { gbl/working.i }

  Line = fill("-", 250).

  { cmp/open-out.i stream OutStream " " ReportPageHeight }

  run PutColumnTitulExcel in this-procedure .

  FORM HEADER
      Line format "X({&P-X})" AT 1 SKIP  "Продолжение - на следующей странице" AT 30 SKIP
      with FRAME BottomFrame width {&DOS_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW stream OutStream FRAME BottomFrame .

  PUT stream OutStream SPACE(30) "Анализ продаж с: " x-date-start format "99/99/9999" "г. по: " x-date-end format "99/99/9999" "г." SKIP .

  PUT stream OutStream str1 format "X(100)" SKIP .
  PUT stream OutStream str2 format "X(100)" SKIP .
  PUT stream OutStream str3 format "X(100)" SKIP .

  assign  v-NameString = "Выбор объекта: " .
  PUT stream OutStream v-NameString format "X(100)" SKIP .
  for each obj-list no-lock:
    Assign  v-NameString = obj-list.obj-name + " (" + obj-list.obj-type + '#' + string(obj-list.obj-code)  + "), " .
    PUT stream OutStream SPACE(5) v-NameString format "X(100)" SKIP .
  end.
  assign  v-NameString = "Выбор товара: " .
  case x-SelectGood : /* все товары */
    when {&g-all}        then assign v-NameString = v-NameString + "по всем товарам"  .
    when {&g-grp}        then assign v-NameString = v-NameString + "по группам"  .
    when {&g-prod}       then assign v-NameString = v-NameString + "по производителям"  .
    when {&g-choice}     then assign v-NameString = v-NameString + "выборочно"  .
    when {&g-one}        then assign v-NameString = v-NameString + "выборочно"  .
    when {&g-spis}       then assign v-NameString = v-NameString + "хранимый список"  .
    when {&g-grp-prod}   then assign v-NameString = v-NameString + "по группам и по производителям"  .
  end case .
  PUT stream OutStream v-NameString format "X(100)" SKIP .

  run PrintTitul in this-procedure .
/*  run gbl/inidebug.p .*/

  if x-SumObj = yes then do:  /* раздельно по объектам */
    for each obj-list no-lock :
      assign
        ind = 0
        titul = yes
        v-old-level = 0
        v-level = 0
      .

      for each temp-DiscSales
        where temp-DiscSales.obj-type = obj-list.obj-type
          and temp-DiscSales.obj-code = obj-list.obj-code
        break by temp-DiscSales.full-grp-name
              by temp-DiscSales.b-code :
        if titul = yes then do:
          assign
            titul = no
            all-qnty      = 0
            all-ostat     = 0
            all-sum-sale  = 0
            all-sum-cost  = 0
            all-qnty1     = 0
            all-ostat1    = 0
            all-sum-sale1 = 0
            all-sum-cost1 = 0
            v-NameString = "Объект: " + obj-list.obj-name + " (" + obj-list.obj-type + '#' + string(obj-list.obj-code) + ")"
          .
          run PrintGroup in this-procedure .
        end.

        if  ( v-row ) >= 63000 then do:
          Output stream Macr_Excel  close .
          /*Запишем в файл параметров */
          run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name ) .
          /* создаем временный файл */
          run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
          output stream  Macr_Excel to value(v-file-name) .
          v-ind = v-ind + 1 .
          run PutColumnTitulExcel in this-procedure .
        end.
        if line-counter( Outstream ) > page-size( Outstream ) then do:
          page stream OutStream .
          run PrintTitul in this-procedure .
        end.

        if first-of(temp-DiscSales.full-grp-name) then do:
          run GrpSumTree in this-procedure .
        End.

        run CalculSum in this-procedure (0) .
        if x-itog = no then run PrintString in this-procedure .

        if last-of(temp-DiscSales.full-grp-name) then do:
          do ii = 1 to v-level :
            run CalculSum in this-procedure (ii) .
          end.
/*          if x-itog = no then do:*/
/*            assign v-NameString = "Итого по группе " + temp-DiscSales.grp-name + ":" .*/
/*            run PrintItog in this-procedure (cur-ostat,cur-ostat1,cur-sum-cost,cur-sum-cost1,cur-sum-sale,cur-sum-sale1,cur-qnty,cur-qnty1) .*/
/*          end.*/
/*          else do:*/
/*            assign v-NameString = temp-DiscSales.full-grp-name .*/
/*            if x-lavel = -1 or x-lavel >= ( num-entries( right-trim(temp-DiscSales.full-grp-name, {&delim-grp}), {&delim-grp} ) )  then*/
/*              run PrintItog in this-procedure (cur-ostat,cur-ostat1,cur-sum-cost,cur-sum-cost1,cur-sum-sale,cur-sum-sale1,cur-qnty,cur-qnty1) .*/
/*          end.*/
          assign
            all-qnty      = all-qnty      + cur-qnty
            all-ostat     = all-ostat     + cur-ostat
            all-sum-sale  = all-sum-sale  + cur-sum-sale
            all-sum-cost  = all-sum-cost  + cur-sum-cost
            all-qnty1     = all-qnty1     + cur-qnty1
            all-ostat1    = all-ostat1    + cur-ostat1
            all-sum-sale1 = all-sum-sale1 + cur-sum-sale1
            all-sum-cost1 = all-sum-cost1 + cur-sum-cost1
            all1-qnty      = all1-qnty      + cur-qnty
            all1-ostat     = all1-ostat     + cur-ostat
            all1-sum-sale  = all1-sum-sale  + cur-sum-sale
            all1-sum-cost  = all1-sum-cost  + cur-sum-cost
            all1-qnty1     = all1-qnty1     + cur-qnty1
            all1-ostat1    = all1-ostat1    + cur-ostat1
            all1-sum-sale1 = all1-sum-sale1 + cur-sum-sale1
            all1-sum-cost1 = all1-sum-cost1 + cur-sum-cost1
          .
        End.
      End.

      do ii = v-old-level to ( ind - 1 ) by -1 : /* удаляем старые заголовки из списка */
        find first temp-grp-sum
          where temp-grp-sum.num = ii no-error .
        if available temp-grp-sum then do:
          if x-itog = no then do:
            assign  v-NameString = "Итого по группе " + temp-grp-sum.grp + ":"  .
            run PrintItog in this-procedure (temp-grp-sum.ostat,temp-grp-sum.ostat1,temp-grp-sum.sum-cost,temp-grp-sum.sum-cost1,temp-grp-sum.sum-sale,temp-grp-sum.sum-sale1,temp-grp-sum.qnty,temp-grp-sum.qnty1) .
          end.
          else do:
            assign v-NameString = temp-grp-sum.full_grp .
            if x-lavel = -1 or ii <= x-lavel then
              run PrintItog in this-procedure (temp-grp-sum.ostat,temp-grp-sum.ostat1,temp-grp-sum.sum-cost,temp-grp-sum.sum-cost1,temp-grp-sum.sum-sale,temp-grp-sum.sum-sale1,temp-grp-sum.qnty,temp-grp-sum.qnty1) .
          end.
        end.
      end.
      for each temp-grp-sum :
        delete temp-grp-sum .
      end.

      if titul = no then do:
        assign v-NameString = "Итого по объекту " + obj-list.obj-name + " (" + obj-list.obj-type + '#' + string(obj-list.obj-code) + ") :" .
        run PrintItog in this-procedure (all-ostat,all-ostat1,all-sum-cost,all-sum-cost1,all-sum-sale,all-sum-sale1,all-qnty,all-qnty1) .
        put stream outstream  "|"   Line format "X({&P-X0})"   "|"    skip .
      end.
    End.
  end.
  else do:
    assign
      ind = 0
      titul = yes
      v-old-level = 0
      v-level = 0
      all-qnty      = 0
      all-ostat     = 0
      all-sum-sale  = 0
      all-sum-cost  = 0
      all-qnty1     = 0
      all-ostat1    = 0
      all-sum-sale1 = 0
      all-sum-cost1 = 0
    .

    for each temp-DiscSales
      break by temp-DiscSales.full-grp-name
            by temp-DiscSales.b-code :
      if  ( v-row ) >= 63000 then do:
        Output stream Macr_Excel  close .
        /*Запишем в файл параметров */
        run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name ) .
        /* создаем временный файл */
        run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
        output stream  Macr_Excel to value(v-file-name) .
        v-ind = v-ind + 1 .
        run PutColumnTitulExcel in this-procedure .
      end.
      if line-counter( Outstream ) > page-size( Outstream ) then do:
        page stream OutStream .
        run PrintTitul in this-procedure .
      end.

      if first-of(temp-DiscSales.full-grp-name) then do:
        run GrpSumTree in this-procedure .
      End.

      run CalculSum in this-procedure (0) .
      if x-itog = no then run PrintString in this-procedure .

      if last-of(temp-DiscSales.full-grp-name) then do:
        do ii = 1 to v-level :
          run CalculSum in this-procedure (ii) .
        end.
/*        if x-itog = no then do:*/
/*          assign v-NameString = "Итого по группе " + temp-DiscSales.grp-name + ":" .*/
/*          run PrintItog in this-procedure (cur-ostat,cur-ostat1,cur-sum-cost,cur-sum-cost1,cur-sum-sale,cur-sum-sale1,cur-qnty,cur-qnty1) .*/
/*        end.*/
/*        else do:*/
/*          assign v-NameString = temp-DiscSales.full-grp-name .*/
/*          if x-lavel = -1 or x-lavel >= ( num-entries( right-trim(temp-DiscSales.full-grp-name, {&delim-grp}), {&delim-grp} ) )  then*/
/*            run PrintItog in this-procedure (cur-ostat,cur-ostat1,cur-sum-cost,cur-sum-cost1,cur-sum-sale,cur-sum-sale1,cur-qnty,cur-qnty1) .*/
/*        end.*/
        assign
          all-qnty      = all-qnty      + cur-qnty
          all-ostat     = all-ostat     + cur-ostat
          all-sum-sale  = all-sum-sale  + cur-sum-sale
          all-sum-cost  = all-sum-cost  + cur-sum-cost
          all-qnty1     = all-qnty1     + cur-qnty1
          all-ostat1    = all-ostat1    + cur-ostat1
          all-sum-sale1 = all-sum-sale1 + cur-sum-sale1
          all-sum-cost1 = all-sum-cost1 + cur-sum-cost1
          all1-qnty      = all1-qnty      + cur-qnty
          all1-ostat     = all1-ostat     + cur-ostat
          all1-sum-sale  = all1-sum-sale  + cur-sum-sale
          all1-sum-cost  = all1-sum-cost  + cur-sum-cost
          all1-qnty1     = all1-qnty1     + cur-qnty1
          all1-ostat1    = all1-ostat1    + cur-ostat1
          all1-sum-sale1 = all1-sum-sale1 + cur-sum-sale1
          all1-sum-cost1 = all1-sum-cost1 + cur-sum-cost1
        .
      End.
    End.

    do ii = v-old-level to (ind - 1) by -1 : /* удаляем старые заголовки из списка */
      find first temp-grp-sum
        where temp-grp-sum.num = ii no-error .
      if available temp-grp-sum then do:
        if x-itog = no then do:
          assign  v-NameString = "Итого по группе " + temp-grp-sum.grp + ":"  .
          run PrintItog in this-procedure (temp-grp-sum.ostat,temp-grp-sum.ostat1,temp-grp-sum.sum-cost,temp-grp-sum.sum-cost1,temp-grp-sum.sum-sale,temp-grp-sum.sum-sale1,temp-grp-sum.qnty,temp-grp-sum.qnty1) .
        end.
        else do:
          assign v-NameString = temp-grp-sum.full_grp .
          if x-lavel = -1 or ii <= x-lavel then
            run PrintItog in this-procedure (temp-grp-sum.ostat,temp-grp-sum.ostat1,temp-grp-sum.sum-cost,temp-grp-sum.sum-cost1,temp-grp-sum.sum-sale,temp-grp-sum.sum-sale1,temp-grp-sum.qnty,temp-grp-sum.qnty1) .
        end.
      end.
    end.
    for each temp-grp-sum :
      delete temp-grp-sum .
    end.
  end.
  assign v-NameString = "В С Е Г О :" .
      run PrintItog in this-procedure (all1-ostat,all1-ostat1,all1-sum-cost,all1-sum-cost1,all1-sum-sale,all1-sum-sale1,all1-qnty,all-qnty1) .
      put stream outstream  "|"   Line format "X({&P-X0})"   "|"    skip .


  HIDE stream OutStream FRAME BottomFrame .
  OUTPUT stream OutStream CLOSE.

  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */
  { gbl/stopwork.i }

  output stream macr_excel close .
  run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name) .
  run end-proc .

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


/* *********************************************************** */

procedure GrpSumTree :
  v-level = num-entries( right-trim(temp-DiscSales.full-grp-name, {&delim-grp}), {&delim-grp} ) .

  assign CurrGrpName = "" .
  do ind = 1 to v-level :
    if ind = 1 then assign CurrGrpName = entry ( ind, temp-DiscSales.full-grp-name, {&delim-grp} ) .
    else assign CurrGrpName = CurrGrpName + {&delim-grp}  + entry ( ind, temp-DiscSales.full-grp-name, {&delim-grp} ) + {&delim-grp}.
    find first temp-grp-sum
      where temp-grp-sum.full_grp = CurrGrpName
    no-error .
    if not available temp-grp-sum then LEAVE.
  end.

  do ii = v-old-level to ind by -1 : /* удаляем старые заголовки из списка */
    find first temp-grp-sum  where temp-grp-sum.num = ii no-error .
    IF available temp-grp-sum THEN DO:
      if x-itog = no then do:
        assign  v-NameString = "Итого по группе " + temp-grp-sum.grp + ":"  .
        run PrintItog in this-procedure (temp-grp-sum.ostat,temp-grp-sum.ostat1,temp-grp-sum.sum-cost,temp-grp-sum.sum-cost1,temp-grp-sum.sum-sale,temp-grp-sum.sum-sale1,temp-grp-sum.qnty,temp-grp-sum.qnty1) .
      end.
      else do:
        assign v-NameString = temp-grp-sum.full_grp .
        if x-lavel = -1 or ii <= x-lavel then
          run PrintItog in this-procedure (temp-grp-sum.ostat,temp-grp-sum.ostat1,temp-grp-sum.sum-cost,temp-grp-sum.sum-cost1,temp-grp-sum.sum-sale,temp-grp-sum.sum-sale1,temp-grp-sum.qnty,temp-grp-sum.qnty1) .
      end.
      delete temp-grp-sum .
    end.
  end.

  assign
     v-old-level = v-level
  .
  /* надо вставлять заголовки для всех нижестоящих и вставить их в список */
  do ii = ind to v-level :
    create temp-grp-sum .
    if ii > ind then do:
      assign CurrGrpName = CurrGrpName + {&delim-grp} + entry ( ii, temp-DiscSales.full-grp-name, {&delim-grp} )  + {&delim-grp}.
    end.
    assign
      temp-grp-sum.num = ii
      temp-grp-sum.full_grp = CurrGrpName
      temp-grp-sum.grp = entry ( ii, temp-DiscSales.full-grp-name, {&delim-grp} )
      v-NameString = "Группа " + temp-grp-sum.grp
      temp-grp-sum.qnty           = 0
      temp-grp-sum.ostat          = 0
      temp-grp-sum.sum-sale       = 0
      temp-grp-sum.sum-cost       = 0
      temp-grp-sum.qnty1          = 0
      temp-grp-sum.ostat1         = 0
      temp-grp-sum.sum-sale1      = 0
      temp-grp-sum.sum-cost1      = 0
    .
    if x-itog = no then run PrintGroup in this-procedure .
  end.

  assign
    v-NameString = "Группа " + temp-DiscSales.grp-name
    cur-qnty      = 0
    cur-ostat     = 0
    cur-sum-sale  = 0
    cur-sum-cost  = 0
    cur-qnty1     = 0
    cur-ostat1    = 0
    cur-sum-sale1 = 0
    cur-sum-cost1 = 0
  .
/*  if x-itog = no then run PrintGroup in this-procedure .*/
end procedure.

/* *********************************************************** */


/* расчет сумм */
procedure CalculSum :
  define input  parameter p-num as integer   no-undo .
  define buffer buf_temp-grp-sum for temp-grp-sum .

  if p-num = 0 then do:
    assign
      cur-qnty      = cur-qnty      + temp-DiscSales.qnty
      cur-ostat     = cur-ostat     + temp-DiscSales.ostat
      cur-sum-sale  = cur-sum-sale  + temp-DiscSales.sum-sale
      cur-sum-cost  = cur-sum-cost  + temp-DiscSales.sum-cost
      cur-qnty1     = cur-qnty1     + temp-DiscSales.qnty1
      cur-ostat1    = cur-ostat1    + temp-DiscSales.ostat1
      cur-sum-sale1 = cur-sum-sale1 + temp-DiscSales.sum-sale1
      cur-sum-cost1 = cur-sum-cost1 + temp-DiscSales.sum-cost1
    .
  end.
  else do:
    find first buf_temp-grp-sum where buf_temp-grp-sum.num = p-num no-error .
    if available buf_temp-grp-sum then
    assign
      buf_temp-grp-sum.qnty      = buf_temp-grp-sum.qnty      + cur-qnty
      buf_temp-grp-sum.ostat     = buf_temp-grp-sum.ostat     + cur-ostat
      buf_temp-grp-sum.sum-sale  = buf_temp-grp-sum.sum-sale  + cur-sum-sale
      buf_temp-grp-sum.sum-cost  = buf_temp-grp-sum.sum-cost  + cur-sum-cost
      buf_temp-grp-sum.qnty1     = buf_temp-grp-sum.qnty1     + cur-qnty1
      buf_temp-grp-sum.ostat1    = buf_temp-grp-sum.ostat1    + cur-ostat1
      buf_temp-grp-sum.sum-sale1 = buf_temp-grp-sum.sum-sale1 + cur-sum-sale1
      buf_temp-grp-sum.sum-cost1 = buf_temp-grp-sum.sum-cost1 + cur-sum-cost1
    .
  end.
end procedure. /* CalculSum */

/* *********************************************************** */

procedure PrintTitul :
  do
  on error undo, return error return-value
  :
  put stream outstream
    skip
    Line format "X({&P-X})"
    skip
        "| "                         "Код"                     format "X(11)"
        "| "     at {&P-C1-S}        "Наименование товара"     format "X(20)"
        "| "     at {&P-C2-S}        "Наценка"                 format "X(10)"
        "|"      at {&P-C9-S}        (if x-RADIO-sel = 1 then "Сумма" else "Кол-во") format "X(6)"
        "|"      at {&P-C12-S}       "Остатки"                 format "X(10)"
        "|"      at {&P-C13-S}       "Остатки в днях"          format "X(16)"
        "|"      at {&P-C16-S}       "Удел."                   format "X(6)"
        "|"      at {&P-E}
    skip
        "|"  "|" at {&P-C1-S}   "|" at {&P-C2-S}   Line format "X({&P-X1})"
        "|"  at {&P-C12-S}      "|" at {&P-C13-S}  Line format "X({&P-X2})"
        "|"  at {&P-C16-S}      "вес"                   format "X(6)"
        "|"  at {&P-E}
    skip
        "|"
        "| "  at {&P-C1-S}
        "| "  at {&P-C2-S}        "Сравнит."               format "X(8)"
        "| "  at {&P-C3-S}        "Рабочий"                format "X(8)"
        "| "  at {&P-C4-S}        "% изм."                 format "X(8)"
        "| "  at {&P-C9-S}        "Сравнит."               format "X(8)"
        "| "  at {&P-C10-S}       "Рабочий"                format "X(8)"
        "| "  at {&P-C11-S}       "% изм."                 format "X(8)"
        "| "  at {&P-C12-S}
        "| "  at {&P-C13-S}       "Сравнит."               format "X(8)"
        "| "  at {&P-C14-S}       "Рабочий"                format "X(8)"
        "| "  at {&P-C15-S}       "% изм."                 format "X(8)"
        "|"   at {&P-C16-S}
        "|"   at {&P-E}
    skip
        "|"  Line format "X({&P-X0})"   "|"
    skip
  .
  end.

end procedure. /* PrintTitul */

/* *********************************************************** */

procedure PrintGroup :
  do
  on error undo, return error return-value
  :
  put stream outstream
        "| "    v-NameString   format "X(50)"
        "| "   at {&P-C2-S}        "| "   at {&P-C3-S}        "| "   at {&P-C4-S}        "| "   at {&P-C9-S}
        "| "   at {&P-C10-S}       "| "   at {&P-C11-S}       "| "   at {&P-C12-S}       "| "   at {&P-C13-S}
        "| "   at {&P-C14-S}       "| "   at {&P-C15-S}       "| "   at {&P-C16-S}       "|"    at {&P-E}
    skip
  .
  run macr_excel_char( v-NameString ,  v-row, 2) .
  assign v-row = v-row + 1 .
  end.
end procedure. /* PrintTitul */


/* *********************************************************** */

procedure PrintString :
  do
  on error undo, return error return-value
  :
  define variable prnaz  as decimal initial 0  no-undo .
  define variable naz    as decimal   no-undo .
  define variable naz1   as decimal   no-undo .
  define variable prod    as decimal   no-undo .
  define variable prod1   as decimal   no-undo .
  define variable ostd   as decimal   no-undo .
  define variable ostd1  as decimal   no-undo .
  define variable prostd as decimal initial 0  no-undo .
  define variable prprod as decimal initial 0  no-undo .
  assign
    naz   = temp-DiscSales.sum-sale - temp-DiscSales.sum-cost
    naz1  = temp-DiscSales.sum-sale1 - temp-DiscSales.sum-cost1
  .
  if temp-DiscSales.sum-cost  <> 0 then naz   = naz * 100 / temp-DiscSales.sum-cost .
  if temp-DiscSales.sum-cost1 <> 0 then naz1  = naz1 * 100 / temp-DiscSales.sum-cost1 .
  if naz1  <> 0    then prnaz  = ((naz - naz1) * 100 / naz1) .
  else if naz <> 0 then prnaz = 100 .

  if x-SET_PAY_TYPE = 1 then assign   prod1 = temp-DiscSales.sum-sale1    prod  = temp-DiscSales.sum-sale  .
  else                       assign   prod1 = temp-DiscSales.sum-cost1    prod  = temp-DiscSales.sum-cost  .

  assign
    ostd1 = temp-DiscSales.ostat1 * (x-date-end1 - x-date-start1 + 1) / prod1
    ostd  = temp-DiscSales.ostat  * (x-date-end - x-date-start + 1)   / prod
  .
  if prod1 <> 0     then prprod  = ((prod - prod1) * 100 / prod1) .
  else if prod <> 0 then prprod = 100 .

  if ostd1 <> 0     then prostd = ((ostd - ostd1) * 100 / ostd1) .
  else if ostd <> 0 then prostd = 100 .

  if x-RADIO-sel = 2 then assign udel = temp-DiscSales.qnty * 100 / v-all-qnty .  /* по кол-ву */
  else                    assign udel = prod * 100 / v-all-sum .

  put stream outstream
        "|"                            temp-DiscSales.b-code                          format {&F1}
        "| "      at {&P-C1-S}         temp-DiscSales.gds-name                        format {&f2}
        "|"       at {&P-C2-S}         naz1                                           format {&f3}
        "|"       at {&P-C3-S}         naz                                            format {&f4}
        "|"       at {&P-C4-S}         prnaz                                          format {&f5}
        "|"       at {&P-C9-S}        (if x-RADIO-sel = 1 then prod1 else temp-DiscSales.qnty1)   format {&f6}
        "|"       at {&P-C10-S}       (if x-RADIO-sel = 1 then prod  else temp-DiscSales.qnty)    format {&f7}
        "|"       at {&P-C11-S}        prprod                                         format {&f8}
        "|"       at {&P-C12-S}        temp-DiscSales.ostat                           format {&f9}
        "|"       at {&P-C13-S}        ostd1                                          format {&f10}
        "|"       at {&P-C14-S}        ostd                                           format {&f10}
        "|"       at {&P-C15-S}        prostd                                         format {&f10}
        "|"       at {&P-C16-S}        udel                                           format {&f11}
        "|"       at {&P-E}
    skip
  .

  assign v-col = 1 .
  run macr_excel_char( string(temp-DiscSales.b-code,{&F1}),  v-row, v-col) .       assign v-col = v-col + 1 .
  run macr_excel_char( temp-DiscSales.gds-name            ,  v-row, v-col) .       assign v-col = v-col + 1 .
  run macr_excel_sum ( naz1                               ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( naz                                ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( prnaz                              ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( (if x-RADIO-sel = 1 then prod1 else temp-DiscSales.qnty1) ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( (if x-RADIO-sel = 1 then prod  else temp-DiscSales.qnty)  ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( prprod                             ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( temp-DiscSales.ostat               ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( ostd1                              ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( ostd                               ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( prostd                             ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( udel                               ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  assign v-row = v-row + 1 .

  end.
end procedure. /* PrintTitul */

/* *********************************************************** */

procedure PrintItog :
  do
  on error undo, return error return-value
  :
  define input  parameter p-ostat     as decimal   no-undo .
  define input  parameter p-ostat1    as decimal   no-undo .
  define input  parameter p-sum-cost  as decimal   no-undo .
  define input  parameter p-sum-cost1 as decimal   no-undo .
  define input  parameter p-sum-sale  as decimal   no-undo .
  define input  parameter p-sum-sale1 as decimal   no-undo .
  define input  parameter p-qnty      as decimal   no-undo .
  define input  parameter p-qnty1     as decimal   no-undo .

  define variable prnaz  as decimal initial 0  no-undo .
  define variable naz    as decimal   no-undo .
  define variable naz1   as decimal   no-undo .
  define variable prod    as decimal   no-undo .
  define variable prod1   as decimal   no-undo .
  define variable ostd   as decimal   no-undo .
  define variable ostd1  as decimal   no-undo .
  define variable prostd as decimal initial 0  no-undo .
  define variable prprod as decimal initial 0  no-undo .

  assign
    naz   = p-sum-sale  - p-sum-cost
    naz1  = p-sum-sale1 - p-sum-cost1
  .
  if p-sum-cost  <> 0  then naz   = naz * 100 / p-sum-cost .
  if p-sum-cost1  <> 0 then naz1  = naz1 * 100 / p-sum-cost1 .
  if naz1  <> 0    then prnaz  = ((naz - naz1) * 100 / naz1) .
  else if naz <> 0 then prnaz = 100 .
  /* ******************** */
  if x-SET_PAY_TYPE = 1 then assign   prod1 = p-sum-sale1    prod  = p-sum-sale  .
  else                       assign   prod1 = p-sum-cost1    prod  = p-sum-cost  .

  assign
    ostd1 = p-ostat1 * (x-date-end1 - x-date-start1 + 1) / prod1
    ostd  = p-ostat  * (x-date-end  - x-date-start + 1)  / prod
  .
  if prod1 <> 0     then prprod  = ((prod - prod1) * 100 / prod1) .
  else if prod <> 0 then prprod = 100 .

  if ostd1 <> 0     then prostd = ((ostd - ostd1) * 100 / ostd1) .
  else if ostd <> 0 then prostd = 100 .

  if x-RADIO-sel = 2 then assign udel = p-qnty * 100 / v-all-qnty .  /* по кол-ву */
  else                    assign udel = prod * 100 / v-all-sum .
  /* ******************** */

  put stream outstream
        "| "                         v-NameString                            format "X(52)"
        "|"      at {&P-C2-S}        naz1                                    format {&f3}
        "|"      at {&P-C3-S}        naz                                     format {&f4}
        "|"      at {&P-C4-S}        prnaz                                   format {&f5}
        "|"      at {&P-C9-S}        (if x-RADIO-sel = 1 then prod1 else p-qnty1)   format {&f6}
        "|"      at {&P-C10-S}       (if x-RADIO-sel = 1 then prod  else p-qnty)    format {&f7}
        "|"      at {&P-C11-S}       prprod                                  format {&f8}
        "|"      at {&P-C12-S}       p-ostat                               format {&f9}
        "|"      at {&P-C13-S}       ostd1                                   format {&f10}
        "|"      at {&P-C14-S}       ostd                                    format {&f10}
        "|"      at {&P-C15-S}       prostd                                  format {&f10}
        "|"      at {&P-C16-S}       udel                                    format {&f11}
        "|"      at {&P-E}
    skip
  .

  assign v-col = 1 .
  assign v-col = v-col + 1 .
  run macr_excel_char( v-NameString                       ,  v-row, v-col) .       assign v-col = v-col + 1 .
  run macr_excel_sum ( naz1                               ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( naz                                ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( prnaz                              ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( (if x-RADIO-sel = 1 then prod1 else p-qnty1) ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( (if x-RADIO-sel = 1 then prod  else p-qnty)  ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( prprod                             ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( p-ostat                            ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( ostd1                              ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( ostd                               ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( prostd                             ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  run macr_excel_sum ( udel                               ,  v-row, v-col,  2) .   assign v-col = v-col + 1 .
  assign v-row = v-row + 1 .
  end.
end procedure. /* PrintItog */





procedure PutColumnTitulExcel : /* заголовки для колонок экселя */
  do
  on error undo, return error return-value
  :
  assign
    v-row = 5
    v-col = 1
  .
  run macr_excel_char (String( "Анализ продаж  с " + String(x-Date-Start,"99.99.9999") + " по " + String(x-Date-End,"99.99.9999") ) , 1, 4) .
  run macr_cell_format( 11, yes, no, ?, 1, 4, 1, 4) .
  run macr_excel_char (Str1 , 2, 1) .
  run macr_excel_char (Str2 , 3, 1) .
  run macr_excel_char (Str3 , 4, 1) .
  run macr_excel_char ("Выбор объекта: " , v-row, v-col) .    assign v-col = v-col + 1 .
  for each obj-list no-lock:
    run macr_excel_char ( string( obj-list.obj-name + " (" + obj-list.obj-type + '#' + string(obj-list.obj-code)  + "), ") , v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  assign
    v-col = 1
    v-row = v-row + 1
  .
  case x-SelectGood : /* все товары */
    when {&g-all}       then run macr_excel_char ("Выбор товара: по всем товарам" , v-row, v-col) .
    when {&g-grp}       then run macr_excel_char ("Выбор товара: по группам" , v-row, v-col) .
    when {&g-prod}      then run macr_excel_char ("Выбор товара: по производителям" , v-row, v-col) .
    when {&g-choice}    then run macr_excel_char ("Выбор товара: выборочно" , v-row, v-col) .
    when {&g-one}       then run macr_excel_char ("Выбор товара: выборочно" , v-row, v-col) .
    when {&g-spis}      then run macr_excel_char ("Выбор товара: по хранимому списку" , v-row, v-col) .
    when {&g-grp-prod}  then run macr_excel_char ("Выбор товара: по группам и по производителям" , v-row, v-col) .
  end case .

  run macr_excel_char("Код", v-row, v-col) .
  run macr_cell_size (10,?, v-row, v-col,?,?).       assign v-col = v-col + 1 .
  run macr_excel_char("Наименование товара", v-row, v-col) .
  run macr_cell_size (30,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Наценка сравнит.", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Наценка рабочий", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Наценка % изм.", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char((if x-RADIO-sel = 1 then "Сумма сравнит." else "Кол-во сравнит."), v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).       assign v-col = v-col + 1 .
  run macr_excel_char((if x-RADIO-sel = 1 then "Сумма рабочий" else "Кол-во рабочий"), v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).       assign v-col = v-col + 1 .
  run macr_excel_char((if x-RADIO-sel = 1 then "Сумма % изм." else "Кол-во % изм."), v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).       assign v-col = v-col + 1 .
  run macr_excel_char("Остатки", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Остатки в днях сравнит.", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Остатки в днях рабочий", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Остатки в днях % изм.", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .

  run macr_excel_char("Удел. вес", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .

  run macr_cell_bordur ( v-row , 1, v-row, 13) .
  run macr_cell_format ( 10, yes, no, 35, v-row , 1, v-row, 13) .
  assign
    v-row = v-row + 1
    v-col = 1
  .

  end.
end procedure. /* PutColumnTitulExcel */