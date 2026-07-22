block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-book.p $
$Archive: rep/r-book.p $

Книга покупок

Автор: Демин Алексей Сергеевич
Дата создания: 11/25/05
Author: Alexey Demin
Creation date: 11/25/05

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-book.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-book.p $":U .
define variable vss-description as character no-undo init "Книга покупок".
{ cmp/vssrevis.i }

define Stream OutStream.

  &scop L1    1
  &scop L2    6
  &scop L3    20
  &scop L4    29
  &scop L5    38
  &scop L6    77
  &scop L7    93
  &scop L8    109
  &scop L9    124
  &scop L10   139
  &scop L11   150
  &scop L12   165
  &scop L13   176
  &scop L14   187
  &scop L15   198

  &scop F1    "99/99/99"
  &scop F2    "->>>>>>>>>9.99"
  &scop F3    "->>>>>9.99"
  &scop FL    "X(198)"
  &scop FL1   string("X(" + string( {&L15} - {&L9} - 1 ) + ")")
  &scop FL2   string("X(" + string( {&L14} - {&L9} - 1 ) + ")")




do
on error undo, return error
:
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }

DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
ASSIGN parParentProc =  my-handle .

{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/prn-lib.i }

define variable g#report-num as integer   no-undo .
run  get-report-num in my-handle (output g#report-num).

{ trg/factord.i  }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ rep/f-fdec.i   }
{ gbl/paramls.i  }
/*{ rep/mcrexcel.i }*/
{ gbl/cur-time.i }
{ str/bookxl.i   }
/*{ cmp/library.i }*/


/*define variable make-excel as logical   no-undo .*/
  define variable  v-fact-order-start     as decimal   no-undo .
  define variable  v-fact-order-end       as decimal   no-undo .
  run day-begin-fact-order in this-procedure ( input x-date-start,        output v-fact-order-start ). /*Поиск нач fact-order*/
  run day-begin-fact-order in this-procedure ( input ( x-date-end + 1 ),  output v-fact-order-end ). /*Поиск посл fact-order*/

  define variable v-ind                  as integer   no-undo .
  define variable ind                    as integer   no-undo .
  define variable ind1                   as integer   no-undo .
  define variable ii                     as integer initial 0  no-undo .
  define variable jj                     as integer initial 0  no-undo .
  define variable kk                     as integer initial 0  no-undo .
  define variable Counter1               as integer   no-undo .
  define variable Line                   as character no-undo .
  define variable v-row                  as integer   no-undo .
  define variable v-col                  as integer   no-undo .

