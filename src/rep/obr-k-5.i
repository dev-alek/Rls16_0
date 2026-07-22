/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

для детал. оборотки

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/22/06
Author: Michael Kochetkov
Creation date: 03/22/06

*/

procedure CheckNullOborot :
  do
  on error undo, return error return-value
  :
  if line-counter( Outstream ) + 5 > page-size( Outstream ) then do:
    put stream outstream  skip Line format frmt skip "продолжение - на следующей странице" AT 30 SKIP .
    page stream OutStream .
    run PutColumnTitul in this-procedure .
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
  assign
    NullStr = 0
  .
  define variable null-ost as integer initial 0 no-undo .
  if ShowZero = no then do: /* только ненулевые остатки */
    if use-column[12] = yes or use-column[13] = yes or use-column[31] = yes or use-column[32] = yes or use-column[50] = yes or use-column[51] = yes then do:
      if ( gds-prop.StartWay-Qnty = 0    or gds-prop.StartWay-Qnty = ? )    and
         ( gds-prop.StartWay-CostSum = 0 or gds-prop.StartWay-CostSum = ? ) and
         ( gds-prop.StartWay-SaleSum = 0 or gds-prop.StartWay-SaleSum = ? ) and
         ( gds-prop.EndWay-Qnty = 0    or gds-prop.EndWay-Qnty = ? )        and
         ( gds-prop.EndWay-CostSum = 0 or gds-prop.EndWay-CostSum = ? )     and
         ( gds-prop.EndWay-SaleSum = 0 or gds-prop.EndWay-SaleSum = ? )
/*      then RETURN no .*/
       then assign null-ost = 1 .
    end.
  end.
/*  if ShowZero-2 = no then do: /* только ненулевые обороты */*/
    if (( gds-prop.EndWay-Qnty - gds-prop.StartWay-Qnty ) = 0 )    and
       ( gds-prop.InExt-Qnty           = 0 or gds-prop.InExt-Qnty = ? )    and
       ( gds-prop.InExt-CostSum        = 0 or gds-prop.InExt-CostSum = ? ) and
       ( gds-prop.RetPost-Qnty         = 0 or gds-prop.RetPost-Qnty = ? ) and
       ( gds-prop.RetPost-CostSum      = 0 or gds-prop.RetPost-CostSum = ? )      and
       ( gds-prop.OutExt-Qnty          = 0 or gds-prop.OutExt-Qnty = ? )   and
       ( gds-prop.OutExt-CostSum       = 0 or gds-prop.OutExt-CostSum = ? ) and
       ( gds-prop.OutExt-SaleSum       = 0 or gds-prop.OutExt-SaleSum = ? ) and
       ( gds-prop.OutExt-DiscntSum     = 0 or gds-prop.OutExt-DiscntSum = ? )      and
       ( gds-prop.RetOut-Qnty          = 0 or gds-prop.RetOut-Qnty = ? )   and
       ( gds-prop.RetOut-CostSum       = 0 or gds-prop.RetOut-CostSum = ? ) and
       ( gds-prop.RetOut-SaleSum       = 0 or gds-prop.RetOut-SaleSum = ? ) and
       ( gds-prop.RetOut-DiscntSum     = 0 or gds-prop.RetOut-DiscntSum = ? )      and
       ( gds-prop.OutExtKass-Qnty      = 0 or gds-prop.OutExtKass-Qnty = ? )   and
       ( gds-prop.OutExtKass-CostSum   = 0 or gds-prop.OutExtKass-CostSum = ? ) and
       ( gds-prop.OutExtKass-SaleSum   = 0 or gds-prop.OutExtKass-SaleSum = ? ) and
       ( gds-prop.OutExtKass-DiscntSum = 0 or gds-prop.OutExtKass-DiscntSum = ? )      and
       ( gds-prop.RetOutKass-Qnty      = 0 or gds-prop.RetOutKass-Qnty = ? )   and
       ( gds-prop.RetOutKass-CostSum   = 0 or gds-prop.RetOutKass-CostSum = ? ) and
       ( gds-prop.RetOutKass-SaleSum   = 0 or gds-prop.RetOutKass-SaleSum = ? ) and
       ( gds-prop.RetOutKass-DiscntSum = 0 or gds-prop.RetOutKass-DiscntSum = ? )      and
       ( gds-prop.Inv-Qnty             = 0 or gds-prop.Inv-Qnty = ? )   and
       ( gds-prop.Inv-CostSum          = 0 or gds-prop.Inv-CostSum = ? ) and
       ( gds-prop.Inv-SaleSum          = 0 or gds-prop.Inv-SaleSum = ? ) and
       ( gds-prop.Spi-Qnty             = 0 or gds-prop.Spi-Qnty = ? )      and
       ( gds-prop.Spi-CostSum          = 0 or gds-prop.Spi-CostSum = ? )   and
       ( gds-prop.Spi-SaleSum          = 0 or gds-prop.Spi-SaleSum = ? ) and
       ( gds-prop.InInt-Qnty           = 0 or gds-prop.InInt-Qnty = ? )      and
       ( gds-prop.InInt-CostSum        = 0 or gds-prop.InInt-CostSum = ? )   and
       ( gds-prop.InInt-SaleSum        = 0 or gds-prop.InInt-SaleSum = ? ) and
       ( gds-prop.OutInt-Qnty          = 0 or gds-prop.OutInt-Qnty = ? )      and
       ( gds-prop.OutInt-CostSum       = 0 or gds-prop.OutInt-CostSum = ? )   and
       ( gds-prop.OutInt-SaleSum       = 0 or gds-prop.OutInt-SaleSum = ? ) and
       ( gds-prop.RetInt-Qnty          = 0 or gds-prop.RetInt-Qnty = ? )      and
       ( gds-prop.RetInt-CostSum       = 0 or gds-prop.RetInt-CostSum = ? )   and
       ( gds-prop.RetInt-SaleSum       = 0 or gds-prop.RetInt-SaleSum = ? ) and
       ( gds-prop.InProiz-Qnty         = 0 or gds-prop.InProiz-Qnty = ? )      and
       ( gds-prop.InProiz-CostSum      = 0 or gds-prop.InProiz-CostSum = ? )   and
       ( gds-prop.InProiz-SaleSum      = 0 or gds-prop.InProiz-SaleSum = ? ) and
       ( gds-prop.OutProiz-Qnty        = 0 or gds-prop.OutProiz-Qnty = ? )      and
       ( gds-prop.OutProiz-CostSum     = 0 or gds-prop.OutProiz-CostSum = ? )   and
       ( gds-prop.OutProiz-SaleSum     = 0 or gds-prop.OutProiz-SaleSum = ? )
      then do:
        if null-ost = 0 then do:
          if ShowZero-2 = no then NullStr = 1 . /* остатки не 0, а оборот 0, суммируем, но не показываем если "ненулевый остатки" */
        end.
        else do:
          NullStr = 2 . /* все 0  */
        end.
      end.
    end.
