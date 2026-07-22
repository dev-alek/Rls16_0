block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-fzlist.p $
$Archive: rep/r-fzlist.p $

Опись дневных заборных листов

Автор: Чернова Светлана Александровна
Дата создания: 11/10/03
Author: Svetlana Chernova
Creation date: 11/10/03


*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-fzlist.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-fzlist.p $":U .
define variable vss-description as character no-undo init " Опись дневных заборных листов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i   }
{ cmp/r-page1.i  }
{ rep/rep-bt.i  }
{ cmp/breakstr.i }
{ rep/r-cliprp.i def }
{ gbl/paramls.i  }
{ rep/f-fdec.i   }
{ str/clcprtsl.i }
{ rep/lkp-font.i }

  &scop gds-len 40

 do
 on error undo, return error return-value
 :

define variable   sort-name   as logical no-undo.
define variable   sort-gr     as logical no-undo.
define variable   print-graft as logical no-undo.   /* "Отладочная печать" */
define variable   s-cost as decimal no-undo .
define variable   s-crsa as decimal no-undo .

sort-gr     = true  .
sort-name   = false .
print-graft = true .

define variable sort-group as logical   no-undo .
if sort-gr                  then assign sort-group = yes .
else                             assign sort-group = no .

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

define buffer buf_clients for  clients .
define buffer This_Object for  clients .

define variable qnty as decimal   no-undo .
define variable sum  as decimal   no-undo .

define variable num-ln as integer   no-undo .

define variable FullNameGds as character no-undo .
define variable gds-str  as character no-undo.
define variable gds-str1 as character no-undo.
define variable gds-str2 as character no-undo.
define variable i as int no-undo.
define variable j as int no-undo.
define variable Counter1 as integer init 0  no-undo .

define variable LineBuf       as character    no-undo.
define variable Line       as character    no-undo.
define variable UndLine    as character    no-undo.

define variable     Lines_Counter as   int  init 0  no-undo.
define variable     Tmp_Counter   as   int  init 0  no-undo.

define variable     tdoc-date     like fbr-pln.doc-date no-undo.
define variable     tdoc-code     like fbr-pln.doc-code no-undo.

define variable  abbr              as  character no-undo.
define variable  pp                as  character no-undo.
define variable vv0 as character no-undo .
define variable vv1 as character no-undo .
define variable vv2 as character no-undo .
define variable vv3 as character no-undo .
define variable vv4 as character no-undo .
define variable vv5 as character no-undo .
define variable vv6 as character no-undo .

define variable sym1 as character  init ":"   no-undo.
define variable sym2 as character  init ":"   no-undo.
define variable sym3 as character  init ":"   no-undo.
define variable sym4 as character  init ":"   no-undo.
define variable sym5 as character  init ":"   no-undo.
define variable sym6 as character  init ":"   no-undo.

define variable np as integer no-undo .
define variable p-cost as decimal no-undo .
define variable p-crsa as decimal no-undo .
define variable p-fact-date as character no-undo .

