block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-fincl1.p $
$Archive: rep/r-fincl1.p $

Форма №1 взаиморасчет с контрагентами

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
define variable vss-workfile    as character no-undo init "$Workfile: r-fincl1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-fincl1.p $":U .
define variable vss-description as character no-undo init "Форма №1 взаиморасчет с контрагентами".
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

define temp-table tt-report no-undo
    field obj-type        like ub.clients.obj-type
    field obj-code        like ub.clients.obj-code
    field obj-name        like ub.clients.obj-name
    field pay-sum         as decimal
    field talon-give-sum  as decimal
    field fuel-sell-sum   as decimal
index pi is primary unique obj-type obj-code
index p1 obj-name.

define stream out-stream.

define buffer buf_clients         for ub.clients.
define buffer buf_arh-wth-cli-tot for ub.arh-wth-cli-tot.

define variable g#report-num         as integer   no-undo .
define variable v-fact-order-start   as decimal   no-undo .
define variable v-fact-order-end     as decimal   no-undo .
define variable v-line               as character no-undo .
define variable v-print-rubl         as logical   no-undo .
define variable v-repfrm-str         as character no-undo .
define variable v-counter            as integer   no-undo .
define variable v-pay-sum-1          as decimal   no-undo .
define variable v-talon-give-sum-1   as decimal   no-undo .
define variable v-fuel-sell-sum-1    as decimal   no-undo .
define variable v-pay-sum-2          as decimal   no-undo .
define variable v-talon-give-sum-2   as decimal   no-undo .
define variable v-fuel-sell-sum-2    as decimal   no-undo .
define variable v-saldo-1            as decimal   no-undo .
define variable v-saldo-2            as decimal   no-undo .
define variable v-curr-r-b           as integer   no-undo .

{ rep/r-fincl0.i }
{ gbl/r-b-curr.i v-cntxt-host-code-obj v-curr-r-b }


define frame fincl1
        sym1                      column-label ":!:"                            format "X(1)"              space(0)
        tt-report.obj-name        column-label "Клиент ! "                      format "X(30)"             space(0)
        sym2                      column-label ":!:"                            format "X(1)"              space(0)
        tt-report.pay-sum         column-label "Оплачено,!{&abbr_rub}"          format "->,>>>,>>>,>>9.99" space(0)
        sym3                      column-label ":!:"                            format "X(1)"              space(0)
        tt-report.talon-give-sum  column-label "Выдано талонов,!{&abbr_rub}"    format "->,>>>,>>>,>>9.99" space(0)
        sym4                      column-label ":!:"                            format "X(1)"              space(0)
        tt-report.fuel-sell-sum   column-label "Отпущено топлива,!{&abbr_rub}"  format "->,>>>,>>>,>>9.99" space(0)
        sym5                      column-label ":!:"                            format "X(1)"              space(0)
header
  v-line format "X(86)" at 1 skip
with width {&A4_CW} down stream-io.

form header
        v-line format "X(87)" at 1 SKIP
        "Продолжение - на следующей странице" at 1 SKIP
with frame BottomFrame width {&A4_CW} PAGE-BOTTOM NO-LABELS NO-BOX .

do on error undo, return error return-value :
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
  assign
    v-line = fill( "-" , 300 )
    v-repfrm-str = "Расчет по архиву..."
    v-counter    = 0

  .

  if p-rad = 1 then do: /* все контрагенты */
    { rep/r-fincl1.i ub.clients }
  end.
  else do: /* выборочно */
    { rep/r-fincl1.i g#post-f }
  end.
  run waitfram-show in this-procedure ("Печать отчета...") .
  run print-header in this-procedure .
  run print-report in this-procedure .

  {&CloseExcel}
  hide stream out-stream frame BottomFrame.
  output stream out-stream close.
  empty temp-table tt-report.
  run waitfram-hide in this-procedure .
  { gbl/stopwork.i }
  define variable v-user-action   as character no-undo .
  define variable v-printed       as logical   no-undo .
  define variable DisabledOptions as integer   no-undo .
  define variable v-orient-page as character no-undo .
  run How-name in this-procedure (
      input ReportPageHeight,
      input ReportPageWidth,
      output v-orient-page )
      .
  if v-orient-page = "A4-lans":U then DisabledOptions = 8 .
                                else DisabledOptions = 0 .
  run gbl/prnfilen.w
      (input  ""
      ,input  DisabledOptions
      ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
      ,input  ReportFontNum
      ,output v-user-action
      ,output v-printed
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
    reportheader = ""
    reportname = substitute( "Взаиморасчеты по контрагентам за период с &1 по &2", x-Date-Start , X-Date-end )
    sheetf.Excel-Column-Lable =
    "Клиент"                      + {&comma-char} +
    "Оплачено {&abbr_rub}."       + {&comma-char} +
    "Выдано талонов {&abbr_rub}." + {&comma-char} +
    "Отпущено топлива {&abbr_rub}."
    sheetf.sizes =
    "40"  + {&comma-char} +
    "20"  + {&comma-char} +
    "20"  + {&comma-char} +
    "20"
    Sheetf.colformat = "1=@;2=0,00;3=0,00;4=0,00;"
  .
  run rep/extitle.p (1).

end.

end procedure. /* print-header */

/* ============================================================================================== */
procedure print-report :

do
on error undo, return error return-value
:
  define variable v-pay-sum-tot         as decimal   no-undo .
  define variable v-talon-give-sum-tot  as decimal   no-undo .
  define variable v-fuel-sell-sum-tot   as decimal   no-undo .

  for each tt-report by tt-report.obj-name
  :
    assign
      v-pay-sum-tot         = v-pay-sum-tot        + tt-report.pay-sum
      v-talon-give-sum-tot  = v-talon-give-sum-tot + tt-report.talon-give-sum
      v-fuel-sell-sum-tot   = v-fuel-sell-sum-tot  + tt-report.fuel-sell-sum
    .
    display stream out-stream
      tt-report.obj-name
      tt-report.pay-sum
      tt-report.talon-give-sum
      tt-report.fuel-sell-sum
      sym1
      sym2
      sym3
      sym4
      sym5
    with frame fincl1.
    down stream out-stream with frame fincl1.
    {&PutExcel}
      tt-report.obj-name        {&tabulation}
      tt-report.pay-sum         {&tabulation}
      tt-report.talon-give-sum  {&tabulation}
      tt-report.fuel-sell-sum   {&tabulation}
    skip.

  end. /* for each tt-report by tt-report.obj-name */
  put stream out-stream unformatted v-line format "X(86)" skip.
  display stream out-stream
    "Итого"               @ tt-report.obj-name
    v-pay-sum-tot         @ tt-report.pay-sum
    v-talon-give-sum-tot  @ tt-report.talon-give-sum
    v-fuel-sell-sum-tot   @ tt-report.fuel-sell-sum
    sym1
    sym2
    sym3
    sym4
    sym5
  with frame fincl1.
  put stream out-stream unformatted v-line format "X(86)" skip.
  {&PutExcel}
    "Итого"              {&tabulation}
    v-pay-sum-tot        {&tabulation}
    v-talon-give-sum-tot {&tabulation}
    v-fuel-sell-sum-tot  {&tabulation}
  skip.
end.

end procedure. /* print-report */