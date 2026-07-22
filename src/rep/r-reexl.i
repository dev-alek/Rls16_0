/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Печать остатков и оборотов (тип остаткаили оборота 1 2 пусто) в excel

Автор: Чернова Светлана Александровна
Дата создания: 01/12/07
Author: Svetlana Chernova
Creation date: 01/12/07

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
CASE "{1}" :
WHEN  "1" then
    TEMPSTR =  string( "Остаток на начало периода (" + string( startdate, "99/99/9999" ) + ")" )   .
WHEN "2" then
    TEMPSTR = string( "Остаток на конец периода (" + string( enddate, "99/99/9999" ) + ")" )  .
OTHERWISE
    TEMPSTR =string( "Оборот с " + string( startdate, "99/99/9999" ) + " по " + string( enddate, "99/99/9999" ) )  .
end CASE.


run new-tmp-page .
num#str# = num#str# + 1.
num#col# = 1.
run macr_excel_char( TEMPSTR , num#str# , num#col#   ) .
run macr_cell_format
  ( 12    ,     /* p-size  */
    true  ,     /*p-bold   */
    false ,     /*p-italic */
    ?     ,     /*p-color  */
    num#str# ,  /*p-row    */
    num#col# ,  /*p-col    */
    ? ,         /*p-row-2  */
    ?           /*p-col-2  */
      ) .
num#str# = num#str# + 1.
num#col# = 2.
run macr_excel_char( "Количество: " + trim( string( Quantity{1}, "->>>,>>>,>>9.<<<" ) ) , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
num#str# = num#str# + 1.

IF PayType = 2 OR PayType = 0  then do:
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_reports_lookup-cost':U
  {&cntxt-object}
  v-cntxt-host-code-obj
  v-cntxt-obj-type
  v-cntxt-obj-code
  0
  0
  0
  false
  g#log
}
    if  g#log = true  then do:
        num#col# = 2.
        run macr_excel_char(  "Cумма   УЧЕТНЫХ  цен: " +  trim( string( Coast{1}, "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
                              curr-rep , num#str# , num#col#   ) .
        num#str# = num#str# + 1.
        run macr_excel_char(  "Cумма   УЧЕТНЫХ  цен без НДС: " +  trim( string( (Coast{1} - Coast-vat{1} ), "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
                              curr-rep , num#str# , num#col#   ) .
        num#str# = num#str# + 1.

    end.
  end.
  Else   do:
        num#col# = 2.
        run macr_excel_char( "Cумма   ПРОДАЖНЫХ  цен: " +
                              trim( string( Coast{1}, "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
                              curr-rep , num#str# , num#col#   ) .
        num#str# = num#str# + 1.
  end.

  &if "{1}" = "vat" or "{2}" = "vat"  &then
  IF PayType = 2 OR PayType = 0  then do :
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_reports_lookup-cost':U
          {&cntxt-object}
          v-cntxt-host-code-obj
          v-cntxt-obj-type
          v-cntxt-obj-code
          0
          0
          0
          false
          g#log
        }
    if  g#log = true  then do:
        num#col# = 2.
        run macr_excel_char( string( "НДС в  УЧЕТНЫХ ценах: " + trim( string( Coast-vat{1}, "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
                              curr-rep ) , num#str# , num#col#   ) .
        num#str# = num#str# + 1.
    end.
    end.
    ELSE  do:
        num#col# = 2.
        run macr_excel_char ( string( "НДС в ПРОДАЖНЫХ ценах: " +
                              trim( string( Coast-vat{1}, "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +  curr-rep
                              ) , num#str# , num#col#   ) .
        num#str# = num#str# + 1.
    end.
    &endif
/* $Workfile$ e n d */