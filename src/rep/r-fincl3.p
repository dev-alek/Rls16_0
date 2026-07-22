block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-fincl3.p $
$Archive: rep/r-fincl3.p $

Форма №3 взаиморасчет с контрагентами

Автор: Хныкин Павел Андреевич
Дата создания: 08/23/07
Author: Pavel Khnykin
Creation date: 08/23/07

*/
define input  parameter parparentproc as handle    no-undo .
define input  parameter p-rad         as integer   no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-fincl3.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-fincl3.p $":U .
define variable vss-description as character no-undo init "Форма №3 взаиморасчет с контрагентами".
{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/r-page1.i      }
{ cmp/r-pril.i       }
{ rep/r-sym.i        }
{ trg/factord.i      }
{ gbl/waitfram.i     }
{ rep/lkp-font.i     }
{ gbl/getcntxt.i def }
{ gbl/paramls.i      }


define shared temp-table g#post-f no-undo
    field obj-type  like ub.clients.obj-type
    field obj-code  like ub.clients.obj-code
    field obj-name  like ub.clients.obj-name
    field grp-code  like ub.clients.grp-code
    field grp-name  like ub.clients.grp-name
    field lvl-num   like ub.cli-grp.lvl-num
    field host-code like ub.clients.host-code
index pi is unique primary obj-type obj-code
index p1  obj-name
index hc host-code
.

&scop op-cli-money-income 1
&scop op-talon-exp 2
&scop op-talon-ret 3


define temp-table tt-report-head no-undo
    field obj-type        like ub.clients.obj-type
    field obj-code        like ub.clients.obj-code
    field obj-name        like ub.clients.obj-name
    field saldo-begin     as decimal
    field saldo-end       as decimal
index pi is unique primary obj-type obj-code
index p1  obj-name
.

define temp-table tt-report no-undo
    field obj-type        like ub.clients.obj-type
    field obj-code        like ub.clients.obj-code
    field op-type         as integer
    field op-name         as character
    field op-date         as date
    field doc-code        like ub.wth-doc.doc-code
    field ext-doc-type    like ub.wth-doc.ext-doc-type
    field sum             as decimal
index pi is primary unique obj-type obj-code doc-code op-type
index dt op-date.


define buffer buf_clients for ub.clients.

define stream out-stream.

function op-name returns character (op-type as integer) forward.

define variable g#report-num         as integer   no-undo .
define variable v-fact-order-start   as decimal   no-undo .
define variable v-fact-order-end     as decimal   no-undo .
define variable v-line               as character no-undo .
define variable v-print-rubl         as logical   no-undo .
define variable v-repfrm-str         as character no-undo .
define variable v-counter            as integer   no-undo .
define variable v-debet-sum          as decimal   no-undo .
define variable v-credit-sum         as decimal   no-undo .
define variable v-saldo-start        as decimal   no-undo .
define variable v-saldo-end          as decimal   no-undo .
define variable v-curr-r-b           as integer   no-undo .

{ rep/fincl3xl.i }
{ rep/r-fincl0.i }
{ gbl/r-b-curr.i v-cntxt-host-code-obj v-curr-r-b }


define frame fincl3
        sym1                      no-label   format "X(1)"               space(0)
        tt-report.op-name         no-label   format "X(30)"              space(0)
        sym2                      no-label   format "X(1)"               space(0)
        tt-report.op-date         no-label   format "99.99.9999"         space(0)
        sym3                      no-label   format "X(1)"               space(0)
        tt-report.doc-code        no-label   format "X(16)"              space(0)
        sym4                      no-label   format "X(1)"               space(0)
        v-debet-sum               no-label   format "->,>>>,>>>,>>9.99"  space(0)
        sym5                      no-label   format "X(1)"               space(0)
        v-credit-sum              no-label   format "->,>>>,>>>,>>9.99"  space(0)
        sym6                      no-label   format "X(1)"               space(0)
with width {&A4_CW} down no-box stream-io .

form header
        v-line format "X(100)" at 1 SKIP
        "Продолжение - на следующей странице" at 1 SKIP
with frame BottomFrame width {&A4_CW} PAGE-BOTTOM NO-LABELS NO-BOX .


