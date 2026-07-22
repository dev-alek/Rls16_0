block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cliartpr.p $
$Archive: str/cliartpr.p $

Печать списка товаров с артикулами поставщика по списку поставщиков.

Автор: Хныкин Павел Андреевич
Дата создания: 11/28/05
Author: Pavel Khnykin
Creation date: 11/28/05

*/

define input parameter parparentproc as widget-handle no-undo .
define output parameter p-frame-width as int no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cliartpr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/cliartpr.p $":U .
define variable vss-description as character no-undo init "Печать списка товаров с артикулами поставщика по списку поставщиков".
{ cmp/vssrevis.i             }
{ cmp/str-glbl.i             }
{ cmp/r-pril.i new           }
{ cmp/cli-list.i cli-list def shared }
{ cmp/r-page1.i              }
assign
  my-handle = parparentproc
.
{ rep/rep-bt.i               }
{ gbl/cur-time.i             }
{ rep/dincol.i def           }
{ rep/opclexcl.i             }
{ gbl/waitfram.i }
{ gbl/prn-lib.i }


define buffer buf_cli-list  for cli-list.
define buffer buf_goods     for ub.goods.
define buffer buf_cli-gds   for ub.cli-gds.

define variable sym1              as char     init ":"  no-undo.
define variable sym2              as char     init ":"  no-undo.
define variable sym3              as char     init ":"  no-undo.
define variable sym4              as char     init ":"  no-undo.

define variable v-single-line     as char               no-undo.
define variable v-under-line      as char               no-undo.
define variable v-merge-cols      as char     init "/"  no-undo.
define variable v-notes           as char               no-undo.
define variable ii                as integer no-undo .

do
on error undo, return error
:
assign
  v-notes = cur-time-print()
.
&scop f-obj-name  92
&scop f-gds-name  50
&scop f-artic     20
&scop f-cli-art   20
&scop f-width     94
&scop ReportName "Список товаров по поставщикам с артикулами поставщика"

define frame f-doc
        sym1 column-label ":!:!" format "X(1)" space(0)
        buf_goods.gds-name COLUMN-LABEL "Наименование товара! " format "X({&f-gds-name})" space(0)
        sym2 column-label ":!:!" format "X(1)" space(0)
        buf_goods.artic COLUMN-LABEL "Артикул! " format "X({&f-artic})" space(0)
        sym3 column-label ":!:!" format "X(1)" space(0)
        buf_cli-gds.cli-art COLUMN-LABEL "Артикул поставщика! " format "X({&f-cli-art})" space(0)
        sym4 column-label ":!:!" format "X(1)" space(0)
    header
        v-notes at 2 format "X(35)" string( "Страница " + string( PAGE-NUMBER( PrnLibStream ), ">>9" ) ) at 83 format "X(13)" SKIP
        v-single-line format "X({&f-width})" at 1
    with width {&DOS_CW} down stream-io.
form header
        v-single-line format "X({&f-width})" at 1 SKIP
        "Продолжение - на следующей странице" at 1 SKIP
    with frame BottomFrame width {&DOS_CW} PAGE-BOTTOM NO-LABELS NO-BOX .

DEFINE VARIABLE t-1 AS CHARACTER INITIAL "||||"
     VIEW-AS EDITOR
     SIZE 1 BY 5 NO-UNDO.

DEFINE FRAME top-frame
t-1       AT ROW 1 COL 1 no-label
HEADER
v-notes AT 5 format "x(35)"
string( "Страница" ) AT 45 PAGE-NUMBER( PrnLibStream ) AT 55 FORMAT ">>>,>>9" SKIP
    with width {&DOS_CW_2} down stream-io use-text NO-BOX.

DEFINE FRAME x1
with width {&DOS_CW_2} down stream-io use-text NO-BOX.

assign
  use-column[1] = yes
  use-column[2] = yes
  use-column[3] = yes
  use-column[4] = yes
  p-frame-width = {&f-width}
.

FOR EACH sheetf where sheetf.sheet-num > 1:
  delete sheetf.
end.
FIND FIRST sheetf where
           sheetf.sheet-num = 1 No-ERROR.

assign
ReportName = {&ReportName}
sheetf.Excel-Column-Lable =  ""
sheetf.sizes = ""
Make-Excel = yes
.
CREATE WIDGET-POOL "My-pool" PERSISTENT no-error .
l-col-pos = 1.
assign
  l-col-type = "CHARACTER"
  l-col-len = {&f-gds-name}
  l-col-format = "x({&f-gds-name})"
  l-col-lable = "Наименование товара"
.
{ rep/dincol.i cr  1 v-gds-name x1 }
{ rep/dincol.i crx 1 }

