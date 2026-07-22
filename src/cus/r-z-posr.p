block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-z-posr.p $
$Archive: cus/r-z-posr.p $

Сравнительный отчет по ценам товара на объектах

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/27/06
Author: Michael Kochetkov
Creation date: 03/27/06

*/

define input parameter p-host       as integer   no-undo .
define input parameter SortType     as integer   no-undo .
define input parameter sort-grp     as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-z-posr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-z-posr.p $":U .
define variable vss-description as character no-undo init "Сравнительный отчет по ценам товара на объектах".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/r-page1.i  }
{ rep/r-sym.i    }
{ cmp/r-pril.i   }
{ rep/f-fdec.i   }   /* Функции для форматирования полей для передачи в EXcel         */
{ gbl/paramls.i  }
{ trg/factord.i  }
{ gbl/temphost.i }
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

&Scop Sort-pole  if SortType = 1 then  temp-goods.b-code Else (if SortType = 2 then  temp-goods.artic Else  temp-goods.gds-name)

  define Stream macr_excel.

  define var    v-fact-order-start     as decimal   no-undo .
  run day-begin-fact-order in this-procedure ( input x-date-start + 1 , output v-fact-order-start ). /*Поиск нач fact-order*/

  define temp-table temp-goods no-undo  /* для списка товаров */
    field gds-code  like goods.gds-code
    field artic     like goods.artic
    field prod-code like goods.prod-code
    field prod-type like goods.prod-type
    field gds-name  like goods.gds-name
    field b-code    as character
    field grp-name  like goods.grp-name
    field sum-posr  as decimal
    field sum-zak   as decimal
    field sum-prod  as decimal
    INDEX pi  IS PRIMARY gds-code
    INDEX pi1            grp-name
    INDEX pi2            artic prod-type prod-code
    INDEX pi3            gds-name
    INDEX pi4            b-code
  .

  define temp-table temp-goods-obj no-undo
    field gds-code  like goods.gds-code
    field obj-type  like clients.obj-type
    field obj-code  like clients.obj-code
    field sum-zak   as decimal
    field sum-prod  as decimal
    INDEX pi  IS PRIMARY gds-code obj-type obj-code
  .

  define buffer buf_goods    for goods.
  define buffer buf_clients  for clients.
  define buffer buf_gds-obj  for gds-obj.
  define buffer buf_doc-line for doc-line.

  define variable Counter1    as integer   no-undo .
  define variable ii          as integer   no-undo .
  define variable CurrGrpName as character no-undo .
  define variable num-obj     as integer initial 0  no-undo .
  define variable num-obj1    as integer initial 0  no-undo .
  define variable num-obj2    as integer initial 0  no-undo .

  define variable v-file-name as character no-undo .
  define variable v-row       as integer   no-undo .
  define variable v-col       as integer   no-undo .
  define variable v-ind       as integer   no-undo initial 1 .

  assign  Counter1 = 0 .

  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 50 } /* Показать окно информации о текущем процессе */

  RUN init-temphost.
  for each temp-obj where temp-obj.host-code <> p-host :  delete temp-obj.  end.
  for each obj-list : assign num-obj = num-obj + 1 .   end.

  if x-SelectGood = {&g-all} then do: /* все товары */
    for each buf_gds-obj where buf_gds-obj.host-code = p-host no-lock :
      { cus/r-z-pos1.i } /* проверка, подходит ли товар и заполнение темп-тейбла */
    end.
  end.
  else do:
    case x-SelectGood :
      when {&g-all} then do:
      end.
      when {&g-prod} then do:    /* не все производители */
        for each G#cli : /* встать на производителя */
          for each buf_gds-obj  no-lock
            where buf_gds-obj.host-code = p-host
              and buf_gds-obj.prod-type = G#cli.obj-type
              and buf_gds-obj.prod-code = G#cli.obj-code
            :
            { cus/r-z-pos1.i } /* проверка, подходит ли товар и заполнение темп-тейбла */
          end .
        end.                /* do ... по производителям */
      end .
      when {&g-grp} then do:    /* не все группы товаров */
        for each tmp#grp :
          run grplib-get-full-name( input tmp#grp.node-code, output CurrGrpName ) .
          for each buf_gds-obj no-lock
            where buf_gds-obj.host-code = p-host and buf_gds-obj.grp-name begins CurrGrpName  :
            { cus/r-z-pos1.i } /* проверка, подходит ли товар и заполнение темп-тейбла */
          end .
        end.    /* do i = 1 to num-entries ( gdsgrp_recids ) : */
      end.
      otherwise do:
        for each gds-list ,
          each buf_gds-obj no-lock
          where buf_gds-obj.host-code = p-host
            and buf_gds-obj.artic     = gds-list.artic
            and buf_gds-obj.prod-type = gds-list.prod-type
            and buf_gds-obj.prod-code = gds-list.prod-code
          :
          { cus/r-z-pos1.i } /* проверка, подходит ли товар и заполнение темп-тейбла */
        end.
      end.

    end case.
  end.

  /* составили список товаров - теперь ищем цены */
  run CalculPrice in this-procedure .

  /* macr_excel - для экселя */
  assign
    make-excel = yes
    v-file-name = string(session :temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt"
  .
  output stream macr_excel to value(v-file-name) .
  assign v-ind = v-ind + 1 .

  { gbl/working.i }

  run PutColumnTitulExcel in this-procedure .

  if sort-grp then do:
    for each temp-goods break by temp-goods.grp-name by {&Sort-pole} :
      if first-of(temp-goods.grp-name ) then do:
        run macr_excel_char (temp-goods.grp-name, v-row, 3) .
        run macr_cell_format ( 11, yes, no, ?, v-row, 3, v-row, 3) .
        assign v-row = v-row + 1  .
      end.
      run PrintLine in this-procedure .
    end. /* for each temp-goods  */
  end.
  else do:
    for each temp-goods break by {&Sort-pole} :
      run PrintLine in this-procedure .
    end. /* for each temp-goods  */
  end.

  output stream macr_excel close .
  run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name) .
  run end-proc .

  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */
  { gbl/stopwork.i }
  run rep/runexcel.p (v-file-name ).
end.

/* ******************************************************* */

procedure CalculPrice :
  do on error undo, return error return-value :
    define variable tmp-fo  as decimal   no-undo .
    define variable tmp-sum as decimal   no-undo .

    for each temp-goods :
      assign
        tmp-fo   = 0
        tmp-sum  = 0
        Counter1 = Counter1 + 1
      .
      { rep/repfrm.i disp Counter1 }
      /* сначала ищем цену последнего прихода к посреднику */
      for each temp-obj :
        find last buf_doc-line no-lock
          where buf_doc-line.artic      = temp-goods.artic
            and buf_doc-line.prod-type  = temp-goods.prod-type
            and buf_doc-line.prod-code  = temp-goods.prod-code
            and buf_doc-line.obj-type   = temp-obj.obj-type
            and buf_doc-line.obj-code   = temp-obj.obj-code
            and buf_doc-line.status_    = {&fact}
            and buf_doc-line.fact-order < v-fact-order-start
            and (buf_doc-line.ext-doc-type = {&TDEDT_Pri_Vnesh} or buf_doc-line.ext-doc-type = {&TDEDT_Pri_Perem} )
          no-error .
        if available buf_doc-line then do:
          if buf_doc-line.fact-order > tmp-fo then do:
            assign
              tmp-sum = if var-report-r-b = "rubl" then buf_doc-line.price-rubl else buf_doc-line.price-base
              tmp-fo  = buf_doc-line.fact-order
            .
          end.
        end.
      end.
      assign
        temp-goods.sum-posr = tmp-sum
        temp-goods.sum-zak  = 0
        temp-goods.sum-prod = 0
        num-obj1 = 0
        num-obj2 = 0
      .
      /* теперь ищем последние приходы и переоценки на объектах */
      for each obj-list :
        create temp-goods-obj .
        assign
          temp-goods-obj.gds-code = temp-goods.gds-code
          temp-goods-obj.obj-type = obj-list.obj-type
          temp-goods-obj.obj-code = obj-list.obj-code
          temp-goods-obj.sum-zak  = 0
          temp-goods-obj.sum-prod = 0
        .

        find last buf_doc-line no-lock
          where buf_doc-line.artic      = temp-goods.artic
            and buf_doc-line.prod-type  = temp-goods.prod-type
            and buf_doc-line.prod-code  = temp-goods.prod-code
            and buf_doc-line.obj-type   = obj-list.obj-type
            and buf_doc-line.obj-code   = obj-list.obj-code
            and buf_doc-line.status_    = {&fact}
            and buf_doc-line.fact-order < v-fact-order-start
            and (buf_doc-line.ext-doc-type = {&TDEDT_Pri_Vnesh} or buf_doc-line.ext-doc-type = {&TDEDT_Pri_Perem} )
          no-error .
        if available buf_doc-line then do:
          assign
            temp-goods.sum-zak     = temp-goods.sum-zak + (if var-report-r-b = "rubl" then buf_doc-line.price-rubl else buf_doc-line.price-base)
            temp-goods-obj.sum-zak = if var-report-r-b = "rubl" then buf_doc-line.price-rubl else buf_doc-line.price-base
            num-obj1 = num-obj1 + 1
          .
        end.

        find last price-list no-lock
          where price-list.obj-type   = obj-list.obj-type
            and price-list.obj-code   = obj-list.obj-code
            and price-list.b-code     = int(temp-goods.b-code)
            and price-list.fact-order < v-fact-order-start
          use-index fact-close no-error .
        if available price-list then do:
          assign
            temp-goods.sum-prod     = temp-goods.sum-prod + price-list.price-sale
            temp-goods-obj.sum-prod = price-list.price-sale
            num-obj2 = num-obj2 + 1
          .
        end.
      end.
      assign
        temp-goods.sum-zak  = temp-goods.sum-zak  / num-obj1
        temp-goods.sum-prod = temp-goods.sum-prod / num-obj2
      .
    end.
  end.
end procedure. /* CalculPrice */


procedure PutColumnTitulExcel : /* заголовки для колонок экселя */
  do
  on error undo, return error return-value
  :
  assign
    v-row = 4
    v-col = 3
    str1 = "Сравнительный отчет по ценам товара на объектах на " + String(x-date-start,"99/99/9999")
  .

  run macr_excel_char (str1, 1, 3) .
  run macr_cell_format ( 11, yes, no, ?, 1, 3, 1, 3) .
  run macr_excel_char ("Объекты: " + STR-obj , 2, 1) .
  run macr_cell_format ( 11, yes, no, ?, 2, 1, 2, 1) .
  if str2 = ? then assign  str2 = "" .
  run macr_excel_char ( str2 , 3, 1) .
  run macr_cell_format ( 11, yes, no, ?, 3, 1, 3, 1) .

  run macr_excel_char("Код", v-row, 1) .
  run macr_cell_size (14,?, v-row, 1,?,?).
  run macr_excel_char("Артикул", v-row, 2) .
  run macr_cell_size (14,?, v-row, 2,?,?).
  run macr_excel_char("Наименование товара", v-row, 3) .
  run macr_cell_size (40,?, v-row, 3,?,?).
  run macr_excel_char("Производитель", v-row, 4) .
  run macr_cell_size (40,?, v-row, 4,?,?).
  assign v-col = 5 .
  run macr_excel_char("Учет. цена посредника", v-row, v-col) .
  assign v-col = 6 + num-obj .
  run macr_excel_char("Сред. учет. цена", v-row, v-col) .
  assign v-col = 7 + num-obj * 2 .
  run macr_excel_char("Сред. продаж. цена", v-row, v-col) .
  assign v-col = 8 + num-obj * 2 .
  run macr_excel_char("Эффективность", v-row, v-col) .
  assign v-col = 9 + num-obj * 2 .
  run macr_excel_char("Наценка", v-row, v-col) .
  assign v-col = 6 .

  for each obj-list :
    find first buf_clients no-lock
      where buf_clients.obj-type = obj-list.obj-type
        and buf_clients.obj-code = obj-list.obj-code
    .
    run macr_excel_char( "Учет. цена на " + buf_clients.obj-name,   v-row, v-col ) .
    run macr_excel_char( "Продаж. цена на " + buf_clients.obj-name,   v-row, v-col + num-obj + 1 ) .
    assign v-col = v-col + 1 .
  end.

  run macr_cell_bordur ( v-row, 1, v-row , 9 + num-obj * 2) .
  run macr_cell_format ( 10, yes, no, 35, v-row, 1, v-row , 9 + num-obj * 2) .
  assign  v-row = 5 .
  end.
end procedure. /* PutColumnTitulExcel */


procedure PrintLine :
  do on error undo, return error return-value :
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

    assign  v-col = 6  .
    run macr_excel_char(temp-goods.b-code,   v-row, 1) .
    run macr_excel_char(temp-goods.artic,    v-row, 2) .
    run macr_excel_char(temp-goods.gds-name, v-row, 3) .
    find first buf_clients no-lock where buf_clients.obj-type = temp-goods.prod-type and buf_clients.obj-code = temp-goods.prod-code .
    run macr_excel_char(buf_clients.obj-name, v-row, 4) .
    run macr_excel_sum (temp-goods.sum-posr,  v-row, 5, 2) .
    run macr_excel_sum (temp-goods.sum-zak,   v-row, 6 + num-obj, 2) .
    run macr_excel_sum (temp-goods.sum-prod,  v-row, 7 + num-obj * 2, 2) .
    run macr_excel_sum (temp-goods.sum-prod - temp-goods.sum-posr,  v-row, 8 + num-obj * 2, 2) .
    run macr_excel_sum ((temp-goods.sum-prod - temp-goods.sum-zak) * 100 / temp-goods.sum-zak ,  v-row, 9 + num-obj * 2, 2) .
    for each temp-goods-obj where temp-goods-obj.gds-code = temp-goods.gds-code :
      run macr_excel_sum (temp-goods-obj.sum-zak,   v-row, v-col, 2) .
      run macr_excel_sum (temp-goods-obj.sum-prod,  v-row, v-col + num-obj + 1, 2) .
      assign v-col = v-col + 1 .
    end.
    assign v-row = v-row + 1 .
  end.
end procedure. /* PrintLine */





/* *********************************************************************** */

procedure macr_excel_char :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val as character no-undo .
 define input parameter  p-row as integer no-undo .
 define input parameter  p-col as integer no-undo .

      put  stream macr_excel unformatted
        substitute('formula(&3,"r&1c&2")', p-row , p-col , format-excel-text-macr ( p-val) ) skip  .

 end. /* do */
end procedure. /* macr_exel_char */



procedure macr_excel_sum :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val as decimal   no-undo .
 define input parameter  p-row as integer   no-undo .
 define input parameter  p-col as integer   no-undo .
 define input parameter  p-typ as integer   no-undo .

 if p-val = ? then assign p-val = 0 .
 define variable ss as character no-undo .
 assign
   ss = string( Round( p-val, p-typ) )
 .
 put  stream macr_excel unformatted  substitute('formula(&3,"r&1c&2")', p-row , p-col , ss ) skip  .
 end. /* do */
END procedure.

procedure macr_cell_format :
 do
 on error undo, return error return-value
 :
 define input parameter  p-size   as integer   no-undo .
 define input parameter  p-bold   as logical   no-undo .
 define input parameter  p-italic as logical   no-undo .
 define input parameter  p-color  as integer   no-undo .
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .
 define input parameter  p-row-2  as integer   no-undo .
 define input parameter  p-col-2  as integer   no-undo .

  if p-size = ? then p-size = 10 .
  if p-bold = ? then p-bold = false .
  if p-italic = ? then p-italic = false .
  if p-row-2 = ? then p-row-2 = p-row .
  if p-col-2 = ? then p-col-2 = p-col .
  put  stream macr_excel unformatted
   substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 ) skip .

  if p-color <> ? then do:
     put  stream macr_excel unformatted
       substitute('patterns(1,,&1,true)', p-color )  skip  .
  end.
  put  stream macr_excel unformatted
       substitute('format.font(,&1,&2,&3)' , p-size,
                                        string ( p-bold  , "true/false" ) ,
                                        string ( p-italic , "true/false" )
                                        ) skip .
 end. /* do */