do on error undo, return error return-value :
  assign
    v-line    = fill( "-" , 300 )
  .
  /* выбираем валюту */
  case x-SET_val_TYPE :
    when {&v-rubl} then do:
      assign
        v-print-rubl = yes
      .
    end.
    when {&v-base} then do:
      assign
        v-print-rubl = no
      .
    end.
    otherwise do:
      message "Неизвестный тип валюты!" skip "Отчет формируется в базовой валюте" view-as alert-box information .
      assign
        v-print-rubl = no
      .
    end.
  end case.
  { gbl/working.i }
  { gbl/getcntxt.i get }
  /*{ gbl/curr-r-b.i v-curr-r-b }*/

  /*Поиск нач fact-order*/
  run day-begin-fact-order in this-procedure ( input x-Date-Start , output v-fact-order-start ).
  /*Поиск посл fact-order*/
  run day-begin-fact-order in this-procedure ( input ( x-Date-End + 1 ) , output v-fact-order-end ).

  run get-report-num in parparentproc (output g#report-num).

  { cmp/open-out.i stream out-stream " " }
  run fincl3xl-init in this-procedure .
  run fincl3xl-write-cell-data in this-procedure ( input {&fincl3xl-h_header}
                                                 , input substitute( "Форма №3 отчета взаиморасчета за период с &1 по &2"
                                                                   , x-Date-Start
                                                                   , X-Date-end
                                                                   )
                                                 ).
  empty temp-table tt-report.

  assign
    str1 = ""
    str2 = ""
    str3 = ""
    str4 = ""
    reportheader = ""
  .
  view stream out-stream frame BottomFrame .

  if p-rad = 1 then do: /* все контрагенты */
    { rep/r-fincl3.i buf_clients }
  end.
  else do: /* выборочно */
    { rep/r-fincl3.i g#post-f }
  end.
  run waitfram-show in this-procedure ( "Формирование отчета..." ).

  for each tt-report-head
  by tt-report-head.obj-name
  :
    assign
      v-counter = v-counter + 1
    .
    run print-header in this-procedure .
    run fincl3xl-sheet1-write-line-data in this-procedure ( input tt-report-head.obj-name
                                                          , input " "
                                                          , input " "
                                                          , input " "
                                                          , input " "
                                                          ).
    run fincl3xl-sheet1-write-line-format in this-procedure ( "Заголовок1" ).
    display stream out-stream
      sym1
      "Сальдо на начало" @ tt-report.op-name
      sym2
      sym3
      sym4
      v-saldo-start when v-saldo-start < 0  @ v-debet-sum
      sym5
      v-saldo-start when v-saldo-start >= 0 @ v-credit-sum
      sym6
    with frame fincl3.
    down stream out-stream with frame fincl3.
    run fincl3xl-sheet1-write-line-data in this-procedure ( input "Сальдо на начало":U
                                                   , input ""
                                                   , input ""
                                                   , input (if v-saldo-start < 0 then  string( v-saldo-start ) else " ")
                                                   , input (if v-saldo-start >= 0 then string( v-saldo-start ) else " ")
                                                   ).
/*    {&PutExcel}*/
/*      "Сальдо на начало"    {&tabulation}*/
/*      " "    {&tabulation}*/
/*      " "    {&tabulation}*/
/*      if v-saldo-start < 0 then  string( v-saldo-start ) else " "    {&tabulation}*/
/*      if v-saldo-start >= 0 then string( v-saldo-start ) else " "    {&tabulation}*/
/*    skip.*/

    for each tt-report
      where tt-report.obj-type = tt-report-head.obj-type
        and tt-report.obj-code = tt-report-head.obj-code
    by tt-report.op-date
    :
      assign
        v-debet-sum   = abs(tt-report.sum)
        v-credit-sum  = abs(tt-report.sum)
      .
      display stream out-stream
        sym1
        op-name(tt-report.op-type) @ tt-report.op-name
        sym2
        tt-report.op-date
        sym3
        tt-report.doc-code
        sym4
        v-debet-sum when tt-report.sum < 0
        sym5
        v-credit-sum when tt-report.sum >= 0
        sym6
      with frame fincl3.
      down stream out-stream with frame fincl3.
      run fincl3xl-sheet1-write-line-data in this-procedure ( input op-name(tt-report.op-type)
                                                    , input string(tt-report.op-date ,"99.99.9999")
                                                    , input tt-report.doc-code
                                                    , input (if tt-report.sum <  0 then  string( v-debet-sum ) else " ")
                                                    , input (if tt-report.sum >= 0 then  string( v-debet-sum ) else " ")
                                                    ).

/*      {&PutExcel}*/
/*        op-name(tt-report.op-type)                                  {&tabulation}*/
/*        tt-report.op-date format "99.99.9999"                       {&tabulation}*/
/*        tt-report.doc-code                                          {&tabulation}*/
/*        if tt-report.sum < 0 then  string( v-debet-sum ) else " "   {&tabulation}*/
/*        if tt-report.sum >= 0 then string( v-credit-sum ) else " "  {&tabulation}*/
/*      skip.*/
    end. /* for each tt-report */

    display stream out-stream
      sym1
      "Сальдо на конец" @ tt-report.op-name
      sym2
      sym3
      sym4
      v-saldo-end when v-saldo-end < 0  @ v-debet-sum
      sym5
      v-saldo-end when v-saldo-end >= 0 @ v-credit-sum
      sym6
    with frame fincl3.
    down stream out-stream with frame fincl3.
    put stream out-stream unformatted v-line format "X(96)" skip(2).
    run fincl3xl-sheet1-write-line-data in this-procedure ( input "Сальдо на конец":U
                                                   , input ""
                                                   , input ""
                                                   , input (if v-saldo-end <  0 then  string( v-saldo-end ) else " ")
                                                   , input (if v-saldo-end >= 0 then  string( v-saldo-end ) else " ")
                                                   ).

/*    {&PutExcel}*/
/*      "Сальдо на конец"    {&tabulation}*/
/*      " "    {&tabulation}*/
/*      " "    {&tabulation}*/
/*      if v-saldo-end < 0 then  string( v-saldo-end ) else " "    {&tabulation}*/
/*      if v-saldo-end >= 0 then string( v-saldo-end ) else " "    {&tabulation}*/
/*    skip(2).*/
  end. /* for each tt-report-head  */

  run waitfram-hide in this-procedure .
  hide stream out-stream frame BottomFrame.
  output stream out-stream close.
  run fincl3xl-close in this-procedure .
/*  {&CloseExcel}*/
  empty temp-table tt-report.
  empty temp-table tt-report-head.
  { gbl/stopwork.i }
  os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
  os-rename
    value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
    value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
  .

  define variable v-user-action   as character no-undo .
  define variable v-printed       as logical   no-undo .
  define variable DisabledOptions as integer   no-undo .
  define variable v-orient-page as character no-undo .
  run How-name in this-procedure ( input ReportPageHeight
                                 , input ReportPageWidth
                                 , output v-orient-page
                                 ) .
  if v-orient-page = "A4-lans":U then DisabledOptions = 8 .
                                 else DisabledOptions = 0 .
  run gbl/prnfilen.w
      ( input  ""
      , input  DisabledOptions
      , input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
      , input  ReportFontNum
      , output v-user-action
      , output v-printed
      ) .
  os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
end.

/* ============================================================================================== */
procedure print-header :

do
on error undo, return error return-value
:
  if line-counter( out-stream ) + 6 > page-size( out-stream ) then do:
    page stream out-stream .
  end.

  put stream out-stream unformatted
    substitute( "Взаиморасчеты по контрагенту &1 за период с &2 по &3"
              , tt-report-head.obj-name
              , x-Date-Start
              , X-Date-end
              ) skip(1)
      "------------------------------------------------------------------------------------------------":U skip
      ":          Операция            :    Дата  :  Номер д-та    :       Дт        :        Кт       :":U skip
      "------------------------------------------------------------------------------------------------":U
  skip.
/*  if v-counter <= 1 then do:*/
/*    find first sheetf*/
/*      where sheetf.sheet-num = 1*/
/*    no-error .*/
/*    if not available sheetf then do:*/
/*      create sheetf.*/
/*    end.*/
/*    assign*/
/*      reportname = substitute( "Взаиморасчеты по контрагенту &1 за период с &2 по &3"*/
/*                            , tt-report-head.obj-name*/
/*                            , x-Date-Start*/
/*                            , X-Date-end*/
/*                            )*/
/*      sheetf.sheet-num   = 1*/
/*      sheetf.Excel-Column-Lable =*/
/*      "Операция"    + {&comma-char} +*/
/*      "Дата"        + {&comma-char} +*/
/*      "Номер д-та"  + {&comma-char} +*/
/*      "Дт"          + {&comma-char} +*/
/*      "Кт"*/
/*      sheetf.sizes =*/
/*      "40"  + {&comma-char} +*/
/*      "20"  + {&comma-char} +*/
/*      "20"  + {&comma-char} +*/
/*      "20"  + {&comma-char} +*/
/*      "20"*/
/*      Sheetf.colformat = "1=@;2=@;3=@;4=@;5=@;"*/
/*    .*/
/*    run rep/extitle.p ( 1 ).*/

/*  end.*/
/*  else do:*/

/*    {&PutExcel}*/
/*      substitute( "Взаиморасчеты по контрагенту &1 за период с &2 по &3"*/
/*                            , tt-report-head.obj-name*/
/*                            , x-Date-Start*/
/*                            , X-Date-end*/
/*                            )   {&tabulation}*/
/*      "" {&tabulation}*/
/*      "" {&tabulation}*/
/*      "" {&tabulation}*/
/*      "" {&tabulation}*/
/*    skip(1)*/
/*      "Операция"   {&tabulation}*/
/*      "Дата"       {&tabulation}*/
/*      "Номер д-та" {&tabulation}*/
/*      "Дт"         {&tabulation}*/
/*      "Кт"         {&tabulation}*/
/*    skip.*/

/*  end.*/

end.

end procedure. /* print-header */

procedure calc-fin-pri :

define input  parameter p-cli-type like ub.clients.obj-type no-undo .
define input  parameter p-cli-code like ub.clients.obj-code no-undo .
define input  parameter p-host-code-obj like ub.clients.obj-code no-undo .

do
on error undo, return error return-value
:
    define buffer buf_fin-doc   for ub.fin-doc.

    for each buf_fin-doc no-lock
      where buf_fin-doc.host-code     = p-host-code-obj
        and buf_fin-doc.status_       = {&fin-fact}
        and buf_fin-doc.fact-order    >= v-fact-order-start
        and buf_fin-doc.fact-order    <  v-fact-order-end
        and buf_fin-doc.payer-type    = p-cli-type
        and buf_fin-doc.payer-code    = p-cli-code
    :
        create tt-report.
        assign
          tt-report.obj-type      = p-cli-type
          tt-report.obj-code      = p-cli-code
          tt-report.op-type       = {&op-cli-money-income}
          tt-report.op-date       = buf_fin-doc.fact-date
          tt-report.doc-code      = buf_fin-doc.prn-doc-code
          tt-report.sum           = if v-print-rubl then buf_fin-doc.sum-rubl
                                    else                 buf_fin-doc.sum-base
        .
    end.

end.

end procedure. /* calc-fin-pri */


procedure calc-talon-oborot :

define input  parameter p-cli-type      like ub.clients.obj-type no-undo .
define input  parameter p-cli-code      like ub.clients.obj-code no-undo .
define input  parameter p-host-code-obj like ub.clients.obj-code no-undo .

do
on error undo, return error return-value
:
  define buffer buf_wth-doc for ub.wth-doc.

  for each buf_wth-doc no-lock
      where buf_wth-doc.host-code =  p-host-code-obj
        and buf_wth-doc.cli-type  =  p-cli-type
        and buf_wth-doc.cli-code  =  p-cli-code
        and buf_wth-doc.fact-date >= x-date-start
        and buf_wth-doc.fact-date <= x-date-end
  :
    case buf_wth-doc.ext-doc-type :
      when {&WDEDT_Exp_ext} then do:
        create tt-report.
        assign
          tt-report.obj-type      = p-cli-type
          tt-report.obj-code      = p-cli-code
          tt-report.op-type       = {&op-talon-exp}
          tt-report.op-date       = buf_wth-doc.fact-date
          tt-report.doc-code      = buf_wth-doc.doc-code
          tt-report.sum           = - ( if v-print-rubl then buf_wth-doc.sum-gds-rubl
                                        else                 buf_wth-doc.sum-gds-base
                                      )
        .
      end.
      when {&WDEDT_Put_Cash} or when {&WDEDT_Put_Sale} then do:

      end.
      when {&WDEDT_Put_Cli} then do:
        create tt-report.
        assign
          tt-report.obj-type      = p-cli-type
          tt-report.obj-code      = p-cli-code
          tt-report.op-type       = {&op-talon-ret}
          tt-report.op-date       = buf_wth-doc.fact-date
          tt-report.doc-code      = buf_wth-doc.doc-code
          tt-report.sum           = if v-print-rubl then buf_wth-doc.sum-gds-rubl
                                    else                 buf_wth-doc.sum-gds-base
        .
      end.
    end case.
  end. /* for each buf_wth-doc no-lock  */

end.

end procedure. /* calc-talon-oborot */

procedure print-cli-report :

do
on error undo, return error return-value
:

  for each tt-report by tt-report.op-date :
    assign
      v-debet-sum   = abs(tt-report.sum)
      v-credit-sum  = abs(tt-report.sum)
    .
    display stream out-stream
      sym1
      op-name(tt-report.op-type) @ tt-report.op-name
      sym2
      tt-report.op-date
      sym3
      tt-report.doc-code
      sym4
      v-debet-sum when tt-report.sum < 0
      sym5
      v-credit-sum when tt-report.sum >= 0
      sym6
    with frame fincl3.
    down stream out-stream with frame fincl3.
  end.
end.

end procedure. /* print-cli-report */

function op-name returns character (p-op-type as integer):

  define variable v-op-name as character no-undo .

  case p-op-type :
    when {&op-cli-money-income} then do:
      assign
        v-op-name = "Приход денег от клиента":U
      .
    end.
    when {&op-talon-exp} then do:
      assign
        v-op-name = "Отпущены талоны":U
      .
    end.
    when {&op-talon-ret} then do:
      assign
        v-op-name = "Возврат талонов":U
      .
    end.
  end case .
  return v-op-name.
end .