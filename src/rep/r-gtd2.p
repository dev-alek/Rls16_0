block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-gtd2.p $
$Archive: rep/r-gtd2.p $

Отчет о товарах в магазине беспошлинной торговли

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/27/06
Author: Michael Kochetkov
Creation date: 03/27/06

*/

define input parameter null-oborot  as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-gtd2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-gtd2.p $":U .
define variable vss-description as character no-undo init "Отчет о товарах в магазине беспошлинной торговли".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/r-sym.i    }
{ cmp/r-pril.i   }
{ rep/r-cost.i   }
{ rep/r-sale.i   }
{ rep/f-fdec.i   }   /* Функции для форматирования полей для передачи в EXcel         */
{ gbl/paramls.i  }
{ trg/factord.i  }
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


  define variable  v-file-name as character no-undo .

  define Stream macr_excel.

  define var    v-fact-order-start     as decimal   no-undo .
  define var    v-fact-order-end       as decimal   no-undo .
  run day-begin-fact-order in this-procedure ( input x-date-start, output v-fact-order-start ). /*Поиск нач fact-order*/
  run day-begin-fact-order in this-procedure ( input ( x-date-end + 1 ),   output v-fact-order-end ). /*Поиск посл fact-order*/


  define temp-table temp-goods no-undo  /* для списка партий */
    field artic     like goods.artic
    field prod-code like goods.prod-code
    field prod-type like goods.prod-type
    field gds-name  like goods.gds-name
    field grp-name  like goods.grp-name
    field cli-code  like trn-doc.cli-code
    field cli-type  like trn-doc.cli-type
    field nat       like goods.nationality
    field part-code like parts.part-code
    field in-code   like parts.in-code
    field gtd-code  like parts.cst-code
    field p-ost         as decimal
    field p-prih        as decimal
    field p-sum1        as decimal
    field p-sum2        as decimal
    field p-prod        as decimal
    field p-vozv        as decimal
    field p-ost-sum     as decimal
    field p-prih-sum    as decimal
    field p-sum1-sum    as decimal
    field p-sum2-sum    as decimal
    field p-prod-sum    as decimal
    field p-vozv-sum    as decimal
    INDEX pi  IS PRIMARY artic  prod-type  prod-code  in-code part-code
    INDEX pi1   grp-name
    INDEX pi2   gtd-code
  .

  define buffer buf_goods      for goods.
  define buffer buf_clients    for clients.
  define buffer buf_trn-doc    for  trn-doc .
  define buffer buf_doc-line   for doc-line.
  define buffer buf_parts      for parts.
  define buffer buf_gds-obj    for gds-obj .

  define variable  Counter1    as integer initial 0  no-undo .
  define variable  ii          as integer   no-undo .
  define variable  CurrGrpName as character no-undo .
  define variable  Line        as character no-undo .
  define variable  v-row       as integer   no-undo .
  define variable  v-col       as integer   no-undo .
  define variable  v-ind       as integer   no-undo initial 1 .
  define variable  str         as character no-undo .
  define variable  is-new      as logical   no-undo .
  define variable  new-grp     as logical   no-undo .

  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 50 } /* Показать окно информации о текущем процессе */

  if x-SelectGood = {&g-all} then do: /* все товары */
    for each obj-list ,
      each  buf_gds-obj no-lock
      where buf_gds-obj.obj-type  = obj-list.obj-type
        and buf_gds-obj.obj-code  = obj-list.obj-code
      :
      { rep/r-gtd2-1.i }
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
            { rep/r-gtd2-1.i }
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
              { rep/r-gtd2-1.i }
            end .
          end.                /* do ... по производителям */
        end .
        when {&g-grp} then do:    /* не все группы товаров */
          for each tmp#grp :
            run grplib-get-full-name in this-procedure (
                                                       input tmp#grp.node-code
                                                     , output CurrGrpName).
            for each buf_gds-obj no-lock
              where buf_gds-obj.obj-type = obj-list.obj-type
                and buf_gds-obj.obj-code = obj-list.obj-code
                and buf_gds-obj.grp-name begins CurrGrpName
              use-index obj-grp :
              { rep/r-gtd2-1.i }
            end .
          end.    /* do i = 1 to num-entries ( gdsgrp_recids ) : */
        end.
      end case.
    end.                    /* for each ... по объектам */
  end.

  /* macr_excel - для экселя */
  assign
    new-grp = no
    make-excel = yes
  .
  run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
  output stream macr_excel to value(v-file-name) .
  assign v-ind = v-ind + 1 .

  { gbl/working.i }

  run PutColumnTitulExcel in this-procedure .

  assign ii = 1 .
  for each temp-goods break by temp-goods.grp-name by temp-goods.artic  by temp-goods.gtd-code by temp-goods.prod-type by temp-goods.prod-code :
    run end-page in this-procedure .
    if first-of(temp-goods.grp-name ) then  assign new-grp = yes .
    run  PrintString in this-procedure .
  end.

  output stream macr_excel close .
  run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name) .
  run end-proc .

  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */
  { gbl/stopwork.i }

  run rep/runexcel.p (v-file-name ).

