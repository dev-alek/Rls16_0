block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-op14.p $
$Archive: rep/r-op14.p $

Товарный отчет по форме ОП-14

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 11/21/03 10:59

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-op14.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-op14.p $":U .
define variable vss-description as character no-undo init " Товарный отчет по форме ОП-14 ".
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
{ rep/rep-bt.i   }
  &scop gds-len 40

 do
 on error undo, return error return-value
 :
ReportPageHeight = 43   .
ReportPageWidth  = 198  .
ReportFontNum    = 7 .

define variable   sort-name   as logical no-undo.
define variable   sort-gr     as logical no-undo.
define variable   print-graft as logical no-undo.   /* "Отладочная печать" */
define variable   summ as decimal no-undo .
define buffer   buf_obj-list for obj-list .
define variable fact-order-1 as decimal no-undo .
define variable fact-order-2 as decimal no-undo .

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
field doc-code  as character
field sum-fact  as decimal
field fact-date as date
field sum-cost  as decimal
index pi doc-code.


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
define variable i as int no-undo.
define variable j as int no-undo.
define variable Counter1 as integer init 0  no-undo .

define variable LineBuf       as char    no-undo.
define variable Line       as char    no-undo.
define variable UndLine    as char    no-undo.

define variable Lines_Counter as   int  init 0  no-undo.
define variable Tmp_Counter   as   int  init 0  no-undo.

define variable tdoc-date  like fbr-pln.doc-date no-undo.
define variable tdoc-code  like fbr-pln.doc-code no-undo.

define variable abbr       as  char no-undo.
define variable pp-a       as  char no-undo.
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
    sym1                format "X(1)" space(0)
    name-raz            format "X(23)" space(0)
    sym2                format "X(1)" space(0)
    temp-sum-fact   format "->>>>>>>>>>9.99" space(0)
    Sym3                format "X(1)" space(0)
    temp-fact-date  format "99/99/99" space(0)
    Sym4                format "X(1)" space(0)
    temp-doc-code   format "X(14)" space(0)
    Sym5                format "X(1)" space(0)
    temp-sum-cost   format "->>>>>>>>>>9.99" space(0)
    Sym6                format "X(1)" space(0)
    t-1                 format "X(8)" space(0)
    Sym7                format "X(1)" space(0)
    t-2                 format "X(6)" space(0)
    Sym8                format "X(1)" space(0)
    t-3                 format "X(3)" space(0)
    Sym9                format "X(1)" space(0)
    t-4                 format "X(7)" space(0)
    Sym10               format "X(1)" space(0)
    t-5                 format "X(7)" space(0)
    Sym11               format "X(1)" space(0)

    HEADER
    string (  "Лист " + string (  PAGE-NUMBER ( OutStream) , ">>>>9") ) AT 80 format "X(13)" SKIP
    UndLine format "X(80)" AT 1
    with width {&DOS_CW} down stream-io use-text NO-UNDERLINE  NO-BOX no-labels.



  if session:set-wait-state ( "compiler") then.

  { cmp/open-out.i STREAM OutStream " " {&CS_PS} }
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

FORM with frame plan-menu .

for each buf_obj-list no-lock :

vv0 = "+-----------------------------------------------------------------------------------------------------------------+".
vv1 = ":                       : Сумма         :       Документ      : Стоимость по  :В том числе стоимость,{&abbr_rub}  " +
                                                                                                                ":Отметки:".
vv2 = ":                       : фактической   :--------+------------: учетным       :--------+------+---+-------:бухгал-:".
vv3 = ":                       : реализации ,  :  Дата  :    Номер   : ценам,        :Продукты:Специи:Та-:Стекло-:терии  :".
vv4 = ":                       : {&abbr_rub}" +
                                   "           :        :            : {&abbr_rub}" +
                                                                         "           :        :и соль:ра :тара   :       :".
