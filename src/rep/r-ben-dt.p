block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-ben-dt.p $
$Archive: rep/r-ben-dt.p $

Отчет по продажам ниже учетной цены

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/22/06
Author: Michael Kochetkov
Creation date: 03/22/06

*/

define input parameter SortType1       as integer   no-undo .
define input parameter Classify        as character no-undo .
define input parameter DetalWeek       as integer   no-undo .
define input parameter Itog            as logical   no-undo .
define input parameter x-date-start1   as date no-undo .
define input parameter x-date-end1     as date no-undo .
define input parameter x-date-start2   as date no-undo .
define input parameter x-date-end2     as date no-undo .
define input parameter x-date-start11  as date no-undo .
define input parameter x-date-end11    as date no-undo .
define input parameter x-date-start12  as date no-undo .
define input parameter x-date-end12    as date no-undo .
define input parameter x-date-start13  as date no-undo .
define input parameter x-date-end13    as date no-undo .
define input parameter x-date-start14  as date no-undo .
define input parameter x-date-end14    as date no-undo .
define input parameter x-date-start15  as date no-undo .
define input parameter x-date-end15    as date no-undo .
define input parameter ParamStr        as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-ben-dt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-ben-dt.p $":U .
define variable vss-description as character no-undo init "Отчет по продажам ниже учетной цены".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ trg/factord.i  }
{ ref/grplib.i   }
{ cmp/r-pril.i   }
{ rep/f-fdec.i   }

