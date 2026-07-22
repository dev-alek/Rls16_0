block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-op10.p $
$Archive: rep/r-op10.p $

О РЕАЛИЗАЦИИ И ОТПУСКЕ ИЗДЕЛИЙ КУХНИ

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 11/21/03 10:59

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-op10.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-op10.p $":U .
define variable vss-description as character no-undo init "О РЕАЛИЗАЦИИ И ОТПУСКЕ ИЗДЕЛИЙ КУХНИ ОП-10".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i   }
{ cmp/r-page1.i  }
{ cmp/breakstr.i }
{ rep/r-cliprp.i def }
{ gbl/paramls.i  }
{ rep/f-fdec.i   }
{ trg/factord.i  }
{ str/clcprtsl.i }
{ rep/rep-bt.i   }
{ rep/lkp-font.i }

 do
 on error undo, return error return-value
 :

define variable   sort-name   as logical no-undo.
define variable   sort-gr     as logical no-undo.
define variable   print-graft as logical no-undo.   /* "Отладочная печать" */
define variable   summ as decimal no-undo .
define buffer     buf_obj-list for obj-list .
define variable   fact-order-1 as decimal no-undo .
define variable   fact-order-2 as decimal no-undo .

sort-gr     = true  .
sort-name   = false .
print-graft = true  .



define variable sort-group as logical   no-undo .
if sort-gr                  then assign sort-group = yes .
else                             assign sort-group = no .


define variable name-raz as character no-undo .
define variable temp-doc-code  as character no-undo .
define variable temp-sum-fact  as decimal   no-undo .
define variable temp-fact-date as date      no-undo .
define variable temp-sum-cost  as decimal   no-undo .

define variable sum-crsa  as decimal   no-undo .
define variable sum-cost  as decimal   no-undo .


define temp-table temp-str no-undo
field nkk          as char format "X ( 8)"
field gds-name     as char format "X ( 25)"
field gds-code     as integer  format ">>>>>>>>9"
field artic         as character
field prod-type     as character
field prod-code     as int
field price-crsa   as decimal  format ">>>>9.99"
field qnty-nal     as decimal  format ">>>>>9.<<<"
field sum-nal      as decimal  format ">>>>>9.99"
field qnty-buf     as decimal  format ">>>>>9.<<<"
field sum-buf      as decimal  format ">>>>>9.99"
field qnty-or      as decimal  format ">>>>>9.<<<"
field sum-or       as decimal  format ">>>>>9.99"
field qnty-all     as decimal  format ">>>>>9.<<<"
field sum-all      as decimal  format ">>>>>9.99"
field qnty-z       as decimal  format ">>>>>9.<<<"
field sum-z        as decimal  format ">>>>>9.99"
field price-cost   as decimal  format ">>>>>9.99"
field sum-cost     as decimal  format ">>>>>9.99"
index pi  gds-code  nkk
.


define stream  OutStream  .
define stream  macr_excel .

define variable v-file-name as character no-undo .
define variable v-ind       as integer   no-undo .
define variable num#col#    as integer no-undo .
define variable C-c    as integer no-undo .
define variable C-str  as character no-undo .
define variable str--1 as character Format "x ( 60)" no-undo.
define variable str--2 as integer no-undo .
define variable C-i    as integer no-undo .
define variable p-var  as integer no-undo .
define variable var-1  as integer no-undo .
define variable var-2  as integer no-undo .
define variable n-recipe-code  as character no-undo .
define variable n-porc as integer no-undo .
define variable num-re as character no-undo .
define variable qnt-delta as decimal no-undo .

def buffer buf_clients for  clients .
def buffer This_Object for  clients .

define variable qnty as decimal   no-undo .
define variable sum  as decimal   no-undo .

define variable crsa-rubl-start    as decimal no-undo .
define variable crsa-base-start    as decimal no-undo .
define variable cost-rubl-start    as decimal no-undo .
define variable cost-base-start    as decimal no-undo .
define variable crsa-rubl-end      as decimal no-undo .
define variable crsa-base-end      as decimal no-undo .
define variable cost-rubl-end      as decimal no-undo .
define variable cost-base-end      as decimal no-undo .

define variable num-ln as integer   no-undo .

define variable FullNameGds as character no-undo .
define variable gds-str as char no-undo.
define variable gds-str1 as char no-undo.
define variable gds-str2 as char no-undo.
define variable i as integer no-undo.
define variable j as integer no-undo.
define variable Counter1 as integer init 0  no-undo .

define variable LineBuf       as char    no-undo.
define variable Line       as char    no-undo.
define variable UndLine    as char    no-undo.

define variable     Lines_Counter as   integer  init 0  no-undo.
define variable     Tmp_Counter   as   integer  init 0  no-undo.

define variable     tdoc-date     like fbr-pln.doc-date no-undo.
define variable     tdoc-code     like fbr-pln.doc-code no-undo.

define variable  abbr              as  char no-undo.
define variable  pp-a              as  char no-undo.
define variable vv0 as character no-undo .
define variable vv1 as character no-undo .
define variable vv2 as character no-undo .
define variable vv3 as character no-undo .
define variable vv4 as character no-undo .
define variable vv5 as character no-undo .
define variable vv6 as character no-undo .
define variable vv7 as character no-undo .
define variable vv8 as character no-undo .
define variable vv9 as character no-undo .
define variable vv10 as character no-undo .


{ rep/r-sym.i }


define variable t-1 as character no-undo .
define variable t-2 as character no-undo .
define variable t-3 as character no-undo .
define variable t-4 as character no-undo .
define variable t-5 as character no-undo .