end procedure. /* macr_pattern */


procedure macr_cell_bordur :
 do
 on error undo, return error return-value
 :
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .
 define input parameter  p-row-2  as integer   no-undo .
 define input parameter  p-col-2  as integer   no-undo .

  if p-row-2 = ? then p-row-2 = p-row .
  if p-col-2 = ? then p-col-2 = p-col .
  put  stream macr_excel unformatted
   substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 ) skip .

  put  stream macr_excel unformatted
       'BORDER( 2 , 2 , 2 , 2 , 2 , ,0,0,0,0,0) '  skip
       'ALIGNMENT(3 , , 4 , 4 ,)'   skip
       .
 end. /* do */
end procedure. /* macr_cell_bordur */

procedure macr_cell_size :
 do
 on error undo, return error return-value
 :
 define input parameter  p-w   as integer   no-undo . /* ширина*/
 define input parameter  p-l   as integer   no-undo . /* длина */
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .
 define input parameter  p-row-2  as integer   no-undo .
 define input parameter  p-col-2  as integer   no-undo .

  if p-row-2 = ? then p-row-2 = p-row .
  if p-col-2 = ? then p-col-2 = p-col .
  if p-w = ? then    p-w = 0 .
  if p-l = ? then    p-l = 0 .

 define variable s-w as character no-undo .
 define variable s-l as character no-undo .

 if p-w = 0 then s-w = "" .
            else s-w = string(p-w)  .
 if p-l = 0 then s-l = "" .
            else s-l = string(p-l)  .

put  stream macr_excel unformatted
     substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 )  skip .
put  stream macr_excel unformatted
     substitute('COLUMN.WIDTH(&1,,,,)' , s-w  )  skip.
put  stream macr_excel unformatted
     'FORMAT.TEXT(2,2,0,,,,,)'  skip.

 end. /* do */

end procedure. /* macr_pattern */

procedure end-proc :
 do
 on error undo, return error return-value
 :

  v-file-name = ( string( session:temp-directory + {&DF_Name} + string( g#report-num ) ) + ".t-t").

  OUTPUT to VALUE (v-file-name) .
  for each temp-param :
    export  temp-param  .
  end.

 end. /* do */
end procedure. /* end-proc */