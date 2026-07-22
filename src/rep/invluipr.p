block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: invluipr.p $
$Archive: rep/invluipr.p $

печать из экрана инвентаризации со сравнением

Автор: Суслов Алексей Юрьевич
Дата создания: 09/08/05
Author: Alexey Suslov
Creation date: 09/08/05

*/
DEFINE TEMP-TABLE tt-result NO-UNDO
FIELD artic LIKE ub.goods.artic
FIELD prod-type LIKE ub.goods.prod-type
FIELD prod-code LIKE ub.goods.prod-code
FIELD node-code  LIKE ub.gds-prt.node-code
FIELD gds-name  LIKE ub.goods.gds-name
FIELD b-code    LIKE ub.bar-code.b-code
FIELD scan-1 AS DECIMAL INITIAL ?
FIELD scan-2 AS DECIMAL INITIAL ?
FIELD diff-1-2 AS CHARACTER
FIELD scan-3 AS CHARACTER INITIAL "":u
FIELD itog AS DECIMAL INITIAL ?
INDEX pi IS UNIQUE PRIMARY artic prod-type prod-code node-code
INDEX artic artic
INDEX itog itog.


define input  parameter parParentProc  as widget-handle no-undo.
define input parameter table for tt-result.

{ cmp/str-glbl.i  }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ cmp/r-page1.i  }
{ cmp/breakstr.i }
{ gbl/cur-time.i }
{ rep/f-fdec.i   }
{ gbl/paramls.i  }
&scop gds-len 40
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: invluipr.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/invluipr.p $":U .
def var vss-description as character no-undo init "печать из экрана инвентаризации со сравнением".
{ cmp/vssrevis.i }

