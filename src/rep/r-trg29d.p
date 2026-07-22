/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Форма ТОРГ-29 по документам

Автор: Хныкин Павел Андреевич
Дата создания: 02/03/09
Author: Pavel Khnykin
Creation date: 02/03/09

Автор1: Демин Алексей Сергеевич
Дата создания: 07/30/08
Author1: Alexey Demin
Creation date: 07/30/08

*/
using Ibs.Th.Gbl.ProgressBar.
block-level on error undo, throw.
define input parameter parparentproc            as   widget-handle         no-undo .
define input parameter p-parent-handle          as handle                  no-undo .
define input parameter p-log-handle             as handle                  no-undo .
define input parameter p-cont-handle            as handle                  no-undo .
define input parameter p-call-handle            as handle                  no-undo .
define input parameter p-rebh                   as handle                  no-undo . /*для ошибок*/
define input parameter p-rdbh                   as handle                  no-undo . /*destination*/
define input parameter p-report-id              as character               no-undo .
define input parameter p-log-file-name          as character               no-undo .
define input parameter p-batch                  as integer                 no-undo .
define input parameter p-codex-id               as integer no-undo .
define input parameter p-ruleset-id             as integer no-undo .
define input parameter p-without-vat as logical no-undo .
define input parameter p-tax-rate-list as character no-undo .
define input parameter p-break-by-cp as logical no-undo .
define input parameter p-no-covered-techrfsl as logical no-undo .
define input parameter p-ext-doc-type-subtotals as logical no-undo .
define input parameter p-plain-txt              as   logical               no-undo .
define input parameter p-xls                    as   logical               no-undo .
define input parameter p-dir-name               as   character             no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Форма ТОРГ-29 по документам".
{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/r-page1.i      }
{ cmp/r-pril.i       }
{ rep/r-sym.i        }
{ trg/factord.i      }
{ gbl/waitfram.i     }
{ rep/p-fmt.i        }
{ rep/lkp-font.i     }
{ rep/ostatok.i  }
{ rep/ost-line.i     }
{ ref/grplibfn.i     }
{ rep/fmtcli.i       }
{ gbl/paramls.i      }
{ rep/r-pychk0.i defalgo    }
&SCOP f-l shiftright
{ gbl/std-func.i {&f-l} }
{ rep/gn-extp.i }
{ str/trdcalib.i }
{ gbl/ggoattr.i }
{ str/trdcalib.i }

define variable g#report-num   as integer no-undo .
run get-report-num in parparentproc (output g#report-num).
{ rep/reprumpr.i print-plain-text,print-printer,print-xlt }

&scop display-message ~
   if p-batch > 0 then do: ~
     run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input p-log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~). ~
   end. ~
   else do: ~
      run write-to-log in p-log-handle ( input ~{&my-message~}). ~
   end

{ rep/torg29xl.i     }
{ gbl/getcntxt.i def }


define temp-table tt-goods no-undo
  field gds-code      like ub.goods.gds-code
  field artic         like ub.goods.artic
  field prod-type     like ub.goods.prod-type
  field prod-code     like ub.goods.prod-code
index pi is primary unique
  artic
  prod-type
  prod-code
.

define temp-table tt-report-object no-undo
  field obj-type      like ub.clients.obj-type
  field obj-code      like ub.clients.obj-code
  field ost-gds-sum-1   as decimal
  field ost-tara-sum-1  as decimal
  field ost-gds-sum-2   as decimal
  field ost-tara-sum-2  as decimal
index pi is primary unique
  obj-type
  obj-code
.

define temp-table tt-report no-undo
  field ext-doc-type  like ub.trn-doc.ext-doc-type
  field real-ext-doc-type like ub.trn-doc.ext-doc-type
  field break-ext-doc-type like ub.trn-doc.ext-doc-type
  field cli-name      as character
  field fact-order    as decimal
  field fact-date     as date
  field doc-code      like ub.trn-doc.doc-code
  FIELD num-ship      like ub.trn-doc.doc-code  
  field doc-sum       as decimal
  field tara-sum      as decimal
  field buh-1         as character
  field obj-type      like ub.clients.obj-type
  field obj-code      like ub.clients.obj-code
index pi is primary unique
  doc-code ext-doc-type
index fo fact-order
index exdoc ext-doc-type
index obj
  obj-type
  obj-code
index fo2 break-ext-doc-type fact-order
.

define temp-table tt-ignore-docs no-undo
field doc-code as character
index pi is unique primary
doc-code.

define temp-table temp-inkas no-undo
field ras-doc-code as character
field ret-doc-code as character
field obj-type as character
field obj-code as integer
field inkas-code as character
index pi is unique primary
inkas-code
index iret ret-doc-code
index idoc ras-doc-code
index iobj obj-type obj-code
.

define temp-table temp-cp no-undo
field gds-code as integer
field cdpay-code as integer
field curr-code as integer
field eff-doc-qnty as decimal
field doc-code  as character
field inkas-code as character
field tot-rb as decimal
field doc-date as date
field sum as decimal
index pi
is unique primary
doc-code
gds-code
cdpay-code
curr-code
index iinkas
inkas-code
.
/*
bf_doc-line.price-rubl * bf_gds-dtl.fact-qnty
*/

define buffer buf_gds-obj   for ub.gds-obj.
define buffer buf_goods     for ub.goods.
define buffer buf_gds-grp   for ub.gds-grp.
define buffer buf_trn-doc   for ub.trn-doc.
define buffer buf_doc-line  for ub.doc-line.
define buffer buf_ot-line   for ub.ot-line.
define buffer buf_obj-list  for obj-list.
define buffer buf2_obj-list  for obj-list.

define stream out-stream.

define variable v-fact-order-1           as decimal   no-undo .
define variable v-fact-order-2           as decimal   no-undo .
define variable v-curr-r-b               as character no-undo .
define variable v-line                   as character no-undo .
define variable v-print-rubl             as logical   no-undo .
define variable v-gds-counter            as integer   no-undo .
define variable v-host-code-1 like ub.clients.host-code no-undo .
define variable v-host-code-2 like ub.clients.host-code no-undo .
define variable v-name              as character no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo init -1.

define variable v-upper-code as integer no-undo.
define variable v-value as character no-undo.
define variable v-type as character no-undo.
define variable v-p-accsup as character no-undo.

/* Учет расходных материалов */
{ gbl/conf-rd.i
  "'accsup'"
  "''"
  "''"
  0
  "''"
  "''"
  "''"
  no
  v-p-accsup
  v-type
  no-error
}

&scop income-type "inc":U
&scop outcome-type "out":U

&scop has-name-column yes
&scop none-symbol "X"
&if "{&has-name-column}" = "yes" &then
&scop frame-width 130
&else
&scop frame-width 135
&endif
&scop col-fmtl-name "X(25)":U
&scop col-fmtl-code-l 25
&scop col-fmtl-code "X(25)":U
&scop col-fmtl-date-l 10
&scop col-fmtl-date "99/99/9999":U
&scop gds-sum-fmt "->>>>,>>>,>>>,>>9.99":U
&if "{&has-name-column}" = "yes" &then
&scop cp-name-length 25
&scop tara-sum-fmt "->>,>>9.99":U
&scop col-fmtl-buh "X(14)":U
&else
&scop cp-name-length 25
&scop tara-sum-fmt "->>>>,>>>,>>>,>>9.99":U
&scop col-fmtl-buh "X(41)":U
&endif
/*&scop col-fmtlw-2 10*/
/*&scop col-fmtlw-3 20*/
/*&scop col-fmtlw-7 15*/

function w-date returns character ( input p-date as date ) forward .

define frame torg29
&if "{&has-name-column}" = "yes" &then
  sym7                            column-label ":" format "X(1)"                             space(0)
  v-name                          column-label "  Наименование" format {&col-fmtl-name}     space(0)
&endif
  sym1                            column-label ": " format "X(2)"                             space(0)
  tt-report.fact-date             column-label "   Дата" format {&col-fmtl-date}                space(0)
  sym2                            column-label ": " format "X(2)"                             space(0)
  tt-report.num-ship              column-label "  Номер документа" format {&col-fmtl-code}     space(0)
  sym3                            column-label ":" format "X(2)"                             space(0)
  tt-report.doc-sum               column-label "Сумма товара    " format {&gds-sum-fmt}          space(0)
  sym4                            column-label ":" format "X(2)"                             space(0)
&if "{&has-name-column}" = "yes" &then
  tt-report.tara-sum              column-label "Сумма тары" format {&tara-sum-fmt}            space(0)
&else
  tt-report.tara-sum              column-label "Сумма тары      " format {&tara-sum-fmt}            space(0)
&endif
  sym5                            column-label ":" format "X(2)"                             space(0)
&if "{&has-name-column}" = "yes" &then
  tt-report.buh-1                 column-label "       Отметки бухгалтерии" format {&col-fmtl-buh}  space(0)
&else
  tt-report.buh-1                 column-label "        Отметки бухгалтерии" format {&col-fmtl-buh}  space(0)
&endif
  sym6                            column-label ":" format "X(1)"                             space(0)
header
&if "{&has-name-column}" = "yes" &then
    ":-------------------------:-----------:--------------------------:---------------------:-----------:---------------------------:":U skip
&else
    ":-----------:--------------------------:---------------------:---------------------:------------------------------------------:":U skip
&endif
/*    ":            1            :     2    :          3         :          4          :                 5                 :":U skip*/
with width {&frame-width} down stream-io .


form header
        v-line format "X({&frame-width})" at 1 SKIP
        "Продолжение - на следующей странице" at 1 SKIP
with frame BottomFrame width {&A4_LS} PAGE-BOTTOM NO-LABELS NO-BOX .


