block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-rnpazs.p $
$Archive: rep/r-rnpazs.p $

Данные о реализации НП на АЗС за период (ТамбовНП)


Автор: Самков Сергей Васильевич
Дата создания: 06/01/12
Author: Samkov Sergey
Creation date: 06/01/12

Input:

Output:

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-rnpazs.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-rnpazs.p $":U .
define variable vss-description as character no-undo init "Данные о реализации НП на АЗС за период (ТамбовНП)".
{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ cmp/r-page1.i      }
{ cmp/r-pril.i       }
{ rep/r-sym.i        }
{ gbl/waitfram.i     }
{ rep/p-fmt.i        }
{ gbl/paramls.i      }
{ rep/repfrm.i def   }
{ gbl/cur-time.i     }

{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/trdcalib.i }
{ cmp/library.i  }
{ rep/r-pychk0.i defalgo }

define temp-table tt-petrol no-undo
  field host-code like ub.sysconf.host-code
  field host-name like ub.clients.obj-name
  field reg-code  like ub.clients.reg-code
  field reg-name  like ub.regions.reg-name
  field obj-type  like ub.clients.obj-type
  field obj-code  like ub.clients.obj-code
  field obj-name  like ub.clients.obj-name
  field gds-code  like ub.goods.gds-code
  field gds-name  like ub.goods.gds-name
  field chk-date  like ub.chk-doc.shift-date
  field gds-qnty  like ub.chk-gds-pay.eff-doc-qnty init 0
  field tot-sum   like ub.chk-gds-pay.tot-r-b
  field gds-price like ub.chk-gds-pay.tot-r-b
  field pay-code  like ub.chk-gds-pay.pay-code
  field pay-name  like ub.cash-pay.obj-name
  index xpk_petrol is unique primary
    obj-type
    obj-code
    gds-code
    chk-date
    pay-code
  index print_petrol
    chk-date
    host-name
    gds-name
    pay-code
.

define variable v-space        as character  no-undo.
define variable v-single-line  as character    no-undo.
define variable v-print-rubl   as logical no-undo.
define variable v-flag         as logical no-undo init "false".
define variable v-count        as integer no-undo .
define variable v-log-file     as character no-undo.
define variable v-has-errors   as logical no-undo init false.

define buffer buf_clients   for ub.clients.
define buffer buf_goods     for ub.goods.
define buffer buf_sys-ctrl  for ub.sys-ctrl.
define buffer buf_chk-doc   for ub.chk-doc.
define buffer buf_bar-code  for ub.bar-code.
define buffer buf_cash-pay  for ub.cash-pay.
define buffer buf_inkas     for ub.inkas.
define buffer buf_chk-gds-pay for ub.chk-gds-pay.
define buffer buf_regions   for ub.regions.

do
on error undo, return error
:
/*---------------------------------*/
define stream out-stream.
define stream log-stream.
define variable parparentproc  as handle  no-undo .
define variable g#report-num   as integer no-undo .
assign
  parparentproc = my-handle
