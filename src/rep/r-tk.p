block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-tk.p $
$Archive: rep/r-tk.p $

Документ Технологическая карта

Автор: Чернова Светлана Александровна
Дата создания: 09/15/05
Author: Svetlana Chernova
Creation date: 09/15/05

Creation date: 03/29/04 4:26

*/

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: r-tk.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/r-tk.p $":U .
def var vss-description as character no-undo init "Документ Технологическая карта    ".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i   }
{ cmp/r-page1.i  new }
{ cmp/breakstr.i }
{ rep/r-cliprp.i def }
{ trg/partslib.i }
{ str/fbrlib.i   }
{ gbl/getcntxt.i def }
{ ref/gds-attr.i }
{ ref/gdsoattr.i }
{ gbl/nutro.i    }

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-recid  as recid     no-undo.
define input parameter p-type as character no-undo .

define variable p-doc-code  as character no-undo .
define buffer main-buf_fbr-doc for fbr-doc.
define buffer main_recipe for recipe.

/* p-type = "recipe":U   */
  find  first main_recipe no-lock
   where recid(main_recipe) = p-recid
   no-error.
p-doc-code = main_recipe.recipe-code.
{ cmp/cr-objls.i main_recipe.obj-type main_recipe.obj-code no-error }

 do
 on error undo, return error return-value
 :
define stream  OutStream  .

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


define variable qnty as decimal   no-undo .
define variable sum  as decimal   no-undo .

define variable num-ln as integer   no-undo .

def var FullNameGds as character no-undo .
def var gds-str as char no-undo.
def var gds-str1 as char no-undo.
def var gds-str2 as char no-undo.
def var i as int no-undo.
def var j as int no-undo.
define variable Counter1 as integer init 0  no-undo .

def var LineBuf       as char    no-undo.
def var Line       as char    no-undo.
def var UndLine    as char    no-undo.

def var     Lines_Counter as   int  init 0  no-undo.
def var     Tmp_Counter   as   int  init 0  no-undo.

def var     tdoc-date     like fbr-pln.doc-date no-undo.
def var     tdoc-code     like fbr-pln.doc-code no-undo.

def var  abbr              as  char no-undo.
def var  pp-r                as  char no-undo.
define variable vv0 as character no-undo .
define variable vv1 as character no-undo .
define variable vv2 as character no-undo .

def var sym1 as char  init ":"   no-undo.
def var sym2 as char  init ":"   no-undo.
def var sym3 as char  init ":"   no-undo.
def var sym4 as char  init ":"   no-undo.
def var sym5 as char  init ":"   no-undo.
def var sym6 as char  init ":"   no-undo.
def var sym7 as char  init ":"   no-undo.
def var sym8 as char  init ":"   no-undo.
def var sym9 as char  init ":"   no-undo.
def var sym10 as char  init ":"   no-undo.
def var sym11 as char  init ":"   no-undo.
def var sym12 as char  init ":"   no-undo.
def var sym13 as char  init ":"   no-undo.
define variable netto    as decimal no-undo init 0.
define variable brutto   as decimal no-undo init 0.
define variable netto10  as decimal no-undo init 0.
define variable netto20  as decimal no-undo init 0.
define variable netto30  as decimal no-undo init 0.
define variable netto40  as decimal no-undo init 0.
define variable netto50  as decimal no-undo init 0.
define variable netto60  as decimal no-undo init 0.
define variable netto100 as decimal no-undo init 0.

define variable v-tk-calories      as decimal   no-undo .
define variable v-tk-protein       as decimal   no-undo .
define variable v-tk-carbohydrate  as decimal   no-undo .
define variable v-tk-fat           as decimal   no-undo .

define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.


&scop frame-name teh-card

DEFINE FRAME {&frame-name}
        sym1 column-label   ":!:!:" format "x(1)" space(0)
        recipe-gds.artic column-label " !Артикул! " format "X(16)" space(0)
        sym2 column-label   ":!:!:" format "x(1)" space(0)
        goods.gds-name COLUMN-LABEL " !Название товара! " FORMAT "X(40)" space(0)
        sym3 column-label   ":!:!:" format "x(1)" space(0)
        goods.unit-base column-label " Ед.! Изм.! " format "X(7)" space(0)
        sym4 column-label    ":!:!:" format "x(1)" space(0)
        brutto column-label  "Норма на !---------!брутто" format ">>>>9.999" space(0)
        sym5 column-label    " !-!:"              format "x(1)" space(0)
        netto column-label   "1 порцию !---------!нетто"     format ">>>>9.999" space(0)
        sym6 column-label    ":!:!:"              format "x(1)" space(0)
        netto10 column-label "   Расчет!---------!10" format ">>>>9.999" space(0)
        sym7 column-label    " !-!:" format "x(1)" space(0)
        netto20 column-label "количеств!---------!20" format ">>>>9.999" space(0)
        sym8 column-label    "а!-!:" format "x(1)" space(0)
        netto30 column-label " порций  !---------!30" format ">>>>9.999" space(0)
        sym9 column-label    " !-!:" format "x(1)" space(0)
        netto40 column-label " (нетто) !---------!40" format ">>>>9.999" space(0)
        sym10 column-label   " !-!:" format "x(1)" space(0)
        netto50 column-label "         !---------!50" format ">>>>9.999" space(0)
        sym11 column-label   " !-!:" format "x(1)" space(0)
        netto60 column-label "         !---------!60" format ">>>>9.999" space(0)
        sym12 column-label   " !-!:" format "x(1)" space(0)
        netto100 column-label "         !---------!100" format ">>>>9.999" space(0)
        sym13 column-label    ":!:!:" format "x(1)" space(0)
    HEADER
    Line format "X(157)" AT 1
    with width {&DOS_CW_2} down stream-io use-text .

