block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-alcpri.p $
$Archive: rep/r-alcpri.p $

Отчет поставки алкогольной продукции

Автор: Хныкин Павел Андреевич
Дата создания: 12/20/06
Author: Pavel Khnykin
Creation date: 12/20/06

*/
define input parameter p-RADpost  as integer no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-alcpri.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-alcpri.p $":U .
define variable vss-description as character no-undo init "Отчет поставки алкогольной продукции".
{ cmp/vssrevis.i                }

do
on error undo, return error
:
{ cmp/str-glbl.i                }
{ cmp/library.i                 }
{ cmp/r-pril.i new              }
{ cmp/r-page1.i                 }
{ rep/f-fdec.i                  }
{ ref/grplibfn.i                }
{ gbl/waitfram.i                }
{ gbl/prn-lib.i                 }
{ rep/r-sym.i                   }
&undefine gds-list_i_def
{ cmp/gds-list.i temp-gds "def" }
{ trg/factord.i                 }
{ trg/partslib.i                }
{ cmp/strcodec.i                }
{ gbl/integerm.i                }
{ gbl/alc-lib.i                 }
{ str/clcprtsl.i                }
{ rep/p-fmt.i                   }
{ rep/lkp-font.i                }
define buffer buf_parts         for ub.parts.
define buffer buf_goods         for ub.goods.
define buffer buf_cli-gds       for ub.cli-gds.
define buffer buf_trn-doc       for ub.trn-doc.
define buffer buf_doc-line      for ub.doc-line.
define buffer buf_temp-gds      for temp-gds.
define stream out-stream.


define variable v-line                    as  character     no-undo.
define variable g#report-num              as integer        no-undo .
define variable v-counter                 as integer        no-undo .
define variable v-vardate                 as date           no-undo .
define variable v-end-fact-order          as decimal        no-undo .
define variable v-shift-end-fact-order    as decimal        no-undo .
define variable v-day-end-fact-order      as decimal        no-undo .
define variable v-alc-db-num              as integer        no-undo .
define variable v-alc-mark-code           as character      no-undo .
define variable v-alc-bottling-date       as date           no-undo .
define variable v-alc-refAB-path          as character      no-undo .
define variable v-alc-qualitycert-path    as character      no-undo .
define variable v-alc-certif-path         as character      no-undo .
define variable v-alc-comment             as character      no-undo .
define variable v-curr-grp-name           as character      no-undo .
define variable v-obj-code                as integer        no-undo .
define variable v-obj-type                as character      no-undo .
define variable v-repfrm-str              as character      no-undo .
define variable v-print-rubl              as logical        no-undo .
define variable v-total-price             as decimal        no-undo .
define variable v-total-sum-noNDS         as decimal        no-undo .
define variable v-total-sum-withNDS       as decimal        no-undo .
define variable v-cli-code                as integer        no-undo .
define variable v-cli-type                as character      no-undo .
define variable v-sub-total-sum-noNDS     as decimal        no-undo .
define variable v-sub-total-sum-withNDS   as decimal        no-undo .
define variable v-sub-total-qnty          like temp-parts.fact-qnty no-undo .

def SHARED temp-table g#post-f NO-UNDO
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    field grp-code like ub.clients.grp-code
    field grp-name like ub.clients.grp-name
    field lvl-num like  ub.cli-grp.lvl-num
    INDEX pi IS UNIQUE PRIMARY obj-type obj-code
    INDEX p1  obj-name
    .

define temp-table temp-str no-undo
  field doc-code      like ub.doc-line.doc-code
  field artic         like ub.doc-line.artic
  field prod-type     like ub.doc-line.prod-type
  field prod-code     like ub.doc-line.prod-code
  field gds-code      like ub.goods.gds-code
  field gds-name      like ub.goods.gds-name
  field fact-date     like ub.trn-doc.fact-date
  field cli-code      like ub.trn-doc.cli-code
  field cli-type      like ub.trn-doc.cli-type
  field cli-name      like ub.trn-doc.cli-name
  field fact-qnty     like ub.doc-line.fact-qnty
  field price         as decimal
  field sum-noNDS     as decimal
  field sum-withNDS   as decimal
  index pi is primary doc-code artic prod-type prod-code
  index cli cli-code cli-type gds-code fact-date
