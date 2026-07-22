block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-alkout.p $
$Archive: rep/r-alkout.p $

Форма распоряжения на склад с акцизными марками

Автор: Хныкин Павел Андреевич
Дата создания: 01/19/06
Author: Pavel Khnykin
Creation date: 01/19/06

*/

do
on error undo, return error
:
define input parameter parParentProc  as widget-handle  no-undo.
define input parameter rec_id         as recid          no-undo.

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-alkout.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-alkout.p $":U .
define variable vss-description as character no-undo initial "Форма распоряжения на склад с акцизными марками":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ str/trdcalib.i }
{ rep/p-fmt.i    }
{ rep/fmtcli.i   }
{ gbl/clntattr.i }
{ rep/torgconf.i }
{ gbl/alc-lib.i  }

define variable g#report-num as integer   no-undo .
run get-report-num  in parParentProc ( output g#report-num ).

define variable g#quest-print as logical   no-undo .
run get-quest-print in parParentProc ( output g#quest-print ).

define variable g#gds-engl as logical   no-undo .
run get-gds-engl  in parParentProc ( output g#gds-engl ).

define variable g#log as logical   no-undo .

{ str/getctxtp.i def }
{ str/getctxtp.i get }

define temp-table temp-str no-undo
  field gds-name        like ub.goods.gds-name
  field fact-qnty       like ub.parts.fact-qnty
  field box-qnty        as integer
  field bottling-date   as date format "99.99.9999"
  field part-code       like ub.parts.part-code
  field mark-name       as character
  field in-code         like ub.parts.in-code
  field gds-code        like ub.goods.gds-code
  field ms-base         like ub.goods.ms-base
  index pi is primary gds-code bottling-date part-code in-code
.

define stream out-stream.

define buffer t-doc             for ub.trn-doc.
define buffer buf_parts         for ub.parts.
define buffer buf_parts-attr    for ub.parts-attr.
define buffer buf_goods         for ub.goods.
define buffer buf_doc-line      for ub.doc-line.
define buffer buf_clients       for ub.clients.
define buffer buf_our_object    for ub.clients.
define buffer buf_our_host      for ub.clients.

define variable sym1   as  character init  ":" no-undo.
define variable sym2   as  character init  ":" no-undo.
define variable sym3   as  character init  ":" no-undo.
define variable sym4   as  character init  ":" no-undo.
define variable sym5   as  character init  ":" no-undo.
define variable sym6   as  character init  ":" no-undo.
define variable sym7   as  character init  ":" no-undo.
define variable sym8   as  character init  ":" no-undo.
define variable v-line as  character init  ":" no-undo.

define variable v-line-num        as integer          no-undo.
define variable v-gds-name        as character        no-undo.
define variable v-box-qnty        as integer          no-undo.
define variable v-total-box-qnty  as integer          no-undo.
define variable v-total-qnty      as integer          no-undo.
define variable v-total-litre     as decimal          no-undo.
define variable v-bottling-date   as character        no-undo.
define variable v-parts-attr-ps   as character        no-undo.
define variable v-str             as character        no-undo.
define variable v-str-date        as character        no-undo.
define variable v-recipient     like ub.doc-attr.attr-value no-undo.
define variable v-auto          like ub.doc-attr.attr-value no-undo.
define variable v-host-code       as integer          no-undo.
define variable v-curr-code       as integer          no-undo .
define variable v-trdcattr-type   as character        no-undo initial {&type-char}.
define variable v-mark-name       as character        no-undo.

&scop f-width 114

define frame f-doc
  sym1 column-label ":!:" format "X(1)" space(0)
  v-line-num column-label "№!пп":C5 format ">>>>9" space(0)
  sym2 column-label ":!:" format "X(1)" space(0)
  temp-str.gds-name  column-label "Описание! ":C40 format "X(40)" space(0)
  sym3 column-label ":!:" format "X(1)" space(0)
  temp-str.fact-qnty column-label "Кол-во! ":C10 format "->>>>>9.99" space(0)
  sym4 column-label ":!:" format "X(1)" space(0)
  temp-str.box-qnty column-label "Ящики! ":C6 format ">>>>>9" space(0)
  sym5 column-label ":!:" format "X(1)" space(0)
  temp-str.bottling-date column-label "Дата!разлива":C11 format "99.99.9999" space(0)
  sym6 column-label ":!:" format "X(1)" space(0)
  temp-str.mark-name column-label "Коды!Спецмарок":C20 format "X(20)" space(0)
  sym7 column-label ":!:" format "X(1)" space(0)
  temp-str.in-code column-label  "№ документа!прихода":C14 format "X(14)" space(0)
  sym8 column-label ":!:" format "X(1)" space(0)
header
  string( "Страница " + string( PAGE-NUMBER( out-stream ), ">>9" ) ) at 99 format "X(13)" skip
  v-line format "X({&f-width})" at 1
with width {&A4_CW0} down stream-io.

define frame BottomFrame with width {&A4_CW0} down stream-io.
form header
        v-line format "X({&f-width})" at 1 SKIP
        "Продолжение - на следующей странице" at 1 SKIP
with frame BottomFrame width {&A4_CW0} PAGE-BOTTOM NO-LABELS NO-BOX .

{ gbl/working.i }
assign
  v-line = fill( "-" , 234)
.

find first t-doc no-lock
  where recid(t-doc) = rec_id
no-error.
if not available t-doc then do:
    message
             vss-workfile vss-revision vss-description
        skip "Не найден документ для печати."
        skip return-value
        skip trim(error-status :get-message(1))
             trim(error-status :get-message(2))
             trim(error-status :get-message(3))
    view-as alert-box error.
    undo, return error .
end.

/* ПЕЧАТЬ */
{ cmp/open-out.i stream out-stream " " }

for each temp-str:
  delete temp-str.
end.
for each buf_doc-line no-lock
        where buf_doc-line.doc-code  = t-doc.doc-code ,
     each buf_parts no-lock
        where buf_parts.obj-type     = buf_doc-line.obj-type
          and buf_parts.obj-code     = buf_doc-line.obj-code
          and buf_parts.artic        = buf_doc-line.artic
          and buf_parts.prod-type    = buf_doc-line.prod-type
          and buf_parts.prod-code    = buf_doc-line.prod-code
          and buf_parts.out-code     = buf_doc-line.doc-code
:
  find first buf_goods no-lock
        where buf_goods.artic        = buf_doc-line.artic
          and buf_goods.prod-type    = buf_doc-line.prod-type
          and buf_goods.prod-code    = buf_doc-line.prod-code
  .
  find first buf_parts-attr no-lock
      where buf_parts-attr.in-code    = buf_parts.in-code
        and buf_parts-attr.gds-code   = buf_goods.gds-code
        and buf_parts-attr.part-code  = buf_parts.part-code
  no-error.
  assign
    v-parts-attr-ps = ( if available buf_parts-attr then buf_parts-attr.ps else "")
  .
  assign
    v-gds-name = buf_goods.gds-name
    /*v-bottling-date = entry( 1 , v-parts-attr-ps , ";" )*/
    v-box-qnty = round( (buf_parts.fact-qnty / buf_goods.qnty-cart) , 0 )
  .
  run alc-lib_mark-name in this-procedure
         ( input  buf_parts.mark-db-num
         , input  buf_parts.mark-code
         , output v-mark-name
         ) .

  create temp-str.
  assign
    temp-str.gds-name      = buf_goods.gds-name
    temp-str.fact-qnty     = buf_parts.fact-qnty
    temp-str.box-qnty      = if v-box-qnty = ? then 0 else v-box-qnty
    temp-str.bottling-date = buf_parts.alc-bottling-date /*date( v-bottling-date )*/
    temp-str.part-code     = buf_parts.part-code
    temp-str.mark-name     = v-mark-name
    temp-str.in-code       = buf_parts.in-code
    temp-str.gds-code      = buf_goods.gds-code
    temp-str.ms-base       = buf_goods.ms-base
  .
end.
run print-title in this-procedure no-error.
for each temp-str no-lock
    break by gds-code
          by bottling-date
          by part-code
          by in-code
:
  run print-line in this-procedure no-error.
  accumulate
      temp-str.box-qnty  ( TOTAL )
      temp-str.fact-qnty ( TOTAL )
      temp-str.fact-qnty * temp-str.ms-base ( TOTAL )
  .
end.
assign
  v-total-box-qnty = accum TOTAL temp-str.box-qnty
  v-total-qnty     = accum TOTAL temp-str.fact-qnty
  v-total-litre    = accum TOTAL temp-str.fact-qnty * temp-str.ms-base
.
run print-itog in this-procedure no-error.
hide stream out-stream frame Bottomframe .
output stream out-stream close.
{ gbl/stopwork.i }
{ rep/q-print.i 4 }
end.

procedure print-title:

  define buffer buf_clients for ub.clients.
do
on error undo, return error
:
  { gbl/hostcode.i
    t-doc.obj-type
    t-doc.obj-code
    v-host-code
  }
  find first buf_clients    no-lock
       where buf_clients.obj-type = t-doc.cli-type
         and buf_clients.obj-code = t-doc.cli-code
  .
  find first buf_our_object no-lock
       where buf_our_object.obj-type = t-doc.obj-type
         and buf_our_object.obj-code = t-doc.obj-code
  .
  run torgconf-read in this-procedure (
      " "
    , input v-host-code
    , input t-doc.obj-type
    , input t-doc.obj-code
  ) no-error.
  if error-status :error
  then do:
      message  vss-workfile vss-revision vss-description
        skip "Ошибка чтения параметров печати формы."  skip "Форма будет напечатана с параметрами по умолчанию." skip return-value
        skip trim(error-status :get-message(1))  trim(error-status :get-message(2))   trim(error-status :get-message(3))
      view-as alert-box error.
  end.
  /*Код фирмы - в переменной v-torgconf-self-host-code*/
  run torgconf-get-self-param in this-procedure ( input t-doc.obj-type, input t-doc.obj-code, input v-curr-code) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description   skip "Ошибка чтения параметров объекта документа."  skip return-value
      skip trim(error-status :get-message(1))   trim(error-status :get-message(2))  trim(error-status :get-message(3))
    view-as alert-box warning.
  end.

  find first buf_our_host   no-lock
       where buf_our_host.obj-type = {&cmp}
         and buf_our_host.obj-code = v-torgconf-self-host-code
  .
   define variable  v-recipient-code as character no-undo .
  { str/tdat-val.i t-doc.doc-code {&trdcattr-recipient} v-recipient-code v-trdcattr-type no-error }
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры tdat-val":U skip
      "Документ: " t-doc.doc-code skip
      "Атрибут: " {&trdcattr-recipient} skip
      "Значение: " v-recipient skip
      trim( error-status :get-message (1) ) skip
      return-value skip
      view-as alert-box error.
    undo, return error return-value.
  end.

  define buffer bufr_clients for ub.clients  .
  define variable v-type-rec as character no-undo .
  define variable v-code-rec as integer   no-undo .

  assign
    v-recipient  = v-recipient-code
    v-type-rec = substring(v-recipient-code,1,3)
    v-code-rec  = int(substring(v-recipient-code,4,15))
    no-error
  .
  if v-type-rec = ? then v-type-rec = "" .
  if v-code-rec  = ? then v-code-rec  =  0 .
  find first bufr_clients no-lock where
             bufr_clients.obj-type = v-type-rec  and
             bufr_clients.obj-code =  v-code-rec  no-error .

  if available bufr_clients then v-recipient  = bufr_clients.obj-name.

  { str/tdat-val.i t-doc.doc-code {&trdcattr-auto} v-auto v-trdcattr-type no-error }
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка привызове процедуры tdcat-val":U skip
      "Документ: " t-doc.doc-code skip
      "Атрибут: " {&trdcattr-auto} skip
      "Значение: " v-auto skip
      trim( error-status :get-message(1)  ) skip
      return-value skip
      view-as alert-box error.
    undo, return error return-value.
  end.
  run w-date in this-procedure (input t-doc.doc-date , output v-str-date ) no-error.
  assign
    v-auto = "Автомобиль: " + v-auto
  .
  put stream out-stream
    string("РАСПОРЯЖЕНИЕ НА СКЛАД № " + string( t-doc.doc-code )) at 49 format "X(40)"  v-str-date at right-field( {&f-width} , length( v-str-date ) ) format "X(20)" skip
    buf_our_host.obj-name at right-field( {&f-width} , length( buf_our_host.obj-name ) ) skip
    string( "Организация: " + string( buf_clients.obj-name ) + " (" + string( buf_clients.obj-code ) + ")" ) at 5   format "X(112)" skip
    string( "Получатель: " + string( v-recipient )) at 5 format "X(70)"
    v-auto at right-field( {&f-width} , length( v-auto ) ) format "X(40)" skip
  .
end.
end procedure. /* print-title */

procedure print-line:
do
on error undo, return error
:
  view stream out-stream frame BottomFrame .
  assign
    v-line-num = v-line-num + 1
  .
  display stream out-stream
    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8
    v-line-num
    temp-str.gds-name
    temp-str.fact-qnty
    temp-str.mark-name
    temp-str.in-code
    temp-str.box-qnty when temp-str.box-qnty > 0
    temp-str.bottling-date
  with frame f-doc.
  down stream out-stream with frame f-doc.
end.
end procedure. /* print-line */

procedure print-itog:
do
on error undo, return
:
  run check-bottom in this-procedure (8).
  put stream out-stream v-line format "X({&f-width})" at 1 skip.
  display stream out-stream
    sym1 sym3 sym4 sym5 sym8
    v-total-qnty @ temp-str.fact-qnty
    v-total-box-qnty @ temp-str.box-qnty
    fill(" ", 35) + "Итого"  @ temp-str.gds-name
  with frame f-doc.
  put stream out-stream v-line format "X({&f-width})" at 1 skip(2)
                        string( "Менеджер " + fill( '_' , 40 ) ) at 5 format "X(50)" skip(2)
                        string( "Выдал " + fill( '_' , 43 ) ) at 5 format "X(50)" string( "Получил " + fill( '_' , 40 ) ) at 60 format "X(50)" skip(2)
                        "Общее количество продукции в литрах "  at 5 v-total-litre format "->>>>>9.99".
  .
end.
end procedure. /* print-itog */

/* Проверка конца страницы */
procedure check-bottom :
define input parameter num_lines as integer no-undo.
do
on error undo, return error :
  if num_lines < 2 then do:
    assign
      num_lines = 2
    .
  end.
  if line-counter( out-stream) + num_lines >= page-size( out-stream ) then do :
    view stream out-stream frame BottomFrame .
    page stream out-stream.
  end.
end.
end. /* check-bottom */

/* Переводит дату в строку с месяцем прописью  01.01.2005 -> 01 января 2006 г. */
procedure w-date:
do
on error undo, return error
:
  define input parameter v-date as date no-undo.
  define output parameter str-date as character no-undo.
  define variable month-str as character init "января;февраля;марта;апреля;мая;июня;июля;августа;сентября;октября;ноября;декабря":U no-undo.
  assign
    str-date = string( DAY( v-date ) ) + " " + entry( month( v-date ) , month-str , ";" ) + " " + string( year( v-date ) ) + " г."
  .
end.
end procedure. /* w-date */