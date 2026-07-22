block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-fincl2.p $
$Archive: rep/r-fincl2.p $

Форма №2 взаиморасчет с контрагентами

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
define variable vss-workfile    as character no-undo init "$Workfile: r-fincl2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-fincl2.p $":U .
define variable vss-description as character no-undo init "Форма №2 взаиморасчет с контрагентами".
{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/r-page1.i      }
{ cmp/r-pril.i       }
{ rep/r-sym.i        }
{ trg/factord.i      }
{ gbl/waitfram.i     }
{ rep/lkp-font.i     }
{ gbl/getcntxt.i def }


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

define temp-table tt-report-pay-sum no-undo
    field obj-type              like ub.clients.obj-type
    field obj-code              like ub.clients.obj-code
    field obj-name              like ub.clients.obj-name
    field pay-sum               as decimal
index pi is primary unique obj-type obj-code
index p1 obj-name.

define temp-table tt-report no-undo
    field obj-type              like ub.clients.obj-type
    field obj-code              like ub.clients.obj-code
    field talon-name            as character
    field wth-code              like ub.wth-gds.wth-code
    field par-code              like ub.wth-par.par-code
    field par-val               like ub.wth-par.par-val
    field gds-code              like ub.wth-gds.gds-code
    field talon-give-money-sum  as decimal
    field talon-give-units-sum  as decimal
    field fuel-sell-money-sum   as decimal
    field fuel-sell-units-sum   as decimal
index pi is primary unique obj-type obj-code gds-code wth-code par-code
index p1 talon-name.


define stream out-stream.

&scop wth-sum-type "":U
&scop wealth-serial 1


define buffer buf_clients     for ub.clients.
define buffer buf_goods       for ub.goods.
define buffer buf_wth-par     for ub.wth-par.
define buffer buf_wth-gds     for ub.wth-gds.
define buffer buf_wth-ser     for ub.wth-ser.
define buffer buf_wealth      for ub.wealth.
define buffer buf_arh-wth-cli for ub.arh-wth-cli.


define variable g#report-num             as integer   no-undo .
define variable v-fact-order-start       as decimal   no-undo .
define variable v-fact-order-end         as decimal   no-undo .
define variable v-line                   as character no-undo .
define variable v-print-rubl             as logical   no-undo .
define variable v-repfrm-str             as character no-undo .
define variable v-counter                as integer   no-undo .
define variable v-pay-sum-1              as decimal   no-undo .
define variable v-talon-give-money-sum-1 as decimal   no-undo .
define variable v-fuel-sell-money-sum-1  as decimal   no-undo .
define variable v-talon-give-units-sum-1 as decimal   no-undo .
define variable v-fuel-sell-units-sum-1  as decimal   no-undo .
define variable v-pay-sum-2              as decimal   no-undo .
define variable v-talon-give-money-sum-2 as decimal   no-undo .
define variable v-fuel-sell-money-sum-2  as decimal   no-undo .
define variable v-talon-give-units-sum-2 as decimal   no-undo .
define variable v-fuel-sell-units-sum-2  as decimal   no-undo .
define variable v-saldo-1                as decimal   no-undo .
define variable v-saldo-2                as decimal   no-undo .
define variable v-curr-r-b           as integer   no-undo .

{ rep/r-fincl0.i }
{ gbl/r-b-curr.i v-cntxt-host-code-obj v-curr-r-b }

&scop col-fmtl-1 "X(30)":U
&scop col-fmtl-2 "->>>,>>>,>>9.99":U
&scop col-fmtl-3 "X(20)"
&scop col-fmtl-4 "->>>,>>9.99":U
&scop col-fmtl-5 "->>>,>>>,>>9.99":U
&scop col-fmtl-6 "->>>,>>9.99":U
&scop col-fmtl-7 "->>>,>>>,>>9.99":U
&scop frame-width 125

define frame fincl2
  sym1                            no-label format "X(1)"                          space(0)
  tt-report-pay-sum.obj-name      no-label format {&col-fmtl-1}                   space(0)
  sym2                            no-label format "X(1)"                          space(0)
  tt-report-pay-sum.pay-sum       no-label format {&col-fmtl-2}                   space(0)
  sym3                            no-label format "X(1)"                          space(0)
  tt-report.talon-name            no-label format {&col-fmtl-3}                   space(0)
  sym4                            no-label format "X(1)"                          space(0)
  tt-report.talon-give-units-sum  no-label format {&col-fmtl-4}                   space(0)
  sym5                            no-label format "X(1)"                          space(0)
  tt-report.talon-give-money-sum  no-label format {&col-fmtl-5}                   space(0)
  sym6                            no-label format "X(1)"                          space(0)
  tt-report.fuel-sell-units-sum   no-label format {&col-fmtl-6}                   space(0)
  sym7                            no-label format "X(1)"                          space(0)
  tt-report.fuel-sell-money-sum   no-label format {&col-fmtl-7}                   space(0)
  sym8                            no-label format "X(1)"                          space(0)