.


&scop f-width 153
&scop f-gds-name 40
&scop f-in-doc 14

define frame f-doc
  sym1 column-label ":!:!" format "X(1)" space (0)
  temp-str.gds-code column-label "Код товара! " format "999999999" space(0)
  sym2 column-label ":!:!" format "X(1)" space (0)
  temp-str.gds-name column-label "Наименование! " format "X({&f-gds-name})" space(0)
  sym3 column-label ":!:!" format "X(1)" space (0)
  temp-str.doc-code column-label "Документ!прихода" format "X({&f-in-doc})" space(0)
  sym4 column-label ":!:!" format "X(1)" space (0)
  temp-str.fact-date column-label "Дата поставки! " format "99.99.99" space(0)
  sym5 column-label ":!:!" format "X(1)" space (0)
  temp-str.fact-qnty column-label "Количество! " format "->>,>>>,>>9.999" space(0)
  sym6 column-label ":!:!" format "X(1)" space (0)
  temp-str.price column-label "Цена! " format "->>,>>>,>>9.99" space(0)
  sym7 column-label ":!:!" format "X(1)" space (0)
  temp-str.sum-noNDS column-label "Сумма без НДС! " format "->>,>>>,>>9.99" space(0)
  sym8 column-label ":!:!" format "X(1)" space (0)
  temp-str.sum-withNDS column-label "Сумма c НДС! " format "->>,>>>,>>9.99" space(0)
  sym9 column-label ":!:!" format "X(1)" space (0)

header

  string( "Страница " + string( PAGE-NUMBER( out-stream ), ">>>9" ) ) at 117 format "X(13)" skip
  v-line format "X({&f-width})" at 1
with width {&A4_CW} down stream-io .
form header
        v-line format "X({&f-width})" at 1 SKIP
        "Продолжение - на следующей странице" at 1 SKIP
with frame BottomFrame width {&A4_CW} PAGE-BOTTOM NO-LABELS NO-BOX .


assign
  v-line = fill( "-" , 300 )
.
form with frame f-doc.

for each temp-str:
  delete temp-str.
end.
for each temp-gds:
  delete temp-gds.
end.

