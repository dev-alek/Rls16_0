block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Печать товарной спецификации к договору

Автор: Демин Алексей Сергеевич
Дата создания: 09/14/05
Author: Alexey Demin
Creation date: 09/14/05

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input  parameter p-host-code    as integer   no-undo .
define input  parameter p-doc-num      as integer   no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Печать товарной спецификации к договору" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ gbl/waitfram.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i   }
{ gbl/prn-lib.i  }
{ cmp/r-page1.i NEW }

/*define variable v-delim as character no-undo .*/
/*define variable v-del-1 as character no-undo .*/
/*define variable v-sdate as character no-undo .*/
/*define variable v-shortdate as character no-undo .*/
/*run gbl/getlocal.p ( output v-delim  , output v-del-1, output v-sdate, output v-shortdate ) no-error .*/
/*if error-status :error then do:*/
/*  message error-status :error error-status :get-message(1) v-delim v-del-1.*/
/*  v-delim = ','  .*/
/*end.*/
define variable g#report-num as integer   no-undo .
run get-report-num in parParentProc ( output g#report-num ).
{ rep/f-fdec.i   }   /* Функции для форматирования полей для передачи в EXcel         */
{ gbl/paramls.i  }
{ rep/mcrexcel.i }
/*{ gbl/getcntxt.i def }*/

  define buffer buf_contract-specif  for ub.contract-specif .
  define buffer buf_contract     for ub.contract .

  define variable v-ind as integer   no-undo .
  define variable v-row as integer   no-undo .
  define variable v-col as integer   no-undo .

  { gbl/working.i }

  /* macr_excel - для экселя */
  assign
    v-file-name = string( session:temp-directory + {&DF_Name} + string( g#report-num ) )  + ".txt"
    make-excel = yes
  .
  output stream macr_excel to value(v-file-name) .
  assign v-ind = v-ind + 1 .

  define variable Line as character no-undo .
  assign Line = fill("-", 199) .

  DEFINE VARIABLE sym1  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U COLUMN-LABEL ":!:".
  DEFINE VARIABLE sym2  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U COLUMN-LABEL ":!:".
  DEFINE VARIABLE sym3  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U COLUMN-LABEL ":!:".
  DEFINE VARIABLE sym4  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U COLUMN-LABEL ":!:".
  DEFINE VARIABLE sym5  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U COLUMN-LABEL ":!:".
  DEFINE VARIABLE sym6  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U COLUMN-LABEL ":!:".
  DEFINE VARIABLE sym7  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U COLUMN-LABEL ":!:".
  DEFINE VARIABLE sym8  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U COLUMN-LABEL ":!:".
  DEFINE VARIABLE sym9  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U COLUMN-LABEL ":!:".
  DEFINE VARIABLE sym10 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U COLUMN-LABEL ":!:".
  DEFINE VARIABLE sym11 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U COLUMN-LABEL ":!:".
  DEFINE VARIABLE sym12 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U COLUMN-LABEL ":!:".
  DEFINE VARIABLE sym13 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U COLUMN-LABEL ":!:".
  DEFINE VARIABLE sym14 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U COLUMN-LABEL ":!:".

  define variable b-code as character no-undo .

  DEFINE frame f-doc
    sym1  b-code                            COLUMN-LABEL '   Код! '            Format "X(12)"                          space(0)
    sym2  buf_contract-specif.artic         COLUMN-LABEL '  Артикул! '         format "x(12)"                          space(0)
    sym3  buf_contract-specif.gds-name      COLUMN-LABEL 'Наименование! '      format "x(41)"                          space(0)
    sym4  buf_contract-specif.unit-base     COLUMN-LABEL "Ед.!изм"             format "x(4)"                           space(0)
    sym5  buf_contract-specif.cli-base-rate COLUMN-LABEL 'Коэф.! '             format ">>,>>9.<<<<"                    space(0)
    sym6  buf_contract-specif.unit-cli      COLUMN-LABEL "Ед.изм!пост."        format "x(4)"                           space(0)
    sym7  buf_contract-specif.qnty          COLUMN-LABEL 'Количество  ! '      Format ">,>>>,>>>,>>9.<<<"              space(0)
    sym8  buf_contract-specif.price-cli     COLUMN-LABEL 'Цена      !поставки     '    Format ">>,>>>,>>>,>>9.99"              space(0)
    sym9  buf_contract-specif.prc           COLUMN-LABEL '%    !отклон.'         Format "->>>9.99"                       space(0)
    sym10 buf_contract-specif.sum-cli       COLUMN-LABEL 'Сумма      !поставки     ' Format ">>>>,>>>,>>>,>>9.99"            space(0)
    sym11 buf_contract-specif.vat-pc        COLUMN-LABEL '% НДС ! '            Format "->>>9.99"                       space(0)
    sym12 buf_contract-specif.vat-type      COLUMN-LABEL ' тип ! НДС'          Format "X(7)"                           space(0)
    sym13 buf_contract-specif.income-qnty   COLUMN-LABEL 'Принято    ! '       Format ">,>>>,>>>,>>9.<<<"              space(0)
    sym14
  HEADER
        string( "Дата печати : " + string(TODAY , "99.99.9999") + " , " + string(TIME, "HH:MM") ) AT 5 format "X(90)"
        string( "Страница " + string( PAGE-NUMBER( PrnLibStream )  , ">>9") ) AT 150 format "X(15)" SKIP
        Line format "X(196)" AT 1
  with width {&A4_LS}  down stream-io.

  run prn-lib-open-stream  in this-procedure (input parParentProc,input {&LS_PS_A4},input yes,input no).

  FORM HEADER
      Line format "X(196)" AT 1 SKIP
      "Продолжение - на следующей странице" AT 30 SKIP
      with FRAME BottomFrame width {&A4_LS} PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW stream PrnLibStream FRAME BottomFrame .

  FORM with FRAME f-doc .

  find first buf_contract no-lock where buf_contract.host-code = p-host-code and buf_contract.contract-code = p-doc-num .
  PUT stream PrnLibStream  SPACE(60) string("Товарная спецификация к договору " + buf_contract.contract-prn-code + " от " + string(buf_contract.contract-date,"99/99/9999")) format "X(100)"  SKIP .

  run PutColumnTitulExcel in this-procedure .

  FOR EACH buf_contract-specif NO-LOCK where buf_contract-specif.host-code = p-host-code and buf_contract-specif.contract-num = p-doc-num :
    { gbl/gdsbcode.i  buf_contract-specif.gds-code  ?  b-code  no-error }
    display stream PrnLibStream
      sym1  b-code
      sym2  buf_contract-specif.artic
      sym3  buf_contract-specif.gds-name
      sym4  buf_contract-specif.unit-base
      sym5  buf_contract-specif.cli-base-rate
      sym6  buf_contract-specif.unit-cli
      sym7  buf_contract-specif.qnty
      sym8  buf_contract-specif.price-cli
      sym9  buf_contract-specif.prc
      sym10 buf_contract-specif.sum-cli
      sym11 buf_contract-specif.vat-pc
      sym12 buf_contract-specif.vat-type
      sym13 buf_contract-specif.income-qnty
      sym14
    with frame f-doc.
    down stream PrnLibStream with frame f-doc .

    assign v-col = 1 .
    run macr_excel_char( b-code                           , v-row, v-col) .     assign v-col = v-col + 1 .
    run macr_excel_char( buf_contract-specif.artic        , v-row, v-col) .     assign v-col = v-col + 1 .
    run macr_excel_char( buf_contract-specif.gds-name     , v-row, v-col) .     assign v-col = v-col + 1 .
    run macr_excel_char( buf_contract-specif.unit-base    , v-row, v-col) .     assign v-col = v-col + 1 .
    run macr_excel_sum ( buf_contract-specif.cli-base-rate, v-row, v-col, 4) .  assign v-col = v-col + 1 .
    run macr_excel_char( buf_contract-specif.unit-cli     , v-row, v-col) .     assign v-col = v-col + 1 .
    run macr_excel_sum ( buf_contract-specif.qnty         , v-row, v-col, 3) .  assign v-col = v-col + 1 .
    run macr_excel_sum ( buf_contract-specif.price-cli    , v-row, v-col, 2) .  assign v-col = v-col + 1 .
    run macr_excel_sum ( buf_contract-specif.prc          , v-row, v-col, 2) .  assign v-col = v-col + 1 .
    run macr_excel_sum ( buf_contract-specif.sum-cli      , v-row, v-col, 2) .  assign v-col = v-col + 1 .
    run macr_excel_sum ( buf_contract-specif.vat-pc       , v-row, v-col, 2) .  assign v-col = v-col + 1 .
    run macr_excel_char( buf_contract-specif.vat-type     , v-row, v-col) .     assign v-col = v-col + 1 .
    run macr_excel_sum ( buf_contract-specif.income-qnty  , v-row, v-col, 3) .  assign v-col = v-col + 1 .

    assign  v-row = v-row + 1 .
    if  ( v-row ) >= 63000 then do:
      Output stream Macr_Excel  close .
      /*Запишем в файл параметров */
      run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name ) .
      /* создаем временный файл */
      run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
      output stream  Macr_Excel to value(v-file-name) .
      assign
        v-ind = v-ind + 1
        v-row = 2
      .
      run PutColumnTitulExcel in this-procedure .
    end.

  end.
  PUT STREAM PrnLibStream Line format "X(196)".

  HIDE stream PrnLibStream FRAME BottomFrame .
  OUTPUT stream PrnLibStream CLOSE.

  output stream macr_excel close .
  run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name) .
  run end-proc .

  { gbl/stopwork.i }

  run prn-lib-prn-file in this-procedure (input parParentProc,input 8).




procedure PutColumnTitulExcel : /* заголовки для колонок экселя */
  do
  on error undo, return error return-value
  :
    assign
      v-row = 1
      v-col = 1
    .
    run macr_excel_char (string("Товарная спецификация к договору " + buf_contract.contract-prn-code + " от " + string(buf_contract.contract-date,"99/99/9999")), v-row, 1) .
    run macr_cell_format ( 11, yes, no, ?, 1, 1, 1, 1) .
    assign  v-row = v-row + 1 .
    run macr_excel_char("Код",            v-row, 1) .    run macr_cell_size (15,?, v-row, 1,?,?).
    run macr_excel_char("Артикул",        v-row, 2) .    run macr_cell_size (15,?, v-row, 2,?,?).
    run macr_excel_char("Наименование",   v-row, 3) .    run macr_cell_size (50,?, v-row, 3,?,?).
    run macr_excel_char("Ед. изм",        v-row, 4) .    run macr_cell_size (10,?, v-row, 4,?,?).
    run macr_excel_char("Коэф.",          v-row, 5) .    run macr_cell_size (10,?, v-row, 5,?,?).
    run macr_excel_char("Ед.изм пост.",   v-row, 6) .    run macr_cell_size (10,?, v-row, 6,?,?).
    run macr_excel_char("Количество",     v-row, 7) .    run macr_cell_size (15,?, v-row, 7,?,?).
    run macr_excel_char("Цена поставки",  v-row, 8) .    run macr_cell_size (15,?, v-row, 8,?,?).
    run macr_excel_char("% отклон.",      v-row, 9) .    run macr_cell_size (15,?, v-row, 9,?,?).
    run macr_excel_char("Сумма поставки", v-row, 10) .   run macr_cell_size (15,?, v-row, 1,?,?).
    run macr_excel_char("% НДС",          v-row, 11) .   run macr_cell_size (10,?, v-row, 1,?,?).
    run macr_excel_char("тип НДС",        v-row, 12) .   run macr_cell_size (10,?, v-row, 1,?,?).
    run macr_excel_char("Принято",        v-row, 13) .   run macr_cell_size (15,?, v-row, 1,?,?).

    run macr_cell_bordur  (v-row, 1, v-row, 13) .
    run macr_cell_format( 10, yes, no,  35, v-row, 1, v-row, 13) . /*?-35*/
    assign  v-row = v-row + 1 .
  end.
end procedure. /* PutColumnTitulExcel */