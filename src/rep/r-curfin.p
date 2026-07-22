block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-curfin.p $
$Archive: rep/r-curfin.p $

Отчет Текущее состояние финансов

Автор: Демин Алексей Сергеевич
Дата создания: 09/13/05
Author: Alexey Demin
Creation date: 09/13/05

*/

define input parameter p-radio-schet as integer   no-undo .
define input parameter p-curr-code   as integer   no-undo .
define input parameter p-radio-sort  as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-curfin.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-curfin.p $":U .
define variable vss-description as character no-undo init "Текущее состояние финансов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/r-page1.i  }
{ trg/factord.i  }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ gbl/cur-time.i }
{ cmp/library.i }
/*{ gbl/paramls.i }*/
/*{ rep/mcrexcel.i }*/

do
on error undo, return error
:

/*define variable make-excel as logical   no-undo .*/
DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
ASSIGN parParentProc =  my-handle .
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

{ gbl/prn-lib.i }

define variable v-curr-r-b as integer   no-undo .
{ gbl/basecode.i v-cntxt-host-code-obj v-curr-r-b }

DEFINE temp-table temp-DiscSales no-undo
    field   sum-doc          as decimal
    field   sum-rubl         as decimal
    field   sum-base         as decimal
    field   name             as  char
    field   code             as integer
    field   curr             as  char
    field   nal              as logical
    INDEX pi  IS PRIMARY   code
    INDEX pi1              name
    INDEX pi2              curr
    INDEX pi3              sum-doc
    INDEX pi4              sum-rubl
    INDEX pi5              sum-base
  .

  define variable  v-fact-order           as decimal   no-undo .
  run day-begin-fact-order in this-procedure ( input x-Date-Alone + 1 , output v-fact-order ).

  define variable v-ind             as integer   no-undo .
  define variable ii as integer initial 0  no-undo .
  define variable Counter1               as integer   no-undo .
  define variable Line                   as character no-undo .

  define variable v-sum-rubl        as decimal   no-undo .
  define variable v-sum-base        as decimal   no-undo .
  define variable v-NameString  as character no-undo .

  assign  Counter1 = 0 .
  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 1 } /* Показать окно информации о текущем процессе */

  define buffer buf_fin-schet for fin-schet .
  define buffer buf_fin-code-cor-acc for fin-code-cor-acc .
  define buffer buf_arh-fin-doc-schet for arh-fin-doc-schet .
  define buffer buf_currency for currency .

/*  for each temp-DiscSales :   delete temp-DiscSales .  end.*/
  case p-radio-schet :
    when  2 then do: /* все счета */
      assign  v-NameString = "Счета: все " .
      for each buf_fin-schet no-lock
        where buf_fin-schet.host-code = v-cntxt-host-code-obj
          and buf_fin-schet.cli-code  = v-cntxt-host-code-obj
          and buf_fin-schet.cli-type  = {&cmp} :
        { rep/r-curfn1.i } /* смотрим и кладем в темп-тейбл  */
      end.
    end.
    when 5 then do: /* р у б л и */
      for each buf_fin-schet no-lock
        where buf_fin-schet.host-code = v-cntxt-host-code-obj
          and buf_fin-schet.cli-code  = v-cntxt-host-code-obj
          and buf_fin-schet.cli-type  = {&cmp}
          and buf_fin-schet.curr-code = 0 :
        { rep/r-curfn1.i } /* смотрим и кладем в темп-тейбл  */
      end.
      assign  v-NameString = "Счета: только {&abbr_rubl}." .
    end.
    when 6 then do: /* не  р у б л и */
      for each buf_fin-schet no-lock
        where buf_fin-schet.host-code = v-cntxt-host-code-obj
          and buf_fin-schet.cli-code  = v-cntxt-host-code-obj
          and buf_fin-schet.cli-type  = {&cmp}
          and buf_fin-schet.curr-code <> 0 :
        { rep/r-curfn1.i } /* смотрим и кладем в темп-тейбл  */
      end.
      assign  v-NameString = "Счета: только валютные" .
    end.
    when 7 then do: /* выбраная валюта */
      for each buf_fin-schet no-lock
        where buf_fin-schet.host-code = v-cntxt-host-code-obj
          and buf_fin-schet.cli-code  = v-cntxt-host-code-obj
          and buf_fin-schet.cli-type  = {&cmp}
          and buf_fin-schet.curr-code = p-curr-code :
        { rep/r-curfn1.i } /* смотрим и кладем в темп-тейбл  */
      end.
      assign  v-NameString = "Счета: только в " + buf_currency.curr-abbr .
    end.
