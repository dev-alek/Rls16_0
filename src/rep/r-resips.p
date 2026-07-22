block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-resips.p $
$Archive: rep/r-resips.p $

Реестр рецептов блюд


Автор: Чернова Светлана Александровна
Дата создания: 09/12/05
Author: Svetlana Chernova
Creation date: 09/12/05

Creation date: 04/06/04 6:57

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-resips.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-resips.p $":U .
define variable vss-description as character no-undo init "Реестр рецептов блюд".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i   }
{ cmp/r-page1.i  }
{ rep/rep-bt.i  }
{ rep/r-sym.i    }
{ cmp/breakstr.i }
{ rep/r-cliprp.i def }
{ gbl/paramls.i  }
{ rep/f-fdec.i   }
{ trg/partslib.i }
{ str/fbrlib.i   }

  &scop gds-len 40
define input parameter p-SortType as character no-undo .

 do
 on error undo, return error return-value
 :

define variable   sort-name   as logical no-undo.
define variable   sort-gr     as logical no-undo.
define variable   print-graft as logical no-undo.   /* "Отладочная печать" */
define variable   summ as decimal no-undo .
define variable pp-r as character no-undo .
sort-gr     = true  .
sort-name   = false .
print-graft = true .

&Scop Sort-pole if sort-name then  temp-str.gds-name Else string(temp-str.np,"999999999")

define variable sort-group as logical   no-undo .
if sort-gr                  then assign sort-group = yes .
else                             assign sort-group = no .


DEFINE temp-table temp-str no-undo
  field  nn           as integer
  field  fact-date    like fbr-doc.fact-date
  field  doc-code     like  fbr-doc.doc-code
  field  recipe-code  like  recipe.recipe-code
  field  gds-name     like  goods.gds-name
  field  gds-code     like  goods.gds-code
  field  artic        like  goods.artic
  field  prod-type    like  goods.prod-type
  field  prod-code    like  goods.prod-code
  field  crsa         AS DECIMAL
  field  cost         as decimal
  field  dis          as decimal
  field  dis-proc     as decimal
  field  porc         as decimal
  field  ei            as char

  index pi   nn
  index pi1  FACT-DATE doc-code
  index pi2  recipe-code FACT-DATE
  index pi3  gds-name recipe-code FACT-DATE
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

&scop mmm  158


DEFINE FRAME plan-menu
    sym1                  COLUMN-LABEL ":!:!:" space(0)
    temp-str.nn           column-label " !   №   ! п/п  "  format ">>>>>>9"     space(0)
    sym2                  COLUMN-LABEL ":!:!:" space(0)
    temp-str.fact-date    column-label "Дата!документа!пр-ва"              space(0)
    sym3                  COLUMN-LABEL ":!:!:" space(0)
    temp-str.doc-code     column-label "№!документа!пр-ва"                 space(0)
    sym4                  COLUMN-LABEL ":!:!:" space(0)
    temp-str.gds-name     column-label " !Название блюда! "                space(0)
    sym5                  COLUMN-LABEL ":!:!:" space(0)
    temp-str.ei           column-label "Ед.!изм.! "  format "x(4)"         space(0)
    sym6                  COLUMN-LABEL ":!:!:" space(0)
    temp-str.crsa         column-label  "Цена !реализации !за 1 ед.изм."   space(0)
    sym7                  COLUMN-LABEL ":!:!:" space(0)
    temp-str.cost         column-label  "Учетная !цена по до-!кументу"     space(0)
    sym8                  COLUMN-LABEL ":!:!:" space(0)
    temp-str.dis          column-label  " !Наценка ! "                     space(0)
    sym9                  COLUMN-LABEL ":!:!:" space(0)
    temp-str.dis-proc     column-label  "%   !наценки ! "                  space(0)
    sym10                 COLUMN-LABEL ":!:!:" space(0)
    temp-str.porc         column-label  "Количество!в ед.изм.!"            space(0)
    sym11                 COLUMN-LABEL ":!:!:" space(0)
    temp-str.recipe-code  column-label  " ! № рецепта ! "                  space(0)
    sym12                 COLUMN-LABEL ":!:!:" space(0)

    HEADER
    string( "Лист " + string( PAGE-NUMBER(OutStream) , ">>>>9") ) AT 160 format "X(13)" SKIP
    Line format "X({&mmm})" AT 1
    with width {&DOS_CW_2} down stream-io use-text  NO-BOX .



  if session:set-wait-state("compiler") then.

  { cmp/open-out.i STREAM OutStream " " {&LS_PS_A4}  }
  define variable v-prn0 as character no-undo .

  assign
    Line    = fill("-", 230)
    UndLine = fill("_", 230)
    LineBuf = fill("_", 240)
  .

  IF var-report-r-b = "rubl" THEN Assign pp-r = "{&abbr_rub}".
                             Else Assign pp-r = "баз.вал" .