do
on error undo, return error
:

  DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
  ASSIGN parParentProc =  my-handle .

  define variable g#db-num as integer   no-undo .
  run get-db-num  in parParentProc ( output g#db-num ).

  define variable g#report-num as integer   no-undo .
  run get-report-num  in parParentProc ( output g#report-num ).

  define variable g#gds-engl as logical   no-undo .
  run get-gds-engl  in parParentProc ( output g#gds-engl ).


/*-----------------------------------------------------------------------------------------------------------------------*/
FUNCTION excel-sum2 RETURNS char (INPUT p-dec as decimal ).
/*   RETURN(excel-format-dec-to-char(Round(p-dec,2))) .*/
   RETURN(String(Round(p-dec,2))) .
END FUNCTION.
/*-----------------------------------------------------------------------------------------------------------------------*/
FUNCTION excel-qnty2 RETURNS char (INPUT p-dec as decimal ).
/*   RETURN(excel-format-dec-to-char(Round(p-dec,3))) .*/
   RETURN(String(Round(p-dec,3))) .
END FUNCTION.
/*-----------------------------------------------------------------------------------------------------------------------*/
 define stream SDoc.

define buffer buf_goods    for goods.
define buffer buf_clients  for clients.
define buffer buf_gds-obj  for gds-obj.
define buffer buf_gds-grp  for gds-grp.
define buffer buf_trn-doc  for trn-doc.
define buffer buf_doc-line for doc-line.
define buffer buf_stk-line for stk-line.
define buffer buf_obj-list for obj-list.


DEFINE temp-table temp-BenetTov no-undo
    field   sort-qnty        as decimal
    field   sum-prov         as decimal
    field   sum-beg          as decimal
    field   sum-end          as decimal
    field   prod-type        as char
    field   prod-code        as integer
    field   artic            as char
    field   gds-name         as char
    field   grp-name         as char
    field   full-grp-name    as char
    INDEX pi  IS PRIMARY     artic  prod-type prod-code
    INDEX pi1                sort-qnty
    INDEX pi2                full-grp-name
  .

  DEFINE temp-table temp-value no-undo
    /* 1-заказ, 2-прих. офис, 3-прих.отлож, 4-прих маг., 5-расх маг., 6-факт остат, 7-реал.,8,9,10,11,12,13-реал.,14-сред,15-инвент */
    field   type             as integer
    field   obj-type         as char
    field   obj-code         as integer
    field   data             as date
    field   qnty             as decimal
    field   sum              as decimal
    field   prod-type        as char
    field   prod-code        as integer
    field   artic            as char
    INDEX pi  IS PRIMARY     artic  prod-type prod-code type
    INDEX pi1                type data /*obj-type obj-code*/
  .
  DEFINE temp-table temp-SumObj no-undo
    field   obj-type         as char
    field   obj-code         as integer
    field   val              as decimal
    field   sum              as decimal
    INDEX pi  IS PRIMARY obj-type obj-code
  .
  DEFINE temp-table temp-date no-undo
    field   type             as integer
    field   data             as date
    INDEX pi  IS PRIMARY type data
  .

  DEFINE temp-table temp-month no-undo
    field   ind                as integer
    field   v-fact-order-start as decimal
    field   v-fact-order-end   as decimal
    field   dat-beg            as date
    field   dat-end            as date
    INDEX pi  IS PRIMARY  ind
  .

  DEFINE temp-table temp-ItogGrp no-undo
    field   ind         as integer
    field   val         as decimal
    field   sum         as decimal
    INDEX pi  IS PRIMARY  ind
  .
  DEFINE temp-table temp-ItogAll no-undo
    field   ind         as integer
    field   val         as decimal
    field   sum         as decimal
    INDEX pi  IS PRIMARY  ind
  .

  define variable  v-fact-order-start     as decimal   no-undo .  /* период отчета */
  define variable  v-fact-order-end       as decimal   no-undo .
  define variable  v-fact-order-start1    as decimal   no-undo .  /* период реализации */
  define variable  v-fact-order-end1      as decimal   no-undo .
  define variable  v-fact-order-start2    as decimal   no-undo .  /* период сред. сут реал. */
  define variable  v-fact-order-end2      as decimal   no-undo .

  define variable  Counter1 as integer   no-undo .
  define variable  CurrGrpName as character no-undo .
  define variable  tmp-fact-order  as decimal   no-undo .
  define variable  tmp-date-start  as date      no-undo .
  define variable  tmp-fact-order1 as decimal   no-undo .
  define variable  tmp-date-end    as date      no-undo .
  define variable  v-base-rate     as decimal   no-undo .
  define variable  v-base-scale    as decimal   no-undo .
  define variable  v-base-rate-z   as decimal   no-undo .
  define variable  v-base-scale-z  as decimal   no-undo .
  define variable  b-code          as integer   no-undo .
  define variable  ii as integer no-undo .
  define variable  NumObj    as integer initial 1  no-undo .
  define variable  NumColumn as integer initial 0  no-undo .
  define variable  NumPrice  as integer initial 0  no-undo .
  define variable  NumLine   as integer initial 1  no-undo .
  define variable  Num-Week   as integer initial 0  no-undo .
  define variable  val-all as decimal   no-undo .
  define variable  sum-all as decimal   no-undo .
  define variable  ind as integer   no-undo .
  define variable  igr as integer   no-undo .
/*  define variable  jj as integer initial 0 no-undo .*/
  define variable  is-zapr as logical   no-undo .
/*  define variable  st-week as logical   no-undo .*/
  define variable  TitleStr1 as character no-undo .
  define variable  TitleStr2 as character no-undo .
  define variable  TitleStr3 as character no-undo .
  define variable  TitleStr4 as character no-undo .
  define variable  TitleH1 as character no-undo .
  define variable  TitleH2 as character no-undo .
  define variable  TitleH3 as character no-undo .
  define variable  TypeValCli as integer   no-undo .
  define variable  use-column1  as logical extent 20 no-undo .
  define variable  NumZakaz  as integer   no-undo .
  define variable  NumPrihod as integer   no-undo .
  define variable  b2 as logical initial no  no-undo .
  define variable  NameDate as character no-undo .

  run day-begin-fact-order in this-procedure ( input x-date-start,         output v-fact-order-start ).   /*Поиск нач fact-order*/
  run day-begin-fact-order in this-procedure ( input ( x-date-end + 1 ),   output v-fact-order-end ).     /*Поиск посл fact-order*/
  run day-begin-fact-order in this-procedure ( input x-date-start1,        output v-fact-order-start1 ).  /*Поиск нач fact-order*/
  run day-begin-fact-order in this-procedure ( input ( x-date-end1 + 1 ),  output v-fact-order-end1 ).    /*Поиск посл fact-order*/
  run day-begin-fact-order in this-procedure ( input x-date-start2,        output v-fact-order-start2 ).  /*Поиск нач fact-order*/
  run day-begin-fact-order in this-procedure ( input ( x-date-end2 + 1 ),  output v-fact-order-end2 ).    /*Поиск посл fact-order*/

  DO ii = 1 TO 20 :
    assign use-column1 [ii] = no .
  end.
  DO ii = 1 TO NUM-ENTRIES(ParamStr):
    assign ind = integer(ENTRY(ii,ParamStr)) .
    if ind > 0 and ind < 20 then assign  use-column1 [ ind ] = yes  .
  end.

  /* заполняем табл. с месяцами или неделями */
  if use-column1[15] = yes then do:
    assign  ii = 1 .
    if DetalWeek = 1 then do:
      assign
        NameDate = "неделя"
      .
      if x-date-start11 <> ? and x-date-end11 <> ? then do:
        Num-Week = Num-Week + 1 .
        create temp-month .
        assign
          temp-month.ind = ii
          ii = ii + 1
          temp-month.dat-beg = x-date-start11
          temp-month.dat-end = x-date-end11
        .
        run day-begin-fact-order in this-procedure ( input x-date-start11,       output temp-month.v-fact-order-start ). /*Поиск нач fact-order*/
        run day-begin-fact-order in this-procedure ( input ( x-date-end11 + 1 ), output temp-month.v-fact-order-end ).   /*Поиск посл fact-order*/
      end.
      if x-date-start12 <> ? and x-date-end12 <> ? then do:
        Num-Week = Num-Week + 1 .
        create temp-month .
        assign
          temp-month.ind = ii
          ii = ii + 1
          temp-month.dat-beg = x-date-start12
          temp-month.dat-end = x-date-end12
        .
        run day-begin-fact-order in this-procedure ( input x-date-start12,       output temp-month.v-fact-order-start ). /*Поиск нач fact-order*/
        run day-begin-fact-order in this-procedure ( input ( x-date-end12 + 1 ), output temp-month.v-fact-order-end ).   /*Поиск посл fact-order*/
      end.
      if x-date-start13 <> ? and x-date-end13 <> ? then do:
        Num-Week = Num-Week + 1 .
        create temp-month .
        assign
          temp-month.ind = ii
          ii = ii + 1
          temp-month.dat-beg = x-date-start13
          temp-month.dat-end = x-date-end13
        .
        run day-begin-fact-order in this-procedure ( input x-date-start13,       output temp-month.v-fact-order-start ). /*Поиск нач fact-order*/
        run day-begin-fact-order in this-procedure ( input ( x-date-end13 + 1 ), output temp-month.v-fact-order-end ).   /*Поиск посл fact-order*/
      end.
      if x-date-start14 <> ? and x-date-end14 <> ? then do:
        Num-Week = Num-Week + 1 .
        create temp-month .
        assign
          temp-month.ind = ii
          ii = ii + 1
          temp-month.dat-beg = x-date-start14
          temp-month.dat-end = x-date-end14
        .
        run day-begin-fact-order in this-procedure ( input x-date-start14,       output temp-month.v-fact-order-start ). /*Поиск нач fact-order*/
        run day-begin-fact-order in this-procedure ( input ( x-date-end14 + 1 ), output temp-month.v-fact-order-end ).   /*Поиск посл fact-order*/
      end.
      if x-date-start15 <> ? and x-date-end15 <> ? then do:
        Num-Week = Num-Week + 1 .
        create temp-month .
        assign
          temp-month.ind = ii
          ii = ii + 1
          temp-month.dat-beg = x-date-start15
          temp-month.dat-end = x-date-end15
        .
        run day-begin-fact-order in this-procedure ( input x-date-start15,       output temp-month.v-fact-order-start ). /*Поиск нач fact-order*/
        run day-begin-fact-order in this-procedure ( input ( x-date-end15 + 1 ), output temp-month.v-fact-order-end ).   /*Поиск посл fact-order*/
      end.
    end.
    else do: /* заполняем табл. с месяцами */
      assign
        NameDate = "месяц"
      .
      define variable mon as integer   no-undo .
      define variable yer as integer   no-undo .
      define variable dat as date   no-undo .
      assign
        mon = month(x-date-start1)
        yer = year(x-date-start1)
      .
      create temp-month .
      assign
        Num-Week = Num-Week + 1
        temp-month.ind                = 1
        temp-month.dat-beg            = x-date-start1
        temp-month.v-fact-order-start = v-fact-order-start1
      .
FillDt:
      do ii = 2 to 1000 :
        assign mon = mon + 1 .
        if mon > 12 then assign mon = 1  yer = yer + 1 .
        assign
          dat = date(mon,1,yer)
          temp-month.dat-end = dat - 1
        .
        if temp-month.dat-end >= x-date-end1 then do:
          assign
            temp-month.dat-end          = x-date-end1
            temp-month.v-fact-order-end = v-fact-order-end1
          .
          leave FillDt .
        end.
        run day-begin-fact-order in this-procedure ( input ( temp-month.dat-end + 1 ), output temp-month.v-fact-order-end ).   /*Поиск посл fact-order*/
        create temp-month .
        assign
          temp-month.ind = ii
/*          ii = ii + 1*/
          Num-Week = Num-Week + 1
          temp-month.dat-beg            = dat
        .
        run day-begin-fact-order in this-procedure ( input dat, output temp-month.v-fact-order-start ).   /*Поиск посл fact-order*/
      end.
    end.
  end.

  assign
    Counter1 = 0 .
  .
  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */

  for each obj-list :
    create temp-SumObj .
    assign
      NumObj = NumObj + 1
      temp-SumObj.obj-type = obj-list.obj-type
      temp-SumObj.obj-code = obj-list.obj-code
      temp-SumObj.sum = 0
      temp-SumObj.val = 0
    .
  end.

  for each temp-BenetTov : delete temp-BenetTov . end.
  for each temp-ItogGrp  : delete temp-ItogGrp  . end.
  for each temp-ItogAll  : delete temp-ItogAll  . end.

  if x-SelectGood = {&g-all} then do: /* все товары */
    for each buf_goods no-lock :
      for each obj-list :
        find first buf_gds-obj no-lock
          where buf_gds-obj.obj-type  = obj-list.obj-type
            and buf_gds-obj.obj-code  = obj-list.obj-code
            and buf_gds-obj.artic     = buf_goods.artic
            and buf_gds-obj.prod-type = buf_goods.prod-type
            and buf_gds-obj.prod-code = buf_goods.prod-code
        no-error .

        if not available buf_gds-obj then next .
        { rep/r-ben-d1.i } /* смотрим, были ли продажи и кладем в темп-тейбл  */
        run CalculBenet in this-procedure (v-fact-order-start,v-fact-order-end,v-fact-order-start1,v-fact-order-end1,v-fact-order-start2,v-fact-order-end2) . /* считаем, и если не было приходов или заказов - удаляем */
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

            find first buf_goods no-lock
              where buf_goods.gds-code = buf_gds-obj.gds-code
            .
            { rep/r-ben-d1.i  } /* смотрим, были ли продажи и кладем в темп-тейбл  */
/*            run CalculBenet in this-procedure (v-fact-order-start,v-fact-order-end,v-fact-order-start1,v-fact-order-end1,v-fact-order-start11,v-fact-order-end11,v-fact-order-start12,v-fact-order-end12,v-fact-order-start13,v-fact-order-end13,v-fact-order-start14,v-fact-order-end14,v-fact-order-start15,v-fact-order-end15,v-fact-order-start2,v-fact-order-end2) . /* считаем, и если не было приходов или заказов - удаляем */*/
            run CalculBenet in this-procedure (v-fact-order-start,v-fact-order-end,v-fact-order-start1,v-fact-order-end1,v-fact-order-start2,v-fact-order-end2) . /* считаем, и если не было приходов или заказов - удаляем */
          end.
        end.
        when 3 then do:    /* не все производители */
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
            { rep/r-ben-d1.i  } /* смотрим, были ли продажи и кладем в темп-тейбл  */
            run CalculBenet in this-procedure (v-fact-order-start,v-fact-order-end,v-fact-order-start1,v-fact-order-end1,v-fact-order-start2,v-fact-order-end2) . /* считаем, и если не было приходов или заказов - удаляем */
          end.                /* do ... по производителям */
        end .
        when 2 then do:    /* не все группы товаров */
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
              { rep/r-ben-d1.i  } /* смотрим, были ли продажи и кладем в темп-тейбл  */
              run CalculBenet in this-procedure (v-fact-order-start,v-fact-order-end,v-fact-order-start1,v-fact-order-end1,v-fact-order-start2,v-fact-order-end2) . /* считаем, и если не было приходов или заказов - удаляем */
            end .
          end.    /* do i = 1 to num-entries ( gdsgrp_recids ) : */
        end.
      end case.
    end.                    /* for each ... по объектам */
  end.

  /* составили список товаров, теперь надо анализировать по ним кол-во колонок и формировать шапку */
  run ColumnTitle in this-procedure .

  run rep/extitle.p (1) .   /* Печать шапки */

  if Classify = "no-classify":u then do:
    for each temp-BenetTov
      break by sort-qnty descending
    :
      run PrintLine        in this-procedure .
    end.
  end.
  else do:
    for each temp-BenetTov
      break by full-grp-name
            by sort-qnty descending
    :
      if first-of(full-grp-name) then do:
        if Itog = no then {&PutExcel}  {&tabulation}  {&tabulation}  temp-BenetTov.grp-name  {&tabulation}  {&new-line} .
      end.
      run PrintLine        in this-procedure .
      if last-of(full-grp-name) then do:
        if Itog = no then do:
          {&PutExcel}  {&tabulation}  {&tabulation}  "Итого по группе: " temp-BenetTov.grp-name {&tabulation}  .
        end.
        else  do:
          {&PutExcel} string(NumLine) {&tabulation}  {&tabulation}  temp-BenetTov.grp-name {&tabulation}  .
          assign   NumLine = NumLine + 1 .
        end.
        if use-column1[1] = yes then {&PutExcel}    {&tabulation} .
        if use-column1[2] = yes then {&PutExcel}    {&tabulation} .
        if use-column1[3] = yes then {&PutExcel}    {&tabulation} .
        for each temp-ItogGrp :
          {&PutExcel}  excel-qnty2(temp-ItogGrp.val)  {&tabulation}  excel-sum2(temp-ItogGrp.sum)  {&tabulation} .
          assign
            temp-ItogGrp.val = 0
            temp-ItogGrp.sum = 0
          .
        end.
        {&PutExcel} {&new-line} .
      end.
    end.
  end.

  {&PutExcel}  {&tabulation}  {&tabulation}  "Итого: " {&tabulation} /* {&new-line} */ .
  if use-column1[1] = yes then {&PutExcel}    {&tabulation} .
  if use-column1[2] = yes then {&PutExcel}    {&tabulation} .
  if use-column1[3] = yes then {&PutExcel}    {&tabulation} .
  for each temp-ItogAll :
    {&PutExcel}  excel-qnty2(temp-ItogAll.val)  {&tabulation}  excel-sum2(temp-ItogAll.sum)  {&tabulation} .
  end.
  {&PutExcel} {&new-line} .

  {&CloseExcel}

  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */

  run rep/runexcel.p ( string( session:temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt" ).

end.


procedure ColumnTitle :
  /* составили список товаров, теперь надо анализировать по ним кол-во колонок и формировать шапку */
  do
  on error undo, return error return-value
  :
  end.
  assign
    igr = 0
    NumZakaz = 0
    NumPrihod = 0
  .

  { rep/r-ben-d2.i }

  do ii = 1 to igr :
    create temp-ItogAll .
    assign
      temp-ItogAll.ind = ii
      temp-ItogAll.val = 0
      temp-ItogAll.sum = 0
    .
    if Classify = "grp-goods":u then do:
      create temp-ItogGrp .
      assign
        temp-ItogGrp.ind = ii
        temp-ItogGrp.val = 0
        temp-ItogGrp.sum = 0
      .
    end.
  end.

end procedure. /* ColumnTitle */


procedure CalculBenet :
/* считаем, и если не было приходов или заказов - удаляем */
  define input parameter v-fact-order-start     as decimal no-undo .
  define input parameter v-fact-order-end       as decimal no-undo .
  define input parameter v-fact-order-start1    as decimal no-undo .
  define input parameter v-fact-order-end1      as decimal no-undo .
  define input parameter v-fact-order-start2    as decimal no-undo .
  define input parameter v-fact-order-end2      as decimal no-undo .
  do
  on error undo, return error return-value
  :
  end.

  { rep/r-ben-d3.i }

end procedure. /* CalculBenet */

procedure PrintLine :
  do
  on error undo, return error return-value
  :
  end.
  assign igr = 0 .
  { rep/r-ben-d5.i }

end procedure. /* PrintLine */

procedure SumGroup :
  define input parameter val  as decimal no-undo .
  define input parameter sum  as decimal no-undo .
  do
  on error undo, return error return-value
  :
  end.
  assign  igr = igr + 1 .

  find first temp-ItogAll
    where temp-ItogAll.ind = igr
    no-error .
  if available temp-ItogAll then do:
    assign
      temp-ItogAll.ind = igr
      temp-ItogAll.val = temp-ItogAll.val + val
      temp-ItogAll.sum = temp-ItogAll.sum + sum
    .
  end.

  if Classify = "grp-goods":u then do:
    find first temp-ItogGrp
      where temp-ItogGrp.ind = igr
      no-error .
    if available temp-ItogGrp then do:
      assign
        temp-ItogGrp.ind = igr
        temp-ItogGrp.val = temp-ItogGrp.val + val
        temp-ItogGrp.sum = temp-ItogGrp.sum + sum
      .
    end.
  end.

end procedure. /* SumGroup */