DEFINE FRAME plan-menu
    sym1                format "X ( 1)" space ( 0)
    np                  format ">>>>9" space ( 0)
    sym2                format "X ( 1)" space ( 0)
    trn-doc.doc-code    format "X ( 18)" space ( 0)
    Sym3                format "X ( 1)" space ( 0)
    p-fact-date         format "x ( 13)" space ( 0)
    Sym4                format "X ( 1)" space ( 0)
    p-cost              format "    >>>>>>>>>>>>>>9.99" space ( 0)
    Sym5                format "X ( 1)" space ( 0)
    p-crsa              format ">>>>>>>>>>>>>9.99" space ( 0)
    Sym6                format "X ( 1)" space ( 0)
    trn-doc.ps          format "X ( 37)" space ( 0)
    HEADER
    string (  "Лист " + string (  PAGE-NUMBER ( OutStream) , ">>>>9") ) AT 100 format "X ( 13)"
    with width  {&DOS_CW} down stream-io use-text NO-UNDERLINE  NO-BOX no-labels.



  if session:set-wait-state ( "compiler") then.

  { cmp/open-out.i STREAM OutStream " "  ReportPageHeight }
  define variable v-prn0 as character no-undo .

  assign
    Line    = fill ( "-", 230)
    UndLine = fill ( "_", 230)
    LineBuf = fill ( "_", 240)
  .

  IF var-report-r-b = "rubl" THEN Assign PP = "Цены {&abbr_rub}.".
                       Else Assign PP = "Цены  баз.вал." .
{ rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
{ rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */
/*-----------------------------------------------------------------------------------------------------------------------*/
v-ind = 0    .

FORM with frame plan-menu .

for each obj-list no-lock :
s-cost = 0 .
s-crsa = 0 .
np = 0 .
 if not can-find
   (  first trn-doc  no-lock  where
      trn-doc.status_   = {&fact}           and
      trn-doc.obj-type  = obj-list.obj-type and
      trn-doc.obj-code  = obj-list.obj-code and
      trn-doc.fact-date = x-date-alone      and
      trn-doc.doc-type  = {&expense}        and
      trn-doc.internal  = true  )
      then next.


vv0 = "+-----+--------------------------------+----------------------------------------+-------------------------------------+".
vv1 = ":     :    Заборный лист  ( накладная)   :            Сумма, {&abbr_rub}.{&abbr_kop}              :                                     :".
vv2 = ": n/n :------------------+-------------:----------------------+-----------------:            Примечание               :".
vv3 = ":     :      Номер       :    Дата     :По учетным ценам кухни:По ценам продажи :                                     :".
vv4 = "+-----+------------------+-------------+----------------------+-----------------+-------------------------------------+".
vv5 = ":  1  :        2         :      3      :           4          :        5        :                    6                :".
vv6 = "+-----+------------------+-------------+----------------------+-----------------+-------------------------------------+" .

 /* создаем временный файл */
    Output stream Macr_Excel  close .
    num#str# = 0 .
    run gbl/_tmpfile.p ( "wb", ".txt", output v-file-name) .
    output stream macr_excel to value ( v-file-name)   .
    v-ind = v-ind + 1.
 define variable col-doc as integer no-undo .


  find this_object  where this_object.obj-type = obj-list.obj-type and this_object.obj-code = obj-list.obj-code  no-lock .
  find clients      where clients.obj-type     = {&cmp}            and clients.obj-code      = v-cntxt-host-code-obj no-lock .
  run PrintTitul in this-procedure .
  /* по строкам документа-------------------------------------------------------------------------------------------- */
  /* теперь печать */
  for each trn-doc  no-lock  where
      trn-doc.status_   = {&fact}           and
      trn-doc.obj-type  = obj-list.obj-type and
      trn-doc.obj-code  = obj-list.obj-code and
      trn-doc.fact-date = x-date-alone      and
      trn-doc.doc-type  = {&expense}        and
      trn-doc.internal  = true             break by trn-doc.fact-order  :

      run print-line in this-procedure .
  end.

  run print-all-itog in this-procedure .
  /* ... Подвал. --- */
  run on-same-page in this-procedure  ( input 2) .

  run PrintPodval in this-procedure .
  /* page stream OutStream . */
  run paramls-write in this-procedure
     ( input "file"
    ,input string ( v-ind) + obj-list.obj-name
    ,input v-file-name
    ) .
     page stream OutStream .
end. /* obj-list */

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
  DisabledOptions = 4 .

  define variable v-orient-page as character no-undo .
  run How-name in this-procedure (
      input ReportPageHeight,
      input ReportPageWidth,
      output v-orient-page )
      .
  if v-orient-page = "A4-lans":U then DisabledOptions = 12 .
                                 else DisabledOptions = 4 .
  run gbl/prnfilen.w
   ( input  ""
    ,input  DisabledOptions
    ,input  string ( session :temp-directory) + {&DF_Name} + string (  g#report-num )
    ,input ReportFontNum
    ,output v-user-action
    ,output v-printed
    ) .

end.

/* *************************************************************************************************** */
procedure print-line :
  do on error undo, return error return-value :

define variable r-exist as logical   no-undo .

p-crsa = 0 .
p-cost = 0 .
 run calc-line-doc in this-procedure
    (  input-output p-crsa ,
     input-output p-cost ,
     output r-exist
     ).

if r-exist = false then return.
s-crsa = s-crsa + p-crsa .
s-cost = s-cost + p-cost .
Lines_Counter = Lines_Counter + 1 .

  if line-counter (  OutStream ) + 2 > page-size (  OutStream ) then page stream OutStream.

  if line-counter (  OutStream ) < Tmp_Counter then
    assign
    .

  assign
    Tmp_Counter  = line-counter (  OutStream )
    num-ln = num-ln + 1
    np = np + 1
  .

  if line-counter (  OutStream ) + j > page-size (  OutStream ) then  PAGE STREAM OutStream.


num#str# = num#str# + 1.
num#col# = 1.

run macr_excel_dec  in this-procedure  ( np                   , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char in this-procedure  ( trn-doc.doc-code     , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char in this-procedure  ( string ( trn-doc.fact-date, "99/99/9999" )    , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec  in this-procedure  ( p-cost                , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec  in this-procedure  ( p-crsa                , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char in this-procedure  ( format-excel-text  (  trn-doc.ps )   , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
display STREAM OutStream
 sym1
 np
 sym2
 trn-doc.doc-code
 Sym3
 string ( trn-doc.fact-date , "99/99/9999") @ p-fact-date
 Sym4
 p-cost
 Sym5
 p-crsa
 Sym6
 trn-doc.ps @ trn-doc.ps
   with FRAME plan-menu.
  DOWN stream OutStream 1 with FRAME plan-menu.
  if print-graft = false THEN do:
  underline stream OutStream
      sym1
      np
      sym2
      trn-doc.doc-code
      Sym3
      p-fact-date
      Sym4
      p-cost
      Sym5
      p-crsa
      Sym6
      trn-doc.ps
    with FRAME plan-menu.
  DOWN stream OutStream 1 with FRAME plan-menu.

   end.
  end.
end procedure. /* print-line */



procedure print-all-itog :
  underline stream OutStream
      sym1
      np
      sym2
      trn-doc.doc-code
      Sym3
      p-fact-date
      Sym4
      p-cost
      Sym5
      p-crsa
      Sym6
      trn-doc.ps
    with FRAME plan-menu.
  DOWN stream OutStream 1 with FRAME plan-menu.

num#str# = num#str# + 1.
num#col# = 3.
run macr_excel_char in this-procedure  ( "ИТОГО"               , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec  in this-procedure  ( s-cost                , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec  in this-procedure  ( s-crsa                , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .

display STREAM OutStream
 sym1
 "ИТОГО"  @ trn-doc.doc-code
 Sym4
 s-cost @  p-cost
 Sym5
 s-crsa  @  p-crsa
 Sym6
   with FRAME plan-menu.
  DOWN stream OutStream 1 with FRAME plan-menu.
  underline stream OutStream
      sym1
      np
      sym2
      trn-doc.doc-code
      Sym3
      p-fact-date
      Sym4
      p-cost
      Sym5
      p-crsa
      Sym6
      trn-doc.ps
    with FRAME plan-menu.
  DOWN stream OutStream 1 with FRAME plan-menu.

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
space ( 1) string (  "Унифицированная форма № ОП-7" )                                             "+--------------------------+" at 89  skip
                                                                                              "|                  | Коды  |" at 89  skip
space ( 5) string (  CAPS (      clients.obj-name ))                                                "|    Форма по ОКУД |0330507|" at 89  skip
space ( 5) string (  CAPS (  This_Object.obj-name ) + "  ( " + string ( This_Object.obj-code) + ")" )   "|          по ОКПО |       |" at 89  skip
                                                                                              "| Вид деятельности |       |" at 89  skip
                                                                                              "|          по ОКДП |       |" at 89  skip
                                                                                              "|     Вид операции |       |" at 89  skip
                                                                                              "+--------------------------+" at 89  skip.

 PUT STREAM OutStream UNFORMATTED
        space ( 5) caps  (  "Опись дневных заборных листов" ) +
                 string (  " ЗА " )  + string ( x-date-alone, "99/99/9999" )
                 format "X ( 100)"  skip
                 "Дата составления " + cur-time-date ( ) at 89 skip
      .


  PUT STREAM OutStream UNFORMATTED
        vv0  skip
        vv1  skip
        vv2 skip
        vv3  skip
        vv4  skip
        vv5  skip
        vv6 skip
    .


    run macr_cell_size  in this-procedure  (  15 , ? , 1 , 11 , 6, 11 ) .
    run macr_cell_format  in this-procedure
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
    run macr_excel_char in this-procedure  (  "Унифицированная форма № ОП-7" , num#str# , num#col#   ) .
    num#col# = 12.
    run macr_excel_char in this-procedure  (  "Коды" , num#str# , num#col#   ) .
    num#str# = 2.
    num#col# = 11.
    run macr_excel_char in this-procedure  (  "Форма по ОКУД" , num#str# , num#col#   ) .
    num#col# = 12.
    run macr_excel_char in this-procedure  (  "0330507" , num#str# , num#col#   ) .
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
    run macr_excel_char in this-procedure  (  caps (  "Опись дневных заборных листов" )  +
                 string (  " ЗА " )  + string ( x-date-alone, "99/99/9999" )
          , num#str# , num#col#   ) .

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

    num#str# = num#str# + 1.
    num#col# = 11.
    run macr_excel_char in this-procedure  ( "Дата составления " + cur-time-date ( )   , num#str# , num#col#   ) .


/* шапка */
    num#str# = num#str# + 1.
    num#col# = 1.
    tt = num#str#  .
    run macr_excel_char in this-procedure  (  "Номер по порядку"   , num#str# , num#col#   ) .
    run macr_cell_size  in this-procedure  (  11 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 2.
    run macr_excel_char in this-procedure  (  "Номер заборного листа  ( накладной)"   , num#str# , num#col#   ) .
    run macr_cell_size  in this-procedure  (  15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 3.
    run macr_excel_char in this-procedure  (  "Дата заборного листа  ( накладной)"   , num#str# , num#col#   ) .
    run macr_cell_size  in this-procedure  (  15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 4.
    run macr_excel_char in this-procedure  (  "Сумма по учетным ценам кухни, {&abbr_rub}"   , num#str# , num#col#   ) .
    run macr_cell_size  in this-procedure  (  15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 5.
    run macr_excel_char in this-procedure  (  "Сумма по ценам продажи, {&abbr_rub}"   , num#str# , num#col#   ) .
    run macr_cell_size  in this-procedure  (  15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 6.
    run macr_excel_char in this-procedure  (  "Примечание"   , num#str# , num#col#   ) .
    run macr_cell_size  in this-procedure  (  40 , ? , num#str# , num#col# , ?, ? ) .


    run macr_cell_format in this-procedure
     (  12    ,    /* p-size     */
      true  ,    /* p-bold     */
      false  ,   /* p-italic   */
      ?    ,     /* p-color-bg */
      Tt,        /* p-row      */
      1 ,        /* p-col      */
      num#str# , /* p-row-2    */
      num#col# ) .      /* p-col-2    */

     put  stream macr_excel unformatted
       substitute ( 'select ( "r&1c&2:r&3c&4 ")' , tt , 1 , num#str# ,  num#col# ) + {&new-line}  +
       'BORDER (  2 , 2 , 2 , 2 , 2 , ,0,0,0,0,0) '  + {&new-line} +
       'ALIGNMENT ( 3 , , 4 , 4 ,)'  + {&new-line}
       .


    /* ... конец создания заголовка. --- */
  end.
end procedure. /* PrintTitul */


procedure PrintPodval :
  do on error undo, return error return-value  :
  define variable pp as integer no-undo .
  define variable rr as integer no-undo .

    num#str# = num#str# + 2.
    num#col# = 1.
    run macr_excel_char in this-procedure  (  "Заведующий производством"   , num#str# , num#col#   ) .


  PUT  STREAM OutStream " "
        skip
      " Заведующий производством _______________________ " skip
      .

    /* ... конец создания Подвал. --- */
  end.
end procedure. /* PrintPodval */



PROCEDURE on-same-page :
  define input parameter p-line-number as integer  no-undo .
  if p-line-number > page-size (  OutStream ) then return .
  if line-counter (  OutStream ) + p-line-number > page-size (  OutStream ) then  page stream OutStream .
end procedure. /* on-same-page */

procedure calc-line-doc :
 do
 on error undo, return error return-value
 :

define input-output parameter    Rubl-NettoSaleSum  as decimal no-undo .
define input-output parameter    Rubl-CostSum       as decimal no-undo .
define output parameter r-exist as logical   no-undo .
 r-exist = false .
define buffer buf_goods for goods.
define buffer buf_fbr-gds-obj for fbr-gds-obj.

 assign
    Rubl-NettoSaleSum  = 0
    Rubl-CostSum       = 0
 .
 for each doc-line no-lock
     where doc-line.doc-code = trn-doc.doc-code
     :
find first buf_goods where
            doc-line.artic     = buf_goods.artic      and
            doc-line.prod-code = buf_goods.prod-code  and
            doc-line.prod-type = buf_goods.prod-type  no-lock no-error .
if not available buf_goods then next.

find first buf_fbr-gds-obj  where
                 buf_fbr-gds-obj.obj-type = trn-doc.obj-type
            and  buf_fbr-gds-obj.obj-code = trn-doc.obj-code
            and  buf_fbr-gds-obj.gds-code = buf_goods.gds-code
            and  ( buf_fbr-gds-obj.is-menu = true
            or   buf_fbr-gds-obj.is-semi-finished = true )
                no-lock no-error .
          if not available buf_fbr-gds-obj then next.
             else r-exist = true .

     run clcprtsl_calc-line in this-procedure  ( input recid  ( doc-line)).
  find first tt-allsum-line where
             tt-allsum-line.sum-type = {&sum-general} no-error .
  if not available tt-allsum-line then do:
  end.
  else do:
     if trn-doc.doc-type = {&income} and trn-doc.internal = false  then
      assign
          Rubl-NettoSaleSum  = Rubl-NettoSaleSum  +  tt-allsum-line.sum-dsc-rubl-doc
        .
     else
      assign
          Rubl-NettoSaleSum  = Rubl-NettoSaleSum  +  tt-allsum-line.sum-dsc-rubl-cur
          .

     assign
          Rubl-CostSum       = Rubl-CostSum       +  tt-allsum-line.sum-dsc-rubl-acc
      .
  end.
end.
assign
  Rubl-NettoSaleSum  = round ( Rubl-NettoSaleSum  ,2)
  Rubl-CostSum       = round ( Rubl-CostSum       ,2)

.

 end. /* do */
end procedure. /* calc-line-doc */


{ rep/r-libmcr.i macr_excel }