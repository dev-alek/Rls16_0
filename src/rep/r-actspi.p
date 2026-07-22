block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-actspi.p $
$Archive: rep/r-actspi.p $

Печать акта списания материалов

Автор: Булгаков Андрей Николаевич
Дата создания: 09/14/05
Author: Andrew Bulgakoff
Creation date: 09/14/05

*/

/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER p-parent-proc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-rec-id      AS RECID         NO-UNDO.

/* VSS Variables Definitions */
DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INITIAL "$Revision: aea5316774be, 0, rls $":U.
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INITIAL "$Author: expertek $":U.
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INITIAL "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INITIAL "$Workfile: r-actspi.p $":U.
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INITIAL "$Archive: rep/r-actspi.p $":U.
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INITIAL "печать акта списания материалов":U.

/* Local Variable Definitions ---                                       */
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ gbl/prn-lib.i  }
{ gbl/waitfram.i }
{ str/clcprtsl.i }
{ gbl/word-sum.i }

/* ********************  Preprocessor Definitions  ******************** */
&SCOP FRAME-NAME fr-prn-fm11
&SCOP run-proc   RUN clcprtsl_calc-line IN THIS-PROCEDURE ( ~{~&~params~} ) NO-ERROR. ~
                 IF ERROR-STATUS :ERROR THEN DO: UNDO, RETURN. END.
&SCOP temp-table tt-allsum-line
&SCOP tt-where   {&temp-table}.sum-type = {&sum-general}
&SCOP sum-no-VAT ( {&temp-table}.sum-dsc-rubl-acc - {&temp-table}.vat-rubl-acc )
&SCOP fact_q-ty    {&temp-table}.fact-qnty
&SCOP price-rubl ( {&sum-no-VAT} / {&fact_q-ty} )
&SCOP tt-find    FIND {&temp-table} WHERE {&tt-where} NO-ERROR. ~
                 IF NOT AVAILABLE {&temp-table} THEN DO: UNDO, RETURN ERROR. END.

/* Print Variable Definitions ---                                       */
DEFINE VARIABLE v-host-name AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-obj-name  AS CHARACTER NO-UNDO.
DEFINE VARIABLE Line        AS CHARACTER NO-UNDO.

DEFINE VARIABLE sym1 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U.
DEFINE VARIABLE sym2 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U.
DEFINE VARIABLE sym3 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U.
DEFINE VARIABLE sym4 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U.
DEFINE VARIABLE sym5 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U.
DEFINE VARIABLE sym6 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U.
DEFINE VARIABLE sym7 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U.
DEFINE VARIABLE sym8 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U.
DEFINE VARIABLE sym9 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U.

DEFINE VARIABLE j-order#    AS INTEGER   NO-UNDO FORMAT ">>9":U.
DEFINE VARIABLE v-article   AS CHARACTER NO-UNDO FORMAT "x(16)":U.
DEFINE VARIABLE wealth-name AS CHARACTER NO-UNDO FORMAT "x(35)":U.
DEFINE VARIABLE v-unit-code AS CHARACTER NO-UNDO FORMAT "x(3)":U.
DEFINE VARIABLE v-quantity  AS DECIMAL   NO-UNDO FORMAT ">,>>>,>>9.999":U.
DEFINE VARIABLE v-total-qty AS DECIMAL   NO-UNDO FORMAT ">,>>>,>>9.999":U.
DEFINE VARIABLE price-rubl  AS DECIMAL   NO-UNDO FORMAT ">,>>>,>>>,>>>,>>9.99":U.
DEFINE VARIABLE sum-rubl    AS DECIMAL   NO-UNDO FORMAT "->,>>>,>>>,>>>,>>9.99":U.
DEFINE VARIABLE sum-total   AS DECIMAL   NO-UNDO FORMAT "->,>>>,>>>,>>>,>>9.99":U.
DEFINE VARIABLE v-object    AS CHARACTER NO-UNDO FORMAT "x(78)":U.
DEFINE VARIABLE word-qty    AS CHARACTER NO-UNDO.
DEFINE VARIABLE word-sum    AS CHARACTER NO-UNDO.

DEFINE BUFFER buf_doc  FOR ub.trn-doc.
DEFINE BUFFER buf_line FOR ub.doc-line.
DEFINE BUFFER buf_cli  FOR ub.clients.
DEFINE BUFFER buf_obj  FOR ub.clients.
DEFINE BUFFER buf_own  FOR ub.clients.

/* ************************  Frame Definitions  *********************** */
DEFINE FRAME {&FRAME-NAME}
  sym1 SPACE( 0 ) j-order#    SPACE( 0 )
  sym2 SPACE( 0 ) v-article   SPACE( 0 )
  sym3 SPACE( 0 ) wealth-name SPACE( 0 )
  sym4 SPACE( 0 ) v-unit-code SPACE( 0 )
  sym5 SPACE( 0 ) v-quantity  SPACE( 0 )
  sym6 SPACE( 0 ) price-rubl  SPACE( 0 )
  sym7 SPACE( 0 ) sum-rubl    SPACE( 0 )
  sym8 SPACE( 0 ) v-object    SPACE( 0 )
  sym9 SPACE( 0 )