/*    if RADIO-nal <> 2 then do:  /* нал  */*/
/*      for each buf_fin-code-cor-acc no-lock*/
/*        where buf_fin-code-cor-acc.host-code = p-curr-host-code*/
/*        :*/
/*        { rep/r-curfn1.i } /* смотрим и кладем в темп-тейбл  */*/
/*      end.*/
/*    end.*/
    when 3 or when 4 then do:  /* список счетов */
      assign  v-NameString = "Счета: выборочно (б/н)" .
      do ii = 1 to num-entries ( fin-schet-recid ) :
        find first buf_fin-schet no-lock where recid(buf_fin-schet) = int(entry(ii,fin-schet-recid)) .
        { rep/r-curfn1.i } /* смотрим и кладем в темп-тейбл  */
      end.
    end.
  end.

  { gbl/working.i }

  Line = fill("-", 250).

/*  assign*/
/*    make-excel = yes*/
/*    v-file-name = string(session :temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt"*/
/*  .*/
/*  output stream macr_excel to value(v-file-name) .*/
/*  assign v-ind = v-ind + 1 .*/

  DEFINE frame f-doc
      sym1  temp-DiscSales.name      column-label "Наименование счета"    format "X(40)"                    space(0)
      sym2  temp-DiscSales.curr      column-label "Вал"                   format "X(3)"                     space(0)
      sym3  temp-DiscSales.sum-doc   column-label "в валюте счета "       format "->>,>>>,>>>,>>>,>>9.99"   space(0)
      sym4  temp-DiscSales.sum-rubl  column-label "в {&abbr_rublyah}    " format "->>,>>>,>>>,>>>,>>9.99"   space(0)
      sym5  temp-DiscSales.sum-base  column-label "в Б.валюте   "         format "->>,>>>,>>>,>>>,>>9.99"   space(0)
      sym6
  HEADER
      string( "Дата печати : " + string(TODAY , "99.99.9999") + " , " + string(TIME, "HH:MM") ) AT 5 format "X(60)"
      string( "Страница " + string( PAGE-NUMBER( PrnLibStream )  , ">>9") ) AT 100 format "X(15)" SKIP Line format "X(120)" AT 1
  with width {&A4_CW} down stream-io.