do on error undo, return error return-value :

  { gbl/working.i }
  run clear-tt in this-procedure .
  { gbl/getcntxt.i get }

  assign  v-line = fill( "-" , 300 ) .
  /* выбираем валюту */
  case x-SET_val_TYPE :
    when {&v-rubl} then do:
      assign  v-print-rubl = yes .
    end.
    when {&v-base} then do:
      assign  v-print-rubl = no .
    end.
    otherwise do:
      if x-SET_PAY_TYPE <> {&p-crsa} then  message "Неизвестный тип валюты!" skip "Отчет формируется в базовой валюте" view-as alert-box information .
      { gbl/curr-r-b.i v-curr-r-b }
      assign  v-print-rubl = ( v-curr-r-b = {&r-b-rubl} )  .
    end.
  end case.

  find first buf_obj-list no-error .
  if not available buf_obj-list then do:
    &scop my-message  substitute("Не указан объект для формирования отчета")
    {&display-message}.
    undo, return error.
  end.
  { gbl/hostcode.i buf_obj-list.obj-type buf_obj-list.obj-code v-host-code-1 }
  for each buf_obj-list :
    { gbl/hostcode.i buf_obj-list.obj-type buf_obj-list.obj-code v-host-code-2 }
    if v-host-code-1 <> v-host-code-2 then do:
      &scop my-message  substitute("Отчет формируется по объектам одной фирмы!")
      {&display-message}.
      undo, return error.
    end.
  end.
  if not x-TOG-Shift then do:
   /*Поиск нач fact-order*/
    run day-begin-fact-order in this-procedure ( input x-Date-Start , output v-fact-order-1 ).
   /*Поиск посл fact-order*/
    run  factord-end-day in this-procedure ( input x-Date-End , output v-fact-order-2 ).
  end.

  { cmp/open-out.i stream out-stream " " }

  run torg29xl-init in this-procedure.

  run create-report in this-procedure .
  run print-report in this-procedure .

  run waitfram-hide in this-procedure .

  run torg29xl-close in this-procedure .
  output stream out-stream close.
  {&CloseExcel}
  run clear-tt in this-procedure .
  { gbl/stopwork.i }
  define variable DisabledOptions as integer   no-undo .
  define variable v-orient-page as character no-undo .
  run How-name in this-procedure ( input ReportPageHeight
                                  , input ReportPageWidth
                                  , output v-orient-page ) .
  if v-orient-page = "A4-lans":U then DisabledOptions = 8 .
                                else DisabledOptions = 0 .
  assign
  ReportFontNum = 7.
  if p-batch > 0 then do:
    /*сразу печатаем на принтер проверка на q-print внутри*/
    run reprumpr_print-printer in this-procedure ( input ReportFontNum /*font*/
                                                  ,input (if v-orient-page = "A4-lans":U
                                                          then 2
                                                          else 0) /*flags*/
                                                  ) no-error.
    if error-status:error then do:
      &scop my-message "Печать на принтер завершилась ошибкой..."
      {&display-message}.
    end.

    IF p-xls THEN DO:
      RUN reprumpr_print-xlt ( input p-dir-name
                              ,input '' /*нет печати по расписанию в XLT*/
                              ,input substitute("torg29d_&1&2_&3&4&5_&6.xls"
                                                , v-obj-type
                                                , v-obj-code
                                                , string(year(X-date-end), "9999")
                                                , string(month(X-date-end), "99")
                                                , string(day(X-date-end), "99")
                                                , X-shift-end)
                               ,input DisabledOptions /*p-disable-option*/
                               ,input ReportFontNum /*p-font-number*/
                                ) no-error  .
      if error-status:error then do:
        &scop my-message return-value
        {&display-message}.
      end.
    END.
    if p-plain-txt then do:
      run reprumpr_print-plain-text in this-procedure ( input p-dir-name
                                                        ,input '' /*нет печати по расписанию в TXT*/
                                                        ,input substitute("torg29d_&1&2_&3&4&5_&6.txt"
                                                                        , v-obj-type
                                                                        , v-obj-code
                                                                        , string(year(X-date-end), "9999")
                                                                        , string(month(X-date-end), "99")
                                                                        , string(day(X-date-end), "99")
                                                                        , X-shift-end)
                                                        ,input DisabledOptions /*p-disable-option*/
                                                        ,input ReportFontNum /*p-font-number*/
                                                        ) no-error.
      if error-status:error then do:
        &scop my-message return-value
        {&display-message}.
      end.
    end.
  end.
  else do:
    define variable v-user-action   as character no-undo .
    define variable v-printed       as logical   no-undo .
  os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
  os-rename
    value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
    value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
  .
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
end.

/* ==================================================================================================================== */
procedure clear-tt :

do
on error undo, return error return-value
:
  empty temp-table tt-report-object.
  empty temp-table tt-report.
  empty temp-table tt-goods.
end.

end procedure. /* clear-tt */

/* ==================================================================================================================== */
procedure print-header-list-1 :
  define buffer buf_clients for ub.clients.
  define variable v-obj-list as character format "X(78)" no-undo .
do
on error undo, return error return-value
:

find first buf_clients no-lock
  where buf_clients.obj-type = {&cmp}
    and buf_clients.obj-code = v-host-code-1
no-error .
if not available buf_clients then do:
  &scop my-message  substitute("Не найдена фирма с кодом &1&2" + ~
                               "Отчет не может быть сформирован" ~
                               , v-host-code-1, ~{&new-line~})
  {&display-message}.
  return error.
end.
for each buf_obj-list :
  assign
    v-obj-list = v-obj-list + buf_obj-list.obj-name + ','
  .
end.
assign
  v-obj-list = trim( v-obj-list , ',' ).
.
run fmtcli-get-client in this-procedure ( input  buf_clients.obj-type , input buf_clients.obj-code ).
put stream out-stream unformatted
  "                                                                                                 Унифицированная форма N ТОРГ-29" skip
  "                                                                                                                                " skip
  "                                                                                                 Утверждена                     " skip
  "                                                                                                 Постановлением                 " skip
  "                                                                                                 Госкомстата России             " skip
  "                                                                                                 от 25.12.98 N 132              " skip
  "                                                                                                                                " skip
  "                                                                                                                      ----------" skip
  "                                                                                                                      |  Код   |" skip
  "                                                                                                                      |--------|" skip
  "                                                                                                        Форма по ОКУД |0330229 |" skip
  "                                                                                                                      |--------|" skip
  substitute( "             &1    по ОКПО |&2|"
            , string( p-fmt-align-string( v-fmtcli-name , 93 , "left") , "X(93)" )
            , string( v-fmtcli-okpo , "X(8)"  )
            )
  skip
  "             -----------------------------------------------------------------------------------------------          |--------|" skip
  "                                                   организация                                                        |        |" skip
  substitute( "             &1                           |--------|"
            , string( p-fmt-align-string( v-obj-list , 78 , "left") , "X(78)" )
            )
  skip
  "             ------------------------------------------------------------------------------  Вид деятельности по ОКДП |        |" skip
  "                                           структурное подразделение                                                  |--------|" skip
  "                                                                                                         Вид операции |        |" skip
  "                                                                                                                      ----------" skip
  "                                                                                                                                " skip
  "                                                                                  ----------------------------------------------" skip
  "                                                                                  |  Номер  |    Дата   |        Отчетный      |" skip
  "                                                                                  |документа|составления|         период       |" skip
  "                                                                                  |         |           |----------------------|" skip
  "                                                                                  |         |           |     с     |    по    |" skip
  "                                                                                  |---------|-----------|-----------|----------|" skip
  substitute( "                                                                   ТОВАРНЫЙ ОТЧЕТ |         |&1 |&2 |&3|"
            , string( today , "99.99.9999" )
            , string( x-Date-Start , "99.99.9999" )
            , string( x-Date-End , "99.99.9999" )
            )
  skip
  "                                                                                  ----------------------------------------------" skip
  "                                                                                                                                " skip
  "                                                                                                               -----------------" skip
  "                                                                                                               |Табельный номер|" skip
  "                                                                                                               |---------------|" skip
  "                                                                                                               |               |" skip
  "                        Материально ответственное лицо _______________________________________________________ -----------------" skip
  "                                                                             должность, фамилия,                                " skip
  "                                                                                имя, отчество                                   " skip(1)
.
run print-table-header in this-procedure .
run torg29xl-write-cell-data in this-procedure ( input {&torg29xl-h_firmname}, input v-fmtcli-name ).
run torg29xl-write-cell-data in this-procedure ( input {&torg29xl-h_objlist},  input v-obj-list ).
run torg29xl-write-cell-data in this-procedure ( input {&torg29xl-h_okpo}, input v-fmtcli-okpo ).
run torg29xl-write-cell-data in this-procedure ( input {&torg29xl-h_printdate}, input string( today , "99.99.9999") ).
run torg29xl-write-cell-data in this-procedure ( input {&torg29xl-h_datestart}, input string( x-Date-Start, "99.99.9999" ) ).
run torg29xl-write-cell-data in this-procedure ( input {&torg29xl-h_dateend  }, input string( x-Date-End , "99.99.9999" ) ).

end.

end procedure. /* print-header-list-1 */

/* ==================================================================================================================== */
procedure print-header-list-2 :
do
on error undo, return error return-value
:
  put stream out-stream "Оборотная сторона формы N ТОРГ-29" skip(1).
  run print-table-header in this-procedure .
end.

end procedure. /* print-header-list-2 */

/* ==================================================================================================================== */
procedure print-table-header :

  define variable v-str     as character no-undo .
  define variable v-length  as integer   no-undo .
  define variable v-result  as character no-undo .
  define variable v-i       as integer   no-undo .
  define variable v-j       as integer   no-undo .

do
:
  &scop field-width 31

  assign
    v-str     = "Сумма, {&abbr_rub}. {&abbr_kop}."
    v-length  = length(v-str)
  .

  if v-length > 31 then do:
    assign  v-result = substring( v-str , 1 , 31 ) .
  end.
  else do:
    assign v-i = center-field( 1, {&field-width}, v-length ) .
    do v-j = 1 to {&field-width} :
      if v-j <> v-i then do:
        assign v-result = v-result + " " .
      end.
      else do:
        assign
          v-result  = v-result + v-str
          v-j       = v-j + length(v-str) - 1
        .
      end.
    end.
  end.