vv5 = ":-----------------------+---------------+--------+------------+---------------+--------+------+---+-------+-------:".
vv6 = ":           1           :       2       :   3    :      4     :       5       :    6   :  7   : 8 :   9   :   10  :".
vv7 = "+-----------------------------------------------------------------------------------------------------------------+".

 /* создаем временный файл */
    Output stream Macr_Excel  close .
    num#str# = 0 .
    run gbl/_tmpfile.p  (  "wb", ".txt", output v-file-name) .
    output stream macr_excel to value ( v-file-name)   .
    v-ind = v-ind + 1.

  find this_object  where this_object.obj-type = buf_obj-list.obj-type and this_object.obj-code = buf_obj-list.obj-code  no-lock .
  find clients      where clients.obj-type     = {&cmp}                and clients.obj-code     = v-cntxt-host-code-obj no-lock .
  run PrintTitul in this-procedure .
  /* по строкам документа-------------------------------------------------------------------------------------------- */
  /* сначала заполняем таблицу */

  run make-tt  in this-procedure .

  run print-all-itog in this-procedure .
  /* ... Подвал. --- */
  run on-same-page in this-procedure  ( input 28) .
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


  run end-proc in this-procedure .
  define variable v-user-action as character no-undo .
  define variable v-printed as logical   no-undo .
  define variable DisabledOptions as integer   no-undo .
  DisabledOptions = 0 .

  run gbl/prnfilen.w
   ( input  ""
    ,input  DisabledOptions
    ,input  string ( session :temp-directory) + {&DF_Name} + string (  g#report-num )
    ,input 7
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
    sym1                format "X(1)" space(0)
    name-raz            format "X(23)" space(0)
    sym2                format "X(1)" space(0)
    temp-sum-fact   format "->>>>>>>>>>9.99" space(0)
    Sym3            format "X(1)" space(0)
    temp-fact-date  format "99/99/99" space(0)
    Sym4            format "X(1)" space(0)
    temp-doc-code   format "X(12)" space(0)
    Sym5            format "X(1)" space(0)
    temp-sum-cost   format "->>>>>>>>>>9.99" space(0)
    Sym6                format "X(1)" space(0)
    t-1                 format "X(8)" space(0)
    Sym7                format "X(1)" space(0)
    t-2                 format "X(6)" space(0)
    Sym8                format "X(1)" space(0)
    t-3                 format "X(3)" space(0)
    Sym9                format "X(1)" space(0)
    t-4                 format "X(7)" space(0)
    Sym10               format "X(1)" space(0)
    t-5                 format "X(7)" space(0)
    Sym11               format "X(1)" space(0)
    skip
.
    num#col# = 1.
    num#str# = num#str# + 1.
    run macr_excel_char ( name-raz          , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_dec  ( round ( temp-sum-fact,2) , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    if temp-fact-date = ? then  assign    num#col# = num#col# + 1 .
    else do:
         run macr_excel_char (  string (  temp-fact-date,"99/99/99"), num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
         end.
    run macr_excel_char ( temp-doc-code , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_dec  ( round ( temp-sum-cost,2) , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char ( t-1               , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char ( t-2               , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char ( t-3               , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char ( t-4               , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char ( t-5               , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .

  if print-graft = false THEN do:
  underline stream OutStream
    sym1
    sym2
    sym3
    sym4
    with FRAME plan-menu.
  DOWN stream OutStream 1 with FRAME plan-menu.

   end.
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
{ rep/r-cliprp.i }
PUT STREAM OutStream UNFORMATTED
space(1) string (  "Унифицированная форма № ОП-14" )                                            "+--------------------------+" at 89  skip
                                                                                              "|                  | Коды  |" at 89  skip
space(5) string( CAPS(     clients.obj-name ))                                                "|    Форма по ОКУД |0330514|" at 89  skip
space(5) string( CAPS( This_Object.obj-name ) + "  ( " + string ( This_Object.obj-code) + ")" )   "|          по ОКПО |       |" at 89  skip
                                                                                              "| Вид деятельности |       |" at 89  skip
space(5)                                                                                      "|          по ОКДП |       |" at 89  skip
                                                                                              "|     Вид операции |       |" at 89  skip
                                                                                              "+--------------------------+" at 89  skip
                                                                                              .

 PUT STREAM OutStream UNFORMATTED
        space(10) string( "         ВЕДОМОСТЬ УЧЕТА"           ) skip
        space(10) string( "ДВИЖЕНИЯ ПРОДУКТОВ И ТАРЫ НА КУХНЕ" ) skip
        space(10) string( "        (ТОВАРНЫЙ ОТЧЕТ)"           ) skip
        space(10) string( "       C " )  + string(x-date-start, "99/99/9999" )  + string( " ПО " )  + string(x-date-end, "99/99/9999" ) skip
                         "Дата составления " + cur-time-date() at 89  skip
      .

  define variable i as integer no-undo .
  Repeat i = 1 to NUM-ENTRIES(ReportHeader,chr(10)) :
    PUT STREAM OutStream UNFORMATTED  Entry(i,ReportHeader,chr(10))  AT 1 format "X(90)" SKIP.
  End.
  PUT STREAM OutStream UNFORMATTED
        " " skip
        space(5) string( "Материально ответственное лицо  ____________________  ___________________" ) skip
        space(5) string( "                                     должность           фамилия, и.,о.  " ) skip
  .
  PUT STREAM OutStream UNFORMATTED
        vv0  skip
        vv1  skip
        vv2  skip
        vv3  skip
        vv4  skip
        vv5  skip
        vv6  skip
        vv7  skip

      .


    run macr_cell_size ( 15 , ? , 1 , 11 , 6, 11 ) .
    run macr_cell_format
    ( 8       ,   /* p-size     */
      false   ,   /* p-bold     */
      false   ,   /* p-italic   */
      ?       ,   /* p-color-bg */
      1  ,        /* p-row      */
      11 ,        /* p-col      */
      6  ,        /* p-row-2    */
      12 ) .      /* p-col-2    */

    num#str# = 1.
    num#col# = 1.
    run macr_excel_char( "Унифицированная форма № ОП-14" , num#str# , num#col#   ) .
    num#col# = 12.
    run macr_excel_char( "Коды" , num#str# , num#col#   ) .
    num#str# = 2.
    num#col# = 11.
    run macr_excel_char( "Форма по ОКУД" , num#str# , num#col#   ) .
    num#col# = 12.
    run macr_excel_char( "0330514" , num#str# , num#col#   ) .
    num#str# = 3.
    num#col# = 11.
    run macr_excel_char( "по ОКПО" , num#str# , num#col#   ) .
    num#str# = 4.
    num#col# = 11.
    run macr_excel_char( "Вид деятельности по ОКДП" , num#str# , num#col#   ) .
    num#str# = 5.
    num#col# = 11.
    run macr_excel_char( "Вид операции" , num#str# , num#col#   ) .

    put  stream macr_excel unformatted
    substitute('select("r&1c&2:r&3c&4 ")' , 1 , 11 , 6 ,  11 ) + {&new-line}  +
    'ALIGNMENT(4 , , 4 , 4 ,)'  + {&new-line}
    .
    put  stream macr_excel unformatted
    substitute('select("r&1c&2:r&3c&4 ")' , 1 , 12 , 6 ,  12 ) + {&new-line}  +
    'BORDER( 2 , 2 , 2 , 2 , 2 , ,0,0,0,0,0) '  + {&new-line}
    .
    num#str# = 3.
    num#col# = 1.
    cc = num#str# .

    run macr_excel_char( "         ВЕДОМОСТЬ УЧЕТА"                                                , num#str# , num#col#   ) . num#str# = num#str# + 1.
    run macr_excel_char( "ДВИЖЕНИЯ ПРОДУКТОВ И ТАРЫ НА КУХНЕ"                                      , num#str# , num#col#   ) . num#str# = num#str# + 1.
    run macr_excel_char( "        (ТОВАРНЫЙ ОТЧЕТ)"                                                , num#str# , num#col#   ) . num#str# = num#str# + 1.
    run macr_excel_char( "       C "   + string(x-date-start, "99/99/9999" ) + " ПО "   + string(x-date-end, "99/99/9999" )                    , num#str# , num#col#   ) . num#str# = num#str# + 1.
    num#str# = num#str# + 2.
    num#col# = 2.
    run macr_excel_char(  CAPS( clients.obj-name)   , num#str# , num#col#   ) .
    num#str# = num#str# + 1.
    num#col# = 2.
    run macr_excel_char( string( CAPS( This_Object.obj-name ) + " (" + string(This_Object.obj-code) + ")" )   , num#str# , num#col#   ) .

    run macr_cell_format
    ( 20    ,    /* p-size     */
      true  ,    /* p-bold     */
      false  ,   /* p-italic   */
      ?    ,     /* p-color-bg */
      cc ,       /* p-row      */
      1 ,        /* p-col      */
      num#str# , /* p-row-2    */
      2 ) .      /* p-col-2    */

    num#str# = num#str# + 2.
    num#col# = 1.

    run macr_excel_char( ReportHeader , num#str# , num#col#   ) .
    num#str# = num#str# + 2.
    num#col# = 2.
    run macr_excel_char( "Материально ответственное лицо  ", num#str# , num#col#   ) .
    num#col# = 4.
    run macr_excel_char( "____________________  ", num#str# , num#col#   ) .
    num#col# = 5.
    run macr_excel_char( "____________________", num#str# , num#col#   ) .
    num#str# = num#str# + 1 .
    num#col# = 4.
    run macr_excel_char( " должность ", num#str# , num#col#   ) .
    num#col# = 5.
    run macr_excel_char( " фамилия, и.,о.  ", num#str# , num#col#   ) .
    num#str# = num#str# + 2 .

    num#str# = num#str# + 1.
    num#col# = 11.
    run macr_excel_char("Дата составления " + cur-time-date()   , num#str# , num#col#   ) .

/* шапка */
    num#str# = num#str# + 1.
    num#col# = 1.
     run macr_cell_size ( 21 , ? , num#str# , num#col# , ?, ? ) .
    pp = num#str#  .
    tt = num#str#  .
    num#col# = num#col# + 1.
    run macr_excel_char( "Сумма фактической реализации, " + pp-a   , num#str# , num#col#   ) .
    run macr_cell_size ( 16 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = num#col# + 1.
    run macr_excel_char( "Дата документа"   , num#str# , num#col#   ) .
    run macr_cell_size ( 14 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = num#col# + 1.
    run macr_excel_char( "Номер документа"   , num#str# , num#col#   ) .
    run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = num#col# + 1.
    run macr_excel_char( "Стоимость по учетным ценам, " + pp-a    , num#str# , num#col#   ) .
    run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = num#col# + 1.
    run macr_excel_char( "В т.ч. продукты, " + pp-a    , num#str# , num#col#   ) .
    run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = num#col# + 1.
    run macr_excel_char( "В т.ч. специи и соль, " + pp-a    , num#str# , num#col#   ) .
    run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
        num#col# = num#col# + 1.
    run macr_excel_char( "В т.ч. тара, " + pp-a    , num#str# , num#col#   ) .
    run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
        num#col# = num#col# + 1.
    run macr_excel_char( "В т.ч. стеклотара, " + pp-a    , num#str# , num#col#   ) .
    run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
        num#col# = num#col# + 1.
    run macr_excel_char( "Отметки бухгалтерии "    , num#str# , num#col#   ) .
    run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
    run macr_cell_format
    ( 12    ,    /* p-size     */
      true  ,    /* p-bold     */
      false  ,   /* p-italic   */
      ?    ,     /* p-color-bg */
      pp, /* p-row      */
      1 ,        /* p-col      */
      num#str# , /* p-row-2    */
      num#col# ) .      /* p-col-2    */

     put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , tt , 1 , num#str# ,  num#col# ) + {&new-line}  +
       'BORDER( 2 , 2 , 2 , 2 , 2 , ,0,0,0,0,0) '  + {&new-line} +
       'ALIGNMENT(3 , , 4 , 4 ,)'  + {&new-line}
       .
    put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , pp , 1 , pp ,  3 ) + {&new-line}  +
       'BORDER( 2, , , , , , , , , , ) '  + {&new-line} .


    /* ... конец создания заголовка. --- */
  end.
end procedure. /* PrintTitul */


procedure PrintPodval :
  do on error undo, return error return-value  :
  define variable pp as integer no-undo .
  define variable rr as integer no-undo .

    num#str# = num#str# + 2.
    num#col# = 2.   run macr_excel_char(" Приложение __________________________________________________________ документов"   , num#str# , num#col#   ) . num#str# = num#str# + 1.
    num#col# = 4.   run macr_excel_char("                            количество прописью"                                       , num#str# , num#col#   ) . num#str# = num#str# + 2.
    num#col# = 2.   run macr_excel_char(" Материально ответственное лицо  _____________________________________ "  , num#str# , num#col#   ) . num#str# = num#str# + 1.
    num#col# = 5.   run macr_excel_char("                                         подпись "                                   , num#str# , num#col#   ) . num#str# = num#str# + 2.
    num#col# = 2.   run macr_excel_char(" Работники _________________________________    "   , num#str# , num#col#   ) . num#col# = 5.   run macr_excel_char("  _________________________________"   , num#str# , num#col#   ) . num#str# = num#str# + 1.
    num#col# = 3.   run macr_excel_char("                    фамилия, и.,о.              "   , num#str# , num#col#   ) . num#col# = 5.   run macr_excel_char("  фамилия, и.,о. "                     , num#str# , num#col#   ) . num#str# = num#str# + 1.






    num#col# = 3.   run macr_excel_char("           _________________________________ "   , num#str# , num#col#   ) . num#col# = 5.   run macr_excel_char("  _________________________________"   , num#str# , num#col#   ) . num#str# = num#str# + 1.
    num#col# = 3.   run macr_excel_char("                    фамилия, и.,о.           "   , num#str# , num#col#   ) . num#col# = 5.   run macr_excel_char("  фамилия, и.,о. "                     , num#str# , num#col#   ) . num#str# = num#str# + 1.
    num#col# = 3.   run macr_excel_char("           _________________________________ "   , num#str# , num#col#   ) . num#col# = 5.   run macr_excel_char("  _________________________________"   , num#str# , num#col#   ) . num#str# = num#str# + 1.
    num#col# = 3.   run macr_excel_char("                    фамилия, и.,о.           "   , num#str# , num#col#   ) . num#col# = 5.   run macr_excel_char("  фамилия, и.,о. "                     , num#str# , num#col#   ) . num#str# = num#str# + 2.
    num#col# = 2.   run macr_excel_char(" Ведомость с документами  ____________________"  , num#str# , num#col#   ) . num#col# = 5.   run macr_excel_char("  ________________"  , num#str# , num#col#   ) . num#col# = 6 . run macr_excel_char("  ____________________"   , num#str# , num#col#   ) .  num#str# = num#str# + 1.
    num#col# = 2.   run macr_excel_char(" принял и проверил              должность     "  , num#str# , num#col#   ) . num#col# = 5.   run macr_excel_char("  подпись "          , num#str# , num#col#   ) . num#col# = 6 . run macr_excel_char("  расшифровка "           , num#str# , num#col#   ) .  num#str# = num#str# + 2.

    num#col# = 2.   run macr_excel_char(" Решение руководителя                         "  , num#str# , num#col#   ) . num#str# = num#str# + 4.



    num#col# = 2.   run macr_excel_char(" Руководитель организации _______________________ "   , num#str# , num#col#   ) . num#col# = 5 . run macr_excel_char("  ________________"  , num#str# , num#col#   ) . num#col# = 6 . run macr_excel_char("  ____________________"   , num#str# , num#col#   ) .  num#str# = num#str# + 1.
    num#col# = 4.   run macr_excel_char("                               должность          "   , num#str# , num#col#   ) . num#col# = 5 . run macr_excel_char("  подпись "          , num#str# , num#col#   ) . num#col# = 6 . run macr_excel_char("  расшифровка "           , num#str# , num#col#   ) .  num#str# = num#str# + 1.



PUT STREAM OutStream UNFORMATTED  vv0 skip.


  PUT  STREAM OutStream " "       skip
      " Приложение __________________________________________________________ документов"  skip
      "                          количество прописью"                                      skip " " skip
      " Материально ответственное лицо  ________________________________________________ " skip
      "                                         подпись "                                  skip  " " skip
      " Работники _________________________________    _________________________________"  skip
      "                    фамилия, и.,о.                    фамилия, и.,о. "              skip " " skip
      "           _________________________________    _________________________________"  skip
      "                    фамилия, и.,о.                    фамилия, и.,о. "              skip " " skip
      "           _________________________________    _________________________________"  skip
      "                    фамилия, и.,о.                    фамилия, и.,о. "              skip " " skip " " skip

      " Ведомость с документами  ____________________ _________________ ________________"  skip
      " принял и проверил              должность           подпись         расшифровка   " skip " " skip
      " Решение руководителя ___________________________________________________________ " skip
      " ________________________________________________________________________________ " skip
      " ________________________________________________________________________________ " skip " " skip
      " Руководитель организации _______________________ ______________ ________________"  skip
      "                               должность           подпись         расшифровка   "  skip


      .

    /* ... конец создания Подвал. --- */
  end.
end procedure. /* PrintPodval */



PROCEDURE on-same-page :
  define input parameter p-line-number as integer  no-undo .
  if p-line-number > page-size( OutStream ) then return .
  if line-counter( OutStream ) + p-line-number > page-size( OutStream ) then  page stream OutStream .
end procedure. /* on-same-page */


procedure make-tt :
  do
  on error undo, return error return-value
  :

define variable fact-order-x as decimal no-undo .
define variable Qnty1        as decimal no-undo .
define variable VAT_R1       as decimal no-undo .
define variable VAT_V1       as decimal no-undo .

for each temp-str: delete temp-str. end.
/* остатоки  по объекту */
    run ostatok   in this-procedure  (
        input buf_obj-list.obj-code     ,
        input buf_obj-list.obj-type     ,
        input false /*x-TOG-Shift*/ ,
        input x-date-start - 1      ,
        input date('')              ,
        input ? /* x-Shift-Start */ ,
        input ? /* x-Shift-End*/    ,
        input {&arh-crsa}           ,
        input {&root-cat-id}        ,
        input true /*xTog-obj  */   ,
        output  Qnty1       ,
        output  crsa-rubl-start   ,
        output  crsa-base-start   ,
        output  VAT_R1      ,
        output  VAT_V1      ,
        output  Fact-order-1 ) .

    run ostatok   in this-procedure  (
        input buf_obj-list.obj-code     ,
        input buf_obj-list.obj-type     ,
        input false /*x-TOG-Shift*/ ,
        input x-date-start - 1      ,
        input x-date-end          ,
        input ? /* x-Shift-Start */ ,
        input ? /* x-Shift-End*/    ,
        input {&arh-crsa}           ,
        input {&root-cat-id}        ,
        input true /*xTog-obj  */   ,
        output  Qnty1           ,
        output  crsa-rubl-end   ,
        output  crsa-base-end   ,
        output  VAT_R1      ,
        output  VAT_V1      ,
        output  Fact-order-2 ) .

    run ostatok   in this-procedure  (
        input buf_obj-list.obj-code     ,
        input buf_obj-list.obj-type     ,
        input false /*x-TOG-Shift*/ ,
        input x-date-start - 1      ,
        input date('')              ,
        input ? /* x-Shift-Start */ ,
        input ? /* x-Shift-End*/    ,
        input {&arh-cost}           ,
        input {&root-cat-id}        ,
        input true /*xTog-obj  */   ,
        output  Qnty1       ,
        output  cost-rubl-start   ,
        output  cost-base-start   ,
        output  VAT_R1      ,
        output  VAT_V1      ,
        output  Fact-order-x ) .

    run ostatok   in this-procedure  (
        input buf_obj-list.obj-code     ,
        input buf_obj-list.obj-type     ,
        input false /*x-TOG-Shift*/ ,
        input x-date-start - 1      ,
        input x-date-end          ,
        input ? /* x-Shift-Start */ ,
        input ? /* x-Shift-End*/    ,
        input {&arh-cost}           ,
        input {&root-cat-id}        ,
        input true /*xTog-obj  */   ,
        output  Qnty1           ,
        output  cost-rubl-end   ,
        output  cost-base-end   ,
        output  VAT_R1      ,
        output  VAT_V1      ,
        output  Fact-order-x ) .

  assign
    name-raz        = "I.Остаток на начало дня"
    temp-doc-code   = ""
    temp-fact-date  = x-date-start
  .
if v-is-base = true then do:
    assign
    temp-sum-fact   = crsa-base-start
    temp-sum-cost   = cost-base-start
    .
end.
else do:
   assign
    temp-sum-fact   = crsa-rubl-start
    temp-sum-cost   = cost-rubl-start
   .
end.

  run print-line in this-procedure .


  /*----ПРИХОД-----------*/
 /* {&TDEDT_Pri_Vnesh}    01 }
    {&TDEDT_RAS_Vnesh_VP}  03}
    {&TDEDT_Pri_Perem} 09 }
    {&TDEDT_Pri_Prvo} 14 }
  */
  for each tdedt where tdedt.n = "01" or
                        tdedt.n = "03" or
                        tdedt.n = "09" or
                        tdedt.n = "14"
  :

      for each ot-tot no-lock where
      ot-tot.obj-type     = buf_obj-list.obj-type and
      ot-tot.obj-code     = buf_obj-list.obj-code and
      ot-tot.ext-doc-type = tdedt.id and
      ot-tot.fact-order   >= fact-order-1     and
      ot-tot.fact-order   <= fact-order-2     and
      ot-tot.sum-type      = {&arh-crsa}
      :

      find first temp-str where temp-str.doc-code = ot-tot.doc-code no-error .
      if not available temp-str then   create temp-str.
      assign
        temp-str.doc-code  = ot-tot.doc-code
      .
      if v-is-base = true then do:
          assign
          temp-str.sum-fact  = ot-tot.sum-base
          .
      end.
      else do:
        assign
          temp-str.sum-fact  = ot-tot.sum-rubl
        .
      end.

      end.
  end.
 run make-cost in this-procedure( output sum-crsa,
                 output sum-cost  ) .

 /* По документам прихода */
 for each temp-str break by temp-str.doc-code :
    If first ( temp-str.doc-code )
       then name-raz        = "II.Приход"  .
       else name-raz        = "" .
      assign
        temp-doc-code   = temp-str.doc-code
        temp-fact-date  = temp-str.fact-date
        temp-sum-fact   = temp-str.sum-fact
        temp-sum-cost   = temp-str.sum-cost
      .
      run print-line in this-procedure .

 end.

for each temp-str: delete temp-str. end.
  assign
    name-raz        = "Итого по приходу"
    temp-doc-code   = ""
    temp-fact-date  = x-date-end
    temp-sum-fact   = sum-crsa
    temp-sum-cost   = sum-cost
  .
  run print-line in this-procedure .

  assign
    name-raz        = "Итого с остатком"
    temp-doc-code   = ""
    temp-fact-date  = date("")
  .
if v-is-base = true then do:
    assign
    temp-sum-fact   = sum-crsa + crsa-base-start
    temp-sum-cost   = sum-cost + cost-base-start
    .
end.
else do:
   assign
    temp-sum-fact   = sum-crsa + crsa-rubl-start
    temp-sum-cost   = sum-cost + cost-rubl-start
   .
end.

  run print-line in this-procedure .

 /*----РАСХОД-----------*/
/*
  {&TDEDT_Ras_Vnesh}    02 }
  {&TDEDT_Ras_Vnesh_Kass} 04 }
  {&TDEDT_Vozvrat_Vnesh} 05 }
  {&TDEDT_Vozvrat_Vnesh_Kass} 06 }
  {&TDEDT_Spi_Vnesh} 07 }
  {&TDEDT_Vozvrat_Perem} 11 }
  {&TDEDT_Ras_Prvo} 12 }
  {&TDEDT_Spi_Prvo} 13 }
  {&TDEDT_Ras_Perem} 10 }
*/

for each tdedt where tdedt.n = "02" or
tdedt.n = "04" or
tdedt.n = "05" or
tdedt.n = "06" or
tdedt.n = "07" or
tdedt.n = "11" or
tdedt.n = "12" or
tdedt.n = "13" or
tdedt.n = "10"
:
 run make-crsa in this-procedure( tdedt.id ) .
end.

 run make-cost in this-procedure ( output sum-crsa,
                 output sum-cost  ) .


 /* По документам расхода */
 for each temp-str  break by temp-str.doc-code :
    If first( temp-str.doc-code ) then name-raz        = "III.Расход".
       else name-raz        = "" .

      assign
        temp-doc-code   = temp-str.doc-code
        temp-fact-date  = temp-str.fact-date
        temp-sum-fact   = temp-str.sum-fact
        temp-sum-cost   = temp-str.sum-cost
      .
      run print-line in this-procedure .
 end.

for each temp-str: delete temp-str. end.
  assign
    name-raz        = "Итого по расходу"
    temp-doc-code   = ""
    temp-fact-date  = x-date-end
    temp-sum-fact   = sum-crsa
    temp-sum-cost   = sum-cost
  .
  run print-line in this-procedure .

  assign
    name-raz        = "IV.Остаток на конец дня"
    temp-doc-code   = ""
    temp-fact-date  = x-date-end
  .
if v-is-base = true then do:
    assign
    temp-sum-fact   =  crsa-base-end
    temp-sum-cost   =  cost-base-end
    .
end.
else do:
   assign
    temp-sum-fact   =  crsa-rubl-end
    temp-sum-cost   =  cost-rubl-end
   .
end.

  run print-line in this-procedure .

 /*----ИНВЕНТАРИЗАЦИЯ-----------*/

for each tdedt where tdedt.n = "08" or
tdedt.n = "16" or
tdedt.n = "17"
:
 run make-crsa( tdedt.id ) .
end.

 run make-cost ( output sum-crsa,
                 output sum-cost  ) .


 /* По документам inv */
 for each temp-str  break by temp-str.doc-code :
 end.
      assign
        name-raz        = "Фактический остаток"
        temp-doc-code   = ""
        temp-fact-date  = date("")
      .
      if v-is-base = true then do:
          assign
          temp-sum-fact   =  crsa-base-end  + sum-crsa
          temp-sum-cost   =  cost-base-end  + sum-cost
          .
      end.
      else do:
        assign
          temp-sum-fact   =  crsa-rubl-end  + sum-crsa
          temp-sum-cost   =  cost-rubl-end  + sum-cost
        .
      end.

      run print-line in this-procedure .

  end. /* do */
 end procedure. /* make-tt */


procedure make-cost :
 do
 on error undo, return error return-value
 :
 define output parameter p-crsa as decimal no-undo .
 define output parameter p-cost as decimal no-undo .
 define variable p-fact-date  as date    no-undo .

 p-crsa = 0 .
 p-cost = 0 .

 for each temp-str:
    for each ot-tot no-lock where
        ot-tot.doc-code = temp-str.doc-code and
        ot-tot.sum-type = {&arh-cost} and
        ot-tot.cat-id   = {&root-cat-id} :

    run factord-to-date in this-procedure  (
                          input   ot-tot.fact-order ,
                          output  p-fact-date  ).

      assign
        temp-str.fact-date = p-fact-date
      .
      if v-is-base = true then do:
          assign
          temp-str.sum-cost  = ot-tot.sum-base
          .
      end.
      else do:
        assign
          temp-str.sum-cost  = ot-tot.sum-rubl
        .
      end.

    end.

 end.

  for each temp-str :
      p-crsa = p-crsa + temp-str.sum-fact .
      p-cost = p-cost + temp-str.sum-cost .
  end.


 end. /* do */
end procedure. /* make-cost */



procedure make-crsa :
  do
  on error undo, return error return-value
  :
  define input parameter p-ext-doc-type as character no-undo .

  for each ot-tot no-lock where
  ot-tot.obj-type     = buf_obj-list.obj-type  and
  ot-tot.obj-code     = buf_obj-list.obj-code  and
  ot-tot.ext-doc-type = p-ext-doc-type     and
  ot-tot.fact-order   >= fact-order-1      and
  ot-tot.fact-order   <= fact-order-2      and
  ot-tot.sum-type      = {&arh-crsa}
  :
  find first temp-str where temp-str.doc-code = ot-tot.doc-code no-error .
  if not available temp-str then   create temp-str.
  assign
     temp-str.doc-code  = ot-tot.doc-code

  .
      if v-is-base = true then do:
          assign
          temp-str.sum-fact  = ot-tot.sum-base
          .
      end.
      else do:
        assign
          temp-str.sum-fact  = ot-tot.sum-rubl
        .
      end.

  end.


  end. /* do */
 end procedure. /* make-crsa */
{ rep/r-libmcr.i macr_excel         }
{ rep/ostatok.i }