/*  define variable s-val as character init {&abbr_rubl} no-undo .*/
/*  if x-SET_val_TYPE = 1 then assign s-val = "{&abbr_rubl}." .*/
/*  else                       assign s-val = "б.вал." .*/

  define variable v-sum1       as decimal   no-undo .
  define variable v-sum2       as decimal   no-undo .
  define variable v-sum3       as decimal   no-undo .
  define variable v-sum4       as decimal   no-undo .
  define variable v-sum5       as decimal   no-undo .
  define variable v-sum6       as decimal   no-undo .
  define variable v-sum7       as decimal   no-undo .

  define variable v-str  as CHAR  no-undo .

  assign  Counter1 = 0 .
  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 1 } /* Показать окно информации о текущем процессе */

    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) .
    output close.
    output to value( string( session:temp-directory + {&DF_Name} + string( g#report-num ) ) + ".txl" ) .
    output close.

  define buffer buf_schet-fact-doc   for schet-fact-doc .

  { gbl/working.i }

  Line = fill("-", 250).

  run bookxl-init in this-procedure .

/*  assign*/
/*    make-excel = yes*/
/*    v-file-name = string(session :temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt"*/
/*  .*/
/*  output stream macr_excel to value(v-file-name) .*/
  assign v-ind = v-ind + 1 .

  run prn-lib-open-stream  in this-procedure (input parParentProc,input {&LS_PS_A4},input yes,input no).

  find first clients no-lock where clients.obj-code = v-cntxt-host-code-obj and clients.obj-type = {&cmp} .
  find first firm no-lock where firm.firm-code = v-cntxt-host-code-obj .

  run PrintTitul in this-procedure .
  run bookxl-write-cell-data in this-procedure ( input {&bookxl-h_organization}, input clients.obj-name ).
  run bookxl-write-cell-data in this-procedure ( input {&bookxl-h_inn}         , input firm.inn + "/" + firm.kpp ).
  run bookxl-write-cell-data in this-procedure ( input {&bookxl-h_startDate}   , input string(x-date-start,"99/99/9999") ).
  run bookxl-write-cell-data in this-procedure ( input {&bookxl-h_endDate}     , input string(x-date-end,"99/99/9999") ).

  define variable list-sf as character no-undo .
  assign list-sf = "" .
  for each buf_schet-fact-doc no-lock
    where buf_schet-fact-doc.host-code  = v-cntxt-host-code-obj
      AND buf_schet-fact-doc.fact-order >= v-fact-order-start
      AND buf_schet-fact-doc.fact-order < v-fact-order-end
      AND buf_schet-fact-doc.status_    = {&fact}
      AND buf_schet-fact-doc.doc-type   = {&income}
  :
    if buf_schet-fact-doc.book-code = "" then do:
      if list-sf <> "" then  assign  list-sf = list-sf + ", " .
      assign  list-sf = list-sf + buf_schet-fact-doc.doc-code + " от " + string(buf_schet-fact-doc.doc-date,"99/99/99") .
      next .
    end.
    run is-page in this-procedure .
    assign
      Counter1 = Counter1 + 1
      v-sum1   = v-sum1 + buf_schet-fact-doc.sum-rubl
      v-sum2   = v-sum2 + buf_schet-fact-doc.sum-VAT-20-rubl
      v-sum3   = v-sum3 + buf_schet-fact-doc.VAT-20-rubl
      v-sum4   = v-sum4 + buf_schet-fact-doc.sum-VAT-10-rubl
      v-sum5   = v-sum5 + buf_schet-fact-doc.VAT-10-rubl
      v-sum6   = v-sum6 + buf_schet-fact-doc.sum-VAT-0-rubl
      v-sum7   = v-sum7 + buf_schet-fact-doc.sum-VAT-no-rubl
    .
    { rep/repfrm.i disp Counter1 }
    run bookxl-write-line-data in this-procedure (
        input string(Counter1)
      , input string(string(buf_schet-fact-doc.doc-date,"99/99/99") + " " + buf_schet-fact-doc.book-code)
      , input (if buf_schet-fact-doc.pay-date = ? then "" else string(buf_schet-fact-doc.pay-date,"99/99/99") )
      , input (if buf_schet-fact-doc.in-date = ? then "" else string(buf_schet-fact-doc.in-date,"99/99/99") )
      , input buf_schet-fact-doc.cli-name
      , input buf_schet-fact-doc.cli-inn
      , input buf_schet-fact-doc.cli-kpp
      , input string(buf_schet-fact-doc.country + " " + buf_schet-fact-doc.gtd)
      , input buf_schet-fact-doc.sum-rubl
      , input buf_schet-fact-doc.sum-VAT-20-rubl
      , input buf_schet-fact-doc.VAT-20-rubl
      , input buf_schet-fact-doc.sum-VAT-10-rubl
      , input buf_schet-fact-doc.VAT-10-rubl
      , input buf_schet-fact-doc.sum-VAT-0-rubl
      , input buf_schet-fact-doc.sum-VAT-no-rubl
    ).
    put stream PrnLibStream
      "|"  at {&L1}   Counter1       format ">>>9"
      "|"  at {&L2}   buf_schet-fact-doc.doc-date format {&F1}
      "|"  at {&L3}   buf_schet-fact-doc.pay-date format {&F1}
      "|"  at {&L4}   buf_schet-fact-doc.in-date  format {&F1}
      "|"  at {&L5}   buf_schet-fact-doc.cli-name format "X(38)"
      "|"  at {&L6}   buf_schet-fact-doc.cli-inn  format "X(15)"
      "|"  at {&L7}   buf_schet-fact-doc.country  format "X(15)"
      "|"  at {&L8}   buf_schet-fact-doc.sum-rubl        format {&F2}
      "|"  at {&L9}   buf_schet-fact-doc.sum-VAT-20-rubl format {&F2}
      "|"  at {&L10}  buf_schet-fact-doc.VAT-20-rubl     format {&F3}
      "|"  at {&L11}  buf_schet-fact-doc.sum-VAT-10-rubl format {&F2}
      "|"  at {&L12}  buf_schet-fact-doc.VAT-10-rubl     format {&F3}
      "|"  at {&L13}  buf_schet-fact-doc.sum-VAT-0-rubl  format {&F3}
      "|"  at {&L14}  buf_schet-fact-doc.sum-VAT-no-rubl format {&F3}
      "|"  at {&L15}
      skip
      "|"  at {&L1}
      "|"  at {&L2}   buf_schet-fact-doc.book-code format "X(12)"
      "|"  at {&L3}
      "|"  at {&L4}
      "|"  at {&L5}
      "|"  at {&L6}   buf_schet-fact-doc.cli-kpp  format "X(15)"
      "|"  at {&L7}   buf_schet-fact-doc.gtd  format "X(15)"
      "|"  at {&L8}
      "|"  at {&L9}
      "|"  at {&L10}
      "|"  at {&L11}
      "|"  at {&L12}
      "|"  at {&L13}
      "|"  at {&L14}
      "|"  at {&L15}
      skip  .
  end.
  run bookxl-write-cell-data in this-procedure ( input {&bookxl-it_sum} ,      input string( v-sum1 ) ).
  run bookxl-write-cell-data in this-procedure ( input {&bookxl-it_sumVAT20} , input string( v-sum2 ) ).
  run bookxl-write-cell-data in this-procedure ( input {&bookxl-it_VAT20} ,    input string( v-sum3 ) ).
  run bookxl-write-cell-data in this-procedure ( input {&bookxl-it_sumVAT10} , input string( v-sum4 ) ).
  run bookxl-write-cell-data in this-procedure ( input {&bookxl-it_VAT10} ,    input string( v-sum5 ) ).
  run bookxl-write-cell-data in this-procedure ( input {&bookxl-it_sumVAT0} ,  input string( v-sum6 ) ).
  run bookxl-write-cell-data in this-procedure ( input {&bookxl-it_sumVATno} , input string( v-sum7 ) ).
  put stream PrnLibStream  Line format {&FL}
      "|"  at {&L1}
       "ВСЕГО" format "X(29)" at {&L5}
      "|"  at {&L8}   v-sum1 format {&F2}
      "|"  at {&L9}   v-sum2 format {&F2}
      "|"  at {&L10}  v-sum3 format {&F3}
      "|"  at {&L11}  v-sum4 format {&F2}
      "|"  at {&L12}  v-sum5 format {&F3}
      "|"  at {&L13}  v-sum6 format {&F3}
      "|"  at {&L14}  v-sum7 format {&F3}
      "|"  at {&L15}
      skip
      Line format {&FL}   skip   "    Гл. бухгалтер" format "X(30)"
  .

  HIDE stream PrnLibStream FRAME BottomFrame .
  OUTPUT stream PrnLibStream CLOSE.

/*  output stream macr_excel close .*/
/*  run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name) .*/
/*  run end-proc .*/
  run bookxl-close in this-procedure .

  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */
  { gbl/stopwork.i }

  if list-sf <> "" then
    message
      "В выбранном периоде есть закрытые счета-фактуры "  skip
      list-sf  skip
      "не имеющие номера в книге. Отчет сформирован без них."
      view-as alert-box.

  os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" ) .
  os-rename
      value(  string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
      value(  string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
  .
  run prn-lib-prn-file in this-procedure (input parParentProc,input 8).
  os-delete value( string( session:temp-directory ) +  "$" + string( g#report-num ) + ".txl" ) .
  os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" ) .
end.


procedure is-page :
  do on error undo, return error return-value :
    if line-counter( PrnLibStream ) + 3 > page-size( PrnLibStream ) then do:
      put stream PrnLibStream  skip Line format {&FL} skip "продолжение - на следующей странице" AT 30 SKIP .
      page stream PrnLibStream .
      run PrintTitul .
    end.
  end.
end procedure. /* is-page */



procedure PrintTitul :
  do
  on error undo, return error return-value
  :
    PUT stream PrnLibStream
      SPACE(30) "КНИГА ПОКУПОК" format "X(100)" SKIP
      string("Покупатель: " + clients.obj-name)  format "X(100)" SKIP
      string("Идентификационный номер налогоплательщика-покупателя: " + firm.inn  + "/" + firm.kpp )  format "X(100)" SKIP
      string("Покупка за период с: " + string(x-date-start,"99/99/9999") + "г. по: "  + string(x-date-end, "99/99/9999") + "г.")   format "X(100)" SKIP
    .

    put stream PrnLibStream  /*cur-time-print() format "x(35)"*/ string( "Страница" ) AT 145 PAGE-NUMBER( PrnLibStream ) AT 155 FORMAT ">>9" SKIP .

    put stream PrnLibStream  Line format {&FL}  skip
      "|"  at {&L1}   " № "                        format "X(4)"
      "|"  at {&L2}   "Дата и номер"               format "X(12)"
      "|"  at {&L3}   "Дата"                       format "X(8)"
      "|"  at {&L4}   "Дата"                       format "X(8)"
      "|"  at {&L5}   " Наименование поставщика"   format "X(25)"
      "|"  at {&L6}   "{&abbr_inn_allshift}/{&abbr_kpp_allshift}"     format "X(10)"
      "|"  at {&L7}   "Страна"                     format "X(14)"
      "|"  at {&L8}   "Всего"                      format "X(10)"
      "|"  at {&L9}   "В том числе покупки, облагаемые налогом по ставке"                format "X(50)"
      "|"  at {&L15}
      skip
      "|"  at {&L1}   " п/п"                       format "X(4)"
      "|"  at {&L2}   "счета-фактуры"              format "X(12)"
      "|"  at {&L3}   "оплаты"                     format "X(8)"
      "|"  at {&L4}   "оприход."                   format "X(8)"
      "|"  at {&L5}
      "|"  at {&L6}   "поставщика"                 format "X(10)"
      "|"  at {&L7}   "происхождения"              format "X(14)"
      "|"  at {&L8}   "покупок,"                   format "X(10)"
      "|"  at {&L9}   Line format {&FL1}
      "|"  at {&L15}
      skip
      "|"  at {&L1}
      "|"  at {&L2}   "продавца"  format "X(12)"
      "|"  at {&L3}   "счета-"     format "X(8)"
      "|"  at {&L4}   "товара"     format "X(8)"
      "|"  at {&L5}
      "|"  at {&L6}
      "|"  at {&L7}   "товара."     format "X(8)"
      "|"  at {&L8}   "включая НДС"                      format "X(11)"
      "|"  at {&L9}   "      18 %"    format "X(12)"
      "|"  at {&L11}  "      10 %"    format "X(12)"
      "|"  at {&L13}  "    0 %"    format "X(9)"
      "|"  at {&L14}  "покупки"    format "X(10)"
      "|"  at {&L15}
      skip
      "|"  at {&L1}
      "|"  at {&L2}
      "|"  at {&L3}   "фактуры"     format "X(8)"
      "|"  at {&L4}
      "|"  at {&L5}
      "|"  at {&L6}
      "|"  at {&L7}  "Номер ГТД"      format "X(14)"
      "|"  at {&L8}
      "|"  at {&L9}  Line format {&FL2}
      "|"  at {&L14} "освобожд."  format "X(10)"
      "|"  at {&L15}
      skip
      "|"  at {&L1}
      "|"  at {&L2}
      "|"  at {&L3}   "продавца"     format "X(8)"
      "|"  at {&L4}
      "|"  at {&L5}
      "|"  at {&L6}
      "|"  at {&L7}
      "|"  at {&L8}
      "|"  at {&L9}   "стоим. без НДС"   format "X(14)"
      "|"  at {&L10}  "сумма НДС"        format "X(9)"
      "|"  at {&L11}  "стоим. без НДС"   format "X(14)"
      "|"  at {&L12}  "сумма НДС"        format "X(9)"
      "|"  at {&L13}
      "|"  at {&L14} "от налога"  format "X(9)"
      "|"  at {&L15}
      skip  Line format {&FL}  skip .
    .

  end.
end procedure. /* PrintTitul */