/*  put stream out-stream unformatted*/
/*               "--------------------------------------------------------------------------------------------------------------------------------":U skip*/
/*    substitute( ":                  Документ                 :&1:              Отметки          :":U*/
/*              , v-result*/
/*              ) skip*/
/*               ":---------------------------------------:-------------------------------:            бухгалтерии        :":U skip*/
/*               ":       номер            :     дата     :     товара    :       тары    :                               :":U skip*/
/* .*/


end.

end procedure. /* print-table-header */


procedure print-footer-list-2 :
do on error undo, return error return-value :
  put stream out-stream unformatted
    "Приложение ____________________________________________ документов                    ":U skip
    "                                                                                      ":U skip
    "Отчет с документами                                                                   ":U skip
    "принял и проверил   _________________________ __________________ _____________________":U skip
    "                              должность              подпись      расшифровка подписи ":U skip
    "                                                                                      ":U skip
    "Материально                                                                           ":U skip
    "ответственное лицо  _________________________ __________________ _____________________":U skip
    "                              должность              подпись      расшифровка подписи ":U skip
  .
  end.
end procedure. /* print-footer-list-2 */


/* ==================================================================================================================== */
procedure create-tt-goods :

  define buffer buf_goods   for ub.goods.
  define buffer buf_cli-gds for ub.cli-gds.

  define variable v-curr-grp-name as character no-undo .
  define variable v-host-code     like ub.clients.host-code  no-undo .

  do on error undo, return error return-value :
    run waitfram-show in this-procedure ( "Формирование списка товаров..." ) .
    empty temp-table tt-goods.

    for each buf_obj-list :
      case x-SelectGood :
        when {&g-all} then do: /* все товары */
          for each buf_gds-obj no-lock
            where buf_gds-obj.obj-type  = buf_obj-list.obj-type
              and buf_gds-obj.obj-code  = buf_obj-list.obj-code
            :
            run fill-tt in this-procedure .
          end.
        end.
        when {&g-prod} then do:    /* не все производители */
          for each G#cli : /* встать на производителя */
            for each buf_gds-obj  no-lock
              where buf_gds-obj.obj-type  = buf_obj-list.obj-type
                and buf_gds-obj.obj-code  = buf_obj-list.obj-code
                and buf_gds-obj.prod-type = G#cli.obj-type
                and buf_gds-obj.prod-code = G#cli.obj-code
              use-index pi  :
              run fill-tt in this-procedure .
            end .
          end .                /* do ... по производителям */
        end .
        when {&g-grp} then do:    /* не все группы товаров */
          for each tmp#grp :
            run grplib-get-full-name in this-procedure( input tmp#grp.node-code, output v-curr-grp-name ) .
            for each buf_gds-obj no-lock
              where buf_gds-obj.obj-type = buf_obj-list.obj-type
                and buf_gds-obj.obj-code = buf_obj-list.obj-code
                and buf_gds-obj.grp-name begins v-curr-grp-name
              use-index obj-grp :
              run fill-tt in this-procedure .
            end .
          end.
        end.
        otherwise do:    /* список товаров */
          for each gds-list ,
              each buf_gds-obj no-lock
            where buf_gds-obj.obj-type  = buf_obj-list.obj-type
              and buf_gds-obj.obj-code  = buf_obj-list.obj-code
              and buf_gds-obj.artic     = gds-list.artic
              and buf_gds-obj.prod-type = gds-list.prod-type
              and buf_gds-obj.prod-code = gds-list.prod-code
            :
            run fill-tt in this-procedure .
          end.
        end.

      end case.
    end.                    /* for each ... по объектам */
    run waitfram-hide in this-procedure .
  end.
end procedure. /* create-tt-goods */


procedure fill-tt :
  do  on error undo, return error return-value :
    find first tt-goods no-lock
      where tt-goods.prod-type = buf_gds-obj.prod-type
        and tt-goods.prod-code = buf_gds-obj.prod-code
        and tt-goods.artic     = buf_gds-obj.artic
    no-error.
    
    find first buf_goods where buf_goods.gds-code = buf_gds-obj.gds-code.
    
    /* #2789 Если есть атрибут группы товара Не учитывать в автоматической отчетности, то пропускаем товар */  
    v-upper-code = buf_goods.grp-code.
    v-value = "".
    do while v-upper-code > 0 and v-p-accsup = "yes" and p-batch > 0 :      
        find first buf_gds-grp where buf_gds-grp.node-code = v-upper-code.
          
        run ggoattr-value(
          input buf_gds-grp.node-code,
          input 0,
          input "",
          input 0,
          input {&ggoattr-no-inc-auto-rep},
          output v-value,
          output v-type
        ).
        
        if v-value = "yes" then
          leave.
        else
          v-upper-code = buf_gds-grp.upper-code.
    end.  
    
    if not available tt-goods and v-value <> "yes" then do:
      create tt-goods.
      assign
        v-gds-counter      = v-gds-counter + 1
        tt-goods.prod-type = buf_gds-obj.prod-type
        tt-goods.prod-code = buf_gds-obj.prod-code
        tt-goods.artic     = buf_gds-obj.artic
        tt-goods.gds-code  = buf_gds-obj.gds-code
      .
    end.
  end.
end procedure. /* fill-tt */





/* ==================================================================================================================== */
procedure create-report :

  define variable var-x-store-code    like ub.clients.obj-code    no-undo.
  define variable var-x-store-type    like ub.clients.obj-type    no-undo.
  define variable var-x-date-start    like ub.stk-tot.Fact-date   no-undo.
  define variable var-x-date-endt     like ub.stk-tot.Fact-date   no-undo.
  define variable var-x-sum-type      like ub.stk-tot.sum-type    no-undo.
  define variable var-x-ost-sum-type  like ub.stk-tot.sum-type    no-undo.
  define variable var-x-cat-id        like ub.stk-tot.cat-id      no-undo.
  define variable var-xTog-obj        as   log                 no-undo.

  define variable var-Quantity        like ub.stk-tot.fact-qnty   initial ? no-undo.
  define variable var-Coast_R         like ub.stk-tot.sum-rubl    no-undo.
  define variable var-Coast_V         like ub.stk-tot.sum-rubl    no-undo.
  define variable var-VAT_R           like ub.stk-tot.sum-rubl    no-undo.
  define variable var-VAT_V           like ub.stk-tot.sum-rubl    no-undo.
  define variable var-Fact-order      like ub.stk-tot.Fact-order  no-undo.

  define variable var-x-artic         like ub.stk-line.artic      no-undo.
  define variable var-x-prod-code     like ub.stk-line.prod-code  no-undo.
  define variable var-x-prod-type     like ub.stk-line.prod-type  no-undo.

  define variable var-SLT_R           like ub.stk-tot.sum-rubl    no-undo.
  define variable var-SLT_V           like ub.stk-tot.sum-rubl    no-undo.


  define variable v-ost-gds-1         as decimal   no-undo .
  define variable v-ost-tara-1        as decimal   no-undo .
  define variable v-ost-gds-2         as decimal   no-undo .
  define variable v-ost-tara-2        as decimal   no-undo .
  define variable v-ost-qnty          as decimal   no-undo .
  define variable v-counter           as integer   no-undo .
  define variable v-prg               as class ProgressBar no-undo .
  define variable v-none-sym-1        as character no-undo .
  define variable v-none-sym-2        as character no-undo .

  define buffer buf_tax-rate-gds for ub.tax-rate-gds.

do
on error undo, return error return-value
:
  run create-tt-goods in this-procedure .
  empty temp-table tt-report.
  case x-SET_PAY_TYPE :
    when {&p-cost} then do:
      assign
        var-x-sum-type      = {&arh-cost}
        var-x-ost-sum-type  = {&arh-cost}
      .
    end.
    when {&p-crsa} then do:
      assign
        var-x-sum-type      = {&arh-crsa}
        var-x-ost-sum-type  = {&arh-crsa}
      .
    end.
    when {&p-sale} then do:
      assign
        var-x-sum-type      = {&arh-sale}
        var-x-ost-sum-type  = {&arh-crsa}
      .
    end.
    otherwise do:
      assign
        var-x-sum-type      = {&arh-cost}
        var-x-ost-sum-type  = {&arh-cost}
      .
    end.
  end case.
  var-x-cat-id      = {&root-cat-id}.
  for each buf_obj-list :
    if v-obj-code = -1 then do:
      assign
      v-obj-type = buf_obj-list.obj-type
      v-obj-code = buf_obj-list.obj-code.
    end.
    else do:
      assign
      v-obj-type = ''
      v-obj-code = 0
      .
    end.
    v-prg = new ProgressBar( 1 , v-gds-counter ).
    assign
      v-prg:frame-title = buf_obj-list.obj-name
      v-prg:fg-color = 9
    .
    v-prg:show-bar().
    if x-TOG-Shift then do:
      /*Поиск нач СМЕННОГО fact-order*/
      run ostatok in this-procedure (
        input buf_obj-list.obj-code
       ,input buf_obj-list.obj-type
       ,input x-TOG-Shift
       ,input x-date-start - 1
       ,input date('')
       ,input x-Shift-Start
       ,input x-Shift-End
       ,input var-x-ost-sum-type
       ,input var-x-cat-id
       ,input true /*tog-obj*/
       ,output  var-Quantity
       ,output  var-Coast_R
       ,output  var-Coast_V
       ,output  var-VAT_R
       ,output  var-VAT_V
       ,output  v-fact-order-1 ).
       run ostatok in this-procedure (
        input buf_obj-list.obj-code
       ,input buf_obj-list.obj-type
       ,input x-TOG-Shift
       ,input x-date-start
       ,input x-date-end
       ,input x-Shift-Start
       ,input x-Shift-End
       ,input var-x-ost-sum-type
       ,input var-x-cat-id
       ,input true
       ,output  var-Quantity
       ,output  var-Coast_R
       ,output  var-Coast_V
       ,output  var-VAT_R
       ,output  var-VAT_V
       ,output v-Fact-order-2 ).
    end. /* if x-TOG-Shift then do:*/
    /*разбивка по типам кассовым платежей - размазка*/
    if p-break-by-cp  then do:
    run break-by-cp-prep in this-procedure ( input buf_obj-list.obj-type
                                       ,input buf_obj-list.obj-code
                                       ,input v-fact-order-1
                                       ,input v-fact-order-2
                                       ) .
    end.
    /* по всем товарам объекта */
    _goods-loop:
    for each tt-goods :
      v-prg:increment().

        /*НДС*/
       if p-tax-rate-list > '' then do:
          find last buf_tax-rate-gds no-lock
              where buf_tax-rate-gds.tax-code  = integer({&vat-tax-code})
                and buf_tax-rate-gds.gds-code  = tt-goods.gds-code
                and buf_tax-rate-gds.host-code  = 0
                and buf_tax-rate-gds.obj-type  = ''
                and buf_tax-rate-gds.obj-code  = 0
                and buf_tax-rate-gds.fact-order <= v-fact-order-1 no-error.
          if not available buf_tax-rate-gds then do:
            next _goods-loop.
          end.
          if lookup(string(buf_tax-rate-gds.rate-code), p-tax-rate-list) = 0
          then do:
            next _goods-loop.
          end.

        end. /*if p-tax-rate-rids > '' then do:*/

      /* собираем остатки по товару на объекте */
      assign
        var-x-store-code  = buf_obj-list.obj-code
        var-x-store-type  = buf_obj-list.obj-type
        var-x-artic       = tt-goods.artic
        var-x-prod-code   = tt-goods.prod-code
        var-x-prod-type   = tt-goods.prod-type
        var-x-cat-id      = {&root-cat-id}
        var-xTog-obj      = yes
        v-counter         = v-counter + 1
      .
      RUN ost-line in this-procedure (
          input   var-x-store-code    ,
          input   var-x-store-type    ,
          input   var-x-artic         ,
          input   var-x-prod-code     ,
          input   var-x-prod-type     ,
          input   X-tog-shift         ,
          input   v-fact-order-1      ,
          input   var-x-ost-sum-type  ,
          input   var-x-cat-id        ,
          input   var-xTog-obj        ,
          output  var-Quantity        ,
          output  var-Coast_R         ,
          output  var-Coast_V         ,
          output  var-VAT_R           ,
          output  var-VAT_V           ,
          output  var-SLT_R           ,
          output  var-SLT_V          ) .
      assign  v-ost-gds-1 = v-ost-gds-1 +
                           ( if v-print-rubl = yes
                           then (var-Coast_R  - (if p-without-vat
                                                 then var-VAT_R
                                                 else 0)
                                )
                           else (var-Coast_V  - (if p-without-vat
                                                then var-VAT_V
                                                else 0)
                                )
                           )  .
      RUN ost-line in this-procedure (
          input   var-x-store-code    ,
          input   var-x-store-type    ,
          input   var-x-artic         ,
          input   var-x-prod-code     ,
          input   var-x-prod-type     ,
          input   X-tog-shift         ,
          input   v-fact-order-2      ,
          input   var-x-ost-sum-type  ,
          input   var-x-cat-id        ,
          input   var-xTog-obj        ,
          output  var-Quantity        ,
          output  var-Coast_R         ,
          output  var-Coast_V         ,
          output  var-VAT_R           ,
          output  var-VAT_V           ,
          output  var-SLT_R           ,
          output  var-SLT_V          ) .
      assign  v-ost-gds-2 = v-ost-gds-2 +
                           ( if v-print-rubl = yes
                           then (var-Coast_R  - (if p-without-vat
                                                 then var-VAT_R
                                                 else 0)
                                )
                           else (var-Coast_V  - (if p-without-vat
                                                then var-VAT_V
                                                else 0)
                                )
                           )  .

      _ot-line:
      for each buf_ot-line no-lock
          where buf_ot-line.obj-type     = buf_obj-list.obj-type
            and buf_ot-line.obj-code     = buf_obj-list.obj-code
            and buf_ot-line.artic        = tt-goods.artic
            and buf_ot-line.prod-type    = tt-goods.prod-type
            and buf_ot-line.prod-code    = tt-goods.prod-code
            and buf_ot-line.fact-order   >= v-fact-order-1  /* fact-order начала периода */
            and buf_ot-line.fact-order   <= v-fact-order-2  /* fact-order конца периода */
            and buf_ot-line.sum-type     = var-x-sum-type
      :
        /* не выводим документы у которых контрагент в списке объектов */
        if buf_ot-line.ext-doc-type <>  {&TDEDT_Overturn} then do:
        find first buf_trn-doc no-lock  where buf_trn-doc.doc-code = buf_ot-line.doc-code  no-error .
        if available buf_trn-doc then do:
           find first buf2_obj-list no-lock
            where buf2_obj-list.obj-type = buf_trn-doc.cli-type
              and buf2_obj-list.obj-code = buf_trn-doc.cli-code
           no-error .
           if available buf2_obj-list then do:
            next _ot-line.
           end.
        end.
        end.
        case buf_ot-line.ext-doc-type :
          /* ПРИХОД */
          when {&TDEDT_Pri_Vnesh}           or
          when {&TDEDT_Pri_Perem}           or
          when {&TDEDT_Vozvrat_Perem}       or
          when {&TDEDT_Pri_Prvo}
          then do:
            if x-SET_PAY_TYPE = {&p-sale} then do:
              next _ot-line.
            end.
            run fill-tt-rep ( input tt-goods.gds-code, input {&income-type}) .
          end.
          when {&tdedt_vozvrat_vnesh}       or
          when {&tdedt_vozvrat_vnesh_kass}
          then do:
            run fill-tt-rep ( input tt-goods.gds-code, input {&income-type}) .
          end.
          /* РАСХОД */
          when {&TDEDT_Ras_Vnesh}           or
          when {&TDEDT_Ras_Vnesh_Kass}      or
          when {&tdedt_ras_vnesh_vp}        or
          when {&tdedt_spi_vnesh}           or
          when {&TDEDT_Ras_Perem}           or
          when {&TDEDT_Ras_Prvo}            or
          when {&TDEDT_Spi_Prvo}
          then do:
            run fill-tt-rep ( input tt-goods.gds-code, input {&outcome-type}) .
          end.
          when {&TDEDT_Inv}               or
          when {&TDEDT_Peresort}          or
          when {&TDEDT_Overturn}          or
          when {&TDEDT_Corr_Acc_Price}    or
          when {&TDEDT_Corr_Minus_Parts}
          then do:
            if x-SET_PAY_TYPE = {&p-sale} then next _ot-line.
            run fill-tt-rep (
                               input tt-goods.gds-code
                              ,input if ( buf_ot-line.sum-base > 0 or buf_ot-line.sum-rubl > 0 )
                                    then {&income-type}
                                     else {&outcome-type}) .
          end.
          otherwise do:
            next _ot-line.
          end.
        end case.
        assign
/*          tt-report.obj-type      = buf_obj-list.obj-type*/
/*          tt-report.obj-code      = buf_obj-list.obj-code*/
          tt-report.doc-sum       = tt-report.doc-sum + abs( if v-print-rubl = yes
                                                             then (buf_ot-line.sum-rubl  - (if p-without-vat
                                                                                            then buf_ot-line.vat-rubl
                                                                                            else 0)
                                                                  )
                                                             else (buf_ot-line.sum-base   - (if p-without-vat
                                                                                            then buf_ot-line.vat-base
                                                                                            else 0)
                                                                   )
                                                             )
          v-counter               = v-counter + 1
         .
      end. /* for each buf_ot-line */

      if x-SET_PAY_TYPE = {&p-sale} then do:
        _ot-line-sale :
        for each buf_ot-line no-lock
            where buf_ot-line.obj-type     = buf_obj-list.obj-type
              and buf_ot-line.obj-code     = buf_obj-list.obj-code
              and buf_ot-line.artic        = tt-goods.artic
              and buf_ot-line.prod-type    = tt-goods.prod-type
              and buf_ot-line.prod-code    = tt-goods.prod-code
              and buf_ot-line.fact-order   >= v-fact-order-1  /* fact-order начала периода */
              and buf_ot-line.fact-order   <= v-fact-order-2  /* fact-order конца периода */
              and buf_ot-line.sum-type     = {&arh-crsa}
        :
          case buf_ot-line.ext-doc-type :
            /* ПРИХОД */
            when {&TDEDT_Pri_Vnesh}           or
            when {&TDEDT_Pri_Perem}           or
            when {&TDEDT_Vozvrat_Perem}       or
            when {&TDEDT_Pri_Prvo}
            then do:
              run fill-tt-rep ( input tt-goods.gds-code
                               ,input {&income-type}) .
            end.
            when {&TDEDT_Inv}               or
            when {&TDEDT_Peresort}          or
            when {&TDEDT_Overturn}          or
            when {&TDEDT_Corr_Acc_Price}    or
            when {&TDEDT_Corr_Minus_Parts}
            then do:
              run fill-tt-rep (  input tt-goods.gds-code
                                ,input if ( buf_ot-line.sum-base > 0 or buf_ot-line.sum-rubl > 0 )
                                      then {&income-type}
                                      else {&outcome-type}) .
            end.
            otherwise do:
              next _ot-line-sale.
            end.
          end case.
          assign
            tt-report.doc-sum       = tt-report.doc-sum + abs( if v-print-rubl = yes
                                                               then (buf_ot-line.sum-rubl - (if p-without-vat
                                                                                             then buf_ot-line.vat-rubl
                                                                                             else 0)
                                                                    )
                                                               else (buf_ot-line.sum-base  - (if p-without-vat
                                                                                             then buf_ot-line.vat-base
                                                                                             else 0)
                                                                     )
                                                                 )
            v-counter               = v-counter + 1
          .
        end.
      end.
    end. /* for each tt-goods */
    create tt-report-object.
    assign
      tt-report-object.obj-type       = buf_obj-list.obj-type
      tt-report-object.obj-code       = buf_obj-list.obj-code
      tt-report-object.ost-gds-sum-1  = v-ost-gds-1
      tt-report-object.ost-gds-sum-2  = v-ost-gds-2
      v-ost-gds-1                     = 0
      v-ost-gds-2                     = 0
    .
    v-prg:hide-bar().
    delete object v-prg.
    assign
        v-prg = ?
    .
  end. /* for each buf_obj-list */
  for each tt-report :
    if tt-report.doc-sum = 0 and tt-report.tara-sum = 0 then delete tt-report.
  end.
  for each tt-ignore-docs,
      each tt-report where
      tt-report.doc-code = tt-ignore-docs.doc-code :
  delete tt-report.
  end.
end.

end procedure. /* create-report */


procedure fill-tt-rep :
  do on error undo, return error return-value :
    define input parameter p-gds-code as integer no-undo .
    define input  parameter p-type as character no-undo .

    DEFINE VARIABLE v-attr-type     as character no-undo .
    DEFINE VARIABLE v-attr-value    as character no-undo .

    define variable v-doc-date          as date      no-undo .
    define variable v-vat-pc            as decimal   no-undo.
    
    define buffer goods_temp-cp for temp-cp.
    define buffer doc_temp-cp for temp-cp.
    define buffer buf_trn-doc for ub.trn-doc.


    find first tt-report where
             tt-report.doc-code = buf_ot-line.doc-code
         and tt-report.ext-doc-type = p-type no-error .
    if not available tt-report then do:
      run factord-to-date in this-procedure ( input buf_ot-line.fact-order , output v-doc-date ) .
      if buf_ot-line.ext-doc-type <> {&TDEDT_Overturn} then do:
        find first buf_trn-doc where
                buf_trn-doc.doc-code = buf_ot-line.doc-code no-error.
      end.
      if available buf_trn-doc
      and buf_trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh}
      and (buf_trn-doc.out-code <> ?
           and
           buf_trn-doc.out-code <> '') then do:
        if p-no-covered-techrfsl then run  process-covered-techrfsl ( buffer buf_trn-doc) no-error.
      end.
      create tt-report.
      assign
        tt-report.doc-code      = buf_ot-line.doc-code
        tt-report.fact-order    = buf_ot-line.fact-order
        tt-report.fact-date     = v-doc-date
        tt-report.ext-doc-type  = p-type
        tt-report.real-ext-doc-type  = buf_ot-line.ext-doc-type
      tt-report.break-ext-doc-type  = (if p-ext-doc-type-subtotals
                                       then  tt-report.real-ext-doc-type
                                       else '').
      if tt-report.real-ext-doc-type = {&TDEDT_Pri_Vnesh} then do:
                run gbl/trdcat-v.p   ( input tt-report.doc-code
                           , input {&trdcattr-nids} /* номер приходной накладной поставщика */
                           , output v-attr-value
                           , output v-attr-type
                           ) NO-ERROR .
        if v-attr-value <> "" then tt-report.num-ship = v-attr-value. else tt-report.num-ship = tt-report.doc-code .                            
      end.                                             
      if tt-report.real-ext-doc-type <> {&TDEDT_Pri_Vnesh} then do:
                run gbl/trdcat-v.p   ( input tt-report.doc-code
                           , input {&trdcattr-print-num} /*номер документа для печати*/
                           , output v-attr-value
                           , output v-attr-type
                           ) NO-ERROR .
        if v-attr-value <> "" then tt-report.num-ship = v-attr-value. else tt-report.num-ship = tt-report.doc-code .                            
      end.   
      tt-report.cli-name      = (if available buf_trn-doc
                                 then buf_trn-doc.cli-name
                                 else (if buf_ot-line.ext-doc-type = {&TDEDT_Overturn}
                                       then "(Переоценка)"
                                       else "")
                                 )
      .
    end.
    if p-break-by-cp
    and (buf_ot-line.ext-doc-type = {&tdedt_ras_vnesh_kass}
         or
         buf_ot-line.ext-doc-type = {&tdedt_vozvrat_vnesh_kass})
    then do:
      for each  goods_temp-cp where
                goods_temp-cp.gds-code = p-gds-code
            and goods_temp-cp.doc-code = buf_ot-line.doc-code :
         find first doc_temp-cp where
                    doc_temp-cp.gds-code = 0
                and doc_temp-cp.doc-code = buf_ot-line.doc-code
                and doc_temp-cp.cdpay-code = goods_temp-cp.cdpay-code
                and doc_temp-cp.curr-code = goods_temp-cp.curr-code no-error.
         if not available doc_temp-cp then do:
           create doc_temp-cp.
           assign
           doc_temp-cp.gds-code = 0
           doc_temp-cp.doc-code = buf_ot-line.doc-code
           doc_temp-cp.cdpay-code = goods_temp-cp.cdpay-code
           doc_temp-cp.curr-code = goods_temp-cp.curr-code
           .
         end.
         assign
         doc_temp-cp.eff-doc-qnty = doc_temp-cp.eff-doc-qnty  + goods_temp-cp.eff-doc-qnty
         doc_temp-cp.tot-rb = doc_temp-cp.tot-rb + goods_temp-cp.tot-rb
         .         
         
         if x-SET_PAY_TYPE = {&p-sale} then do:
             if not p-without-vat then do:
                 { gbl/pftxvalg.i
                   goods_temp-cp.gds-code
                   {&vat-tax-code}
                   buf_trn-doc.fact-date
                   buf_trn-doc.host-code
                   buf_trn-doc.obj-type
                   buf_trn-doc.obj-code
                   v-vat-pc
                   no-error
                 }
             end.
             doc_temp-cp.sum = doc_temp-cp.sum  + goods_temp-cp.tot-rb - (if p-without-vat then (goods_temp-cp.tot-rb * v-vat-pc / (100 + v-vat-pc)) else 0).
         end.
         else do:
         doc_temp-cp.sum = doc_temp-cp.sum +
                           goods_temp-cp.eff-doc-qnty * abs(if v-print-rubl = yes
                                                            then (buf_ot-line.sum-rubl - (if p-without-vat
                                                                                          then buf_ot-line.vat-rubl
                                                                                          else 0)
                                                                 )
                                                            else (buf_ot-line.sum-base  - (if p-without-vat
                                                                                          then buf_ot-line.vat-base
                                                                                          else 0)
                                                                 )
                                                            ) / if buf_ot-line.fact-qnty <> 0 then abs(buf_ot-line.fact-qnty) else 1.
