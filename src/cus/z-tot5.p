block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: z-tot5.p $
$Archive: cus/z-tot5.p $

Вывод расчета заказа в EXCEL

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 07/02/03 4:47


*/


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: z-tot5.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/z-tot5.p $":U .
define variable vss-description as character no-undo init " Вывод расчета заказа в EXCEL ".
{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/r-page1.i new  }
{ cmp/r-pril.i  NEW  }
{ gbl/cur-time.i     }
{ rep/repfrm.i def   }
{ rep/f-fdec.i       }
{ gbl/paramls.i      }
{ cus/df-zakaz.i     }
{ cus/df-ex-za.i     }
{ gbl/dtm.i          }
{ gbl/getcntxt.i def }
{ str/getctxtp.i def }
{ gbl/thbjattr.i     }

define input parameter parParentProc  as widget-handle no-undo .
define input parameter TABLE FOR export-ras .
define input parameter p-ord-doc as character no-undo .
define input parameter p-e-method as character no-undo .
define input parameter p-prt-all as logical   no-undo . /* если ДА - Артикул печатать по всем объектам */


{ gbl/getcntxt.i get }
{ str/getctxtp.i get }

define variable base-type as character no-undo .
define variable base-code as integer   no-undo .
define variable g#report-num as integer   no-undo .
define variable g#gds-engl as logical   no-undo .
define variable g#log as logical   no-undo .
define variable par-ord-min-ost as logical   no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable p-type as character no-undo .
define variable v-param-value as character no-undo .

for each thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.

par-ord-min-ost = false .

define variable v-cntxt-host-name-obj as character no-undo .

define buffer buf_rep_currency for ub.currency.
{ gbl/hostname.i v-cntxt-obj-type v-cntxt-obj-code v-cntxt-host-code-obj v-cntxt-host-name-obj }
{ gbl/basecode.i v-cntxt-host-code-obj base-code }


find first buf_rep_currency no-lock
  where buf_rep_currency.curr-code = base-code
  no-error .
  if available buf_rep_currency then base-type = buf_rep_currency.curr-abbr .
               else base-type = "б.в." .

