block-level on error undo, throw.
/*

$Revision: 540d86a07c0d, 3497, rls $
$Author: ARostovtsev $
$Date: 2023/10/16 15:13:36 $
$Workfile: r-f_m11.p $
$Archive: rep/r-f_m11.p $

Печать требования-накладной (форма М-11)

Автор: Булгаков Андрей Николаевич
Дата создания: 09/08/05
Author: Andrew Bulgakoff
Creation date: 09/08/05

*/

/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER p-parent-proc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-rec-id      AS RECID         NO-UNDO.

/* VSS Variables Definitions */
DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INITIAL "$Revision: 540d86a07c0d, 3497, rls $":U.
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INITIAL "$Author: ARostovtsev $":U.
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INITIAL "$Date: 2023/10/16 15:13:36 $":U.
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INITIAL "$Workfile: r-f_m11.p $":U.
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INITIAL "$Archive: rep/r-f_m11.p $":U.
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INITIAL "печать требования-накладной (форма М-11)":U.
/* Local Variable Definitions ---                                       */
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ gbl/prn-lib.i  }
{ gbl/waitfram.i }
{ str/clcprtsl.i }
{ gbl/word-sum.i }
{ gbl/paramls.i  }
define shared variable CostPrice          as logical              no-undo.
define variable g#report-num              as integer              no-undo .
run get-report-num in p-parent-proc (output g#report-num).
{ rep/r-f_m11xl.i}

/* ********************  Preprocessor Definitions  ******************** */
&SCOP FRAME-NAME fr-prn-fm11
&SCOP run-proc   RUN clcprtsl_calc-line IN THIS-PROCEDURE ( ~{~&~params~} ) NO-ERROR. ~
                 IF ERROR-STATUS :ERROR THEN DO: UNDO, RETURN. END.
&SCOP temp-table tt-allsum-line
&SCOP suffix     acc
&SCOP tt-where   {&temp-table}.sum-type = {&sum-general}
&SCOP fact_q-ty  {&temp-table}.fact-qnty
&SCOP sum-VAT    {&temp-table}.vat-rubl-{&suffix}
&SCOP sum-doc    {&temp-table}.sum-dsc-rubl-{&suffix}
&SCOP sum-no-VAT ( {&sum-doc} - {&sum-VAT} )
&SCOP price-rubl ( {&sum-doc} / {&fact_q-ty} )

&SCOP sum-VAT-base       {&temp-table}.vat-base-{&suffix}
&SCOP sum-doc-base       {&temp-table}.sum-dsc-base-{&suffix}
&SCOP sum-no-VAT-base    ( {&sum-doc-base} - {&sum-VAT-base} )
&SCOP price-base         ( {&sum-doc-base} / {&fact_q-ty} )

/*&SCOP price-rubl ( {&sum-no-VAT} / {&fact_q-ty} )*/

&SCOP suffix-doc        doc
&SCOP sum-VAT-doc       {&temp-table}.vat-rubl-{&suffix-doc}
&SCOP sum-doc-doc       {&temp-table}.sum-dsc-rubl-{&suffix-doc}
&SCOP sum-no-VAT-doc    ( {&sum-doc-doc} - {&sum-VAT-doc} )
&SCOP price-rubl-doc    ( {&sum-doc-doc} / {&fact_q-ty} )

&SCOP sum-VAT-base-doc       {&temp-table}.vat-base-{&suffix-doc}
&SCOP sum-doc-base-doc       {&temp-table}.sum-dsc-base-{&suffix-doc}
&SCOP sum-no-VAT-base-doc    ( {&sum-doc-base-doc} - {&sum-VAT-base-doc} )
&SCOP price-base-doc         ( {&sum-doc-base-doc} / {&fact_q-ty} )



&SCOP tt-find    FIND {&temp-table} WHERE {&tt-where} NO-ERROR. ~
                 IF NOT AVAILABLE {&temp-table} THEN DO: UNDO, RETURN ERROR. END.

/* Print Variable Definitions ---                                       */
DEFINE VARIABLE v-host-name  AS CHARACTER NO-UNDO.
DEFINE VARIABLE Line         AS CHARACTER NO-UNDO.

DEFINE VARIABLE sym1  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U.
DEFINE VARIABLE sym2  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U.
DEFINE VARIABLE sym3  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U.
DEFINE VARIABLE sym4  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U.
DEFINE VARIABLE sym5  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U.
DEFINE VARIABLE sym6  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U.
DEFINE VARIABLE sym7  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U.
DEFINE VARIABLE sym8  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U.
DEFINE VARIABLE sym9  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U.
DEFINE VARIABLE sym10 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U.
DEFINE VARIABLE sym11 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U.
DEFINE VARIABLE sym12 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U.

DEFINE VARIABLE v-host-code AS INTEGER   NO-UNDO.
DEFINE VARIABLE v-curr-code AS INTEGER   NO-UNDO.

DEFINE VARIABLE v-account   AS CHARACTER NO-UNDO FORMAT "x(7)":U.
DEFINE VARIABLE v-analytics AS CHARACTER NO-UNDO FORMAT "x(10)":U.
DEFINE VARIABLE wealth-name AS CHARACTER NO-UNDO FORMAT "x(35)":U.
DEFINE VARIABLE v-article   AS CHARACTER NO-UNDO FORMAT "x(16)":U.
DEFINE VARIABLE v-unit-code AS CHARACTER NO-UNDO FORMAT "x(3)":U.
DEFINE VARIABLE v-unit-name AS CHARACTER NO-UNDO FORMAT "x(35)":U.
DEFINE VARIABLE v-quantity1 AS DECIMAL   NO-UNDO FORMAT ">,>>>,>>9.999":U.
DEFINE VARIABLE v-quantity2 AS DECIMAL   NO-UNDO FORMAT ">,>>>,>>9.999":U.
DEFINE VARIABLE cost-rubl   AS DECIMAL   NO-UNDO FORMAT ">,>>>,>>>,>>>,>>9.99":U.
DEFINE VARIABLE no-VAT      AS DECIMAL   NO-UNDO FORMAT "->,>>>,>>>,>>>,>>9.99":U.
DEFINE VARIABLE VAT         AS DECIMAL   NO-UNDO FORMAT "->,>>>,>>>,>>>,>>9.99":U.
DEFINE VARIABLE v-order     AS CHARACTER NO-UNDO FORMAT "x(10)":U.
DEFINE VARIABLE v-store_man AS CHARACTER NO-UNDO.
DEFINE VARIABLE total-qty1  AS DECIMAL   NO-UNDO FORMAT ">,>>>,>>9.999":U.
DEFINE VARIABLE total-qty2  AS DECIMAL   NO-UNDO FORMAT ">,>>>,>>9.999":U.
DEFINE VARIABLE total-noVAT AS DECIMAL   NO-UNDO FORMAT "->,>>>,>>>,>>>,>>9.99":U.
DEFINE VARIABLE j-order#    AS INTEGER   NO-UNDO FORMAT ">>9":U.
DEFINE VARIABLE word-ord    AS CHARACTER NO-UNDO.
DEFINE VARIABLE word-sum    AS CHARACTER NO-UNDO.
DEFINE VARIABLE word-VAT    AS CHARACTER NO-UNDO.

DEFINE BUFFER buf_doc  FOR ub.trn-doc.
DEFINE BUFFER buf_line FOR ub.doc-line.
DEFINE BUFFER buf_cli  FOR ub.clients.
DEFINE BUFFER buf_obj  FOR ub.clients.
DEFINE BUFFER buf_own  FOR ub.clients.
DEFINE BUFFER buf_wrkr FOR ub.clients.

/* ************************  Frame Definitions  *********************** */
DEFINE FRAME {&FRAME-NAME}
  sym1  SPACE( 0 ) v-account   SPACE( 0 )
  sym2  SPACE( 0 ) v-analytics SPACE( 0 )
  sym3  SPACE( 0 ) wealth-name SPACE( 0 )
  sym4  SPACE( 0 ) v-article   SPACE( 0 )
  sym5  SPACE( 0 ) v-unit-code SPACE( 0 )
  sym6  SPACE( 0 ) v-unit-name SPACE( 0 )
  sym7  SPACE( 0 ) v-quantity1 SPACE( 0 )
  sym8  SPACE( 0 ) v-quantity2 SPACE( 0 )
  sym9  SPACE( 0 ) cost-rubl   SPACE( 0 )
  sym10 SPACE( 0 ) no-VAT      SPACE( 0 )
  sym11 SPACE( 0 ) v-order     SPACE( 0 )
  sym12 SPACE( 0 )
HEADER
/* ....+....1....+....2....+....3....+....4....+....5....+....6....+....7....+....8....+....9....+....C....+....1....+....2....+....3....+....4....+....5....+....6....+....7....+....8....+....9....+.... */
  "---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" SKIP
  ": Корреспондирующий:                Материальные ценности               :           Единица измерения           :         Количество        :                    :                     :          :" SKIP
  ":       счет       :                                                    :                                       :                           :                    :      Сумма без      :Порядковый:" SKIP
  ":------------------:----------------------------------------------------:---------------------------------------:---------------------------:        Цена,       :      учета НДС,     : номер по :" SKIP
  ": счет, :код анали-:                                   :                :   :                                   :             :             :      {&abbr_rub}. {&abbr_kop}.     :      {&abbr_rub}. {&abbr_kop}.      : складской:" SKIP
  ":субсчет: тического:            наименование           : номенклатурный :код:            наименование           : затребовано :   отпущено  :                    :                     : картотеке:" SKIP
  ":       :   учета  :                                   :      номер     :   :                                   :             :             :                    :                     :          :" SKIP
  ":-------:----------:-----------------------------------:----------------:---:-----------------------------------:-------------:-------------:--------------------:---------------------:----------:" SKIP
  ":   1   :     2    :                 3                 :        4       : 5 :                 6                 :      7      :      8      :          9         :          10         :    11    :" SKIP
/*     7        10                     35                         16         3                  35                       13            13                20                    21              10           */
/*"---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" SKIP*/
WITH WIDTH 195 DOWN USE-TEXT STREAM-IO NO-BOX NO-LABELS.

/* ***************************  Main Block  *************************** */
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
Main-Block:
DO ON ERROR   UNDO Main-Block, LEAVE Main-Block
   ON END-KEY UNDO Main-Block, LEAVE Main-Block :
  FIND buf_doc NO-LOCK WHERE RECID( buf_doc ) = p-rec-id NO-ERROR.
  IF NOT AVAILABLE buf_doc THEN DO:
    MESSAGE "Накладная не найдена!" VIEW-AS ALERT-BOX ERROR.
    UNDO Main-Block, LEAVE Main-Block.
  END.
  RUN WaitFram-Show IN THIS-PROCEDURE ( INPUT "Ждите..." ).
  IF SESSION :SET-WAIT-STATE( "COMPILER" ) THEN DO: END.
  RUN prn-lib-open-stream IN THIS-PROCEDURE ( INPUT p-parent-proc, INPUT {&LS_PS_A4}, INPUT YES, INPUT NO ).

  FIND buf_own NO-LOCK WHERE
       buf_own.obj-type = {&cmp}            AND
       buf_own.obj-code = buf_doc.host-code NO-ERROR.
  FIND buf_obj NO-LOCK WHERE
       buf_obj.obj-type = buf_doc.obj-type AND
       buf_obj.obj-code = buf_doc.obj-code NO-ERROR.
  FIND buf_cli NO-LOCK WHERE
       buf_cli.obj-type = buf_doc.cli-type AND
       buf_cli.obj-code = buf_doc.cli-code NO-ERROR.
  FIND buf_wrkr NO-LOCK WHERE
       buf_wrkr.obj-type = {&prs}       AND
       buf_wrkr.obj-code = buf_doc.wrkr NO-ERROR.
  ASSIGN v-store_man = ( IF AVAILABLE buf_wrkr THEN TRIM( buf_wrkr.obj-name ) ELSE FILL( "_", 25 ) ).
  IF LENGTH( v-store_man ) < 25 THEN DO: ASSIGN v-store_man = FILL( "_", 25 - LENGTH( v-store_man ) ) + v-store_man. END.

  ASSIGN v-host-name =
    ( IF AVAILABLE buf_own THEN ( TRIM( buf_own.obj-name ) + FILL( "_", 155 - LENGTH( TRIM( buf_own.obj-name ) ) ) )
                           ELSE                              FILL( "_", 155 ) ).

  PUT STREAM PrnLibStream UNFORMATTED "Типовая межотраслевая форма № М-11"            AT 150 SKIP
                                      "Утверждена постановлением Госкомстата России"  AT 150 SKIP
                                      "от 30.10.97 № 71а"                             AT 150 SKIP.
  PUT STREAM PrnLibStream UNFORMATTED "Т Р Е Б О В А Н И Е - Н А К Л А Д Н А Я   №  " AT  69.
  PUT STREAM PrnLibStream UNFORMATTED buf_doc.doc-code                                       SKIP.
  PUT STREAM PrnLibStream UNFORMATTED               "+-------------+" AT 181 SKIP
                                                    "|     Коды    |" AT 181 SKIP
                                                    "+-------------+" AT 181 SKIP
                                      "Форма по ОКУД |   0315006   |" AT 167 SKIP
                                                    "+-------------+" AT 181 SKIP
            "Организация ___" + v-host-name
                                            "по ОКПО |             |" AT 173 SKIP
                                                    "+-------------+" AT 181 SKIP.
/*   ....+....1....+....2....+....3....+....4....+....5....+....6....+....7....+....8....+....9....+....C....+....1....+....2....+....3....+....4....+....5....+....6....+....7....+....8....+....9....+.... */
  PUT STREAM PrnLibStream UNFORMATTED
    "-------------------------------------------------------------------------------------------------------------------------------------" AT 63 SKIP
    ":    Дата   :  Код вида :            Отправитель           :            Получатель            :   Корреспондирующий  :    Учетная   :" AT 63 SKIP
    ":составления:  операции :                                  :                                  :         счет         :    единица   :" AT 63 SKIP
    ":           :           :---------------------:------------:---------------------:------------:----------------------:    выпуска   :" AT 63 SKIP
    ":           :           :     структурное     :     вид    :     структурное     :     вид    : счет, : код аналити- :   продукции  :" AT 63 SKIP
    ":           :           :    подразделение    :деятельности:    подразделение    :деятельности:субсчет: ческого учета:(работ, услуг):" AT 63 SKIP
    ":-----------:-----------:---------------------:------------:---------------------:------------:-------:--------------:--------------:" AT 63 SKIP
    ":     1     :     2     :          3          :      4     :          5          :      6     :   7   :       8      :       9      :" AT 63 SKIP
    "-------------------------------------------------------------------------------------------------------------------------------------" AT 63 SKIP.

  PUT STREAM PrnLibStream UNFORMATTED
    ": " + STRING( buf_doc.doc-date, "99.99.9999":U ) +
                ":" + ( IF buf_doc.ext-doc-type = {&TDEDT_Spi_Vnesh} OR
                           buf_doc.ext-doc-type = {&TDEDT_Spi_Prvo}  THEN "  списание " ELSE
                      ( IF buf_doc.ext-doc-type = {&TDEDT_Ras_Perem} THEN "расх.внутр."
                                                                         ELSE "           ":U ) ) +
                            ":" + STRING( buf_obj.obj-name, "x(21)":U ) +
                                                  ":            :" + STRING( buf_cli.obj-name, "x(21)":U ) +
                                                                                     ":            :       :              :              :" AT 63 SKIP.
  PUT STREAM PrnLibStream UNFORMATTED
    "-------------------------------------------------------------------------------------------------------------------------------------" AT 63 SKIP.
  PUT STREAM PrnLibStream UNFORMATTED
    "Через кого " FILL( "_", 184 ) SKIP
    "Затребовал " FILL( "_",  85 ) SPACE( 5 )
    "Разрешил "   FILL( "_",  85 ) SKIP.

  ASSIGN total-qty1  = 0
         total-qty2  = 0
         total-noVAT = 0
         VAT         = 0
         j-order#    = 0.

  RUN r-f_m11xl-init.
  RUN r-f_m11xl-write-cell-data (INPUT {&r-f_m11xl-doccode}, INPUT  buf_doc.doc-code) .
  RUN r-f_m11xl-write-cell-data (INPUT {&r-f_m11xl-orgname}, INPUT  IF AVAILABLE buf_own THEN  TRIM( buf_own.obj-name )
                           ELSE "" ) .
  /*RUN r-f_m11xl-write-cell-data (INPUT {&r-f_m11xl-OKPO}, INPUT  ???) .*/
  RUN r-f_m11xl-write-cell-data (INPUT {&r-f_m11xl-docdate}, INPUT STRING( buf_doc.doc-date, "99.99.9999":U )).
  RUN r-f_m11xl-write-cell-data (INPUT {&r-f_m11xl-doctype}, INPUT ( IF buf_doc.ext-doc-type = {&TDEDT_Spi_Vnesh} OR
                           buf_doc.ext-doc-type = {&TDEDT_Spi_Prvo}  THEN "списание" ELSE
                      ( IF buf_doc.ext-doc-type = {&TDEDT_Ras_Perem} THEN "расх.внутр."
                                                                         ELSE "":U ) )).
  RUN r-f_m11xl-write-cell-data (INPUT {&r-f_m11xl-objname1}, INPUT TRIM ( buf_obj.obj-name ) ).
  RUN r-f_m11xl-write-cell-data (INPUT {&r-f_m11xl-objname2}, INPUT TRIM ( buf_cli.obj-name ) ).
  RUN r-f_m11xl-write-cell-data (INPUT {&r-f_m11xl-storeman}, INPUT TRIM ( IF AVAILABLE buf_wrkr THEN ( buf_wrkr.obj-name ) ELSE "" ) ).

  FOR EACH buf_line NO-LOCK WHERE
           buf_line.doc-code = buf_doc.doc-code
  BREAK BY buf_line.artic
        BY buf_line.prod-type
        BY buf_line.prod-code :
    RUN get-vars IN THIS-PROCEDURE (  INPUT RECID( buf_line ),
                                     OUTPUT v-account,
                                     OUTPUT v-analytics,
                                     OUTPUT wealth-name,
                                     OUTPUT v-article,
                                     OUTPUT v-unit-code,
                                     OUTPUT v-unit-name,
                                     OUTPUT v-quantity1,
                                     OUTPUT v-quantity2,
                                     OUTPUT cost-rubl,
                                     OUTPUT no-VAT,
                                     OUTPUT v-order            ) NO-ERROR.
    IF ERROR-STATUS :ERROR THEN DO: UNDO Main-Block, LEAVE Main-Block. END.
    RUN r-f_m11xl-sheet1-write-line-data IN THIS-PROCEDURE ( INPUT v-account,
                                     INPUT v-analytics,
                                     INPUT wealth-name,
                                     INPUT v-article,
                                     INPUT v-unit-code,
                                     INPUT v-unit-name,
                                     INPUT v-quantity1,
                                     INPUT v-quantity2,
                                     INPUT cost-rubl,
                                     INPUT no-VAT,
                                     INPUT v-order            ) NO-ERROR.
    IF ERROR-STATUS :ERROR THEN DO: UNDO Main-Block, LEAVE Main-Block. END.

    IF LAST( buf_line.artic ) THEN DO:
      IF LINE-COUNTER( PrnLibStream ) + 9 > PAGE-SIZE( PrnLibStream ) THEN DO: PAGE STREAM PrnLibStream. END.
    END.

    DISPLAY STREAM PrnLibStream sym1  v-account   WHEN v-account   <> ?
                                sym2  v-analytics WHEN v-analytics <> ?
                                sym3  wealth-name WHEN wealth-name <> ?
                                sym4  v-article   WHEN v-article   <> ?
                                sym5  v-unit-code WHEN v-unit-code <> ?
                                sym6  v-unit-name WHEN v-unit-name <> ?
                                sym7  v-quantity1 WHEN v-quantity1 <> ? AND v-quantity1 <> 0
                                sym8  v-quantity2 WHEN v-quantity2 <> ? AND v-quantity2 <> 0
                                sym9  cost-rubl   WHEN cost-rubl   <> ? AND cost-rubl   <> 0
                                sym10 no-VAT      WHEN no-VAT <> ? AND no-VAT <> 0
                                sym11 v-order     WHEN v-order     <> ?
                                sym12
    WITH FRAME {&FRAME-NAME}.
    ASSIGN total-qty1  = total-qty1  + ( IF v-quantity1 <> ? THEN v-quantity1 ELSE 0 )
           total-qty2  = total-qty2  + ( IF v-quantity2 <> ? THEN v-quantity2 ELSE 0 )
           total-noVAT = total-noVAT + ( IF no-VAT <> ? THEN no-VAT ELSE 0 )
           j-order#    = j-order#    + 1.
  END. /* FOR EACH buf_line */

  IF printrubl
    THEN FIND ub.currency NO-LOCK WHERE ub.currency.curr-code = 0.
  ELSE DO:
    { gbl/hostcode.i
      buf_doc.obj-type
      buf_doc.obj-code
      v-host-code
    }
    { gbl/basecode.i
      v-host-code
      v-curr-code
    }
    FIND ub.currency NO-LOCK WHERE ub.currency.curr-code = v-curr-code.
  END.
  ASSIGN word-sum = Word-Sum( total-noVAT ).
  ASSIGN word-ord = Word-Sum( DECIMAL( j-order# ) ).
  ASSIGN word-sum = ( IF total-noVAT < 0 THEN "- " ELSE "":U ) + TRIM( word-sum  ) + " ":U + ub.currency.curr-abbr + ". ":U +
                    SUBSTRING( STRING( ABS( total-noVAT ), "999999999999999.99" ), 17, 2 ) + " ":U + ub.currency.part-abbr + ".".
  ASSIGN word-VAT = ( IF VAT < 0 THEN "- " ELSE "":U ) + ( IF VAT <> 0 THEN
                    LEFT-TRIM( SUBSTRING( STRING( ABS( VAT ), "999999999999999.99" ),  1, 15 ), "0" )
                                                                                 ELSE "0" )         + " ":U + ub.currency.curr-abbr + ". ":U +
                               SUBSTRING( STRING( ABS( VAT ), "999999999999999.99" ), 17,  2 ) + " ":U + ub.currency.part-abbr + ".".
  RUN r-f_m11xl-write-cell-data (INPUT {&r-f_m11xl-wordord}, INPUT TRIM ( word-ord ) + " наименований" ).
  RUN r-f_m11xl-write-cell-data (INPUT {&r-f_m11xl-wordsum}, INPUT TRIM ( word-sum ) ).
  RUN r-f_m11xl-write-cell-data (INPUT {&r-f_m11xl-wordVAT}, INPUT TRIM ( word-VAT ) ).
  RUN r-f_m11xl-write-cell-data (INPUT {&r-f_m11xl-it_noVATrubl}, INPUT TRIM ( STRING ( total-noVAT ))).
  RUN r-f_m11xl-write-cell-data (INPUT {&r-f_m11xl-it_quantity1}, INPUT TRIM ( STRING ( total-qty1 ))).
  RUN r-f_m11xl-write-cell-data (INPUT {&r-f_m11xl-it_quantity2}, INPUT TRIM ( STRING ( total-qty2 ))).
  IF LENGTH( TRIM( word-ord ) ) < 100 THEN DO:
    ASSIGN word-ord = TRIM( word-ord ) + FILL( "_", 100 - LENGTH( TRIM( word-ord ) ) ).
  END.

  PUT STREAM PrnLibStream UNFORMATTED
    ":-------:----------:-----------------------------------:----------------:---:-----------------------------------:-------------:-------------:--------------------:---------------------:----------:" SKIP
    ":       :          : ИТОГО                             :                :   :                                   :" +
     STRING( total-qty1,  ">,>>>,>>9.999":U         ) +
                                                                                                                                  ":" +
     STRING( total-qty2,  ">,>>>,>>9.999":U         ) +
                                                                                                                                                ":                    :" +
     STRING( total-noVAT, "->,>>>,>>>,>>>,>>9.99":U ) +
                                                                                                                                                                                           ":          :" SKIP
    "---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" SKIP.
  PUT STREAM PrnLibStream UNFORMATTED
    "Всего отпущено: ___" + STRING( word-ord, "x(100)":U ) + " наименований" SKIP
    "На сумму: "          + STRING( word-sum, "x(185)":U )                   SKIP
    "В том числе НДС: "   + STRING( word-VAT, "x(18)":U  )                   SKIP.
  PUT STREAM PrnLibStream UNFORMATTED
    "Отпустил " FILL( "_",  25 ) "     ":U FILL( "_",  25 ) "     ":U STRING( v-store_man, "x(25)":U ) "       ":U
    "Получил "  FILL( "_",  25 ) "     ":U FILL( "_",  25 ) "     ":U FILL( "_",  25 )           SKIP
    "          должность                     подпись                       расшифровка подписи " SPACE( 10 )
    "          должность                     подпись                       расшифровка подписи " SKIP.
  RUN r-f_m11xl-close.
  os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
  os-rename
    value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
    value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
  .
  OUTPUT STREAM PrnLibStream CLOSE.
  IF SESSION :SET-WAIT-STATE( "":U       ) THEN DO: END.
  RUN WaitFram-Hide IN THIS-PROCEDURE.
  RUN prn-lib-prn-file IN THIS-PROCEDURE ( INPUT p-parent-proc, INPUT 8 ).
END. /* Main-Block */
RUN WaitFram-Hide IN THIS-PROCEDURE.

/* **********************  Internal Procedures  *********************** */
PROCEDURE get-vars :
  DEFINE  INPUT PARAMETER p-line-rec_id   AS RECID     NO-UNDO.
  DEFINE OUTPUT PARAMETER p-account       AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-analytics     AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-wealth-name   AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-article       AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-unit-code     AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-unit-name     AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-quantity-doc  AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-quantity-fact AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-cost          AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-no-VAT        AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-order         AS CHARACTER NO-UNDO.

  DEFINE BUFFER buf-line FOR ub.doc-line.
  DEFINE BUFFER buf-gds  FOR ub.goods.
  DEFINE BUFFER buf-unit FOR ub.units.
  DEFINE BUFFER buf_trn-doc FOR trn-doc.

  DO ON ERROR UNDO, RETURN :
    FIND buf-line NO-LOCK WHERE RECID( buf-line ) = p-line-rec_id NO-ERROR.
    IF NOT AVAILABLE buf-line THEN DO: UNDO, RETURN ERROR. END.
    ASSIGN p-article       = buf-line.artic
           p-quantity-doc  = buf-line.doc-qnty
           p-unit-code     = buf-line.unit-cli.
    FIND buf-gds NO-LOCK WHERE
         buf-gds.artic     = buf-line.artic     AND
         buf-gds.prod-type = buf-line.prod-type AND
         buf-gds.prod-code = buf-line.prod-code NO-ERROR.
    ASSIGN p-wealth-name   = ( IF AVAILABLE buf-gds  THEN buf-gds.gds-name   ELSE "":U ).
    FIND buf-unit NO-LOCK WHERE buf-unit.unit-name = buf-line.unit-cli NO-ERROR.
    ASSIGN p-unit-name     = ( IF AVAILABLE buf-unit THEN buf-unit.long-name ELSE "":U ).
    &SCOP params INPUT p-line-rec_id
    {&run-proc}
    {&tt-find}
    ASSIGN p-quantity-fact = {&fact_q-ty}.
    IF CostPrice
      THEN DO:
        IF printrubl
          THEN DO:
            ASSIGN  p-cost     = {&price-rubl}
                    p-no-VAT   = {&sum-no-VAT}
                    VAT        = VAT + {&sum-VAT}.
          END.
          ELSE DO:
            ASSIGN  p-cost     = {&price-base}
                    p-no-VAT   = {&sum-no-VAT-base}
                    VAT        = VAT + {&sum-VAT-base}.
          END.
      END.
      ELSE DO:
        IF printrubl
          THEN DO:
            ASSIGN  p-cost     = {&price-rubl-doc}
                    p-no-VAT   = {&sum-no-VAT-doc}
                    VAT        = VAT + {&sum-VAT-doc}.
          END.
          ELSE DO:
            ASSIGN  p-cost     = {&price-base-doc}
                    p-no-VAT   = {&sum-no-VAT-base-doc}
                     VAT       = VAT + {&sum-VAT-base-doc}.
          END.
    END.

  END. /* ON ERROR */
END PROCEDURE. /* get-vars */