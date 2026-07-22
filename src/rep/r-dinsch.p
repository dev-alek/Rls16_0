block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-dinsch.p $
$Archive: rep/r-dinsch.p $

Отчет Динамика финансового движения по счету

Автор: Демин Алексей Сергеевич
Дата создания: 09/13/05
Author: Alexey Demin
Creation date: 09/13/05

*/

define input parameter ParParentProc  as widget-handle no-undo.
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo.
define input parameter p-code-schet    as integer   no-undo .
define input parameter p-num-key       as integer   no-undo .
define input parameter p-key-list      as character no-undo .
define input parameter p-date1         as date no-undo .
define input parameter p-date2         as date no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-dinsch.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-dinsch.p $":U .
define variable vss-description as character no-undo init "Динамика финансового движения по счету".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
/*{ gbl/paramls.i }*/
/*{ rep/mcrexcel.i }*/
{ gbl/prn-lib.i  }
{ trg/factord.i  }

do
on error undo, return error
:

/*define variable make-excel as logical   no-undo .*/

  &scop FL    "X(198)"

  define variable v-ind             as integer   no-undo .
  define variable ii as integer initial 0  no-undo .
  define variable Counter1               as integer   no-undo .
  define variable Line                   as character no-undo .

  define variable v-sum1        as decimal   no-undo .
  define variable v-sum2        as decimal   no-undo .
  define variable v-all-sum1        as decimal   no-undo .
  define variable v-all-sum2        as decimal   no-undo .
  define variable v-NameString  as character no-undo .

  assign  Counter1 = 0 .
  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 1 } /* Показать окно информации о текущем процессе */

  define buffer buf_fin-schet for fin-schet .
  define buffer buf_fin-bank  for fin-bank .
  define buffer buf_fin-doc   for fin-doc .
  define buffer buf_currency  for currency .

  define variable  v-fact-order1           as decimal   no-undo .
  run day-begin-fact-order in this-procedure ( input p-date1, output v-fact-order1 ).
  define variable  v-fact-order2           as decimal   no-undo .
  run day-begin-fact-order in this-procedure ( input p-date2 + 1 , output v-fact-order2 ).

  { gbl/working.i }

  Line = fill("-", 250).