run get-report-num in parParentProc ( output g#report-num ).

define buffer buf_ord-doc  for ub.ord-doc.
define buffer buf_ord-line for ub.ord-line.
define buffer buf_cli-gds  for ub.cli-gds.

define variable max-col as integer no-undo .
max-col = 32.
define variable v-today as date      no-undo .
define variable v-time  as integer   no-undo .
define variable kol-obj as integer no-undo .

define stream  instream  .
define stream  outstream  .
define stream  outstream2  .

make-excel-com = false .
make-excel     = true  .

define stream  macr_excel .

define variable v-file-name as character no-undo .
define variable p-file-name as character no-undo .
define variable v-ind       as integer   no-undo .
define variable C-c    as integer no-undo .
define variable C-str  as character no-undo .
define variable str--1 as character Format "x(60)" no-undo.
define variable str--2 as integer no-undo .
define variable C-i    as integer no-undo .
define variable p-var  as integer no-undo .
define variable num#col# as integer no-undo .
define variable var-1 as integer no-undo .
define variable var-2 as integer no-undo .
define variable var-3 as integer no-undo .

define variable  p-obj-type like ub.ord-doc.obj-type no-undo .
define variable  p-obj-code like ub.ord-doc.obj-code no-undo .
define variable  p-cli-type like ub.ord-doc.cli-type no-undo .
define variable  p-cli-code like ub.ord-doc.cli-code no-undo .
define variable  p-doc-type as character no-undo .
define variable  p-doc-date as date no-undo .
define variable  p-ship-date like ub.ord-doc.ship-date no-undo .
define variable  p-ship-time like ub.ord-doc.ship-time no-undo .
define variable  p-host-code like ub.ord-doc.host-code no-undo .

define variable is-l as integer no-undo .

FUNCTION excel-qnty-null RETURNS char (INPUT p-dec as decimal ).
if p-dec = 0 then Return ("").
   else RETURN(format-excel-text(excel-format-dec-to-char(Round(p-dec,3)))) .
END FUNCTION.

main-block :
do on error undo main-block, return error
:

run adm/shattri.p (
  input "get":U
  ,input ""
  ,input 0
  ,input {&attr-ord-global}
  ,input {&attr-ord-global_ord-min-ost-day}
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output par-ord-min-ost
  ,output p-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
  if error-status :error then par-ord-min-ost = false .

p-file-name =  string( session:temp-directory + {&df_name} + string( g#report-num ) + ".txt" ) .
output stream outstream to value( string( session:temp-directory + {&df_name} + string( g#report-num ) ) )      .
output stream outstream2 to value(p-file-name).
v-ind = 1    .
num#str# = 1 .
num#col# = 1 .

{ rep/repfrm.i on 50 }
{ gbl/curobjdt.i v-cntxt-obj-type v-cntxt-obj-code to-day }

find first buf_ord-doc no-lock where  buf_ord-doc.doc-code = p-ord-doc no-error .
if error-status :error then do:
  assign
    p-obj-type  = loc-store-type
    p-obj-code  = loc-store-code
    p-cli-type  = loc-cli-type
    p-cli-code  = loc-cli-code
    p-doc-type  = loc-doc-type
    p-doc-date  = doc-date
    p-ship-date = loc-date-ship
    p-host-code = v-cntxt-host-code-obj
    /* p-ship-time =  ( integer (entry(1,string(loc-time-ship,"hh:mm"),":"))   * 3600 ) +
                   ( integer (entry(2,string(loc-time-ship,"hh:mm"),":"))   * 60 ) */
    .

    /* message loc-time-ship p-ord-doc . */
end.
else do:
  assign
    p-obj-type = buf_ord-doc.obj-type
    p-obj-code = buf_ord-doc.obj-code
    p-cli-type = buf_ord-doc.cli-type
    p-cli-code = buf_ord-doc.cli-code
    p-doc-type = buf_ord-doc.doc-type
    p-doc-date = buf_ord-doc.doc-date
    p-ship-date = buf_ord-doc.ship-date
    p-ship-date = loc-date-ship
    p-ship-time = buf_ord-doc.ship-time
    p-host-code = buf_ord-doc.host-code
    .
    if p-cli-type = ? or p-cli-code = ? then do:
        assign
        p-cli-type  =  loc-cli-type
        p-cli-code  =  loc-cli-code
        p-obj-type  =  loc-store-type
        p-obj-code  =  loc-store-code
        .
    end.
end.

find first ubflt.usr-flt  no-lock where
         ubflt.usr-flt.user-name = loc-ord-num and
         ubflt.usr-flt.call-point   = "ord-m":U  + "export":U   no-error .
         if not avail ubflt.usr-flt  then do:
          find first ubflt.usr-flt  no-lock where
                  ubflt.usr-flt.user-name = loc-ord-num and
                  ubflt.usr-flt.call-point   = "ord-m":U  no-error .
         end.

define variable i          as integer no-undo .
define variable R-algoritm as integer no-undo .
define variable R-min-rest as integer no-undo .
define variable v-nn as integer   no-undo .
v-nn = num-entries(ubflt.usr-flt.list_) .

  do i = 1 to v-nn :
     case  entry(1,(entry(i,ubflt.usr-flt.list_)), "=" ) :
        when string( "R-algoritm" )             then R-algoritm = integer(entry(2,(entry(i,ubflt.usr-flt.list_)), "=" )).
        when string( "date-p-1" ) then  date-1 = date(entry(2,(entry(i,ubflt.usr-flt.list_)), "=" )).
        when string( "date-p-2" ) then  date-2 = date(entry(2,(entry(i,ubflt.usr-flt.list_)), "=" )).
        when string( "R-min-rest" )             then R-min-rest = integer(entry(2,(entry(i,ubflt.usr-flt.list_)), "=" )).
        otherwise do:
        end.
     end case.
  end.


  kol-obj = num-entries( entry(2,ubflt.usr-flt.list_,"&" ) , ",") - 1 .
     if kol-obj  = ? then kol-obj  = 0 .
  /* message kol-obj skip
          entry(2,ubflt.usr-flt.list_,"&" ).
     */
define variable p-name as character no-undo .
define buffer post-clients for ub.clients.
define buffer sh-clients for ub.clients.

find first sh-clients no-lock where
           sh-clients.obj-type =   p-obj-type and
           sh-clients.obj-code =   p-obj-code no-error  .
           if error-status :error then next.
find first post-clients no-lock where
           post-clients.obj-type =   p-cli-type and
           post-clients.obj-code =   p-cli-code no-error  .
           if error-status :error then next.


/*ШАПКА*/
reportname =  ( if p-doc-type = {&o-f} then "Заявка " else  "Заказ " )
                + p-ord-doc +
               " от " +
               string( p-doc-date,"99/99/9999")
              .
 run mf in this-procedure .
 num#str#  = 0 .
 num#col# = 1 .
 num#str# = num#str# + 1 .
 run macr_excel_char_with_format in this-procedure ( reportname , num#str# , num#col#  ).
 run macr_cell_format in this-procedure
          ( 12    ,     /* p-size */
            true  ,     /*p-bold   */
            false ,     /*p-italic */
            ?     ,     /*p-color  */
            num#str# ,  /*p-row    */
            num#col# ,  /*p-col    */
            ? ,         /*p-row-2  */
            ?         ) . /*p-col-2 */


    run make-str-1 in this-procedure .
    Output stream Macr_Excel  close .
    /*Запишем в файл параметров 1*/
    run paramls-write in this-procedure
      (input "file"
      ,input "Результат"
      ,input v-file-name
      ) .

    run mf in this-procedure .
    run make-str-3 in this-procedure .
    Output stream Macr_Excel  close .
    /*Запишем в файл параметров */
    run paramls-write in this-procedure
      (input "file"
      ,input "Экспорт данных расчета заказа"
      ,input v-file-name
      ) .

 Output stream OutStream   close .
  { rep/repfrm.i off}

  run paramls-write in this-procedure
  (input "command"
  ,input ""
  ,input 'workbook.select("Экспорт данных расчета заказа","Экспорт данных расчета заказа")'
  ) .

  run paramls-write in this-procedure
        (input "charcol"
        ,input ""
        ,input "1,2,4,5,6,7"
        ) .

 run end-proc in this-procedure .
 run rep/runexcel.p ( string( session:temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt").
 end.  /* main */

/*-----------------------------------------------------------------------------------------------------------------------*/
{ rep/r-libmcr.i macr_excel         }



procedure make-str-1 :
 do
 on error undo, return error return-value
 :
/* по строкам */

/* столбики */
num#col# =  0.
num#str# = num#str# + 1 .
num#col# = num#col# + 1 .

p-name = "Артикул" .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).

num#col# = num#col# + 1 .
p-name = "Тип производителя " .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).

num#col# = num#col# + 1 .
p-name = "Код производителя " .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).

num#col# = num#col# + 1 .
p-name = "Название товара" .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).

num#col# = num#col# + 1 .
p-name = "Артикул поставщика" .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).


num#col# = num#col# + 1 .
p-name = "Цена в валюте поставщика в баз.ед.изм" .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).

num#col# = num#col# + 1 .
p-name = "Количество в баз.ед.изм" .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).


for each  buf_ord-line no-lock where  buf_ord-line.doc-code = p-ord-doc /* buf_ord-line.line-num */ ,
    first ub.goods no-lock where
          ub.goods.artic     = buf_ord-line.artic      and
          ub.goods.prod-type = buf_ord-line.prod-type  and
          ub.goods.prod-code = buf_ord-line.prod-code  break by ub.goods.gds-code :

    find first ub.clients no-lock where
          ub.goods.prod-type = ub.clients.obj-type and
          ub.goods.prod-code = ub.clients.obj-code no-error .
          if error-status :error then next.
    num#col# = 1 .
    num#str# = num#str# + 1 .
    run macr_excel_char_with_format in this-procedure ( buf_ord-line.artic , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_char_with_format in this-procedure ( buf_ord-line.prod-type , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_char_with_format in this-procedure ( buf_ord-line.prod-code , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_char_with_format in this-procedure ( ub.goods.gds-name , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_char_with_format in this-procedure ( (if buf_ord-line.cli-art <> ? then buf_ord-line.cli-art  else "") , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_dec in this-procedure ( determined ( buf_ord-line.price-cli / buf_ord-line.cli-base-rate ), num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_dec in this-procedure ( buf_ord-line.qnty       , num#str# , num#col#  ). num#col# = num#col# + 1 .

end.


 end. /* do */
end procedure. /* make-str */
procedure make-str-3 :
 do
 on error undo, return error return-value
 :
define variable loc-sum-min1 as character no-undo .
define variable loc-sum-min2 as character no-undo .
define variable loc-sum-min3 as character no-undo .
define variable t-type       as character no-undo .

define variable lp-in-qnty     as decimal no-undo .
define variable lp-out-qnty    as decimal no-undo .
define variable lp-out-sum     as decimal no-undo .
define variable lp-Temp-rash   as decimal no-undo .
define variable lp-min-stock   as decimal no-undo .
define variable lp-qnty-sale   as decimal no-undo .
define variable lp-zero-day    as decimal no-undo .
define variable lp-in-out-qnty as decimal no-undo .
define variable lp-supp-qnty   as decimal no-undo .
define variable lp-qnty-kassa  as decimal no-undo .
define variable lp-qnty-stk   as decimal no-undo .
define variable lp-qnty-prih  as decimal no-undo .
define variable lp-qnty-rash  as decimal no-undo .

 num#str# = 0 .
 num#col# = 1 .
 num#str# = num#str# + 1 .

 run macr_excel_char_with_format in this-procedure ( reportname , num#str# , num#col#  ).
 run macr_cell_format in this-procedure
          ( 12    ,       /* p-size   */
            true  ,       /* p-bold   */
            false ,       /* p-italic */
            ?     ,       /* p-color  */
            num#str# ,    /* p-row    */
            num#col# ,    /* p-col    */
            ? ,           /* p-row-2  */
            ?         ) . /* p-col-2  */

reportheader =   cur-time-print() .


num#str# = num#str# + 1 .
num#col# = 1 .
p-name = "Покупатель: " .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).
num#col# =  4 .
run macr_excel_char_with_format in this-procedure ( sh-clients.obj-name , num#str# , num#col#  ).


num#str# = num#str# + 1 .
num#col# =  1 .
p-name = "Поставщик: " .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).
num#col# =  4 .
run macr_excel_char_with_format in this-procedure ( post-clients.obj-name , num#str# , num#col#  ).


num#str# = num#str# + 1 .
num#col# = 1 .
p-name = "Дата печати: " .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).
num#col# = 4 .
run macr_excel_char_with_format in this-procedure ( string( today ,"99/99/9999") , num#str# , num#col#  ).

num#str# = num#str# + 1 .
num#col# = 1 .
p-name = "Планируемая дата доставки: " .
run macr_excel_char_with_format in this-procedure ( p-name , num#str# , num#col#  ).
num#col# = 4 .
run macr_excel_char_with_format in this-procedure ( string( p-ship-date,"99/99/9999") , num#str# , num#col#  ).
num#col# = 5 .
run macr_excel_char_with_format in this-procedure ( "Время : " + string( p-ship-time,"hh:mm") , num#str# , num#col#  ).

/* столбики */
 run macr_cell_format in this-procedure  (
        10       , /*p-size-font */
        true     , /*p-bold      */
        false    , /*p-italic    */
        34       , /*p-color-bg  */
        6        , /*p-row       */
        1        , /*p-col       */
        6        , /*p-row-2     */
        max-col )       /*p-col-2     */
        .

num#col# =  0 .
num#str# = num#str# + 1 .
num#col# = num#col# + 1 .
define variable p-fi as character no-undo .
define variable name-tt as character no-undo .

if loc-doc-type = {&f-p} then do:
    p-fi  = " по фирме " .
end.
else do:
   p-fi  = " по объекту " .
end.

case R-algoritm :
  when 2 then do:
      name-tt =  "Темп продаж из списка" .
  end.
  when 4 then do:
      name-tt =  "Максимальная продажа" .
  end.
  otherwise do:
      name-tt =  "Темп продаж с " + String(date-1) + " по " + String(date-2) .
  end.
end case.


 run macr_excel_char_with_format in this-procedure ("Артикул"                                                         , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("Название товара"                                                 , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 put  stream macr_excel unformatted  'COLUMN.WIDTH(30,,,,)'  skip.
 run macr_excel_char_with_format in this-procedure ("Ед.изм."                                                         , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("Код производителя ", num#str# , num#col#  ).                                                num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("Название производителя ", num#str# , num#col#  ).                                           num#col# = num#col# + 1 .
 put  stream macr_excel unformatted  'COLUMN.WIDTH(30,,,,)'  skip.
 run macr_excel_char_with_format in this-procedure ("Артикул контрагента"                                             , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("Ед.изм. контрагента"                                             , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("Кол-во приход по контрагенту"                                    , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("Кол-во расход по контрагенту"                                    , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("Продаж.цены(вал.продаж) расход"                                  , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("Последн.цена контрагента на баз.ед.изм."                         , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("Кол-во остатки по контрагенту"                                   , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("Приход / Расход"                                                 , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("Срок хранения"                                                   , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("Коэффициент пересчета ед.изм."                                   , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("Количество в упаковке"                                                  , num#str# , num#col#  ) . num#col# = num#col# + 1 .


 run macr_excel_char_with_format in this-procedure ( name-tt      , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("ЗАКАЗ кол-во"                                                    , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("ЗАКАЗ сумма"                                                     , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ( if R-algoritm = 2 then "Расход (не рассчитывается)" else "Расход с " + String(date-1) + " по " + String(date-2)            , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("Дней без продаж и остатков"                                      , num#str# , num#col#  ) . num#col# = num#col# + 1 .

 run macr_excel_char_with_format in this-procedure ("Остаток на " + String(to-day)                              , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("Приход "                                                   , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("Внешний расход "                                           , num#str# , num#col#  ) . num#col# = num#col# + 1 .
 run macr_excel_char_with_format in this-procedure ("Касса "                                                    , num#str# , num#col#  ) . num#col# = num#col# + 1 .

define variable v-tooltip as character no-undo .
define variable v-label   as character no-undo .
if R-min-rest = 1 then dO:
    run macr_excel_char_with_format in this-procedure ( "Минимальный остаток" , num#str# , num#col# ).    num#col# = num#col# + 1 .
    run macr_excel_char_with_format in this-procedure ( "Уровень постоянного присутствия", num#str# , num#col# ).    num#col# = num#col# + 1 .
    run macr_excel_char_with_format in this-procedure ( "Минимальный заказ" , num#str# , num#col# ).                 num#col# = num#col# + 1 .
end.
if R-min-rest = 2 then dO:
    run macr_excel_char_with_format in this-procedure ( "Минимальный остаток на фирме" , num#str# , num#col# ).    num#col# = num#col# + 1 .
    run macr_excel_char_with_format in this-procedure ( "Уровень постоянного присутствия на фирме", num#str# , num#col# ).    num#col# = num#col# + 1 .
    run macr_excel_char_with_format in this-procedure ( "Минимальный заказ на фирме" , num#str# , num#col# ).                 num#col# = num#col# + 1 .
end.

run macr_excel_char_with_format in this-procedure ("Код объекта ", num#str# , num#col#  ).       num#col# = num#col# + 1 .
run macr_excel_char_with_format in this-procedure ("Разрешены отриц.остатки ", num#str# , num#col#  ).       num#col# = num#col# + 1 .
run macr_excel_char_with_format in this-procedure ("В пути ", num#str# , num#col#  ).       num#col# = num#col# + 1 .
run macr_excel_char_with_format in this-procedure ("Дней в продаже ", num#str# , num#col#  ).       num#col# = num#col# + 1 .

  put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , 6  , 1 , num#str# ,  max-col ) + {&new-line}  +
        'BORDER( 2 , 2 , 2 , 2 , 2 , ,0,0,0,0,0) '  + {&new-line} +
       'ALIGNMENT(3 , , 4 , 4 ,)'  + {&new-line}
       .

num#col# =  0.


/* по строкам */

define variable l-all-day as integer no-undo .

define variable s-in-qnty   as decimal no-undo .
define variable s-out-qnty  as decimal no-undo .
define variable s-out-sum   as decimal no-undo .
define variable s-supp-qnty as decimal no-undo .
define variable ss-in-qnty  as decimal no-undo .
define variable ss-out-qnty as decimal no-undo .
define variable ss-out-sum  as decimal no-undo .
define variable ss-supp-qnty as decimal no-undo .

define variable s-qnty       as decimal no-undo .
define variable s-sum-rubl   as decimal no-undo .
define variable s-qnty-rashkassa  as decimal no-undo .
define variable s-zero-day        as decimal no-undo .
define variable s-qnty-stk        as decimal no-undo .
define variable s-qnty-prih       as decimal no-undo .
define variable s-qnty-rash       as decimal no-undo .
define variable s-qnty-kassa      as decimal no-undo .
define variable s-min-stock       as decimal no-undo .
define variable s-service-order   as decimal no-undo .
define variable s-min-order       as decimal no-undo .
define variable s-gds-way-all     as decimal no-undo .
define variable s-l-all-day       as decimal no-undo .
define variable ss-qnty       as decimal no-undo .
define variable ss-sum-rubl   as decimal no-undo .
define variable ss-qnty-rashkassa  as decimal no-undo .
define variable ss-zero-day        as decimal no-undo .
define variable ss-qnty-stk        as decimal no-undo .
define variable ss-qnty-prih       as decimal no-undo .
define variable ss-qnty-rash       as decimal no-undo .
define variable ss-qnty-kassa      as decimal no-undo .
define variable ss-min-stock       as decimal no-undo .
define variable ss-service-order   as decimal no-undo .
define variable ss-min-order       as decimal no-undo .
define variable ss-gds-way-all     as decimal no-undo .
define variable ss-l-all-day       as decimal no-undo .



for each  export-ras where  break by export-ras.gds-code :
    find first ub.goods no-lock where
          ub.goods.artic     = export-ras.artic     and
          ub.goods.prod-type = export-ras.prod-type and
          ub.goods.prod-code = export-ras.prod-code no-error .
          if error-status :error then next.
    find first ub.clients no-lock where
          ub.goods.prod-type = ub.clients.obj-type and
          ub.goods.prod-code = ub.clients.obj-code no-error .
          if error-status :error then next.

    num#col# = 1 .
    num#str# = num#str# + 1 .
    /* === */
    if first-of(export-ras.gds-code) then do:
       assign
          s-in-qnty    = 0
          s-out-qnty   = 0
          s-out-sum    = 0
          s-supp-qnty  = 0
          s-qnty                 = 0
          s-sum-rubl             = 0
          s-qnty-rashkassa       = 0
          s-zero-day             = 0
          s-qnty-stk             = 0
          s-qnty-prih            = 0
          s-qnty-rash            = 0
          s-qnty-kassa           = 0
          s-min-stock            = 0
          s-service-order        = 0
          s-min-order            = 0
          s-gds-way-all          = 0
          s-l-all-day           = 0

        .
        run macr_excel_char_with_format in this-procedure ( export-ras.artic , num#str# , num#col#  ). num#col# = num#col# + 1 .
        run macr_excel_char_with_format in this-procedure ( ub.goods.gds-name   , num#str# , num#col#  ). num#col# = num#col# + 1 .
        run macr_excel_char_with_format in this-procedure ( ub.goods.unit-base  , num#str# , num#col#  ). num#col# = num#col# + 1 .
        run macr_excel_char_with_format in this-procedure ( export-ras.prod-type + " " + string(export-ras.prod-code) , num#str# , num#col#  ). num#col# = num#col# + 1 .
        run macr_excel_char_with_format in this-procedure ( ub.clients.obj-name      , num#str# , num#col#  ). num#col# = num#col# + 1 .
        run macr_excel_char_with_format in this-procedure ( export-ras.cli-art    , num#str# , num#col#  ). num#col# = num#col# + 1 .
        run macr_excel_char_with_format in this-procedure ( export-ras.unit-cli   , num#str# , num#col#  ). num#col# = num#col# + 1 .
        run macr_excel_dec in this-procedure (  export-ras.in-qnty     , num#str# , num#col#  ). num#col# = num#col# + 1 .
        run macr_excel_dec in this-procedure (  export-ras.out-qnty    , num#str# , num#col#  ). num#col# = num#col# + 1 .
        run macr_excel_dec in this-procedure (  export-ras.out-sum     , num#str# , num#col#  ). num#col# = num#col# + 1 .
        run macr_excel_dec in this-procedure (  determined ( export-ras.price-cli / export-ras.cli-base-rate )  , num#str# , num#col#  ). num#col# = num#col# + 1 .
        run macr_excel_dec in this-procedure (  export-ras.supp-qnty   , num#str# , num#col#  ). num#col# = num#col# + 1 .
        run macr_excel_dec in this-procedure (  determined (  export-ras.in-qnty / export-ras.out-qnty )    , num#str# , num#col#  ). num#col# = num#col# + 1 .
        run macr_excel_dec in this-procedure (  ub.goods.deadline         , num#str# , num#col#  ). num#col# = num#col# + 1 .
        run macr_excel_dec in this-procedure (  export-ras.cli-base-rate         , num#str# , num#col#  ). num#col# = num#col# + 1 .
        run macr_excel_dec in this-procedure (  ub.goods.qnty-cart          , num#str# , num#col#  ). num#col# = num#col# + 1 .
       assign
          s-in-qnty    = s-in-qnty   +  export-ras.in-qnty
          s-out-qnty   = s-out-qnty  +  export-ras.out-qnty
          s-out-sum    = s-out-sum   +  export-ras.out-sum
          s-supp-qnty  = s-supp-qnty +  export-ras.supp-qnty
          ss-in-qnty   = ss-in-qnty   +  export-ras.in-qnty
          ss-out-qnty  = ss-out-qnty  +  export-ras.out-qnty
          ss-out-sum   = ss-out-sum   +  export-ras.out-sum
          ss-supp-qnty = ss-supp-qnty +  export-ras.supp-qnty
       .

    end.
    else do:
      num#col# = num#col# + 16 .
    end.
   if (p-doc-type = {&f-p} and R-min-rest = 2 and first-of ( export-ras.gds-code )) or
      (p-doc-type = {&f-p} and R-min-rest = 1 ) or
       p-doc-type <> {&f-p}
    then do :
    run macr_excel_dec in this-procedure (  export-ras.Temp-rash           , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_dec in this-procedure (  export-ras.qnty      , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_dec in this-procedure (  export-ras.sum-rubl  , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_dec in this-procedure (  (export-ras.qnty-rash + export-ras.qnty-kassa)           , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_dec in this-procedure (  export-ras.zero-day            , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_dec in this-procedure (  export-ras.qnty-stk            , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_dec in this-procedure (  export-ras.qnty-prih           , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_dec in this-procedure (  export-ras.qnty-rash           , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_dec in this-procedure (  export-ras.qnty-kassa          , num#str# , num#col#  ). num#col# = num#col# + 1 .

    if par-ord-min-ost = true then do:
       run macr_excel_dec in this-procedure
          ((export-ras.min-stock * export-ras.Temp-rash)   ,
            num#str# ,
            num#col#
            ) .
       num#col# = num#col# + 1 .
    end.
    else do:
       run macr_excel_dec in this-procedure
       ( export-ras.min-stock ,
         num#str# ,
         num#col#
         ).
       num#col# = num#col# + 1 .
    end.

    run macr_excel_dec in this-procedure (  export-ras.service-order , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_dec in this-procedure (  export-ras.min-order   , num#str# , num#col#  ).   num#col# = num#col# + 1 .
        if ( p-doc-type = {&f-p} and R-min-rest = 2 ) then do:
       run macr_excel_char_with_format in this-procedure  ( "список" , num#str# , num#col#  ) .
    end.
    else do:
       run macr_excel_char_with_format in this-procedure ( export-ras.obj-type + " " + string(export-ras.obj-code) , num#str# , num#col#  ) .
    end.
    if p-prt-all then do:
       run macr_excel_char_with_format in this-procedure ( export-ras.artic , num#str# , 1  ) .
    end.
    num#col# = num#col# + 1 .
    run macr_excel_char_with_format in this-procedure ( export-ras.negative-rest  , num#str# , num#col#  ). num#col# = num#col# + 1 .
    run macr_excel_dec in this-procedure ( export-ras.gds-way-all  , num#str# , num#col#  ). num#col# = num#col# + 1 .
         l-all-day =  export-ras.all-day  .   if l-all-day = ? then l-all-day = 0 .
    run macr_excel_dec in this-procedure ( l-all-day  , num#str# , num#col#  ). num#col# = num#col# + 1 .


    assign
     s-qnty                =  s-qnty        +  export-ras.qnty
     s-sum-rubl            =  s-sum-rubl    +  export-ras.sum-rubl
     s-qnty-rashkassa      =  s-qnty-rashkassa +   (export-ras.qnty-rash + export-ras.qnty-kassa)
     s-zero-day            =  s-zero-day    +  export-ras.zero-day
     s-qnty-stk            =  s-qnty-stk    +  export-ras.qnty-stk
     s-qnty-prih           =  s-qnty-prih   +  export-ras.qnty-prih
     s-qnty-rash           =  s-qnty-rash   +  export-ras.qnty-rash
     s-qnty-kassa          =  s-qnty-kassa  +  export-ras.qnty-kassa
     s-min-stock           =  s-min-stock   +  export-ras.min-stock
     s-service-order       =  s-service-order + export-ras.service-order
     s-min-order           =  s-min-order     + export-ras.min-order
     s-gds-way-all         =  s-gds-way-all   + export-ras.gds-way-all
     s-l-all-day           =  s-l-all-day     +           l-all-day
     ss-qnty                =  ss-qnty        +  export-ras.qnty
     ss-sum-rubl            =  ss-sum-rubl    +  export-ras.sum-rubl
     ss-qnty-rashkassa      =  ss-qnty-rashkassa +   (export-ras.qnty-rash + export-ras.qnty-kassa)
     ss-zero-day            =  ss-zero-day    +  export-ras.zero-day
     ss-qnty-stk            =  ss-qnty-stk    +  export-ras.qnty-stk
     ss-qnty-prih           =  ss-qnty-prih   +  export-ras.qnty-prih
     ss-qnty-rash           =  ss-qnty-rash   +  export-ras.qnty-rash
     ss-qnty-kassa          =  ss-qnty-kassa  +  export-ras.qnty-kassa
     ss-min-stock           =  ss-min-stock   +  export-ras.min-stock
     ss-service-order       =  ss-service-order + export-ras.service-order
     ss-min-order           =  ss-min-order     + export-ras.min-order
     ss-gds-way-all         =  ss-gds-way-all   + export-ras.gds-way-all
     ss-l-all-day           =  ss-l-all-day     +           l-all-day
    .
    end.

    if last-of(export-ras.gds-code) and  loc-doc-type = {&f-p} and kol-obj > 1  then do:
            num#str# = num#str# + 1 .
            num#col# =  1.
            run macr_excel_char in this-procedure (  " Итого по товару", num#str# , num#col#     ) .
            define variable iii as integer no-undo .
            num#col# =  8.
            run macr_excel_dec in this-procedure (s-in-qnty    , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (s-out-qnty   , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (s-out-sum    , num#str# , num#col#  ). num#col# = num#col# + 1 .
            num#col# =  12.
            run macr_excel_dec in this-procedure (s-supp-qnty  , num#str# , num#col#  ). num#col# = num#col# + 1 .
            num#col# =  18.
            run macr_excel_dec in this-procedure (s-qnty       , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (s-sum-rubl   , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (s-qnty-rashkassa , num#str# , num#col#  ). num#col# = num#col# + 1 .
            /* run macr_excel_dec in this-procedure (s-zero-day       , num#str# , num#col#  ). */ num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (s-qnty-stk       , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (s-qnty-prih      , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (s-qnty-rash      , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (s-qnty-kassa     , num#str# , num#col#  ). num#col# = num#col# + 1 .
           /*
            run macr_excel_dec in this-procedure (s-min-stock      , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (s-service-order  , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (s-min-order      , num#str# , num#col#  ). num#col# = num#col# + 1 .
            */
            num#col# =  31.
            run macr_excel_dec in this-procedure (s-gds-way-all    , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (s-l-all-day      , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_cell_format in this-procedure
                      ( 10    ,     /* p-size */
                        true  ,     /*p-bold   */
                        false ,     /*p-italic */
                        ?     ,     /*p-color  */
                        num#str# ,  /*p-row    */
                        1 ,         /*p-col    */
                        ? ,         /*p-row-2  */
                        num#col#         ) . /*p-col-2 */
                num#col# =  1.

    end.
end.
    num#str# = num#str# + 1.
    num#col# =  1.
 if loc-doc-type <> {&f-p} or loc-doc-type = {&f-p}   then do:
    run macr_excel_char in this-procedure (  " Итого по Заказу", num#str# , num#col#     ) .
            num#col# =  8.
            run macr_excel_dec in this-procedure (ss-in-qnty    , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (ss-out-qnty   , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (ss-out-sum    , num#str# , num#col#  ). num#col# = num#col# + 1 .
            num#col# =  12.
            run macr_excel_dec in this-procedure (ss-supp-qnty  , num#str# , num#col#  ). num#col# = num#col# + 1 .
            num#col# =  18.
            run macr_excel_dec in this-procedure (ss-qnty       , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (ss-sum-rubl   , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (ss-qnty-rashkassa , num#str# , num#col#  ). num#col# = num#col# + 1 .
            /* run macr_excel_dec in this-procedure (ss-zero-day       , num#str# , num#col#  ). */ num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (ss-qnty-stk       , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (ss-qnty-prih      , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (ss-qnty-rash      , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (ss-qnty-kassa     , num#str# , num#col#  ). num#col# = num#col# + 1 .
            /*
            run macr_excel_dec in this-procedure (ss-min-stock      , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (ss-service-order  , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (ss-min-order      , num#str# , num#col#  ). num#col# = num#col# + 1 .
            */
            num#col# =  31.
            run macr_excel_dec in this-procedure (ss-gds-way-all    , num#str# , num#col#  ). num#col# = num#col# + 1 .
            run macr_excel_dec in this-procedure (ss-l-all-day      , num#str# , num#col#  ). num#col# = num#col# + 1 .
      run macr_cell_format
                ( 10    ,     /* p-size */
                  true  ,     /*p-bold   */
                  false ,     /*p-italic */
                  ?     ,     /*p-color  */
                  num#str# ,  /*p-row    */
                  1 ,         /*p-col    */
                  ? ,         /*p-row-2  */
                  num#col#         ) . /*p-col-2 */

          num#str# = num#str# + 1.


          num#col# =  1.
end.

run macr_excel_char in this-procedure (  " Категорийный менеджер", num#str# , num#col#     )   .
num#col# =  5.

run macr_excel_char in this-procedure ( "ФИО Категорийного менеджера" , num#str# , num#col#     )   .

 run macr_cell_format in this-procedure
          ( 10    ,     /* p-size */
            true  ,     /*p-bold   */
            false ,     /*p-italic */
            ?     ,     /*p-color  */
            num#str# ,  /*p-row    */
            1 ,         /*p-col    */
            ? ,         /*p-row-2  */
            num#col#         ) . /*p-col-2 */

num#str# = num#str# + 3.
num#col# =  1.
run macr_excel_char in this-procedure (  "Параметры расчета заказа", num#str# , num#col#     )   .
 run macr_cell_format  in this-procedure
          ( 12    ,     /* p-size */
            true  ,     /*p-bold   */
            false ,     /*p-italic */
            15     ,     /*p-color  */
            num#str# ,  /*p-row    */
            1 ,         /*p-col    */
            ? ,         /*p-row-2  */
            3       ) . /*p-col-2 */


    define variable jjj as integer no-undo .
    define variable pp-str as character no-undo .
    define variable pp-str2 as character no-undo .
    num#col# =  1.
    iii= 0.
define variable l-jj  as integer no-undo .
define variable l-len as integer no-undo .
define variable l-m   as integer no-undo .
define variable v-nn as integer   no-undo .
define variable v-nn2 as integer   no-undo .

v-nn = num-entries( p-e-method ,"{&new-line}") .
v-nn2 = num-entries( pp-str ,";") .
    repeat iii = 1 to v-nn  :
        pp-str = entry (iii, p-e-method , "{&new-line}").
        v-nn2 = num-entries( pp-str ,";") .
          repeat jjj = 1 to v-nn2 :
            pp-str2 = entry (jjj, pp-str , ";").
            if pp-str2 <> "" and pp-str2 <> ? and  pp-str2 <> " " then do:
                    l-len = length (pp-str2  ) .
                    l-m = integer( l-len / 220 ) + 1 .
                    do l-jj = 1 to  l-m  :
                        num#str# = num#str# + 1 .
                        run macr_excel_char in this-procedure (
                            substring( pp-str2, (( 220 * l-jj ) - 219 )  , 220 )  , num#str# , num#col# ) .
                    end.                                                                                                       ~
            end.
          end.
    end.



end. /* do */
end procedure. /* make-str-3 */




procedure mf :
 do
 on error undo, return error return-value
 :
    /* создаем временный файл  */
    run gbl/_tmpfile.p ( "wb", ".txt", output v-file-name) .
    output stream  Macr_Excel to value(v-file-name) .
    v-ind = v-ind + 1 .
    num#str# = 0 .


 end. /* do */
end procedure. /* mf */

/* $Workfile: z-tot5.p $ e n d */