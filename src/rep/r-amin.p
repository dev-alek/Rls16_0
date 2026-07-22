block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author:Ishalnev $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-amin.p $
$Archive: rep/r-amin.p $

Ассортиментный минимум по текущему объекту

Автор: Чернова Светлана Александровна
Дата создания: 08/24/05
Author: Svetlana Chernova
Creation date: 08/24/05

*/
define input parameter p-all-gds as logical no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-amin.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-amin.p $":U .
define variable vss-description as character no-undo init "Ассортиментный минимум по текущему объекту".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i   }
{ cmp/r-page1.i  }
{ gbl/paramls.i  }
{ rep/f-fdec.i   }
{ gbl/getcntxt.i def }
{ ref/def-hash.i }
{ rep/lkp-font.i }

define variable  parParentProc  AS WIDGET-HANDLE NO-UNDO.
define variable g#host-name  as character no-undo .
define variable g#host-code    as integer   no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable g#log      as logical   no-undo .
define variable g#report-num as integer   no-undo .

parParentProc = my-HANDLE  .
{ gbl/getcntxt.i get }
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
.
{ gbl/hostname.i store-type store-code  g#host-code g#host-name }
run get-report-num  in parParentProc ( output g#report-num ).



define variable parhost-code as integer   no-undo .
parhost-code = g#host-code.

define stream  OutStream  .
define stream  macr_excel .

define variable v-file-name as character no-undo .
define variable v-ind       as integer   no-undo .
define variable num#col#    as integer no-undo .
define variable C-c    as integer no-undo .
define variable C-str  as character no-undo .
define variable str--1 as character Format "x(60)" no-undo.
define variable str--2 as integer no-undo .
define variable C-i    as integer no-undo .
define variable p-var  as integer no-undo .
define variable var-1  as integer no-undo .
define variable var-2  as integer no-undo .
define buffer This_Object for  ub.clients .

define variable num-ln as integer   no-undo .

define variable i as int no-undo.
define variable j as int no-undo.
define variable Counter1 as integer init 0  no-undo .

define variable LineBuf    as char    no-undo.
define variable Line       as char    no-undo.
define variable UndLine    as char    no-undo.

define variable Lines_Counter as   int  init 0  no-undo.
define variable Tmp_Counter   as   int  init 0  no-undo.

define variable vv0 as character no-undo .
define variable vv1 as character no-undo .
define variable vv2 as character no-undo .
define variable vv3 as character no-undo .
define variable vv4 as character no-undo .
define variable vv5 as character no-undo .
define variable vv6 as character no-undo .
define variable vv7 as character no-undo .
{ rep/r-sym.i }

define variable t-1 as character no-undo .
define variable t-2 as character no-undo .
define variable t-3 as character no-undo .
define variable t-4 as character no-undo .
define variable t-5 as character no-undo .

DEFINE FRAME plan-menu
    HEADER
    string( "Лист " + string( PAGE-NUMBER(OutStream) , ">>>>9") ) AT 80 format "X(13)" SKIP
    UndLine format "X(80)" AT 1
    with width {&DOS_CW} down stream-io use-text NO-UNDERLINE  NO-BOX no-labels.

  if session:set-wait-state("compiler") then.
 ReportPageHeight = 43.
 ReportPageWidth = 198.

  { cmp/open-out.i STREAM OutStream " " ReportPageHeight }

  define variable v-prn0 as character no-undo .

  assign
    Line    = fill("-", 230)
    UndLine = fill("_", 230)
    LineBuf = fill("_", 240)
  .

define variable v-is-base as logical no-undo .
{ gbl/rbisbase.i    v-is-base  }

if v-is-base = true then do:
end.
else do:
end.

{ rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
{ rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */
/*-----------------------------------------------------------------------------------------------------------------------*/
v-ind = 0    .

FORM with frame plan-menu .



 /* создаем временный файл */
    Output stream Macr_Excel  close .
    num#str# = 0 .
    run gbl/_tmpfile.p ( "wb", ".txt", output v-file-name) .
    output stream macr_excel to value(v-file-name)   .
    v-ind = v-ind + 1.

define buffer buf_clients for ub.clients  .
define buffer obj_clients for ub.clients  .
define buffer buf_gds-obj-prop for ub.gds-obj-prop  .
define buffer buf_gds-obj      for ub.gds-obj .
define buffer buf_goods for ub.goods  .
define buffer buf_xyz-analysis-goods for ub.xyz-analysis-goods  .
define buffer buf_abc-analysis-goods for ub.abc-analysis-goods  .
define buffer buf_abc-analysis-gds-obj for ub.abc-analysis-gds-obj  .


define variable v-abc-id as integer   no-undo .
define variable v-xyz-id as integer   no-undo .
define variable v-db-num as integer   no-undo .
define variable v-db-num-xyz as integer   no-undo .
define variable v-abc as character no-undo .
define variable v-xyz as character no-undo .
define variable v-temp as decimal   no-undo .
define variable v-qnty  as decimal   no-undo .
define variable v-price as decimal   no-undo .
define variable v-ord-qnty as decimal   no-undo .
define variable v-min-qnty as decimal no-undo.

find buf_clients      where buf_clients.obj-type     = {&cmp}                and buf_clients.obj-code      = g#host-code no-lock .
find obj_clients      where obj_clients.obj-type     = store-type            and obj_clients.obj-code      = store-code no-lock .

run find-def-analysis-obj (
   input  "abc"
 , input  store-type
 , input  store-code
 , output v-abc-id
 , output v-db-num   ).

run find-def-analysis-obj (
   input  "xyz"
 , input  store-type
 , input  store-code
 , output v-xyz-id
 , output v-db-num-xyz   ).



  run PrintTitul in this-procedure .
  /* по строкам -------------------------------------------------------------------------------------------- */
  for each buf_gds-obj-prop no-lock where
           buf_gds-obj-prop.obj-type = store-type and
           buf_gds-obj-prop.obj-code = store-code and
           buf_gds-obj-prop.gdop-assort-min = true
           :
    find first buf_goods no-lock where buf_goods.gds-code = buf_gds-obj-prop.gds-code no-error .

    case x-SelectGood :
        when {&g-all}  then do: /* все товары */
                            end.
        when {&g-prod} then do:    /* не все производители */

                             find first  G#cli no-lock
                             where G#cli.obj-type = buf_goods.prod-type
                               and G#cli.obj-code = buf_goods.prod-code no-error.
                             if not available  G#cli then next.
                            end .
        when {&g-grp}  then do:     /*не все группы товаров */
                             find first tmp#grp no-lock
                             where tmp#grp.node-code = buf_goods.grp-code no-error.
                             if not available tmp#grp then next.
                            end.
        otherwise do:     /*список товаров*/
                    find first gds-list no-lock
                    where buf_goods.artic     = gds-list.artic
                      and buf_goods.prod-type = gds-list.prod-type
                      and buf_goods.prod-code = gds-list.prod-code  no-error.
                      if not available  gds-list then next.
                  end.

    end case.

    find first buf_gds-obj no-lock where
               buf_gds-obj.gds-code = buf_gds-obj-prop.gds-code and
               buf_gds-obj.obj-code = buf_gds-obj-prop.obj-code and
               buf_gds-obj.obj-type = buf_gds-obj-prop.obj-type no-error .
               if available buf_gds-obj then do:
                 v-qnty  = buf_gds-obj.fact-qnty.
                 v-price = buf_gds-obj.price-sale.
                 v-min-qnty = buf_gds-obj-prop.gdop-min-stock.
               end.
               else do:
                 v-qnty  = 0.
                 v-price = 0.
                 v-min-qnty = 0.
               end.
    find first buf_abc-analysis-goods no-lock where
               buf_abc-analysis-goods.abc-id = v-abc-id and
               buf_abc-analysis-goods.db-num = v-db-num and
               buf_abc-analysis-goods.gds-code = buf_gds-obj-prop.gds-code no-error .
               if available buf_abc-analysis-goods
                  then do:
                     assign v-abc = buf_abc-analysis-goods.abcg-abc .
                      find first buf_abc-analysis-gds-obj no-lock where
                                buf_abc-analysis-gds-obj.obj-type = buf_gds-obj-prop.obj-type and
                                buf_abc-analysis-gds-obj.obj-code = buf_gds-obj-prop.obj-code and
                                buf_abc-analysis-gds-obj.abc-id = v-abc-id and
                                buf_abc-analysis-gds-obj.db-num = v-db-num and
                                buf_abc-analysis-gds-obj.gds-code = buf_gds-obj-prop.gds-code no-error .
                                if available buf_abc-analysis-gds-obj then v-temp = buf_abc-analysis-gds-obj.abog-temp-sale-goods .
                                                                      else v-temp = 0.
                  end.
                  else do:
                    assign
                      v-abc = ""
                      v-temp = 0
                    .
                  end.

    find first buf_xyz-analysis-goods no-lock where
               buf_xyz-analysis-goods.xyz-id = v-xyz-id and
               buf_xyz-analysis-goods.db-num = v-db-num-xyz and
               buf_xyz-analysis-goods.gds-code = buf_gds-obj-prop.gds-code no-error .
               if available buf_xyz-analysis-goods
                  then v-xyz = buf_xyz-analysis-goods.xyzg-xyz .
                  else v-xyz = "" .

      run def-order (
       input   buf_gds-obj-prop.obj-type
      ,input   buf_gds-obj-prop.obj-code
      ,input   buf_goods.artic
      ,input   buf_goods.prod-type
      ,input   buf_goods.prod-code
      ,output  v-ord-qnty  ).

    if p-all-gds = false then do :
      if v-qnty < v-min-qnty then do :
        run print-line in this-procedure .
      end.
    end.
    else do :
     run print-line in this-procedure .
    end.
  end.
  run print-all-itog in this-procedure .
  /* ... Подвал. --- */
  run on-same-page in this-procedure (input 3) .
  run PrintPodval in this-procedure .
  run paramls-write in this-procedure
    (input "file"
    ,input string(v-ind)
    ,input v-file-name
    ) .
     page stream OutStream .

HIDE STREAM OutStream FRAME plan-menu.
HIDE stream OutStream FRAME BottomFrame .
HIDE stream OutStream FRAME BottomFrame2 .
output stream OutStream CLOSE .
Output stream Macr_Excel  close .

{ rep/repfrm.i off } /* Показать окно информации о текущем процессе */

    run paramls-write in this-procedure
        (input "charcol"
        ,input ""
        ,input "2,3,4"
        ) .


  run end-proc in this-procedure .

define variable v-user-action as character no-undo .
define variable v-printed as logical   no-undo .
define variable DisabledOptions as integer   no-undo .
define variable v-orient-page as character no-undo .
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
    ,input ReportFontNum
    ,output v-user-action
    ,output v-printed
    ) .

/* *************************************************************************************************** */
procedure print-line :
  do on error undo, return error return-value :
  assign
     Lines_Counter = Lines_Counter + 1
    .

  if line-counter( OutStream ) + 2 > page-size( OutStream ) then do:
     page stream OutStream.
     PUT STREAM OutStream UNFORMATTED
         string( "Лист " + string( PAGE-NUMBER(OutStream) , ">>>>9") ) AT 100 format "X(13)" SKIP .
     run print-1 in this-procedure .
     end.
  if line-counter( OutStream ) < Tmp_Counter then
    assign
    .

  assign
    Tmp_Counter  = line-counter( OutStream )
    num-ln = num-ln + 1
  .

  if line-counter( OutStream ) + j > page-size( OutStream ) then  PAGE STREAM OutStream.


PUT STREAM OutStream UNFORMATTED
    sym1                format "X(1)" space(0)
    string(buf_goods.gds-code)    format "X(10)" space(0)
    sym2                format "X(1)" space(0)
    string(buf_goods.artic)    format "X(16)" space(0)
    sym3                format "X(1)" space(0)
    string(buf_goods.gds-name)    format "X(30)" space(0)
    sym4                format "X(1)" space(0)
    string(buf_goods.unit-base)    format "X(3)" space(0)
    sym5                format "X(1)" space(0)
    string(v-price)               format "X(14)" space(0)
    sym6                format "X(1)" space(0)
    string(v-qnty)                format "X(14)" space(0)
    sym7                format "X(1)" space(0)
    string(v-min-qnty)            format "X(14)" space(0)
    sym8                format "X(1)" space(0)
    string(v-ord-qnty)            format "X(14)" space(0)
    sym9                format "X(1)" space(0)
    string(v-temp)                format "X(11)" space(0)
    sym10                format "X(1)" space(0)
    buf_gds-obj-prop.gdop-igt     format "X(19)" space(0)
    sym11               format "X(1)" space(0)
    v-ABC                         format "X(3)" space(0)
    sym12               format "X(1)" space(0)
    v-XYZ                         format "X(3)" space(0)
    sym13               format "X(1)" space(0)
      skip
  .

    num#col# = 1.
    num#str# = num#str# + 1.
    run macr_excel_char (buf_goods.gds-code  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char (buf_goods.artic  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char (buf_goods.gds-name  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char (buf_goods.unit-base  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_dec (v-price               , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_dec (v-qnty                , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_dec (v-min-qnty            , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_dec (v-ord-qnty            , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_dec (v-temp                , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char (buf_gds-obj-prop.gdop-igt, num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char (v-ABC                    , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char (v-XYZ                    , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .

  end.
end procedure. /* print-line */



procedure print-all-itog :
  /* Итоговые суммы */
   run prn-line in this-procedure .
end procedure. /* print-all-itog */


procedure PrintTitul :
  do  on error undo, return error return-value  :
  define variable cc as integer no-undo .
  define variable tt as integer no-undo .
  define variable pp as integer no-undo .

/* ---------------- Создание заголовка :--------------------------------------------------------------------------- */
PUT STREAM OutStream UNFORMATTED
space(1)
   ReportNAme skip
   "на объекте "  obj_clients.obj-name skip
   "по фирме "  buf_clients.obj-name skip
   "Дата составления " + cur-time-date()  skip
      .

  define variable i as integer no-undo .
  Repeat i = 1 to NUM-ENTRIES(ReportHeader,chr(10)) :
    PUT STREAM OutStream UNFORMATTED  Entry(i,ReportHeader,chr(10))  AT 1 format "X(90)" SKIP.
  End.


    num#str# = 1.
    num#col# = 1.
    run macr_excel_char ( Reportname , num#str# , num#col#   ) .
    num#str# = num#str# + 1.
    run macr_excel_char ( "на объекте " + CAPS( obj_clients.obj-name)   , num#str# , num#col#   ) .
    num#str# = num#str# + 1.
    run macr_excel_char ( "по фирме "   + CAPS( buf_clients.obj-name)   , num#str# , num#col#   ) .
    num#str# = num#str# + 1.

    run macr_excel_char ( ReportHeader , num#str# , num#col#   ) .
    num#str# = num#str# + 1.
    run macr_excel_char ("Дата составления " + cur-time-date()   , num#str# , num#col#   ) .

/* шапка */
    num#str# = num#str# + 1.
    run macr_excel_char ("Код"  , num#str# , num#col#   ) .    run macr_cell_size ( 10 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 2.
    run macr_excel_char ("Артикул"  , num#str# , num#col#   ) .    run macr_cell_size ( 16 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 3.
    run macr_excel_char ("Наименование"  , num#str# , num#col#   ) .  run macr_cell_size ( 30 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 4.
    run macr_excel_char ("Ед.Изм"  , num#str# , num#col#   ) . run macr_cell_size ( 7 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 5.
    run macr_excel_char ("Цена товара на объекте"  , num#str# , num#col#   ) . run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 6.
    run macr_excel_char ("Остаток товара на объекте"  , num#str# , num#col#   ) . run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 7.
    run macr_excel_char ("Минимальный остаток"  , num#str# , num#col#   ) . run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 8.
    run macr_excel_char ("Ожидается"  , num#str# , num#col#   ) . run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 9.
    run macr_excel_char ("Темп (ABC)"  , num#str# , num#col#   ) . run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 10.
    run macr_excel_char ("ИЖТ"  , num#str# , num#col#   ) . run macr_cell_size ( 24 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 11.
    run macr_excel_char ("ABC"  , num#str# , num#col#   ) . run macr_cell_size ( 4 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 12.
    run macr_excel_char ("XYZ"  , num#str# , num#col#   ) . run macr_cell_size ( 4 , ? , num#str# , num#col# , ?, ? ) .

  run print-1 in this-procedure .


    run macr_cell_format in this-procedure
    ( 10    ,            /* p-size     */
      true  ,            /* p-bold     */
      false  ,           /* p-italic   */
      ?    ,             /* p-color-bg */
      1 ,                /* p-row      */
      1 ,                /* p-col      */
      num#str# ,         /* p-row-2    */
      num#col# ) .       /* p-col-2    */

     put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , num#str# , 1 , num#str# ,  num#col# ) + {&new-line}  +
       'BORDER( 2 , 2 , 2 , 2 , 2 , ,0,0,0,0,0) '  + {&new-line} +
       'ALIGNMENT(3 , , 4 , 4 ,)'  + {&new-line}
       .
    put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , num#str# , 1 , num#str# ,  3 ) + {&new-line}  +
       'BORDER( 2, , , , , , , , , , ) '  + {&new-line} .

    /* ... конец создания заголовка. --- */
  end.
end procedure. /* PrintTitul */


procedure PrintPodval :
  do on error undo, return error return-value  :
  define variable pp as integer no-undo .
  define variable rr as integer no-undo .


    /* ... конец создания Подвал. --- */
  end.
end procedure. /* PrintPodval */



PROCEDURE on-same-page :
  define input parameter p-line-number as integer  no-undo .
  if p-line-number > page-size( OutStream ) then return .
  if line-counter( OutStream ) + p-line-number > page-size( OutStream ) then  page stream OutStream .
end procedure. /* on-same-page */

procedure print-1 :
/* шапка на экран */
  do
  on error undo, return error return-value
  :
    run prn-line in this-procedure .

    PUT STREAM OutStream UNFORMATTED  ":Код"  AT 1 format "X(11)" .
    PUT STREAM OutStream UNFORMATTED  ":Артикул"       format "X(17)" .
    PUT STREAM OutStream UNFORMATTED  ":Наименование"  format "X(31)" .
    PUT STREAM OutStream UNFORMATTED  ":Е.И"           format "X(4)" .
    PUT STREAM OutStream UNFORMATTED ":Цена товара"    format "X(15)" .
    PUT STREAM OutStream UNFORMATTED ":Остаток"        format "X(15)" .
    PUT STREAM OutStream UNFORMATTED ":Мин.остаток"    format "X(15)" .
    PUT STREAM OutStream UNFORMATTED ":Ожидается"      format "X(15)" .
    PUT STREAM OutStream UNFORMATTED ":Темп (ABC)"    format "X(12)" .
    PUT STREAM OutStream UNFORMATTED ":ИЖТ"            format "X(20)" .
    PUT STREAM OutStream UNFORMATTED ":ABC"            format "X(4)" .
    PUT STREAM OutStream UNFORMATTED ":XYZ:"           format "X(5)" .


    PUT STREAM OutStream UNFORMATTED  skip .
    run prn-line in this-procedure .

  end.

end procedure. /* print-1 */
procedure prn-line :

  do
  on error undo, return error return-value
  :
    PUT STREAM OutStream UNFORMATTED  fill("-",11)  AT 1 format "X(11)" .
    PUT STREAM OutStream UNFORMATTED  fill("-",17)  format "X(17)" .
    PUT STREAM OutStream UNFORMATTED  fill("-",31)  format "X(31)" .
    PUT STREAM OutStream UNFORMATTED  fill("-",4)   format "X(4)" .
    PUT STREAM OutStream UNFORMATTED  fill("-",15)  format "X(15)" .
    PUT STREAM OutStream UNFORMATTED  fill("-",15)  format "X(15)" .
    PUT STREAM OutStream UNFORMATTED  fill("-",15)  format "X(15)" .
    PUT STREAM OutStream UNFORMATTED  fill("-",15)  format "X(15)" .
    PUT STREAM OutStream UNFORMATTED  fill("-",12)  format "X(12)" .
    PUT STREAM OutStream UNFORMATTED  fill("-",20)  format "X(20)" .
    PUT STREAM OutStream UNFORMATTED  fill("-",4)  format "X(4)" .
    PUT STREAM OutStream UNFORMATTED  fill("-",5)   format "X(5)" .



    PUT STREAM OutStream UNFORMATTED  skip .

  end.
end procedure. /* prn-line */

procedure def-order :
define input  parameter p-obj-type  as character no-undo .
define input  parameter p-obj-code  as integer   no-undo .
define input  parameter p-artic     as char   no-undo .
define input  parameter p-prod-type as character no-undo .
define input  parameter p-prod-code as integer   no-undo .
define output parameter v-qnty       as decimal   no-undo .

  do
  on error undo, return error return-value
  :

define buffer buf-ord-line for ub.ord-line.
define buffer buf-ord-doc  for ub.ord-doc.


      for each buf-ord-line no-lock where
              buf-ord-line.artic              =   p-artic     and
              buf-ord-line.prod-type          =   p-prod-type and
              buf-ord-line.prod-code          =   p-prod-code and
              buf-ord-line.obj-type          =   p-obj-type and
              buf-ord-line.obj-code          =   p-obj-code
              ,
          first buf-ord-doc no-lock where
                buf-ord-doc.doc-code          =   buf-ord-line.doc-code and
                buf-ord-doc.status_           <>   {&fact}    and
                buf-ord-doc.status_           <>   {&g___new}
                :
                  v-qnty =  v-qnty + buf-ord-line.qnty .
      end.
  end.

end procedure. /* def-order */

{ rep/r-libmcr.i macr_excel         }