block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: e-alcost.p $
$Archive: rep/e-alcost.p $

Отчет Остатки по датам разлива

Автор: Хныкин Павел Андреевич
Дата создания: 12/06/05
Author: Pavel Khnykin
Creation date: 12/06/05

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: e-alcost.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/e-alcost.p $":U .
define variable vss-description as character no-undo init "Отчет Остатки по датам розлива".
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
{ cmp/gds-list.i temp-gds def   }
{ trg/factord.i                 }
{ trg/partslib.i                }
{ cmp/strcodec.i                }
{ gbl/integerm.i                }
{ gbl/alc-lib.i                 }

define temp-table temp-str no-undo
  field artic           like ub.parts.artic
  field part-code       like ub.parts.part-code
  field obj-code        like ub.clients.obj-code
  field obj-type        like ub.clients.obj-type
  field in-code         like ub.parts.in-code
  field out-code        like ub.parts.out-code
  field prod-code       like ub.parts.prod-code
  field prod-type       like ub.parts.prod-type
  field gds-name        like ub.goods.gds-name
  field fact-qnty       like ub.parts.fact-qnty
  field ms-base         like ub.goods.ms-base
  field fact-date       like ub.parts.fact-date format "99.99.99"
  field out-date        as date format "99.99.99"
  field mark-code       as character
  field list-doc        as character
  field list-date       as character
  field ext-type        as character
  index pi is primary artic part-code obj-code obj-type prod-code prod-type in-code out-code
.

define stream out-stream.

define buffer buf_parts         for ub.parts.
define buffer buf_goods         for ub.goods.
define buffer buf_cli-gds       for ub.cli-gds.
define buffer buf_trn-doc       for ub.trn-doc.
define buffer buf_temp-gds      for temp-gds.

define variable v-line                    as  character     no-undo.
define variable g#report-num              as integer        no-undo .
define variable counter                   as integer        no-undo .
define variable vardate                   as date           no-undo .
define variable v-list-doc                as character      no-undo .
define variable v-list-date               as character      no-undo .
define variable v-ext-type                as character      no-undo .
define variable v-end-fact-order          as decimal        no-undo .
define variable v-shift-end-fact-order    as decimal        no-undo .
define variable v-day-end-fact-order      as decimal        no-undo .
define variable v-obj-code                as integer        no-undo .
define variable v-doc                     like temp-str.in-code     no-undo.
define variable v-date                    like temp-str.fact-date   no-undo.
define variable v-doc-source              as character      no-undo.
define variable v-date-source             as character      no-undo.
define variable v-ext-type-source         as character      no-undo.
define variable v-alc-mark-code           as character      no-undo .
define variable v-alc-bottling-date       as date           no-undo .
define variable v-total-qnty              like ub.parts.fact-qnty no-undo.
define variable v-curr-grp-name           as character      no-undo .
define variable v-repfrm-title            as character  initial "Формирование отчета по партиям...":U no-undo .
define variable v-gds-name                as character      no-undo .

&scop f-width 131
&scop f-mark-code 12
&scop f-gds-name 40
&scop list-doc-delim ","
&scop list-date-delim {&list-doc-delim}

define frame f-doc
  sym1 column-label ":!:!:" format "X(1)" space(0)
  temp-str.artic column-label "Артикул ! ! ":C16 format "X(16)" space(0)
  sym2 column-label ":!:!:" format "X(1)" space(0)
  temp-str.gds-name  column-label "Описание! ! ":C40 format "X({&f-gds-name})" space(0)
  sym3 column-label ":!:!:" format "X(1)" space(0)
  temp-str.fact-qnty column-label "Остаток! ! ":C7 format "->>>>>9" space(0)
  sym4 column-label ":!:!:" format "X(1)" space(0)
  temp-str.out-date column-label "Дата!выпуска! ":C8 format "99.99.99" space(0)
  sym5 column-label ":!:!:" format "X(1)" space(0)
  temp-str.ms-base column-label "Ед. из! ! ":C7 format ">>>9.9<<<" space(0)
  sym6 column-label ":!:!:" format "X(1)" space(0)
  temp-str.obj-code column-label "Код!склада! ":C9 format ">>>>>>>>9" space(0)
  sym7 column-label ":!:!:" format "X(1)" space(0)
  temp-str.fact-date column-label  "Дата!прих.!док.":C8 format "99.99.99" space(0)
  sym8 column-label ":!:!:" format "X(1)" space(0)
  temp-str.in-code column-label "Документ!прихода! ":C14 format "X(14)" space(0)
  sym9 column-label ":!:!:" format "X(1)" space(0)
  temp-str.mark-code column-label "Спецификация!выпуска! " format "X({&f-mark-code})" space(0)
  sym10 column-label ":!:!:" format "X(1)" space(0)