/*  { cmp/open-out.i stream PrnLibStream " " {&CS_PS} }*/
  run prn-lib-open-stream  in this-procedure (input parParentProc,input {&CS_PS},input yes,input no).

  FORM HEADER
      Line format "X(120)" AT 1 SKIP   "Продолжение - на следующей странице" AT 30 SKIP
      with FRAME BottomFrame width {&A4_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW stream PrnLibStream FRAME BottomFrame .

  FORM with FRAME f-doc .

  PUT stream PrnLibStream SPACE(30) ReportNAme format "X(100)" SKIP .
  PUT stream PrnLibStream str1 format "X(100)" SKIP .

/*  if RADIO-schet = 2 then assign  v-NameString = "Счета: выборочно (б/н)" .*/
/*  else do:*/
/*    assign  v-NameString = "Счета: все " .*/
/*    if RADIO-nal = 2 then assign v-NameString = v-NameString + "(б/н)" .*/
/*    else if RADIO-nal = 3 then assign v-NameString = v-NameString + "(нал.)" .*/
/*    case RADIO-curr :*/
/*      when 2 then assign v-NameString = v-NameString + ", только {&abbr_rubl}."  .*/
/*      when 3 then assign v-NameString = v-NameString + ", только валютные"  .*/
/*      when 4 then assign v-NameString = v-NameString + ", только в " + buf_currency.curr-abbr .*/
/*    end case .*/
/*  end.*/
  PUT stream PrnLibStream v-NameString format "X(100)" SKIP .

/*  run PutColumnTitulExcel in this-procedure .*/

  case p-radio-sort :
    when 1 then do:
      for each temp-DiscSales break by temp-DiscSales.name :     run prn-line in this-procedure .  end.
    end.
    when 2 then do:
      for each temp-DiscSales break by temp-DiscSales.curr :     run prn-line in this-procedure .  end.
    end.
    when 3 then do:
      for each temp-DiscSales break by temp-DiscSales.sum-doc descending :  run prn-line in this-procedure .  end.
    end.
    when 4 then do:
      for each temp-DiscSales break by temp-DiscSales.sum-rubl descending : run prn-line in this-procedure .  end.
    end.
    when 5 then do:
      for each temp-DiscSales break by temp-DiscSales.sum-base descending : run prn-line in this-procedure .  end.
    end.
  end.

  PUT STREAM PrnLibStream Line format "X(120)".
  display stream PrnLibStream
    sym1 "Итого " @ temp-DiscSales.name sym2 sym3 sym4 v-sum-rubl @ temp-DiscSales.sum-rubl sym5 v-sum-base @ temp-DiscSales.sum-base sym6
  with frame f-doc.
  down stream PrnLibStream with frame f-doc .
  PUT STREAM PrnLibStream Line format "X(120)".

  HIDE stream PrnLibStream FRAME BottomFrame .
  OUTPUT stream PrnLibStream CLOSE.

/*  output stream macr_excel close .*/
/*  run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name) .*/
/*  run end-proc .*/

  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */
  { gbl/stopwork.i }

  run prn-lib-prn-file in this-procedure (input parParentProc,input 0).
end.


procedure prn-line :
  do on error undo, return error return-value :

    assign
      v-sum-rubl = v-sum-rubl + temp-DiscSales.sum-rubl
      v-sum-base = v-sum-base + temp-DiscSales.sum-base
    .
    display stream PrnLibStream
      sym1  temp-DiscSales.name
      sym2  temp-DiscSales.curr
      sym3  temp-DiscSales.sum-doc
      sym4  temp-DiscSales.sum-rubl
      sym5  temp-DiscSales.sum-base
      sym6
    with frame f-doc.
    down stream PrnLibStream with frame f-doc .

/*    run macr_excel_char(temp-DiscSales.name    , v-row, 1) .*/
/*    run macr_excel_char(temp-DiscSales.curr    , v-row, 2) .*/
/*    run macr_excel_sum (temp-DiscSales.sum-doc , v-row, 3, 2) .*/
/*    run macr_excel_sum (temp-DiscSales.sum-rubl, v-row, 3, 2) .*/
/*    run macr_excel_sum (temp-DiscSales.sum-base, v-row, 3, 2) .*/
/*    assign v-row = v-row + 1 .*/
  end.
end procedure. /* prn-line */


procedure PutColumnTitulExcel : /* заголовки для колонок экселя */
  do
  on error undo, return error return-value
  :
/*    assign  v-row = 4 .*/
/*    run macr_excel_char ("Cостояние финансов на " + string(x-date,"99/99/9999") + "г.", 1, 2) .*/
/*    run macr_cell_format ( 11, yes, no, ?, 1, 2, 1, 2) .*/
/*    run macr_excel_char (v-NameString, 2, 1) .*/
/*    run macr_excel_char("Наименование счета", 3, 1) .*/
/*    run macr_cell_size (40,?, 3, 1,?,?).*/
/*    run macr_excel_char("Вал", 3, 2) .*/
/*    run macr_cell_size (4,?, 3, 2,?,?).*/
/*    run macr_excel_char("в валюте счета", 3, 3) .*/
/*    run macr_excel_char("в {&abbr_rublyah}", 3, 4) .*/
/*    run macr_excel_char("в Б.валюте", 3, 5) .*/

/*    run macr_cell_bordur ( 3, 1, 3, 5) .*/
/*    run macr_cell_format ( 10, yes, no, 35, 3, 1, 3, 5) .*/
/*    run macr_cell_size (12,?, 3, 3, 3, 5) .*/
   end.
end procedure. /* PutColumnTitulExcel */