/*  end.*/

end procedure. /* CheckNullOborot */



PROCEDURE PutColumnTitul :
/* -----------------------------------------------------------
  Purpose:     Печать заголовка
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  put stream outstream  skip
    string( "Дата печати :" ) AT 5 format "x(15)" TODAY format "99.99.9999"
    string( " , " ) format "X(3)" string(TIME, "HH:MM")
    string( "Страница" ) AT 45 PAGE-NUMBER( outstream ) AT 55 FORMAT ">>>>9" SKIP
   Line format frmt skip .
  for each line-frm :
    put stream outstream  "|" at line-frm.beg  line-frm.titul format line-frm.frmt .
  end.
  put stream outstream    "|" skip .
  for each line-frm :
    put stream outstream  "|" at line-frm.beg  line-frm.titul1 format line-frm.frmt .
  end.
  put stream outstream    "|" skip .
  for each line-frm :
    put stream outstream  "|" at line-frm.beg  line-frm.titul2 format line-frm.frmt .
  end.
  put stream outstream    "|"  skip  Line format frmt skip .
/*  assign*/
/*    ObS = ObS + 1*/
/*  .*/

END PROCEDURE.


procedure PutItogSum :
  define input  parameter p-num as integer   no-undo .
  define buffer buf_gds-sum for gds-sum .

  if p-num = 2 then do:
     if available obj-list then assign ItogStr = "Итого по объекту " + obj-list.obj-name + " (" + obj-list.obj-type + '#' + string(obj-list.obj-code) + ") :" .
     else assign ItogStr = "" .
  end.
  else if p-num = 1 then assign  ItogStr = "ИТОГО: " .

  find first buf_gds-sum where buf_gds-sum.num = p-num no-error .
  { rep/obr-k-8.i } /* вывод сумм */
end procedure. /* PutItogSum */


procedure CalculSum :
  define input  parameter p-num as integer   no-undo .
  define buffer buf_gds-sum for gds-sum .

  find first buf_gds-sum where buf_gds-sum.num = p-num no-error .
  { rep/obr-k-9.i } /* расчет сумм */
end procedure. /* CalculSum */


procedure Create-gds-sum :
  define input  parameter p-num as integer   no-undo .
  define buffer buf_gds-sum for gds-sum .

  find first buf_gds-sum where buf_gds-sum.num = p-num no-error .
  if not available buf_gds-sum then do:
    create buf_gds-sum .
    assign
      buf_gds-sum.num = p-num
    .
  end.
  { rep/obr-k-7.i } /* обнуление сумм */
end procedure. /* Create-gds-sum */


procedure PrintLine :
  if SumsOnly = no then do:
    { rep/obr-k-6.i } /* вывод строки */
    if sys-key = "parts" then do:
       run PrintParts ( gds-prop.artic, gds-prop.prod-type, gds-prop.prod-code , gds-prop.obj-type, gds-prop.obj-code )  .
    end.
  end.
end procedure. /* PrintLine */


procedure PutTitul :
  if titul = 0 and tog-obj = true then do:   /* заголовок объекта */
    assign
      line1 = ""
      titul = 1
    .
    if available obj-list then assign  line1 = "По объекту: " + obj-list.obj-name + " (" + obj-list.obj-type + '#' + string(obj-list.obj-code) + ")" .
    run macr_excel_char (line1, v-row, 1) .
    assign v-row = v-row + 1 .
    put stream outstream   Line format frmt skip .
    PUT stream OutStream "| " line1 format "X(60)" "|" at beg  SKIP .
  end.
  if SumsOnly = no then do:
    if var-client <> "" then do:
      run macr_excel_char (var-client, v-row, 1) .
      assign v-row = v-row + 1 .
      PUT stream OutStream "| " var-client format "X(60)" "|" at beg  SKIP .
      assign  var-client = "" .
    end.
    if var-client1 <> "" then do:
      run macr_excel_char (var-client1, v-row, 1) .
      assign v-row = v-row + 1 .
      PUT stream OutStream "| " var-client1 format "X(60)" "|" at beg  SKIP .
      assign  var-client1 = "" .
    end.
  end.
end procedure. /* PutItogSum */


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

 put  stream macr_excel unformatted
      substitute('formula(&3,"r&1c&2")', p-row , p-col , format-excel-text-macr ( ss ) ) skip  .
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

/* $Workfile$   E n d */