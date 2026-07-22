block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-slg-g.p $
$Archive: rep/r-slg-g.p $

Отчет по продажам ниже учетной цены

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/23/06
Author: Michael Kochetkov
Creation date: 03/23/06

*/

define input parameter p_provid     as integer   no-undo .
define input parameter p_cli-list   as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-slg-g.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-slg-g.p $":U .
define variable vss-description as character no-undo init "Отчет по продажам ниже учетной цены".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/r-page1.i  }
{ trg/factord.i  }
{ ref/grplib.i   }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
  { rep/rep-bt.i   }

do
on error undo, return error
:

define Stream OutStream.
define variable  v-fact-order-start     as decimal   no-undo .
define variable  v-fact-order-end       as decimal   no-undo .
define variable  Counter1               as integer   no-undo .
define variable  CurrGrpName            as character no-undo .
define variable  Line                   as character no-undo .

define variable beg-qnty     as decimal   no-undo .
define variable end-qnty     as decimal   no-undo .
define variable sale-qnty    as decimal   no-undo .
define variable in-qnty      as decimal   no-undo .

define variable titul           as logical   no-undo .
define variable v-level         as integer   no-undo .
define variable ind             as integer   no-undo .
define variable ret as logical   no-undo .
define variable v-old-level as integer initial 0  no-undo .
define variable ii as integer initial 0  no-undo .

define buffer buf_goods    for goods.
define buffer buf_clients  for clients.
define buffer buf_gds-obj  for gds-obj.
define buffer buf_gds-grp  for gds-grp.
define buffer buf_stk-line for stk-line.
define buffer buf_stk-supp-line for stk-supp-line.
/*define buffer buf_trn-doc  for trn-doc.*/
/*define buffer buf_doc-line for doc-line.*/