HEADER
/* ....+....1....+....2....+....3....+....4....+....5....+....6....+....7....+....8....+....9....+....C....+....1....+....2....+....3....+....4....+....5....+....6....+....7....+....8....+....9....+.... */
  "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" SKIP
  ":№пп:     Артикул    :       Наименование материала      :Ед.:  Количество :        Цена        :        Сумма        :                           Объект расхода материала                           :" SKIP
  ":   :                :                                   :изм:             :                    :                     :                                                                              :" SKIP
  ":---:----------------:-----------------------------------:---:-------------:--------------------:---------------------:------------------------------------------------------------------------------:" SKIP
  ": 1 :        2       :                 3                 : 4 :      5      :          6         :          7          :                                       8                                      :" SKIP
/*   3         16                         35                  3       13                20                    21                                                78                                      */
/*"------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" SKIP*/
WITH WIDTH 198 DOWN USE-TEXT STREAM-IO NO-BOX NO-LABELS.

/* ***************************  Main Block  *************************** */
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
Main-Block:
DO ON ERROR   UNDO Main-Block, LEAVE Main-Block
   ON END-KEY UNDO Main-Block, LEAVE Main-Block :
  FIND buf_doc NO-LOCK WHERE RECID( buf_doc ) = p-rec-id NO-ERROR.
  IF NOT AVAILABLE buf_doc THEN DO:
    MESSAGE "Акт списания материалов не найден!" VIEW-AS ALERT-BOX ERROR.
    UNDO Main-Block, LEAVE Main-Block.
  END.
  RUN WaitFram-Show IN THIS-PROCEDURE ( INPUT "Ждите..." ).
  SESSION :SET-WAIT-STATE( "COMPILER":U ).

  RUN prn-lib-open-stream IN THIS-PROCEDURE ( INPUT p-parent-proc, INPUT {&LS_PS_A4}, INPUT YES, INPUT NO ).

  FIND buf_own NO-LOCK WHERE
       buf_own.obj-type = {&cmp}            AND
       buf_own.obj-code = buf_doc.host-code NO-ERROR.
  ASSIGN v-host-name =
    ( IF AVAILABLE buf_own THEN ( TRIM( buf_own.obj-name ) + FILL( "_", 100 - LENGTH( TRIM( buf_own.obj-name ) ) ) )
                           ELSE                              FILL( "_", 100 ) ).
  FIND buf_obj NO-LOCK WHERE
       buf_obj.obj-type = buf_doc.obj-type AND
       buf_obj.obj-code = buf_doc.obj-code NO-ERROR.
  ASSIGN v-obj-name  =
    ( IF AVAILABLE buf_obj THEN ( TRIM( buf_obj.obj-name ) + FILL( "_",  85 - LENGTH( TRIM( buf_obj.obj-name ) ) ) )
                           ELSE                              FILL( "_",  85 ) ).
  FIND buf_cli NO-LOCK WHERE
       buf_cli.obj-type = buf_doc.cli-type AND
       buf_cli.obj-code = buf_doc.cli-code NO-ERROR.

  PUT STREAM PrnLibStream UNFORMATTED
    '"У Т В Е Р Ж Д А Ю"'                                                  AT 160 SKIP
    "Наименование организации ___" + v-host-name
                               "Генеральный директор"                      AT 148 SKIP( 1 )
    "Наименование структурного подразделения ___" + v-obj-name
                               "_________________________  Т.М. Погромова" AT 148 SKIP( 1 )
    "Основание для составления акта " + FILL( "_", 97 )
                                             "---------------------------------------" AT 150 SKIP
                                             ":  Номер документа : Дата составления :" AT 150 SKIP
                                             ":------------------:------------------:" AT 150 SKIP
            "А К Т"         AT 45            ":" + STRING( buf_doc.doc-code, "x(18)":U ) +
                                                                ":    " + STRING( buf_doc.doc-date, "99.99.9999":U ) +
                                                                               "    :" AT 150 SKIP
    "о списании материалов" AT 37            "---------------------------------------" AT 150 SKIP.
  ASSIGN j-order# = 0.
  FOR EACH buf_line NO-LOCK WHERE
           buf_line.doc-code = buf_doc.doc-code
  BREAK BY buf_line.artic
        BY buf_line.prod-type
        BY buf_line.prod-code :
    ASSIGN j-order# = j-order# + 1.
    RUN get-vars IN THIS-PROCEDURE (  INPUT RECID( buf_line ),
                                     OUTPUT wealth-name,
                                     OUTPUT v-quantity,
                                     OUTPUT price-rubl,
                                     OUTPUT sum-rubl,
                                     OUTPUT v-object           ) NO-ERROR.
    IF ERROR-STATUS :ERROR THEN DO: UNDO Main-Block, LEAVE Main-Block. END.
    ASSIGN v-article   = buf_line.artic
           v-unit-code = buf_line.unit-cli.
    ASSIGN v-total-qty = v-total-qty + v-quantity
           sum-total   = sum-total   + sum-rubl.

    IF LAST( buf_line.artic ) THEN DO:
      IF LINE-COUNTER( PrnLibStream ) + 5 > PAGE-SIZE( PrnLibStream ) THEN DO: PAGE STREAM PrnLibStream. END.
    END.

    DISPLAY STREAM PrnLibStream sym1 j-order#    WHEN j-order#    <> ?
                                sym2 v-article   WHEN v-article   <> ?
                                sym3 wealth-name WHEN wealth-name <> ?
                                sym4 v-unit-code WHEN v-unit-code <> ?
                                sym5 v-quantity  WHEN v-quantity  <> ? AND v-quantity <> 0
                                sym6 price-rubl  WHEN price-rubl  <> ? AND price-rubl <> 0
                                sym7 sum-rubl    WHEN sum-rubl    <> ? AND sum-rubl   <> 0
                                sym8 v-object    WHEN v-object    <> ?
                                sym9
    WITH FRAME {&FRAME-NAME}.
  END. /* FOR EACH buf_line */
  FIND ub.currency NO-LOCK WHERE ub.currency.curr-code = 0.
  ASSIGN word-sum = Word-Sum( sum-total ).
  ASSIGN word-sum = ( IF sum-total < 0 THEN "- " ELSE "":U ) + TRIM( word-sum  ) + " ":U + ub.currency.curr-abbr + ". ":U +
                    SUBSTRING( STRING( ABS( sum-total ), "999999999999999.99" ), 17, 2 ) + " ":U + ub.currency.part-abbr + ".".
  /*
  ASSIGN word-sum = Word-Sum( sum-total ) + " {&abbr_rub}. " + STRING( ( sum-total - TRUNCATE( sum-total, 0 ) ) * 100, "99":U ) +
                    " {&abbr_kop}.".
   */

  PUT STREAM PrnLibStream UNFORMATTED
    ":---:----------------:-----------------------------------:---:-------------:--------------------:---------------------:------------------------------------------------------------------------------:" SKIP
    ":   :                : И Т О Г О                         :   :" + STRING( v-total-qty, ">,>>>,>>9.999":U ) +
                                                                               ":                    :" + STRING( sum-total, "->,>>>,>>>,>>>,>>9.99":U ) +
                                                                                                                          ":                                                                              :" SKIP
    "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" SKIP( 1 ).
  PUT STREAM PrnLibStream UNFORMATTED
    "Сумма списания (прописью): " + STRING( word-sum, "x(171)":U ) SKIP( 1 )
    "Все члены комиссии предупреждены об ответственности за подписание акта, содержащего данные, несоответствующие действительности." SKIP( 1 ).
  PUT STREAM PrnLibStream UNFORMATTED
    "Вышеперечисленные материалы израсходованы: " + FILL( "_", 155 ) SKIP( 1 )
    FILL( "_", 198 ) SKIP( 1 ).
  PUT STREAM PrnLibStream UNFORMATTED
    "Комиссия в составе:" SKIP
    "Начальник Управления технического обеспечения: " + FILL( "_", 32 ) + "     ":U + FILL( "_", 32 ) SKIP.

  OUTPUT STREAM PrnLibStream CLOSE.

  SESSION :SET-WAIT-STATE( "":U ).
  RUN WaitFram-Hide IN THIS-PROCEDURE.

  RUN prn-lib-prn-file IN THIS-PROCEDURE ( INPUT p-parent-proc, INPUT 8 ).
