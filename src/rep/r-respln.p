block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-respln.p $
$Archive: rep/r-respln.p $

печатная форма  АРМ РЕСТОРАН

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 11/04/03 4:00

*/
 def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
 def var vss-author      as character no-undo init "$Author: expertek $":U .
 def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
 def var vss-workfile    as character no-undo init "$Workfile: r-respln.p $":U .
 def var vss-archive     as character no-undo init "$Archive: rep/r-respln.p $":U .
 def var vss-description as character no-undo init " печатная форма  АРМ РЕСТОРАН   ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i   }
{ cmp/breakstr.i }

{ rep/r-cliprp.i def }
  &scop gds-len 40

 do
 on error undo, return error return-value
 :

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter v-doc-rec  as recid no-undo .
define   /*  shared */ variable sort-name   as logical no-undo.
define   /*  shared */ variable sort-gr     as logical no-undo.
define   /*  shared */ variable print-graft as logical no-undo.   /* "Отладочная печать" */
define   /*  shared */ variable CostPrice   as logical no-undo .
define   /*  shared */ variable PrintScale  as logical no-undo .
define variable var-report-r-b as character no-undo .
{ gbl/curr-r-b.i  var-report-r-b }

  define variable summ as decimal no-undo .

  &Scop Sort-pole if sort-name then  temp-str.gds-name Else string(temp-str.np,"999999999")

  define variable sort-group as logical   no-undo .
  if sort-gr                  then assign sort-group = yes .
  else                             assign sort-group = no .


  DEFINE temp-table temp-str no-undo
    field   np                as integer
    field   grp-name          as  char
    field   gds-name          as  char
    field   b-code            as character
    field   norma             as decimal
    field   num-rcp           as char
    field   p-inp             as decimal
    field   qnty              as decimal
    field   price             as decimal
    field   stoim             as decimal
  .


  def stream Out-Stream.

  def buffer buf_clients for  clients .
  def buffer This_Object for  clients .
  def buffer buf_goods        for goods .

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
  def var  pp                as  char no-undo.


  def var sym1 as char  init ":"   no-undo.
  def var sym2 as char  init ":"   no-undo.
  def var sym3 as char  init ":"   no-undo.
  def var sym4 as char  init ":"   no-undo.
  def var sym5 as char  init ":"   no-undo.
  def var sym6 as char  init ":"   no-undo.
  def var sym7 as char  init ":"   no-undo.
  def var sym8 as char  init ":"   no-undo.
  def var sym9 as char  init ":"   no-undo.
  def var sym10 as char init ":"   no-undo.
  define variable g#report-num    as integer      no-undo.
  define variable g#quest-print   as logical      no-undo.
  define variable g#log           as logical      no-undo.

  DEFINE FRAME plan-menu
        sym1 column-label ":!:!:!:!:"  format "X(1)" space(0)
        Lines_Counter COLUMN-LABEL " ! !N!п/п! ":C5 format ">>>>9" space(0)
        sym2 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.gds-name COLUMN-LABEL " !----------------------------------------!Наименование и краткая!характеристика! ":C40
                                                                                   format "X(40)" space(0)
        Sym3 column-label " !-!:!:!:" format "X(1)" space(0)
        temp-str.b-code COLUMN-LABEL "  Блюдо и!---------!Код ! ! ":C9 format "X(9)" space(0)
        sym4 column-label " !-!:!:!:" format "X(1)" space(0)
        temp-str.norma COLUMN-LABEL "гарнир!------!Норма! ! ":C6 format ">>>>>9.<<<" space(0)
        Sym5 column-label " !-!:!:!:" format "X(1)" space(0)
        temp-str.num-rcp COLUMN-LABEL "!-----------!Номер блюд!по сборнику!рецептур":C11 format "x(11)" space(0)
        Sym6 column-label " !-!:!:!:" format "X(1)" space(0)
        temp-str.p-inp COLUMN-LABEL "!----------!Выход!одного!блюда":C10 format "->>>>>>>9.<<<" space(0)
        Sym7 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.qnty COLUMN-LABEL " ! !Количество! ! ":C13 format "->>>>>>>9.<<<" space(0)
        sym8 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.Price COLUMN-LABEL " ! !Цена! ! ":C13 format "->>>>>9.99" space(0)
        sym9 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.stoim COLUMN-LABEL " ! !Сумма! ! ":C15 format "->>>,>>>,>>9.99" space(0)
        sym10 column-label ":!:!:!:!:" format "X(1)" space(0)
       HEADER
        cur-time-print() AT 5 format "X(35)"
        string( "План-меню N " + tdoc-code + "  от  " + string ( tdoc-date , "99/99/9999" ) ) AT 47 format "X(63)"
        string( pp) AT 105 format "X(10)"
        string( "Лист " + string( PAGE-NUMBER(Out-Stream) , ">>>>9") ) AT 116 format "X(13)" SKIP
        Line format "X(132)" AT 1
        with width {&A4_CW0} down stream-io use-text NO-BOX.


  run get-report-num in p-mainmenu-handle (
      output g#report-num
  ).
  run get-quest-print in p-mainmenu-handle (
      output g#quest-print
  ).
  FIND fbr-pln WHERE recid(fbr-pln) = v-doc-rec NO-LOCK .
  assign
    tdoc-date = (if fbr-pln.status_ <> {&fact} then fbr-pln.doc-date else fbr-pln.fact-date)
    tdoc-code = fbr-pln.doc-code
  .


  if session:set-wait-state("compiler") then.

  { cmp/open-out.i STREAM Out-Stream " " {&CS_PS}  }

  define variable v-prn0 as character no-undo .

  assign
    Line    = fill("-", 230)
    UndLine = fill("_", 230)
    LineBuf = fill("_", 240)
  .

  IF var-report-r-b = "rubl" THEN Assign PP = "Цены {&abbr_rub}.".
                       Else Assign PP = "Цены  баз.вал." .


  FIND This_Object  WHERE This_Object.obj-type = fbr-pln.obj-type AND This_Object.obj-code = fbr-pln.obj-code  NO-LOCK.
  FIND clients      WHERE clients.obj-type     = {&cmp}           AND clients.obj-code     = fbr-pln.host-code NO-LOCK.



  FORM with frame plan-menu .
  run PrintTitul in this-procedure .
  /* по строкам документа-------------------------------------------------------------------------------------------- */
  { rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */

  /* сначала заполняем таблицу */
 run make-tt in this-procedure .


  /* теперь печать с сортировками */
    if sort-group = yes then do:
      for each temp-str no-lock break by temp-str.grp-name by {&Sort-pole} :
        if first-of( temp-str.grp-name) then run print-grp in this-procedure .
        run print-line in this-procedure .
        if last-of( temp-str.grp-name ) then  run print-grp-itog in this-procedure .
      end.
    end.        /* sort-gr = yes */
    else do:
      for each temp-str no-lock break by {&Sort-pole} :
        run print-line in this-procedure .
      end.
    end.        /* sort-gr <> yes */
  run on-same-page in this-procedure (input 5) .
  run print-all-itog in this-procedure .
  /* ... Подвал. --- */
  run PrintPodval in this-procedure .
  HIDE stream Out-Stream FRAME plan-menu .
  HIDE stream Out-Stream FRAME BottomFrame .
  HIDE stream Out-Stream FRAME BottomFrame2 .
  output stream Out-Stream CLOSE .
{ rep/repfrm.i off } /* Показать окно информации о текущем процессе */
{ rep/q-print.i 8  }
end.

/* *************************************************************************************************** */

procedure print-grp :
  do  on error undo, return error return-value  :
    DOWN stream Out-Stream 1 with FRAME plan-menu .
    PUT stream Out-Stream UNFORMATTED String("_______________" + TRIM(CAPS(temp-str.grp-name)) + UndLine)  FORMAT "x(132)"  skip  .
  end.
end procedure. /* print-grp */



procedure print-line :
  do on error undo, return error return-value :
  assign
     Lines_Counter = Lines_Counter + 1
     summ = summ  + temp-str.stoim
    .

  if line-counter( out-stream ) + 2 > page-size( out-stream ) then page stream out-stream.

  if line-counter( Out-Stream ) < Tmp_Counter then
    assign
    .

  assign
    Tmp_Counter  = line-counter( Out-Stream )
    num-ln = num-ln + 1
  .

  /* полное название на несколько строк */
  FullNameGds = temp-str.gds-name .
  gds-str1 = breakstr(FullNameGds, {&gds-len}, input-output  gds-str1, input-output gds-str2).
  assign j = 0.
  DO WHILE gds-str2 <> "" :
    assign gds-str = gds-str2.
    gds-str1 = breakstr(gds-str, {&gds-len}, input-output gds-str1, input-output gds-str2).
    assign j = j + 1.
  END. /* DO WHILE ... */
  if line-counter( Out-Stream ) + j > page-size( Out-Stream ) then  PAGE STREAM Out-Stream.

  gds-str1 = breakstr(FullNameGds, {&gds-len}, input-output  gds-str1, input-output gds-str2).

  display stream Out-Stream
    sym1     num-ln @ Lines_Counter
    sym2     temp-str.gds-name
    sym3     temp-str.b-code
    sym4     temp-str.qnty
    sym5     temp-str.stoim
    sym6     temp-str.price
    sym7     sym8 sym9 sym10
    temp-str.norma
    temp-str.num-rcp
    temp-str.p-inp
    with FRAME plan-menu.
    DOWN stream Out-Stream 1 with FRAME plan-menu.
  end.
end procedure. /* print-line */


procedure print-grp-itog :
  do on error undo, return error return-value :
  end.
end procedure. /* print-grp-itog */




procedure print-all-itog :
  underline stream Out-Stream
    sym1     Lines_Counter
    sym2     temp-str.gds-name
    sym3     temp-str.b-code
    sym4     temp-str.qnty
    sym5     temp-str.stoim
    sym6     temp-str.price
    sym7     sym8 sym9 sym10
    temp-str.norma
    temp-str.num-rcp
    temp-str.p-inp
    with FRAME plan-menu.
  DOWN stream Out-Stream 1 with FRAME plan-menu.

  /* Итоговые суммы */
      PUT STREAM Out-Stream "Итого  " +   string(summ , "->>>,>>>,>>9.99") + ":" format "X(23)"  at 110 skip.
  underline stream Out-Stream
            sym9
            sym10
            temp-str.stoim
    with FRAME plan-menu.
  DOWN stream Out-Stream 1 with FRAME plan-menu.

end procedure. /* print-all-itog */


procedure PrintTitul :
  do  on error undo, return error return-value  :
    /* ---------------- Создание заголовка :--------------------------------------------------------------------------- */

    { rep/r-cliprp.i }
      PUT STREAM Out-Stream
        space(5) "Унифицированная форма № ОП-2"  AT 5

        space(5) Line format  "X(19)" AT 117 skip

        space(5) "| "                 AT 117 {&g___code} AT 125 "|" AT 135 skip
        space(5) "Форма по ОКУД" format "X(14)" AT 103 "| " AT 117 "0330502" "|" AT 135 skip

        space(5) string( "{&abbr_inn_allshift} " + t-inn + " " + CAPS( clients.obj-name ) + " (" + string(clients.obj-code) + ")"
                              + t-addres + t-phone) format "X(60)"

            "по ОКПО" format "X(7)"  AT 109
                                "| " AT 117
          t-okpo format "X(16)" "|"  AT 135 skip

        space(5) string( CAPS( This_Object.obj-name ) + " (" + string(This_Object.obj-code) + ")" ) format "X(60)"

        "| " AT 117  "|" AT 135 skip

        space(5) "Вид деятельности по ОКДП" format "X(25)" AT 92 "| " AT 117 "|" AT 135 skip
                       "Вид операции" format "X(12)" AT 102       "| " AT 117 "|" AT 135 skip
                                                                  "| " AT 117 "|" AT 135 skip
        space(5)  Line format  "X(19)" AT 117 skip

        space(87) "УТВЕРЖДАЮ" format "X(9)"               AT 87  skip
        space(87) "______________________" format "X(20)" AT 87  skip
        space(87) "______________________" format "X(20)" AT 87 "/___________________/" AT 109 SKIP
        space(87) "подпись"                               AT 87 "расшифровка подписи"   AT 109 SKIP
        space(65) Line format "X(50)" skip
        space(54) string( "ПЛАН-МЕНЮ | "
                                    + string( tdoc-code , "X(16)") + " | "
                                    + string( tdoc-date, "99/99/9999")
                                    + " | "  + (if fbr-pln.status_ <> {&fact} then string( "(" + CAPS(fbr-pln.status_) + ")" ) else "")
                                    ) format "X(60)" skip
         space(65) Line format "X(50)" skip .
      .
    /* ... конец создания заголовка. --- */

/*    PAGE stream Out-Stream. */

  end.
end procedure. /* PrintTitul */


procedure PrintPodval :
  do on error undo, return error return-value  :
  PUT  STREAM Out-Stream " "   skip
LineBuf format "X(25)" AT 10 LineBuf format "X(25)"   AT 40 LineBuf format "X(50)"               AT 70 SKIP
"должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP
"<<       >> _________________        г. "
      .
    /* ... конец создания Подвал. --- */
  end.
end procedure. /* PrintPodval */



PROCEDURE on-same-page :
  define input parameter p-line-number as integer  no-undo .
  if p-line-number > page-size( Out-Stream ) then return .
  if line-counter( Out-Stream ) + p-line-number > page-size( Out-Stream ) then  page stream Out-Stream .
end procedure. /* on-same-page */


procedure make-tt :
  do
  on error undo, return error return-value
  :

define buffer buf_fbr-pln-line for fbr-pln-line .
define buffer buf_recipe for recipe .
define buffer buf_goods  for goods .
define variable v-cur-dn as character no-undo .
define variable v-cur-pr as decimal no-undo .
define variable v-cur-rt as decimal no-undo .
define variable v-cur-ex as decimal no-undo .
define variable v-bar-code like bar-code.b-code no-undo .


 for each  buf_fbr-pln-line no-lock where buf_fbr-pln-line.doc-code = fbr-pln.doc-code
                                    break by  buf_fbr-pln-line.line-num :
  find first buf_recipe  where buf_recipe.recipe-code = buf_fbr-pln-line.recipe-code  no-lock  .
  find first buf_goods   where buf_goods.gds-code = buf_fbr-pln-line.gds-code         no-lock  .

{ gbl/gdsbcode.i buf_goods.gds-code ? v-bar-code  }
/* Определим текущую цену бар-кода  */
{ gbl/bcodeprc.i
  buf_fbr-pln-line.obj-type
  buf_fbr-pln-line.obj-code
  v-bar-code
  0
  0
  v-cur-dn
  v-cur-pr
  v-cur-rt
  v-cur-ex }

  define variable v-grp-fbr-name as character no-undo .

  find first fbr-gds-obj no-lock where
             fbr-gds-obj.gds-code = buf_goods.gds-code and
             fbr-gds-obj.obj-code = buf_fbr-pln-line.obj-code and
             fbr-gds-obj.obj-type = buf_fbr-pln-line.obj-type
             no-error .
  if error-status :error then v-grp-fbr-name = "Блюдо и гарнир" .

  find first fbr-gds-grp no-lock where fbr-gds-grp.node-code = fbr-gds-obj.fbr-grp-code and
                                       fbr-gds-grp.obj-code = fbr-gds-obj.obj-code     and
                                       fbr-gds-grp.obj-type = fbr-gds-obj.obj-type    no-error .

  if available fbr-gds-grp then v-grp-fbr-name = fbr-gds-grp.node-name .
  else do:
    v-grp-fbr-name = "Блюдо и гарнир" .
  end.


  create temp-str .
  assign
    temp-str.np         = buf_fbr-pln-line.line-num
    temp-str.grp-name   = v-grp-fbr-name
    temp-str.gds-name   = buf_goods.gds-name
    temp-str.b-code     = string(v-bar-code)
    temp-str.p-inp      = if buf_recipe.portion-qnty <> 0 and buf_recipe.portion-qnty <> ? then  buf_recipe.qnty / buf_recipe.portion-qnty else 0
    temp-str.norma      = temp-str.p-inp
    temp-str.num-rcp    = string(buf_recipe.recipe-ref-num)
    temp-str.qnty       = buf_fbr-pln-line.fact-qnty
    temp-str.price      = if v-cur-pr = ? then 0 else v-cur-pr
    temp-str.stoim      = temp-str.qnty  * temp-str.price
    .
  end.

  end. /* do */
 end procedure. /* make-tt */