DEFINE temp-table temp-GrSales1 no-undo
    field   sale-qnty        as decimal
    field   in-qnty          as decimal
    field   obj-type         as  char
    field   obj-code         as  integer
    field   grp-name         as  char
    field   grp-code         as  integer
    field   full-grp-name    as  char
    INDEX pi  IS PRIMARY   obj-type obj-code grp-code
    INDEX pi2              full-grp-name
  .

  DEFINE temp-table temp-grp-sum no-undo
    field  sale-qnty        as decimal
    field  in-qnty          as decimal
    field  grp              as character
    field  full_grp         as character
    field  num              as integer
    INDEX pi  IS PRIMARY unique num
    INDEX pi1 is unique full_grp
  .

  define variable v-NameString  as character no-undo .
  define variable v-in-qnty     as decimal   no-undo .
  define variable v-sale-qnty   as decimal   no-undo .
  define variable v-proc        as decimal   no-undo .

  define variable  all-in-qnty     as decimal initial 0  no-undo .
  define variable  all-sale-qnty   as decimal initial 0  no-undo .

  run day-begin-fact-order in this-procedure ( input x-date-start, output v-fact-order-start ). /*Поиск нач fact-order*/
  run day-begin-fact-order in this-procedure ( input ( x-date-end + 1 ),   output v-fact-order-end ). /*Поиск посл fact-order*/

  assign
    Counter1 = 0 .
  .
  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */

  for each temp-GrSales1 exclusive-lock :
    delete temp-GrSales1 .
  end.

  if x-SelectGood = {&g-all} then do: /* все товары */
    for each buf_goods no-lock :
      for each obj-list :
        find first buf_gds-obj no-lock
          where buf_gds-obj.obj-type  = obj-list.obj-type
            and buf_gds-obj.obj-code  = obj-list.obj-code
            and buf_gds-obj.artic     = buf_goods.artic
            and buf_gds-obj.prod-type = buf_goods.prod-type
            and buf_gds-obj.prod-code = buf_goods.prod-code
        no-error .

        if not available buf_gds-obj then next .
        /* смотрим, были ли продажи и кладем в темп-тейбл  */
        if p_provid = 1 then do: { rep/r-slg-g1.i } end. /* все поставщики */
        else                 do: { rep/r-slg-g2.i } end. /* будет цикл по выбранным поставщикам */
      end.
    end.
  end.
  else do:
    for each obj-list :                /* встать на объект */
      case x-SelectGood :
        when {&g-all} then do:
        end.

        when {&g-prod} then do:    /* не все производители */
          for each G#cli , /* встать на производителя */
              each buf_gds-obj  no-lock
            where buf_gds-obj.obj-type  = obj-list.obj-type
              and buf_gds-obj.obj-code  = obj-list.obj-code
              and buf_gds-obj.prod-type = G#cli.obj-type
              and buf_gds-obj.prod-code = G#cli.obj-code
             use-index pi  :

            find first buf_goods no-lock
              where buf_goods.gds-code = buf_gds-obj.gds-code
            .
            /* смотрим, были ли продажи и кладем в темп-тейбл  */
            if p_provid = 1 then do: { rep/r-slg-g1.i } end. /* все поставщики */
            else                 do: { rep/r-slg-g2.i } end. /* будет цикл по выбранным поставщикам */

          end.                /* do ... по производителям */
        end .
        when {&g-grp} then do:    /* не все группы товаров */
          for each tmp#grp :
            find first buf_gds-grp no-lock
              where buf_gds-grp.node-code = tmp#grp.node-code
            .
            run grplib-get-full-name in this-procedure( input buf_gds-grp.node-code, output CurrGrpName ) .

            for each buf_gds-obj no-lock
              where buf_gds-obj.obj-type  = obj-list.obj-type
                and buf_gds-obj.obj-code  = obj-list.obj-code
                and buf_gds-obj.grp-name begins CurrGrpName
              use-index obj-grp :

              find first buf_goods no-lock
                where buf_goods.gds-code = buf_gds-obj.gds-code
              .
              /* смотрим, были ли продажи и кладем в темп-тейбл  */
              if p_provid = 1 then do: { rep/r-slg-g1.i } end. /* все поставщики */
              else                 do: { rep/r-slg-g2.i } end. /* будет цикл по выбранным поставщикам */
            end .
          end.    /* do i = 1 to num-entries ( gdsgrp_recids ) : */
        end.
        otherwise do:     /* список товаров */
          for each gds-list ,
              each buf_gds-obj no-lock
            where buf_gds-obj.obj-type  = obj-list.obj-type
              and buf_gds-obj.obj-code  = obj-list.obj-code
              and buf_gds-obj.artic     = gds-list.artic
              and buf_gds-obj.prod-type = gds-list.prod-type
              and buf_gds-obj.prod-code = gds-list.prod-code
            :

            find first buf_goods no-lock
              where buf_goods.gds-code = buf_gds-obj.gds-code
            .
            /* смотрим, были ли продажи и кладем в темп-тейбл  */
            if p_provid = 1 then do: { rep/r-slg-g1.i } end. /* все поставщики */
            else                 do: { rep/r-slg-g2.i } end. /* будет цикл по выбранным поставщикам */
          end.
        end.

      end case.
    end.                    /* for each ... по объектам */
  end.