header
    "-----------------------------------------------------------------------------------------------------------------------------":U skip
    ":            Клиент            : Оплачено, {&abbr_rub} :                     Выдано талонов             :Отпущено топлива по талонам:":U skip
    ":                              :               :--------------------:-----------:---------------:-----------:---------------:":U skip
    ":                              :               :        Талон       :     л     :       {&abbr_rub}.    :     л     :       {&abbr_rub}.    :":U skip
with width {&frame-width} down stream-io no-label no-box.

form header
        v-line format "X({&frame-width})" at 1 SKIP
        "Продолжение - на следующей странице" at 1 SKIP
with frame BottomFrame width {&A4_LS} PAGE-BOTTOM NO-LABELS NO-BOX .


do on error undo, return error return-value :
  assign
    v-line = fill( "-" , 300 )
    v-repfrm-str = "Расчет по архиву..."
    v-counter    = 0
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

  /*Поиск нач fact-order*/
  run day-begin-fact-order in this-procedure ( input x-Date-Start , output v-fact-order-start ).
  /*Поиск посл fact-order*/
  run day-begin-fact-order in this-procedure ( input ( x-Date-End + 1 ) , output v-fact-order-end ).

  run get-report-num in parparentproc (output g#report-num).
  { cmp/open-out.i stream out-stream " " }
  view stream out-stream frame BottomFrame .

  if p-rad = 1 then do: /* все контрагенты */
    { rep/r-fincl2.i ub.clients }
  end.
  else do: /* выборочно */
    { rep/r-fincl2.i g#post-f }
  end.
  run waitfram-show in this-procedure ("Печать отчета...") .
  run print-header in this-procedure .
  run print-report in this-procedure .
  run waitfram-hide in this-procedure .
  hide stream out-stream frame BottomFrame.
  output stream out-stream close.
  {&CloseExcel}
  empty temp-table tt-report.
  empty temp-table tt-report-pay-sum.
  { gbl/stopwork.i }

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

end.

/* ============================================================================================== */
procedure print-header :

do
on error undo, return error return-value
:
  put stream out-stream unformatted
    substitute( "Взаиморасчеты по контрагентам за период с &1 по &2", x-Date-Start , X-Date-end ) skip
  .
  assign
    str1 = ""
    str2 = ""
    str3 = ""
    str4 = ""
/*    reportheader = ""*/
    reportname = substitute( "Взаиморасчеты по контрагентам за период с &1 по &2", x-Date-Start , X-Date-end )
    sheetf.sheet-num   = 1
    sheetf.MergeCellsH = "3:5,6:7"
    sheetf.MergeCellsV = "1=1:2/2=1:2"
    sheetf.Excel-Column-Lable =
      "Клиент"          + {&comma-char} +
      "Оплачено {&abbr_rub}"   + {&comma-char} +
      "Выдано талонов"  + {&comma-char} +
                          {&comma-char} +
                          {&comma-char} +
      "Отпущено топлива по талонам" + {&comma-char} +
      {&comma-char} +
      {&new-line}   +
      {&comma-char} +
      {&comma-char} +
      "Талон"           + {&comma-char} +
      "л"               + {&comma-char} +
      "{&abbr_rub}"             + {&comma-char} +
      "л"               + {&comma-char} +
      "{&abbr_rub}"
    sheetf.sizes =
      "30"  + {&comma-char} +
      "15"  + {&comma-char} +
      "20"  + {&comma-char} +
      "10"  + {&comma-char} +
      "15"  + {&comma-char} +
      "15"  + {&comma-char} +
      "20"
    Sheetf.colformat = "1=@;2=@;3=@;4=@;5=@;6=@;7=@"
  .
  run rep/extitle.p (1).
end.

end procedure. /* print-header */

procedure print-report :

do
on error undo, return error return-value
:

  define variable v-is-first-print                as logical   no-undo .
  define variable v-subtotal-talon-give-money-sum as decimal   no-undo .
  define variable v-subtotal-fuel-sell-money-sum  as decimal   no-undo .
  define variable v-total-talon-give-money-sum    as decimal   no-undo .
  define variable v-total-fuel-sell-money-sum     as decimal   no-undo .

  for each tt-report-pay-sum
    by tt-report-pay-sum.obj-name
  :
    if tt-report-pay-sum.pay-sum = 0 then do:
      find first tt-report
        where tt-report.obj-type = tt-report-pay-sum.obj-type
          and tt-report.obj-code = tt-report-pay-sum.obj-code
      no-error .
      if not available tt-report then next.
    end.

    assign
      v-is-first-print                = yes
    .

    display stream out-stream
        tt-report-pay-sum.obj-name
        tt-report-pay-sum.pay-sum
        sym1
        sym2
        sym3
        sym4
        sym5
        sym6
        sym7
        sym8
    with frame fincl2.
    for each tt-report
      where tt-report.obj-type = tt-report-pay-sum.obj-type
        and tt-report.obj-code = tt-report-pay-sum.obj-code
    by tt-report.talon-name
    :
      display stream out-stream
        tt-report.talon-name
        tt-report.talon-give-units-sum
        tt-report.talon-give-money-sum
        tt-report.fuel-sell-units-sum
        tt-report.fuel-sell-money-sum
        sym1
        sym2
        sym3
        sym4
        sym5
        sym6
        sym7
        sym8
      with frame fincl2.
      down stream out-stream with frame fincl2.
      {&PutExcel}
        ( if v-is-first-print then tt-report-pay-sum.obj-name else " ")           {&tabulation}
        ( if v-is-first-print then string(tt-report-pay-sum.pay-sum)  else " " )  {&tabulation}
        tt-report.talon-name                                                      {&tabulation}
        tt-report.talon-give-units-sum                                            {&tabulation}
        tt-report.talon-give-money-sum                                            {&tabulation}
        tt-report.fuel-sell-units-sum                                             {&tabulation}
        tt-report.fuel-sell-money-sum                                             {&tabulation}
      skip.
      assign
        v-counter                       = v-counter + 1
        v-is-first-print                = no
        v-subtotal-talon-give-money-sum = v-subtotal-talon-give-money-sum + tt-report.talon-give-money-sum
        v-subtotal-fuel-sell-money-sum  = v-subtotal-fuel-sell-money-sum  + tt-report.fuel-sell-money-sum
      .
    end. /* for each tt-report */
    put stream out-stream unformatted v-line format "X({&frame-width})" skip.
    display stream out-stream
      "Итого:"                        @ tt-report-pay-sum.pay-sum
      v-subtotal-talon-give-money-sum @ tt-report.talon-give-money-sum
      v-subtotal-fuel-sell-money-sum  @ tt-report.fuel-sell-money-sum
      sym1
      sym2
      sym3
      sym4
      sym5
      sym6
      sym7
      sym8
    with frame fincl2.
    down stream out-stream with frame fincl2.
    put stream out-stream unformatted v-line format "X({&frame-width})" skip.
    {&PutExcel}
      " "                             {&tabulation}
      "Итого"                         {&tabulation}
      " "                             {&tabulation}
      " "                             {&tabulation}
      v-subtotal-talon-give-money-sum {&tabulation}
      " "                             {&tabulation}
      v-subtotal-fuel-sell-money-sum  {&tabulation}
    skip.
    assign
      v-total-talon-give-money-sum    = v-total-talon-give-money-sum + v-subtotal-talon-give-money-sum
      v-total-fuel-sell-money-sum     = v-total-fuel-sell-money-sum  + v-subtotal-fuel-sell-money-sum
      v-subtotal-talon-give-money-sum = 0
      v-subtotal-fuel-sell-money-sum  = 0
    .
  end. /* for each tt-report-pay-sum */
  display stream out-stream
    "Всего"                      @ tt-report-pay-sum.pay-sum
    v-total-talon-give-money-sum @ tt-report.talon-give-money-sum
    v-total-fuel-sell-money-sum  @ tt-report.fuel-sell-money-sum
    sym1
    sym2
    sym3
    sym4
    sym5
    sym6
    sym7
    sym8
  with frame fincl2.
  put stream out-stream unformatted v-line format "X({&frame-width})" skip.
  {&PutExcel}
    " "                          {&tabulation}
    "Всего"                      {&tabulation}
    " "                          {&tabulation}
    " "                          {&tabulation}
    v-total-talon-give-money-sum {&tabulation}
    " "                          {&tabulation}
    v-total-fuel-sell-money-sum  {&tabulation}
  skip.
end.

end procedure. /* print-report */