define frame nutrition-frame
        sym1              column-label ":!:"                                format "x(1)"         space(0)
        v-tk-protein      column-label "Белки, г! "                         format ">>>>>>>9.9"   space(0)
        sym2              column-label ":!:"                                format "x(1)"         space(0)
        v-tk-fat          column-label "Жиры, г! "                          format ">>>>>>>9.9"   space(0)
        sym3              column-label ":!:"                                format "x(1)"         space(0)
        v-tk-carbohydrate column-label "Углеводы, г! "                      format ">>>>>>>9.9"   space(0)
        sym4              column-label ":!:"                                format "x(1)"         space(0)
        v-tk-calories     column-label " Энергетическая! ценность, ккал "   format ">>>>>>>9.9"   space(0)
        sym5              column-label ":!:"                                format "x(1)"         space(0)
    HEADER
    Line format "X(52)" AT 1
    with width {&DOS_CW_2} down stream-io use-text .


  if session:set-wait-state("compiler") then.

  { gbl/getcntxt.i get " " p-mainmenu-handle }
  run get-report-num in p-mainmenu-handle (
      output g#report-num
  ).
  run get-quest-print in p-mainmenu-handle (
      output g#quest-print
  ).
  { cmp/open-out.i STREAM OutStream " " {&CP_PS}  }
  define variable v-prn0 as character no-undo .

  assign
    Line    = fill("-", 157)
    UndLine = fill("_", 157)
    LineBuf = fill("_", 157)
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

FORM with frame {&frame-name}  .
define variable v-type-goods as character no-undo .
define variable v-ves        as logical no-undo .

define buffer buf_init-goods for goods .
define variable ii as integer no-undo .
define variable v-se-qnty-brutto   as decimal no-undo .
define variable v-se-qnty-netto    as decimal no-undo .

for each recipe no-lock where   recipe.recipe-code    =  p-doc-code  :
      find first buf_init-goods no-lock where
                  buf_init-goods.artic      =  recipe.artic      and
                  buf_init-goods.prod-type  =  recipe.prod-type  and
                  buf_init-goods.prod-code  =  recipe.prod-code no-error .

   run PrintTitul .
      for each recipe-gds no-lock where recipe-gds.recipe-code = recipe.recipe-code
          on error undo, return error :
            FIND goods WHERE goods.prod-type = recipe-gds.prod-type AND
                             goods.prod-code = recipe-gds.prod-code AND
                             goods.artic = recipe-gds.artic NO-LOCK .

                            run get-brutto-netto-seson (
                             input  goods.artic
                            ,input  goods.prod-type
                            ,input  goods.prod-code
                            ,input  recipe-gds.recipe-code
                            ,output  v-se-qnty-brutto
                            ,output  v-se-qnty-netto
                            ) no-error .
                             if error-status :error then
                             message vss-workfile vss-revision vss-description skip
                                    "Ошибка get-brutto-netto-seson  " skip
                                     skip
                                     error-status :get-message(1) skip
                                     return-value skip
                                     view-as alert-box error
                             .

                             brutto   = v-se-qnty-brutto / recipe.portion-qnty .
                             netto    = v-se-qnty-netto  / recipe.portion-qnty .
                             netto10  = netto * 10  .
                             netto20  = netto * 20  .
                             netto30  = netto * 30  .
                             netto40  = netto * 40  .
                             netto50  = netto * 50  .
                             netto60  = netto * 60  .
                             netto100 = netto * 100 .

            DISPLAY stream OutStream
                            sym1 recipe-gds.artic
                            sym2 goods.gds-name
                            sym3 goods.unit-base
                            sym4 netto
                            sym5 brutto
                            sym6 netto10
                            sym9 netto20
                            sym10 netto30
                            sym11 netto40
                            sym12 netto50
                            sym13 netto60
                            sym7 netto100
                            sym8    with frame {&frame-name}  .
            DOWN stream OutStream 1 with frame {&frame-name}  .
            assign
              ii =  ii + 1
              brutto   = 0
              netto    = 0
              netto10  = 0
              netto20  = 0
              netto30  = 0
              netto40  = 0
              netto50  = 0
              netto60  = 0
              netto100 = 0
           .


      end. /* for each */

  put stream  OutStream  Line format "X(157)" AT 1 skip(2).

  run print-nutrition in this-procedure ( input recipe.artic
                                        , input recipe.prod-type
                                        , input recipe.prod-code
                                        ) .

  run on-same-page in this-procedure (input 11) .
  run PrintPodval in this-procedure .
  page stream OutStream .