/*  { rep/repfrm.i off } /* убрать окно информации о текущем процессе */*/

  { gbl/working.i }

  Line = fill("-", 102).

  DEFINE frame f-doc
      sym1  v-NameString column-label " Отдел/Группа/Подгруппа " format "X(50)"              space(0)
      sym2  v-in-qnty    column-label "Продано за!период  "      format "->>>,>>>,>>9"   space(0)
      sym3  v-sale-qnty  column-label "  Было за !период  "      format "->>>,>>>,>>9"   space(0)
      sym4  v-proc       column-label " % прода- !ваемости"      format  "->>>,>>9.99"       space(0)
      sym5
  HEADER
      string( "Дата печати : " + string(TODAY , "99.99.9999") + " , " + string(TIME, "HH:MM") ) AT 5 format "X(70)"
      string( "Страница " + string( PAGE-NUMBER( OutStream )  , ">>9") ) AT 80 format "X(15)" SKIP
      Line format "X(102)" AT 1
  with width {&A4_CW} down stream-io.

  { cmp/open-out.i stream OutStream " " {&PT_PS_A4} }

  FORM HEADER
      Line format "X(102)" AT 1 SKIP
      "Продолжение - на следующей странице" AT 30 SKIP
      with FRAME BottomFrame width {&A4_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW stream OutStream FRAME BottomFrame .

  FORM with FRAME f-doc .

  PUT stream OutStream SPACE(20) "Отчет по количеству наименований с: " x-date-start format "99/99/9999" "г. по: " x-date-end format "99/99/9999" "г." SKIP .

  assign  v-NameString = "Выбор объекта: " .
  PUT stream OutStream v-NameString format "X(100)" SKIP .
  for each obj-list no-lock:
    Assign  v-NameString = obj-list.obj-name + " (" + obj-list.obj-type + '#' + string(obj-list.obj-code)  + "), " .
    PUT stream OutStream SPACE(5) v-NameString format "X(100)" SKIP .
  end.
  assign  v-NameString = "Выбор товара: " .
  case x-SelectGood : /* все товары */
    when {&g-all}        then assign v-NameString = v-NameString + "по всем товарам"  .
    when {&g-grp}        then assign v-NameString = v-NameString + "по группам"  .
    when {&g-prod}       then assign v-NameString = v-NameString + "по производителям"  .
    when {&g-choice}     then assign v-NameString = v-NameString + "выборочно"  .
    when {&g-one}        then assign v-NameString = v-NameString + "выборочно"  .
    when {&g-spis}       then assign v-NameString = v-NameString + "хранимый список"  .
    when {&g-grp-prod}   then assign v-NameString = v-NameString + "по группам и по производителям"  .
  end case .
  PUT stream OutStream v-NameString format "X(100)" SKIP .
  if p_provid = 1 then assign  v-NameString = "Выбор поставщика: все" .
  else                 assign  v-NameString = "Выбор поставщика: выборочно" .
  PUT stream OutStream v-NameString format "X(100)" SKIP .

  for each obj-list no-lock :
    assign
      ind = 0
      titul = yes
      v-old-level = 0
      v-level = 0
    .

    for each temp-GrSales1
      where temp-GrSales1.obj-type = obj-list.obj-type
        and temp-GrSales1.obj-code = obj-list.obj-code
      break by temp-GrSales1.full-grp-name :
      if titul = yes then do:
        assign
          titul = no
          all-in-qnty   = 0
          all-sale-qnty = 0
          v-NameString  = "Объект: " + obj-list.obj-name + " (" + obj-list.obj-type + '#' + string(obj-list.obj-code) + ")"
        .
        display stream outstream sym1 v-NameString sym2 sym3 sym4 sym5 with frame f-doc.
        down stream outstream with frame f-doc .
      end.

      run GrpSumTree in this-procedure .

      assign
        v-NameString  = temp-GrSales1.grp-name
        v-in-qnty     = temp-GrSales1.in-qnty
        v-sale-qnty   = temp-GrSales1.sale-qnty
        v-proc        = 100 - ( ( temp-GrSales1.sale-qnty - temp-GrSales1.in-qnty ) * 100 / temp-GrSales1.sale-qnty )
        all-in-qnty   = all-in-qnty + temp-GrSales1.in-qnty
        all-sale-qnty = all-sale-qnty + temp-GrSales1.sale-qnty
      .
      if v-proc = ? then v-proc = 0 .
      display stream outstream
        sym1  v-NameString
        sym2  v-in-qnty
        sym3  v-sale-qnty
        sym4  v-proc
        sym5
      with frame f-doc.
      down stream outstream with frame f-doc .

      do ii = 1 to v-level :
        run CalculSum in this-procedure (ii) .
      end.
    End.

    do ii = v-old-level to ind by -1 : /* удаляем старые заголовки из списка */
      find first temp-grp-sum
        where temp-grp-sum.num = ii no-error .
      if available temp-grp-sum then do:
        assign
          v-NameString = "Итого по группе " + temp-grp-sum.grp + ":"
          v-in-qnty    = temp-grp-sum.in-qnty
          v-sale-qnty  = temp-grp-sum.sale-qnty
          v-proc       = 100 - ( ( temp-grp-sum.sale-qnty - temp-grp-sum.in-qnty ) * 100 / temp-grp-sum.sale-qnty )
        .
        if v-proc = ? then v-proc = 0 .
        display stream outstream sym1 v-NameString sym2 v-in-qnty sym3 v-sale-qnty sym4 v-proc sym5 with frame f-doc.
        down stream outstream with frame f-doc .
      end.
    end.
    for each temp-grp-sum :
      delete temp-grp-sum .
    end.

    if titul = no then do:
      assign
        v-NameString = "Итого по объекту " + obj-list.obj-name + " (" + obj-list.obj-type + '#' + string(obj-list.obj-code) + ") :"
        v-in-qnty    = all-in-qnty
        v-sale-qnty  = all-sale-qnty
        v-proc       = 100 - ( ( all-sale-qnty - all-in-qnty ) * 100 / all-sale-qnty )
      .
      if v-proc = ? then v-proc = 0 .
      display stream outstream sym1 v-NameString sym2 v-in-qnty sym3 v-sale-qnty sym4 v-proc sym5 with frame f-doc.
      down stream outstream with frame f-doc .
      display stream outstream sym1 sym2 sym3 sym4 sym5 with frame f-doc.
      down stream outstream with frame f-doc .
    end.
  End.

  PUT STREAM OutStream Line format "X(102)".

  HIDE stream OutStream FRAME BottomFrame .
  OUTPUT stream OutStream CLOSE.

  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */
  { gbl/stopwork.i }

  define variable v-user-action as character no-undo .
  define variable v-printed as logical   no-undo .
  run gbl/prnfilen.w
    (input  ""
    ,input  0
    ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
    ,input 7
    ,output v-user-action
    ,output v-printed
    ) .

end.


procedure GrpSumTree :
  v-level      = num-entries( right-trim(temp-GrSales1.full-grp-name, {&delim-grp}), {&delim-grp} ) - 1 .

  assign CurrGrpName = "" .
  do ind = 1 to v-level :
    assign CurrGrpName = CurrGrpName + entry ( ind, temp-GrSales1.full-grp-name, {&delim-grp} )  + {&delim-grp}.
    find first temp-grp-sum
      where temp-grp-sum.full_grp = CurrGrpName
    no-error .
    if not available temp-grp-sum then LEAVE.
  end.

  do ii = v-old-level to ind by -1 : /* удаляем старые заголовки из списка */
    find first temp-grp-sum
      where temp-grp-sum.num = ii .
    assign
      v-NameString = "Итого по группе " + temp-grp-sum.grp + ":"
      v-in-qnty    = temp-grp-sum.in-qnty
      v-sale-qnty  = temp-grp-sum.sale-qnty
      v-proc       = 100 - ( ( temp-grp-sum.sale-qnty - temp-grp-sum.in-qnty ) * 100 / temp-grp-sum.sale-qnty )
    .
    if v-proc = ? then v-proc = 0 .
    display stream outstream sym1 v-NameString sym2 v-in-qnty sym3 v-sale-qnty sym4 v-proc sym5 with frame f-doc.
    down stream outstream with frame f-doc .
    delete temp-grp-sum .
  end.

  assign
     v-old-level = v-level
  .
  /* надо вставлять заголовки для всех нижестоящих и вставить их в список */
  do ii = ind to v-level :
    create temp-grp-sum .
    if ii > ind then do:
      assign CurrGrpName = CurrGrpName + entry ( ii, temp-GrSales1.full-grp-name, {&delim-grp} )  + {&delim-grp}.
    end.
    assign
      temp-grp-sum.num = ii
      temp-grp-sum.full_grp = CurrGrpName
      temp-grp-sum.grp = entry ( ii, temp-GrSales1.full-grp-name, {&delim-grp} )
      v-NameString = "Группа " + temp-grp-sum.grp
      temp-grp-sum.in-qnty    = 0
      temp-grp-sum.sale-qnty  = 0
    .
    display stream outstream sym1 v-NameString sym2 sym3 sym4 sym5 with frame f-doc.
    down stream outstream with frame f-doc .
  end.
end procedure.

/* расчет сумм */
procedure CalculSum :
  define input  parameter p-num as integer   no-undo .
  define buffer buf_temp-grp-sum for temp-grp-sum .

  find first buf_temp-grp-sum where buf_temp-grp-sum.num = p-num no-error .
  assign
    buf_temp-grp-sum.in-qnty   = buf_temp-grp-sum.in-qnty     + v-in-qnty
    buf_temp-grp-sum.sale-qnty = buf_temp-grp-sum.sale-qnty + v-sale-qnty
  .
end procedure. /* CalculSum */