.
run get-report-num in my-handle (output g#report-num).
v-log-file = session:TEMP-DIRECTORY + "r-rnpazs-errors.txt".

{ gbl/getcntxt.i def }
{ str/writelog.i def v-log-file }
{ rep/rnpazsxl.i     }

/*---------------------------------------*/

/*print*/

/*-------------------------------*/
 /* выбираем валюту */
  assign
    v-print-rubl = yes
  .

  if session:set-wait-state("compiler") then.

  run incom in this-procedure.

  if v-has-errors then do:
      message
        "При создании отчета произошли ошибки, возможно данные в отчете будут не точными. Список ошибок находится в файле"
        skip
        v-log-file view-as alert-box.
  end.
  else
    os-delete value(v-log-file).

  if not can-find( first tt-petrol ) then do:
    if session:set-wait-state("") then.
    message "Не было никакой выручки в течение заданного Вами периода времени." view-as alert-box information .
    return.
  end.

  v-single-line = fill("-", 198).
 { cmp/open-out.i stream out-stream " " }

      define frame Pri_Vnesh
        sym1                  column-label ":!:!:"  format "X(1)" space(0)
        tt-petrol.host-name   column-label " !НПО! "  format "X(30)" space(0)
        sym2                  column-label ":!:!:" format "X(1)" space(0)
        tt-petrol.reg-name    column-label " !Регион АЗК! " format "X(30)" space(0)
        sym3                  column-label ":!:!:"  format "X(1)" space(0)
        tt-petrol.obj-name    column-label " !АЗК! "  format "X(15)" space(0)
        sym4                  column-label ":!:!:" format "X(1)" space(0)
        tt-petrol.gds-name    column-label " !Вид!нефтепродукта" format "X(15)" space(0)
        sym5                  column-label ":!:!:" format "X(1)" space(0)
        v-space               column-label "Код!нефтепродукта!КМС (если есть)" format "X(15)" space(0)
        sym6                  column-label ":!:!:" format "X(1)" space(0)
        tt-petrol.chk-date    column-label " !Дата!реализации" format "99/99/9999" space(0)
        sym7                  column-label ":!:!:" format "X(1)" space(0)
        tt-petrol.gds-qnty    column-label "Объем!продаж!л" format "->>,>>>,>>9.99" space(0)
        sym8                  column-label ":!:!:" format "X(1)" space(0)
        tt-petrol.gds-price   column-label " !Цена!р/л" format "->>>,>>9.99" space(0)
        sym9                  column-label ":!:!:" format "X(1)" space(0)
        tt-petrol.tot-sum     column-label "Выручка от продаж!с НДС!тыс. руб " format "->>,>>>,>>9.99" space(0)
        sym10                 column-label ":!:!:" format "X(1)" space(0)
        tt-petrol.pay-name    column-label "Тип цены (тип карты,!тип скидки, безнал,!нал и т.п.)" format "X(30)" space(0)
        sym11                 column-label ":!:!:" format "X(1)" space(0)
        header
        cur-time-print() at 5 format "X(35)" skip
        v-single-line format "X(198)" at 1
        with width {&DOS_CW} down stream-io use-text .

  FORM HEADER
    string( "Страница " + string( PAGE-NUMBER( out-stream ), ">>9" ) ) at 160 format "X(13)" skip
    with FRAME TopFrame width {&DOS_CW} PAGE-TOP use-text stream-io NO-LABELS no-box.
  VIEW stream out-stream FRAME TopFrame .

  FORM HEADER
  "Продолжение - на следующей странице" AT 10 SKIP
  with FRAME CliBottomFrame width {&DOS_CW} PAGE-BOTTOM use-text stream-io NO-LABELS no-box.
  VIEW stream out-stream FRAME CliBottomFrame .

  run rnpazsxl-init in this-procedure .

  run pr-Header in this-procedure.

  run print-lines.

  hide stream out-stream FRAME TopFrame .
  hide stream out-stream frame CliBottomFrame.
  run rnpazsxl-close in this-procedure .
  output stream out-stream close.
  {&CloseExcel}

  if session:set-wait-state("") then.

  os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
  os-rename
    value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
    value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
  .
  define variable v-user-action   as character no-undo .
  define variable v-printed       as logical   no-undo .
  define variable DisabledOptions as integer   no-undo .
  define variable v-orient-page as character no-undo .
    run gbl/prnfilen.w
      ( input  ""
      , input  8 /*DisabledOptions*/
      , input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
      , input  ReportFontNum
      , output v-user-action
      , output v-printed
      ) .

  os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
end.

/*==========================================================================*/
procedure pr-Header :
define variable v-obj-list as character no-undo.
do
on error undo, return error
:
  put stream  out-stream unformatted
    space (50) "Данные о реализации НП на АЗС за период (ТамбовНП)" at 50 format "X(50)" skip
    space (65) "ЗА ПЕРИОД с " string(x-Date-Start,"99/99/9999") " по " string(x-Date-End,"99/99/9999") SKIP.
  for each obj-list no-lock
  :
    put stream  out-stream
      space (65) obj-list.obj-name skip.
    v-obj-list = v-obj-list + ( if v-obj-list = '' then '' else ', ') + obj-list.obj-name.
  end.
  if x-TOG-Shift = false then do:
    put stream  out-stream
      space (65) "Порядок смен - без смен " skip.
    run rnpazsxl-write-cell-data in this-procedure ( input {&rnpazsxl-h_num}   , input "Порядок смен - без смен " ).
  end.
  else do:
    put stream  out-stream
    space (65) "Порядок смен с "X-Shift-Start " по " X-Shift-End skip.
    run rnpazsxl-write-cell-data in this-procedure ( input {&rnpazsxl-h_num}   , input substitute("Порядок смен с &1  по  &2", X-Shift-Start, X-Shift-End  ) ).
  end.
  run rnpazsxl-write-cell-data in this-procedure ( input {&rnpazsxl-h_docname} , input "Данные о реализации НП на АЗС за период (ТамбовНП)" ).
  run rnpazsxl-write-cell-data in this-procedure ( input {&rnpazsxl-h_date}  , input substitute("ЗА ПЕРИОД с  &1  по &2", string(x-Date-Start, "99/99/9999"), string(x-Date-End, "99/99/9999"))).
  run rnpazsxl-write-cell-data in this-procedure ( input {&rnpazsxl-h_obj}   , input substitute("&1", v-obj-list  ) ).
  run rnpazsxl-write-cell-data in this-procedure ( input {&rnpazsxl-h_printdate}, input cur-time-print() ).

end. /* do on error */
end procedure. /* Header */

procedure incom :

do
on error undo, return error
:
  for each ub.units no-lock
    where lookup( {&petrolium}, ub.units.type) > 0
    ,each buf_goods no-lock
      where buf_goods.unit-base = ub.units.unit-name
      ,first buf_bar-code no-lock where buf_bar-code.gds-code = buf_goods.gds-code and buf_bar-code.cr-db-num = ?
  :
     
    for each obj-list  no-lock:
      run rep/rpychk0.p ( input "r-shftc2"
                         ,input obj-list.obj-type
                         ,input obj-list.obj-code
                         ,input ? /*p-date-from*/
                         ,input ? /*p-date-to*/
                         ,input X-date-start /*p-shift-date-from*/
                         ,input X-date-end /*p-shift-date-to*/
                         ,input 1 /*p-shift-num-start*/
                         ,input 99 /*p-shift-num-end*/
                         ,input ? /*p-inkas-code*/
                        ) no-error.
      if error-status:error then do:
        v-has-errors = true.
        run writelog(v-log-file, 0, return-value).
      end.

      _chk-inkas:
      for each buf_inkas no-lock
        where buf_inkas.obj-type   = obj-list.obj-type
          and buf_inkas.obj-code   = obj-list.obj-code
          and buf_inkas.status_    = {&fact}
          and buf_inkas.shift-date >= X-date-start
          and buf_inkas.shift-date <= X-date-end
      :
        if x-TOG-Shift then do:
          if buf_inkas.shift-date = X-date-start  and buf_inkas.shift-num < X-shift-Start  then next _chk-inkas.
          if buf_inkas.shift-date = X-date-end and buf_inkas.shift-num > X-shift-End then next _chk-inkas.
        end.
                
        assign
          v-count = v-count + 1
        .
        
        _chk-doc:
        for each buf_chk-doc no-lock
          where buf_chk-doc.obj-type    = buf_inkas.obj-type
            and buf_chk-doc.obj-code    = buf_inkas.obj-code
            and buf_chk-doc.out-code    = buf_inkas.inkas-code
        :
                                         
          if lookup(string(buf_chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc.        
        
          for each buf_chk-gds-pay no-lock
             where buf_chk-gds-pay.doc-code = buf_chk-doc.doc-code
               and buf_chk-gds-pay.algo-num = {&current-algo-1}
               and buf_chk-gds-pay.b-code   = buf_bar-code.b-code
             ,first buf_cash-pay no-lock
               where buf_cash-pay.cdpay-code = buf_chk-gds-pay.pay-code
                 and buf_cash-pay.curr-code = buf_chk-gds-pay.curr-code
          :
                        
            run add-record( input buf_inkas.host-code
                          , input buf_inkas.obj-type
                          , input buf_inkas.obj-code
                          , input buf_goods.gds-code
                          , input buf_goods.gds-name
                          , input buf_inkas.shift-date
                          , input buf_chk-gds-pay.eff-doc-qnty
                          , input buf_chk-gds-pay.tot-r-b
                          , input buf_chk-gds-pay.pay-code
                          , input buf_cash-pay.obj-name
                          ).
          end.
        end.
      end.
    end.
  end.
end.

run fill-fields.

end procedure.

PROCEDURE add-record :

define input  parameter p-host-code like ub.sysconf.host-code.
define input  parameter p-obj-type  like ub.clients.obj-type.
define input  parameter p-obj-code  like ub.clients.obj-code.
define input  parameter p-gds-code  like ub.goods.gds-code.
define input  parameter p-gds-name  like ub.goods.gds-name.
define input  parameter p-chk-date  like ub.chk-doc.shift-date.
define input  parameter p-gds-qnty  like ub.chk-gds-pay.eff-doc-qnty.
define input  parameter p-tot-sum   like ub.chk-gds-pay.tot-r-b.
define input  parameter p-pay-code  like ub.chk-gds-pay.pay-code.
define input  parameter p-pay-name  like ub.cash-pay.obj-name.

find first tt-petrol
  where tt-petrol.obj-type  = p-obj-type
    and tt-petrol.obj-code  = p-obj-code
    and tt-petrol.gds-code  = p-gds-code
    and tt-petrol.chk-date  = p-chk-date
    and tt-petrol.pay-code  = p-pay-code
  no-error.
if not avail tt-petrol then do:
  create tt-petrol.
  assign
    tt-petrol.obj-type  = p-obj-type
    tt-petrol.obj-code  = p-obj-code
    tt-petrol.gds-code  = p-gds-code
    tt-petrol.chk-date  = p-chk-date
    tt-petrol.pay-code  = p-pay-code
    tt-petrol.host-code = p-host-code
    tt-petrol.gds-name  = p-gds-name
    tt-petrol.pay-name  = p-pay-name
  .
end.
assign
  tt-petrol.gds-qnty  = tt-petrol.gds-qnty + p-gds-qnty when p-gds-qnty <> ?
  tt-petrol.tot-sum   = tt-petrol.tot-sum  + p-tot-sum when p-tot-sum <> ?
  tt-petrol.gds-price = tt-petrol.tot-sum /* / tt-petrol.gds-qnty when tt-petrol.gds-qnty <> 0 and tt-petrol.gds-qnty <> ?*/
.

END PROCEDURE.


PROCEDURE fill-fields :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable v-firm   as character no-undo.
define variable v-region as character no-undo.

for each tt-petrol
break by tt-petrol.host-code
:
  if first-of( tt-petrol.host-code ) then do:
    find first buf_clients no-lock
      where buf_clients.obj-type = {&cmp}
        and buf_clients.obj-code = tt-petrol.host-code
      no-error.
    if avail buf_clients then do:
      v-firm = buf_clients.obj-name.
      find first buf_regions no-lock
        where buf_regions.reg-code = buf_clients.reg-code
        no-error.
      if avail buf_regions then do:
        v-region = buf_regions.reg-name.
      end.
      else do:
        v-region = ''.
      end.
    end.
    else do:
      assign
        v-firm = ''
        v-region = ''
      .
    end.
  end.
  assign
    tt-petrol.host-name = v-firm
    tt-petrol.reg-name  = v-region
  .
end.

for each tt-petrol
break by tt-petrol.obj-type
      by tt-petrol.obj-code
:
  if first-of( tt-petrol.obj-code ) then do:
    find first buf_clients no-lock
      where buf_clients.obj-type = tt-petrol.obj-type
        and buf_clients.obj-code = tt-petrol.obj-code
      no-error.
    if avail buf_clients then do:
      v-firm = buf_clients.obj-name.
    end.
    else do:
      v-firm = "".
    end.
  end.
  tt-petrol.obj-name = v-firm.
end.

END PROCEDURE.

PROCEDURE print-lines :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
for each tt-petrol
by tt-petrol.chk-date
by tt-petrol.host-name
by tt-petrol.gds-name
by tt-petrol.pay-code
:
  tt-petrol.gds-price = tt-petrol.gds-price / tt-petrol.gds-qnty.
  if (tt-petrol.gds-price = ?) then tt-petrol.gds-price = 0.

  display stream out-stream
  sym1  tt-petrol.host-name sym2 tt-petrol.reg-name sym3 tt-petrol.obj-name sym4 tt-petrol.gds-name sym5 v-space sym6
  tt-petrol.chk-date sym7 tt-petrol.gds-price sym8 tt-petrol.gds-qnty sym9  ( tt-petrol.tot-sum / 1000 ) @ tt-petrol.tot-sum sym10  tt-petrol.pay-name sym11
  with frame Pri_Vnesh .
  DOWN STREAM out-stream 1 WITH FRAME Pri_Vnesh.

  run rnpazsxl-sheet1-write-line-data ( input   tt-petrol.host-name
                                      , input   tt-petrol.reg-name
                                      , input   tt-petrol.obj-name
                                      , input   tt-petrol.gds-name
                                      , input   string(tt-petrol.chk-date, "99.99.9999")
                                      , input   string(tt-petrol.gds-qnty, "->>,>>>,>>9.99")
                                      , input   string(tt-petrol.gds-price, "->>,>>>,>>9.99")
                                      , input   string(tt-petrol.tot-sum / 1000, "->>,>>>,>>9.99")
                                      , input   tt-petrol.pay-name
                                      ) .

end.

end procedure. /* print-lines */