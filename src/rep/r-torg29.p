/*

$Revision: d862744f2b63, 1905, rls $
$Author: EShklyar $
$Date: Fri Jun 07 16:26:46 2019 +0300 $
$Workfile: r-torg29.p $
$Archive: rep/r-torg29.p $

Форма ТОРГ-29

Автор: Хныкин Павел Андреевич
Дата создания: 10/17/07
Author: Pavel Khnykin
Creation date: 10/17/07

*/
using Ibs.Th.Gbl.ProgressBar.
block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: d862744f2b63, 1905, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Fri Jun 07 16:26:46 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-torg29.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-torg29.p $":U .
define variable vss-description as character no-undo init "Форма ТОРГ-29".
{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/r-page1.i      }
{ cmp/r-pril.i       }
{ rep/r-sym.i        }
{ trg/factord.i      }
{ gbl/waitfram.i     }
{ rep/p-fmt.i        }
{ rep/lkp-font.i     }
{ rep/ost-line.i     }
{ ref/grplibfn.i     }
{ rep/fmtcli.i       }
{ gbl/paramls.i      }
define variable parparentproc  as handle  no-undo .
define variable g#report-num   as integer no-undo .
assign
  parparentproc = my-handle
.
run get-report-num in my-handle (output g#report-num).
{ rep/torg29xl.i     }
{ gbl/getcntxt.i def }


define temp-table tt-goods no-undo like ub.goods.

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
  field fact-order    as decimal
  field fact-date     as date
  field gds-code      like ub.goods.gds-code
  field doc-code      like ub.trn-doc.doc-code
  field gds-name      as character
  field gds-sum       as decimal
  field tara-sum      as decimal
  field fact-date-str as character
  field gds-sum-str   as character
  field tara-sum-str  as character
  field buh-1         as character
  field buh-2         as character
  field obj-type      like ub.clients.obj-type
  field obj-code      like ub.clients.obj-code
index pi is primary unique
  obj-type
  obj-code
  ext-doc-type
  doc-code
  gds-code
index fo fact-order
index exdoc ext-doc-type
index gds
  gds-code
  fact-order
  obj-type
  obj-code
.

define stream out-stream.

define variable v-fact-order-1           as decimal   no-undo .
define variable v-fact-order-2           as decimal   no-undo .
define variable v-curr-r-b               as character no-undo .
define variable v-line                   as character no-undo .
define variable v-print-rubl             as logical   no-undo .
define variable v-gds-counter            as integer   no-undo .
define variable v-host-code-1 like ub.clients.host-code no-undo .
define variable v-host-code-2 like ub.clients.host-code no-undo .

&scop income-type "inc":U
&scop outcome-type "out":U


&scop frame-width 128
&scop col-fmtl-1 "X(30)":U
&scop col-fmtl-2 "X(10)":U
&scop col-fmtl-3 "X(20)":U
&scop col-fmtl-4 "X(15)":U
&scop col-fmtl-5 "X(15)":U
&scop col-fmtl-6 "X(15)":U
&scop col-fmtl-7 "X(15)":U
&scop col-fmtlw-1 30
&scop col-fmtlw-2 10
&scop col-fmtlw-3 20
&scop col-fmtlw-4 15
&scop col-fmtlw-5 15
&scop col-fmtlw-6 15
&scop col-fmtlw-7 15

&scop none-symbol "---":U
&scop none-symbol-2 "X":U

function w-date returns character ( input p-date as date ) forward .

define frame torg29
  sym1                            no-label format "X(1)"                          space(0)
  tt-report.gds-name              no-label format {&col-fmtl-1}                   space(0)
  sym2                            no-label format "X(1)"                          space(0)
  tt-report.fact-date-str         no-label format {&col-fmtl-2}                   space(0)
  sym3                            no-label format "X(1)"                          space(0)
  tt-report.doc-code              no-label format {&col-fmtl-3}                   space(0)
  sym4                            no-label format "X(1)"                          space(0)
  tt-report.gds-sum-str           no-label format {&col-fmtl-4}                   space(0)
  sym5                            no-label format "X(1)"                          space(0)
  tt-report.tara-sum-str          no-label format {&col-fmtl-5}                   space(0)
  sym6                            no-label format "X(1)"                          space(0)
  tt-report.buh-1                 no-label format {&col-fmtl-6}                   space(0)
  sym7                            no-label format "X(1)"                          space(0)
  tt-report.buh-2                 no-label format {&col-fmtl-7}                   space(0)
  sym8                            no-label format "X(1)"                          space(0)
header
    ":------------------------------:----------:--------------------:---------------:---------------:-------------------------------:":U skip
    ":               1              :     2    :          3         :       4       :       5       :       6       :        7      :":U skip
with width {&frame-width} down stream-io no-label no-box.

form header
        v-line format "X(128)" at 1 SKIP
        "Продолжение - на следующей странице" at 1 SKIP
with frame BottomFrame width {&A4_LS} PAGE-BOTTOM NO-LABELS NO-BOX .


do on error undo, return error return-value
:
  { gbl/working.i }
  run clear-tt in this-procedure .
  { gbl/getcntxt.i get }
  assign
    v-line = fill( "-" , 300 )
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
      if x-SET_PAY_TYPE <> {&p-crsa} then do:
        message "Неизвестный тип валюты!" skip "Отчет формируется в базовой валюте" view-as alert-box information .
      end.
      { gbl/curr-r-b.i v-curr-r-b }
      assign
        v-print-rubl = ( v-curr-r-b = {&r-b-rubl} )
      .
    end.
  end case.

  find first obj-list no-error .
  if not available obj-list then do:
    message
      "Не указан объект для формирования отчета!"
    view-as alert-box error.
    undo, return error.
  end.
  { gbl/hostcode.i obj-list.obj-type obj-list.obj-code v-host-code-1 }
  for each obj-list :
    { gbl/hostcode.i obj-list.obj-type obj-list.obj-code v-host-code-2 }
    if v-host-code-1 <> v-host-code-2 then do:
      message
        "Отчет формируется по объектом одной фирмы!"
      view-as alert-box error.
      undo, return error.
    end.
  end.

  /*Поиск нач fact-order*/
  run day-begin-fact-order in this-procedure ( input x-Date-Start , output v-fact-order-1 ).
  /*Поиск посл fact-order*/
  run day-begin-fact-order in this-procedure ( input ( x-Date-End + 1 ) , output v-fact-order-2 ).

  run get-report-num in parparentproc (output g#report-num).
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
  message
    "Не найдена фирма с кодом " v-host-code-1 skip
    "Отчет не может быть сформирован"
  view-as alert-box error.
  return error.
end.
for each obj-list :
  assign
    v-obj-list = v-obj-list + obj-list.obj-name + ','
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

  if v-length > 31
  then do:
    assign
      v-result = substring( v-str , 1 , 31 )
    .
  end.
  else do:
    assign
      v-i = center-field( 1, {&field-width}, v-length )
    .
    do v-j = 1 to {&field-width}
    :
      if v-j <> v-i
      then do:
        assign
          v-result = v-result + " "
        .
      end.
      else do:
        assign
          v-result  = v-result + v-str
          v-j       = v-j + length(v-str) - 1
        .
      end.
    end.
  end.

  put stream out-stream unformatted
               "--------------------------------------------------------------------------------------------------------------------------------":U skip
    substitute( ":          Наименование        :            Документ           :&1:              Отметки          :":U
              , v-result
              ) skip
               ":                              :-------------------------------:-------------------------------:            бухгалтерии        :":U skip
               ":                              :    дата  :        номер       :     товара    :       тары    :                               :":U skip
 .


end.

end procedure. /* print-table-header */


procedure print-footer-list-2 :

do
on error undo, return error return-value
:


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

  define variable v-curr-grp-name as character            no-undo .
  define variable v-host-code     like ub.clients.host-code  no-undo .
do
on error undo, return error return-value
:
  run waitfram-show in this-procedure ( "Формирование списка товаров..." ) .
  empty temp-table tt-goods.
  case x-SelectGood :
    when {&g-all} then do: /* все товары */
      for each buf_goods no-lock
        where buf_goods.stts = 0
      :
        create tt-goods.
        buffer-copy buf_goods to tt-goods.
        assign
          v-gds-counter = v-gds-counter + 1
        .
      end.
    end.
    when {&g-grp} then do: /* товары по группам  */
      for each tmp#grp no-lock
      :
        run grplib-get-full-name in this-procedure( input tmp#grp.node-code, output v-curr-grp-name ) .
        for each buf_goods no-lock
              where buf_goods.grp-name begins v-curr-grp-name
        :
          find first tt-goods no-lock
            where tt-goods.artic     = buf_goods.artic
              and tt-goods.prod-type = buf_goods.prod-type
              and tt-goods.prod-code = buf_goods.prod-code
            no-error .
          if not available tt-goods then do:
            create tt-goods.
            buffer-copy buf_goods to tt-goods.
            assign
              v-gds-counter = v-gds-counter + 1
            .
          end.
        end.
      end.
    end.
    when {&g-prod} then do: /* товары по производителю */
      for each buf_goods no-lock
        where buf_goods.stts = 0 ,
          each buf_cli-gds no-lock
            where buf_cli-gds.prod-type = buf_goods.prod-type
              and buf_cli-gds.prod-code = buf_goods.prod-code
              and buf_cli-gds.artic     = buf_goods.artic ,
          first g#cli
            where g#cli.obj-type = buf_cli-gds.cli-type
              and g#cli.obj-code = buf_cli-gds.cli-code
      :
        find first tt-goods no-lock
          where tt-goods.prod-type = buf_goods.prod-type
            and tt-goods.prod-code = buf_goods.prod-code
            and tt-goods.artic     = buf_goods.artic
        no-error.
        if not available tt-goods then do:
          create tt-goods.
          buffer-copy buf_goods to tt-goods no-error.
          assign
            v-gds-counter = v-gds-counter + 1
          .
        end.
      end.
    end.
    when {&g-choice} or when {&g-one} then do: /* товары выборочно */
      for each gds-list :
        find first buf_goods no-lock
          where buf_goods.gds-code = gds-list.gds-code
        no-error .
        if available buf_goods then do:
          create tt-goods.
          buffer-copy buf_goods to tt-goods.
          assign
            v-gds-counter = v-gds-counter + 1
          .
        end.
      end.
    end.
    when {&g-grp-prod} then do: /* группа и производитель */
      for each tmp#grp no-lock
      :
        run grplib-get-full-name in this-procedure( input tmp#grp.node-code, output v-curr-grp-name ) .
        for each buf_goods no-lock
              where buf_goods.grp-name begins v-curr-grp-name
        :
          find first tt-goods no-lock
            where tt-goods.artic     = buf_goods.artic
              and tt-goods.prod-type = buf_goods.prod-type
              and tt-goods.prod-code = buf_goods.prod-code
            no-error .
          if not available tt-goods then do:
            create tt-goods.
            buffer-copy buf_goods to tt-goods no-error.
            assign
              v-gds-counter = v-gds-counter + 1
            .
          end.
        end.
      end.
      for each buf_goods no-lock
        where buf_goods.stts = 0 ,
          each buf_cli-gds no-lock
            where buf_cli-gds.prod-type = buf_goods.prod-type
              and buf_cli-gds.prod-code = buf_goods.prod-code
              and buf_cli-gds.artic     = buf_goods.artic ,
          first g#cli
            where g#cli.obj-type = buf_cli-gds.cli-type
              and g#cli.obj-code = buf_cli-gds.cli-code
      :
        find first tt-goods no-lock
          where tt-goods.prod-type = buf_goods.prod-type
            and tt-goods.prod-code = buf_goods.prod-code
            and tt-goods.artic     = buf_goods.artic
        no-error.
        if not available tt-goods then do:
          create tt-goods.
          buffer-copy buf_goods to tt-goods no-error.
          assign
            v-gds-counter = v-gds-counter + 1
          .
        end.
      end.
    end.
  end case.
  run waitfram-hide in this-procedure .
end.

end procedure. /* create-tt-goods */

/* ==================================================================================================================== */
procedure create-report :

  define buffer buf_gds-obj   for ub.gds-obj.
  define buffer buf_trn-doc   for ub.trn-doc.
  define buffer buf_doc-line  for ub.doc-line.
  define buffer buf_ot-line   for ub.ot-line.
  define buffer buf_obj-list  for obj-list.
  define buffer tt_report     for tt-report .
  
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

  define variable var-x-artic         like ub.stk-line.artic        no-undo.
  define variable var-x-prod-code     like ub.stk-line.prod-code    no-undo.
  define variable var-x-prod-type     like ub.stk-line.prod-type    no-undo.

  define variable var-SLT_R           like ub.stk-tot.sum-rubl    no-undo.
  define variable var-SLT_V           like ub.stk-tot.sum-rubl    no-undo.


  define variable v-ost-gds-1         as decimal   no-undo .
  define variable v-ost-tara-1        as decimal   no-undo .
  define variable v-ost-gds-2         as decimal   no-undo .
  define variable v-ost-tara-2        as decimal   no-undo .
  define variable v-ost-qnty          as decimal   no-undo .
  define variable v-counter           as integer   no-undo .
  define variable v-doc-date          as date      no-undo .
  define variable v-prg               as class ProgressBar no-undo .
  define variable v-none-sym-1        as character no-undo .
  define variable v-none-sym-2        as character no-undo .

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
  assign
    v-none-sym-1 = p-fmt-align-string( {&none-symbol} , {&col-fmtlw-4} , "center")
    v-none-sym-2 = p-fmt-align-string( {&none-symbol} , {&col-fmtlw-5} , "center")
  .
  for each obj-list :
    v-prg = new ProgressBar( 1 , v-gds-counter ).
    assign
      v-prg:frame-title = obj-list.obj-name
      v-prg:fg-color = 9
    .
    v-prg:show-bar().
    /* по всем товарам объекта */
    _goods-loop:
    for each tt-goods
    :
      v-prg:increment().
      find first buf_gds-obj no-lock
          where buf_gds-obj.obj-type  = obj-list.obj-type
            and buf_gds-obj.obj-code  = obj-list.obj-code
            and buf_gds-obj.artic     = tt-goods.artic
            and buf_gds-obj.prod-type = tt-goods.prod-type
            and buf_gds-obj.prod-code = tt-goods.prod-code
      no-error .
      if not available buf_gds-obj then do:
        next _goods-loop.
      end.
      /* собираем остатки по товару на объекте */
      assign
        var-x-store-code  = obj-list.obj-code
        var-x-store-type  = obj-list.obj-type
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
          input   no                  ,
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
      assign
        v-ost-gds-1 = v-ost-gds-1 + ( if v-print-rubl = yes then var-Coast_R else var-Coast_V )
      .
      RUN ost-line in this-procedure (
          input   var-x-store-code    ,
          input   var-x-store-type    ,
          input   var-x-artic         ,
          input   var-x-prod-code     ,
          input   var-x-prod-type     ,
          input   no                  ,
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
      assign
        v-ost-gds-2 = v-ost-gds-2 + ( if v-print-rubl = yes then var-Coast_R else var-Coast_V )
      .
      _ot-line:
      for each buf_ot-line no-lock
          where buf_ot-line.obj-type     = obj-list.obj-type
            and buf_ot-line.obj-code     = obj-list.obj-code
            and buf_ot-line.artic        = tt-goods.artic
            and buf_ot-line.prod-type    = tt-goods.prod-type
            and buf_ot-line.prod-code    = tt-goods.prod-code
            and buf_ot-line.fact-order   >= v-fact-order-1  /* fact-order начала периода */
            and buf_ot-line.fact-order   <= v-fact-order-2  /* fact-order конца периода */
            and buf_ot-line.sum-type     = var-x-sum-type
      :
        /* не выводим документы у которых контрагент в списке объектов */
        find first buf_trn-doc no-lock
          where buf_trn-doc.doc-code = buf_ot-line.doc-code
        no-error .
        if available buf_trn-doc then do:
           find first buf_obj-list no-lock
            where buf_obj-list.obj-type = buf_trn-doc.cli-type
              and buf_obj-list.obj-code = buf_trn-doc.cli-code
           no-error .
           if available buf_obj-list then do:
            next _ot-line.
           end.
        end.

        case buf_ot-line.ext-doc-type :
          /* ПРИХОД */
          when {&TDEDT_Pri_Vnesh}           or
          when {&TDEDT_Pri_Perem}           or
          when {&TDEDT_Vozvrat_Perem}       or
          when {&TDEDT_Pri_Prvo}
          then do:
            if x-SET_PAY_TYPE = {&p-sale} then next _ot-line.
          find first tt_report where 
              tt_report.ext-doc-type = {&income-type}
          and tt_report.obj-type      = obj-list.obj-type
          and tt_report.obj-code      = obj-list.obj-code
          and tt_report.doc-code      = buf_ot-line.doc-code
          and tt_report.gds-code      = tt-goods.gds-code no-error .
          if not available (tt_report) then do:
            create tt_report.
            assign
              tt_report.ext-doc-type = {&income-type}
              tt_report.obj-type      = obj-list.obj-type
              tt_report.obj-code      = obj-list.obj-code
              tt_report.doc-code      = buf_ot-line.doc-code
              tt_report.gds-code      = tt-goods.gds-code
            .
          end.  
          end.
          when {&tdedt_vozvrat_vnesh}       or
          when {&tdedt_vozvrat_vnesh_kass}
          then do:
          find first tt_report where 
              tt_report.ext-doc-type = {&income-type}
          and tt_report.obj-type      = obj-list.obj-type
          and tt_report.obj-code      = obj-list.obj-code
          and tt_report.doc-code      = buf_ot-line.doc-code
          and tt_report.gds-code      = tt-goods.gds-code no-error .
          if not available (tt_report) then do:
            create tt_report.
            assign
              tt_report.ext-doc-type = {&income-type}
              tt_report.obj-type      = obj-list.obj-type
              tt_report.obj-code      = obj-list.obj-code
              tt_report.doc-code      = buf_ot-line.doc-code
              tt_report.gds-code      = tt-goods.gds-code
            .
          end.  
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
          find first tt_report where 
              tt_report.ext-doc-type = {&outcome-type}
          and tt_report.obj-type      = obj-list.obj-type
          and tt_report.obj-code      = obj-list.obj-code
          and tt_report.doc-code      = buf_ot-line.doc-code
          and tt_report.gds-code      = tt-goods.gds-code no-error .
          if not available (tt_report) then do:
            create tt_report.
            assign
              tt_report.ext-doc-type = {&outcome-type}
              tt_report.obj-type      = obj-list.obj-type
              tt_report.obj-code      = obj-list.obj-code
              tt_report.doc-code      = buf_ot-line.doc-code
              tt_report.gds-code      = tt-goods.gds-code
            .
          end.              
          end.
          when {&TDEDT_Inv}               or
          when {&TDEDT_Peresort}          or
          when {&TDEDT_Overturn}          or
          when {&TDEDT_Corr_Acc_Price}    or
          when {&TDEDT_Corr_Minus_Parts}
          then do:
            if x-SET_PAY_TYPE = {&p-sale} then next _ot-line.
          if ( buf_ot-line.sum-base > 0 or buf_ot-line.sum-rubl > 0 ) then 
          do:
            find first tt_report where 
              tt_report.ext-doc-type = {&income-type}
              and tt_report.obj-type      = obj-list.obj-type
              and tt_report.obj-code      = obj-list.obj-code
              and tt_report.doc-code      = buf_ot-line.doc-code
              and tt_report.gds-code      = tt-goods.gds-code no-error .
            if not available (tt_report) then 
            do:
              create tt_report.
              assign
                tt_report.ext-doc-type = {&income-type}
                tt_report.obj-type     = obj-list.obj-type
                tt_report.obj-code     = obj-list.obj-code
                tt_report.doc-code     = buf_ot-line.doc-code
                tt_report.gds-code     = tt-goods.gds-code
                .
            end.
          end.
          else 
          do:
            find first tt_report where 
              tt_report.ext-doc-type = {&outcome-type}
              and tt_report.obj-type      = obj-list.obj-type
              and tt_report.obj-code      = obj-list.obj-code
              and tt_report.doc-code      = buf_ot-line.doc-code
              and tt_report.gds-code      = tt-goods.gds-code no-error .
            if not available (tt_report) then 
            do:
              create tt_report.
              assign
                tt_report.ext-doc-type = {&outcome-type}
                tt_report.obj-type     = obj-list.obj-type
                tt_report.obj-code     = obj-list.obj-code
                tt_report.doc-code     = buf_ot-line.doc-code
                tt_report.gds-code     = tt-goods.gds-code
                .
            end.
          end.                  
        end.

          otherwise do:
            next _ot-line.
          end.
        end case.
        run factord-to-date in this-procedure ( input buf_ot-line.fact-order , output v-doc-date ) .
        assign

          tt_report.fact-order    = buf_ot-line.fact-order
          tt_report.fact-date     = v-doc-date
          tt_report.gds-name      = tt-goods.gds-name
          tt_report.gds-sum       = abs( if v-print-rubl = yes then buf_ot-line.sum-rubl
                                    else buf_ot-line.sum-base )
          tt_report.tara-sum      = 0 /*abs( if v-print-rubl = yes then buf_ot-line.road-tax-rubl*/
                                    /*else buf_ot-line.road-tax-base )*/
          tt_report.fact-date-str = string( v-doc-date , "99.99.9999" )
          tt_report.gds-sum-str   = if tt_report.gds-sum = 0  then v-none-sym-1
                                    else string( tt_report.gds-sum , "->>>,>>>,>>9.99" )
          tt_report.tara-sum-str  = if tt_report.tara-sum = 0  then v-none-sym-2
                                    else string( tt_report.tara-sum , "->>>,>>>,>>9.99")
          tt_report.buh-1         = ""
          tt_report.buh-2         = ""
          v-counter               = v-counter + 1
         .
         release tt_report .
      end. /* for each buf_ot-line */

      if x-SET_PAY_TYPE = {&p-sale} then do:
        _ot-line-sale :
        for each buf_ot-line no-lock
            where buf_ot-line.obj-type     = obj-list.obj-type
              and buf_ot-line.obj-code     = obj-list.obj-code
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
          find first tt_report where 
              tt_report.ext-doc-type = {&outcome-type}
          and tt_report.obj-type      = obj-list.obj-type
          and tt_report.obj-code      = obj-list.obj-code
          and tt_report.doc-code      = buf_ot-line.doc-code
          and tt_report.gds-code      = tt-goods.gds-code no-error .
          if not available (tt_report) then do:
            create tt_report.
            assign
              tt_report.ext-doc-type = {&outcome-type}
              tt_report.obj-type      = obj-list.obj-type
              tt_report.obj-code      = obj-list.obj-code
              tt_report.doc-code      = buf_ot-line.doc-code
              tt_report.gds-code      = tt-goods.gds-code
            .
          end. 
            end.
            when {&TDEDT_Inv}               or
            when {&TDEDT_Peresort}          or
            when {&TDEDT_Overturn}          or
            when {&TDEDT_Corr_Acc_Price}    or
            when {&TDEDT_Corr_Minus_Parts}
            then do:
          if ( buf_ot-line.sum-base > 0 or buf_ot-line.sum-rubl > 0 ) then 
          do:
            find first tt_report where 
              tt_report.ext-doc-type = {&income-type}
              and tt_report.obj-type      = obj-list.obj-type
              and tt_report.obj-code      = obj-list.obj-code
              and tt_report.doc-code      = buf_ot-line.doc-code
              and tt_report.gds-code      = tt-goods.gds-code no-error .
            if not available (tt_report) then 
            do:
              create tt_report.
              assign
                tt_report.ext-doc-type = {&income-type}
                tt_report.obj-type     = obj-list.obj-type
                tt_report.obj-code     = obj-list.obj-code
                tt_report.doc-code     = buf_ot-line.doc-code
                tt_report.gds-code     = tt-goods.gds-code
                .
            end.
          end.
          else 
          do:
            find first tt_report where 
              tt_report.ext-doc-type = {&outcome-type}
              and tt_report.obj-type      = obj-list.obj-type
              and tt_report.obj-code      = obj-list.obj-code
              and tt_report.doc-code      = buf_ot-line.doc-code
              and tt_report.gds-code      = tt-goods.gds-code no-error .
            if not available (tt_report) then 
            do:
              create tt_report.
              assign
                tt_report.ext-doc-type = {&outcome-type}
                tt_report.obj-type     = obj-list.obj-type
                tt_report.obj-code     = obj-list.obj-code
                tt_report.doc-code     = buf_ot-line.doc-code
                tt_report.gds-code     = tt-goods.gds-code
                .
            end.
          end.        
            end.
            otherwise do:
              next _ot-line-sale.
            end.
          end case.
          run factord-to-date in this-procedure ( input buf_ot-line.fact-order , output v-doc-date ) .
          assign
            tt_report.fact-order    = buf_ot-line.fact-order
            tt_report.fact-date     = v-doc-date
            tt_report.gds-name      = tt-goods.gds-name
            tt_report.gds-sum       = abs( if v-print-rubl = yes then buf_ot-line.sum-rubl
                                      else buf_ot-line.sum-base )
            tt_report.tara-sum      = 0 /*abs( if v-print-rubl = yes then buf_ot-line.road-tax-rubl*/
                                      /*else buf_ot-line.road-tax-base )*/
            tt_report.fact-date-str = string( v-doc-date , "99.99.9999" )
            tt_report.gds-sum-str   = if tt_report.gds-sum = 0  then v-none-sym-1
                                      else string( tt_report.gds-sum , "->>>,>>>,>>9.99" )
            tt_report.tara-sum-str  = if tt_report.tara-sum = 0  then v-none-sym-2
                                      else string( tt_report.tara-sum , "->>>,>>>,>>9.99")
            tt_report.buh-1         = ""
            tt_report.buh-2         = ""
            v-counter               = v-counter + 1
          .
          release tt_report .
        end.
      end.
    end. /* for each tt-goods */
    create tt-report-object.
    assign
      tt-report-object.obj-type       = obj-list.obj-type
      tt-report-object.obj-code       = obj-list.obj-code
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
  end. /* for each obj-list */
  for each tt-report :
    if tt-report.gds-sum = 0 and tt-report.tara-sum = 0 then delete tt-report.
  end.
end.

end procedure. /* create-report */

/* ==================================================================================================================== */
procedure print-report :

  define variable v-total-gds         as decimal   no-undo .
  define variable v-total-tara        as decimal   no-undo .
  define variable v-ost-gds-1         as decimal   no-undo .
  define variable v-ost-tara-1        as decimal   no-undo .
  define variable v-ost-gds-2         as decimal   no-undo .
  define variable v-ost-tara-2        as decimal   no-undo .
  define variable v-ost-gds-str-1     as character no-undo .
  define variable v-ost-tara-str-1    as character no-undo .
  define variable v-ost-gds-str-2     as character no-undo .
  define variable v-ost-tara-str-2    as character no-undo .
  define variable v-total-gds-str     as character no-undo .
  define variable v-total-tara-str    as character no-undo .
  define variable v-itog-s-ost-gds    as decimal   no-undo .
  define variable v-itog-s-ost-tara   as decimal   no-undo .
  define variable v-avt-ovt-gds       as decimal   no-undo .
  define variable v-avt-ovt-tara      as decimal   no-undo .
  define variable v-avt-ovt-gds-str   as character no-undo .
  define variable v-avt-ovt-tara-str  as character no-undo .

do
on error undo, return error return-value
:
  &scop gds-sum-fmt "->>>,>>>,>>9.99":U

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
  assign
    v-ost-gds-str-1   = if v-ost-gds-1  = 0 then p-fmt-align-string( {&none-symbol} , {&col-fmtlw-4} , "center")
                        else string( v-ost-gds-1  , {&gds-sum-fmt} )
    v-ost-tara-str-1  = if v-ost-tara-1 = 0 then p-fmt-align-string( {&none-symbol} , {&col-fmtlw-5} , "center")
                        else string( v-ost-tara-1 , {&gds-sum-fmt} )
    v-ost-gds-str-2   = if v-ost-gds-2  = 0 then p-fmt-align-string( {&none-symbol} , {&col-fmtlw-4} , "center")
                        else string( v-ost-gds-2  , {&gds-sum-fmt} )
    v-ost-tara-str-2  = if v-ost-tara-2 = 0 then p-fmt-align-string( {&none-symbol} , {&col-fmtlw-5} , "center")
                        else string( v-ost-tara-2 , {&gds-sum-fmt} )
  .
    /* остаток на начало */
    display stream out-stream
      sym1
      substitute("Остаток на &1" , w-date( x-Date-Start ))  @ tt-report.gds-name
      sym2
      p-fmt-align-string( {&none-symbol-2} , {&col-fmtlw-2} , "center") @ tt-report.fact-date-str
      sym3
      p-fmt-align-string( {&none-symbol-2} , {&col-fmtlw-3} , "center") @ tt-report.doc-code
      sym4
      v-ost-gds-str-1 @ tt-report.gds-sum-str
      sym5
      v-ost-tara-str-1 @ tt-report.tara-sum-str
      sym6
      sym7
      sym8
    with frame torg29.
    down stream out-stream with frame torg29.
    display stream out-stream
      sym1
      p-fmt-align-string( "Приход" , {&col-fmtlw-1} , "center")  @ tt-report.gds-name
      sym2
      sym3
      sym4
      sym5
      sym6
      sym7
      sym8
    with frame torg29.
    down stream out-stream with frame torg29.
    run torg29xl-sheet1-write-line-data ( input substitute("Остаток на &1" , w-date( x-Date-Start ))
                                        , input {&none-symbol-2}
                                        , input {&none-symbol-2}
                                        , input trim( v-ost-gds-str-1  )
                                        , input trim( v-ost-tara-str-1 )
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
    for each tt-report
      where tt-report.ext-doc-type = {&income-type}
    by tt-report.fact-order
    by tt-report.obj-type
    by tt-report.obj-code
    :
      display stream out-stream
        sym1
        tt-report.gds-name
        sym2
        tt-report.fact-date-str
        sym3
        tt-report.doc-code
        sym4
        tt-report.gds-sum-str
        sym5
        tt-report.tara-sum-str
        sym6
        tt-report.buh-1
        sym7
        tt-report.buh-2
        sym8
      with frame torg29.
      down stream out-stream with frame torg29.
      run torg29xl-sheet1-write-line-data ( input tt-report.gds-name
                                          , input tt-report.fact-date-str
                                          , input tt-report.doc-code
                                          , input trim(tt-report.gds-sum-str)
                                          , input trim(tt-report.tara-sum-str)
                                          , input tt-report.buh-1
                                          , input tt-report.buh-2
                                          ) .
      assign
        v-total-gds  = v-total-gds  + tt-report.gds-sum
        v-total-tara = v-total-tara + tt-report.tara-sum
      .
    end.
    put stream out-stream v-line format "X({&frame-width})" skip.
    assign
      v-total-gds-str   = if v-total-gds  = 0 then p-fmt-align-string( {&none-symbol} , {&col-fmtlw-4} , "center")
                          else string( v-total-gds , {&gds-sum-fmt} )
      v-total-tara-str  = if v-total-tara = 0 then p-fmt-align-string( {&none-symbol} , {&col-fmtlw-5} , "center")
                          else string( v-total-tara , {&gds-sum-fmt} )
    .

    display stream out-stream
      sym1
      "Итого по приходу" @ tt-report.gds-name
      sym2
      p-fmt-align-string( {&none-symbol-2} , {&col-fmtlw-2} , "center") @ tt-report.fact-date-str
      sym3
      p-fmt-align-string( {&none-symbol-2} , {&col-fmtlw-3} , "center") @ tt-report.doc-code
      sym4
      v-total-gds-str @ tt-report.gds-sum-str
      sym5
      v-total-tara-str @ tt-report.tara-sum-str
      sym6
      sym7
      sym8
    with frame torg29.
    down stream out-stream with frame torg29.
    put stream out-stream v-line format "X({&frame-width})" skip.
    run torg29xl-write-cell-data in this-procedure ( input {&torg29xl-f_incomegds}  , input trim(v-total-gds-str)  ).
    run torg29xl-write-cell-data in this-procedure ( input {&torg29xl-f_incometara} , input trim(v-total-tara-str) ).

    assign
      v-total-gds-str   = if (v-ost-gds-1 + v-total-gds) = 0 then
                            p-fmt-align-string( {&none-symbol} , {&col-fmtlw-4} , "center")
                          else
                            string( (v-ost-gds-1 + v-total-gds) , {&gds-sum-fmt} )
      v-total-tara-str  = if (v-ost-tara-1 + v-total-tara) = 0 then
                            p-fmt-align-string( {&none-symbol} , {&col-fmtlw-5} , "center")
                          else
                            string( (v-ost-tara-1 + v-total-tara) , {&gds-sum-fmt} )
      v-itog-s-ost-gds  = (v-ost-gds-1 + v-total-gds)
      v-itog-s-ost-tara = (v-ost-tara-1 + v-total-tara)
    .
    display stream out-stream
      sym1
      "Итого с остатком" @ tt-report.gds-name
      sym2
      p-fmt-align-string( {&none-symbol-2} , {&col-fmtlw-2} , "center") @ tt-report.fact-date-str
      sym3
      p-fmt-align-string( {&none-symbol-2} , {&col-fmtlw-3} , "center") @ tt-report.doc-code
      sym4
      v-total-gds-str @ tt-report.gds-sum-str
      sym5
      v-total-tara-str @ tt-report.tara-sum-str
      sym6
      sym7
      sym8
    with frame torg29.
    down stream out-stream with frame torg29.
    put stream out-stream v-line format "X({&frame-width})" skip.
    run torg29xl-write-cell-data in this-procedure ( input {&torg29xl-f_incostgds}  , input trim(v-total-gds-str)  ).
    run torg29xl-write-cell-data in this-procedure ( input {&torg29xl-f_incosttara} , input trim(v-total-tara-str) ).

  /*end.*/
  hide stream out-stream frame BottomFrame .
  page stream out-stream.
  view stream out-stream frame BottomFrame .
  run print-header-list-2 in this-procedure .
  /*for each tt-report-object :*/
    display stream out-stream
      sym1
      p-fmt-align-string( "Расход" , {&col-fmtlw-1} , "center")  @ tt-report.gds-name
      sym2
      p-fmt-align-string( {&none-symbol-2} , {&col-fmtlw-2} , "center") @ tt-report.fact-date-str
      sym3
      p-fmt-align-string( {&none-symbol-2} , {&col-fmtlw-3} , "center") @ tt-report.doc-code
      sym4
      sym5
      sym6
      sym7
      sym8
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
    for each tt-report
      where tt-report.ext-doc-type = {&outcome-type}
    by tt-report.gds-code
    by tt-report.fact-order
    by tt-report.obj-type
    by tt-report.obj-code
    :
      display stream out-stream
        sym1
        tt-report.gds-name
        sym2
        tt-report.fact-date-str
        sym3
        tt-report.doc-code
        sym4
        tt-report.gds-sum-str
        sym5
        tt-report.tara-sum-str
        sym6
        tt-report.buh-1
        sym7
        tt-report.buh-2
        sym8
      with frame torg29.
      down stream out-stream with frame torg29.
      run torg29xl-sheet2-write-line-data ( input tt-report.gds-name
                                          , input tt-report.fact-date-str
                                          , input tt-report.doc-code
                                          , input trim(tt-report.gds-sum-str)
                                          , input trim(tt-report.tara-sum-str)
                                          , input tt-report.buh-1
                                          , input tt-report.buh-2
                                          ) .
      assign
        v-total-gds  = v-total-gds  + tt-report.gds-sum
        v-total-tara = v-total-tara + tt-report.tara-sum
      .
    end.
    if x-SET_PAY_TYPE = {&p-sale} then do:
      assign
        v-avt-ovt-gds       = v-itog-s-ost-gds  - (v-total-gds + v-ost-gds-2)
        v-avt-ovt-tara      = v-itog-s-ost-tara - (v-total-tara + v-ost-tara-2)
        v-avt-ovt-gds-str   = if v-avt-ovt-gds = 0 then p-fmt-align-string( {&none-symbol} , {&col-fmtlw-4} , "center")
                              else string( v-avt-ovt-gds , {&gds-sum-fmt} )
        v-avt-ovt-tara-str  = if v-avt-ovt-tara = 0 then p-fmt-align-string( {&none-symbol} , {&col-fmtlw-5} , "center")
                              else string( v-avt-ovt-tara , {&gds-sum-fmt} )
      .
    end.
    else do:
      assign
        v-avt-ovt-gds       = 0
        v-avt-ovt-tara      = 0
        v-avt-ovt-gds-str   = p-fmt-align-string( {&none-symbol} , {&col-fmtlw-4} , "center")
        v-avt-ovt-tara-str  = p-fmt-align-string( {&none-symbol} , {&col-fmtlw-5} , "center")
      .
    end.

    assign
      v-total-gds         = v-total-gds  + v-avt-ovt-gds
      v-total-tara        = v-total-tara + v-avt-ovt-tara
      v-total-gds-str     = if v-total-gds  = 0 then p-fmt-align-string( {&none-symbol} , {&col-fmtlw-4} , "center")
                            else string( v-total-gds , {&gds-sum-fmt} )
      v-total-tara-str    = if v-total-tara = 0 then p-fmt-align-string( {&none-symbol} , {&col-fmtlw-5} , "center")
                            else string( v-total-tara , {&gds-sum-fmt} )
    .
    if x-SET_PAY_TYPE = {&p-sale} and ( v-avt-ovt-gds <> 0 or v-avt-ovt-tara <> 0 ) then do:
      put stream out-stream v-line format "X({&frame-width})" skip.
      display stream out-stream
        sym1
        "Автоматическая переоценка" @ tt-report.gds-name
        sym2
        p-fmt-align-string( {&none-symbol-2} , {&col-fmtlw-2} , "center") @ tt-report.fact-date-str
        sym3
        p-fmt-align-string( {&none-symbol-2} , {&col-fmtlw-3} , "center") @ tt-report.doc-code
        sym4
        v-avt-ovt-gds-str @ tt-report.gds-sum-str
        sym5
        v-avt-ovt-tara-str @ tt-report.tara-sum-str
        sym6
        sym7
        sym8
      with frame torg29.
      down stream out-stream with frame torg29.
      run torg29xl-sheet2-write-line-data ( input "Автоматическая переоценка":U
                                          , input {&none-symbol-2}
                                          , input {&none-symbol-2}
                                          , input trim(v-avt-ovt-gds-str)
                                          , input trim(v-avt-ovt-tara-str)
                                          , input ""
                                          , input ""
                                          ) .
    end.
    put stream out-stream v-line format "X({&frame-width})" skip.

    display stream out-stream
      sym1
      "Итого по расходу" @ tt-report.gds-name
      sym2
      p-fmt-align-string( {&none-symbol-2} , {&col-fmtlw-2} , "center") @ tt-report.fact-date-str
      sym3
      p-fmt-align-string( {&none-symbol-2} , {&col-fmtlw-3} , "center") @ tt-report.doc-code
      sym4
      v-total-gds-str @ tt-report.gds-sum-str
      sym5
      v-total-tara-str @ tt-report.tara-sum-str
      sym6
      sym7
      sym8
    with frame torg29.
    down stream out-stream with frame torg29.
    put stream out-stream v-line format "X({&frame-width})" skip.
    display stream out-stream
      sym1
      substitute("Остаток на &1 " , w-date(x-Date-End) )  @ tt-report.gds-name
      sym2
      p-fmt-align-string( {&none-symbol-2} , {&col-fmtlw-2} , "center") @ tt-report.fact-date-str
      sym3
      p-fmt-align-string( {&none-symbol-2} , {&col-fmtlw-3} , "center") @ tt-report.doc-code
      sym4
      v-ost-gds-str-2 @ tt-report.gds-sum-str
      sym5
      v-ost-tara-str-2 @ tt-report.tara-sum-str
      sym6
      sym7
      sym8
    with frame torg29.
    down stream out-stream with frame torg29.
    put stream out-stream v-line format "X({&frame-width})" skip(2).
    run torg29xl-write-cell-data in this-procedure ( input {&torg29xl-f_expgds}       , input trim(v-total-gds-str)  ).
    run torg29xl-write-cell-data in this-procedure ( input {&torg29xl-f_exptara}      , input trim(v-total-tara-str) ).
    run torg29xl-write-cell-data in this-procedure ( input {&torg29xl-f_expostdateend}, input substitute("Остаток на &1 " , w-date(x-Date-End) )  ).
    run torg29xl-write-cell-data in this-procedure ( input {&torg29xl-f_expostgds}    , input trim(v-ost-gds-str-2)  ).
    run torg29xl-write-cell-data in this-procedure ( input {&torg29xl-f_exposttara}   , input trim(v-ost-tara-str-2) ).

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