/*                                                            message doc_temp-cp.sum "sum" doc_temp-cp.doc-code "sum-rubl" buf_ot-line.sum-rubl "gds-code" p-gds-code view-as alert-box.*/
                                                        
         end.
         release doc_temp-cp.
      end.
    end.

  end.
end procedure. /* fill-tt-rep */

/* ==================================================================================================================== */
procedure print-report :

  define variable v-total-gds         as decimal   no-undo .
  define variable v-total-tara        as decimal   no-undo .
  define variable v-ost-gds-1         as decimal   no-undo .
  define variable v-ost-tara-1        as decimal   no-undo .
  define variable v-ost-gds-2         as decimal   no-undo .
  define variable v-ost-tara-2        as decimal   no-undo .
  define variable v-itog-s-ost-gds    as decimal   no-undo .
  define variable v-itog-s-ost-tara   as decimal   no-undo .
  define variable v-avt-ovt-gds       as decimal   no-undo .
  define variable v-avt-ovt-tara      as decimal   no-undo .
  define variable v-ii                as integer no-undo .
  define variable v-ext-doc-type-doc-sum as decimal no-undo .
  define variable v-ext-doc-type-tara-sum as decimal no-undo .
  define buffer buf_cash-pay for ub.cash-pay.
  define buffer doc_temp-cp for temp-cp.