/*  assign*/
/*    make-excel = yes*/
/*    v-file-name = string(session :temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt"*/
/*  .*/
/*  output stream macr_excel to value(v-file-name) .*/
/*  assign v-ind = v-ind + 1 .*/


  DEFINE frame f-doc
      sym1  buf_fin-doc.doc-date       column-label "Дата! ! "                format "99/99/99"                 space(0)
      sym2  buf_fin-doc.cor-acc-value  column-label "Кор.!счет! "             format "X(7)"                     space(0)
      sym3  buf_fin-doc.an-uchet-value column-label "Шифр!аналит!учета"       format "X(7)"                     space(0)
      sym4  buf_fin-doc.cel-nazn-value column-label "Шифр!целев.!назн."       format "X(7)"                     space(0)
      sym5  v-sum1                     column-label "Сумма!поступления! "     format "->>>>,>>>,>>>,>>9.99"     space(0)
      sym6  v-sum2                     column-label "Сумма!выбытия! "         format "->>>>,>>>,>>>,>>9.99"     space(0)
      sym7  buf_fin-doc.prn-doc-code   column-label "Номер!платеж.!поруч."    format "X(10)"                    space(0)
      sym8  buf_fin-doc.payer-name     column-label "Плательщик! ! "          format "X(20)"                    space(0)
      sym9  buf_fin-doc.receiver-name  column-label "Получатель! ! "          format "X(20)"                    space(0)
      sym10 buf_fin-doc.naznach-plat   column-label "Назначение!платежа! "    format "X(58)"                    space(0)
      sym11
  HEADER
      string( "Дата печати : " + string(TODAY , "99.99.9999") + " , " + string(TIME, "HH:MM") ) AT 5 format "X(50)"
      string( "Страница " + string( PAGE-NUMBER( PrnLibStream )  , ">>9") ) AT 100 format "X(15)" SKIP Line format {&FL} AT 1
  with width {&DOS_CW} down stream-io.

  run prn-lib-open-stream  in this-procedure (input parParentProc,input {&LS_PS_A4},input yes,input no).

  FORM HEADER
      Line format {&FL} AT 1 SKIP   "Продолжение - на следующей странице" AT 30 SKIP
      with FRAME BottomFrame width {&DOS_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW stream PrnLibStream FRAME BottomFrame .

  FORM with FRAME f-doc .

  PUT stream PrnLibStream SPACE(30) string( "Динамика финансового движения по счету c " + string(p-date1,"99/99/9999") + "г. по " + string(p-date2,"99/99/9999") + "г.") format "X(120)" SKIP .

  find first buf_fin-schet no-lock where recid (buf_fin-schet) = p-code-schet no-error .
  find first buf_fin-bank  no-lock where buf_fin-bank.host-code   = buf_fin-schet.host-code and buf_fin-bank.code-bank  = buf_fin-schet.code-bank no-error .
  find first buf_currency  no-lock where buf_currency.curr-code   = buf_fin-schet.curr-code .
  PUT stream PrnLibStream string("Р/С " + buf_fin-schet.r-schet + " (в.н. " + string(buf_fin-schet.code-schet) + ") в банке " + buf_fin-bank.short-name + " ,валюта: " + buf_currency.curr-abbr) format "X(160)"   skip .

  case p-num-key :
    when 1 then do:
      case entry(1,p-key-list) :
        when "buf_fin-doc.doc-date"      then do: { rep/r-dinsc1.i buf_fin-doc.doc-date      } end.
        when "buf_fin-doc.cor-acc"  then do: { rep/r-dinsc1.i buf_fin-doc.cor-acc  } end.
        when "buf_fin-doc.an-uchet-code" then do: { rep/r-dinsc1.i buf_fin-doc.an-uchet-code } end.
        when "buf_fin-doc.cel-nazn-code" then do: { rep/r-dinsc1.i buf_fin-doc.cel-nazn-code } end.
      end.
    end.
    when 2 then do:
      run lavel-2 in this-procedure .
    end.
    when 3 then do:
      run lavel-3 in this-procedure .
    end.
    when 4 then do:
      run lavel-4 in this-procedure .
    end.
  end.

  PUT STREAM PrnLibStream Line format {&FL}.
  display stream PrnLibStream
    sym1 "Итого" @ buf_fin-doc.cel-nazn-value sym2 sym3 sym4 v-all-sum1 @ v-sum1 v-all-sum2 @ v-sum2 sym5 sym6 sym7 sym8 sym9 sym10 sym11
  with frame f-doc.
  down stream PrnLibStream with frame f-doc .
  PUT STREAM PrnLibStream Line format {&FL}.

  HIDE stream PrnLibStream FRAME BottomFrame .
  OUTPUT stream PrnLibStream CLOSE.

/*  output stream macr_excel close .*/
/*  run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name) .*/
/*  run end-proc .*/

  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */
  { gbl/stopwork.i }

  run prn-lib-prn-file in this-procedure (input parParentProc,input 8).
end.


procedure prn-line :
  do on error undo, return error return-value :

    if buf_fin-doc.fin-doc-type = {&income-cashless} then assign v-all-sum1 = v-all-sum1 + buf_fin-doc.sum-doc .
    else                                                  assign v-all-sum2 = v-all-sum2 + buf_fin-doc.sum-doc .
    display stream PrnLibStream
      sym1  buf_fin-doc.doc-date
      sym2  buf_fin-doc.cor-acc-value
      sym3  buf_fin-doc.an-uchet-value
      sym4  buf_fin-doc.cel-nazn-value
      sym5  (if buf_fin-doc.fin-doc-type = {&income-cashless} then buf_fin-doc.sum-doc else 0) @ v-sum1
      sym6  (if buf_fin-doc.fin-doc-type = {&income-cashless} then 0 else buf_fin-doc.sum-doc) @ v-sum2
      sym7  buf_fin-doc.prn-doc-code
      sym8  buf_fin-doc.payer-name
      sym9  buf_fin-doc.receiver-name
      sym10 buf_fin-doc.naznach-plat
      sym11
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


procedure lavel-2 :
  do on error undo, return error return-value :
      case entry(1,p-key-list) :
        when "buf_fin-doc.doc-date"      then do:
          case entry(2,p-key-list) :
            when "buf_fin-doc.cor-acc"  then do: { rep/r-dinsc2.i buf_fin-doc.doc-date buf_fin-doc.cor-acc  } end.
            when "buf_fin-doc.an-uchet-code" then do: { rep/r-dinsc2.i buf_fin-doc.doc-date buf_fin-doc.an-uchet-code } end.
            when "buf_fin-doc.cel-nazn-code" then do: { rep/r-dinsc2.i buf_fin-doc.doc-date buf_fin-doc.cel-nazn-code } end.
          end.
        end.
        when "buf_fin-doc.cor-acc"  then do:
          case entry(2,p-key-list) :
            when "buf_fin-doc.doc-date"      then do: { rep/r-dinsc2.i buf_fin-doc.cor-acc buf_fin-doc.doc-date      } end.
            when "buf_fin-doc.an-uchet-code" then do: { rep/r-dinsc2.i buf_fin-doc.cor-acc buf_fin-doc.an-uchet-code } end.
            when "buf_fin-doc.cel-nazn-code" then do: { rep/r-dinsc2.i buf_fin-doc.cor-acc buf_fin-doc.cel-nazn-code } end.
          end.
        end.
        when "buf_fin-doc.an-uchet-code" then do:
          case entry(2,p-key-list) :
            when "buf_fin-doc.doc-date"      then do: { rep/r-dinsc2.i buf_fin-doc.an-uchet-code buf_fin-doc.doc-date      } end.
            when "buf_fin-doc.cor-acc"  then do: { rep/r-dinsc2.i buf_fin-doc.an-uchet-code buf_fin-doc.cor-acc  } end.
            when "buf_fin-doc.cel-nazn-code" then do: { rep/r-dinsc2.i buf_fin-doc.an-uchet-code buf_fin-doc.cel-nazn-code } end.
          end.
        end.
        when "buf_fin-doc.cel-nazn-code" then do:
          case entry(2,p-key-list) :
            when "buf_fin-doc.doc-date"      then do: { rep/r-dinsc2.i buf_fin-doc.cel-nazn-code buf_fin-doc.doc-date      } end.
            when "buf_fin-doc.cor-acc"  then do: { rep/r-dinsc2.i buf_fin-doc.cel-nazn-code buf_fin-doc.cor-acc  } end.
            when "buf_fin-doc.an-uchet-code" then do: { rep/r-dinsc2.i buf_fin-doc.cel-nazn-code buf_fin-doc.an-uchet-code } end.
          end.
        end.
      end.
  end.
end procedure. /* lavel-2 */




procedure lavel-3 :
  do on error undo, return error return-value :
    case entry(1,p-key-list) :
      when "buf_fin-doc.doc-date"      then do:
        case entry(2,p-key-list) :
          when "buf_fin-doc.cor-acc"  then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.an-uchet-code" then do: { rep/r-dinsc3.i buf_fin-doc.doc-date buf_fin-doc.cor-acc buf_fin-doc.an-uchet-code } end.
              when "buf_fin-doc.cel-nazn-code" then do: { rep/r-dinsc3.i buf_fin-doc.doc-date buf_fin-doc.cor-acc buf_fin-doc.cel-nazn-code } end.
            end.
          end.
          when "buf_fin-doc.an-uchet-code" then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.cor-acc"       then do: { rep/r-dinsc3.i buf_fin-doc.doc-date buf_fin-doc.an-uchet-code buf_fin-doc.cor-acc } end.
              when "buf_fin-doc.cel-nazn-code" then do: { rep/r-dinsc3.i buf_fin-doc.doc-date buf_fin-doc.an-uchet-code buf_fin-doc.cel-nazn-code } end.
            end.
          end.
          when "buf_fin-doc.cel-nazn-code" then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.cor-acc"       then do: { rep/r-dinsc3.i buf_fin-doc.doc-date buf_fin-doc.cel-nazn-code buf_fin-doc.cor-acc } end.
              when "buf_fin-doc.an-uchet-code" then do: { rep/r-dinsc3.i buf_fin-doc.doc-date buf_fin-doc.cel-nazn-code buf_fin-doc.an-uchet-code } end.
            end.
          end.
        end.
      end.
      when "buf_fin-doc.cor-acc"  then do:
        case entry(2,p-key-list) :
          when "buf_fin-doc.doc-date"  then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.an-uchet-code" then do: { rep/r-dinsc3.i buf_fin-doc.cor-acc buf_fin-doc.doc-date buf_fin-doc.an-uchet-code } end.
              when "buf_fin-doc.cel-nazn-code" then do: { rep/r-dinsc3.i buf_fin-doc.cor-acc buf_fin-doc.doc-date buf_fin-doc.cel-nazn-code } end.
            end.
          end.
          when "buf_fin-doc.an-uchet-code" then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.doc-date"      then do: { rep/r-dinsc3.i buf_fin-doc.cor-acc buf_fin-doc.an-uchet-code buf_fin-doc.doc-date } end.
              when "buf_fin-doc.cel-nazn-code" then do: { rep/r-dinsc3.i buf_fin-doc.cor-acc buf_fin-doc.an-uchet-code buf_fin-doc.cel-nazn-code } end.
            end.
          end.
          when "buf_fin-doc.cel-nazn-code" then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.doc-date"      then do: { rep/r-dinsc3.i buf_fin-doc.cor-acc buf_fin-doc.cel-nazn-code buf_fin-doc.doc-date } end.
              when "buf_fin-doc.an-uchet-code" then do: { rep/r-dinsc3.i buf_fin-doc.cor-acc buf_fin-doc.cel-nazn-code buf_fin-doc.an-uchet-code } end.
            end.
          end.
        end.
      end.
      when "buf_fin-doc.an-uchet-code" then do:
        case entry(2,p-key-list) :
          when "buf_fin-doc.cor-acc"  then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.doc-date"      then do: { rep/r-dinsc3.i buf_fin-doc.an-uchet-code buf_fin-doc.cor-acc buf_fin-doc.doc-date } end.
              when "buf_fin-doc.cel-nazn-code" then do: { rep/r-dinsc3.i buf_fin-doc.an-uchet-code buf_fin-doc.cor-acc buf_fin-doc.cel-nazn-code } end.
            end.
          end.
          when "buf_fin-doc.doc-date" then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.cor-acc"       then do: { rep/r-dinsc3.i buf_fin-doc.an-uchet-code buf_fin-doc.doc-date buf_fin-doc.cor-acc } end.
              when "buf_fin-doc.cel-nazn-code" then do: { rep/r-dinsc3.i buf_fin-doc.an-uchet-code buf_fin-doc.doc-date buf_fin-doc.cel-nazn-code } end.
            end.
          end.
          when "buf_fin-doc.cel-nazn-code" then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.cor-acc"       then do: { rep/r-dinsc3.i buf_fin-doc.an-uchet-code buf_fin-doc.cel-nazn-code buf_fin-doc.cor-acc } end.
              when "buf_fin-doc.doc-date"      then do: { rep/r-dinsc3.i buf_fin-doc.an-uchet-code buf_fin-doc.cel-nazn-code buf_fin-doc.doc-date } end.
            end.
          end.
        end.
      end.
      when "buf_fin-doc.cel-nazn-code" then do:
        case entry(2,p-key-list) :
          when "buf_fin-doc.cor-acc"  then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.an-uchet-code" then do: { rep/r-dinsc3.i buf_fin-doc.cel-nazn-code buf_fin-doc.cor-acc buf_fin-doc.an-uchet-code } end.
              when "buf_fin-doc.doc-date"      then do: { rep/r-dinsc3.i buf_fin-doc.cel-nazn-code buf_fin-doc.cor-acc buf_fin-doc.doc-date } end.
            end.
          end.
          when "buf_fin-doc.an-uchet-code" then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.cor-acc"       then do: { rep/r-dinsc3.i buf_fin-doc.cel-nazn-code buf_fin-doc.an-uchet-code buf_fin-doc.cor-acc } end.
              when "buf_fin-doc.doc-date"      then do: { rep/r-dinsc3.i buf_fin-doc.cel-nazn-code buf_fin-doc.an-uchet-code buf_fin-doc.doc-date } end.
            end.
          end.
          when "buf_fin-doc.doc-date" then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.cor-acc"       then do: { rep/r-dinsc3.i buf_fin-doc.cel-nazn-code buf_fin-doc.doc-date buf_fin-doc.cor-acc } end.
              when "buf_fin-doc.an-uchet-code" then do: { rep/r-dinsc3.i buf_fin-doc.cel-nazn-code buf_fin-doc.doc-date buf_fin-doc.an-uchet-code } end.
            end.
          end.
        end.
      end.
    end.
  end.
end procedure. /* lavel-3 */



procedure lavel-4 :
  do on error undo, return error return-value :
    case entry(1,p-key-list) :
      when "buf_fin-doc.doc-date"      then do:
        case entry(2,p-key-list) :
          when "buf_fin-doc.cor-acc"  then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.an-uchet-code" then do: { rep/r-dinsc4.i buf_fin-doc.doc-date buf_fin-doc.cor-acc buf_fin-doc.an-uchet-code buf_fin-doc.cel-nazn-code} end.
              when "buf_fin-doc.cel-nazn-code" then do: { rep/r-dinsc4.i buf_fin-doc.doc-date buf_fin-doc.cor-acc buf_fin-doc.cel-nazn-code buf_fin-doc.an-uchet-code} end.
            end.
          end.
          when "buf_fin-doc.an-uchet-code" then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.cor-acc"       then do: { rep/r-dinsc4.i buf_fin-doc.doc-date buf_fin-doc.an-uchet-code buf_fin-doc.cor-acc       buf_fin-doc.cel-nazn-code} end.
              when "buf_fin-doc.cel-nazn-code" then do: { rep/r-dinsc4.i buf_fin-doc.doc-date buf_fin-doc.an-uchet-code buf_fin-doc.cel-nazn-code buf_fin-doc.cor-acc} end.
            end.
          end.
          when "buf_fin-doc.cel-nazn-code" then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.cor-acc"       then do: { rep/r-dinsc4.i buf_fin-doc.doc-date buf_fin-doc.cel-nazn-code buf_fin-doc.cor-acc       buf_fin-doc.an-uchet-code} end.
              when "buf_fin-doc.an-uchet-code" then do: { rep/r-dinsc4.i buf_fin-doc.doc-date buf_fin-doc.cel-nazn-code buf_fin-doc.an-uchet-code buf_fin-doc.cor-acc} end.
            end.
          end.
        end.
      end.
      when "buf_fin-doc.cor-acc"  then do:
        case entry(2,p-key-list) :
          when "buf_fin-doc.doc-date"  then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.an-uchet-code" then do: { rep/r-dinsc4.i buf_fin-doc.cor-acc buf_fin-doc.doc-date buf_fin-doc.an-uchet-code buf_fin-doc.cel-nazn-code} end.
              when "buf_fin-doc.cel-nazn-code" then do: { rep/r-dinsc4.i buf_fin-doc.cor-acc buf_fin-doc.doc-date buf_fin-doc.cel-nazn-code buf_fin-doc.an-uchet-code} end.
            end.
          end.
          when "buf_fin-doc.an-uchet-code" then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.doc-date"      then do: { rep/r-dinsc4.i buf_fin-doc.cor-acc buf_fin-doc.an-uchet-code buf_fin-doc.doc-date      buf_fin-doc.cel-nazn-code} end.
              when "buf_fin-doc.cel-nazn-code" then do: { rep/r-dinsc4.i buf_fin-doc.cor-acc buf_fin-doc.an-uchet-code buf_fin-doc.cel-nazn-code buf_fin-doc.doc-date} end.
            end.
          end.
          when "buf_fin-doc.cel-nazn-code" then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.doc-date"      then do: { rep/r-dinsc4.i buf_fin-doc.cor-acc buf_fin-doc.cel-nazn-code buf_fin-doc.doc-date      buf_fin-doc.an-uchet-code} end.
              when "buf_fin-doc.an-uchet-code" then do: { rep/r-dinsc4.i buf_fin-doc.cor-acc buf_fin-doc.cel-nazn-code buf_fin-doc.an-uchet-code buf_fin-doc.doc-date} end.
            end.
          end.
        end.
      end.
      when "buf_fin-doc.an-uchet-code" then do:
        case entry(2,p-key-list) :
          when "buf_fin-doc.cor-acc"  then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.doc-date"      then do: { rep/r-dinsc4.i buf_fin-doc.an-uchet-code buf_fin-doc.cor-acc buf_fin-doc.doc-date      buf_fin-doc.cel-nazn-code} end.
              when "buf_fin-doc.cel-nazn-code" then do: { rep/r-dinsc4.i buf_fin-doc.an-uchet-code buf_fin-doc.cor-acc buf_fin-doc.cel-nazn-code buf_fin-doc.doc-date} end.
            end.
          end.
          when "buf_fin-doc.doc-date" then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.cor-acc"       then do: { rep/r-dinsc4.i buf_fin-doc.an-uchet-code buf_fin-doc.doc-date buf_fin-doc.cor-acc       buf_fin-doc.cel-nazn-code} end.
              when "buf_fin-doc.cel-nazn-code" then do: { rep/r-dinsc4.i buf_fin-doc.an-uchet-code buf_fin-doc.doc-date buf_fin-doc.cel-nazn-code buf_fin-doc.cor-acc} end.
            end.
          end.
          when "buf_fin-doc.cel-nazn-code" then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.cor-acc"       then do: { rep/r-dinsc4.i buf_fin-doc.an-uchet-code buf_fin-doc.cel-nazn-code buf_fin-doc.cor-acc  buf_fin-doc.doc-date} end.
              when "buf_fin-doc.doc-date"      then do: { rep/r-dinsc4.i buf_fin-doc.an-uchet-code buf_fin-doc.cel-nazn-code buf_fin-doc.doc-date buf_fin-doc.cor-acc} end.
            end.
          end.
        end.
      end.
      when "buf_fin-doc.cel-nazn-code" then do:
        case entry(2,p-key-list) :
          when "buf_fin-doc.cor-acc"  then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.an-uchet-code" then do: { rep/r-dinsc4.i buf_fin-doc.cel-nazn-code buf_fin-doc.cor-acc buf_fin-doc.an-uchet-code buf_fin-doc.doc-date} end.
              when "buf_fin-doc.doc-date"      then do: { rep/r-dinsc4.i buf_fin-doc.cel-nazn-code buf_fin-doc.cor-acc buf_fin-doc.doc-date      buf_fin-doc.an-uchet-code} end.
            end.
          end.
          when "buf_fin-doc.an-uchet-code" then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.cor-acc"       then do: { rep/r-dinsc4.i buf_fin-doc.cel-nazn-code buf_fin-doc.an-uchet-code buf_fin-doc.cor-acc  buf_fin-doc.doc-date} end.
              when "buf_fin-doc.doc-date"      then do: { rep/r-dinsc4.i buf_fin-doc.cel-nazn-code buf_fin-doc.an-uchet-code buf_fin-doc.doc-date buf_fin-doc.cor-acc} end.
            end.
          end.
          when "buf_fin-doc.doc-date" then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.cor-acc"       then do: { rep/r-dinsc4.i buf_fin-doc.cel-nazn-code buf_fin-doc.doc-date buf_fin-doc.cor-acc       buf_fin-doc.an-uchet-code} end.
              when "buf_fin-doc.an-uchet-code" then do: { rep/r-dinsc4.i buf_fin-doc.cel-nazn-code buf_fin-doc.doc-date buf_fin-doc.an-uchet-code buf_fin-doc.cor-acc} end.
            end.
          end.
        end.
      end.
    end.
  end.
end procedure. /* lavel-4 */