define variable varobj-date as date no-undo .
   { gbl/curobjdt.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      varobj-date
      no-error
    }

{ rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
{ rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */
/*-----------------------------------------------------------------------------------------------------------------------*/
v-ind = 0    .
 /* создаем временный файл */
    Output stream Macr_Excel  close .
    num#str# = 0 .
    run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
    output stream macr_excel to value(v-file-name)   .
    v-ind = v-ind + 1.


FORM with frame plan-menu .
define variable v-type-goods as character no-undo .
define variable v-ves        as logical no-undo .
run PrintTitul in this-procedure .
/*
for each gds-list no-lock :


      if not can-find (first  fbr-recipe where
                      fbr-recipe.recipe-type = {&manufacturing}
                and  fbr-recipe.prod-type = gds-list.prod-type
                and  fbr-recipe.prod-code = gds-list.prod-code
                and  fbr-recipe.artic =     gds-list.artic no-lock ) then next .
      if not can-find ( first fbr-gds-obj  where
                      fbr-gds-obj.obj-type = obj-list.obj-type
                and  fbr-gds-obj.obj-code = obj-list.obj-code
                and  fbr-gds-obj.gds-code = gds-list.gds-code
                and (fbr-gds-obj.is-menu = true
                or   fbr-gds-obj.is-semi-finished = true )
                    no-lock ) then next .

      for each temp-str   : delete temp-str .   end.

 for each fbr-line no-lock  where fbr-line.artic     = gds-list.artic and
                                  fbr-line.prod-code = gds-list.prod-code and
                                  fbr-line.prod-type = gds-list.prod-type  and
                                  fbr-line.is-comp = true   ,
        first fbr-recipe no-lock where fbr-recipe.recipe-code =  fbr-line.recipe-code  and
                                       fbr-recipe.doc-code    =  fbr-line.doc-code  and
                                       fbr-recipe.recipe-type = {&manufacturing} ,
         first fbr-doc no-lock   where
                                fbr-doc.doc-code   = fbr-line.doc-code and
                                fbr-doc.obj-type   = obj-list.obj-type and
                                fbr-doc.obj-code   = obj-list.obj-code and
                                fbr-doc.fact-date  >= x-date-start and
                                fbr-doc.fact-date  <= x-date-end  :
 end.

 end.
 */

  /* сначала заполняем таблицу */
  run make-tt.
  /* теперь печать */



  case p-sorttype :
    when "sort-doc-code" then do:
        for each temp-str no-lock  use-index pi1 :
            run print-line in this-procedure .
        end.
    end.
    when "sort-recipe-code" then do:
        for each temp-str no-lock  use-index pi2  :
            run print-line in this-procedure .
        end.
    end.
    when "sort-name" then do:
        for each temp-str no-lock use-index pi3  :
            run print-line in this-procedure .
        end.
    end.
  end case.

  run print-all-itog in this-procedure .
  /* ... Подвал. --- */
  run on-same-page in this-procedure (input 11) .
  run PrintPodval in this-procedure .
  /* page stream OutStream . */

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
        ,input "2,3,4,5,11"
        ) .

  run end-proc .

   define variable v-user-action as character no-undo .
   define variable v-printed as logical   no-undo .
   define variable DisabledOptions as integer   no-undo .
   DisabledOptions = 8 .

   run gbl/prnfilen.w
     (input  ""
     ,input  DisabledOptions
     ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
     ,input 7
     ,output v-user-action
     ,output v-printed
     ) .

end.

/* *************************************************************************************************** */
procedure print-line :
  do on error undo, return error return-value :
  define buffer buf_fbr-line       for fbr-line .
  define buffer buf_fbr-recipe-gds for fbr-recipe-gds .
  define buffer buf_recipe-gds     for recipe-gds .
  define buffer buf_fbr-recipe     for fbr-recipe .
  define variable p-norma as decimal format "->>>>>>>>>9.999"  no-undo .
  define variable p-price as decimal format ">>>>>>>>>>9.99" no-undo .
  define variable p-sum   as decimal format "->>>>>>>>>9.99"  no-undo .
  define variable s-plus  as logical init false  no-undo .
  define variable s-minus as logical init false no-undo .
  define variable var-season-qnty1 as decimal no-undo .

  assign
     Lines_Counter = Lines_Counter + 1
    .

  if line-counter( OutStream ) + 2 > page-size( OutStream ) then page stream OutStream.

  if line-counter( OutStream ) < Tmp_Counter then
    assign
    .

  assign
    Tmp_Counter  = line-counter( OutStream )
    num-ln = num-ln + 1
  .

  if line-counter( OutStream ) + j > page-size( OutStream ) then  PAGE STREAM OutStream.

num#str# = num#str# + 1.
num#col# = 1.
run macr_excel_char( num-ln      , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char(  string(temp-str.fact-date , "99/99/9999") , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char(     temp-str.doc-code  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char(     temp-str.gds-name  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char(     temp-str.ei        , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec (round(temp-str.crsa , 2)     , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec (round(temp-str.cost  , 2)    , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec (round(temp-str.dis   , 2)    , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec (round(temp-str.dis-proc, 2)  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec (round(temp-str.porc   , 3)   , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char(      temp-str.recipe-code , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .

 display stream OutStream
    num-ln @ temp-str.nn                sym1
    temp-str.fact-date         sym2
    temp-str.doc-code          sym3
    temp-str.gds-name          sym4
    temp-str.ei                sym5
    temp-str.crsa              sym6
    temp-str.cost              sym7
    temp-str.dis               sym8
    temp-str.dis-proc          sym9
    temp-str.porc              sym10
    temp-str.recipe-code       sym11
                               sym12
    with frame plan-menu.
    down stream OutStream 1 with frame plan-menu.

  end.
end procedure. /* print-line */



procedure print-all-itog :
  /* Итоговые суммы */
 PUT STREAM OutStream UNFORMATTED
      line format "x({&mmm})" skip.

end procedure. /* print-all-itog */


procedure PrintTitul :
  do  on error undo, return error return-value  :
  define variable cc as integer no-undo .
  define variable tt as integer no-undo .
  define variable pp as integer no-undo .

    /* ---------------- Создание заголовка :--------------------------------------------------------------------------- */
 PUT STREAM OutStream UNFORMATTED
        space(5) string( caps(reportname) ) +
                 string( " C " )  + string(x-date-start, "99/99/9999" )  +
                 string( " ПО " ) + string(x-date-end, "99/99/9999" )
                 format "X(160)"  skip
                 "Дата составления " + cur-time-date() at 165 skip
      .
      num#str# = num#str# + 1 .
      num#col# =  1 .

      run macr_excel_char_with_format( caps(reportname) +
                 string( " C " )  + string(x-date-start, "99/99/9999" )  +
                 string( " ПО " ) + string(x-date-end, "99/99/9999" )
      , num#str# , num#col#  ).
      run macr_cell_format
          ( 12    ,     /* p-size */
            true  ,     /*p-bold   */
            false ,     /*p-italic */
            ?     ,     /*p-color  */
            num#str# ,  /*p-row    */
            num#col# ,  /*p-col    */
            ? ,         /*p-row-2  */
            ?         ) . /*p-col-2 */

define variable l-ii  as integer no-undo .
define variable l-jj  as integer no-undo .
define variable l-len as integer no-undo .
define variable l-m   as integer no-undo .

&scop var-print-n    do l-ii = 1 to num-entries( ~{&var-str-n} , "~{&new-line}"  )    :  ~
      l-len = length (entry( l-ii , ~{&var-str-n}  , "~{&new-line}")) .                 ~
      l-m = integer( l-len / 220 ) + 1 .                                                ~
      do l-jj = 1 to  l-m  :                                                            ~
          num#str# = num#str# + 1 .                                                     ~
          run macr_excel_char_with_format(                                                          ~
              substring(entry( l-ii , ~{&var-str-n}  , "~{&new-line}") , (( 220 * l-jj ) - 219 )  , 220 )  , num#str# , num#col# ) .~
          PUT STREAM OutStream UNFORMATTED substring(entry( l-ii , ~{&var-str-n}  , "~{&new-line}") , (( 220 * l-jj ) - 219 )  , 220 )  ~
          skip.  ~
      end.                                                                                                       ~
  end.

&scop var-str-n  str1
{&var-print-n }
&scop var-str-n  str2
{&var-print-n }
&scop var-str-n  str3
{&var-print-n }
&scop var-str-n  str4
{&var-print-n }
&scop var-str-n  reportheader
{&var-print-n }



  num#str# = num#str# + 1.
  num#col# = 1.

    run proc-print-header .
    /*
     put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , tt , 1 , num#str# ,  num#col# ) + {&new-line}  +
       'BORDER( 2 , 2 , 2 , 2 , 2 , ,0,0,0,0,0) '  + {&new-line} +
       'ALIGNMENT(3 , , 4 , 4 ,)'  + {&new-line}
       .
    put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , pp , 1 , pp ,  3 ) + {&new-line}  +
       'BORDER( 2, , , , , , , , , , ) '  + {&new-line} .
      */
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
  if p-line-number > page-size( OutStream ) then return .
  if line-counter( OutStream ) + p-line-number > page-size( OutStream ) then  page stream OutStream .
end procedure. /* on-same-page */


procedure make-tt :
  do
  on error undo, return error return-value
  :
define buffer buf_fbr-doc for fbr-doc.
define buffer buf_fbr-line for fbr-line.
define variable ii as integer no-undo .
define buffer buf_recipe for recipe.
define buffer buf_goods for goods.


for each  buf_fbr-doc no-lock where
          buf_fbr-doc.host-code  = v-cntxt-host-code-obj and
          buf_fbr-doc.fact-date <= x-date-end  and
          buf_fbr-doc.fact-date >= x-date-start
          break by buf_fbr-doc.fact-date
    on error undo, return error :

    run fbrlib-put-in-order-recipe (input buf_fbr-doc.doc-code ) .

    for each temp_recipe-order where temp_recipe-order.recipe-code <> ""  break by temp_recipe-order.order
        on error undo, return error :
        find first buf_recipe no-lock where buf_recipe.recipe-code = temp_recipe-order.recipe-code no-error .
        if error-status :error then
           message vss-workfile vss-revision vss-description skip
                  "Ошибка поиска recipce № " temp_recipe-order.recipe-code skip
                   skip
                   error-status :get-message(1) skip
                   return-value skip
                   view-as alert-box error
           .

        if buf_recipe.recipe-type = {&manufacturing} then do:

            find first buf_goods no-lock
                where buf_goods.artic      = buf_recipe.artic
                  and buf_goods.prod-type  = buf_recipe.prod-type
                  and buf_goods.prod-code  = buf_recipe.prod-code .
            find first buf_fbr-line no-lock where
                      buf_fbr-line.artic        = buf_recipe.artic
                  and buf_fbr-line.prod-type    = buf_recipe.prod-type
                  and buf_fbr-line.prod-code    = buf_recipe.prod-code
                  and buf_fbr-line.recipe-code  = buf_recipe.recipe-code
                  and buf_fbr-line.doc-code     = buf_fbr-doc.doc-code
                  .


           ii = ii + 1 .
           create temp-str.
           assign
             temp-str.nn           = ii
             temp-str.fact-date    = buf_fbr-doc.fact-date
             temp-str.doc-code     = buf_fbr-doc.doc-code
             temp-str.recipe-code  = buf_recipe.recipe-code
             temp-str.gds-name     = buf_goods.gds-name
             temp-str.gds-code     = buf_goods.gds-code
             temp-str.artic        = buf_goods.artic
             temp-str.prod-type    = buf_goods.prod-type
             temp-str.prod-code    = buf_goods.prod-code
             temp-str.ei           = buf_goods.unit-base
             temp-str.crsa         = buf_fbr-line.price-sale
             temp-str.cost         = buf_fbr-line.price-rubl
             temp-str.dis          = temp-str.crsa - temp-str.cost
             temp-str.dis-proc     = temp-str.dis * 100 / temp-str.cost
             temp-str.porc         = buf_fbr-line.fact-qnty
            .
        end.
    end. /* for each */
end. /* for each */


  end. /* do */
 end procedure. /* make-tt */

{ rep/r-libmcr.i macr_excel         }