do
on error undo, return error return-value
:
  &scop gds-sum-fmt "->>>,>>>,>>9.99":U
&if "{&has-name-column}" = "yes" &then
  &scop tara-sum-fmt "->>,>>9.99":U
&else
  &scop tara-sum-fmt "->>>,>>>,>>9.99":U
&endif

  view stream out-stream frame BottomFrame .
  run print-header-list-1 in this-procedure .

  for each tt-report-object :
    assign
      v-ost-gds-1   = v-ost-gds-1  + tt-report-object.ost-gds-sum-1
      v-ost-tara-1  = v-ost-tara-1 + tt-report-object.ost-tara-sum-1
      v-ost-gds-2   = v-ost-gds-2  + tt-report-object.ost-gds-sum-2
      v-ost-tara-2  = v-ost-tara-2 + tt-report-object.ost-tara-sum-2
    .
  end.
    /* остаток на начало */
    display stream out-stream
&if "{&has-name-column}" = "yes" &then
    sym7   substitute("Остаток на &1" , string(x-date-start, "99/99/9999"))   @ v-name
    sym2    p-fmt-align-string( {&none-symbol} , {&col-fmtl-date-l} , "center")  @ tt-report.fact-date
    sym3    p-fmt-align-string( {&none-symbol} , {&col-fmtl-code-l} , "center")  @ tt-report.num-ship
&else
    sym2   x-Date-Start @ tt-report.fact-date
    sym3   "Остаток на "  @ tt-report.num-ship
&endif
      sym4   v-ost-gds-1  @ tt-report.doc-sum
      sym5   v-ost-tara-1 @ tt-report.tara-sum
    sym6
    sym1
    with frame torg29.
    down stream out-stream with frame torg29.
    display stream out-stream
&if "{&has-name-column}" = "yes" &then
     sym7   "Приход "  @ v-name
     sym2    p-fmt-align-string( {&none-symbol} , {&col-fmtl-date-l} , "center") @ tt-report.fact-date
     sym3    p-fmt-align-string( {&none-symbol} , {&col-fmtl-code-l} , "center") @ tt-report.num-ship
&else
    "Приход"  @ tt-report.num-ship
    sym2
    sym3