header
  string( "Страница " + string( PAGE-NUMBER( out-stream ), ">>>9" ) ) at 117 format "X(13)" skip
  v-line format "X({&f-width})" at 1

with width {&A4_CW0} down stream-io.

form header
        v-line format "X({&f-width})" at 1 SKIP
        "Продолжение - на следующей странице" at 1 SKIP
with frame BottomFrame width {&A4_CW0} PAGE-BOTTOM NO-LABELS NO-BOX .

assign
  v-line = fill( "-" , 300 )
.
run get-report-num in my-handle (output g#report-num).
{ cmp/open-out.i stream out-stream " " }
view stream out-stream frame BottomFrame .
run waitfram-show in this-procedure ("Формирование списка товаров...").
for each temp-gds:
  delete temp-gds.
end.
case x-SelectGood :
  when {&g-all} then do: /* все товары */
    { rep/e-alcost.i buf_goods}
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
    { rep/e-alcost.i temp-gds}
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
   { rep/e-alcost.i temp-gds}
  end.
  when {&g-choice} then do: /* товары выборочно */
    { rep/e-alcost.i gds-list}
  end.
  when {&g-one} then do: /* один товар */
    { rep/e-alcost.i gds-list}
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
    { rep/e-alcost.i temp-gds}
  end.
end case.
run print-header in this-procedure.
{ rep/repfrm.i def   }
{ rep/repfrm.i on }
for each temp-str no-lock
  break by temp-str.obj-code
        by temp-str.obj-type
        by temp-str.artic
:
  assign
    counter = counter + 1
  .
  { rep/repfrm.i disp counter v-repfrm-title}
  run print-temp-str-line in this-procedure.
  accumulate temp-str.fact-qnty ( TOTAL ).
end.
{ rep/repfrm.i off }
assign
  v-total-qnty = accum TOTAL temp-str.fact-qnty
.
run print-itog in this-procedure.

for each temp-gds:
  delete temp-gds.
end.
for each temp-str:
  delete temp-str.
end.
hide stream out-stream frame BottomFrame.
{&CloseExcel}
output stream out-stream close.


  define variable v-user-action as character no-undo .
  define variable v-printed as logical   no-undo .
  define variable DisabledOptions as integer   no-undo .
  DisabledOptions = 7 .

  run gbl/prnfilen.w
    (input  ""
    ,input  DisabledOptions
    ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
    ,input  7
    ,output v-user-action
    ,output v-printed
    ) .

/*RUN prn-file.w(7) .*/
end. /* do */


procedure print-header :

do
on error undo, return error return-value
:
  put stream out-stream "СКЛАД НАЛИЧИЕ" at 70 skip x-Date-Alone at 120 format "99.99.99" skip.
  put stream out-stream "По объектам:" at 6 skip.
  for each obj-list no-lock
      by obj-list.obj-code
      by obj-list.obj-name
  :
    put stream out-stream substitute( "&1 (&2)" , obj-list.obj-name , obj-list.obj-code) at 19 format "X(100)" skip.
  end.
  assign
    sheetf.Excel-Column-Lable =
    "Артикул" + {&comma-char} +
    "Описание"  + {&comma-char} +
    "Остаток"  + {&comma-char} +
    "Дата выпуска"  + {&comma-char} +
    "Ед.Из" + {&comma-char} +
    "Код склада" + {&comma-char} +
    "Дата прих. док." + {&comma-char} +
    "Документ прихода" + {&comma-char} +
    "Спецификация выпуска"
    sheetf.sizes =
    "20"  + {&comma-char} +
    "40"  + {&comma-char} +
    "15"  + {&comma-char} +
    "15"  + {&comma-char} +
    "15"  + {&comma-char} +
    "15"  + {&comma-char} +
    "15"  + {&comma-char} +
    "15"  + {&comma-char} +
    "15"
    Sheetf.colformat = "1=@;2=@;3=0,00;4=dd/mm/yy;5=0,00;6=0;7=dd/mm/yy;8=@;9=@;"
  .
  run rep/extitle.p (1).
end.
end procedure. /* print-header */



procedure find-docs:
define output parameter list-doc  as character no-undo.
define output parameter list-date as character no-undo.
define output parameter ext-type  as character no-undo.

define buffer buf_parts for ub.parts.

do
on error undo, return error return-value
:
  define variable v-doc                as character      no-undo .
  define variable v-date               as character      no-undo .
  assign
    list-doc  = ""
    list-date = ""
    ext-type  = ""
  .
  for each buf_parts no-lock
        where buf_parts.obj-type  = temp-parts.obj-type
          and buf_parts.obj-code  = temp-parts.obj-code
          and buf_parts.artic     = temp-parts.artic
          and buf_parts.prod-type = temp-parts.prod-type
          and buf_parts.prod-code = temp-parts.prod-code
          and buf_parts.in-code   = temp-parts.in-code
          and buf_parts.part-code = temp-parts.part-code,
      first buf_trn-doc no-lock
        where buf_trn-doc.doc-code      = buf_parts.out-code
          and buf_trn-doc.ext-doc-type  = {&TDEDT_Pri_Vnesh}
          and buf_trn-doc.status_       = {&fact}
          or  buf_trn-doc.doc-code      = buf_parts.out-code
          and buf_trn-doc.ext-doc-type  = {&TDEDT_Pri_Perem}
          and buf_trn-doc.status_       = {&fact}
      on error undo, return error return-value

  :
    assign
      v-doc     = if buf_trn-doc.doc-code <> ? then buf_trn-doc.doc-code else " "
      v-date    = if buf_trn-doc.fact-date <> ? then string( buf_trn-doc.fact-date ) else " "
    .
    if list-doc = "" then do :
      assign
        list-doc  = v-doc
        list-date = v-date
        ext-type  = buf_trn-doc.ext-doc-type
      .
    end.
    else do :
      assign
        list-doc  = list-doc  + {&list-doc-delim} + v-doc
        list-date = list-date + {&list-date-delim} + v-date
        ext-type  = ext-type  + "," + buf_trn-doc.ext-doc-type
      .
    end.
  end. /* for each buf_parts */
end.
end procedure. /* find-docs */


procedure print-temp-str-line:

define variable v-log-first               as logical  initial yes   no-undo .

do
on error undo, return error
:
   if ( length( temp-str.mark-code ) + 1 ) > {&f-mark-code} then
    do:
      assign
        v-alc-mark-code = substitute( "&1>" , substring( temp-str.mark-code , 1 , ({&f-mark-code} - 1) ) )
      .
   end.
   else
    do:
      assign
        v-alc-mark-code = temp-str.mark-code
      .
    end.
    if length( temp-str.gds-name ) > {&f-gds-name} then
    do:
      assign
        v-gds-name = substitute( "&1>" , substring( temp-str.gds-name , 1 , ({&f-gds-name} - 1) ) )
      .
    end.
    else
    do:
      assign
        v-gds-name = temp-str.gds-name
      .
    end.
  if temp-str.list-doc = "" then do:
    display stream out-stream
      sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
      temp-str.artic
      v-gds-name @ temp-str.gds-name
      temp-str.fact-qnty
      temp-str.out-date
      temp-str.ms-base
      temp-str.obj-code
      temp-str.in-code
      temp-str.fact-date
      v-alc-mark-code @ temp-str.mark-code
    with frame f-doc.
    down stream out-stream with frame f-doc.
    {&PutExcel}
      temp-str.artic      {&tabulation}
      temp-str.gds-name   {&tabulation}
      temp-str.fact-qnty  {&tabulation}
      temp-str.out-date   {&tabulation}
      temp-str.ms-base    {&tabulation}
      temp-str.obj-code   {&tabulation}
      temp-str.fact-date  {&tabulation}
      temp-str.in-code    {&tabulation}
      temp-str.mark-code
    SKIP.
  end. /* temp-str.list-doc = "" */
  else do:
    assign
      v-doc-source      = temp-str.list-doc
      v-date-source     = temp-str.list-date
      v-ext-type-source = temp-str.ext-type
    .
    loop :
      repeat :
        assign
          v-doc   = entry( 1 , v-doc-source , {&list-doc-delim} )
          v-date  = date( entry( 1 , v-date-source , {&list-date-delim} ) )
          v-ext-type = entry( 1 , v-ext-type-source , {&list-doc-delim} )
        .
        if v-doc = "" then do:
          leave loop .
        end.
        else do:
          view stream out-stream frame BottomFrame .
          if v-log-first = yes then do:
            assign
              v-log-first = no
            .
            display stream out-stream
              sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
              temp-str.artic
              v-gds-name @ temp-str.gds-name
              temp-str.fact-qnty
              temp-str.out-date
              temp-str.ms-base
              temp-str.obj-code
              v-date @ temp-str.fact-date
              v-doc @ temp-str.in-code
              v-alc-mark-code @ temp-str.mark-code
            with frame f-doc.
            down stream out-stream with frame f-doc.
            {&PutExcel}
              temp-str.artic            {&tabulation}
              temp-str.gds-name         {&tabulation}
              temp-str.fact-qnty        {&tabulation}
              temp-str.out-date         {&tabulation}
              temp-str.ms-base          {&tabulation}
              temp-str.obj-code         {&tabulation}
              v-date format "99.99.99"  {&tabulation}
              v-doc                     {&tabulation}
              temp-str.mark-code
            SKIP.
          end.
          else do:
            display stream out-stream
              sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
              v-doc @ temp-str.in-code
              v-date @ temp-str.fact-date
            with frame f-doc.
            down stream out-stream with frame f-doc.
            {&PutExcel}
              " "   {&tabulation}
              " "   {&tabulation}
              " "   {&tabulation}
              " "   {&tabulation}
              " "   {&tabulation}
              " "   {&tabulation}
              v-date format "99.99.99" {&tabulation}
              v-doc {&tabulation}
              " "
            SKIP.
          end.
        end.
        assign
          v-doc-source      = substring( v-doc-source , length( v-doc ) + 2 )
          v-date-source     = substring( v-date-source , length ( string( v-date ) ) + 2 )
          v-ext-type-source = substring( v-ext-type-source , length ( v-ext-type ) + 2 )
        .
      END.
  end.
end.
end procedure.

procedure print-itog :
do
on error undo, return error return-value
:
{&PutExcel}
  " "           {&tabulation}
  " "           {&tabulation}
  " "           {&tabulation}
  " "           {&tabulation}
  " "           {&tabulation}
  " "           {&tabulation}
  " "           {&tabulation}
  " "           {&tabulation}
  " "
skip(1).
{&PutExcel}
  " "           {&tabulation}
  "Итого: "     {&tabulation}
  v-total-qnty format "->>>,>>>,>>>,>>9.99" {&tabulation}
  " "           {&tabulation}
  " "           {&tabulation}
  " "           {&tabulation}
  " "           {&tabulation}
  " "           {&tabulation}
  " "
SKIP.
put stream out-stream v-line at 1 format "X({&f-width})".
if line-counter( out-stream ) + 5 > page-size( out-stream ) then do :
  page stream out-stream.
  down stream out-stream with frame f-doc.
end.
put stream out-stream skip(2) "Итого: " at 19 v-total-qnty at 51 format "->>>,>>>,>>>,>>9.99" .
end.
end procedure. /* print-itog */