define variable g#report-num as integer   no-undo .
run get-report-num  in parParentProc ( output g#report-num ).



def var LineBuf  as char  no-undo.
def var Line     as char  no-undo.
def var UndLine  as char  no-undo.
def var Lines_Counter as   int  init 0  no-undo.
def var Tmp_Counter   as   int  init 0  no-undo.
define stream  OutStream .
define stream  macr_excel.
define variable v-file-name as character no-undo .
define variable v-ind       as integer   no-undo .
define variable C-str  as character no-undo .
def var sym1 as char  init ":"   no-undo.
def var sym2 as char  init ":"   no-undo.
def var sym3 as char  init ":"   no-undo.
def var sym4 as char  init ":"   no-undo.
def var sym5 as char  init ":"   no-undo.
define variable vartemp-string as character no-undo.
define variable num#col#    as integer no-undo .
define variable summ   as decimal no-undo .
define variable num-ln as integer no-undo .
define variable var-1  as integer no-undo .
define variable var-2  as integer no-undo .
define variable C-c    as integer no-undo .
define variable str--1 as character Format "x(60)" no-undo.
define variable str--2 as integer no-undo .
define variable C-i    as integer no-undo .
define variable p-var  as integer no-undo .
define variable v-user-action as character no-undo .
define variable v-printed     as logical   no-undo .
DEFINE FRAME print-diff
    sym1 column-label ":"  format "X(1)" space(0)
    tt-result.b-code COLUMN-LABEL "Бар-код":C9 format "999999999" space(0)
    sym2 column-label ":"  format "X(1)" space(0)
    tt-result.artic COLUMN-LABEL "Артикул":C40 format "X(16)" space(0)
    Sym3 column-label ":" format "X(1)" space(0)
    tt-result.gds-name COLUMN-LABEL "Наименование товара":C40 format "X(40)" space(0)
    Sym4 column-label ":" format "X(1)" space(0)
    vartemp-string COLUMN-LABEL "Количество":C13 format "X(20)" space(0)
    Sym5 column-label ":" format "X(1)" space(0)
    HEADER
    string( "Лист " + string( PAGE-NUMBER(OutStream) , ">>>>9") ) AT 70 format "X(13)" SKIP
    Line format "X(114)" AT 1
    with width {&DOS_CW_2} down stream-io use-text NO-BOX.
  if session:set-wait-state("compiler") then.

  { cmp/open-out.i STREAM OutStream " " {&LS_PS_A4}  }
  define variable v-prn0 as character no-undo .

  assign
    Line    = fill("-", 230)
    UndLine = fill("_", 230)
    LineBuf = fill("_", 240)
  .
{ rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
{ rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */
/*-----------------------------------------------------------------------------------------------------------------------*/
v-ind = 0    .
FORM with frame print-diff .
 Output stream Macr_Excel close .
 run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
 output stream macr_excel to value(v-file-name)   .
assign
  num#str# = 0 .
assign
  v-ind = v-ind + 1.

run PrintTitul in this-procedure .
for each tt-result where tt-result.scan-1 <> tt-result.scan-2 use-index artic:
    run print-line in this-procedure .
end.
/* ... Подвал. --- */
put stream OutStream Line format "X(114)".
run on-same-page in this-procedure (input 15) .
page stream OutStream .

run paramls-write in this-procedure
  (input "file"
  ,input "Разница":u
  ,input v-file-name
  ) .


HIDE STREAM OutStream FRAME print-diff.
HIDE stream OutStream FRAME BottomFrame .
HIDE stream OutStream FRAME BottomFrame2 .
output stream OutStream CLOSE .
Output stream Macr_Excel  close .

{ rep/repfrm.i off } /* Показать окно информации о текущем процессе */

run paramls-write in this-procedure
    (input "charcol"
    ,input ""
    ,input "1"
    ) .

run end-proc .

  define variable DisabledOptions as integer   no-undo .
  DisabledOptions = 0 .

  run gbl/prnfilen.w
    (input  ""
    ,input  DisabledOptions
    ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
    , 7
    ,output v-user-action
    ,output v-printed
    ) .

/* *************************************************************************************************** */
procedure print-line :
  do on error undo, return error return-value :
  assign
     Lines_Counter = Lines_Counter + 1
    .

  if line-counter( OutStream ) + 2 > page-size( OutStream ) then page stream OutStream.

  if line-counter( OutStream ) < Tmp_Counter then
    assign
    .

  assign
    Tmp_Counter  = line-counter( OutStream )
    num-ln = num-ln + 1
  .
num#str# = num#str# + 1.
num#col# = 1.
run macr_excel_char( string(tt-result.b-code)   , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char( tt-result.artic    , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char( tt-result.gds-name , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
  display stream OutStream
    sym1 tt-result.b-code
    sym2 tt-result.artic
    sym3 tt-result.gds-name
    sym4
    sym5
    with FRAME print-diff.
  DOWN stream OutStream 1 with FRAME print-diff.
end.
end procedure. /* print-line */
procedure PrintTitul :
  do  on error undo, return error return-value  :
  define variable cc as integer no-undo .
  define variable tt as integer no-undo .
    /* ---------------- Создание заголовка :--------------------------------------------------------------------------- */
      PUT STREAM OutStream
        space(5) string( "Отчет расхождений по инвентаризации со сравнением" ) format "x(50)" skip
        space(5) cur-time-date() format "X(20)"
        skip .
      .

    num#str# = num#str# + 1.
    num#col# = 2.
    cc = num#str# .
    run macr_excel_char( "Отчет расхождений по инвентаризации со сравнением"    , num#str# , num#col#   ) .
    num#str# = num#str# + 1.
    num#col# = 2.
    run macr_excel_char( cur-time-date()   , num#str# , num#col#   ) .
    run macr_cell_format
    ( 20    ,      /* p-size     */
      true  ,      /* p-bold     */
      false  ,      /* p-italic   */
      ?    ,      /* p-color-bg */
      cc ,      /* p-row      */
      2 ,      /* p-col      */
      num#str# ,   /* p-row-2    */
      2 ) . /* p-col-2    */

    num#str# = num#str# + 1.
    num#col# = 1.
    tt = num#str#  .
    run macr_excel_char( "Бар-код"   , num#str# , num#col#   ) .
    run macr_cell_size ( 10 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 2.
    run macr_excel_char( "Артикул"   , num#str# , num#col#   ) .
    run macr_cell_size ( 21 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 3.
    run macr_excel_char( "Наименование товара"   , num#str# , num#col#   ) .
    run macr_cell_size ( 40 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 4.
    run macr_excel_char( "Количество"   , num#str# , num#col#   ) .
    run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
    run macr_cell_format
    ( 12    ,      /* p-size     */
      true  ,      /* p-bold     */
      false  ,      /* p-italic   */
      ?    ,      /* p-color-bg */
      num#str# ,      /* p-row      */
      1 ,      /* p-col      */
      num#str# ,   /* p-row-2    */
      4 ) . /* p-col-2    */

     put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , tt , 1 , num#str# ,  num#col# ) + {&new-line}  +
       'BORDER( 2 , 2 , 2 , 2 , 2 , ,0,0,0,0,0) '  + {&new-line} +
       'ALIGNMENT(3 , , 4 , 4 ,)'  + {&new-line}
       .
  end.
end procedure. /* PrintTitul */

PROCEDURE on-same-page :
  define input parameter p-line-number as integer  no-undo .
  if p-line-number > page-size( OutStream ) then return .
  if line-counter( OutStream ) + p-line-number > page-size( OutStream ) then  page stream OutStream .
end procedure. /* on-same-page */

{ rep/r-libmcr.i macr_excel         }