&endif
    sym4
    sym5
    sym6
    sym1
    with frame torg29.
    down stream out-stream with frame torg29.
    run torg29xl-sheet1-write-line-data ( input substitute("Остаток на &1" , w-date( x-Date-Start ))
                                        , input ""
                                        , input ""
                                        , input string( v-ost-gds-1  )
                                        , input string( v-ost-tara-1 )
                                        , input " ":U
                                        , input " ":U
                                        ) .
    run torg29xl-sheet1-write-line-data ( input "Приход"
                                        , input " ":U
                                        , input " ":U
                                        , input " ":U
                                        , input " ":U
                                        , input " ":U
                                        , input " ":U
                                        ) .
    for each tt-report where tt-report.ext-doc-type = {&income-type}
    break
    by tt-report.break-ext-doc-type
    by tt-report.fact-order /* by tt-report.obj-type  by tt-report.obj-code*/ :
      if first-of(tt-report.break-ext-doc-type)
      and p-ext-doc-type-subtotals
      then do:
        assign
        v-ext-doc-type-doc-sum = 0
        v-ext-doc-type-tara-sum = 0
        .
        display stream out-stream
  &if "{&has-name-column}" = "yes" &then
        sym7
        func-get-name-from-ext-type( tt-report.real-ext-doc-type, no) @ v-name
  &else
        '' @ tt-report.num-ship
  &endif
        sym2
        sym3
        sym4
        sym5
        sym6
        sym1
        with frame torg29.
        down stream out-stream with frame torg29.
        run torg29xl-sheet1-write-line-data ( input func-get-name-from-ext-type( tt-report.real-ext-doc-type, no)
                                            , input ""
                                            , input ""
                                            , input ""
                                            , input ""
                                            , input ""
                                            , input ""
                                            ) .
      end. /*if first-of(tt-report.break-ext-doc-type) then do:*/
      display stream out-stream
&if "{&has-name-column}" = "yes" &then
      sym7
      tt-report.cli-name @ v-name
&else
&endif
      sym2        tt-report.fact-date
      sym3        tt-report.num-ship
      sym4        tt-report.doc-sum
      sym5        tt-report.tara-sum
      sym6        tt-report.buh-1
      sym1
      with frame torg29.
      down stream out-stream with frame torg29.
      run torg29xl-sheet1-write-line-data ( input tt-report.cli-name
                                          , input tt-report.fact-date
                                          , input tt-report.num-ship
                                          , input string(tt-report.doc-sum)
                                          , input string(tt-report.tara-sum)
                                          , input tt-report.buh-1
                                          , input ""
                                          ) .
      assign
        v-total-gds  = v-total-gds  + tt-report.doc-sum
        v-total-tara = v-total-tara + tt-report.tara-sum
      v-ext-doc-type-doc-sum = v-ext-doc-type-doc-sum + tt-report.doc-sum
      v-ext-doc-type-tara-sum = v-ext-doc-type-tara-sum + tt-report.tara-sum
      .
      if p-break-by-cp
      and tt-report.real-ext-doc-type = {&tdedt_vozvrat_vnesh_kass} then do:
        display stream out-stream
&if "{&has-name-column}" = "yes" &then
       sym7
       "В т.ч.по типам касс.плат." @ v-name
        sym3
&else
        sym3 "В т.ч.по типам касс.плат." @ tt-report.doc-code
&endif
        sym2
        sym4
        sym5
        sym6
        sym1
        with frame torg29.
        down stream out-stream with frame torg29.
        v-ii = 0.
        run torg29xl-sheet1-write-line-data ( input "В т.ч.по типам касс.плат."
                                            , input ""
                                            , input ""
                                            , input ""
                                            , input ""
                                            , input ""
                                            , input ""
                                            ) .
        for each doc_temp-cp where
                doc_temp-cp.doc-code = tt-report.doc-code
            and doc_temp-cp.gds-code = 0,
            first buf_cash-pay no-lock where
                  buf_cash-pay.cdpay-code = doc_temp-cp.cdpay-code
              and buf_cash-pay.curr-code = doc_temp-cp.curr-code:
          v-ii = v-ii + 1.
          display stream out-stream
&if "{&has-name-column}" = "yes" &then
          sym7 shiftright(buf_cash-pay.obj-name, {&cp-name-length})  @ v-name
          sym3
&else
          sym3 shiftright(buf_cash-pay.obj-name, {&cp-name-length}) @ tt-report.naum-ship
&endif
          sym2
          sym4 (- doc_temp-cp.sum)   @ tt-report.doc-sum
          sym5
          sym6
          sym1
          with frame torg29.
          down stream out-stream with frame torg29.
          run torg29xl-sheet1-write-line-data ( input shiftright(buf_cash-pay.obj-name, {&cp-name-length})
                                              , input ""
                                              , input ""
                                              , input string(doc_temp-cp.sum)
                                              , input ""
                                              , input ""
                                              , input ""
                                              ) .
        end.
      end.
      if last-of(tt-report.break-ext-doc-type)
      and p-ext-doc-type-subtotals
      then do:
        display stream out-stream
  &if "{&has-name-column}" = "yes" &then
        sym7
        substitute("ИТОГО &1", func-get-name-from-ext-type( tt-report.real-ext-doc-type, no)) @ v-name
        sym2    p-fmt-align-string( {&none-symbol} , {&col-fmtl-date-l} , "center")  @ tt-report.fact-date
        sym3    p-fmt-align-string( {&none-symbol} , {&col-fmtl-code-l} , "center")  @ tt-report.num-ship
  &else
        sym2
        sym3
        "" @ tt-report.num-ship
  &endif
        sym4 v-ext-doc-type-doc-sum   @ tt-report.doc-sum
        sym5 v-ext-doc-type-tara-sum  @ tt-report.tara-sum
        sym6
        sym1
        with frame torg29.
        down stream out-stream with frame torg29.
        run torg29xl-sheet1-write-line-data ( input substitute("ИТОГО &1", func-get-name-from-ext-type( tt-report.real-ext-doc-type, no))
                                            , input {&none-symbol}
                                            , input {&none-symbol}
                                            , input string(v-ext-doc-type-doc-sum)
                                            , input string(v-ext-doc-type-tara-sum)
                                            , input ""
                                            , input ""
                                            ) .
      end. /*if last-of(tt-report.break-ext-doc-type) then do:*/
    end.
    put stream out-stream v-line format "X({&frame-width})" skip.

    display stream out-stream
&if "{&has-name-column}" = "yes" &then
      sym7
      "Итого по приходу"  @ v-name
     sym2    p-fmt-align-string( {&none-symbol} , {&col-fmtl-date-l} , "center") @ tt-report.fact-date
     sym3    p-fmt-align-string( {&none-symbol} , {&col-fmtl-code-l} , "center") @ tt-report.num-ship
&else
      sym2
      sym3  "Итого по приходу"  @ tt-report.num-ship
&endif

      sym4     v-total-gds @ tt-report.doc-sum
      sym5     v-total-tara @ tt-report.tara-sum
      sym6
      sym1
    with frame torg29.
    down stream out-stream with frame torg29.
    put stream out-stream v-line format "X({&frame-width})" skip.
    run torg29xl-write-cell-data in this-procedure ( input {&torg29xl-f_incomegds}  , input string(v-total-gds)  ).
    run torg29xl-write-cell-data in this-procedure ( input {&torg29xl-f_incometara} , input string(v-total-tara) ).

    assign
      v-itog-s-ost-gds  = (v-ost-gds-1 + v-total-gds)
      v-itog-s-ost-tara = (v-ost-tara-1 + v-total-tara)
    .
    display stream out-stream
&if "{&has-name-column}" = "yes" &then
      sym7
      "Итого с остатком" @ v-name
     sym2    p-fmt-align-string( {&none-symbol} , {&col-fmtl-date-l} , "center") @ tt-report.fact-date
     sym3    p-fmt-align-string( {&none-symbol} , {&col-fmtl-code-l} , "center") @ tt-report.num-ship
&else
      sym2
      sym3 "Итого с остатком" @ tt-report.num-ship
&endif

      sym4   v-itog-s-ost-gds @ tt-report.doc-sum
      sym5   v-itog-s-ost-tara @ tt-report.tara-sum
      sym6    sym1
    with frame torg29.
    down stream out-stream with frame torg29.
    put stream out-stream v-line format "X({&frame-width})" skip.
    run torg29xl-write-cell-data in this-procedure ( input {&torg29xl-f_incostgds}  , input string(v-itog-s-ost-gds)  ).
    run torg29xl-write-cell-data in this-procedure ( input {&torg29xl-f_incosttara} , input string(v-itog-s-ost-tara) ).

  /*end.*/
  hide stream out-stream frame BottomFrame .
  page stream out-stream.
  view stream out-stream frame BottomFrame .
  run print-header-list-2 in this-procedure .
  /*for each tt-report-object :*/
    display stream out-stream
&if "{&has-name-column}" = "yes" &then
    sym7
    "Расход" @ v-name
     sym2    p-fmt-align-string( {&none-symbol} , {&col-fmtl-date-l} , "center") @ tt-report.fact-date
     sym3    p-fmt-align-string( {&none-symbol} , {&col-fmtl-code-l} , "center") @ tt-report.num-ship
&else
    sym2
    sym3 "Расход" @ tt-report.num-ship
&endif

    sym4
    sym5
    sym6
    sym1
    with frame torg29.
    down stream out-stream with frame torg29.
    run torg29xl-sheet2-write-line-data ( input "Расход":U
                                        , input " ":U
                                        , input " ":U
                                        , input " ":U
                                        , input " ":U
                                        , input " ":U
                                        , input " ":U
                                        ) .
    assign
      v-total-gds  = 0
      v-total-tara = 0
    .
    for each tt-report  where
    tt-report.ext-doc-type = {&outcome-type}
    break
    by tt-report.break-ext-doc-type
    by tt-report.fact-order
    /* by tt-report.obj-type  by tt-report.obj-code */ :
      if first-of(tt-report.break-ext-doc-type)
      and p-ext-doc-type-subtotals
      then do:
        assign
        v-ext-doc-type-doc-sum = 0
        v-ext-doc-type-tara-sum = 0
        .
        display stream out-stream
  &if "{&has-name-column}" = "yes" &then
        sym7
        func-get-name-from-ext-type( tt-report.real-ext-doc-type, no) @ v-name
  &else
        "" @ tt-report.num-ship
  &endif
        sym2
        sym3
        sym4
        sym5
        sym6
        with frame torg29.
        down stream out-stream with frame torg29.
        run torg29xl-sheet2-write-line-data ( input func-get-name-from-ext-type( tt-report.real-ext-doc-type, no)
                                            , input ""
                                            , input ""
                                            , input ""
                                            , input ""
                                            , input ""
                                            , input ""
                                            ) .
      end. /*if first-of(tt-report.break-ext-doc-type) then do:*/
      display stream out-stream