end.


procedure PrintString :
  do
  on error undo, return error return-value
  :
    define variable ost-end     as decimal initial 0  no-undo .
    define variable ost-end-sum as decimal initial 0  no-undo .
    define variable zena        as decimal initial 0  no-undo .

    if    temp-goods.p-prih = 0 and temp-goods.p-sum1 = 0 and temp-goods.p-sum2 = 0
      and temp-goods.p-vozv = 0 and temp-goods.p-prod = 0 then do:
       if null-oborot = no then next .
       else if temp-goods.p-ost = 0 then next .
    end.

    if new-grp = yes then do:
      run macr_excel_char( temp-goods.grp-name,  v-row, 6) .
      run macr_cell_format ( 10, yes, no, ?, v-row , 6, v-row, 6) .
      assign
        v-row = v-row + 1
        new-grp = no
      .
    end.

    assign
      temp-goods.p-sum2 = temp-goods.p-sum2     + temp-goods.p-ost      + temp-goods.p-prih - temp-goods.p-sum1
      temp-goods.p-sum2-sum = temp-goods.p-sum2-sum + temp-goods.p-ost-sum + temp-goods.p-prih-sum - temp-goods.p-sum1-sum
      ost-end           = temp-goods.p-sum2     + temp-goods.p-vozv     - temp-goods.p-prod
      ost-end-sum       = temp-goods.p-sum2-sum + temp-goods.p-vozv-sum - temp-goods.p-prod-sum
    .

    run macr_excel_char(String(ii), v-row, 1) .
    run macr_excel_char(temp-goods.gtd-code, v-row, 2) .

    /* ищем приходную накладную */
    find first buf_trn-doc where buf_trn-doc.doc-code = temp-goods.in-code no-error .
    if available buf_trn-doc then do:
      run macr_excel_char(buf_trn-doc.cli-type,    v-row, 3) .
      run macr_excel_char(buf_trn-doc.cli-code,    v-row, 4) .
      run macr_excel_char(buf_trn-doc.cli-name,    v-row, 5) .
    end.
    run macr_excel_char(temp-goods.artic,      v-row, 6) .
    run macr_excel_char(temp-goods.prod-type,  v-row, 7) .
    run macr_excel_char(temp-goods.prod-code,  v-row, 8) .
    run macr_excel_char(temp-goods.gds-name,   v-row, 9) .

    run macr_excel_sum (temp-goods.p-ost,      v-row, 10, 3) .
    if temp-goods.p-ost = 0 then assign zena =  0 .
    else                         assign zena =  temp-goods.p-ost-sum / temp-goods.p-ost .
    run macr_excel_sum (zena,   v-row, 11, 2) .
    run macr_excel_sum (temp-goods.p-ost-sum,  v-row, 12, 2) .

    run macr_excel_sum (temp-goods.p-prih,      v-row, 13, 3) .
    if temp-goods.p-prih = 0 then assign zena =  0 .
    else                          assign zena =  temp-goods.p-prih-sum / temp-goods.p-prih .
    run macr_excel_sum (zena,   v-row, 14, 2) .
    run macr_excel_sum (temp-goods.p-prih-sum,  v-row, 15, 2) .

    run macr_excel_sum (temp-goods.p-sum1,      v-row, 16, 3) .
    if temp-goods.p-sum1 = 0 then assign zena =  0 .
    else                          assign zena =  temp-goods.p-sum1-sum / temp-goods.p-sum1 .
    run macr_excel_sum (zena,   v-row, 17, 2) .
    run macr_excel_sum (temp-goods.p-sum1-sum,  v-row, 18, 2) .

    run macr_excel_sum (temp-goods.p-sum2,      v-row, 19, 3) .
    if temp-goods.p-sum2 = 0 then assign zena =  0 .
    else                          assign zena =  temp-goods.p-sum2-sum / temp-goods.p-sum2 .
    run macr_excel_sum (zena,   v-row, 20, 2) .
    run macr_excel_sum (temp-goods.p-sum2-sum,  v-row, 21, 2) .

    run macr_excel_sum (temp-goods.p-vozv,      v-row, 22, 3) .
    if temp-goods.p-vozv = 0 then assign zena =  0 .
    else                         assign zena =  temp-goods.p-vozv-sum / temp-goods.p-vozv .
    run macr_excel_sum (zena,   v-row, 23, 2) .
    run macr_excel_sum (temp-goods.p-vozv-sum,  v-row, 24, 2) .

    run macr_excel_sum (temp-goods.p-prod,      v-row, 25, 3) .
    if temp-goods.p-prod = 0 then assign zena =  0 .
    else                         assign zena =  temp-goods.p-prod-sum / temp-goods.p-prod .
    run macr_excel_sum (zena,   v-row, 26, 2) .
    run macr_excel_sum (temp-goods.p-prod-sum,  v-row, 27, 2) .

    run macr_excel_sum (ost-end,      v-row, 28, 3) .
    if ost-end = 0 then assign zena =  0 .
    else                assign zena =  ost-end-sum / ost-end .
    run macr_excel_sum (zena,   v-row, 29, 2) .
    run macr_excel_sum (ost-end-sum,  v-row, 30, 2) .

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
    v-row = 2
    v-col = 1
  .
  run macr_excel_char ("Отчет по товарам, принятым на реализацию и реализованных за период с " + String(x-Date-Start,"99.99.9999") + " по " + String(x-Date-End,"99.99.9999") , 1, 3) .
  run macr_cell_format( 11, yes, no, ?, 1, 3, 1, 3) .

  run macr_excel_char("№ п/п", v-row, v-col) .         assign v-col = v-col + 1 .
  run macr_excel_char("№ ГТД", v-row, v-col) .         run macr_cell_size (20,?, v-row, v-col,?,?).   assign v-col = v-col + 1 .
  run macr_excel_char("тип", v-row + 1, v-col) .       assign v-col = v-col + 1 .
  run macr_excel_char("Поставщик", v-row, v-col) .
  run macr_excel_char("код", v-row + 1, v-col) .       assign v-col = v-col + 1 .
  run macr_excel_char("наименование", v-row + 1, v-col) .    assign v-col = v-col + 1 .
  run macr_excel_char("Артикул", v-row, v-col) .       run macr_cell_size (20,?, v-row, v-col,?,?).   assign v-col = v-col + 1 .
  run macr_excel_char("Производитель", v-row, v-col) .
  run macr_excel_char("тип", v-row + 1, v-col) .       assign v-col = v-col + 1 .
  run macr_excel_char("код", v-row + 1, v-col) .       assign v-col = v-col + 1 .
  run macr_excel_char("Наименование товара", v-row, v-col) .
  run macr_cell_size (40,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .

  run macr_excel_char("кол-во", v-row + 1, v-col) .       assign v-col = v-col + 1 .
  run macr_excel_char("Начальный остаток", v-row, v-col) .
  run macr_excel_char("цена",   v-row + 1, v-col) .       assign v-col = v-col + 1 .
  run macr_excel_char("сумма",  v-row + 1, v-col) .       assign v-col = v-col + 1 .

  run macr_excel_char("кол-во", v-row + 1, v-col) .       assign v-col = v-col + 1 .
  run macr_excel_char("Приход", v-row, v-col) .
  run macr_excel_char("цена",   v-row + 1, v-col) .       assign v-col = v-col + 1 .
  run macr_excel_char("сумма",  v-row + 1, v-col) .       assign v-col = v-col + 1 .

  run macr_excel_char("кол-во", v-row + 1, v-col) .       assign v-col = v-col + 1 .
  run macr_excel_char("Снято с учета", v-row, v-col) .
  run macr_excel_char("цена",   v-row + 1, v-col) .       assign v-col = v-col + 1 .
  run macr_excel_char("сумма",  v-row + 1, v-col) .       assign v-col = v-col + 1 .

  run macr_excel_char("кол-во", v-row + 1, v-col) .       assign v-col = v-col + 1 .
  run macr_excel_char("Принято на учет", v-row, v-col) .
  run macr_excel_char("цена",   v-row + 1, v-col) .       assign v-col = v-col + 1 .
  run macr_excel_char("сумма",  v-row + 1, v-col) .       assign v-col = v-col + 1 .

  run macr_excel_char("кол-во", v-row + 1, v-col) .       assign v-col = v-col + 1 .
  run macr_excel_char("Возврат", v-row, v-col) .
  run macr_excel_char("цена",   v-row + 1, v-col) .       assign v-col = v-col + 1 .
  run macr_excel_char("сумма",  v-row + 1, v-col) .       assign v-col = v-col + 1 .

  run macr_excel_char("кол-во", v-row + 1, v-col) .       assign v-col = v-col + 1 .
  run macr_excel_char("Реализовано", v-row, v-col) .
  run macr_excel_char("цена",   v-row + 1, v-col) .       assign v-col = v-col + 1 .
  run macr_excel_char("сумма",  v-row + 1, v-col) .       assign v-col = v-col + 1 .

  run macr_excel_char("кол-во", v-row + 1, v-col) .       assign v-col = v-col + 1 .
  run macr_excel_char("Остаток на конец периода", v-row, v-col) .
  run macr_excel_char("цена",   v-row + 1, v-col) .       assign v-col = v-col + 1 .
  run macr_excel_char("сумма",  v-row + 1, v-col) .       assign v-col = v-col + 1 .

  run macr_cell_bordur ( v-row , 1, v-row + 1, 30) .
  run macr_cell_format ( 10, yes, no, 35, v-row , 1, v-row + 1, 30) .
  assign
    v-row = v-row + 2
    v-col = 1
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
      assign  v-ind = v-ind + 1   .
      run PutColumnTitulExcel in this-procedure .
    end.
  end.

end procedure. /* end-page */



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
 assign ss = string( Round( p-val, p-typ) ) .
 put  stream macr_excel unformatted   substitute('formula(&3,"r&1c&2")', p-row , p-col , ss ) skip  .
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
    put  stream macr_excel unformatted  substitute('patterns(1,,&1,true)', p-color )  skip  .
  end.
  put  stream macr_excel unformatted
       substitute('format.font(,&1,&2,&3)' , p-size, string ( p-bold  , "true/false" ) ,  string ( p-italic , "true/false" ) ) skip .
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
  put  stream macr_excel unformatted substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 ) skip .
  put  stream macr_excel unformatted 'BORDER( 2 , 2 , 2 , 2 , 2 , ,0,0,0,0,0) '  skip 'ALIGNMENT(3 , , 4 , 4 ,)'   skip
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

put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 )  skip .
put  stream macr_excel unformatted  substitute('COLUMN.WIDTH(&1,,,,)' , s-w  )  skip.
put  stream macr_excel unformatted  'FORMAT.TEXT(2,2,0,,,,,)'  skip.

 end. /* do */
end procedure. /* macr_pattern */



procedure end-proc :
 do
 on error undo, return error return-value
 :
  v-file-name = ( string( session:temp-directory + {&DF_Name} + string( g#report-num ) ) + ".t-t").
  OUTPUT to VALUE (v-file-name) .
  for each temp-param :  export  temp-param  .  end.
 end. /* do */
end procedure. /* end-proc */