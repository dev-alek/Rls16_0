block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-zapasr.p $
$Archive: rep/r-zapasr.p $

Отчет "Состояние запаса с учетом резервов"

Автор: Кочетков Михаил Юрьевич
Дата создания: 01/12/06
Author: Michael Kochetkov
Creation date: 01/12/06

*/

define input parameter x-base-type like currency.curr-abbr no-undo .
define input parameter x-base-code like currency.curr-code no-undo .
define input parameter xClassify   as character no-undo .
define input parameter xSortType   as character no-undo .
define input parameter xSumsOnly   as logical   no-undo .
define input parameter xShowZero   as logical   no-undo .
define input parameter tog-obj     as logical   no-undo .

/*  define variable tog-obj as logical init yes  no-undo .*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-zapasr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-zapasr.p $":U .
define variable vss-description as character no-undo init "Состояние запаса с учетом резервов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ rep/f-fdec.i   }
{ gbl/cur-time.i }
{ trg/factord.i  }
{ trg/partslib.i }
{ str/prl-vat.i  }
{ trg/prdoclib.i }
{ ref/grplib.i   }
{ rep/lkp-font.i }


do
on error undo, return error
:


  DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
  ASSIGN parParentProc =  my-handle .
  define variable g#report-num as integer no-undo .
  run get-report-num  in parparentproc (output  g#report-num).

  { gbl/getcntxt.i def }
  { gbl/getcntxt.i get }

  define stream  OutStream  .
  /*define stream  macr_excel .*/

  &Scop Sort-pole  if xSortType = "sort-code" then  temp-gds.sb-code Else (if xSortType = "sort-artic" then  temp-gds.artic Else  temp-gds.gds-name)

  define variable v-fact-order-end as decimal   no-undo .
  run day-begin-fact-order in this-procedure ( input ( x-date-end + 1 ),   output v-fact-order-end ). /*Поиск посл fact-order*/

  define variable v-curr-r-b as character no-undo .
  { gbl/curr-r-b.i v-curr-r-b }

  define variable v-base-rate  as decimal   no-undo .
  define variable v-base-scale as decimal   no-undo .
  { gbl/baserate.i v-cntxt-host-code-obj x-date-end v-base-rate v-base-scale no-error }


  define variable num-line        as integer   no-undo .
  define variable i               as integer   no-undo .
  define variable ii              as integer   no-undo .
  define variable Counter1        as integer   no-undo .
  define variable Line as character no-undo .
  define variable CurrGrpName as character no-undo .

  assign Line = fill ("-", 220).
  assign ReportPageWidth = ReportPageWidth + 1 .

  define buffer buf_gds-obj  for gds-obj.
  define buffer buf_clients for clients .
  define buffer buf_goods    for goods.
  define buffer buf_parts    for parts.

  define  variable v-cur-qnty           as decimal   no-undo .
  define  variable v-cur-base           as decimal   no-undo .
  define  variable v-cur-VAT-base       as decimal   no-undo .
  define  variable v-cur-SLT-base       as decimal   no-undo .
  define  variable v-cur-road-tax-base  as decimal   no-undo .
  define  variable v-cur-excise-base    as decimal   no-undo .

  define variable all-fact-qnty  as decimal   no-undo .
  define variable all-free-qnty  as decimal   no-undo .
  define variable all-wait-qnty  as decimal   no-undo .
  define variable all-zak-sum    as decimal   no-undo .
  define variable all-naz-sum    as decimal   no-undo .
  define variable all0-fact-qnty  as decimal   no-undo .
  define variable all0-free-qnty  as decimal   no-undo .
  define variable all0-wait-qnty  as decimal   no-undo .
  define variable all0-zak-sum    as decimal   no-undo .
  define variable all0-naz-sum    as decimal   no-undo .
  define variable all1-fact-qnty  as decimal   no-undo .
  define variable all1-free-qnty  as decimal   no-undo .
  define variable all1-wait-qnty  as decimal   no-undo .
  define variable all1-zak-sum    as decimal   no-undo .
  define variable all1-naz-sum    as decimal   no-undo .
  define variable all2-fact-qnty  as decimal   no-undo .
  define variable all2-free-qnty  as decimal   no-undo .
  define variable all2-wait-qnty  as decimal   no-undo .
  define variable all2-zak-sum    as decimal   no-undo .
  define variable all2-naz-sum    as decimal   no-undo .

DEFINE temp-table temp-gds no-undo
    field   fact-qnty    as  decimal
    field   free-qnty    as  decimal
    field   wait-qnty    as  decimal
    field   zak-price    as  decimal
    field   prod-price   as  decimal
    field   zak-sum      as  decimal
    field   prod-sum     as  decimal
    field   naz-sum      as  decimal
    field   naz-prc      as  decimal

    field   obj-type         as  char
    field   obj-code         as  integer
    field   obj-name         as  char
    field   prod-type        as  char
    field   prod-code        as  integer
/*    field   prod-name        as  char*/
    field   post-type        as  char
    field   post-code        as  integer
/*    field   post-name        as  char*/
    field   artic            as  char
    field   in-code          as  char
    field   part-code        as  char
    field   gds-name         as  char
    field   gds-name1        as  char
    field   grp-name         as  char
    field   unit-base        as  char
    field   sb-code          as  char
    field   b-code           as  integer
    field   grp-code         as  integer
    field   vat-pc           as  decimal
    INDEX pi  IS PRIMARY   obj-type obj-code artic  prod-type prod-code
    INDEX pi1              obj-type obj-code b-code prod-type prod-code
    INDEX pi2              artic  prod-type prod-code
    INDEX pi3              prod-type prod-code
    INDEX pi4              post-type post-code
    INDEX pi5              grp-code
    INDEX pi6              vat-pc
    INDEX pi7              gds-name
