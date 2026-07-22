block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-ost-bd.p $
$Archive: cus/r-ost-bd.p $

Отчет Остатки по УБД

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/27/06
Author: Michael Kochetkov
Creation date: 03/27/06

*/

define input parameter p-obj1       as integer   no-undo .
define input parameter p-list-obj1  as character no-undo .
define input parameter p-obj2       as integer   no-undo .
define input parameter p-list-obj2  as character no-undo .
define input parameter x-itog       as logical   no-undo .
define input parameter x-lavel      as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-ost-bd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-ost-bd.p $":U .
define variable vss-description as character no-undo init "Остатки по УБД".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/r-page1.i }
{ rep/r-sym.i }
{ cmp/r-pril.i }
{ rep/f-fdec.i }   /* Функции для форматирования полей для передачи в EXcel         */
{ gbl/paramls.i }
{ trg/factord.i }
{ trg/partslib.i }
{ ref/grplibfn.i }

do
on error undo, return error
:

  DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
  ASSIGN parParentProc =  my-handle .

  define variable g#report-num as integer   no-undo .
  run get-report-num  in parParentProc ( output g#report-num ).

  define variable g#gds-engl as logical   no-undo .
  run get-gds-engl  in parParentProc ( output g#gds-engl ).

  { rep/mcrexcel.i }

  define Stream macr_excel.

  define var    v-fact-order-start     as decimal   no-undo .

  run day-begin-fact-order in this-procedure ( input x-date-start, output v-fact-order-start ). /*Поиск нач fact-order*/

  define temp-table temp-goods no-undo  /* для списка товаров */
    field gds-code  like goods.gds-code
    field artic     like goods.artic
    field prod-code like goods.prod-code
    field prod-type like goods.prod-type
    field gds-name  like goods.gds-name
    field grp-name  like goods.grp-name
    field full-grp-name  like goods.grp-name
    INDEX pi  IS PRIMARY gds-code
    INDEX pi1            grp-name gds-name
  .

  define temp-table temp-goods-obj no-undo
    field gds-code  like goods.gds-code
    field db-num    like db.db-num
    field obj-name  like clients.obj-name
    field obj-type  like clients.obj-type
    field obj-code  like clients.obj-code
    field qnty      as decimal
    field sum-zak   as decimal
    field sum-prod  as decimal
    INDEX pi  IS PRIMARY gds-code obj-type obj-code
    INDEX pi1       db-num
  .

  define temp-table Temp-Sum no-undo  /* для подсчета сумм */
    field num         as integer /* -2 - строка, -1 -все, ...- группа уровня */
    field ind          as integer
    field sum          as decimal
    field grp       like goods.grp-name
    field full_grp  like goods.grp-name
    index pi IS PRIMARY num ind
    index pi1  full_grp
  .

  define temp-table temp-obj no-undo
    field typ       as integer
    field db-num    like db.db-num
    field obj-name  like clients.obj-name
    field obj-type  like clients.obj-type
    field obj-code  like clients.obj-code
    INDEX pi  IS PRIMARY obj-type obj-code
    INDEX pi1            db-num typ
  .

  define temp-table temp-db no-undo
    field db-num    like db.db-num
    field db-name   like db.db-name
    INDEX pi1            db-num
  .

  define buffer buf_goods    for goods.
  define buffer buf_db       for db.
  define buffer buf_clients  for clients.
  define buffer buf_gds-obj  for gds-obj.
  define buffer buf_gds-grp  for gds-grp.
  define buffer buf_stk-line for stk-line.

  define variable Counter1    as integer   no-undo .
  define variable ii          as integer   no-undo .
  define variable CurrGrpName as character no-undo .
  define variable num-col     as integer initial 0  no-undo .
  define variable is-null     as logical   no-undo .
  define variable str-grp     as character no-undo .
  define variable p-num       as integer   no-undo .

  define variable ind         as integer   no-undo .
  define variable v-level     as integer   no-undo .
  define variable v-old-level as integer initial 0  no-undo .

  define variable v-row       as integer   no-undo .
  define variable v-col       as integer   no-undo .
  define variable v-ind       as integer   no-undo initial 1 .

  for each obj-list :
    find first buf_clients no-lock
      where buf_clients.obj-type = obj-list.obj-type
        and buf_clients.obj-code = obj-list.obj-code
    no-error .
    if available buf_clients then do:
      create temp-obj .
      assign
        temp-obj.typ       = 0
        temp-obj.db-num    = buf_clients.db-num
        temp-obj.obj-name  = buf_clients.obj-name
        temp-obj.obj-type  = obj-list.obj-type
        temp-obj.obj-code  = obj-list.obj-code
      .
    end.
  end.

  if p-obj1 = 2 then do:
    assign p-num = num-entries( p-list-obj1 ) .
    do ii = 1 to p-num by 2 :
       find first temp-obj
         where temp-obj.obj-type = entry( ii, p-list-obj1 )
           and temp-obj.obj-code = integer( entry( ii + 1 , p-list-obj1 ))
       no-error .
       if available temp-obj then do:
         if temp-obj.typ = 0 then
           assign
             temp-obj.typ = 1
             num-col = num-col + 1
           .
       end.
       else do:
         find first buf_clients no-lock
           where buf_clients.obj-type = entry( ii, p-list-obj1 )
             and buf_clients.obj-code = integer( entry( ii + 1 , p-list-obj1 ))
         .
         if available buf_clients then do:
           create temp-obj .
           assign
             temp-obj.typ       = 1
             temp-obj.db-num    = buf_clients.db-num
             temp-obj.obj-name  = buf_clients.obj-name
             temp-obj.obj-type  = buf_clients.obj-type
             temp-obj.obj-code  = buf_clients.obj-code
             num-col = num-col + 1 .
           .
         end.
       end.
     end.
  end.

  if p-obj2 = 2 then do:
    assign num-col = num-col + 1 .
    assign p-num = num-entries( p-list-obj2 ) .
    do ii = 1 to p-num by 2 :
       find first temp-obj
         where temp-obj.obj-type = entry( ii, p-list-obj2 )
           and temp-obj.obj-code = integer( entry( ii + 1 , p-list-obj2 ))
       no-error .
      if available temp-obj then do:
        if temp-obj.typ = 1 then assign num-col = num-col - 1 .
        assign temp-obj.typ = 2 .
      end.
      else do:
        find first buf_clients no-lock
          where buf_clients.obj-type = entry( ii, p-list-obj1 )
            and buf_clients.obj-code = integer( entry( ii + 1 , p-list-obj1 ))
        .
        if available buf_clients then do:
          create temp-obj .
          assign
            temp-obj.typ       = 2
            temp-obj.db-num    = buf_clients.db-num
            temp-obj.obj-name  = buf_clients.obj-name
            temp-obj.obj-type  = buf_clients.obj-type
            temp-obj.obj-code  = buf_clients.obj-code
          .
        end.
      end.
    end.
  end.

  for each temp-obj where temp-obj.typ <> 2 :  /* список убд */
    find first temp-db where temp-db.db-num = temp-obj.db-num no-error .
    if not available temp-db then do:
      assign num-col = num-col + 1 .
      create temp-db .
      find first db no-lock where db.db-num = temp-obj.db-num no-error .
      assign
        temp-db.db-num  = db.db-num
        temp-db.db-name = db.db-name
      .
    end.
  end.

  assign
    Counter1 = 0 .
  .

  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 50 } /* Показать окно информации о текущем процессе */

  if x-SelectGood = {&g-all} then do: /* все товары */
    for each buf_goods no-lock :
      for each temp-obj :
        find first buf_gds-obj no-lock
          where buf_gds-obj.gds-code  = buf_goods.gds-code
            and buf_gds-obj.obj-type  = temp-obj.obj-type
            and buf_gds-obj.obj-code  = temp-obj.obj-code
        no-error .

        if not available buf_gds-obj then next.
        { cus/r-ost-b1.i } /* проверка, подходит ли товар и заполнение темп-тейбла */
      end.
    end.
  end.
  else do:
    for each temp-obj :                /* встать на объект */
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
              where buf_gds-obj.obj-type  = temp-obj.obj-type
                and buf_gds-obj.obj-code  = temp-obj.obj-code
                and buf_gds-obj.prod-type = buf_clients.obj-type
                and buf_gds-obj.prod-code = buf_clients.obj-code
              use-index pi  :

              find first buf_goods no-lock
                where buf_goods.gds-code = buf_gds-obj.gds-code
              .
              { cus/r-ost-b1.i } /* проверка, подходит ли товар и заполнение темп-тейбла */
            end .
          end.                /* do ... по производителям */
        end .
        when {&g-grp} then do:    /* не все группы товаров */
          for each tmp#grp :
            find first buf_gds-grp no-lock
              where buf_gds-grp.node-code = tmp#grp.node-code
            .
            run grplib-get-full-name in this-procedure ( input buf_gds-grp.node-code, output CurrGrpName ) .

            for each buf_gds-obj no-lock
              where buf_gds-obj.obj-type = temp-obj.obj-type
                and buf_gds-obj.obj-code = temp-obj.obj-code
                and buf_gds-obj.grp-name begins CurrGrpName
              use-index obj-grp :

              find first buf_goods no-lock
                where buf_goods.gds-code = buf_gds-obj.gds-code
              .
              { cus/r-ost-b1.i } /* проверка, подходит ли товар и заполнение темп-тейбла */
            end .
          end.    /* do i = 1 to num-entries ( gdsgrp_recids ) : */
        end.
        otherwise do:
          for each gds-list ,
              each buf_gds-obj no-lock
            where buf_gds-obj.obj-type  = temp-obj.obj-type
              and buf_gds-obj.obj-code  = temp-obj.obj-code
              and buf_gds-obj.artic     = gds-list.artic
              and buf_gds-obj.prod-type = gds-list.prod-type
              and buf_gds-obj.prod-code = gds-list.prod-code
            :

            find first buf_goods no-lock
              where buf_goods.gds-code = buf_gds-obj.gds-code
            .
            { cus/r-ost-b1.i } /* проверка, подходит ли товар и заполнение темп-тейбла */
          end.
        end.

      end case.
    end.                    /* for each ... по объектам */
  end.

  /* составили список товаров - теперь ищем остатки  */
  run Ostatok in this-procedure .

  /* macr_excel - для экселя */
  assign
    make-excel = yes
    v-file-name = string(session :temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt"
  .
  output stream macr_excel to value(v-file-name) .
  assign v-ind = v-ind + 1 .

  { gbl/working.i }

  run PutColumnTitulExcel in this-procedure .
  run InitTempSum in this-procedure (-2) . /* уровен товарной строки */
  run InitTempSum in this-procedure (0) .  /* итоговая сумма */

  assign
    ind = 0
    v-old-level = 0
    v-level = 0
  .
/*  run gbl/inidebug.p .*/
  for each temp-goods
    break by temp-goods.grp-name
          by temp-goods.gds-name
    :
    if first-of(temp-goods.grp-name ) then run GrpSumTree in this-procedure .

    run PrintLine in this-procedure .

    if last-of(temp-goods.grp-name ) then do:
      do ii = 1 to v-level :      run AddTempSum in this-procedure (ii) .      end.
    End.
  end. /* for each temp-goods  */

  do ii = v-old-level to 0 /*( ind - 2 )*/ by -1 : /* удаляем старые заголовки из списка */
    find first temp-sum  where temp-sum.num = ii no-error .
    if available temp-sum then do:
      if x-itog = no then do:
        if ii = 0 then run macr_excel_char("Итого: ", v-row, 2) .
        else run macr_excel_char("Итого по группе " + temp-sum.grp + ":", v-row, 2) .
        run macr_cell_format ( 10, yes, no, ?, v-row , 2, v-row, 2) .
        for each Temp-Sum where Temp-Sum.num = ii :
          if TRUNCATE( Temp-Sum.ind / 3,0) = Temp-Sum.ind / 3 then run macr_excel_sum  ( Temp-Sum.sum, v-row, Temp-Sum.ind, 3) .
          else                                                     run macr_excel_sum  ( Temp-Sum.sum, v-row, Temp-Sum.ind, 2) .
        end.
        assign v-row = v-row + 1 .
      end.
      else do:
        if ii = 0 then do:
          run macr_excel_char("Итого: ", v-row, 2) .
          for each Temp-Sum where Temp-Sum.num = ii :
            if TRUNCATE( Temp-Sum.ind / 3,0) = Temp-Sum.ind / 3 then run macr_excel_sum  ( Temp-Sum.sum, v-row, Temp-Sum.ind, 3) .
            else                                                     run macr_excel_sum  ( Temp-Sum.sum, v-row, Temp-Sum.ind, 2) .
          end.
          assign v-row = v-row + 1 .
        end.
        else if x-lavel = -1 or x-lavel >= ( num-entries( right-trim(temp-sum.full_grp, {&delim-grp}), {&delim-grp} ) )  then do:
          run macr_excel_char(temp-sum.full_grp + ":", v-row, 2) .
          run macr_cell_format ( 10, yes, no, ?, v-row , 2, v-row, 2) .
          for each Temp-Sum where Temp-Sum.num = ii :
            if TRUNCATE( Temp-Sum.ind / 3,0) = Temp-Sum.ind / 3 then run macr_excel_sum  ( Temp-Sum.sum, v-row, Temp-Sum.ind, 3) .
            else                                                     run macr_excel_sum  ( Temp-Sum.sum, v-row, Temp-Sum.ind, 2) .
          end.
          assign v-row = v-row + 1 .
        end.
      end.
    end.
  end.

  for each temp-sum : delete temp-sum . end.

  output stream macr_excel close .
  run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name) .
  run end-proc .

  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */

  { gbl/stopwork.i }

  run rep/runexcel.p (v-file-name ).

end.

/* ******************************************************* */
{ cus/r-ost-b2.i } /* процедуры */

/* ******************************************************* */


procedure InitTempSum :
  define input parameter  p-num as integer   no-undo .

  do
  on error undo, return error return-value
  :
    define variable i as integer no-undo .
    define variable jj as integer no-undo .
    assign jj = 3 .

    do i = 1 to (3 * num-col) :
      create Temp-Sum .
      assign
        Temp-Sum.num  = p-num
        Temp-Sum.ind  = jj
        Temp-Sum.sum  = 0
        jj = jj + 1
      .
    end.
  end.
end procedure. /* InitTempSum */


procedure AddTempSum :
  define input parameter  p-num as integer   no-undo .

  do
  on error undo, return error return-value
  :
    define buffer buf_Temp-Sum for Temp-Sum .

    for each Temp-Sum
      where Temp-Sum.num = v-level
    :
      find first buf_Temp-Sum
        where buf_Temp-Sum.num  = p-num - 1
          and buf_Temp-Sum.ind  = Temp-Sum.ind
      no-error .
      if available buf_Temp-Sum then assign buf_Temp-Sum.sum = buf_Temp-Sum.sum + Temp-Sum.sum  .
    end.
  end.
end procedure. /* AddTempSum */