block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-dinrel.p $
$Archive: rep/r-dinrel.p $

Отчет о динамике реализации

Автор: Демин Алексей Сергеевич
Дата создания: 03/22/06
Author: Alexey Demin
Creation date: 03/22/06

*/

define input parameter SortType        as integer   no-undo .
define input parameter Classify        as integer   no-undo .
define input parameter sum-only        as logical   no-undo .
define input parameter num-col         as integer   no-undo .
define input parameter null-obort      as logical   no-undo .
define input parameter ExportZUM       as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-dinrel.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-dinrel.p $":U .
define variable vss-description as character no-undo init "Отчет о динамике реализации".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ trg/factord.i  }
{ ref/grplib.i   }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ gbl/cur-time.i }
{ rep/f-fdec.i   }   /* Функции для форматирования полей для передачи в EXcel         */
{ gbl/paramls.i  }
{ rep/rep-bt.i   }
{ rep/mcrexcel.i }

do
on error undo, return error
:

  &scop L1    1
  &scop L2    49
  &scop L3    61
  &scop F1     ">>>>>>>>>>>>9"
  &scop F2     "X(13)"
  &scop F3     "X(46)"
  &scop F4     "->>>>>>>>9"
  &scop F5     "->>>>>>>>9.<<<"

define variable XL-delim as character no-undo .
define variable type-par1 as character no-undo .
define variable tmp-var1  as character no-undo .
  { gbl/getsect.i  def }
  { gbl/getsect.i run v-cntxt-obj-type  v-cntxt-obj-code {&attr-report-firm} }
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'XL-delim'  then tmp-var1   = thbjattr_thbj-attr.property-value-character.
  end.
  IF tmp-var1 = "" then XL-delim = ";".
  else XL-delim = tmp-var1.

  define variable frmt as character no-undo .
  assign frmt = "X(" + string(72 + num-col * 21) + ')' .

  define Stream OutStream.
  define Stream txt-file .

  DEFINE temp-table temp-tovar no-undo
    field   ostat-beg      as decimal
    field   prihod         as decimal
    field   rashod         as decimal
    field   ostat      as decimal
    field   prod-type      as  char
    field   prod-code      as  integer
    field   gds-code       as  integer
    field   artic          as  char
    field   gds-name       as  char
    field   grp-name       as  char
    field   unit-base      as  char
    field   b-code         as  integer
    field   sort-val       as decimal
    INDEX pi  IS PRIMARY   artic  prod-type prod-code
    INDEX pi1              b-code
    INDEX pi2              grp-name
    INDEX pi3              sort-val
  .

  DEFINE temp-table temp-sum no-undo
    field  prihod         as decimal
    field  rashod         as decimal
    field  ostat          as decimal
    field  gds-code       as integer
    field  num            as integer
    INDEX pi  IS PRIMARY gds-code num
  .

  DEFINE temp-table temp-date no-undo
    field  dat1           as date
    field  dat2           as date
    field  fo1            as decimal
    field  fo2            as decimal
    field  num            as integer
    INDEX pi  IS PRIMARY num
  .

  define buffer buf_goods    for goods.
  define buffer buf_clients  for clients.
  define buffer buf_gds-obj  for gds-obj.
  define buffer buf_stk-line for stk-line.
  define buffer buf_temp-sum for temp-sum.

  define variable  v-fact-order-start     as decimal   no-undo .
  define variable  v-fact-order-end       as decimal   no-undo .

  define variable ii as integer initial 0  no-undo .
  define variable Counter1               as integer   no-undo .
  define variable CurrGrpName            as character no-undo .
  define variable Line                   as character no-undo .
  define variable v-NameString           as character no-undo .
  define variable tmp1                   as decimal   no-undo .
  define variable tmp2                   as decimal   no-undo .
  define variable no-null                as logical   no-undo .

  define variable v-row       as integer   no-undo .
  define variable v-col       as integer   no-undo .
  define variable v-ind       as integer   no-undo initial 1 .

  run day-begin-fact-order in this-procedure ( input x-date-start,        output v-fact-order-start ). /*Поиск нач fact-order*/
  run day-begin-fact-order in this-procedure ( input ( x-date-end + 1 ),  output v-fact-order-end ). /*Поиск посл fact-order*/
  do ii = 1 to num-col :
    create temp-date .
    assign
      temp-date.num = ii
      temp-date.dat1 = (x-date-start + (x-date-end + 1 - x-date-start) * (ii - 1) / num-col)
      temp-date.dat2 = (x-date-start + (x-date-end + 1 - x-date-start) * ii / num-col) - 1
    .
    run day-begin-fact-order in this-procedure ( input temp-date.dat1,  output temp-date.fo1 ).
    run day-begin-fact-order in this-procedure ( input temp-date.dat2 + 1,  output temp-date.fo2 ).
  end.

  /* coздаем таблицы для сумм нужных уровней */
  do ii = 0 to num-col : create temp-sum . assign temp-sum.num = ii temp-sum.gds-code = - 3 . end.
  if classify > 1 then do:
    do ii = 0 to num-col : create temp-sum . assign temp-sum.num = ii temp-sum.gds-code = - 1 . end.
    if classify > 3 then do:
      do ii = 0 to num-col : create temp-sum . assign temp-sum.num = ii temp-sum.gds-code = - 2 . end.
    end.
  end.
  assign Counter1 = 0 .
  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */

  for each obj-list :                /* встать на объект */
      case x-SelectGood :
      when {&g-all} then do: /* все товары */
          for each buf_gds-obj no-lock
            where buf_gds-obj.obj-type  = obj-list.obj-type
              and buf_gds-obj.obj-code  = obj-list.obj-code
            :
            { rep/r-dinrl1.i } /* смотрим, были ли продажи и кладем в темп-тейбл  */
          end.
      end.
        when {&g-prod} then do:    /* не все производители */
          for each G#cli , /* встать на производителя */
              each buf_gds-obj  no-lock
            where buf_gds-obj.obj-type  = obj-list.obj-type
              and buf_gds-obj.obj-code  = obj-list.obj-code
              and buf_gds-obj.prod-type = G#cli.obj-type
              and buf_gds-obj.prod-code = G#cli.obj-code
             use-index pi  :
             { rep/r-dinrl1.i } /* смотрим, были ли продажи и кладем в темп-тейбл  */
          end.                /* do ... по производителям */
        end .
        when {&g-grp} then do:    /* не все группы товаров */
          for each tmp#grp :
            run grplib-get-full-name in this-procedure( input tmp#grp.node-code, output CurrGrpName ) .
            for each buf_gds-obj no-lock
              where buf_gds-obj.obj-type  = obj-list.obj-type
                and buf_gds-obj.obj-code  = obj-list.obj-code
                and buf_gds-obj.grp-name begins CurrGrpName
              use-index obj-grp :
              { rep/r-dinrl1.i } /* смотрим, были ли продажи и кладем в темп-тейбл  */
            end .
          end.    /* do i = 1 to num-entries ( gdsgrp_recids ) : */
        end.

       otherwise do: /* список товаров */
          for each gds-list ,
              each buf_gds-obj no-lock
            where buf_gds-obj.obj-type  = obj-list.obj-type
              and buf_gds-obj.obj-code  = obj-list.obj-code
              and buf_gds-obj.artic     = gds-list.artic
              and buf_gds-obj.prod-type = gds-list.prod-type
              and buf_gds-obj.prod-code = gds-list.prod-code
            :
            { rep/r-dinrl1.i } /* смотрим, были ли продажи и кладем в темп-тейбл  */
          end.
        end.

      end case.
  end.                    /* for each ... по объектам */

  Line = fill("-", 250).
  { gbl/working.i }

  if num-col < 4 then do:
    { cmp/open-out.i stream OutStream " " {&CS_PS} }
  end.
  else do:
    if num-col < 7 then do:
      { cmp/open-out.i stream OutStream " " {&LS_PS_A4} }
    end.
    else  do:
      { cmp/open-out.i stream OutStream " " {&CS_PS} }
    end.
  end.

  /* macr_excel - для экселя */
  assign
    make-excel = yes
    v-file-name = string(session :temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt"
  .
  output stream macr_excel to value(v-file-name) .
  assign v-ind = v-ind + 1 .


  if ExportZUM then do:
    output stream txt-file to value(string(session :temp-directory) + "rpz" + string( g#report-num ) + ".txt").
    put stream txt-file "Отчет о динамике реализации с: " x-date-start format "99/99/9999" "г. по: " x-date-end format "99/99/9999" "г."   {&new-line} .
    put stream txt-file str1 format "X(100)"   string( {&new-line} + "Группа" + XL-delim  +
                                                                     "Производитель" + XL-delim  +
                                                                     "Код" + XL-delim +
                                                                     "Артикул" + XL-delim +
                                                                     "Наименование товара" + XL-delim +
                                                                     "Остаток на начало" + XL-delim ) format "X(72)"
    .
    for each temp-date :
      put stream txt-file string(string(temp-date.dat1,"99/99/9999") + "-" + string(temp-date.dat2,"99/99/9999") +
        " приход внеш.-возврат постав."   + XL-delim  +
        string(temp-date.dat1,"99/99/9999") + "-" + string(temp-date.dat2,"99/99/9999") +
        " Реализ. внеш.-возврат реализ."   + XL-delim  +
        string(temp-date.dat1,"99/99/9999") + "-" + string(temp-date.dat2,"99/99/9999") +
        " Остаток на конец интервала"   + XL-delim) format "X(152)"
      .
    end.
    put stream txt-file
      string("Всего приход внеш.-возврат постав."   + XL-delim  +
             "Всего реализ. внеш.-возврат реализ."  + {&new-line})  format "X(73)"
    .
  end.

  PUT stream OutStream SPACE(30) "Отчет о динамике реализации с: " x-date-start format "99/99/9999" "г. по: " x-date-end format "99/99/9999" "г." SKIP .
  PUT stream OutStream str1 format "X(100)" SKIP .
  run macr_excel_char (str1, 2, 1) .

  assign  v-NameString = "Выбор объекта: " .
  PUT stream OutStream v-NameString format "X(100)" SKIP .
  run macr_excel_char ("Выбор объекта: ", 3, 1) .
  assign v-col = 2 .
  for each obj-list no-lock:
    Assign  v-NameString = obj-list.obj-name + " (" + obj-list.obj-type + '#' + string(obj-list.obj-code)  + "), " .
    PUT stream OutStream SPACE(5) v-NameString format "X(100)" SKIP .
    run macr_excel_char (v-NameString, 3, v-col) .   assign v-col = v-col + 1 .
  end.

  assign  v-NameString = "Выбор товара: " .

  case x-SelectGood : /* все товары */
    when {&g-all}      then assign v-NameString = v-NameString + "по всем товарам"  .
    when {&g-grp}      then assign v-NameString = v-NameString + "по группам"  .
    when {&g-prod}     then assign v-NameString = v-NameString + "по производителям"  .
    when {&g-choice}   then assign v-NameString = v-NameString + "выборочно"  .
    when {&g-one}      then assign v-NameString = v-NameString + "выборочно"  .
    when {&g-spis}     then assign v-NameString = v-NameString + "хранимый список"  .
    when {&g-grp-prod} then assign v-NameString = v-NameString + "по группам и по производителям"  .
  end case .

  PUT stream OutStream v-NameString format "X(100)" SKIP .
  run macr_excel_char (v-NameString, 4, 1) .
  assign v-row = 5 .

  run PrintTitul in this-procedure .
  run PutColumnTitulExcel in this-procedure .

  case classify:
    when 1 then run class1 in this-procedure .  /*"Без классификации" .*/
    when 2 then run class2 in this-procedure .  /*"Производители"   .*/
    when 3 then run class3 in this-procedure .  /*"Группы товаров"  .*/
    when 4 then run class4 in this-procedure .  /*"Производители/Группы товаров" .*/
    when 5 then run class5 in this-procedure .  /*"Группы товаров/Производители" .*/
  end case.

  assign v-NameString = "ВСЕГО: " .
  run PrintItog in this-procedure (input -3) .

  HIDE stream OutStream FRAME BottomFrame .
  OUTPUT stream OutStream CLOSE.

  if ExportZUM then do:
    output stream txt-file close.
  end.

  output stream macr_excel close .
  run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name) .
  run end-proc .

  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */
  { gbl/stopwork.i }

  define variable disop as integer   no-undo .
  if num-col < 4 then assign disop = 0 .
  else do:
    if num-col < 7 then assign disop = 8 .
    else do:
      if num-col < 13 then assign disop = 1 .
      else                 assign disop = 3 .   /* только в файл */
    end.
  end.

  define variable v-user-action as character no-undo .
  define variable v-printed as logical   no-undo .
  run gbl/prnfilen.w
    (input  ""
    ,input  disop
    ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
    ,input 7
    ,output v-user-action
    ,output v-printed
    ) .

end.



/* *********************************************************** */

procedure class1 :  /*"Без классификации" .*/
  do on error undo, return error return-value :
    case SortType:
      when 1 then do: /*"по коду" .*/
        for each temp-tovar break by temp-tovar.b-code :    run PrintLine in this-procedure .  end.
      end.
      when 2 then do: /*"по артикулу"  .*/
        for each temp-tovar break by temp-tovar.artic :     run PrintLine in this-procedure .  end.
      end.
      when 3 then do: /*"по наименованию".*/
        for each temp-tovar break by temp-tovar.gds-name :  run PrintLine in this-procedure .  end.
      end.
      when 4 or when 5 or when 6 or when 7 then do:
        for each temp-tovar break by temp-tovar.sort-val DESCENDING : run PrintLine in this-procedure .  end.
      end.
    end case.
  end.
end procedure. /* class1 */


procedure class2 :  /* Производители */
  do on error undo, return error return-value :
    case SortType:
      when 1 then do: /*"по коду" .*/
        for each temp-tovar break by temp-tovar.prod-type by temp-tovar.prod-code by temp-tovar.b-code :
          if first-of(temp-tovar.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = temp-tovar.prod-type and buf_clients.obj-code = temp-tovar.prod-code .
            assign v-NameString = buf_clients.obj-name .
            run PrintGroup in this-procedure (-1).
          end.
          run PrintLine in this-procedure .
          if last-of(temp-tovar.prod-code) then do:
            assign v-NameString = "Итого по: " + buf_clients.obj-name .
            run PrintItog in this-procedure (input -1) .
          end.
        end.
      end.
      when 2 then do: /*"по артикулу"  .*/
        for each temp-tovar break by temp-tovar.prod-type by temp-tovar.prod-code by temp-tovar.artic :
          if first-of(temp-tovar.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = temp-tovar.prod-type and buf_clients.obj-code = temp-tovar.prod-code .
            assign v-NameString = buf_clients.obj-name .
            run PrintGroup in this-procedure (-1).
          end.
          run PrintLine in this-procedure .
          if last-of(temp-tovar.prod-code) then do:
            assign v-NameString = "Итого по: " + buf_clients.obj-name .
            run PrintItog in this-procedure (input -1) .
          end.
        end.
      end.
      when 3 then do: /*"по наименованию".*/
        for each temp-tovar break by temp-tovar.prod-type by temp-tovar.prod-code by temp-tovar.gds-name :
          if first-of(temp-tovar.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = temp-tovar.prod-type and buf_clients.obj-code = temp-tovar.prod-code .
            assign v-NameString = buf_clients.obj-name .
            run PrintGroup in this-procedure (-1).
          end.
          run PrintLine in this-procedure .
          if last-of(temp-tovar.prod-code) then do:
            assign v-NameString = "Итого по: " + buf_clients.obj-name .
            run PrintItog in this-procedure (input -1) .
          end.
        end.
      end.
      when 4 or when 5 or when 6 or when 7 then do:
        for each temp-tovar break by temp-tovar.prod-type by temp-tovar.prod-code  by temp-tovar.sort-val DESCENDING :
          if first-of(temp-tovar.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = temp-tovar.prod-type and buf_clients.obj-code = temp-tovar.prod-code .
            assign v-NameString = buf_clients.obj-name .
            run PrintGroup in this-procedure (-1).
          end.
          run PrintLine in this-procedure .
          if last-of(temp-tovar.prod-code) then do:
            assign v-NameString = "Итого по: " + buf_clients.obj-name .
            run PrintItog in this-procedure (input -1) .
          end.
        end.
      end.
    end case.
  end.
end procedure. /* class2 */


procedure class3 :  /* Группы товаров */
  do on error undo, return error return-value :
    case SortType:
      when 1 then do: /*"по коду" .*/
        for each temp-tovar break by temp-tovar.grp-name by temp-tovar.b-code :
          if first-of(temp-tovar.grp-name) then do:
            assign v-NameString = temp-tovar.grp-name .
            run PrintGroup in this-procedure (-1).
          end.
          run PrintLine in this-procedure .
          if last-of(temp-tovar.grp-name) then do:
            assign v-NameString = "Итого по: " + temp-tovar.grp-name .
            run PrintItog in this-procedure (input -1) .
          end.
        end.
      end.
      when 2 then do: /*"по артикулу"  .*/
        for each temp-tovar break by temp-tovar.grp-name by temp-tovar.artic :
          if first-of(temp-tovar.grp-name) then do:
            assign v-NameString = temp-tovar.grp-name .
            run PrintGroup in this-procedure (-1).
          end.
          run PrintLine in this-procedure .
          if last-of(temp-tovar.grp-name) then do:
            assign v-NameString = "Итого по: " + temp-tovar.grp-name .
            run PrintItog in this-procedure (input -1) .
          end.
        end.
      end.
      when 3 then do: /*"по наименованию".*/
        for each temp-tovar break by temp-tovar.grp-name by temp-tovar.gds-name :
          if first-of(temp-tovar.grp-name) then do:
            assign v-NameString = temp-tovar.grp-name .
            run PrintGroup in this-procedure (-1).
          end.
          run PrintLine in this-procedure .
          if last-of(temp-tovar.grp-name) then do:
            assign v-NameString = "Итого по: " + temp-tovar.grp-name .
            run PrintItog in this-procedure (input -1) .
          end.
        end.
      end.
      when 4 or when 5 or when 6 or when 7 then do:
        for each temp-tovar break by temp-tovar.grp-name by temp-tovar.sort-val DESCENDING :
          if first-of(temp-tovar.grp-name) then do:
            assign v-NameString = temp-tovar.grp-name .
            run PrintGroup in this-procedure (-1).
          end.
          run PrintLine in this-procedure .
          if last-of(temp-tovar.grp-name) then do:
            assign v-NameString = "Итого по: " + temp-tovar.grp-name .
            run PrintItog in this-procedure (input -1) .
          end.
        end.
      end.
    end case.
  end.
end procedure. /* class3 */


procedure class4 :  /* Производители/Группы товаров */
  do on error undo, return error return-value :
    case SortType:
      when 1 then do: /*"по коду" .*/
        for each temp-tovar break by temp-tovar.prod-type by temp-tovar.prod-code by temp-tovar.grp-name by temp-tovar.b-code :
          if first-of(temp-tovar.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = temp-tovar.prod-type and buf_clients.obj-code = temp-tovar.prod-code .
            assign v-NameString = buf_clients.obj-name .
            run PrintGroup in this-procedure (-2).
          end.
          if first-of(temp-tovar.grp-name) then do:
            assign v-NameString = temp-tovar.grp-name .
            run PrintGroup in this-procedure (-1).
          end.
          run PrintLine in this-procedure .
          if last-of(temp-tovar.grp-name) then do:
            assign v-NameString = "Итого по: " + temp-tovar.grp-name .
            run PrintItog in this-procedure (input -1) .
          end.
          if last-of(temp-tovar.prod-code) then do:
            assign v-NameString = "Итого по: " + buf_clients.obj-name .
            run PrintItog in this-procedure (input -2) .
          end.
        end.
      end.
      when 2 then do: /*"по артикулу"  .*/
        for each temp-tovar break by temp-tovar.prod-type by temp-tovar.prod-code by temp-tovar.grp-name by temp-tovar.artic :
          if first-of(temp-tovar.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = temp-tovar.prod-type and buf_clients.obj-code = temp-tovar.prod-code .
            assign v-NameString = buf_clients.obj-name .
            run PrintGroup in this-procedure (-2).
          end.
          if first-of(temp-tovar.grp-name) then do:
            assign v-NameString = temp-tovar.grp-name .
            run PrintGroup in this-procedure (-1).
          end.
          run PrintLine in this-procedure .
          if last-of(temp-tovar.grp-name) then do:
            assign v-NameString = "Итого по: " + temp-tovar.grp-name .
            run PrintItog in this-procedure (input -1) .
          end.
          if last-of(temp-tovar.prod-code) then do:
            assign v-NameString = "Итого по: " + buf_clients.obj-name .
            run PrintItog in this-procedure (input -2) .
          end.
        end.
      end.
      when 3 then do: /*"по наименованию".*/
        for each temp-tovar break by temp-tovar.prod-type by temp-tovar.prod-code by temp-tovar.grp-name by temp-tovar.gds-name :
          if first-of(temp-tovar.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = temp-tovar.prod-type and buf_clients.obj-code = temp-tovar.prod-code .
            assign v-NameString = buf_clients.obj-name .
            run PrintGroup in this-procedure (-2).
          end.
          if first-of(temp-tovar.grp-name) then do:
            assign v-NameString = temp-tovar.grp-name .
            run PrintGroup in this-procedure (-1).
          end.
          run PrintLine in this-procedure .
          if last-of(temp-tovar.grp-name) then do:
            assign v-NameString = "Итого по: " + temp-tovar.grp-name .
            run PrintItog in this-procedure (input -1) .
          end.
          if last-of(temp-tovar.prod-code) then do:
            assign v-NameString = "Итого по: " + buf_clients.obj-name .
            run PrintItog in this-procedure (input -2) .
          end.
        end.
      end.
      when 4 or when 5 or when 6 or when 7 then do:
        for each temp-tovar break by temp-tovar.prod-type by temp-tovar.prod-code by temp-tovar.grp-name by temp-tovar.sort-val DESCENDING :
          if first-of(temp-tovar.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = temp-tovar.prod-type and buf_clients.obj-code = temp-tovar.prod-code .
            assign v-NameString = buf_clients.obj-name .
            run PrintGroup in this-procedure (-2).
          end.
          if first-of(temp-tovar.grp-name) then do:
            assign v-NameString = temp-tovar.grp-name .
            run PrintGroup in this-procedure (-1).
          end.
          run PrintLine in this-procedure .
          if last-of(temp-tovar.grp-name) then do:
            assign v-NameString = "Итого по: " + temp-tovar.grp-name .
            run PrintItog in this-procedure (input -1) .
          end.
          if last-of(temp-tovar.prod-code) then do:
            assign v-NameString = "Итого по: " + buf_clients.obj-name .
            run PrintItog in this-procedure (input -2) .
          end.
        end.
      end.
    end case.
  end.
end procedure. /* class4 */


procedure class5 :  /* Группы товаров/Производители */
  do on error undo, return error return-value :
    case SortType:
      when 1 then do: /*"по коду" .*/
        for each temp-tovar break by temp-tovar.grp-name by temp-tovar.prod-type by temp-tovar.prod-code by temp-tovar.b-code :
          if first-of(temp-tovar.grp-name) then do:
            assign v-NameString = temp-tovar.grp-name .
            run PrintGroup in this-procedure (-2).
          end.
          if first-of(temp-tovar.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = temp-tovar.prod-type and buf_clients.obj-code = temp-tovar.prod-code .
            assign v-NameString = buf_clients.obj-name .
            run PrintGroup in this-procedure (-1).
          end.
          run PrintLine in this-procedure .
          if last-of(temp-tovar.prod-code) then do:
            assign v-NameString = "Итого по: " + buf_clients.obj-name .
            run PrintItog in this-procedure (input -1) .
          end.
          if last-of(temp-tovar.grp-name) then do:
            assign v-NameString = "Итого по: " + temp-tovar.grp-name .
            run PrintItog in this-procedure (input -2) .
          end.
        end.
      end.
      when 2 then do: /*"по артикулу"  .*/
        for each temp-tovar break by temp-tovar.grp-name by temp-tovar.prod-type by temp-tovar.prod-code by temp-tovar.artic :
          if first-of(temp-tovar.grp-name) then do:
            assign v-NameString = temp-tovar.grp-name .
            run PrintGroup in this-procedure (-2).
          end.
          if first-of(temp-tovar.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = temp-tovar.prod-type and buf_clients.obj-code = temp-tovar.prod-code .
            assign v-NameString = buf_clients.obj-name .
            run PrintGroup in this-procedure (-1).
          end.
          run PrintLine in this-procedure .
          if last-of(temp-tovar.prod-code) then do:
            assign v-NameString = "Итого по: " + buf_clients.obj-name .
            run PrintItog in this-procedure (input -1) .
          end.
          if last-of(temp-tovar.grp-name) then do:
            assign v-NameString = "Итого по: " + temp-tovar.grp-name .
            run PrintItog in this-procedure (input -2) .
          end.
        end.
      end.
      when 3 then do: /*"по наименованию".*/
        for each temp-tovar break by temp-tovar.grp-name by temp-tovar.prod-type by temp-tovar.prod-code by temp-tovar.gds-name :
          if first-of(temp-tovar.grp-name) then do:
            assign v-NameString = temp-tovar.grp-name .
            run PrintGroup in this-procedure (-2).
          end.
          if first-of(temp-tovar.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = temp-tovar.prod-type and buf_clients.obj-code = temp-tovar.prod-code .
            assign v-NameString = buf_clients.obj-name .
            run PrintGroup in this-procedure (-1).
          end.
          run PrintLine in this-procedure .
          if last-of(temp-tovar.prod-code) then do:
            assign v-NameString = "Итого по: " + buf_clients.obj-name .
            run PrintItog in this-procedure (input -1) .
          end.
          if last-of(temp-tovar.grp-name) then do:
            assign v-NameString = "Итого по: " + temp-tovar.grp-name .
            run PrintItog in this-procedure (input -2) .
          end.
        end.
      end.
      when 4 or when 5 or when 6 or when 7 then do:
        for each temp-tovar break by temp-tovar.grp-name by temp-tovar.prod-type by temp-tovar.prod-code by temp-tovar.sort-val DESCENDING :
          if first-of(temp-tovar.grp-name) then do:
            assign v-NameString = temp-tovar.grp-name .
            run PrintGroup in this-procedure (-2).
          end.
          if first-of(temp-tovar.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = temp-tovar.prod-type and buf_clients.obj-code = temp-tovar.prod-code .
            assign v-NameString = buf_clients.obj-name .
            run PrintGroup in this-procedure (-1).
          end.
          run PrintLine in this-procedure .
          if last-of(temp-tovar.prod-code) then do:
            assign v-NameString = "Итого по: " + buf_clients.obj-name .
            run PrintItog in this-procedure (input -1) .
          end.
          if last-of(temp-tovar.grp-name) then do:
            assign v-NameString = "Итого по: " + temp-tovar.grp-name .
            run PrintItog in this-procedure (input -2) .
          end.
        end.
      end.
    end case.
  end.
end procedure. /* class5 */



procedure PrintTitul :
  do on error undo, return error return-value :
    put stream outstream  skip cur-time-print() format "x(35)" string( "Страница" ) AT 45 PAGE-NUMBER( outstream ) AT 55 FORMAT ">>9" SKIP .

    put stream outstream
      skip  Line format frmt  skip
        "| "     "Код"   format "X(11)"   "Артикул" format "X(11)"
        "|"      at {&L2}        "Остаток на"       format "X(10)"

    .
    for each temp-date :
      put stream outstream  "|   "   at ({&L3} + 21 * (temp-date.num - 1))  temp-date.dat1   format "99/99/9999" .
    end.
    put stream outstream
        "|"  at ({&L3} + 21 * num-col)  "Всего"  format "X(10)"
        "|"   at ({&L3} + 21 * num-col + 11)      skip
        "| "     "Наименование товара"              format "X(20)"
        "|"      at {&L2}        "начало"           format "X(10)"
    .
    for each temp-date :
      put stream outstream  "|   "   at ({&L3} + 21 * (temp-date.num - 1)) temp-date.dat2   format "99/99/9999" .
    end.
    put stream outstream  "|"   at ({&L3} + 21 * num-col)  "|"  at ({&L3} + 21 * num-col + 11)  skip    Line format frmt  skip  .
  end.
end procedure. /* PrintTitul */


procedure PutColumnTitulExcel : /* заголовки для колонок экселя */
  do
  on error undo, return error return-value
  :
  assign v-NameString = "Отчет о динамике реализации с: " + string(x-date-start,"99/99/9999") + "г. по: " + string(x-date-end,"99/99/9999") + "г." .
  run macr_excel_char ( v-NameString, 1, 2) .
  run macr_cell_format ( 11, yes, no, ?, 1, 2, 1, 2) .

  define variable st as integer   no-undo .
  assign
    v-col = 1
    st = v-row
  .
  run macr_excel_char("Группа", v-row, v-col) .               assign v-col = v-col + 1 .
  run macr_cell_size (20,?, v-row, v-col,?,?).
  run macr_excel_char("Производитель", v-row, v-col) .        assign v-col = v-col + 1 .
  run macr_cell_size (20,?, v-row, v-col,?,?).
  run macr_excel_char("Код", v-row, v-col) .                  assign v-col = v-col + 1 .
  run macr_cell_size (13,?, v-row, v-col,?,?).
  run macr_excel_char("Артикул", v-row, v-col) .              assign v-col = v-col + 1 .
  run macr_cell_size (15,?, v-row, v-col,?,?).
  run macr_excel_char("Наименование товара", v-row, v-col) .  assign v-col = v-col + 1 .
  run macr_cell_size (40,?, v-row, v-col,?,?).
  run macr_excel_char("Остаток на начало", v-row, v-col) .    assign v-col = v-col + 1 .
  for each temp-date :
    run macr_excel_char(string(temp-date.dat1,"99/99/9999") + "-" + string(temp-date.dat2,"99/99/9999"), v-row, v-col + 1 ) .
    run macr_excel_char("Приход внеш.-возврат постав.", v-row + 1, v-col ) .  assign v-col = v-col + 1 .
    run macr_excel_char("Реализ. внеш.-возврат реализ.", v-row + 1, v-col ) .  assign v-col = v-col + 1 .
    run macr_excel_char("Остаток на конец интервала", v-row + 1, v-col ) .  assign v-col = v-col + 1 .
  end.
  run macr_excel_char("Всего приход внеш.-возврат постав.", v-row, v-col ) .  assign v-col = v-col + 1 .
  run macr_excel_char("Всего реализ. внеш.-возврат реализ.", v-row, v-col ) .
  assign v-row = v-row + 1 .
  run macr_cell_bordur ( st, 1, v-row , v-col) .
  run macr_cell_format ( 10, yes, no, 35, st, 1, v-row, v-col) .
  run macr_cell_size (12,?, st, 6, v-row, v-col) .
  assign v-row = v-row + 1 .

  end.
end procedure. /* PutColumnTitulExcel */



/* *********************************************************** */

procedure PrintGroup :
  do on error undo, return error return-value :
    define input  parameter p-lavel as integer   no-undo .

    run is-page in this-procedure .

    for each temp-sum where temp-sum.gds-code = p-lavel :
      assign
        temp-sum.ostat     = 0
        temp-sum.prihod    = 0
        temp-sum.rashod    = 0
      .
    end.
    if sum-only = no then put stream outstream "| "  v-NameString format "X(100)" "|" at ({&L3} + 21 * num-col + 11) skip Line format frmt skip.
  end.
end procedure. /* PrintTitul */


/* *********************************************************** */
procedure AddSum :
  do on error undo, return error return-value :
    define input  parameter p-lavel as integer   no-undo .
    find first temp-sum where temp-sum.gds-code = p-lavel and temp-sum.num = 0 .
    assign
      temp-sum.ostat     = temp-sum.ostat     + temp-tovar.ostat-beg
      temp-sum.prihod    = temp-sum.prihod    + temp-tovar.prihod
      temp-sum.rashod    = temp-sum.rashod    + temp-tovar.rashod
    .
    for each temp-sum where temp-sum.gds-code = p-lavel and temp-sum.num > 0 .
      find first buf_temp-sum where buf_temp-sum.gds-code = temp-tovar.gds-code and buf_temp-sum.num = temp-sum.num .
      assign
        temp-sum.ostat     = temp-sum.ostat     + buf_temp-sum.ostat
        temp-sum.prihod    = temp-sum.prihod    + buf_temp-sum.prihod
        temp-sum.rashod    = temp-sum.rashod    + buf_temp-sum.rashod
      .
    end.
  end.
end procedure. /* AddSum */

procedure PrintLine :
  do
  on error undo, return error return-value
  :
    run is-page in this-procedure .

    if sum-only = no then do:
      assign v-col = 1 .
      Put Stream Outstream "| " temp-tovar.b-code  Format {&f1}  space(10) temp-tovar.artic  Format {&f2}
                           "|"  At {&L2} temp-tovar.ostat-beg    Format {&f4} .

      run macr_excel_char(temp-tovar.grp-name,  v-row, v-col) .     assign v-col = v-col + 1 .
      find first buf_clients no-lock where buf_clients.obj-type = temp-tovar.prod-type and buf_clients.obj-code = temp-tovar.prod-code .
      run macr_excel_char(buf_clients.obj-name, v-row, v-col) .     assign v-col = v-col + 1 .
      run macr_excel_char(temp-tovar.b-code,    v-row, v-col) .     assign v-col = v-col + 1 .
      run macr_excel_char(temp-tovar.artic,     v-row, v-col) .     assign v-col = v-col + 1 .
      run macr_excel_char(temp-tovar.gds-name,  v-row, v-col) .     assign v-col = v-col + 1 .
      run macr_excel_sum (temp-tovar.ostat-beg, v-row, v-col, 2) .  assign v-col = v-col + 1 .
      if ExportZUM then do:
        put stream txt-file  temp-tovar.grp-name  format "X(40)" XL-delim .
        put stream txt-file  buf_clients.obj-name format "X(40)" XL-delim .
        put stream txt-file  temp-tovar.b-code    Format {&f1}   XL-delim .
        put stream txt-file  temp-tovar.artic     Format {&f2}   XL-delim .
        put stream txt-file  temp-tovar.gds-name  Format {&f3}   XL-delim .
        put stream txt-file  replace(string(temp-tovar.ostat-beg,{&f5}),".",",")   XL-delim .
      end.

      for each temp-sum where temp-sum.gds-code = temp-tovar.gds-code :
        put stream outstream  "|"  At ({&L3} + 21 * (temp-sum.num - 1))  temp-sum.prihod    Format {&f4} temp-sum.ostat Format {&f4}  .
        run macr_excel_sum (temp-sum.prihod, v-row, v-col, 2) .  assign v-col = v-col + 1 .
        run macr_excel_sum (temp-sum.rashod, v-row, v-col, 2) .  assign v-col = v-col + 1 .
        run macr_excel_sum (temp-sum.ostat,  v-row, v-col, 2) .  assign v-col = v-col + 1 .
        if ExportZUM then do:
          put stream txt-file replace(string(temp-tovar.prihod,{&f5}),".",",")   XL-delim .
          put stream txt-file replace(string(temp-tovar.rashod,{&f5}),".",",")   XL-delim .
          put stream txt-file replace(string(temp-tovar.ostat ,{&f5}),".",",")   XL-delim .
        end.
      end.
      if ExportZUM then do:
        put stream txt-file replace(string(temp-tovar.prihod,{&f5}),".",",")   XL-delim .
        put stream txt-file replace(string(temp-tovar.rashod,{&f5}),".",",")   {&new-line} .
      end.


      put stream outstream "|"  At ({&L3} + 21 * num-col) temp-tovar.prihod       Format {&f4}
                           "|"  At ({&L3} + 21 * num-col + 11) skip
                           "| " temp-tovar.gds-name  Format {&f3}
                           "|"  At {&L2} .
      run macr_excel_sum (temp-tovar.prihod, v-row, v-col, 2) .  assign v-col = v-col + 1 .
      run macr_excel_sum (temp-tovar.rashod, v-row, v-col, 2) .  assign v-col = v-col + 1 .

      for each temp-sum where temp-sum.gds-code = temp-tovar.gds-code :
        put stream outstream  "|"  At ({&L3} + 21 * (temp-sum.num - 1))  temp-sum.rashod    Format {&f4}  .
      end.
      put stream outstream "|"  At ({&L3} + 21 * num-col)  temp-tovar.rashod       Format {&f4}
                           "|"  At ({&L3} + 21 * num-col + 11)  skip     Line format frmt   skip .
      assign v-row = v-row + 1 .
    end.
    run AddSum in this-procedure (-3).
    if classify > 1 then do:
      run AddSum in this-procedure (-1).
      if classify > 3 then do: run AddSum in this-procedure (-2).    end.
    end.
  end.
end procedure. /* PrintLine */

/* *********************************************************** */


procedure PrintItog :
  do on error undo, return error return-value :
    define input  parameter p-lavel     as integer   no-undo .

    run is-page in this-procedure .

    find first buf_temp-sum where buf_temp-sum.gds-code = p-lavel and buf_temp-sum.num = 0 .

    Put Stream Outstream "| " v-NameString  Format {&f3}  "|"  At {&L2}  buf_temp-sum.ostat Format {&f4} .
    for each temp-sum where temp-sum.gds-code = p-lavel and temp-sum.num > 0  use-index pi:
      put stream outstream  "|"  At ({&L3} + 21 * (temp-sum.num - 1))  temp-sum.prihod    Format {&f4} temp-sum.ostat Format {&f4}  .
    end.
    put stream outstream "|"  At ({&L3} + 21 * num-col) buf_temp-sum.prihod       Format {&f4}
                         "|"  At ({&L3} + 21 * num-col + 11) skip
                         "| "   "|"  At {&L2} .
    for each temp-sum where temp-sum.gds-code = p-lavel and temp-sum.num > 0  use-index pi :
      put stream outstream  "|"  At ({&L3} + 21 * (temp-sum.num - 1))  temp-sum.rashod    Format {&f4} .
    end.
    put stream outstream "|"  At ({&L3} + 21 * num-col) buf_temp-sum.rashod       Format {&f4}
                         "|"  At ({&L3} + 21 * num-col + 11) skip   Line format frmt  skip
    .
  end.
end procedure. /* PrintItog */


procedure GetValTovar :
  do on error undo, return error return-value :
    define input  parameter sum-type   as character no-undo .
    define input  parameter fact-order as decimal   no-undo .
    define output parameter qnty       as decimal   no-undo .

    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = sum-type
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order  < fact-order
      use-index category no-error .
    if available buf_stk-line then  assign qnty = buf_stk-line.fact-qnty .
    else                            assign qnty = 0 .
  end.
end procedure. /* GetValTovar */


procedure is-page :
  do
  on error undo, return error return-value
  :
    if line-counter( Outstream ) + 4 > page-size( Outstream ) then do:
      put stream outstream  skip Line format frmt skip "продолжение - на следующей странице" AT 30 SKIP .
      page stream OutStream .
      run PrintTitul .
    end.
    if  ( v-row ) >= 63000 then do:
      Output stream Macr_Excel  close .
      /*Запишем в файл параметров */
      run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name ) .
      /* создаем временный файл */
      run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
      output stream  Macr_Excel to value(v-file-name) .
      assign
        v-ind = v-ind + 1
        v-row = 2
      .

      run PutColumnTitulExcel in this-procedure .
    end.
  end.
end procedure. /* is-page */