DEFINE FRAME plan-menu
    sym1                format "X ( 1)"        space ( 0)
    temp-str.nkk        format "X ( 8)"        space ( 0)
    sym2                format "X ( 1)"        space ( 0)
    temp-str.gds-name   format "X ( 25)"       space ( 0)
    Sym3                format "X ( 1)"        space ( 0)
    temp-str.gds-code   format ">>>>>>>>9"   space ( 0)
    Sym4                format "X ( 1)"        space ( 0)
    temp-str.price-crsa format ">>>>9.99"    space ( 0)
    Sym5                format "X ( 1)"        space ( 0)
    temp-str.qnty-nal   format ">>>>9.<<<"   space ( 0)
    Sym6                format "X ( 1)"        space ( 0)
    temp-str.sum-nal    format ">>>>>9.99"   space ( 0)
    Sym7                format "X ( 1)"        space ( 0)
    temp-str.qnty-buf   format ">>>>9.99"    space ( 0)
    Sym8                format "X ( 1)"        space ( 0)
    temp-str.sum-buf    format ">>>>>9.99"   space ( 0)
    Sym9                format "X ( 1)"        space ( 0)
    temp-str.qnty-or    format ">>>>9.99"    space ( 0)
    Sym10               format "X ( 1)"        space ( 0)
    temp-str.sum-or     format ">>>>>9.99"   space ( 0)
    Sym11               format "X ( 1)"        space ( 0)
    temp-str.qnty-z     format ">>>>9.99"    space ( 0)
    Sym12               format "X ( 1)"        space ( 0)
    temp-str.sum-z      format ">>>>>9.99"   space ( 0)
    Sym13               format "X ( 1)"        space ( 0)
    temp-str.qnty-all   format ">>>>9.99"    space ( 0)
    Sym14               format "X ( 1)"        space ( 0)
    temp-str.sum-all    format ">>>>>9.99"   space ( 0)
    Sym15               format "X ( 1)"        space ( 0)
    temp-str.price-cost format ">>>>>9.99"   space ( 0)
    Sym16               format "X ( 1)"        space ( 0)
    temp-str.sum-cost   format ">>>>>9.99"   space ( 0)
    Sym17               format "X ( 1)"        space ( 0)
  HEADER
    string (  "Лист " + string (  PAGE-NUMBER ( OutStream) , ">>>>9") ) AT 80 format "X ( 13)" SKIP
    Line format "X ( 180)" AT 1
    with width 180 down stream-io use-text NO-UNDERLINE  NO-BOX no-labels.

  if session:set-wait-state ( "compiler") then.

  { cmp/open-out.i STREAM OutStream " " ReportPageHeight }
  define variable v-prn0 as character no-undo .

  assign
    Line    = fill ( "-", 230)
    UndLine = fill ( "_", 230)
    LineBuf = fill ( "_", 240)
  .

define variable v-is-base as logical no-undo .
{ gbl/rbisbase.i    v-is-base  }

if v-is-base = true then do:
    assign    PP-a = "баз.вал" .
end.
else do:
   assign     PP-a = "{&abbr_rub}".
end.

{ rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
{ rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */

/*-----------------------------------------------------------------------------------------------------------------------*/
v-ind = 0    .



run factord-end-day in this-procedure  ( input x-date-alone , output fact-order-1 ) .

FORM with frame plan-menu .

for each buf_obj-list no-lock :

vv0 = "+--------+-----------------------------------+--------+-----------------------------------------------------------------------------------------------+------------------+" .
vv1 = ":   №    :            Готовое изделие        :  Цена  :                           Реализовано и отпущено по ценам продажи                             : По учетным ценам :" .
vv2 = ": Кальк. :-----------------------------------: продажи:-----------------------------------------------------------------------------------------------:                  :" .
vv3 = ":карточки:      Наименование       :  Код    :        :за наличный расчет:отпущено буфетам и :    работникам    :                  :      всего       :   производства   :" .
vv4 = ":   /    :                         :         :{&abbr_rub}.{&abbr_kop}." +
                                                            ":                  :мелкорозничной сети:    организации   :                  :                  :                  :" .
vv5 = ":рецепта :                         :         :        :------------------:-------------------:------------------:------------------:------------------:------------------:" .
vv6 = ":        :                         :         :        : кол-во :  сумма  : кол-во :  сумма   : кол-во :  сумма  : кол-во :  сумма  : кол-во :  сумма  : цена   :  сумма  :" .
vv7 = "+--------+-------------------------+---------+--------+--------+---------+--------+----------+--------+---------+--------+---------+--------+---------+--------+---------+" .
vv8 = ":   1    :             2           :    3    :   4    :   5    :   6     :    7   :    8     :    9   :   10    :   11   :   12    :   13   :   14    :   15   :   16    :" .
vv9 = "+--------+-------------------------+---------+--------+--------+---------+--------+----------+--------+---------+--------+---------+--------+---------+--------+---------+" .



 /* создаем временный файл */
    Output stream Macr_Excel  close .
    num#str# = 0 .
    run gbl/_tmpfile.p  (  "wb", ".txt", output v-file-name) .
    output stream macr_excel to value ( v-file-name)   .
    v-ind = v-ind + 1.

  find this_object  where this_object.obj-type = buf_obj-list.obj-type and this_object.obj-code = buf_obj-list.obj-code  no-lock .
  find clients      where clients.obj-type     = {&cmp}            and clients.obj-code      = v-cntxt-host-code-obj no-lock .
  run PrintTitul in this-procedure .
  /* по строкам документа-------------------------------------------------------------------------------------------- */
  /* сначала заполняем таблицу */
  for each temp-str
      on error undo, return error :
      delete temp-str .
  end. /* for each */

  run make-tt  in this-procedure .

    for each temp-str :
         run print-line in this-procedure .
    end. /* for each */

  run print-all-itog in this-procedure .
  /* ... Подвал. --- */
  run on-same-page in this-procedure  ( input 34) .
  run PrintPodval in this-procedure .
  run paramls-write in this-procedure
     ( input "file"
    ,input string ( v-ind) + buf_obj-list.obj-name
    ,input v-file-name
    ) .
     page stream OutStream .
  end.

HIDE STREAM OutStream FRAME plan-menu.
HIDE stream OutStream FRAME BottomFrame .
HIDE stream OutStream FRAME BottomFrame2 .
output stream OutStream CLOSE .
Output stream Macr_Excel  close .

{ rep/repfrm.i off } /* Показать окно информации о текущем процессе */

    run paramls-write in this-procedure
         ( input "charcol"
        ,input ""
        ,input "2"
        ) .


  run end-proc  in this-procedure .
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
    ,input  string ( session :temp-directory) + {&DF_Name} + string (  g#report-num )
    ,input  7
    ,output v-user-action
    ,output v-printed
    ) .

end.
/* *************************************************************************************************** */
procedure print-line :
  do on error undo, return error return-value :
  assign
     Lines_Counter = Lines_Counter + 1
    .

  if line-counter (  OutStream ) + 2 > page-size (  OutStream ) then page stream OutStream.

  if line-counter (  OutStream ) < Tmp_Counter then
    assign
    .

  assign
    Tmp_Counter  = line-counter (  OutStream )
    num-ln = num-ln + 1
  .

  if line-counter (  OutStream ) + j > page-size (  OutStream ) then  PAGE STREAM OutStream.

PUT STREAM OutStream UNFORMATTED
    sym1                format "X ( 1)"     space ( 0)
    temp-str.nkk        format "X ( 8)"     space ( 0)
    sym2                format "X ( 1)"     space ( 0)
    temp-str.gds-name   format "X ( 25)"    space ( 0)
    Sym3                format "X ( 1)"     space ( 0)
    temp-str.gds-code   format ">>>>>>>>9"    space ( 0)
    Sym4                format "X ( 1)"     space ( 0)
    string ( temp-str.price-crsa ,">>>>9.99") format "x ( 8)" space ( 0)
    Sym5                format "X ( 1)"    space ( 0)
     (  string ( temp-str.qnty-nal ))  format "x ( 8)" space ( 0)
    Sym6                format "X ( 1)"       space ( 0)
    string ( temp-str.sum-nal,">>>>>9.99" )   format  "x ( 9)"  space ( 0)
    Sym7                format "X ( 1)"    space ( 0)
    trim ( string ( temp-str.qnty-buf))  format  "x ( 8)"         space ( 0)
    Sym8                format "X ( 1)" space ( 0)
    string ( temp-str.sum-buf  ,   ">>>>>9.99")  format  "x ( 10)"  space ( 0)
    Sym9                format "X ( 1)"    space ( 0)
    trim ( string ( temp-str.qnty-or  ,  ">>>>9.<<<")  )  format  "x ( 8)"    space ( 0)
    Sym10               format "X ( 1)" space ( 0)
    string ( temp-str.sum-or  ,    ">>>>>9.99")  format  "x ( 9)"  space ( 0)
    Sym11               format "X ( 1)"    space ( 0)
    trim ( string ( temp-str.qnty-z  ,    ">>>>>.<<<") )  format  "x ( 8)"     space ( 0)
    Sym12               format "X ( 1)" space ( 0)
    string ( temp-str.sum-z   ,    ">>>>>>.<<")  format  "x ( 9)"  space ( 0)
    Sym13               format "X ( 1)"    space ( 0)
    trim ( string ( temp-str.qnty-all,    ">>>>9.<<<" ))  format  "x ( 8)"     space ( 0)
    Sym14               format "X ( 1)" space ( 0)
    string ( temp-str.sum-all ,    ">>>>>9.99")  format  "x ( 9)"  space ( 0)
    Sym15               format "X ( 1)"    space ( 0)
    string ( temp-str.price-cost,  ">>>>>9.99")  format  "x ( 8)"      space ( 0)
    Sym16               format "X ( 1)" space ( 0)
    string ( temp-str.sum-cost  ,  ">>>>>9.99")  format  "x ( 9)"  space ( 0)
    Sym17               format "X ( 1)" space ( 0)
    skip
.
    num#col# = 1.
    num#str# = num#str# + 1.
run macr_excel_char in this-procedure  (  temp-str.nkk       , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char in this-procedure  (  temp-str.gds-name  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char in this-procedure  (  temp-str.gds-code  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure   (  temp-str.price-crsa, num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure   (  temp-str.qnty-nal   , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure   (  temp-str.sum-nal    , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure   (  temp-str.qnty-buf   , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure   (  temp-str.sum-buf    , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure   (  temp-str.qnty-or    , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure   (  temp-str.sum-or     , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure   (  temp-str.qnty-z     , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure   (  temp-str.sum-z      , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure   (  temp-str.qnty-all   , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure   (  temp-str.sum-all    , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure   (  temp-str.price-cost , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure   (  temp-str.sum-cost   , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
  end.
end procedure. /* print-line */



procedure print-all-itog :
  /* Итоговые суммы */
end procedure. /* print-all-itog */


procedure PrintTitul :
  do  on error undo, return error return-value  :
  define variable cc as integer no-undo .
  define variable tt as integer no-undo .
  define variable pp as integer no-undo .

/* ---------------- Создание заголовка :--------------------------------------------------------------------------- */
/* { rep/r-cliprp.i } */
PUT STREAM OutStream UNFORMATTED
space ( 1) string (  "Унифицированная форма № ОП-10" )                                            "+--------------------------+" at 130  skip
                                                                                              "|                  | Коды  |" at 130  skip
space ( 1) string (  CAPS (      clients.obj-name ))                                                "|    Форма по ОКУД |0330510|" at 130  skip
space ( 1) string (  CAPS (  This_Object.obj-name ) + "  ( " + string ( This_Object.obj-code) + ")" )   "|          по ОКПО |       |" at 130  skip
                                                                                              "| Вид деятельности |       |" at 130  skip
space ( 1)                                                                                      "|          по ОКДП |       |" at 130  skip
                                                                                              "|     Вид операции |       |" at 130  skip
                                                                                              "+--------------------------+" at 130  skip
                                                                                              .

PUT STREAM OutStream
space ( 35) "                                                                                           УТВЕРЖДАЮ                         " skip
space ( 35) "                                                                                           Руководитель                      " skip
space ( 35) "                                                                                           ________________________________  " skip
space ( 35) "               АКТ                                                                                     ( должность)            " skip
space ( 35) "                                                                                           __________ _____________________  " skip
space ( 35) "  О РЕАЛИЗАЦИИ И ОТПУСКЕ ИЗДЕЛИЙ КУХНИ                                                      ( подпись)   ( расшифровка подписи)  " skip
space ( 35) "       на "   + string ( x-date-alone, "99/99/9999" )  format "x ( 20)"                      " «____» ______________________ г.  " at 125 skip
space ( 35) "Дата составления " + cur-time-date ( )  format "x ( 30)"  at 89  skip
.

PUT STREAM OutStream UNFORMATTED
" " skip
space ( 0) string (  "Комиссия установила:" ) skip
  .

    run macr_cell_size in this-procedure   (  15 , ? , 1 , 11 , 6, 11 ) .
    run macr_cell_format in this-procedure
     (  8       ,   /* p-size     */
      false   ,   /* p-bold     */
      false   ,   /* p-italic   */
      ?       ,   /* p-color-bg */
      1  ,        /* p-row      */
      11 ,        /* p-col      */
      6  ,        /* p-row-2    */
      12 ) .      /* p-col-2    */

    num#str# = 1.
    num#col# = 1.
    run macr_excel_char in this-procedure  (  "Унифицированная форма № ОП-10" , num#str# , num#col#   ) .
    num#col# = 12.
    run macr_excel_char in this-procedure  (  "Коды" , num#str# , num#col#   ) .
    num#str# = 2.
    num#col# = 11.
    run macr_excel_char in this-procedure  (  "Форма по ОКУД" , num#str# , num#col#   ) .
    num#col# = 12.
    run macr_excel_char in this-procedure  (  "0330510" , num#str# , num#col#   ) .
    num#str# = 3.
    num#col# = 11.
    run macr_excel_char in this-procedure  (  "по ОКПО" , num#str# , num#col#   ) .
    num#str# = 4.
    num#col# = 11.
    run macr_excel_char in this-procedure  (  "Вид деятельности по ОКДП" , num#str# , num#col#   ) .
    num#str# = 5.
    num#col# = 11.
    run macr_excel_char in this-procedure  (  "Вид операции" , num#str# , num#col#   ) .

    put  stream macr_excel unformatted
    substitute ( 'select ( "r&1c&2:r&3c&4 ")' , 1 , 11 , 6 ,  11 ) + {&new-line}  +
    'ALIGNMENT ( 4 , , 4 , 4 ,)'  + {&new-line}
    .
    put  stream macr_excel unformatted
    substitute ( 'select ( "r&1c&2:r&3c&4 ")' , 1 , 12 , 6 ,  12 ) + {&new-line}  +
    'BORDER (  2 , 2 , 2 , 2 , 2 , ,0,0,0,0,0) '  + {&new-line}
    .
    num#str# = 3.
    num#col# = 1.
    cc = num#str# .

    run macr_excel_char in this-procedure  (  "             АКТ"                     , num#str# , num#col#   ) . num#str# = num#str# + 1.
    run macr_excel_char in this-procedure  (  "О РЕАЛИЗАЦИИ И ОТПУСКЕ ИЗДЕЛИЙ КУХНИ" , num#str# , num#col#   ) . num#str# = num#str# + 1.
    run macr_excel_char in this-procedure  (  "       на "   + string ( x-date-alone, "99/99/9999" )      , num#str# , num#col#   ) . num#str# = num#str# + 1.
    num#str# = num#str# + 2.
    num#col# = 2.
    run macr_excel_char in this-procedure  (   CAPS (  clients.obj-name)   , num#str# , num#col#   ) .
    num#str# = num#str# + 1.
    num#col# = 2.
    run macr_excel_char in this-procedure  (  string (  CAPS (  This_Object.obj-name ) + "  ( " + string ( This_Object.obj-code) + ")" )   , num#str# , num#col#   ) .

    run macr_cell_format in this-procedure
     (  20    ,    /* p-size     */
      true  ,    /* p-bold     */
      false  ,   /* p-italic   */
      ?    ,     /* p-color-bg */
      cc ,       /* p-row      */
      1 ,        /* p-col      */
      num#str# , /* p-row-2    */
      2 ) .      /* p-col-2    */

    num#str# = num#str# + 2.
    num#col# = 1.

    num#col# = 2.
    run macr_excel_char in this-procedure  (  "Комиссия установила: ", num#str# , num#col#   ) .
    num#str# = num#str# + 1.
    num#col# = 11.
    run macr_excel_char in this-procedure  ( "Дата составления " + cur-time-date ( )   , num#str# , num#col#   ) .

/* шапка */
PUT STREAM OutStream
  vv0 format "x ( 180)" skip
  vv1 format "x ( 180)"  skip
  vv2 format "x ( 180)"  skip
  vv3 format "x ( 180)"  skip
  vv4 format "x ( 180)"  skip
  vv5 format "x ( 180)"  skip
  vv6 format "x ( 180)"  skip
  vv7 format "x ( 180)"  skip
  vv8 format "x ( 180)"  skip
  vv9 format "x ( 180)"  skip
  .

define variable v-red   as integer no-undo .
define variable v-green as integer no-undo .
define variable v-blue  as integer no-undo .
v-red   = 16.
v-green = 48.
v-blue  = 15.

    num#str# = num#str# + 1.
    num#col# = 1.
     run macr_cell_size in this-procedure   (  21 , ? , num#str# , num#col# , ?, ? ) .
    pp = num#str#  .
    tt = num#str# + 2 .
    num#col# = 1.
    run macr_excel_char in this-procedure  (  "N карточки / рецепт, " + pp-a   , num#str# , num#col#   ) .
    run macr_cell_size in this-procedure  (  16 , ? , num#str# , num#col# , ?, ? ) .
    run fill-color in this-procedure   ( v-red , num#col#, pp , num#col# , tt ) .
    run macr_excel_char in this-procedure  (  "."   , num#str# + 1 , num#col#   ) .
    run fill-color in this-procedure   ( v-red , num#col# , pp + 1 , num#col# , pp + 1 ) .
    run macr_excel_char in this-procedure  (  "."   , num#str# + 2 , num#col#   ) .
    run fill-color in this-procedure   ( v-red , num#col# , pp + 2 , num#col# , pp + 2 ) .


    num#col# = 2.
    run macr_excel_char in this-procedure  (  "Готовое изделие"   , num#str# , num#col#   ) .
    run fill-color in this-procedure   ( v-blue , num#col#, pp , num#col# + 1 , pp ) .
    run macr_cell_size in this-procedure   (  40 , ? , num#str# , num#col# , ?, ? ) .

    run macr_excel_char in this-procedure  (  "Наименование"   , num#str# + 1 , num#col#   ) .
    run fill-color in this-procedure   ( v-green , num#col# , pp + 1 , num#col# , pp + 1 ) .
    run macr_excel_char in this-procedure  (  "."   , num#str# + 2 , num#col#   ) .
    run fill-color in this-procedure   ( v-green , num#col# , pp + 2 , num#col# , pp + 2 ) .


    num#col# = 3.
    run macr_excel_char in this-procedure  (  "Код"   , num#str# + 1 , num#col#   ) .
    run fill-color in this-procedure   ( v-red , num#col# , pp + 1 , num#col# , pp + 2 ) .
    run macr_cell_size in this-procedure   (  10 , ? , num#str# , num#col# , ?, ? ) .

    num#col# = 4.
    run macr_excel_char in this-procedure  (  "Цена продажи, " + pp-a   , num#str# , num#col#   ) .
    run fill-color in this-procedure   ( v-green , num#col#, pp , num#col# , tt ) .
    run macr_excel_char in this-procedure  (  "."   , num#str# + 1 , num#col#   ) .
    run fill-color in this-procedure   ( v-green , num#col# , pp + 1 , num#col# , pp + 1 ) .
    run macr_excel_char in this-procedure  (  "."   , num#str# + 2 , num#col#   ) .
    run fill-color in this-procedure   ( v-green , num#col# , pp + 2 , num#col# , pp + 2 ) .


    num#col# = 5.
    run macr_excel_char in this-procedure  (  "Реализовано и отпущено по ценам продажи"   , num#str# , num#col#   ) .
    run fill-color in this-procedure   ( v-blue , num#col#, pp , num#col# + 9 , pp ) .

    run macr_excel_char in this-procedure  (  "за наличный расчет"   , num#str# + 1, num#col#   ) .
    run fill-color in this-procedure   ( v-red , num#col#, pp + 1, num#col# + 1 , pp + 1 ) .

    run macr_excel_char in this-procedure  (  "количество"   , num#str# + 2, num#col#   ) .
    run fill-color in this-procedure   ( v-blue , num#col#, pp + 2, num#col# , pp + 2 ) .

    num#col# = 6.
    run macr_excel_char in this-procedure  (  "сумма"   , num#str# + 2, num#col#   ) .
    run fill-color in this-procedure   ( v-green , num#col#, pp + 2, num#col# , pp + 2 ) .


    num#col# = 7.
    run macr_excel_char in this-procedure  (  "Отпущено буфетами и мелкорозничной сети"   , num#str# + 1, num#col#   ) .
    run fill-color in this-procedure   ( v-green , num#col#, pp + 1, num#col# + 1 , pp + 1 ) .

    run macr_excel_char in this-procedure  (  "количество"   , num#str# + 2, num#col#   ) .
    run fill-color in this-procedure   ( v-blue , num#col#, pp + 2, num#col# , pp + 2 ) .

    num#col# = 8.
    run macr_excel_char in this-procedure  (  "сумма"   , num#str# + 2, num#col#   ) .
    run fill-color in this-procedure   ( v-red , num#col#, pp + 2, num#col# , pp + 2 ) .

    num#col# = 9.
    run macr_excel_char in this-procedure  (  "работникам организации"   , num#str# + 1, num#col#   ) .
    run fill-color in this-procedure   ( v-red , num#col#, pp + 1, num#col# + 1 , pp + 1 ) .

    run macr_excel_char in this-procedure  (  "количество"   , num#str# + 2, num#col#   ) .
    run fill-color in this-procedure   ( v-green , num#col#, pp + 2, num#col# , pp + 2 ) .

    num#col# = 10.
    run macr_excel_char in this-procedure  (  "сумма"   , num#str# + 2, num#col#   ) .
    run fill-color  ( v-blue , num#col#, pp + 2, num#col# , pp + 2 ) .

    num#col# = 11.
    run macr_excel_char (  "."   , num#str# + 1, num#col#   ) .
    run fill-color  ( v-green , num#col#, pp + 1, num#col# + 1 , pp + 1 ) .

    run macr_excel_char (  "количество"   , num#str# + 2, num#col#   ) .
    run fill-color  ( v-red , num#col#, pp + 2, num#col# , pp + 2 ) .

    num#col# = 12.
    run macr_excel_char (  "сумма"   , num#str# + 2, num#col#   ) .
    run fill-color  ( v-blue , num#col#, pp + 2, num#col# , pp + 2 ) .

    num#col# = 13.
    run macr_excel_char (  "всего"   , num#str# + 1, num#col#   ) .
    run fill-color  ( v-red , num#col#, pp + 1, num#col# + 1 , pp + 1 ) .

    run macr_excel_char (  "количество"   , num#str# + 2, num#col#   ) .
    run fill-color  ( v-green , num#col#, pp + 2, num#col# , pp + 2 ) .

    num#col# = 14.
    run macr_excel_char (  "сумма"   , num#str# + 2, num#col#   ) .
    run fill-color  ( v-blue , num#col#, pp + 2, num#col# , pp + 2 ) .

    num#col# = 15.
    run macr_excel_char (  "По учетным ценам производства"   , num#str# , num#col#   ) .
    run fill-color  ( v-green , num#col#, pp , num#col# + 1 , pp + 1 ) .
    run macr_excel_char (  "."   , num#str# + 1 , num#col#   ) .
    run fill-color  ( v-green , num#col# , pp + 1 , num#col# , pp + 1 ) .

    run macr_excel_char (  "цена"   , num#str# + 2, num#col#   ) .
    run fill-color  ( v-red , num#col#, pp + 2, num#col# , pp + 2 ) .

    num#col# = 16.
    run macr_excel_char (  "сумма"   , num#str# + 2, num#col#   ) .
    run fill-color  ( v-blue , num#col#, pp + 2, num#col# , pp + 2 ) .

    /*
    run macr_cell_format
     (  10    ,    /* p-size     */
      true  ,    /* p-bold     */
      false  ,   /* p-italic   */
      ?    ,     /* p-color-bg */
      pp ,         /* p-row      */
      1  ,        /* p-col      */
      tt    , /* p-row-2    */
      num#col# ) .      /* p-col-2    */
      */

    /*
     put  stream macr_excel unformatted
       substitute ( 'select ( "r&1c&2:r&3c&4 ")' , tt , 1 , num#str# ,  num#col# ) + {&new-line}  +
       'BORDER (  2 , 2 , 2 , 2 , 2 , ,0,0,0,0,0) '  + {&new-line} +
       'ALIGNMENT ( 3 , , 4 , 4 ,)'  + {&new-line}
       .
    put  stream macr_excel unformatted
       substitute ( 'select ( "r&1c&2:r&3c&4 ")' , pp , 1 , pp ,  3 ) + {&new-line}  +
       'BORDER (  2, , , , , , , , , , ) '  + {&new-line} .
      */

   num#str# = num#str# + 2 .
    /* ... конец создания заголовка. --- */


  end.
end procedure. /* PrintTitul */


procedure PrintPodval :
  do on error undo, return error return-value  :
  define variable pp as integer no-undo .
  define variable rr as integer no-undo .

num#str# = num#str# + 2. num#col# = 1.

run macr_excel_char ( "Получено за приготовление блюд из продуктов посетителей   ________________________________________________________________________________      "   , num#str# , num#col#   ) . num#str# = num#str# + 1.
run macr_excel_char ( "                                                                             ( прописью)                                                          "   , num#str# , num#col#   ) . num#str# = num#str# + 1.
run macr_excel_char ( " __________________________________________________________________________________________________________  {&abbr_rub}. ____ {&abbr_kop}.                     "   , num#str# , num#col#   ) . num#str# = num#str# + 1.
run macr_excel_char ( "Итого реализовано, отпущено и оказано услуг за отчетный день ______________________________________________  {&abbr_rub}. ____ {&abbr_kop}.                     "   , num#str# , num#col#   ) . num#str# = num#str# + 1.
run macr_excel_char ( "                                                                             ( прописью)                                                          "   , num#str# , num#col#   ) . num#str# = num#str# + 1.
run macr_excel_char ( "СПРАВКА: Израсходовано на приготовление блюд                                                                                                    "   , num#str# , num#col#   ) . num#str# = num#str# + 1.
run macr_excel_char ( "         специй ______  % к обороту на сумму _________  {&abbr_rub}. _____  {&abbr_kop}.                                                                        "   , num#str# , num#col#   ) . num#str# = num#str# + 1.
run macr_excel_char ( "                                              ( цифрами)                                                                                          "   , num#str# , num#col#   ) . num#str# = num#str# + 1.
run macr_excel_char ( "         соли ________  % к обороту на сумму _________  {&abbr_rub}. _____  {&abbr_kop}.                                                                        "   , num#str# , num#col#   ) . num#str# = num#str# + 1.
run macr_excel_char ( "                                              ( цифрами)                                                                                          "   , num#str# , num#col#   ) . num#str# = num#str# + 1.
run macr_excel_char ( "                                       Итого _________  {&abbr_rub}. _____  {&abbr_kop}.                                                                        "   , num#str# , num#col#   ) . num#str# = num#str# + 1.
run macr_excel_char ( "                                              ( цифрами)                                                                                          "   , num#str# , num#col#   ) . num#str# = num#str# + 1.
run macr_excel_char ( "Члены комиссии:                                                                                                                                 "   , num#str# , num#col#   ) . num#str# = num#str# + 1.
run macr_excel_char ( "Заведующий производством _____________________    ___________________________________                                                           "   , num#str# , num#col#   ) . num#str# = num#str# + 1.
run macr_excel_char ( "                              ( подпись)                    ( расшифровка подписи)                                                                  "   , num#str# , num#col#   ) . num#str# = num#str# + 1.
run macr_excel_char ( "Марочница                _____________________    ___________________________________                                                           "   , num#str# , num#col#   ) . num#str# = num#str# + 1.
run macr_excel_char ( "                              ( подпись)                    ( расшифровка подписи)                                                                  "   , num#str# , num#col#   ) . num#str# = num#str# + 1.
run macr_excel_char ( "_____________________    _____________________    ___________________________________                                                           "   , num#str# , num#col#   ) . num#str# = num#str# + 1.
run macr_excel_char ( "    ( должность)                ( подпись)                    ( расшифровка подписи)                                                                  "   , num#str# , num#col#   ) . num#str# = num#str# + 1.
run macr_excel_char ( "                                                                                                                                                "   , num#str# , num#col#   ) . num#str# = num#str# + 1.
run macr_excel_char ( "Выручка кассы _____________________________________________________________________________________________  {&abbr_rub}. ____ {&abbr_kop}.                     "   , num#str# , num#col#   ) . num#str# = num#str# + 1.
run macr_excel_char ( "                                       ( прописью)                                                                                                "   , num#str# , num#col#   ) . num#str# = num#str# + 1.
run macr_excel_char ( "Стоимость реализованных изделий, указанная в настоящем акте, соответствует кассовым чекам          Кассир___________ _____________________      "   , num#str# , num#col#   ) . num#str# = num#str# + 1.
run macr_excel_char ( "ПРИЛОЖЕНИЕ:                                                                                                ( подпись)   ( расшифровка подписи)      "   , num#str# , num#col#   ) . num#str# = num#str# + 1.
run macr_excel_char ( "Накладные №№ ______________________________________   Сумма реализованного наложения за день ______________  {&abbr_rub}. ___  {&abbr_kop}.                     "   , num#str# , num#col#   ) . num#str# = num#str# + 1.
run macr_excel_char ( "                                                                                                 ( цифрами)                                       "   , num#str# , num#col#   ) . num#str# = num#str# + 1.
run macr_excel_char ( "Заборные листы №№ _________________________________                                                                                             "   , num#str# , num#col#   ) . num#str# = num#str# + 1.
run macr_excel_char ( "                                                                                                                                                "   , num#str# , num#col#   ) . num#str# = num#str# + 1.
run macr_excel_char ( "Акт проверил бухгалтер _____________________    ___________________________________                                                             "   , num#str# , num#col#   ) . num#str# = num#str# + 1.
run macr_excel_char ( "                             ( подпись)               ( расшифровка подписи)                                                                        "   , num#str# , num#col#   ) . num#str# = num#str# + 1.


PUT  STREAM OutStream " "       skip
"Получено за приготовление блюд из продуктов посетителей   ________________________________________________________________________________     " skip
"                                                                             ( прописью)                                                         " skip
" __________________________________________________________________________________________________________  {&abbr_rub}. ____ {&abbr_kop}.                    " skip
"Итого реализовано, отпущено и оказано услуг за отчетный день ______________________________________________  {&abbr_rub}. ____ {&abbr_kop}.                    " skip
"                                                                             ( прописью)                                                         " skip
"СПРАВКА: Израсходовано на приготовление блюд                                                                                                   " skip
"         специй ______  % к обороту на сумму _________  {&abbr_rub}. _____  {&abbr_kop}.                                                                       " skip
"                                              ( цифрами)                                                                                         " skip
"         соли ________  % к обороту на сумму _________  {&abbr_rub}. _____  {&abbr_kop}.                                                                       " skip
"                                              ( цифрами)                                                                                         " skip
"                                       Итого _________  {&abbr_rub}. _____  {&abbr_kop}.                                                                       " skip
"                                              ( цифрами)                                                                                         " skip
"Члены комиссии:                                                                                                                                " skip
"Заведующий производством _____________________    ___________________________________                                                          " skip
"                              ( подпись)                    ( расшифровка подписи)                                                                 " skip
"Марочница                _____________________    ___________________________________                                                          " skip
"                              ( подпись)                    ( расшифровка подписи)                                                                 " skip
"_____________________    _____________________    ___________________________________                                                          " skip
"    ( должность)                ( подпись)                    ( расшифровка подписи)                                                                 " skip
"                                                                                                                                               " skip
"Выручка кассы _____________________________________________________________________________________________  {&abbr_rub}. ____ {&abbr_kop}.                    " skip
"                                       ( прописью)                                                                                               " skip
"Стоимость реализованных изделий, указанная в настоящем акте, соответствует кассовым чекам          Кассир___________ _____________________     " skip
"ПРИЛОЖЕНИЕ:                                                                                                ( подпись)   ( расшифровка подписи)     " skip
"Накладные №№ ______________________________________   Сумма реализованного наложения за день ______________  {&abbr_rub}. ___  {&abbr_kop}.                    " skip
"                                                                                                 ( цифрами)                                      " skip
"Заборные листы №№ _________________________________                                                                                            " skip
"                                                                                                                                               " skip
"Акт проверил бухгалтер _____________________    ___________________________________                                                            " skip
"                             ( подпись)               ( расшифровка подписи)                                                                       " skip
.


    /* ... конец создания Подвал. --- */
  end.
end procedure. /* PrintPodval */



PROCEDURE on-same-page :
  define input parameter p-line-number as integer  no-undo .
  if p-line-number > page-size (  OutStream ) then return .
  if line-counter (  OutStream ) + p-line-number > page-size (  OutStream ) then  page stream OutStream .
end procedure. /* on-same-page */




{ rep/r-libmcr.i macr_excel         }



procedure fill-color :
 do
 on error undo, return error substitute ( "&1 &2 &3", return-value, error-status:get-message ( 1), error-status:get-message ( 2))
 :
define input parameter p-color as integer no-undo .
define input parameter p-col as integer no-undo . /* колонка с  */
define input parameter p-row as integer no-undo . /* колонка по */
define input parameter p-col-2 as integer no-undo . /* колонка с  */
define input parameter p-row-2 as integer no-undo . /* колонка по */

   put  stream macr_excel unformatted
        substitute ( 'select ( "r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 ) + {&new-line} .
  /* put  stream macr_excel unformatted
        substitute ( 'patterns ( 1,,&1,true)', p-color ) + {&new-line}  .
   */
    put  stream macr_excel unformatted
       'ALIGNMENT ( 7 , , 4 , 4 ,)'  + {&new-line}
    .
    put  stream macr_excel unformatted
        'BORDER (  1     , 1    , 1   , 1   , 1    ,      ,0             ,0,0,0,0) '  + {&new-line}
      /* BORDER ( outline, left, right, top, bottom, shade, outline_color, left_color, right_color, top_color, bottom_color) */
    .


 end. /* do */
end procedure. /* fill-color */


procedure make-tt :
  do
  on error undo, return error return-value
  :
  define buffer buf_trn-doc for trn-doc.

  for each buf_trn-doc no-lock where
           buf_trn-doc.status_      = {&fact}                 and
           buf_trn-doc.internal     = false                   and
           buf_trn-doc.fact-date    = x-date-alone            and
            (
            buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass} or
            buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass} or
            buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} or
            buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} or
            buf_trn-doc.ext-doc-type = {&TDEDT_Inv} or
            buf_trn-doc.ext-doc-type = {&TDEDT_Peresort} or
            buf_trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh}  ) and
            buf_trn-doc.obj-type     = buf_obj-list.obj-type   and
            buf_trn-doc.obj-code     = buf_obj-list.obj-code
           on error undo, return error :
      run make-body  (  input buf_trn-doc.doc-code , input buf_trn-doc.ext-doc-type ) .
  end. /* for each */

  for each buf_trn-doc no-lock where
           buf_trn-doc.status_      = {&fact}                 and
           buf_trn-doc.internal     = true                    and
           buf_trn-doc.fact-date    = x-date-alone            and
           buf_trn-doc.ext-doc-type = {&TDEDT_Spi_Prvo}       and
           buf_trn-doc.obj-type     = buf_obj-list.obj-type   and
           buf_trn-doc.obj-code     = buf_obj-list.obj-code
           on error undo, return error :
      run make-body  (  input buf_trn-doc.doc-code , input buf_trn-doc.ext-doc-type ) .
  end. /* for each */

  end. /* do */
 end procedure. /* make-tt */



procedure make-body :
 do
 on error undo, return error substitute ( "&1 &2 &3", return-value, error-status:get-message ( 1), error-status:get-message ( 2))
 :

define input parameter par-doc-code as character no-undo .
define input parameter par-doc-type as character no-undo .

define buffer buf_doc-line for doc-line.
define buffer buf_goods for goods.
define buffer buf_recipe for recipe.
define buffer buf_gds-obj for gds-obj.
define buffer buf_fbr-gds-obj for fbr-gds-obj.
define variable v-nkk as character no-undo .

define variable v-cur-dn as character no-undo .
define variable v-cur-pr as decimal no-undo .
define variable v-cur-rt as decimal no-undo .
define variable v-cur-ex as decimal no-undo .
define variable v-bar-code like ub.bar-code.b-code no-undo .

    for each buf_doc-line no-lock
        where buf_doc-line.doc-code = par-doc-code
        on error undo, return error :
        find first temp-str where
              temp-str.artic     = buf_doc-line.artic and
              temp-str.prod-type = buf_doc-line.prod-type and
              temp-str.prod-code = buf_doc-line.prod-code no-error .

                if not available temp-str then do:
                    find first buf_goods no-lock where
                               buf_goods.artic     = buf_doc-line.artic and
                               buf_goods.prod-type = buf_doc-line.prod-type and
                               buf_goods.prod-code = buf_doc-line.prod-code
                               no-error .
                    find first buf_fbr-gds-obj no-lock where
                               buf_fbr-gds-obj.obj-type = buf_obj-list.obj-type and
                               buf_fbr-gds-obj.obj-code = buf_obj-list.obj-code and
                               buf_fbr-gds-obj.gds-code = buf_goods.gds-code    and
                                (  buf_fbr-gds-obj.is-menu = true                 or  /* Блюдо или ПФ */
                                 buf_fbr-gds-obj.is-semi-finished = true )
                               no-error .
                    if not available buf_fbr-gds-obj then next.

                    find first buf_recipe no-lock where
                               buf_recipe.gds-code = buf_goods.gds-code no-error .
                    if available buf_recipe then v-nkk = buf_recipe.recipe-code.
                      else v-nkk = "" .

                    create temp-str .
                    assign
                      temp-str.nkk          = v-nkk
                      temp-str.gds-name     = buf_goods.gds-name
                      temp-str.artic        = buf_goods.artic
                      temp-str.prod-type    = buf_goods.prod-type
                      temp-str.prod-code    = buf_goods.prod-code
                      temp-str.gds-code     = buf_goods.gds-code

                    .

                { gbl/gdsbcode.i buf_goods.gds-code ? v-bar-code  }
                /* Определим текущую цену бар-кода  (  корневого признака ) */
                { gbl/bcodeprc.i
                  buf_obj-list.obj-type
                  buf_obj-list.obj-code
                  v-bar-code
                  0
                  fact-order-1
                  v-cur-dn
                  v-cur-pr
                  v-cur-rt
                  v-cur-ex }

                temp-str.price-crsa   = v-cur-pr .
                end.

        run clcprtsl_calc-line in this-procedure ( input recid ( buf_doc-line) ) .
        find first tt-allsum-line where tt-allsum-line.sum-type = {&sum-general} no-error .

        case par-doc-type :
            when {&TDEDT_Ras_Vnesh_Kass} then do:
                  assign
                    temp-str.qnty-nal     = temp-str.qnty-nal + buf_doc-line.fact-qnty
                    temp-str.sum-nal      = temp-str.sum-nal  +  (  temp-str.price-crsa * buf_doc-line.fact-qnty )
                    temp-str.sum-cost     = temp-str.sum-cost +   (  if v-is-base = true then tt-allsum-line.sum-dsc-base-acc
                                                                     else tt-allsum-line.sum-dsc-rubl-acc )
                    .
            end.
            when {&TDEDT_Vozvrat_Vnesh_Kass} then do:
                  assign
                    temp-str.qnty-nal     = temp-str.qnty-nal - buf_doc-line.fact-qnty
                    temp-str.sum-nal      = temp-str.sum-nal  -  (  temp-str.price-crsa * buf_doc-line.fact-qnty )
                    temp-str.sum-cost     = temp-str.sum-cost -   (  if v-is-base = true then  tt-allsum-line.sum-dsc-base-acc
                                                                     else tt-allsum-line.sum-dsc-rubl-acc )
                  .
            end.


            when {&TDEDT_Ras_Vnesh} then do:
                  assign
                    temp-str.qnty-buf     = temp-str.qnty-buf + buf_doc-line.fact-qnty
                    temp-str.sum-buf      = temp-str.sum-buf  +  (  temp-str.price-crsa * buf_doc-line.fact-qnty )
                    temp-str.sum-cost     = temp-str.sum-cost +   (  if v-is-base = true then  tt-allsum-line.sum-dsc-base-acc
                                                                     else tt-allsum-line.sum-dsc-rubl-acc )
                  .
            end.
            when {&TDEDT_Vozvrat_Vnesh} then do:
                  assign
                    temp-str.qnty-buf     = temp-str.qnty-buf - buf_doc-line.fact-qnty
                    temp-str.sum-buf      = temp-str.sum-buf  -  (  temp-str.price-crsa * buf_doc-line.fact-qnty )
                    temp-str.sum-cost     = temp-str.sum-cost -   (  if v-is-base = true then  tt-allsum-line.sum-dsc-base-acc
                                                                                        else tt-allsum-line.sum-dsc-rubl-acc )
                  .
            end.

            when {&TDEDT_Spi_Vnesh}  or
            when {&TDEDT_Spi_Prvo} then do:
                  assign
                    temp-str.qnty-z     = temp-str.qnty-z + buf_doc-line.fact-qnty
                    temp-str.sum-z      = temp-str.sum-z +  (  temp-str.price-crsa * buf_doc-line.fact-qnty )
                    temp-str.sum-cost     = temp-str.sum-cost +   (  if v-is-base = true then  tt-allsum-line.sum-dsc-base-acc
                                                                                         else tt-allsum-line.sum-dsc-rubl-acc )
                  .
            end.
        end case.
        assign
          temp-str.qnty-all     = temp-str.qnty-z +  temp-str.qnty-buf + temp-str.qnty-nal
          temp-str.sum-all      = temp-str.sum-z  +  temp-str.sum-buf  + temp-str.sum-nal
          temp-str.price-cost   = temp-str.sum-cost  / temp-str.qnty-all

        .

    end. /* for each */


 end. /* do */
end procedure. /* make-body */