assign
  l-col-type = "CHARASTER"
  l-col-len = {&f-artic}
  l-col-format = "x({&f-artic})"
  l-col-lable = "Артикул"
.
{ rep/dincol.i cr  2 v-artic x1 }
{ rep/dincol.i crx 2 }

assign
  l-col-type = "CHARASTER"
  l-col-len = {&f-cli-art}
  l-col-format = "x({&f-cli-art})"
  l-col-lable ="Артикул поставщика"
.
{ rep/dincol.i cr  3 v-cli-art x1 }
{ rep/dincol.i crx 3 }

assign
  l-col-type = "CHARASTER"
  l-col-len = {&f-gds-name}
  l-col-format = "X({&f-gds-name})"
  l-col-lable = "Поставщик"
.
{ rep/dincol.i cr  4 v-cli-obj-name x1 }
{ rep/dincol.i crx 4 }

v-single-line = fill( "-" , 230 ).
run waitfram-show in this-procedure ( "Ждите..." ).
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&CS_PS}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

if not valid-handle(my-handle) then do:
  assign
  my-handle = parparentproc.
end.
run get-report-num in parparentproc(output g#report-num).


RUN OpenForExcel in this-procedure .
run rep/extitle.p ( 1 ) .

put stream PrnLibStream {&ReportName} at 21 skip.
form with frame f-doc.

for each buf_cli-list no-lock ,
    each buf_cli-gds no-lock
          where   buf_cli-gds.cli-type  = buf_cli-list.obj-type
              and buf_cli-gds.cli-code  = buf_cli-list.obj-code
              and buf_cli-gds.cli-art   <> ""
              and buf_cli-gds.cli-art   <> ? ,
    each buf_goods no-lock
          where buf_goods.artic     = buf_cli-gds.artic
              and buf_goods.prod-type = buf_cli-gds.prod-type
              and buf_goods.prod-code = buf_cli-gds.prod-code
    break by buf_cli-list.obj-name
    :
      if first-of( buf_cli-list.obj-name ) then do :
        run check-bottom in this-procedure ( 5 ) .
        if not first( buf_cli-list.obj-name ) and line-counter( PrnLibStream ) <> 1 then do :
          put stream PrnLibStream v-single-line format "X({&f-width})".
        end.
        run print-obj-name in this-procedure.
      end.
      run print-line in this-procedure.
end. /* for each buf_cli-list*/
run print-itog in this-procedure.
hide stream PrnLibStream frame BottomFrame.
hide stream PrnLibStream frame f-doc.
output stream PrnLibStream close.
{&CloseExcel}
delete widget-pool "My-pool".
run waitfram-hide in this-procedure .
end.

/* Печать линии документа */
procedure print-line :
do
on error undo, return error :
  run check-bottom in this-procedure ( 0 ).
  display stream PrnLibStream
    buf_goods.gds-name
    buf_goods.artic
    buf_cli-gds.cli-art
    sym1 sym2 sym3 sym4
  with frame f-doc.
  down stream PrnLibStream with frame f-doc.
      { rep/dincol.i di 1 v-gds-name buf_goods.gds-name }
      { rep/dincol.i di 2 v-artic buf_goods.artic }
      { rep/dincol.i di 3 v-cli-art buf_cli-gds.cli-art }
      { rep/dincol.i di 4 v-cli-obj-name buf_cli-list.obj-name}
      {&PutExcel}
      { rep/dincol.i dix 1 v-gds-name buf_goods.gds-name }
      { rep/dincol.i dix 2 v-artic buf_goods.artic }
      { rep/dincol.i dix 3 v-cli-art buf_cli-gds.cli-art }
      { rep/dincol.i dix 4 v-cli-obj-name buf_cli-list.obj-name}
      skip.
end.
end procedure. /* print-line */

/* Печать поставщика */
procedure print-obj-name :
do
on error undo, return error :
  display stream PrnLibStream
    buf_cli-list.obj-name @ buf_goods.gds-name
    sym1 sym4
  with frame f-doc.
  put stream PrnLibStream v-single-line format "X({&f-width})" skip.
end.
end. /* print-obj-name*/

/* Печать итога по отчету */
procedure print-itog :
do
on error undo, return error :
put stream PrnLibStream v-single-line format "X({&f-width})".
end.
end. /* print-itog */

/* Проверка конца страницы */
procedure check-bottom :
define input parameter num_lines as integer no-undo.
do
on error undo, return error :
  if line-counter( PrnLibStream) + num_lines > page-size( PrnLibStream ) then do :
    view stream PrnLibStream frame BottomFrame .
    page stream PrnLibStream.
  end.
end.
end.