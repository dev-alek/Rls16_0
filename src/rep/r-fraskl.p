block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-fraskl.p $
$Archive: rep/r-fraskl.p $

Отчет по раскладке продуктов за период

Автор: Чернова Светлана Александровна
Дата создания: 11/20/03
Author: Svetlana Chernova
Creation date: 11/20/03

*/


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-fraskl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-fraskl.p $":U .
define variable vss-description as character no-undo init " Отчет по раскладке продуктов за период ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i   }
{ cmp/r-page1.i  }
{ cmp/breakstr.i }
{ rep/r-cliprp.i def }
{ gbl/paramls.i  }
{ rep/f-fdec.i   }
{ rep/rep-bt.i  }
{ rep/lkp-font.i }
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
define variable n-c as integer no-undo .
sort-gr     = true  .
sort-name   = false .
print-graft = true .

&Scop Sort-pole if sort-name then  temp-str.gds-name Else string (temp-str.np,"999999999")

define variable sort-group as logical   no-undo .
if sort-gr                  then assign sort-group = yes .
else                             assign sort-group = no .


DEFINE temp-table temp-bl no-undo
  field   id                as integer
  field   artic             as  char
  field   prod-type         as  char
  field   prod-code         as integer
  field   gds-name          as  char
  field   gds-code          as  integer
  field   qnty              as decimal
  field   qnty-porc         as decimal
  field   s-porc         as decimal
  field   qnty-netto        as decimal

  index by_art
           artic
           prod-type
           prod-code
  index by_gds
           gds-code
  index pi id
.

DEFINE temp-table temp-ing  no-undo
  field   id                as integer
  field   artic             as  char
  field   prod-type         as  char
  field   prod-code         as integer
  field   gds-name          as  char
  field   gds-code          as  integer
  field   itog              as  decimal

  index by_art
           artic
           prod-type
           prod-code
  index by_gds
           gds-code

  index pi id
.

DEFINE temp-table temp-qnty  no-undo
  field   id-bl           as integer
  field   id-ing          as integer
  field   qnty              as decimal
  index pi IS UNIQUE PRIMARY id-bl id-ing
.


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

def buffer buf_clients for  clients .
def buffer This_Object for  clients .

define variable qnty as decimal   no-undo .
define variable sum  as decimal   no-undo .

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

define variable     Lines_Counter as   int  init 0  no-undo.
define variable     Tmp_Counter   as   int  init 0  no-undo.

define variable     tdoc-date     like fbr-pln.doc-date no-undo.
define variable     tdoc-code     like fbr-pln.doc-code no-undo.

define variable  abbr              as  char no-undo.
define variable  pp                as  char no-undo.
define variable vv0 as character no-undo .
define variable vv1 as character no-undo .
define variable vv2 as character no-undo .

define variable sym1 as char  init ":"   no-undo.
define variable sym2 as char  init ":"   no-undo.
define variable sym3 as char  init ":"   no-undo.
define variable sym4 as char  init ":"   no-undo.




  if session:set-wait-state ("compiler") then.

  { cmp/open-out.i STREAM OutStream " " ReportPageHeight }
  define variable v-prn0 as character no-undo .

  assign
    Line    = fill ("-", 230)
    UndLine = fill ("_", 230)
    LineBuf = fill ("_", 240)
  .

{ rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
{ rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */
/*-----------------------------------------------------------------------------------------------------------------------*/
v-ind = 0    .
for each obj-list :
    Output stream Macr_Excel  close .
    num#str# = 0 .
    run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
    output stream macr_excel to value (v-file-name)   .
    v-ind = v-ind + 1.
 /* очистим временные таблички */
for each temp-bl  : delete temp-bl.  end.
for each temp-ing : delete temp-ing. end.
for each temp-qnty : delete temp-qnty. end.
n-c = 0.

  /* сначала заполняем таблицы */
  run make-tt.

  find this_object  where this_object.obj-type = obj-list.obj-type and this_object.obj-code = obj-list.obj-code  no-lock .
  find clients      where clients.obj-type     = {&cmp}            and clients.obj-code      = v-cntxt-host-code-obj no-lock .
  run PrintTitul in this-procedure .

  /* теперь печать */
  for each temp-bl no-lock break by temp-bl.id :
      run print-line in this-procedure .
  end.

  run print-all-itog in this-procedure .
  /* ... Подвал. --- */
  run on-same-page in this-procedure  (input 1) .
  run PrintPodval in this-procedure .
  /* page stream OutStream . */
  run paramls-write in this-procedure
     (input "file"
    ,input string (v-ind) + obj-list.obj-name
    ,input v-file-name
    ) .
end. /* obj-list */

output stream OutStream CLOSE .
Output stream Macr_Excel  close .

{ rep/repfrm.i off } /* Показать окно информации о текущем процессе */

    run paramls-write in this-procedure
         (input "charcol"
        ,input ""
        ,input "1"
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

  if n-c <= 10 then  DisabledOptions = 8 .
  if n-c > 10 and n-c < 66 then DisabledOptions = 9 .
  if n-c >= 66 then DisabledOptions = 11 .

  /* TODO проверить почему не печатается в текстовый файл , ставлю заглушку*/
  DisabledOptions = 11 .

run gbl/prnfilen.w
   (input  ""
  ,input  DisabledOptions
  ,input  string (session :temp-directory) + {&DF_Name} + string ( g#report-num )
  ,input ReportFontNum
  ,output v-user-action
  ,output v-printed
  ) .

end.

/* *************************************************************************************************** */
procedure print-line :
  do on error undo, return error return-value :
define variable p-qnty as character no-undo .

  assign
     Lines_Counter = Lines_Counter + 1
    .

  if line-counter ( OutStream ) + 2 > page-size ( OutStream ) then page stream OutStream.

  if line-counter ( OutStream ) < Tmp_Counter then
    assign
    .

  assign
    Tmp_Counter  = line-counter ( OutStream )
    num-ln = num-ln + 1
  .

  if line-counter ( OutStream ) + j > page-size ( OutStream ) then  PAGE STREAM OutStream.

num#str# = num#str# + 1.
num#col# = 1.

temp-bl.qnty-porc = temp-bl.qnty * temp-bl.s-porc / temp-bl.qnty-netto no-error .
/* message temp-bl.qnty skip  temp-bl.s-porc skip temp-bl.qnty-netto  skip "=" temp-bl.qnty-porc. */
run macr_excel_char ( temp-bl.gds-name  , num#str# , num#col#) . assign num#col# = num#col# + 1 .
run macr_excel_dec  ( temp-bl.qnty      , num#str# , num#col#) . assign num#col# = num#col# + 1 .
run macr_excel_dec  ( temp-bl.qnty-porc , num#str# , num#col#) . assign num#col# = num#col# + 1 .


PUT STREAM OutStream UNFORMATTED
    sym1                format "X(1)" space (0)
    temp-bl.gds-name    format "x(30)" space (0)
    sym2                format "X(1)" space (0)
    temp-bl.qnty        format ">>>>>>>>9.999" space (0)
    sym3                format "X(1)" space (0)
    temp-bl.qnty-porc   format ">>>>>>>>9.999" space (0)
    sym4                format "X(1)" space (0)

.

/* по ингридиентам */
    for each temp-ing :
        p-qnty = "".
        find first temp-qnty where
                  temp-qnty.id-bl  = temp-bl.gds-code and
                  temp-qnty.id-ing = temp-ing.gds-code no-error .
        if available temp-qnty then p-qnty = string  ( temp-qnty.qnty ) .
        run macr_excel_char ( p-qnty , num#str# , num#col#   ). num#col# = num#col# + 1 .

        PUT STREAM OutStream UNFORMATTED
            p-qnty              format "x(15)" space (0)
            sym2                format "X(1)"  space (0)
            .
    end.
PUT STREAM OutStream UNFORMATTED skip .


end.
end procedure. /* print-line */



procedure print-all-itog :
define variable sss  as decimal no-undo .

for each temp-ing :
  sss = 0 .
  for each temp-qnty where temp-qnty.id-ing = temp-ing.gds-code :
      sss = sss + temp-qnty.qnty .
      temp-ing.itog = sss .
  end.
end.

  /* Итоговые суммы */
assign
  vv0 = ":                              :             :    ИТОГО    :"
  vv2 = ":------------------------------:-------------:-------------:"
.


   put stream outstream unformatted  vv2 space (0)   .
   for each temp-ing :
      put stream outstream unformatted  "---------------:".
   end.
   put stream outstream unformatted skip.

   put stream outstream unformatted  vv0 space (0)   .
   for each temp-ing :
      put stream outstream unformatted  string (temp-ing.itog,">>>>>>>>>>9.999" ) + ":" .
   end.
   put stream outstream unformatted skip.

   put stream outstream unformatted  vv2 space (0)   .
   for each temp-ing :
      put stream outstream unformatted  "---------------:".
   end.
   put stream outstream unformatted skip.
    num#str# = num#str# + 1.
    num#col# = 3.
    run macr_excel_char ( "ИТОГО"   , num#str# , num#col#   ) .
 /* по ингридиентам */
    for each temp-ing :
        num#col# = num#col# + 1.
        run macr_excel_dec ( temp-ing.itog   , num#str# , num#col#   ) .
    end.

end procedure. /* print-all-itog */


procedure PrintTitul :
  do  on error undo, return error return-value  :
  define variable cc as integer no-undo .
  define variable tt as integer no-undo .
  define variable pp as integer no-undo .

 /* ---------------- Создание заголовка :--------------------------------------------------------------------------- */
    { rep/r-cliprp.i }
PUT STREAM OutStream UNFORMATTED
space (5) string ( CAPS ( This_Object.obj-name ) + "  (" + string (This_Object.obj-code) + ")" )  skip.

 PUT STREAM OutStream UNFORMATTED
        space (5) string ( "РАСКЛАДКА ПРОДУКТОВ" ) +
                 string ( " C " )  + string (x-date-start, "99/99/9999" )  +
                 string ( " ПО " ) + string (x-date-end, "99/99/9999" )
                 format "X(160)"  skip
                 "Дата составления " + cur-time-date() at 165 skip
      .

assign
  vv0 = ":                              :             : Количество  :"
  vv1 = ":         Готовые блюда        : Количество  :    порций   :"
  vv2 = ":------------------------------:-------------:-------------:"
.


   put stream outstream unformatted  vv2 space (0)   .
   for each temp-ing :
      put stream outstream unformatted  "---------------:".
   end.
   put stream outstream unformatted skip.

   put stream outstream unformatted  vv0 space (0)   .
   for each temp-ing :
      put stream outstream unformatted  string (substring (temp-ing.gds-name,1,15),"x(15)" ) + ":" .
   end.
   put stream outstream unformatted skip.

   put stream outstream unformatted  vv1 space (0)   .
   for each temp-ing :
      put stream outstream unformatted  string (substring (temp-ing.gds-name,16,15),"x(15)" ) + ":" .
   end.
   put stream outstream unformatted skip.

   put stream outstream unformatted  vv2 space (0)   .
   for each temp-ing :
      put stream outstream unformatted  "---------------:".
   end.
   put stream outstream unformatted skip.




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
    cc = num#str# .
    run macr_excel_char ( "РАСКЛАДКА ПРОДУКТОВ"  +
                 string ( " C " )  + string (x-date-start, "99/99/9999" )  +
                 string ( " ПО " ) + string (x-date-end, "99/99/9999" )
          , num#str# , num#col#   ) .

    num#str# = num#str# + 1.
    num#col# = 2.
    run macr_excel_char ( string ( CAPS ( This_Object.obj-name ) + "  (" + string (This_Object.obj-code) + ")" )   , num#str# , num#col#   ) .
    run macr_cell_format
     ( 20    ,    /* p-size     */
      true  ,    /* p-bold     */
      false  ,   /* p-italic   */
      ?    ,     /* p-color-bg */
      cc ,       /* p-row      */
      1 ,        /* p-col      */
      num#str# , /* p-row-2    */
      2 ) .      /* p-col-2    */

    num#str# = num#str# + 1.
    num#col# = 11.
    run macr_excel_char ("Дата составления " + cur-time-date()   , num#str# , num#col#   ) .

/* шапка */
    num#str# = num#str# + 1.
    num#col# = 1.
    tt = num#str#  .
    run macr_excel_char ( "Наименование блюда"   , num#str# , num#col#   ) .
    run macr_cell_size  ( 40 , ? , num#str# , num#col# , ?, ? ) .
    run macr_cell_format
     ( 12    ,    /* p-size     */
      true  ,    /* p-bold     */
      false  ,   /* p-italic   */
      ?    ,     /* p-color-bg */
      pp,        /* p-row      */
      1 ,        /* p-col      */
      num#str# , /* p-row-2    */
      3 ) .      /* p-col-2    */

    num#col# = num#col# + 1.
    run macr_excel_char ( "Количество"   , num#str# , num#col#   ) .
    run macr_cell_size  ( 15 , ? , num#str# , num#col# , ?, ? ) .
    run macr_cell_format
     ( 12    ,    /* p-size     */
      true  ,    /* p-bold     */
      false  ,   /* p-italic   */
      ?    ,     /* p-color-bg */
      pp,        /* p-row      */
      1 ,        /* p-col      */
      num#str# , /* p-row-2    */
      3 ) .      /* p-col-2    */

    num#col# = num#col# + 1.
    run macr_excel_char ( "Количество порций"   , num#str# , num#col#   ) .
    run macr_cell_size  ( 20 , ? , num#str# , num#col# , ?, ? ) .
    run macr_cell_format
     ( 12    ,    /* p-size     */
      true  ,    /* p-bold     */
      false  ,   /* p-italic   */
      ?    ,     /* p-color-bg */
      pp,        /* p-row      */
      1 ,        /* p-col      */
      num#str# , /* p-row-2    */
      3 ) .      /* p-col-2    */


     put  stream macr_excel unformatted
       substitute ('select("r&1c&2:r&3c&4")' , tt , 1 , num#str# ,  num#col# ) + {&new-line}  +
       'BORDER(2 , 2 , 2 , 2 , 2 , ,0,0,0,0,0) '  + {&new-line} +
       'ALIGNMENT(3 , , 4 , 4 ,)'  + {&new-line}
       .

 /* по ингридиентам */
    for each temp-ing :
        num#col# = num#col# + 1.
        run macr_excel_char ( temp-ing.gds-name   , num#str# , num#col#   ) .
        run macr_cell_size  ( 20 , ? , num#str# , num#col# , ?, ? ) .
       run macr_cell_format
         ( 12    ,    /* p-size     */
          true  ,    /* p-bold     */
          false  ,   /* p-italic   */
          ?    ,     /* p-color-bg */
          num#col#,        /* p-row      */
          num#str# ,        /* p-col      */
          num#str# , /* p-row-2    */
          num#col# ) .      /* p-col-2    */

        put  stream macr_excel unformatted
          substitute ('select("r&1c&2:r&3c&4 ")' , num#str# , num#col# , num#str# ,  num#col# ) + {&new-line}  +
          'BORDER(2 , 2 , 2 , 2 , 2 , ,0,0,0,0,0) '  + {&new-line} +
          'ALIGNMENT(3 , , 4 , 4 ,)'  + {&new-line}
          .

    end.

    /* ... конец создания заголовка. --- */
  end.
end procedure. /* PrintTitul */


procedure PrintPodval :
  do on error undo, return error return-value  :

    /* ... конец создания Подвал. --- */
  end.
end procedure. /* PrintPodval */



PROCEDURE on-same-page :
  define input parameter p-line-number as integer  no-undo .
  if p-line-number > page-size ( OutStream ) then return .
  if line-counter ( OutStream ) + p-line-number > page-size ( OutStream ) then  page stream OutStream .
end procedure. /* on-same-page */


procedure make-tt :
  do
  on error undo, return error return-value
  :
define variable sum-fact-qnty as decimal no-undo .
define variable sum-porc as decimal no-undo .
define variable sum-netto as decimal no-undo .

for each fbr-doc no-lock   where
            /*            fbr-doc.doc-type   = {&expense} and */
                        fbr-doc.status_    = {&fact} and
                        fbr-doc.obj-type   = obj-list.obj-type and
                        fbr-doc.obj-code   = obj-list.obj-code and
                        fbr-doc.fact-date  >= x-date-start and
                        fbr-doc.fact-date  <= x-date-end
                        :

    for each fbr-line no-lock  where fbr-line.doc-code  = fbr-doc.doc-code ,
        first fbr-recipe no-lock where fbr-recipe.recipe-code = fbr-line.recipe-code and
                                       fbr-recipe.doc-code    = fbr-line.doc-code and
                                    (   fbr-recipe.recipe-type = {&manufacturing} or
                                       fbr-recipe.recipe-type = {&gathering} )
     :
    for each goods no-lock where          goods.artic     = fbr-line.artic         and
                                          goods.prod-code = fbr-line.prod-code     and
                                          goods.prod-type = fbr-line.prod-type  :


    if  fbr-line.is-comp = true  /* составной */  then do:
        sum-fact-qnty = sum-fact-qnty + fbr-line.fact-qnty.
        find first temp-bl where temp-bl.gds-code = goods.gds-code no-error .
          if not available temp-bl then do:
             create temp-bl .
             sum-fact-qnty =  0 .
             sum-porc = 0.
             sum-netto = 0.
          end.
          else do:
            sum-fact-qnty =  temp-bl.qnty     .
            sum-porc      = temp-bl.qnty-porc .
            sum-netto     = temp-bl.qnty-netto .
          end.
            sum-fact-qnty = sum-fact-qnty + fbr-line.fact-qnty .
            sum-porc      = sum-porc    +  (fbr-recipe.portion-qnty  * fbr-line.fact-qnty ).
            sum-netto     = sum-netto   +  ( fbr-recipe.qnty * fbr-line.fact-qnty ).
          assign
            temp-bl.artic       = goods.artic
            temp-bl.prod-type   = goods.prod-type
            temp-bl.prod-code   = goods.prod-code
            temp-bl.gds-name    = goods.gds-name
            temp-bl.gds-code    = goods.gds-code
            temp-bl.qnty        = sum-fact-qnty
            temp-bl.s-porc      = sum-porc
            temp-bl.qnty-porc   = sum-fact-qnty * sum-porc / sum-netto
            temp-bl.qnty-netto  = sum-netto
          .

             /* message "блюдо" goods.gds-name skip
                      "doc-code"  fbr-line.doc-code
                      skip
                       sum-netto    skip                                             
                       fbr-recipe.qnty  skip
                       temp-bl.qnty-netto skip
                       temp-bl.qnty-porc
                      .
                */
            run make-sum  (
                  input  fbr-line.doc-code,
                  input  fbr-line.recipe-code,
                  input  goods.gds-code     ).

    end.
    else do: /* не составной */
        find first temp-ing where temp-ing.gds-code = goods.gds-code no-error .
          if not available temp-ing then do:
                                         n-c = n-c + 1.
                                         create temp-ing .
                                         end.
          assign
            temp-ing.artic       = goods.artic
            temp-ing.prod-type   = goods.prod-type
            temp-ing.prod-code   = goods.prod-code
            temp-ing.gds-name    = goods.gds-name
            temp-ing.gds-code    = goods.gds-code
          .
    end.

               end.
           end.
      end.


  end. /* do */
 end procedure. /* make-tt */



procedure make-sum :
do
on error undo, return error return-value
 :

define input parameter x-doc-code like fbr-line.doc-code no-undo . /*  рецепт */
define input parameter x-recipe like fbr-line.recipe-code no-undo . /*  рецепт */
define input parameter x-id as integer no-undo . /* блюдо */

define buffer comp_fbr-doc  for fbr-doc.
define buffer comp_fbr-line for fbr-line.
define buffer comp_recipe   for fbr-recipe.
define buffer comp_recipe-gds   for fbr-recipe-gds.
define buffer comp_goods for goods .
define variable tt-sum as decimal no-undo .

for each comp_fbr-doc no-lock   where
                        comp_fbr-doc.doc-code    = x-doc-code
                        :
     for each comp_recipe-gds no-lock where
              comp_recipe-gds.doc-code    = comp_fbr-doc.doc-code      and
              comp_recipe-gds.recipe-code = x-recipe
              :

    for each comp_fbr-line no-lock  where
              comp_fbr-line.doc-code      = comp_fbr-doc.doc-code and
              comp_fbr-line.recipe-code   = x-recipe and
              comp_fbr-line.artic       = comp_recipe-gds.artic         and
              comp_fbr-line.prod-code   = comp_recipe-gds.prod-code     and
              comp_fbr-line.prod-type   = comp_recipe-gds.prod-type
              :

    for each comp_goods no-lock where
             comp_goods.artic     = comp_fbr-line.artic         and
             comp_goods.prod-code = comp_fbr-line.prod-code     and
             comp_goods.prod-type = comp_fbr-line.prod-type
             :


        find first temp-qnty where
                   temp-qnty.id-bl = x-id and
                   temp-qnty.id-ing = comp_goods.gds-code
                   no-error .
          if not available temp-qnty then do:
              create temp-qnty .
              tt-sum = 0.
              end.
              else  tt-sum = temp-qnty.qnty.

         tt-sum = tt-sum  + comp_fbr-line.fact-qnty .
          assign
            temp-qnty.id-bl  = x-id
            temp-qnty.id-ing = comp_goods.gds-code
            temp-qnty.qnty   = tt-sum
          .
          /*
             message "ing" comp_goods.gds-name skip
                       comp_fbr-line.doc-code  skip
                       comp_fbr-line.fact-qnty skip
                      "накопит" temp-qnty.qnty
                      .
                      */
          end.
        end.
    end.
end.


 end. /* do */
end procedure. /* make-sum */

{ rep/r-libmcr.i macr_excel         }