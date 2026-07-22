block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-tk1.p $
$Archive: rep/r-tk1.p $

Документ Технологическая карта еще одна

Автор: Чернова Светлана Александровна
Дата создания: 10/31/05
Author: Svetlana Chernova
Creation date: 10/31/05


*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-tk1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-tk1.p $":U .
define variable vss-description as character no-undo init "Документ Технологическая карта еще одна ".
{ cmp/vssrevis.i }

define input parameter parparentproc as handle no-undo .
define input parameter p-recid  as recid     no-undo.
define input parameter p-type as character no-undo .

{ cmp/str-glbl.i  }
{ cmp/r-pril.i   }
{ cmp/r-page1.i  new }
my-handle = parparentproc .
{ rep/rep-bt.i   }
{ gbl/cur-time.i }
{ cmp/breakstr.i }
{ rep/r-cliprp.i def }
{ trg/partslib.i   }
{ str/fbrlib.i     }
{ ref/gds-attr.i }
{ ref/gdsoattr.i }
{ gbl/nutro.i    }


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
define variable  pp-r                as  char no-undo.
define variable vv0 as character no-undo .
define variable vv1 as character no-undo .
define variable vv2 as character no-undo .

define variable sym1 as char  init ":"   no-undo.
define variable sym2 as char  init ":"   no-undo.
define variable sym3 as char  init ":"   no-undo.
define variable sym4 as char  init ":"   no-undo.
define variable sym5 as char  init ":"   no-undo.
define variable sym6 as char  init ":"   no-undo.
define variable sym7 as char  init ":"   no-undo.
define variable sym8 as char  init ":"   no-undo.
define variable sym9 as char  init ":"   no-undo.
define variable sym10 as char  init ":"   no-undo.
define variable sym11 as char  init ":"   no-undo.
define variable sym12 as char  init ":"   no-undo.
define variable sym13 as char  init ":"   no-undo.
define variable netto    as decimal no-undo init 0.
define variable brutto   as decimal no-undo init 0.

define variable netto10  as decimal no-undo init 0.
define variable netto20  as decimal no-undo init 0.
define variable str as character no-undo .

define variable v-tk-calories      as decimal   no-undo .
define variable v-tk-protein       as decimal   no-undo .
define variable v-tk-carbohydrate  as decimal   no-undo .
define variable v-tk-fat           as decimal   no-undo .


define temp-table temp-str no-undo
field str-1 as character
field pr as logical
.

&scop frame-name teh-card

