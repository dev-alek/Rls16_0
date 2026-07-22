block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-spd-p.p $
$Archive: rep/r-spd-p.p $

Отчет по скорости продаж

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/23/06
Author: Michael Kochetkov
Creation date: 03/23/06

*/

define input parameter p-provider as integer   no-undo .
define input parameter p-null     as logical   no-undo .
define input parameter p-rashod   as logical   no-undo .
define input parameter p-speed    as logical   no-undo .
define input parameter p-day      as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-spd-p.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-spd-p.p $":U .
define variable vss-description as character no-undo init "Отчет по скорости продаж".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-page1.i  }
{ rep/r-sym.i    }
{ cmp/r-pril.i   }
{ rep/r-cost.i   }
{ rep/r-sale.i   }
{ rep/f-fdec.i   }
{ gbl/paramls.i  }
{ trg/factord.i  }
{ trg/partslib.i }
{ ref/grplibfn.i }

DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
ASSIGN parParentProc =  my-handle .

  define variable g#report-num as integer   no-undo .
  run get-report-num  in parParentProc ( output g#report-num ).

  define variable g#gds-engl as logical   no-undo .
  run get-gds-engl  in parParentProc ( output g#gds-engl ).

{ rep/mcrexcel.i }

do
on error undo, return error
:

  define var    v-fact-order-start     as decimal   no-undo .
  define var    v-fact-order-end       as decimal   no-undo .

  run day-begin-fact-order in this-procedure ( input x-date-start, output v-fact-order-start ). /*Поиск нач fact-order*/
  run day-begin-fact-order in this-procedure ( input ( x-date-end + 1 ),   output v-fact-order-end ). /*Поиск посл fact-order*/


  define temp-table temp-goods no-undo  /* для списка товаров */
    field gds-code  like goods.gds-code
    field artic     like goods.artic
    field prod-code like goods.prod-code
    field prod-type like goods.prod-type
    field gds-name  like goods.gds-name
    field grp-name  like goods.grp-name
    field sum-reserv   as decimal
    field sum-postup   as decimal
    field sum-ostat    as decimal
    field sum-speed    as decimal
    INDEX pi  IS PRIMARY gds-code
    INDEX pi1            grp-name gds-name
  .

  define temp-table temp-goods-cli no-undo  /* для списка товаров */
    field gds-code  like goods.gds-code
    field artic     like goods.artic
    field prod-code like goods.prod-code
    field prod-type like goods.prod-type
    field gds-name  like goods.gds-name
    field cli       like clients.obj-name
    field cli-type  like clients.obj-type
    field cli-code  like clients.obj-code
    field grp-name  like goods.grp-name
    field sum-reserv   as decimal
    field sum-postup   as decimal
    field sum-ostat    as decimal
    field sum-speed    as decimal
    INDEX pi  IS PRIMARY gds-code cli-type cli-code
    INDEX pi1            cli grp-name gds-name
  .

  define temp-table Temp-obj1 no-undo  /* для подсчета сумм */
    field gds-code     like goods.gds-code
    field cli-type     like clients.obj-type
    field cli-code     like clients.obj-code
    field obj-code     like obj-list.obj-code
    field obj-type     like obj-list.obj-type
    field rashod       as decimal
    field speed        as decimal
    field ostat        as decimal
    field reserv   as decimal
    field postup   as decimal
    index pi IS PRIMARY gds-code obj-type obj-code
    INDEX pi1           gds-code obj-type obj-code cli-type cli-code
  .

  define temp-table Temp-Sum no-undo  /* для подсчета сумм */
    field type         as integer /* 1 - строка, 4 -все, 2- группа, 3 - поставщик */
    field ind          as integer
    field sum          as decimal
    index pi IS PRIMARY type ind
  .

  define temp-table Temp-cli no-undo  /* для клиентов */
    field gds-code     like goods.gds-code
    field cli          like clients.obj-name
    field cli-type     like clients.obj-type
    field cli-code     like clients.obj-code
    index pi IS PRIMARY gds-code cli-type cli-code
  .

  define temp-table Temp-date no-undo  /* для дат на объектах */
    field obj-code       like obj-list.obj-code
    field obj-type       like obj-list.obj-type
    field cur-date       as date
    field cur-fact-order as decimal
    index pi IS PRIMARY obj-type obj-code
  .

  define temp-table Temp-DayNal no-undo  /* для дат наличия  */
    field cur-date  as date
    field f-o1 as decimal
    field f-o2 as decimal
    field DayNal    as logical
    index pi IS PRIMARY cur-date
    index pi1   DayNal
  .

  define buffer buf_goods    for goods.
  define buffer buf_clients  for clients.
  define buffer buf_gds-obj  for gds-obj.
  define buffer buf_gds-grp  for gds-grp.
  define buffer buf_trn-doc  for trn-doc.
  define buffer buf1_doc-line for doc-line.
  define buffer buf_stk-line for stk-line.
  define buffer buf_stk-supp-line for stk-supp-line.

  define variable  Counter1    as integer   no-undo .
  define variable  ii          as integer   no-undo .
  define variable  CurrGrpName as character no-undo .
  define variable  str-find    as character no-undo .
  define variable  str-find1   as character no-undo .
  define variable  v-day-nal   as integer   no-undo .
  define variable  str-grp     as character no-undo .
  define variable  str-cli     as character no-undo .

  define variable v-row       as integer   no-undo .
  define variable v-col       as integer   no-undo .
  define variable v-ind       as integer   no-undo initial 1 .

  for each obj-list :
    create Temp-date .
    assign
      Temp-date.obj-type = obj-list.obj-type
      Temp-date.obj-code = obj-list.obj-code
    .
    { gbl/curobjdt.i obj-list.obj-type obj-list.obj-code Temp-date.cur-date }
    run day-begin-fact-order in this-procedure ( input Temp-date.cur-date + 1, output Temp-date.cur-fact-order ). /*Поиск нач fact-order*/
  end.

  assign
    Counter1 = 0 .
  .

  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */

  if x-SelectGood = {&g-all} then do: /* все товары */
    for each buf_goods no-lock :
      for each obj-list :
        find first buf_gds-obj no-lock
          where buf_gds-obj.gds-code  = buf_goods.gds-code
            and buf_gds-obj.obj-type  = obj-list.obj-type
            and buf_gds-obj.obj-code  = obj-list.obj-code
        no-error .

        if not available buf_gds-obj then next.
        { rep/spd-p-1.i } /* проверка, подходит ли товар и заполнение темп-тейбла */
      end.
    end.
  end.
  else do:
    for each obj-list :                /* встать на объект */
      case x-SelectGood :
        when {&g-all} then do:
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

              find first buf_goods no-lock
                where buf_goods.gds-code = buf_gds-obj.gds-code
              .
              { rep/spd-p-1.i } /* проверка, подходит ли товар и заполнение темп-тейбла */
            end .
          end.                /* do ... по производителям */
        end .
        when {&g-grp} then do:    /* не все группы товаров */
          for each tmp#grp :
            find first buf_gds-grp no-lock
              where buf_gds-grp.node-code = tmp#grp.node-code
            .
            run grplib-get-full-name in this-procedure( input buf_gds-grp.node-code, output CurrGrpName ) .

            for each buf_gds-obj no-lock
              where buf_gds-obj.obj-type = obj-list.obj-type
                and buf_gds-obj.obj-code = obj-list.obj-code
                and buf_gds-obj.grp-name begins CurrGrpName
              use-index obj-grp :

              find first buf_goods no-lock
                where buf_goods.gds-code = buf_gds-obj.gds-code
              .
              { rep/spd-p-1.i } /* проверка, подходит ли товар и заполнение темп-тейбла */
            end .
          end.    /* do i = 1 to num-entries ( gdsgrp_recids ) : */
        end.
        otherwise do:  /* список товаров */
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
            { rep/spd-p-1.i } /* проверка, подходит ли товар и заполнение темп-тейбла */
          end.
        end.
      end case.
    end.                    /* for each ... по объектам */
  end.

  define variable xdate as date .
  repeat xdate = x-date-start to x-date-end :       /*по каждому дню  */
    create Temp-DayNal .
    assign
      Temp-DayNal.cur-date = xdate
      Temp-DayNal.DayNal   = no
    .
    run day-begin-fact-order in this-procedure ( input Temp-DayNal.cur-date        , output Temp-DayNal.f-o1 ). /* Поиск нач fact-order  */
    run day-begin-fact-order in this-procedure ( input ( Temp-DayNal.cur-date + 1 ), output Temp-DayNal.f-o2 ). /* Поиск посл fact-order */
  end.

  /* составили список товаров - теперь ищем всех поставщиков, которые их поставляли */
  if p-provider = 1 then do: /* нет разбиения по поставщикам, просто справочно */
    run search-prov in this-procedure .
    run Ostatok in this-procedure .
  end.
  else do: /* делаем новый тт для поставщиков */
    run search-prov1 in this-procedure .
    run Ostatok1 in this-procedure .
  end.

  /* macr_excel - для экселя */
  assign
    make-excel = yes
    v-file-name = string(session :temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt"
  .
  output stream macr_excel to value(v-file-name) .
  assign v-ind = v-ind + 1 .


  { gbl/working.i }

  run PutColumnTitulExcel in this-procedure .
  run InitTempSum in this-procedure (2) .
  run InitTempSum in this-procedure (3) .

  if p-provider = 1 then do: /* нет разбиения по поставщикам, просто справочно */
    for each temp-goods
      break by temp-goods.grp-name
            by temp-goods.gds-name
      :
      if first-of(temp-goods.grp-name ) then do:
        run macr_excel_char("Группа: " + temp-goods.grp-name, v-row, 2) .
        assign
          v-row = v-row + 1
          str-grp = temp-goods.grp-name
        .
      end.
      run PrintLine in this-procedure .
      if last-of(temp-goods.grp-name ) then run PrintItog in this-procedure (2) .
    end. /* for each temp-goods  */
    run PrintItog in this-procedure (3) .
  end.
  else do:
    run InitTempSum in this-procedure (4) .
    for each temp-goods-cli
      break by temp-goods-cli.cli
            by temp-goods-cli.grp-name
            by temp-goods-cli.gds-name
      :
      if first-of(temp-goods-cli.cli ) then do:
        run macr_excel_char("Поставщик: " + temp-goods-cli.cli, v-row, 2) .
        assign
          v-row = v-row + 1
          str-cli = temp-goods-cli.cli
        .
      end.
      if first-of(temp-goods-cli.grp-name ) then do:
        run macr_excel_char("Группа: " + temp-goods-cli.grp-name, v-row, 2) .
        assign
          v-row = v-row + 1
          str-grp = temp-goods-cli.grp-name
        .
      end.
      run PrintLine1 in this-procedure .
      if last-of(temp-goods-cli.grp-name ) then run PrintItog in this-procedure (2) .
      if last-of(temp-goods-cli.cli )      then run PrintItog in this-procedure (3) .
    end. /* for each temp-goods  */
    run PrintItog in this-procedure (4) .
  end.

  output stream macr_excel close .
  run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name) .
  run end-proc .

  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */

  { gbl/stopwork.i }

  run rep/runexcel.p (v-file-name ).

end.

/* ******************************************************* */

{ rep/spd-p-2.i } /* процедуры при выборке по группам */
{ rep/spd-p-3.i } /* процедуры при выборке по поставщикам */
{ rep/spd-p-4.i } /* процедуры вывода в excel */

/* ******************************************************* */


procedure InitTempSum :
  define input parameter  p-num as integer   no-undo .

  do
  on error undo, return error return-value
  :
    assign ii = 3 .

    for each obj-list :
      if p-rashod = yes then do:
        create Temp-Sum .
        assign
          Temp-Sum.type = p-num
          Temp-Sum.ind  = ii
          Temp-Sum.sum  = 0
          ii = ii + 1
        .
      end.
      if p-speed = yes then do:
        create Temp-Sum .
        assign
          Temp-Sum.type = p-num
          Temp-Sum.ind  = ii
          Temp-Sum.sum  = 0
          ii = ii + 1
        .
      end.
      create Temp-Sum .
      assign
        Temp-Sum.type = p-num
        Temp-Sum.ind  = ii
        Temp-Sum.sum  = 0
        ii = ii + 1
      .
      create Temp-Sum .
      assign
        Temp-Sum.type = p-num
        Temp-Sum.ind  = ii
        Temp-Sum.sum  = 0
        ii = ii + 1
      .
      create Temp-Sum .
      assign
        Temp-Sum.type = p-num
        Temp-Sum.ind  = ii
        Temp-Sum.sum  = 0
        ii = ii + 1
      .
    end.
    create Temp-Sum .
    assign
      Temp-Sum.type = p-num
      Temp-Sum.ind  = ii
      Temp-Sum.sum  = 0
      ii = ii + 1
    .
    create Temp-Sum .
    assign
      Temp-Sum.type = p-num
      Temp-Sum.ind  = ii
      Temp-Sum.sum  = 0
      ii = ii + 1
    .
  end.
end procedure. /* InitTempSum */


procedure AddTempSum :
  define input parameter  p-num as integer   no-undo .

  do
  on error undo, return error return-value
  :
    define buffer buf_Temp-Sum for Temp-Sum .

    for each Temp-Sum
      where Temp-Sum.type = p-num
    :
      find first buf_Temp-Sum
        where buf_Temp-Sum.type = p-num - 1
          and buf_Temp-Sum.ind  = Temp-Sum.ind
      no-error .
      assign Temp-Sum.sum = Temp-Sum.sum + buf_Temp-Sum.sum  .
    end.
  end.
end procedure. /* AddTempSum */