run get-report-num in my-handle (output g#report-num).
{ cmp/open-out.i stream out-stream " " ReportPageHeight }
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

assign
  v-counter = 0
.
{ rep/repfrm.i def  }
run create-temp-str in this-procedure no-error .
view stream out-stream frame BottomFrame.
run print-header in this-procedure no-error.

for each temp-str no-lock
  break by temp-str.cli-code
        by temp-str.cli-type
        by temp-str.gds-code
        by temp-str.fact-date
:
  accumulate
    temp-str.sum-noNDS    (TOTAL)
    temp-str.sum-withNDS  (TOTAL)
  .
  { rep/repfrm.i disp v-counter v-repfrm-str }
  if v-cli-code <> temp-str.cli-code or v-cli-type <> temp-str.cli-type then do:
    assign
      v-cli-code = temp-str.cli-code
      v-cli-type = temp-str.cli-type
    .
    run print-sub-itog in this-procedure
                 ( input v-sub-total-qnty
                 , input v-sub-total-sum-noNDS
                 , input v-sub-total-sum-withNDS
                 )
                 no-error.
    run print-supplier in this-procedure no-error.
    assign
      v-sub-total-qnty        = 0
      v-sub-total-sum-noNDS   = 0
      v-sub-total-sum-withNDS = 0
    .
  end.
  run print-line in this-procedure no-error.
  assign
    v-counter               = v-counter               + 1
    v-sub-total-qnty        = v-sub-total-qnty        + temp-str.fact-qnty
    v-sub-total-sum-noNDS   = v-sub-total-sum-noNDS   + temp-str.sum-noNDS
    v-sub-total-sum-withNDS = v-sub-total-sum-withNDS + temp-str.sum-withNDS
  .
end.
{ rep/repfrm.i off }

for each temp-gds:
  delete temp-gds.
end.
for each temp-str:
  delete temp-str.
end.
assign
  v-total-sum-noNDS   = accum TOTAL temp-str.sum-noNDS
  v-total-sum-withNDS = accum TOTAL temp-str.sum-withNDS
.
run print-sub-itog in this-procedure
              ( input v-sub-total-qnty
              , input v-sub-total-sum-noNDS
              , input v-sub-total-sum-withNDS
              )
                 no-error .
run print-itog in this-procedure
              ( input v-total-sum-noNDS
              , input v-total-sum-withNDS
              )
              no-error .
hide stream out-stream frame BottomFrame.
{&CloseExcel}
output stream out-stream close.

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

end. /* main do */


procedure create-temp-str :
do
on error undo, return error return-value
:
case x-SelectGood :
  when {&g-all} then do: /* все товары */
    { rep/r-alcpri.i buf_goods g#post-f}
  end.
  when {&g-grp} then do: /* товары по группам  */
    for each tmp#grp no-lock
    :
      run grplib-get-full-name in this-procedure( input tmp#grp.node-code, output v-curr-grp-name ) .
      for each buf_goods no-lock
            where buf_goods.grp-name begins v-curr-grp-name
      :
        find first temp-gds no-lock
          where temp-gds.artic     = buf_goods.artic
            and temp-gds.prod-type = buf_goods.prod-type
            and temp-gds.prod-code = buf_goods.prod-code
          no-error .
        if not available temp-gds then do:
          create temp-gds.
          buffer-copy buf_goods to temp-gds no-error.
        end.
      end.
    end.
    { rep/r-alcpri.i temp-gds g#post-f}
  end.
  when {&g-prod} then do: /* товары по производителю */
    for each g#cli no-lock,
        each buf_goods no-lock
/*        ,first buf_cli-gds no-lock*/
          where
/*                buf_cli-gds.cli-type  = g#cli.obj-type*/
/*            and buf_cli-gds.cli-code  = g#cli.obj-code*/
            /*and buf_cli-gds.host-code = g#cli.host-code*/
                buf_goods.prod-type   = g#cli.obj-type
            and buf_goods.prod-code   = g#cli.obj-code
/*            and buf_goods.artic       = buf_cli-gds.artic*/
    :
      find first buf_temp-gds no-lock
        where buf_temp-gds.prod-type = buf_goods.prod-type
          and buf_temp-gds.prod-code = buf_goods.prod-code
          and buf_temp-gds.artic     = buf_goods.artic
      no-error.
      if not available buf_temp-gds then do:
        create temp-gds.
        buffer-copy buf_goods to temp-gds no-error.
      end.
    end.
    { rep/r-alcpri.i temp-gds g#post-f}
  end.
  when {&g-choice} then do: /* товары выборочно */
    { rep/r-alcpri.i gds-list g#post-f}
  end.
  when {&g-one} then do: /* один товар */
    { rep/r-alcpri.i gds-list g#post-f}
  end.
  when {&g-grp-prod} then do: /* группа и производитель */
    for each tmp#grp no-lock
    :
      run grplib-get-full-name in this-procedure( input tmp#grp.node-code, output v-curr-grp-name ) .
      for each buf_goods no-lock
            where buf_goods.grp-name begins v-curr-grp-name
      :
        find first temp-gds no-lock
          where temp-gds.artic     = buf_goods.artic
            and temp-gds.prod-type = buf_goods.prod-type
            and temp-gds.prod-code = buf_goods.prod-code
          no-error .
        if not available temp-gds then do:
          create temp-gds.
          buffer-copy buf_goods to temp-gds no-error.
        end.
      end.
    end.
    for each g#cli no-lock,
        each buf_goods no-lock
/*        ,first buf_cli-gds no-lock*/
          where
/*          buf_cli-gds.cli-type  = g#cli.obj-type*/
/*            and buf_cli-gds.cli-code  = g#cli.obj-code*/
                buf_goods.prod-type   = g#cli.obj-type
            and buf_goods.prod-code   = g#cli.obj-code
/*            and buf_goods.artic       = buf_cli-gds.artic*/
    :
      find first buf_temp-gds no-lock
        where buf_temp-gds.prod-type = buf_goods.prod-type
          and buf_temp-gds.prod-code = buf_goods.prod-code
          and buf_temp-gds.artic     = buf_goods.artic
      no-error.
      if not available buf_temp-gds then do:
        create temp-gds.
        buffer-copy buf_goods to temp-gds no-error.
      end.
    end.
    { rep/r-alcpri.i temp-gds g#post-f}
  end.
end case.
end.
end procedure. /* create-temp-str */


procedure print-header :

define variable v-rep-title as character init "ПОСТАВКИ АЛКОГОЛЬНОЙ ПРОДУКЦИИ":u no-undo .
define variable v-rep-date  as character no-undo .
do
on error undo, return error return-value
:
  assign
    v-rep-date = substitute( "за период с &1 по &2" , X-date-start , X-date-end)
  .
  put stream out-stream
    v-rep-title at center-field( 1 , {&f-width} , length(v-rep-title) ) format "X(50)" skip
    v-rep-date  at center-field( 1 , {&f-width} , length(v-rep-date) ) format "X(50)" skip(1)
  .
  assign
    sheetf.Excel-Column-Lable =
    "Код товара" + {&comma-char} +
    "Наменование"  + {&comma-char} +
    "Документ прихода"  + {&comma-char} +
    "Дата поставки"  + {&comma-char} +
    "Количество" + {&comma-char} +
    "Цена" + {&comma-char} +
    "Сумма без НДС" + {&comma-char} +
    "Сумма с НДС"
    sheetf.sizes =
    "20"  + {&comma-char} +
    "40"  + {&comma-char} +
    "15"  + {&comma-char} +
    "15"  + {&comma-char} +
    "15"  + {&comma-char} +
    "15"  + {&comma-char} +
    "15"  + {&comma-char} +
    "15"
    Sheetf.colformat = "1=@;2=@;3=@;4=dd/mm/yy;5=0,00;6=0,00;7=0,00;8=0,00;"
  .
  run rep/extitle.p (1).

end.
end procedure. /* print-header */


procedure print-line :

define variable v-gds-name                as character      no-undo .

do
on error undo, return error return-value
:

    if length( temp-str.gds-name ) > {&f-gds-name} then
    do:
      assign
        v-gds-name = substitute( "&1>" , substring( temp-str.gds-name , 1 , ({&f-gds-name} - 1) ) )
      .
    end.
    else do:
      assign
        v-gds-name = temp-str.gds-name
      .
    end.

  display stream out-stream
    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9
    temp-str.gds-code
    v-gds-name @ temp-str.gds-name
    temp-str.doc-code
    temp-str.fact-date
    temp-str.fact-qnty
    temp-str.price
    temp-str.sum-noNDS
    temp-str.sum-withNDS
  with frame f-doc.
  down stream out-stream with frame f-doc.
  {&PutExcel}
    temp-str.gds-code                           {&tabulation}
    temp-str.gds-name                           {&tabulation}
    temp-str.doc-code                           {&tabulation}
    temp-str.fact-date    format "99.99.99"     {&tabulation}
    temp-str.fact-qnty                          {&tabulation}
    temp-str.price        format ">>>>>>>>9.99" {&tabulation}
    temp-str.sum-noNDS    format ">>>>>>>>9.99" {&tabulation}
    temp-str.sum-withNDS  format ">>>>>>>>9.99" {&tabulation}
  skip.
end.
end procedure. /* print-line */

procedure print-supplier :

do
on error undo, return error return-value
:
    if line-counter( out-stream ) + 4 > page-size( out-stream ) then page stream out-stream .
    put stream out-stream v-line at 1 format "X({&f-width})" skip .
    display stream out-stream
      temp-str.cli-code @ temp-str.gds-code
      temp-str.cli-name @ temp-str.gds-name
    with frame f-doc.
    down stream out-stream with frame f-doc.
    put stream out-stream v-line at 1 format "X({&f-width})" skip .
    {&PutExcel}
      temp-str.cli-code     {&tabulation}
      temp-str.cli-name     {&tabulation}
      " "                   {&tabulation}
      " "                   {&tabulation}
      " "                   {&tabulation}
      " "                   {&tabulation}
      " "                   {&tabulation}
      " "                   {&tabulation}
    skip.
end.
end procedure. /* print-supplieк */

procedure print-sub-itog :

define input  parameter p-sub-total-qnty        like ub.parts.fact-qnty no-undo .
define input  parameter p-sub-total-sum-noNDS   as decimal format ">>>>>>>>9.99"  no-undo .
define input  parameter p-sub-total-sum-withNDS as decimal format ">>>>>>>>9.99"  no-undo .

do
on error undo, return error return-value
:
    if line-counter( out-stream ) + 4 > page-size( out-stream ) then page stream out-stream .
    if p-sub-total-qnty > 0 then do:
        put stream out-stream v-line at 1 format "X({&f-width})" skip.
        display stream out-stream
          sym1 sym2 sym5 sym6 sym8 sym9
          "Итого по товарам"          @ temp-str.gds-code
          p-sub-total-qnty            @ temp-str.fact-qnty
          p-sub-total-sum-noNDS       @ temp-str.sum-noNDS
          p-sub-total-sum-withNDS     @ temp-str.sum-withNDS
        with frame f-doc.
        down stream out-stream with frame f-doc.
        {&PutExcel}
          "Итого по товарам"                            {&tabulation}
          " "                                           {&tabulation}
          " "                                           {&tabulation}
          " "                                           {&tabulation}
          p-sub-total-qnty                              {&tabulation}
          " "                                           {&tabulation}
          p-sub-total-sum-noNDS   format ">>>>>>>>9.99" {&tabulation}
          p-sub-total-sum-withNDS format ">>>>>>>>9.99" {&tabulation}
        skip(1).
    end.
end.
end procedure. /* print-sub-itog */


procedure print-itog :

define input  parameter p-total-sum-noNDS   as decimal format ">>>>>>>>9.99"  no-undo .
define input  parameter p-total-sum-withNDS as decimal format ">>>>>>>>9.99"  no-undo .

do
on error undo, return error return-value
:
  if line-counter( out-stream ) + 3 > page-size( out-stream ) then do:
    page stream out-stream.
  end.
  put stream out-stream v-line at 1 format "X({&f-width})".
  display stream out-stream
    sym1 sym2 sym8 sym9
    "Итого по поставщикам"  @ temp-str.gds-code
    p-total-sum-noNDS       @ temp-str.sum-noNDS
    p-total-sum-withNDS     @ temp-str.sum-withNDS
  with frame f-doc.
  put stream out-stream v-line at 1 format "X({&f-width})".
  {&PutExcel}
  skip(2)
    "Итого по поставщикам"                    {&tabulation}
    " "                                       {&tabulation}
    " "                                       {&tabulation}
    " "                                       {&tabulation}
    " "                                       {&tabulation}
    " "                                       {&tabulation}
    p-total-sum-noNDS   format ">>>>>>>>9.99" {&tabulation}
    p-total-sum-withNDS format ">>>>>>>>9.99" {&tabulation}
  skip.

end.
end procedure. /* print-itog */