DEFINE FRAME {&frame-name}
        sym1 column-label   ":!:!:" format "x(1)" space(0)
        goods.gds-name COLUMN-LABEL " !Название продукта! " FORMAT "X(40)" space(0)
        sym2 column-label   ":!:!:" format "x(1)" space(0)
        brutto column-label  "Вес!брутто!в гр." format ">>>>9.999" space(0)
        sym3 column-label   ":!:!:" format "x(1)" space(0)
        netto column-label   "Вес нетто!и п/ф!в гр."     format ">>>>9.999" space(0)
        sym4 column-label    ":!:!:"              format "x(1)" space(0)
        netto10 column-label "Вес готового!продукта!в гр." format ">>>>9.999" space(0)
        sym5 column-label    ":!:!:"              format "x(1)" space(0)
        netto20 column-label "                !порций (кг) ! " format ">>>>>>>>>>>9.999" space(0)
        sym6 column-label    ":!:!:"              format "x(1)" space(0)
        str column-label "Правила приготовления и оформления блюда ! Требования к качеству ! " format "x(60)" space(0)
        sym7 column-label    ":!:!:"              format "x(1)" space(0)
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
  { gbl/getcntxt.i get }
  { cmp/open-out.i STREAM OutStream " " {&CP_PS}  }
  define variable v-prn0 as character no-undo .

  assign
    Line    = fill("-", 153)
    UndLine = fill("_", 153)
    LineBuf = fill("_", 153)
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
 netto20:label = "Вес нетто на " + string(recipe.portion-qnty)  .

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

                             brutto   = v-se-qnty-brutto * 1000 .
                             netto    = v-se-qnty-netto * 1000 .
                             netto10  = netto / recipe.portion-qnty  .
                             netto20  = v-se-qnty-netto   .
                             find next temp-str no-error .
                             if available temp-str then do:
                                  str = temp-str.str-1 .
                                  temp-str.pr = true .
                                  end.
                                  else str = "".
            DISPLAY stream OutStream
                            sym1 goods.gds-name
                                        sym2
                            netto when netto <> 0
                            sym3
                            brutto  when brutto <> 0
                            sym4
                            netto10  when netto10 <> 0
                            sym5
                            netto20 when netto20 <> 0
                            sym6
                            str
                            sym6 str
                            sym7
                            with frame {&frame-name}  .
            DOWN stream OutStream 1 with frame {&frame-name}  .
            assign
              ii =  ii + 1
              brutto   = 0
              netto    = 0
              netto10  = 0
              netto20  = 0
              str = ""
           .


      end. /* for each */
      for each temp-str where temp-str.pr = false  and temp-str.str <> "" and temp-str.str-1 <> ?:
       PUT STREAM OutStream UNFORMATTED ":" + string(temp-str.str-1,"x(60)") + ":"  at 92  format "x(62)"  skip .
      end.
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
define variable g#quest-print  as logical   no-undo .
define variable g#log as logical   no-undo .
run get-quest-print in parparentproc ( output g#quest-print ).
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

 define buffer buf_obj-clients for ub.clients  .
 find first buf_obj-clients no-lock where
      buf_obj-clients.obj-type = v-cntxt-obj-type and
      buf_obj-clients.obj-code = v-cntxt-obj-code no-error .
PUT STREAM OutStream UNFORMATTED
CAPS( v-cntxt-host-name-obj )     format "x(30)"  "Рецептура : "        + string ( recipe.recipe-ref-num )  at 60  format "x(60)"  skip
CAPS( buf_obj-clients.obj-name )  format "x(30)"  "Название блюда   : " + CAPS ( buf_init-goods.gds-name )  at 60  format "x(120)" skip
.

 PUT STREAM OutStream UNFORMATTED
    skip
    space(50) string( " ТЕХНОЛОГИЧЕСКАЯ КАРТА "   )           skip
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
 &scop m-max 60
 define variable vvv as character no-undo .

 &scop v-put ~
 v-max = ( integer (length(vvv) / {&m-max} ) ) .  ~
 if (  length(vvv) modulo {&m-max}  ) > 0 then  v-max-dop = 1 . else v-max-dop = 0  . ~
 if vvv <> "" then do:  ~
    create temp-str .       ~
    temp-str.str-1 = substring( vvv , 1 , {&m-max}) .  ~
    temp-str.pr = false  .  ~
    repeat v = 1 to v-max + v-max-dop    : ~
        if substring( vvv , ({&m-max} * v ) + 1 , {&m-max}) <> "" then do : ~
              create temp-str .       ~
              temp-str.str-1 = substring(vvv , ({&m-max} * v) + 1 , {&m-max}) .  ~
              temp-str.pr = false  . ~
              if temp-str.str-1 = ? then temp-str.str-1 = " " . ~
              temp-str.str-1 = REPLACE (temp-str.str-1 , chr(10) ,chr(32) ) . ~
              end.  ~
    end. ~
 end.

 create temp-str .
 temp-str.str-1  = "Описание технологии приготовления :  " .
 temp-str.pr = false  .
 vvv =  recipe.recipe-technique.
 {&v-put}


 create temp-str .
 temp-str.str-1  = "Показатели качества готовой продукции :  ".
 temp-str.pr = false  .
 vvv =  recipe.recipe-quality.
 {&v-put}


 create temp-str .
 temp-str.str-1  ="Способ оформления блюда :  " .
 temp-str.pr = false  .
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
      " Директор _______________________          "
      " Заведующий производством _______________________          "
      " Калькулятор _______________________ " skip
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

/*
 run fbrlib-s-coeff-value in this-procedure
   (input bf_goods.gds-code,
    input varobj-date,
    input v-cntxt-obj-type,
    input v-cntxt-obj-code,
    output varcoeff
    ).    */
   /* Теперь в базе лежит уже с коэффициентом */
 varcoeff = 1.

 p-se-qnty =       local-recipe-gds.brutto-qnty * varcoeff.
 p-se-qnty-netto = local-recipe-gds.qnty        * varcoeff.

 define buffer buf_units for ub.units  .

 find first buf_units no-lock where buf_units.unit-name = bf_goods.unit-base no-error .
 if lookup({&pieces}, buf_units.type) > 0  or lookup({&serial}, buf_units.type) > 0 then do:
    if bf_goods.wt-base = 0 or bf_goods.wt-base = ? then do:
        p-se-qnty =    0   .
        p-se-qnty-netto = 0 .
    end.
    else do:
        p-se-qnty-netto = bf_goods.wt-base * local-recipe-gds.qnty.
        p-se-qnty       = p-se-qnty-netto + (p-se-qnty-netto * local-recipe-gds.coeff-waste / 100) .
    end.
 end.


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