.

  define variable frmt as character no-undo .
  assign frmt = "X(" + string(ReportPageWidth) + ')' .
  define variable frmt1 as character no-undo .
  assign frmt1 = "X(" + string(ReportPageWidth - 2) + ')' .

  define variable frmt2 as character no-undo .
  assign i = 0 .
  if use-column[1]  = yes then assign i = i + 6 .
  if use-column[2]  = yes then assign i = i + 11 .
  if use-column[3]  = yes then assign i = i + 17 .
  if use-column[4]  = yes then assign i = i + 41 .
  if use-column[5]  = yes then assign i = i + 4 .
  if i > 1 then assign i = i - 1 .
  else assign i = 1 .
  assign frmt2 = "X(" + string( i ) + ')' .

  assign  Counter1 = 0 .
  { rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */

  for each obj-list :
    case x-SelectGood :
      when {&g-all} then do: /* все товары */
        for each buf_gds-obj no-lock where buf_gds-obj.obj-type = obj-list.obj-type and buf_gds-obj.obj-code = obj-list.obj-code :
          { rep/r-zapr1.i } /* проверка, подходит ли товар и заполнение темп-тейбла */
        end.
      end.
      when {&g-prod} then do:    /* не все производители */
        for each G#cli : /* встать на производителя */
          for each buf_gds-obj  no-lock
            where buf_gds-obj.obj-type  = obj-list.obj-type
              and buf_gds-obj.obj-code  = obj-list.obj-code
              and buf_gds-obj.prod-type = G#cli.obj-type
              and buf_gds-obj.prod-code = G#cli.obj-code
            use-index pi  :
            { rep/r-zapr1.i } /* проверка, подходит ли товар и заполнение темп-тейбла */
          end .
        end.                /* do ... по производителям */
      end .
      when {&g-grp} then do:    /* не все группы товаров */
        for each tmp#grp :
          run grplib-get-full-name in this-procedure ( input tmp#grp.node-code, output CurrGrpName ) .
          for each buf_gds-obj no-lock
            where buf_gds-obj.obj-type = obj-list.obj-type
              and buf_gds-obj.obj-code = obj-list.obj-code
              and buf_gds-obj.grp-name begins CurrGrpName
            use-index obj-grp :
            { rep/r-zapr1.i } /* проверка, подходит ли товар и заполнение темп-тейбла */
          end .
        end.    /* do i = 1 to num-entries ( gdsgrp_recids ) : */
      end.
      otherwise do:      /* список товаров */
        for each gds-list ,
            each buf_gds-obj no-lock
          where buf_gds-obj.obj-type  = obj-list.obj-type
            and buf_gds-obj.obj-code  = obj-list.obj-code
            and buf_gds-obj.artic     = gds-list.artic
            and buf_gds-obj.prod-type = gds-list.prod-type
            and buf_gds-obj.prod-code = gds-list.prod-code
          :
          { rep/r-zapr1.i } /* проверка, подходит ли товар и заполнение темп-тейбла */
        end.
      end.

    end case.
  end. /* for each ... по объектам */

 { cmp/open-out.i stream OutStream " " ReportPageHeight }

  /* составили список товаров, теперь надо анализировать по ним кол-во колонок и формировать шапку */
  PUT stream OutStream  space(20) ReportNAme  format "X(100)" skip .
  Repeat i = 1 to NUM-ENTRIES (ReportHeader,chr(10)) :
    PUT stream OutStream  Entry(i,ReportHeader,chr(10))  AT 1 format "X(180)" skip .
  End.
  PUT stream OutStream  str3 format "x(190)"  skip .
  Repeat i = 1 to NUM-ENTRIES (str2,chr(10)) :
    PUT stream OutStream  Entry(i,str2,chr(10))  AT 1 format "X(170)" skip .
  End.
  Repeat i = 1 to NUM-ENTRIES (str4,chr(10)) :
    PUT stream OutStream  Entry(i,str4,chr(10))  AT 1 format "X(170)" skip .
  End.

  run ColumnTitle in this-procedure .

  run rep/extitle.p (1) .   /* Печать шапки */

  CASE xClassify :
    when "no-classify":U  then DO:
      if tog-obj then do:
        for each temp-gds  break by temp-gds.obj-type by temp-gds.obj-code  by {&Sort-Pole} :
          if first-of(temp-gds.obj-code) then run PrintName ( temp-gds.obj-name ) .
          run PrintLine        in this-procedure .
          if last-of(temp-gds.obj-code) then  run PrintItog ("Всего по объекту " + temp-gds.obj-name, all0-fact-qnty, all0-free-qnty, all0-zak-sum, all0-naz-sum, all0-wait-qnty, 3).
        end.
      end.
      else do:
        for each temp-gds  break by {&Sort-Pole} :
          run PrintLine        in this-procedure .
        end.
      end.
    End.
    when "grp-goods":U then          run Run1.
    when "prod":U then               run Run2.
    when "prod/grp-goods":U then     run run3.
    when "grp-goods/prod":U then     run Run4.
    when "post":U then               run Run5.
    when "post/grp-goods":U then     run run6.
    when "grp-goods/post":U then     run Run7.
    when "vat-pc":U then             run Run8.
  End case.
  HIDE stream OutStream FRAME BottomFrame .

  run PrintItog (" ИТОГО: ", all-fact-qnty, all-free-qnty, all-zak-sum, all-naz-sum, all-wait-qnty, 0).

  {&CloseExcel}

  HIDE STREAM   OutStream   FRAME ZAPAS .
  Output stream OutStream   close .
  { rep/repfrm.i off }

  define variable disop as integer   no-undo .
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

procedure Run1 :      /* "grp-goods":U */
  do on error undo, return error return-value :
    if tog-obj then do:
      for each temp-gds  break by temp-gds.obj-type by temp-gds.obj-code by temp-gds.grp-name by {&Sort-Pole} :
        if first-of(temp-gds.obj-code) then run PrintName ( temp-gds.obj-name ) .
        if first-of(temp-gds.grp-name) then run PrintName ( temp-gds.grp-name ) .
        run PrintLine        in this-procedure .
        if last-of(temp-gds.grp-name) then do:
          run PrintItog ("Всего по группе " + temp-gds.grp-name, all1-fact-qnty, all1-free-qnty, all1-zak-sum, all1-naz-sum, all1-wait-qnty, 1).
        end.
        if last-of(temp-gds.obj-code) then  run PrintItog ("Всего по объекту " + temp-gds.obj-name, all0-fact-qnty, all0-free-qnty, all0-zak-sum, all0-naz-sum, all0-wait-qnty, 3).
      end.
    end.
    else do:
      for each temp-gds  break by temp-gds.grp-name by {&Sort-Pole} :
        if first-of(temp-gds.grp-name) then run PrintName ( temp-gds.grp-name ) .
        run PrintLine        in this-procedure .
        if last-of(temp-gds.grp-name) then do:
          run PrintItog ("Всего по группе " + temp-gds.grp-name, all1-fact-qnty, all1-free-qnty, all1-zak-sum, all1-naz-sum, all1-wait-qnty, 1).
        end.
      end.
    end.
  end.
end procedure. /* Run1 */

procedure Run2 :     /* "prod":U */
  do on error undo, return error return-value :
    if tog-obj then do:
      for each temp-gds break by temp-gds.obj-type by temp-gds.obj-code by temp-gds.prod-type by temp-gds.prod-code by {&Sort-Pole} :
        if first-of(temp-gds.obj-code) then run PrintName ( temp-gds.obj-name ) .
        if first-of(temp-gds.prod-code) then do:
          find first buf_clients no-lock where buf_clients.obj-type = temp-gds.prod-type and  buf_clients.obj-code = temp-gds.prod-code .
          run PrintName ( buf_clients.obj-name ) .
        end.
        run PrintLine        in this-procedure .
        if last-of(temp-gds.prod-code) then do:
          run PrintItog ("Всего по производителю " + buf_clients.obj-name, all1-fact-qnty, all1-free-qnty, all1-zak-sum, all1-naz-sum, all1-wait-qnty, 1).
        end.
        if last-of(temp-gds.obj-code) then  run PrintItog ("Всего по объекту " + temp-gds.obj-name, all0-fact-qnty, all0-free-qnty, all0-zak-sum, all0-naz-sum, all0-wait-qnty, 3).
      end.
    end.
    else do:
      for each temp-gds break by temp-gds.prod-type by temp-gds.prod-code by {&Sort-Pole} :
        if first-of(temp-gds.prod-code) then do:
          find first buf_clients no-lock where buf_clients.obj-type = temp-gds.prod-type and  buf_clients.obj-code = temp-gds.prod-code .
          run PrintName ( buf_clients.obj-name ) .
        end.
        run PrintLine        in this-procedure .
        if last-of(temp-gds.prod-code) then do:
          run PrintItog ("Всего по производителю " + buf_clients.obj-name, all1-fact-qnty, all1-free-qnty, all1-zak-sum, all1-naz-sum, all1-wait-qnty, 1).
        end.
      end.
    end.
  end.
end procedure. /* Run2 */

procedure Run3 :       /* "prod/grp-goods":U */
  do on error undo, return error return-value :
    if tog-obj then do:
      for each temp-gds break by temp-gds.obj-type by temp-gds.obj-code by temp-gds.prod-type by temp-gds.prod-code by temp-gds.grp-name by {&Sort-Pole} :
        if first-of(temp-gds.obj-code) then run PrintName ( temp-gds.obj-name ) .
        if first-of(temp-gds.prod-code) then do:
          find first buf_clients no-lock where buf_clients.obj-type = temp-gds.prod-type and  buf_clients.obj-code = temp-gds.prod-code .
          run PrintName ( "Производитель " + buf_clients.obj-name ) .
        end.
        if first-of(temp-gds.grp-name) then run PrintName ( "Группа " + temp-gds.grp-name ) .
        run PrintLine        in this-procedure .
        if last-of(temp-gds.grp-name) then do:
          run PrintItog ("Всего по группе " + temp-gds.grp-name, all2-fact-qnty, all2-free-qnty, all2-zak-sum, all2-naz-sum, all2-wait-qnty, 2).
        end.
        if last-of(temp-gds.prod-code) then do:
          run PrintItog ("Всего по производителю " + buf_clients.obj-name, all1-fact-qnty, all1-free-qnty, all1-zak-sum, all1-naz-sum, all1-wait-qnty, 1).
        end.
        if last-of(temp-gds.obj-code) then  run PrintItog ("Всего по объекту " + temp-gds.obj-name, all0-fact-qnty, all0-free-qnty, all0-zak-sum, all0-naz-sum, all0-wait-qnty, 3).
      end.
    end.
    else do:
      for each temp-gds break by temp-gds.prod-type by temp-gds.prod-code by temp-gds.grp-name by {&Sort-Pole} :
        if first-of(temp-gds.prod-code) then do:
          find first buf_clients no-lock where buf_clients.obj-type = temp-gds.prod-type and  buf_clients.obj-code = temp-gds.prod-code .
          run PrintName ( "Производитель " + buf_clients.obj-name ) .
        end.
        if first-of(temp-gds.grp-name) then run PrintName ( "Группа " + temp-gds.grp-name ) .
        run PrintLine        in this-procedure .
        if last-of(temp-gds.grp-name) then do:
          run PrintItog ("Всего по группе " + temp-gds.grp-name, all2-fact-qnty, all2-free-qnty, all2-zak-sum, all2-naz-sum, all2-wait-qnty, 2).
        end.
        if last-of(temp-gds.prod-code) then do:
          run PrintItog ("Всего по производителю " + buf_clients.obj-name, all1-fact-qnty, all1-free-qnty, all1-zak-sum, all1-naz-sum, all1-wait-qnty, 1).
        end.
      end.
    end.
  end.
end procedure. /* run3 */


procedure Run4 :       /* "grp-goods/prod":U */
  do on error undo, return error return-value :
    if tog-obj then do:
      for each temp-gds break by temp-gds.obj-type by temp-gds.obj-code by temp-gds.grp-name by temp-gds.prod-type by temp-gds.prod-code by {&Sort-Pole} :
        if first-of(temp-gds.obj-code) then run PrintName ( temp-gds.obj-name ) .
        if first-of(temp-gds.grp-name) then  run PrintName ( "Группа " + temp-gds.grp-name ) .
        if first-of(temp-gds.prod-code) then do:
          find first buf_clients no-lock where buf_clients.obj-type = temp-gds.prod-type and  buf_clients.obj-code = temp-gds.prod-code .
          run PrintName ( "Производитель " + buf_clients.obj-name ) .
        end.
        run PrintLine        in this-procedure .
        if last-of(temp-gds.prod-code) then do:
          run PrintItog ("Всего по производителю " + buf_clients.obj-name, all2-fact-qnty, all2-free-qnty, all2-zak-sum, all2-naz-sum, all2-wait-qnty, 2).
        end.
        if last-of(temp-gds.grp-name) then do:
          run PrintItog ("Всего по группе " + temp-gds.grp-name, all1-fact-qnty, all1-free-qnty, all1-zak-sum, all1-naz-sum, all1-wait-qnty, 1).
        end.
        if last-of(temp-gds.obj-code) then  run PrintItog ("Всего по объекту " + temp-gds.obj-name, all0-fact-qnty, all0-free-qnty, all0-zak-sum, all0-naz-sum, all0-wait-qnty, 3).
      end.
    end.
    else do:
      for each temp-gds break by temp-gds.grp-name by temp-gds.prod-type by temp-gds.prod-code by {&Sort-Pole} :
        if first-of(temp-gds.grp-name) then  run PrintName ( "Группа " + temp-gds.grp-name ) .
        if first-of(temp-gds.prod-code) then do:
          find first buf_clients no-lock where buf_clients.obj-type = temp-gds.prod-type and  buf_clients.obj-code = temp-gds.prod-code .
          run PrintName ( "Производитель " + buf_clients.obj-name ) .
        end.
        run PrintLine        in this-procedure .
        if last-of(temp-gds.prod-code) then do:
          run PrintItog ("Всего по производителю " + buf_clients.obj-name, all2-fact-qnty, all2-free-qnty, all2-zak-sum, all2-naz-sum, all2-wait-qnty, 2).
        end.
        if last-of(temp-gds.grp-name) then do:
          run PrintItog ("Всего по группе " + temp-gds.grp-name, all1-fact-qnty, all1-free-qnty, all1-zak-sum, all1-naz-sum, all1-wait-qnty, 1).
        end.
      end.
    end.
  end.
end procedure. /* Run4 */

procedure Run5 :     /* "post":U */
  do on error undo, return error return-value :
    if tog-obj then do:
      for each temp-gds break by temp-gds.obj-type by temp-gds.obj-code by temp-gds.post-type by temp-gds.post-code by {&Sort-Pole} :
        if first-of(temp-gds.obj-code) then run PrintName ( temp-gds.obj-name ) .
        if first-of(temp-gds.post-code) then do:
          find first buf_clients no-lock where buf_clients.obj-type = temp-gds.post-type and  buf_clients.obj-code = temp-gds.post-code .
          run PrintName ( buf_clients.obj-name ) .
        end.
        run PrintLine        in this-procedure .
        if last-of(temp-gds.post-code) then do:
          run PrintItog ("Всего по поставщику " + buf_clients.obj-name, all1-fact-qnty, all1-free-qnty, all1-zak-sum, all1-naz-sum, all1-wait-qnty, 1).
        end.
        if last-of(temp-gds.obj-code) then  run PrintItog ("Всего по объекту " + temp-gds.obj-name, all0-fact-qnty, all0-free-qnty, all0-zak-sum, all0-naz-sum, all0-wait-qnty, 3).
      end.
    end.
    else do:
      for each temp-gds break by temp-gds.post-type by temp-gds.post-code by {&Sort-Pole} :
        if first-of(temp-gds.post-code) then do:
          find first buf_clients no-lock where buf_clients.obj-type = temp-gds.post-type and  buf_clients.obj-code = temp-gds.post-code .
          run PrintName ( buf_clients.obj-name ) .
        end.
        run PrintLine        in this-procedure .
        if last-of(temp-gds.post-code) then do:
          run PrintItog ("Всего по поставщику " + buf_clients.obj-name, all1-fact-qnty, all1-free-qnty, all1-zak-sum, all1-naz-sum, all1-wait-qnty, 1).
        end.
      end.
    end.
  end.
end procedure. /* Run5 */

procedure Run6 :       /* "post/grp-goods":U */
  do on error undo, return error return-value :
    if tog-obj then do:
      for each temp-gds break by temp-gds.obj-type by temp-gds.obj-code by temp-gds.post-type by temp-gds.post-code by temp-gds.grp-name by {&Sort-Pole} :
        if first-of(temp-gds.obj-code) then run PrintName ( temp-gds.obj-name ) .
        if first-of(temp-gds.post-code) then do:
          find first buf_clients no-lock where buf_clients.obj-type = temp-gds.post-type and  buf_clients.obj-code = temp-gds.post-code .
          run PrintName ( "Поставщик " + buf_clients.obj-name ) .
        end.
        if first-of(temp-gds.grp-name) then run PrintName ( "Группа " + temp-gds.grp-name ) .
        run PrintLine        in this-procedure .
        if last-of(temp-gds.grp-name) then do:
          run PrintItog ("Всего по группе " + temp-gds.grp-name, all2-fact-qnty, all2-free-qnty, all2-zak-sum, all2-naz-sum, all2-wait-qnty, 2).
        end.
        if last-of(temp-gds.post-code) then do:
          run PrintItog ("Всего по поставщику " + buf_clients.obj-name, all1-fact-qnty, all1-free-qnty, all1-zak-sum, all1-naz-sum, all1-wait-qnty, 1).
        end.
        if last-of(temp-gds.obj-code) then  run PrintItog ("Всего по объекту " + temp-gds.obj-name, all0-fact-qnty, all0-free-qnty, all0-zak-sum, all0-naz-sum, all0-wait-qnty, 3).
      end.
    end.
    else do:
      for each temp-gds break by temp-gds.post-type by temp-gds.post-code by temp-gds.grp-name by {&Sort-Pole} :
        if first-of(temp-gds.post-code) then do:
          find first buf_clients no-lock where buf_clients.obj-type = temp-gds.post-type and  buf_clients.obj-code = temp-gds.post-code .
          run PrintName ( "Поставщик " + buf_clients.obj-name ) .
        end.
        if first-of(temp-gds.grp-name) then run PrintName ( "Группа " + temp-gds.grp-name ) .
        run PrintLine        in this-procedure .
        if last-of(temp-gds.grp-name) then do:
          run PrintItog ("Всего по группе " + temp-gds.grp-name, all2-fact-qnty, all2-free-qnty, all2-zak-sum, all2-naz-sum, all2-wait-qnty, 2).
        end.
        if last-of(temp-gds.post-code) then do:
          run PrintItog ("Всего по поставщику " + buf_clients.obj-name, all1-fact-qnty, all1-free-qnty, all1-zak-sum, all1-naz-sum, all1-wait-qnty, 1).
        end.
      end.
    end.
  end.
end procedure. /* Run6 */


procedure Run7 :       /* "grp-goods/post":U */
  do on error undo, return error return-value :
    if tog-obj then do:
      for each temp-gds break by temp-gds.obj-type by temp-gds.obj-code by temp-gds.grp-name by temp-gds.post-type by temp-gds.post-code by {&Sort-Pole} :
        if first-of(temp-gds.obj-code) then run PrintName ( temp-gds.obj-name ) .
        if first-of(temp-gds.grp-name) then  run PrintName ( "Группа " + temp-gds.grp-name ) .
        if first-of(temp-gds.post-code) then do:
          find first buf_clients no-lock where buf_clients.obj-type = temp-gds.post-type and  buf_clients.obj-code = temp-gds.post-code .
          run PrintName ( "Поставщик " + buf_clients.obj-name ) .
        end.
        run PrintLine        in this-procedure .
        if last-of(temp-gds.post-code) then do:
          run PrintItog ("Всего по поставщику " + buf_clients.obj-name, all2-fact-qnty, all2-free-qnty, all2-zak-sum, all2-naz-sum, all2-wait-qnty, 2).
        end.
        if last-of(temp-gds.grp-name) then do:
          run PrintItog ("Всего по группе " + temp-gds.grp-name, all1-fact-qnty, all1-free-qnty, all1-zak-sum, all1-naz-sum, all1-wait-qnty, 1).
        end.
        if last-of(temp-gds.obj-code) then  run PrintItog ("Всего по объекту " + temp-gds.obj-name, all0-fact-qnty, all0-free-qnty, all0-zak-sum, all0-naz-sum, all0-wait-qnty, 3).
      end.
    end.
    else do:
      for each temp-gds break by temp-gds.grp-name by temp-gds.post-type by temp-gds.post-code by {&Sort-Pole} :
        if first-of(temp-gds.grp-name) then  run PrintName ( "Группа " + temp-gds.grp-name ) .
        if first-of(temp-gds.post-code) then do:
          find first buf_clients no-lock where buf_clients.obj-type = temp-gds.post-type and  buf_clients.obj-code = temp-gds.post-code .
          run PrintName ( "Поставщик " + buf_clients.obj-name ) .
        end.
        run PrintLine        in this-procedure .
        if last-of(temp-gds.post-code) then do:
          run PrintItog ("Всего по поставщику " + buf_clients.obj-name, all2-fact-qnty, all2-free-qnty, all2-zak-sum, all2-naz-sum, all2-wait-qnty, 2).
        end.
        if last-of(temp-gds.grp-name) then do:
          run PrintItog ("Всего по группе " + temp-gds.grp-name, all1-fact-qnty, all1-free-qnty, all1-zak-sum, all1-naz-sum, all1-wait-qnty, 1).
        end.
      end.
    end.
  end.
end procedure. /* Run7 */


procedure Run8 :      /* "vat":U */
  do on error undo, return error return-value :
    if tog-obj then do:
      for each temp-gds break by temp-gds.obj-type by temp-gds.obj-code by temp-gds.vat-pc by {&Sort-Pole} :
        if first-of(temp-gds.obj-code) then run PrintName ( temp-gds.obj-name ) .
        if first-of(temp-gds.vat-pc) then run PrintName ( "НДС " + string(temp-gds.vat-pc) + " %" ) .
        run PrintLine        in this-procedure .
        if last-of(temp-gds.vat-pc) then run PrintItog ("Всего по НДС " + string(temp-gds.vat-pc) + " %", all1-fact-qnty, all1-free-qnty, all1-zak-sum, all1-naz-sum, all1-wait-qnty, 1).
        if last-of(temp-gds.obj-code) then  run PrintItog ("Всего по объекту " + temp-gds.obj-name, all0-fact-qnty, all0-free-qnty, all0-zak-sum, all0-naz-sum, all0-wait-qnty, 3).
      end.
    end.
    else do:
      for each temp-gds break by temp-gds.vat-pc by {&Sort-Pole} :
        if first-of(temp-gds.vat-pc) then run PrintName ( "НДС " + string(temp-gds.vat-pc) + " %" ) .
        run PrintLine        in this-procedure .
        if last-of(temp-gds.vat-pc) then run PrintItog ("Всего по НДС " + string(temp-gds.vat-pc) + " %", all1-fact-qnty, all1-free-qnty, all1-zak-sum, all1-naz-sum, all1-wait-qnty, 1).
      end.
    end.
  end.
end procedure. /* Run1 */


procedure CalcWaitQnty :
  do on error undo, return error return-value :
    define input  parameter p-ext-doc-type as character no-undo .

    define buffer buf_doc-line for doc-line .
    define buffer buf_parts for parts .

    for each buf_doc-line no-lock
      where buf_doc-line.obj-type     = obj-list.obj-type
        and buf_doc-line.obj-code     = obj-list.obj-code
        and buf_doc-line.prod-type    = buf_gds-obj.prod-type
        and buf_doc-line.prod-code    = buf_gds-obj.prod-code
        and buf_doc-line.artic        = buf_gds-obj.artic
        and buf_doc-line.ext-doc-type = p-ext-doc-type
        and buf_doc-line.status_      = {&wayb}
/*        and buf_doc-line.fact-order   <  v-fact-order-end*/
      :
      for each buf_parts no-lock
        where buf_parts.out-code     = buf_doc-line.doc-code
          and buf_parts.obj-type     = buf_doc-line.obj-type
          and buf_parts.obj-code     = buf_doc-line.obj-code
          and buf_parts.prod-type    = buf_doc-line.prod-type
          and buf_parts.prod-code    = buf_doc-line.prod-code
          and buf_parts.artic        = buf_doc-line.artic
        :
        if ( p-ext-doc-type = {&TDEDT_Inv} or p-ext-doc-type = {&TDEDT_Peresort} ) and buf_parts.fact-qnty <= 0 then next .
        if tog-obj = true then do: /* раздельно по объектам */
          find first temp-gds
            where temp-gds.prod-type = buf_parts.prod-type
              and temp-gds.prod-code = buf_parts.prod-code
              and temp-gds.artic     = buf_parts.artic
              and temp-gds.in-code   = buf_parts.in-code
              and temp-gds.part-code = buf_parts.part-code
              and temp-gds.obj-type  = buf_parts.obj-type
              and temp-gds.obj-code  = buf_parts.obj-code
          no-error .
        end.
        else do:
          find first temp-gds
            where temp-gds.prod-type = buf_parts.prod-type
              and temp-gds.prod-code = buf_parts.prod-code
              and temp-gds.artic     = buf_parts.artic
              and temp-gds.in-code   = buf_parts.in-code
              and temp-gds.part-code = buf_parts.part-code
          no-error .
        end.
        if not available temp-gds then do:
          run CreateGDS ( buf_parts.artic, buf_parts.prod-type, buf_parts.prod-code, buf_parts.in-code, buf_parts.part-code, buf_parts.supp-type, buf_parts.supp-code) .
        end.
        assign temp-gds.wait-qnty = temp-gds.wait-qnty + buf_parts.fact-qnty  .
      end.
    end.
  end.
end procedure. /* CalcWaitQnty */


procedure CreateGDS :
  do on error undo, return error return-value :
    define input  parameter p-artic     like parts.artic     no-undo.
    define input  parameter p-prod-type like parts.prod-type no-undo.
    define input  parameter p-prod-code like parts.prod-code no-undo.
    define input  parameter p-in-code   like parts.in-code   no-undo.
    define input  parameter p-part-code like parts.part-code no-undo.
    define input  parameter p-supp-type like parts.supp-type no-undo.
    define input  parameter p-supp-code like parts.supp-code no-undo.

    find first buf_goods no-lock where buf_goods.artic = p-artic and buf_goods.prod-type = p-prod-type and buf_goods.prod-code = p-prod-code .

    create temp-gds .
    { gbl/gdsbcode.i  buf_goods.gds-code  ?  temp-gds.b-code  no-error }
    if error-status :error then do:
      message   vss-workfile vss-revision vss-description skip
        "Ошибка при определении бар-кода товара" skip   "Артикул товара" skip buf_goods.artic
      view-as alert-box error .
    end.
    else assign temp-gds.sb-code = string(temp-gds.b-code) .

    { gbl/pftxvalg.i buf_goods.gds-code {&vat-tax-code} ? v-cntxt-host-code-obj obj-list.obj-type obj-list.obj-code temp-gds.vat-pc no-error }

    assign
      temp-gds.prod-type = buf_goods.prod-type
      temp-gds.prod-code = buf_goods.prod-code
      temp-gds.post-type = p-supp-type
      temp-gds.post-code = p-supp-code
      temp-gds.artic     = buf_goods.artic
      temp-gds.grp-name  = trim( buf_goods.grp-name )
      temp-gds.grp-code  = buf_goods.grp-code
      temp-gds.obj-type  = obj-list.obj-type
      temp-gds.obj-code  = obj-list.obj-code
      temp-gds.obj-name  = obj-list.obj-name
      temp-gds.unit-base = buf_goods.unit-base
      temp-gds.gds-name1 = buf_goods.engl-name
      temp-gds.gds-name  = buf_goods.gds-name
      temp-gds.in-code   = p-in-code
      temp-gds.part-code = p-part-code
    .
  /*  if g#gds-engl then assign temp-gds.gds-name = buf_goods.engl-name.*/
  end.
end procedure. /* CreateGDS */



procedure ColumnTitle :
  /* составили список товаров, теперь надо анализировать по ним кол-во колонок и формировать шапку */
  do on error undo, return error return-value :

    put stream outstream  skip cur-time-print() format "x(35)"   "Цены указаны в "  (if x-SET_val_TYPE = 1 then "{&abbr_rub_allshift}" else x-base-type )  string( "Страница" ) AT 100 PAGE-NUMBER( outstream ) FORMAT ">>>9" SKIP .
    put stream outstream   Line format frmt skip .
    if use-column[1]  = yes then  PUT stream OutStream  "|"  "№ п/п"              format "X(5)"  .
    if use-column[2]  = yes then  PUT stream OutStream  "|"  "  Код"              format "X(10)" .
    if use-column[3]  = yes then  PUT stream OutStream  "|"  "  Артикул"          format "X(16)" .
    if use-column[4]  = yes then  PUT stream OutStream  "|"  "  Название товара"  format "X(40)" .
    if use-column[5]  = yes then  PUT stream OutStream  "|"  "Ед."                format "X(3)"  .
    if use-column[6]  = yes then  PUT stream OutStream  "|"   "Фактическое"       format "X(14)" .
    if use-column[7]  = yes then  PUT stream OutStream  "|"   "Свободное"         format "X(14)" .
    if use-column[8]  = yes then  PUT stream OutStream  "|"   "Учетная"           format "X(15)" .
    if use-column[9]  = yes then  PUT stream OutStream  "|"   "Продажная"         format "X(15)" .
    if use-column[10] = yes then  PUT stream OutStream  "|"   "Сумма в учет."     format "X(15)" .
    if use-column[11] = yes then  PUT stream OutStream  "|"   "Сумма"             format "X(15)" .
    if use-column[12] = yes then  PUT stream OutStream  "|"   "Процент"           format "X(9)"  .
    if use-column[13] = yes then  PUT stream OutStream  "|"   "Ожидаемое"         format "X(13)" .
    PUT stream OutStream "|"   skip .
    if use-column[1]  = yes then  PUT stream OutStream  "|"  ""                   format "X(5)"  .
    if use-column[2]  = yes then  PUT stream OutStream  "|"  ""                   format "X(10)" .
    if use-column[3]  = yes then  PUT stream OutStream  "|"  ""                   format "X(16)" .
    if use-column[4]  = yes then  PUT stream OutStream  "|"  ""                   format "X(40)" .
    if use-column[5]  = yes then  PUT stream OutStream  "|"  "изм"                format "X(3)"  .
    if use-column[6]  = yes then  PUT stream OutStream  "|"   "кол-во"            format "X(14)" .
    if use-column[7]  = yes then  PUT stream OutStream  "|"   "кол-во"            format "X(14)" .
    if use-column[8]  = yes then  PUT stream OutStream  "|"   "цена с НДС"        format "X(15)" .
    if use-column[9]  = yes then  PUT stream OutStream  "|"   "цена"              format "X(15)" .
    if use-column[10] = yes then  PUT stream OutStream  "|"   "ценах с НДС"       format "X(15)" .
    if use-column[11] = yes then  PUT stream OutStream  "|"   "наценки"           format "X(15)" .
    if use-column[12] = yes then  PUT stream OutStream  "|"   "наценки"           format "X(9)"  .
    if use-column[13] = yes then  PUT stream OutStream  "|"   "кол-во"            format "X(13)" .
    put stream outstream "|" skip  Line format frmt skip .

  end.
end procedure. /* ColumnTitle */


procedure is-page :
  do on error undo, return error return-value :
    if line-counter( Outstream ) + 2 > page-size( Outstream ) then do:
      put stream outstream  skip Line format frmt skip "продолжение - на следующей странице" AT 30 SKIP .
      page stream OutStream .
      run ColumnTitle .
    end.
  end.
end procedure. /* is-page */



procedure PrintLine :
  do on error undo, return error return-value :
    if temp-gds.fact-qnty <> 0 then do:
      assign
        temp-gds.zak-price  = temp-gds.zak-sum  / abs ( temp-gds.fact-qnty)
        temp-gds.prod-price = temp-gds.prod-sum / abs ( temp-gds.fact-qnty)
      .
    end.
    assign
      temp-gds.naz-sum    = temp-gds.prod-sum - temp-gds.zak-sum
      temp-gds.naz-prc    = if temp-gds.zak-sum = 0 then 0 else temp-gds.naz-sum * 100 / temp-gds.zak-sum
    .
    if xClassify = "prod/grp-goods":U or xClassify = "grp-goods/prod":U or xClassify = "post/grp-goods":U or xClassify = "grp-goods/post":U then DO:
      assign
        all2-fact-qnty      = all2-fact-qnty + temp-gds.fact-qnty
        all2-free-qnty      = all2-free-qnty + temp-gds.free-qnty
        all2-wait-qnty      = all2-wait-qnty + temp-gds.wait-qnty
        all2-zak-sum        = all2-zak-sum   + temp-gds.zak-sum
        all2-naz-sum        = all2-naz-sum   + temp-gds.naz-sum
      .
    end.
    else do:
      if xClassify = "no-classify":U  then DO:
        assign
          all-fact-qnty      = all-fact-qnty + temp-gds.fact-qnty
          all-free-qnty      = all-free-qnty + temp-gds.free-qnty
          all-wait-qnty      = all-wait-qnty + temp-gds.wait-qnty
          all-zak-sum        = all-zak-sum   + temp-gds.zak-sum
          all-naz-sum        = all-naz-sum   + temp-gds.naz-sum
        .
      end.
      else do:
        assign
          all1-fact-qnty      = all1-fact-qnty + temp-gds.fact-qnty
          all1-free-qnty      = all1-free-qnty + temp-gds.free-qnty
          all1-wait-qnty      = all1-wait-qnty + temp-gds.wait-qnty
          all1-zak-sum        = all1-zak-sum   + temp-gds.zak-sum
          all1-naz-sum        = all1-naz-sum   + temp-gds.naz-sum
        .
      end.
    end.
    assign
      all0-fact-qnty      = all0-fact-qnty + temp-gds.fact-qnty
      all0-free-qnty      = all0-free-qnty + temp-gds.free-qnty
      all0-wait-qnty      = all0-wait-qnty + temp-gds.wait-qnty
      all0-zak-sum        = all0-zak-sum   + temp-gds.zak-sum
      all0-naz-sum        = all0-naz-sum   + temp-gds.naz-sum
    .

    if xSumsOnly = no then do:
      assign num-line = num-line + 1 .
      run is-page .

      if use-column[1]  = yes then do:
        PUT stream OutStream  "|"   num-line   format ">>>>9" .
        {&PutExcel}  string(num-line)   {&tabulation} .
      end.
      if use-column[2]  = yes then do:
        PUT stream OutStream  "|"   temp-gds.sb-code     format "X(10)" .
        {&PutExcel}  temp-gds.sb-code   {&tabulation} .
      end.
      if use-column[3]  = yes then do:
        PUT stream OutStream  "|"   temp-gds.artic       format "X(16)" .
        {&PutExcel}  temp-gds.artic   {&tabulation} .
      end.
      if use-column[4]  = yes then do:
        PUT stream OutStream  "|"   temp-gds.gds-name    format "X(40)" .
        {&PutExcel}  temp-gds.gds-name   {&tabulation} .
      end.
      if use-column[5]  = yes then do:
        PUT stream OutStream  "|"   temp-gds.unit-base   format "X(3)" .
        {&PutExcel}   temp-gds.unit-base  {&tabulation} .
      end.
      if use-column[6]  = yes then do:
        PUT stream OutStream  "|"   temp-gds.fact-qnty   format "->>>>>>>>9.999" .
        {&PutExcel}  excel-qnty ( temp-gds.fact-qnty )   {&tabulation} .
      end.
      if use-column[7]  = yes then do:
        PUT stream OutStream  "|"   temp-gds.free-qnty   format "->>>>>>>>9.999".
        {&PutExcel}  excel-qnty ( temp-gds.free-qnty )   {&tabulation} .
      end.
      if use-column[8]  = yes then do:
        PUT stream OutStream  "|"   temp-gds.zak-price   format "->>>>>>>>>>9.99" .
        {&PutExcel}  excel-sum ( temp-gds.zak-price )  {&tabulation} .
      end.
      if use-column[9]  = yes then do:
        PUT stream OutStream  "|"   temp-gds.prod-price  format "->>>>>>>>>>9.99" .
        {&PutExcel}  excel-sum ( temp-gds.prod-price )  {&tabulation} .
      end.
      if use-column[10] = yes then do:
        PUT stream OutStream  "|"   temp-gds.zak-sum     format "->>>>>>>>>>9.99" .
        {&PutExcel}  excel-sum ( temp-gds.zak-sum )  {&tabulation} .
      end.
      if use-column[11] = yes then do:
        PUT stream OutStream  "|"   temp-gds.naz-sum     format "->>>>>>>>>>9.99" .
        {&PutExcel}  excel-sum ( temp-gds.naz-sum )  {&tabulation} .
      end.
      if use-column[12] = yes then do:
        PUT stream OutStream  "|"   temp-gds.naz-prc     format "->>>>9.99" .
        {&PutExcel}  excel-sum ( temp-gds.naz-prc )  {&tabulation} .
      end.
      if use-column[13] = yes then do:
        PUT stream OutStream  "|"   temp-gds.wait-qnty   format "->>>>>>>9.999" .
       {&PutExcel}  excel-qnty ( temp-gds.wait-qnty )   {&tabulation} .
      end.
      {&PutExcel} {&new-line} .
      PUT stream OutStream "|" skip  .
    end.
  end.
end procedure. /* PrintLine */


procedure PrintName :
  do on error undo, return error return-value :
    define input  parameter str           as character no-undo .
    run is-page .

    PUT stream OutStream  "|"  str format frmt1 "|" skip .
    {&PutExcel}   str  {&new-line} .
  end.
end procedure. /* PrintName */



procedure PrintItog :
  do on error undo, return error return-value :
  define input  parameter str           as character no-undo .
  define input  parameter sum-fact-qnty as decimal   no-undo .
  define input  parameter sum-free-qnty as decimal   no-undo .
  define input  parameter sum-zak-sum   as decimal   no-undo .
  define input  parameter sum-naz-sum   as decimal   no-undo .
  define input  parameter sum-wait-qnty as decimal   no-undo .
  define input  parameter  level        as integer   no-undo .


    run is-page .
    put stream outstream   Line format frmt skip .
    run is-page .
    PUT stream OutStream  "|"  str  format frmt2 .
    do i = 1 to 5 :
      if i = 3 and use-column[3] then  {&PutExcel}   str .
      if use-column[i]  = yes then   {&PutExcel}   {&tabulation}  .
    end.
    if use-column[6]  = yes then do:
      PUT stream OutStream  "|"   sum-fact-qnty   format "->>>>>>>>9.999" .
     {&PutExcel}  excel-qnty ( sum-fact-qnty )   {&tabulation} .
    end.
    if use-column[7]  = yes then do:
      PUT stream OutStream  "|"   sum-free-qnty   format "->>>>>>>>9.999".
     {&PutExcel}  excel-qnty ( sum-free-qnty )   {&tabulation} .
    end.
    if use-column[8]  = yes then do:
      PUT stream OutStream  "|"   format "X(16)" .
     {&PutExcel}  {&tabulation} .
    end.
    if use-column[9]  = yes then do:
      PUT stream OutStream  "|"   format "X(16)" .
     {&PutExcel}  {&tabulation} .
    end.
    if use-column[10] = yes then do:
      PUT stream OutStream  "|"   sum-zak-sum     format "->>>>>>>>>>9.99" .
     {&PutExcel}  excel-sum ( sum-zak-sum )  {&tabulation} .
    end.
    if use-column[11] = yes then do:
      PUT stream OutStream  "|"   sum-naz-sum     format "->>>>>>>>>>9.99" .
     {&PutExcel}  excel-sum ( sum-naz-sum )  {&tabulation} .
    end.
    if use-column[12] = yes then do:
      PUT stream OutStream  "|"   format "X(10)" .
     {&PutExcel}  {&tabulation} .
    end.
    if use-column[13] = yes then do:
      PUT stream OutStream  "|"   sum-wait-qnty   format "->>>>>>>9.999" .
     {&PutExcel}  excel-qnty ( sum-wait-qnty )   {&tabulation} .
    end.
    {&PutExcel} {&new-line} .
    PUT stream OutStream "|" skip  .
    run is-page .
    put stream outstream   Line format frmt skip .

    case level :
      when 0 then do:
      end.
      when 1 then do:
        assign
          all-fact-qnty  = all-fact-qnty + all1-fact-qnty
          all-free-qnty  = all-free-qnty + all1-free-qnty
          all-wait-qnty  = all-wait-qnty + all1-wait-qnty
          all-zak-sum    = all-zak-sum   + all1-zak-sum
          all-naz-sum    = all-naz-sum   + all1-naz-sum
          all1-fact-qnty = 0
          all1-free-qnty = 0
          all1-wait-qnty = 0
          all1-zak-sum   = 0
          all1-naz-sum   = 0
        .
      end.
      when 2 then do:
        assign
          all1-fact-qnty  = all1-fact-qnty + all2-fact-qnty
          all1-free-qnty  = all1-free-qnty + all2-free-qnty
          all1-wait-qnty  = all1-wait-qnty + all2-wait-qnty
          all1-zak-sum    = all1-zak-sum   + all2-zak-sum
          all1-naz-sum    = all1-naz-sum   + all2-naz-sum
          all2-fact-qnty = 0
          all2-free-qnty = 0
          all2-wait-qnty = 0
          all2-zak-sum   = 0
          all2-naz-sum   = 0
        .
      end.
      when 3 then do:
        assign
          all0-fact-qnty = 0
          all0-free-qnty = 0
          all0-wait-qnty = 0
          all0-zak-sum   = 0
          all0-naz-sum   = 0
        .
      end.
    end case.

  end.
end procedure. /* PrintItog */