end.

HIDE   STREAM OutStream FRAME {&frame-name} .
HIDE   stream OutStream FRAME BottomFrame .
HIDE   stream OutStream FRAME BottomFrame2 .
output stream OutStream CLOSE .

{ rep/repfrm.i off } /* Показать окно информации о текущем процессе */
  define variable v-user-action as character no-undo .
  define variable v-printed as logical   no-undo .

   if p-type = "recipe":U then
       run gbl/prnfilen.w
         (input  ""
         ,input  8
         ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
         ,input  7
         ,output v-user-action
         ,output v-printed
         ) .
   else do:
       { rep/q-print.i 8 }
   end.
end.

/* *************************************************************************************************** */

procedure PrintTitul :
  do  on error undo, return error return-value  :
 /* ---------------- Создание заголовка :--------------------------------------------------------------------------- */
define variable v-host-code    as integer      no-undo.
define variable v-host-name    as character    no-undo.
{ gbl/hostname.i
    v-cntxt-obj-type
    v-cntxt-obj-code
    v-host-code
    v-host-name
}
PUT STREAM OutStream UNFORMATTED
CAPS( v-host-name )   format "x(30)"
skip "Название блюда   : " + CAPS( buf_init-goods.gds-name ) + " ( арт. " + buf_init-goods.artic + ")"  format "x(120)"
skip "Название рецепта : " + CAPS( recipe.recipe-name )                                    format "x(120)"
skip "Номер рецепта    : " +  string( recipe.recipe-code)                                   format "x(60)"
skip "Номер блюда по сборнику рецептур : " + string ( recipe.recipe-ref-num )             format "x(60)"
skip "Вес готового продукта в гр. : " + string (1000 * recipe.portion-weight )                 format "x(60)"
skip
.

 PUT STREAM OutStream UNFORMATTED
    space(50) string( " ТЕХНОЛОГИЧЕСКАЯ КАРТА "   )           skip
                      "УТВЕРЖДАЮ"              format "X(9)"  AT 120  skip
                      "______________________" format "X(20)" AT 120  skip
                      "______________________" format "X(20)" AT 120 "/___________________/"
                      "подпись"                               AT 120 "            расшифровка подписи"
                      skip
      .
 if p-type = "recipe":U then
 PUT STREAM OutStream UNFORMATTED
     "Дата составления " + cur-time-date()   at 120 skip   .
     else

 PUT STREAM OutStream UNFORMATTED
     "Дата составления " + p-type   at 120 skip   .



 define variable v-max as integer no-undo .
 define variable v-max-dop as integer no-undo .
 define variable v as integer no-undo .
 &scop m-max 225
 define variable vvv as character no-undo .

 &scop v-put ~
 v-max = ( integer (length(vvv) / {&m-max} ) ) . ~
 if (  length(vvv) modulo {&m-max}  ) > 0 then  v-max-dop = 1 . else v-max-dop = 0  . ~
 if vvv <> "" then do:  ~
    PUT STREAM OutStream UNFORMATTED         ~
    space(5) substring( vvv , 1 , {&m-max})  format "x({&m-max})"  skip. ~
    repeat v = 1 to v-max + v-max-dop : ~
        if substring( vvv , {&m-max} * v , {&m-max}) <> "" then ~
          PUT STREAM OutStream UNFORMATTED ~
          space(5) substring( vvv , {&m-max} * v , {&m-max})  format "x({&m-max})"  skip. ~
    end. ~
 end.

 PUT STREAM OutStream UNFORMATTED
 "Описание технологии приготовления :  "     format "x(60)"  skip.
 vvv =  recipe.recipe-technique.
 {&v-put}


 PUT STREAM OutStream UNFORMATTED
 "Показатели качества готовой продукции :  "    format "x(60)"  skip.
 vvv =  recipe.recipe-quality.
 {&v-put}


 PUT STREAM OutStream UNFORMATTED
 "Способ оформления блюда :  "    format "x(60)"  skip.
 vvv =  recipe.recipe-design.
 {&v-put}
    /* ... конец создания заголовка. --- */
  end.