END. /* Main-Block */
RUN WaitFram-Hide IN THIS-PROCEDURE.

/* **********************  Internal Procedures  *********************** */
PROCEDURE get-vars :
  DEFINE  INPUT PARAMETER p-line-rec_id AS RECID     NO-UNDO.
  DEFINE OUTPUT PARAMETER p-wealth-name AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-quantity    AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-price-rubl  AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-sum-rubl    AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-object      AS CHARACTER NO-UNDO.

  DEFINE BUFFER buf-line FOR ub.doc-line.
  DEFINE BUFFER buf-gds  FOR ub.goods.

  DO ON ERROR UNDO, RETURN :
    FIND buf-line NO-LOCK WHERE RECID( buf-line ) = p-line-rec_id NO-ERROR.
    IF NOT AVAILABLE buf-line THEN DO: UNDO, RETURN ERROR. END.
    FIND buf-gds NO-LOCK WHERE
         buf-gds.artic     = buf-line.artic     AND
         buf-gds.prod-type = buf-line.prod-type AND
         buf-gds.prod-code = buf-line.prod-code NO-ERROR.
    &SCOP params INPUT p-line-rec_id
    {&run-proc}
    {&tt-find}
    ASSIGN p-quantity    = {&fact_q-ty}
           p-price-rubl  = {&price-rubl}
           p-sum-rubl    = {&sum-no-VAT}
           p-wealth-name = ( IF AVAILABLE buf-gds THEN buf-gds.gds-name ELSE "":U ).
  END. /* ON ERROR */
END PROCEDURE. /* get-vars */