&if "{&has-name-column}" = "yes" &then
      sym7        tt-report.cli-name @ v-name
&else
&endif
      sym2        tt-report.fact-date
      sym3        tt-report.num-ship
      sym4        tt-report.doc-sum
      sym5        tt-report.tara-sum
      sym6        tt-report.buh-1
      sym1
      with frame torg29.
      down stream out-stream with frame torg29.
      run torg29xl-sheet2-write-line-data ( input tt-report.cli-name
                                          , input tt-report.fact-date
                                          , input tt-report.num-ship
                                          , input string(tt-report.doc-sum)
                                          , input string(tt-report.tara-sum)
                                          , input tt-report.buh-1
                                          , input ""
                                          ) .
      assign
        v-total-gds  = v-total-gds  + tt-report.doc-sum
        v-total-tara = v-total-tara + tt-report.tara-sum
      v-ext-doc-type-doc-sum = v-ext-doc-type-doc-sum + tt-report.doc-sum
      v-ext-doc-type-tara-sum = v-ext-doc-type-tara-sum + tt-report.tara-sum
      .
      if p-break-by-cp
      and tt-report.real-ext-doc-type = {&tdedt_ras_vnesh_kass} then do:
        display stream out-stream
&if "{&has-name-column}" = "yes" &then
        sym7 "В т.ч.по типам касс.плат." @ v-name
        sym3
&else
        sym3 "В т.ч.по типам касс.плат." @ tt-report.num-ship
&endif
        sym2
        sym4
        sym5
        sym6
        sym1
        with frame torg29.
        down stream out-stream with frame torg29.
        run torg29xl-sheet2-write-line-data ( input "В т.ч.по типам касс.плат."
                                            , input ""
                                            , input ""
                                            , input ""
                                            , input ""
                                            , input ""
                                            , input ""
                                            ) .
        v-ii = 0.
        for each doc_temp-cp where
                doc_temp-cp.doc-code = tt-report.doc-code
            and doc_temp-cp.gds-code = 0,
            first buf_cash-pay no-lock where
                  buf_cash-pay.cdpay-code = doc_temp-cp.cdpay-code
              and buf_cash-pay.curr-code = doc_temp-cp.curr-code:
          v-ii = v-ii + 1.
          display stream out-stream
&if "{&has-name-column}" = "yes" &then
          sym7 shiftright(buf_cash-pay.obj-name, {&cp-name-length}) @ v-name
          sym3
&else
          sym3 shiftright(buf_cash-pay.obj-name, {&cp-name-length}) @ tt-report.doc-code
&endif
          sym2
          sym4 doc_temp-cp.sum   @ tt-report.doc-sum
          sym5
          sym6
          sym1
          with frame torg29.
          down stream out-stream with frame torg29.
          run torg29xl-sheet2-write-line-data ( input shiftright(buf_cash-pay.obj-name, {&cp-name-length})
                                              , input ""
                                              , input ""
                                              , input string(doc_temp-cp.sum)
                                              , input ""
                                              , input ""
                                              , input ""
                                              ) .
        end.
      end.
      if last-of(tt-report.break-ext-doc-type)
      and p-ext-doc-type-subtotals
      then do:
        display stream out-stream
  &if "{&has-name-column}" = "yes" &then
        sym7
        substitute("ИТОГО &1", func-get-name-from-ext-type( tt-report.real-ext-doc-type, no)) @ v-name
        sym2    p-fmt-align-string( {&none-symbol} , {&col-fmtl-date-l} , "center")  @ tt-report.fact-date
        sym3    p-fmt-align-string( {&none-symbol} , {&col-fmtl-code-l} , "center")  @ tt-report.num-ship
  &else
        sym2
        sym3
        '' @ tt-report.num-ship
  &endif
        sym4 v-ext-doc-type-doc-sum  @ tt-report.doc-sum
        sym5 v-ext-doc-type-tara-sum @ tt-report.tara-sum
        sym6
        sym1
        with frame torg29.
        down stream out-stream with frame torg29.
        run torg29xl-sheet2-write-line-data ( input substitute("ИТОГО &1", func-get-name-from-ext-type( tt-report.real-ext-doc-type, no))
                                            , input {&none-symbol}
                                            , input {&none-symbol}
                                            , input string(v-ext-doc-type-doc-sum)
                                            , input string(v-ext-doc-type-tara-sum)
                                            , input ""
                                            , input ""
                                            ) .
      end. /*if last-of(tt-report.break-ext-doc-type) then do:*/
    end.
    if x-SET_PAY_TYPE = {&p-sale} then do:
      assign
        v-avt-ovt-gds       = v-itog-s-ost-gds  - (v-total-gds + v-ost-gds-2)
        v-avt-ovt-tara      = v-itog-s-ost-tara - (v-total-tara + v-ost-tara-2)
      .
    end.
    else do:
      assign
        v-avt-ovt-gds       = 0
        v-avt-ovt-tara      = 0
      .
    end.

    assign
      v-total-gds         = v-total-gds  + v-avt-ovt-gds
      v-total-tara        = v-total-tara + v-avt-ovt-tara
    .
    if x-SET_PAY_TYPE = {&p-sale} and ( v-avt-ovt-gds <> 0 or v-avt-ovt-tara <> 0 ) then do:
      put stream out-stream v-line format "X({&frame-width})" skip.
      display stream out-stream
&if "{&has-name-column}" = "yes" &then
      sym7 "Автоматическая переоценка" @ v-name
     sym2    p-fmt-align-string( {&none-symbol} , {&col-fmtl-date-l} , "center") @ tt-report.fact-date
     sym3    p-fmt-align-string( {&none-symbol} , {&col-fmtl-code-l} , "center") @ tt-report.num-ship
&else
      sym2
      sym3  "Автоматическая переоценка" @ tt-report.num-ship
&endif

        sym4   v-avt-ovt-gds @ tt-report.doc-sum
        sym5   v-avt-ovt-tara @ tt-report.tara-sum
      sym6
      sym1
      with frame torg29.
      down stream out-stream with frame torg29.
      run torg29xl-sheet2-write-line-data ( input "Автоматическая переоценка":U
                                          , input ""
                                          , input ""
                                          , input string(v-avt-ovt-gds)
                                          , input string(v-avt-ovt-tara)
                                          , input ""
                                          , input ""
                                          ) .
    end.
    put stream out-stream v-line format "X({&frame-width})" skip.

    display stream out-stream
&if "{&has-name-column}" = "yes" &then
    sym7 "Итого по расходу" @ v-name
    sym2    p-fmt-align-string( {&none-symbol} , {&col-fmtl-date-l} , "center") @ tt-report.fact-date
    sym3    p-fmt-align-string( {&none-symbol} , {&col-fmtl-code-l} , "center") @ tt-report.num-ship
&else
    sym2
    sym3  "Итого по расходу" @ tt-report.num-ship
&endif

      sym4     v-total-gds @ tt-report.doc-sum
      sym5     v-total-tara @ tt-report.tara-sum
    sym6
    sym1
    with frame torg29.
    down stream out-stream with frame torg29.
    put stream out-stream v-line format "X({&frame-width})" skip.
    display stream out-stream
&if "{&has-name-column}" = "yes" &then
    sym7   substitute("Остаток на &1" , string(x-date-end, "99/99/9999"))   @ v-name
    sym2    p-fmt-align-string( {&none-symbol} , {&col-fmtl-date-l} , "center")  @ tt-report.fact-date
    sym3    p-fmt-align-string( {&none-symbol} , {&col-fmtl-code-l} , "center")  @ tt-report.num-ship
&else
    sym2      x-Date-End    @ tt-report.fact-date
    sym3      "Остаток на " @ tt-report.num-ship
&endif
      sym4      v-ost-gds-2   @ tt-report.doc-sum
      sym5      v-ost-tara-2  @ tt-report.tara-sum
    sym6
    sym1
    with frame torg29.
    down stream out-stream with frame torg29.
    put stream out-stream v-line format "X({&frame-width})" skip(2).
    run torg29xl-write-cell-data in this-procedure ( input {&torg29xl-f_expgds}       , input string(v-total-gds)  ).
    run torg29xl-write-cell-data in this-procedure ( input {&torg29xl-f_exptara}      , input string(v-total-tara) ).
    run torg29xl-write-cell-data in this-procedure ( input {&torg29xl-f_expostdateend}, input substitute("Остаток на &1 " , w-date(x-Date-End) )  ).
    run torg29xl-write-cell-data in this-procedure ( input {&torg29xl-f_expostgds}    , input string(v-ost-gds-2)  ).
    run torg29xl-write-cell-data in this-procedure ( input {&torg29xl-f_exposttara}   , input string(v-ost-tara-2) ).

  /*end.*/
  run print-footer-list-2 in this-procedure .
  hide stream out-stream frame BottomFrame .
end.

end procedure. /* print-report */

/* ==================================================================================================================== */
function w-date returns character ( input p-date as date ) .
/* Переводит дату в строку с месяцем прописью  01.01.2005 -> 01 января 2006 г. */
do
on error undo, return error
:
  define variable month-str as character init "января;февраля;марта;апреля;мая;июня;июля;августа;сентября;октября;ноября;декабря":U no-undo.

  return ( string( DAY( p-date ) ) + " " + entry( month( p-date ) , month-str , ";" ) + " " + string( year( p-date ) ) + " г." ).