end procedure. /* PrintTitul */


procedure PrintPodval :
  do on error undo, return error return-value  :
  define variable pp as integer no-undo .
  define variable rr as integer no-undo .

  PUT  STREAM OutStream
        skip (2)
      " Заведующий производством _______________________ " skip
      " Калькуляцию составил     _______________________ " skip
      .

    /* ... конец создания Подвал. --- */
  end.
end procedure. /* PrintPodval */



PROCEDURE on-same-page :
  define input parameter p-line-number as integer  no-undo .
  if p-line-number > page-size( OutStream ) then return .
  if line-counter( OutStream ) + p-line-number > page-size( OutStream ) then  page stream OutStream .
end procedure. /* on-same-page */



procedure get-brutto-netto-seson :
 do
 on error undo, return error return-value
 :
define input parameter p-artic     like  ub.goods.artic      no-undo.
define input parameter p-prod-type like  ub.goods.prod-type  no-undo.
define input parameter p-prod-code like  ub.goods.prod-code  no-undo.
define input parameter p-recipe-code like ub.recipe-gds.recipe-code no-undo.
define output parameter p-se-qnty as decimal no-undo .
define output parameter p-se-qnty-netto as decimal no-undo .

define buffer local-recipe-gds for  ub.recipe-gds  .
define buffer bf_goods for ub.goods.

define variable varcoeff as decimal no-undo.
find first bf_goods no-lock where
          bf_goods.artic     = p-artic and
          bf_goods.prod-type = p-prod-type and
          bf_goods.prod-code = p-prod-code no-error .
if error-status :error then return error .

find first local-recipe-gds no-lock where
          local-recipe-gds.recipe-code = p-recipe-code and
          local-recipe-gds.artic       = p-artic and
          local-recipe-gds.prod-type   = p-prod-type and
          local-recipe-gds.prod-code   = p-prod-code no-error .
if error-status :error then return error .


 run fbrlib-s-coeff-value in this-procedure
   (input bf_goods.gds-code,
    input varobj-date,
    input v-cntxt-obj-type,
    input v-cntxt-obj-code,
    output varcoeff
    ).




 /* Теперь в базе лежит уже с коэффициентом */
 varcoeff = 1.

 p-se-qnty =       local-recipe-gds.brutto-qnty * varcoeff.
 p-se-qnty-netto = local-recipe-gds.qnty        * varcoeff.

  /*
  message "коэф сезонный " varcoeff skip
   bf_goods.gds-name skip
  "brutto      " local-recipe-gds.brutto-qnty skip
  "netto       " local-recipe-gds.qnty  skip
  "brutto c.к " p-se-qnty             skip
  "netto  c.к " p-se-qnty-netto       skip

  .
  */
 end. /* do */
end procedure. /* get-brutto-seson */


procedure print-nutrition :
  define input  parameter p-artic     as character no-undo .
  define input  parameter p-prod-type as character no-undo .
  define input  parameter p-prod-code as integer   no-undo .

  define buffer buf_goods for ub.goods.

  define variable v-calories      as decimal   no-undo .
  define variable v-protein       as decimal   no-undo .
  define variable v-carbohydrate  as decimal   no-undo .
  define variable v-fat           as decimal   no-undo .

do
on error undo, return error return-value
:
  find first buf_goods no-lock
    where buf_goods.artic     = p-artic
      and buf_goods.prod-type = p-prod-type
      and buf_goods.prod-code = p-prod-code
  no-error .
  if not available buf_goods
  then do:
    message
      substitute( "Не найден товар &1 &2 &3"
                , p-artic
                , p-prod-type
                , p-prod-code
                )
    view-as alert-box error.
    return . /* --->>>--- */
  end. /* if not available buf_goods */

  run on-same-page in this-procedure (input 9) .

  run nutro_get-nutrition-info in this-procedure ( input  p-artic
                                                 , input  p-prod-type
                                                 , input  p-prod-code
                                                 , input  v-cntxt-obj-type
                                                 , input  v-cntxt-obj-code
                                                 , output v-calories
                                                 , output v-protein
                                                 , output v-carbohydrate
                                                 , output v-fat
                                                 ).

  put stream OutStream
    'Сведения о пищевой и энергетической ценности:':U skip
    'Пищевая и энергетическая ценность на 100 г. готового продукта':U skip
  .

  view frame nutrition-frame.
  display stream OutStream
  v-calories     @ v-tk-calories
  v-protein      @ v-tk-protein
  v-carbohydrate @ v-tk-carbohydrate
  v-fat          @ v-tk-fat
  sym1
  sym2
  sym3
  sym4
  sym5
  with frame nutrition-frame.
  put stream  OutStream  Line format "X(52)" at 1 skip(2).

end.

end procedure. /* print-nutrition */