end.
end function. /* w-date */

procedure break-by-cp-prep :
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-fact-order-1 as decimal no-undo .
define input parameter p-fact-order-2 as decimal no-undo .

define buffer buf_ot-tot for ub.ot-tot.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_temp-inkas for temp-inkas.
define buffer buf_goods for ub.goods.
define buffer buf_temp-cp for temp-cp.
define buffer buf_chk-gds-pay for ub.chk-gds-pay.
define buffer buf_bar-code for ub.bar-code.
if p-obj-type = {&stock} then return.
for each buf_ot-tot no-lock where
        buf_ot-tot.obj-type = p-obj-type
    and buf_ot-tot.obj-code = p-obj-code
    and buf_ot-tot.fact-order >= p-fact-order-1
    and buf_ot-tot.fact-order <= p-fact-order-2:
  case buf_ot-tot.ext-doc-type:
    when  {&tdedt_ras_vnesh_kass} then do:
      find first buf_temp-inkas no-lock where
                buf_temp-inkas.inkas-code = buf_ot-tot.doc-code no-error.
      if not available buf_temp-inkas then do:
        run rep/rpychk0.p ( input "r-trg29d"
                            ,input p-obj-type
                            ,input p-obj-code
                            ,input ? /*p-date-from*/
                            ,input ? /*p-date-to*/
                            ,input ? /*p-shift-date-from*/
                            ,input ? /*p-shift-date-to*/
                            ,input ? /*p-shift-num-start*/
                            ,input ? /*p-shift-num-end*/
                            ,input buf_ot-tot.doc-code /*p-inkas-code*/
                            ) no-error.
        create buf_temp-inkas.
        assign
        buf_temp-inkas.inkas-code = buf_ot-tot.doc-code
        buf_temp-inkas.ras-doc-code = buf_ot-tot.doc-code
        buf_temp-inkas.obj-type = p-obj-type
        buf_temp-inkas.obj-code = p-obj-code
        .
      end.
    end.
    when {&tdedt_vozvrat_vnesh_kass}   then do:
      find first buf_trn-doc no-lock where
               buf_trn-doc.doc-code = buf_ot-tot.doc-code no-error.
      if available buf_trn-doc then do:
        find first buf_temp-inkas no-lock where
                  buf_temp-inkas.inkas-code = buf_trn-doc.out-code
             no-error.
        if not available buf_temp-inkas then do:
          run rep/rpychk0.p ( input "r-trg29d"
                              ,input p-obj-type
                              ,input p-obj-code
                              ,input ? /*p-date-from*/
                              ,input ? /*p-date-to*/
                              ,input ? /*p-shift-date-from*/
                              ,input ? /*p-shift-date-to*/
                              ,input ? /*p-shift-num-start*/
                              ,input ? /*p-shift-num-end*/
                              ,input buf_ot-tot.doc-code /*p-inkas-code*/
                              ) no-error.
          create buf_temp-inkas.
          assign
          buf_temp-inkas.inkas-code = buf_trn-doc.out-code
          buf_temp-inkas.ras-doc-code = buf_trn-doc.out-code
          buf_temp-inkas.ret-doc-code = buf_ot-tot.doc-code
          buf_temp-inkas.obj-type = p-obj-type
          buf_temp-inkas.obj-code = p-obj-code
          .
        end.
        else do:
          assign
          buf_temp-inkas.ret-doc-code = buf_ot-tot.doc-code
          .
        end.
      end.
    end.
  end case.
end. /*for each buf_ot-tot no-lock where*/
define variable v-exp as logical   no-undo .
define variable v-inc as logical   no-undo .
for each buf_temp-inkas where
       buf_temp-inkas.obj-type = p-obj-type
   and buf_temp-inkas.obj-code = p-obj-code
 break
 by buf_temp-inkas.inkas-code:
  if first-of(buf_temp-inkas.inkas-code) then do:
    for each buf_chk-gds-pay no-lock where
        buf_chk-gds-pay.out-code = buf_temp-inkas.inkas-code,
    first buf_bar-code no-lock where
          buf_bar-code.b-code = buf_chk-gds-pay.b-code :
      if buf_chk-gds-pay.algo-num <> {&current-algo-1} then next.
      if num-entries(buf_chk-gds-pay.line-type, {&delim-par}) > 1 then do:
        if entry(2, buf_chk-gds-pay.line-type, {&delim-par}) = {&TDEDT_Ras_Vnesh_kass} then do:
          assign
          v-exp = yes
          v-inc = no
          .
        end.
        if entry(2, buf_chk-gds-pay.line-type, {&delim-par}) = {&TDEDT_Vozvrat_Vnesh_kass} then do:
          assign
          v-exp = no
          v-inc = yes
          .
        end.
      end.
      else do:
        define buffer buf_chk-doc for ub.chk-doc.
        find first buf_chk-doc no-lock where
        buf_chk-doc.doc-code = buf_chk-gds-pay.doc-code .
        assign
        v-exp = lookup(string(buf_chk-doc.chk-type), {&sale-out-receipt-codes}) > 0
        v-inc = lookup(string(buf_chk-doc.chk-type), {&sale-in-receipt-codes}) > 0
        .
      end.
      if v-exp then do:
    find first buf_temp-cp where
              buf_temp-cp.doc-code = buf_temp-inkas.ras-doc-code
          and buf_temp-cp.gds-code = buf_bar-code.gds-code
          and buf_temp-cp.cdpay-code = buf_chk-gds-pay.pay-code
          and buf_temp-cp.curr-code = buf_chk-gds-pay.curr-code no-error.
    if not available buf_temp-cp then do:
      create buf_temp-cp.
      assign
      buf_temp-cp.doc-code = buf_temp-inkas.ras-doc-code
      buf_temp-cp.gds-code = buf_bar-code.gds-code
      buf_temp-cp.cdpay-code = buf_chk-gds-pay.pay-code
      buf_temp-cp.curr-code = buf_chk-gds-pay.curr-code
      .
    end .

        assign
          buf_temp-cp.eff-doc-qnty =  buf_temp-cp.eff-doc-qnty + buf_chk-gds-pay.eff-doc-qnty
          buf_temp-cp.tot-rb = buf_temp-cp.tot-rb + buf_chk-gds-pay.tot-r-b
        .
  end.
      if v-inc then do:
    find first buf_temp-cp where
                  buf_temp-cp.doc-code = buf_temp-inkas.ret-doc-code
          and buf_temp-cp.gds-code = buf_bar-code.gds-code
          and buf_temp-cp.cdpay-code = buf_chk-gds-pay.pay-code
          and buf_temp-cp.curr-code = buf_chk-gds-pay.curr-code no-error.
    if not available buf_temp-cp then do:
      create buf_temp-cp.
      assign
          buf_temp-cp.doc-code = buf_temp-inkas.ret-doc-code
      buf_temp-cp.gds-code = buf_bar-code.gds-code
      buf_temp-cp.cdpay-code = buf_chk-gds-pay.pay-code
      buf_temp-cp.curr-code = buf_chk-gds-pay.curr-code
      .
    end.
        assign
          buf_temp-cp.eff-doc-qnty =  buf_temp-cp.eff-doc-qnty + buf_chk-gds-pay.eff-doc-qnty
          buf_temp-cp.tot-rb = buf_temp-cp.tot-rb + buf_chk-gds-pay.tot-r-b
        .
end.
    end. /*for each buf_chk-gds-pay no-lock where*/
  end. /*fi first-of*/
end. /*for each buf_temp-inkas.*/
end procedure. /* break-by-cp */

procedure process-covered-techrfsl :
define parameter buffer buf_trn-doc for ub.trn-doc.
define variable v-covered as logical no-undo .
define variable v-doc-qnty as decimal no-undo .
define buffer buf2_trn-doc for ub.trn-doc.
define buffer buf_sale-doc for ub.sale-doc.
define buffer buf2_sale-doc for ub.sale-doc.



do
on error undo, return error
:

  /*найдем не списание ли это по техпроливу*/
  
  def var v-value as character no-undo.
  def var v-type  as character no-undo.
  def var v-tech-pass as logical no-undo.
  { str/tdat-val.i                                    
    buf_trn-doc.doc-code
    {&trdcattr-techpass}
    v-value 
    v-type 
    no-error
  }
  assign
    v-tech-pass = yes when v-value = "yes".
  
  find first buf_sale-doc no-lock where
            buf_sale-doc.doc-code = buf_trn-doc.doc-code
        and buf_sale-doc.doc-kind = {&sale-add-tech-refuell} no-error.
  if available buf_sale-doc then do:
    for each buf2_sale-doc no-lock where
            buf2_sale-doc.inkas-code = buf_sale-doc.inkas-code
        and buf2_sale-doc.doc-kind = {&sale-add2-in-tech-refuell} ,
        first buf2_trn-doc no-lock where
              buf2_trn-doc.doc-code = buf2_sale-doc.doc-code:
      assign
      v-covered = (buf2_trn-doc.fact-qnty = buf2_trn-doc.doc-qnty) and v-covered
      v-doc-qnty = v-doc-qnty + buf2_trn-doc.fact-qnty
      .
    end.
    v-covered = (v-doc-qnty = buf_sale-doc.doc-qnty).

    if v-covered then do:
      for each buf2_sale-doc no-lock where
              buf2_sale-doc.inkas-code = buf_sale-doc.inkas-code
          and buf2_sale-doc.doc-kind = {&sale-add2-in-tech-refuell}:
        create tt-ignore-docs.
        assign
        tt-ignore-docs.doc-code = buf2_sale-doc.doc-code.
        release tt-ignore-docs.
      end.
      create tt-ignore-docs.
      assign
      tt-ignore-docs.doc-code = buf_trn-doc.doc-code.
    end. /*if v-covered then do:*/
  end. /*if v-exist-techrfsl-write-off then do:*/
end.
end procedure. /* process-covered-techrfsl */