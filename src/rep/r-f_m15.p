block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-f_m15.p $
$Archive: rep/r-f_m15.p $

Печать накладной на отпуск материалов на сторону (форма М-15)

Автор: Булгаков Андрей Николаевич
Дата создания: 09/08/05
Author: Andrew Bulgakoff
Creation date: 09/08/05

*/

/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER p-parent-proc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-rec-id      AS RECID         NO-UNDO.

/* ********************  Preprocessor Definitions  ******************** */
&SCOP lib clcprtsl

/* VSS Variables Definitions */
DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INITIAL "$Revision: aea5316774be, 0, rls $":U.
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INITIAL "$Author: expertek $":U.
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INITIAL "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INITIAL "$Workfile: r-f_m15.p $":U.
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INITIAL "$Archive: rep/r-f_m15.p $":U.
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INITIAL "печать накладной на отпуск материалов на сторону (форма М-15)":U.

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
&SCOP FRAME-NAME fr-prn-fm15
&SCOP run-proc   RUN clcprtsl_calc-line IN THIS-PROCEDURE ( ~{~&~params~} ) NO-ERROR. ~
                 IF ERROR-STATUS :ERROR THEN DO: UNDO, RETURN. END.
&SCOP temp-table tt-allsum-line
&SCOP suffix     doc
&SCOP tt-where   {&temp-table}.sum-type = {&sum-general}
&SCOP sum-VAT    {&temp-table}.vat-rubl-{&suffix}
&SCOP sum-doc    {&temp-table}.sum-dsc-rubl-{&suffix}
&SCOP sum-no-VAT ( {&sum-doc} - {&sum-VAT} )
&SCOP fact_q-ty  {&temp-table}.fact-qnty
&SCOP price-rubl ( {&sum-no-VAT} / {&fact_q-ty} )
&SCOP tt-find    FIND {&temp-table} WHERE {&tt-where} NO-ERROR. ~
                 IF NOT AVAILABLE {&temp-table} THEN DO: UNDO, RETURN ERROR. END.

/* Print Variable Definitions ---                                       */
DEFINE VARIABLE v-host-name  AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-cli-name   AS CHARACTER NO-UNDO.

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
DEFINE VARIABLE sym13 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U.
DEFINE VARIABLE sym14 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U.
DEFINE VARIABLE sym15 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U.
DEFINE VARIABLE sym16 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL ":":U.

DEFINE VARIABLE v-account   AS CHARACTER NO-UNDO FORMAT "x(5)":U.
DEFINE VARIABLE v-analytics AS CHARACTER NO-UNDO FORMAT "x(10)":U.
DEFINE VARIABLE wealth-name AS CHARACTER NO-UNDO FORMAT "x(32)":U.
DEFINE VARIABLE v-article   AS CHARACTER NO-UNDO FORMAT "x(16)":U.
DEFINE VARIABLE v-unit-code AS CHARACTER NO-UNDO FORMAT "x(3)":U.
DEFINE VARIABLE v-unit-name AS CHARACTER NO-UNDO FORMAT "x(8)":U.
DEFINE VARIABLE v-quantity1 AS DECIMAL   NO-UNDO FORMAT ">>,>>9.999":U.
DEFINE VARIABLE v-quantity2 AS DECIMAL   NO-UNDO FORMAT ">>,>>9.999":U.
DEFINE VARIABLE cost-rubl   AS DECIMAL   NO-UNDO FORMAT ">>>,>>9.99":U.
DEFINE VARIABLE no-VAT-rubl AS DECIMAL   NO-UNDO FORMAT "->>>,>>>,>>>,>>9.99":U.
DEFINE VARIABLE VAT-rubl    AS DECIMAL   NO-UNDO FORMAT "->>>,>>>,>>>,>>9.99":U.
DEFINE VARIABLE to-pay-rubl AS DECIMAL   NO-UNDO FORMAT "->>>,>>>,>>>,>>9.99":U.
DEFINE VARIABLE v-inventory AS CHARACTER NO-UNDO FORMAT "x(6)":U.
DEFINE VARIABLE v-passport  AS CHARACTER NO-UNDO FORMAT "x(5)":U.
DEFINE VARIABLE v-order     AS CHARACTER NO-UNDO FORMAT "x(10)":U.
DEFINE VARIABLE v-store_man AS CHARACTER NO-UNDO.
DEFINE VARIABLE total-qty1  AS DECIMAL   NO-UNDO FORMAT ">>,>>9.999":U.
DEFINE VARIABLE total-qty2  AS DECIMAL   NO-UNDO FORMAT ">>,>>9.999":U.
DEFINE VARIABLE total-noVAT AS DECIMAL   NO-UNDO FORMAT "->>>,>>>,>>>,>>9.99":U.
DEFINE VARIABLE total-VAT   AS DECIMAL   NO-UNDO FORMAT "->>>,>>>,>>>,>>9.99":U.
DEFINE VARIABLE total-topay AS DECIMAL   NO-UNDO FORMAT "->>>,>>>,>>>,>>9.99":U.
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
  sym10 SPACE( 0 ) no-VAT-rubl SPACE( 0 )
  sym11 SPACE( 0 ) VAT-rubl    SPACE( 0 )
  sym12 SPACE( 0 ) to-pay-rubl SPACE( 0 )
  sym13 SPACE( 0 ) v-inventory SPACE( 0 )
  sym14 SPACE( 0 ) v-passport  SPACE( 0 )
  sym15 SPACE( 0 ) v-order     SPACE( 0 )
  sym16 SPACE( 0 )
HEADER
/* ....+....1....+....2....+....3....+....4....+....5....+....6....+....7....+....8....+....9....+....C....+....1....+....2....+....3....+....4....+....5....+....6....+....7....+....8....+....9....+....С....+....1....+... */
  "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" SKIP
  ": Корреспондирую-:              Материальные ценности              :   Единица  :      Количество     :   Цена,  :     Сумма без     :     Сумма НДС,    :      Всего с      :    Номер   :Порядковый:" SKIP
  ":    щий счет    :                                                 :  измерения :                     : {&abbr_rub}. {&abbr_kop}.:     учета НДС,    : {&abbr_rub}.         {&abbr_kop}. :    учетом НДС,    :            :   номер  :" SKIP
  ":----------------:-------------------------------------------------:------------:---------------------:          : {&abbr_rub}.         {&abbr_kop}. :                   : {&abbr_rub}.         {&abbr_kop}. :------------: записи по:" SKIP
  ":счет,:код анали-:       наименование, сорт,      : номенклатурный :код:наимено-: надлежит : отпущено :          :                   :                   :                   :инвен-: пас-: складской:" SKIP
  ": суб-: тического:          размер, марка         :      номер     :   :  вание : отпустить:          :          :                   :                   :                   :тарный: пор-: картотеке:" SKIP
  ": счет:   учета  :                                :                :   :        :          :          :          :                   :                   :                   :      :  та :          :" SKIP
  ":-----:----------:--------------------------------:----------------:---:--------:----------:----------:----------:-------------------:-------------------:-------------------:------:-----:----------:" SKIP
  ":  1  :     2    :                3               :        4       : 5 :    6   :     7    :     8    :     9    :         10        :        11         :         12        :  13  : 14  :    15    :" SKIP
/*    5       10                    32                       16         3      8        10         10         10              19                 19                   19            6     5       10    */
WITH WIDTH 198 DOWN USE-TEXT STREAM-IO NO-BOX NO-LABELS.

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
  IF LENGTH( v-store_man ) < 25 THEN DO: ASSIGN v-store_man = v-store_man + FILL( "_", 25 - LENGTH( v-store_man ) ). END.

  ASSIGN v-host-name = "___" +
    ( IF AVAILABLE buf_own THEN ( TRIM( buf_own.obj-name ) + FILL( "_", 155 - LENGTH( TRIM( buf_own.obj-name ) ) ) )
                           ELSE                              FILL( "_", 155 ) ).
  ASSIGN v-cli-name  = "___" +
    ( IF AVAILABLE buf_cli THEN ( TRIM( buf_cli.obj-name ) + FILL( "_",  91 - LENGTH( TRIM( buf_cli.obj-name ) ) ) )
                           ELSE                              FILL( "_",  91 ) ).

  PUT STREAM PrnLibStream UNFORMATTED "Типовая межотраслевая форма № М-15"                            AT 150 SKIP
                                      "Утверждена постановлением Госкомстата России"                  AT 150 SKIP
                                      "от 30.10.97 № 71а"                                             AT 150 SKIP.
  PUT STREAM PrnLibStream UNFORMATTED "Н А К Л А Д Н А Я   №  " +  buf_doc.doc-code                   AT  80 SKIP
                                      "н а   о т п у с к   м а т е р и а л о в   н а   с т о р о н у" AT  69 SKIP.
  PUT STREAM PrnLibStream UNFORMATTED               "+-------------+" AT 181 SKIP
                                                    "|     Коды    |" AT 181 SKIP
                                                    "+-------------+" AT 181 SKIP
                                      "Форма по ОКУД |   0315007   |" AT 167 SKIP
                                                    "+-------------+" AT 181 SKIP
           "Организация " + v-host-name     "по ОКПО |             |" AT 173 SKIP
                                                    "+-------------+" AT 181 SKIP.
/*   ....+....1....+....2....+....3....+....4....+....5....+....6....+....7....+....8....+....9....+....C....+....1....+....2....+....3....+....4....+....5....+....6....+....7....+....8....+....9....+.... */
  PUT STREAM PrnLibStream UNFORMATTED
    "----------------------------------------------------------------------------------------------------------------------------------------------" AT 57 SKIP
    ":    Дата   :  Код вида :            Отправитель           :            Получатель            :           Ответственный за поставку          :" AT 57 SKIP
    ":составления:  операции :---------------------:------------:---------------------:------------:----------------------------------------------:" AT 57 SKIP
    ":           :           :     структурное     :     вид    :     структурное     :     вид    :     структурное     :     вид    :    код    :" AT 57 SKIP
    ":           :           :    подразделение    :деятельности:    подразделение    :деятельности:    подразделение    :деятельности:исполнителя:" AT 57 SKIP
    ":-----------:-----------:---------------------:------------:---------------------:------------:---------------------:------------:-----------:" AT 57 SKIP
    ":     1     :     2     :          3          :      4     :          5          :      6     :          7          :      8     :     9     :" AT 57 SKIP
    "----------------------------------------------------------------------------------------------------------------------------------------------" AT 57 SKIP.

  PUT STREAM PrnLibStream UNFORMATTED
    ": " + STRING( buf_doc.doc-date, "99.99.9999":U ) +
                ":   расход  :" + STRING( buf_obj.obj-name, "x(21)":U ) +
                                                  ":            :" + STRING( buf_cli.obj-name, "x(21)":U ) +
                                                                                     ":            :                     :            :           :" AT 57 SKIP.
  PUT STREAM PrnLibStream UNFORMATTED
    "----------------------------------------------------------------------------------------------------------------------------------------------" AT 57 SKIP.
  PUT STREAM PrnLibStream UNFORMATTED
    "Основание "  FILL( "_", 188 ) SKIP
    "Кому "       v-cli-name "   ":U
    "Через кого " FILL( "_",  85 ) SKIP.

  ASSIGN total-qty1  = 0
         total-qty2  = 0
         total-noVAT = 0
         total-VAT   = 0
         total-topay = 0
         j-order#    = 0.
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
                                     OUTPUT no-VAT-rubl,
                                     OUTPUT VAT-rubl,
                                     OUTPUT to-pay-rubl,
                                     OUTPUT v-inventory,
                                     OUTPUT v-passport,
                                     OUTPUT v-order            ) NO-ERROR.
    IF ERROR-STATUS :ERROR THEN DO: UNDO Main-Block, LEAVE Main-Block. END.

    DISPLAY STREAM PrnLibStream sym1  v-account   WHEN v-account   <> ?
                                sym2  v-analytics WHEN v-analytics <> ?
                                sym3  wealth-name WHEN wealth-name <> ?
                                sym4  v-article   WHEN v-article   <> ?
                                sym5  v-unit-code WHEN v-unit-code <> ?
                                sym6  v-unit-name WHEN v-unit-name <> ?
                                sym7  v-quantity1 WHEN v-quantity1 <> ?
                                sym8  v-quantity2 WHEN v-quantity2 <> ?
                                sym9  cost-rubl   WHEN cost-rubl   <> ?
                                sym10 no-VAT-rubl WHEN no-VAT-rubl <> ?
                                sym11 VAT-rubl    WHEN VAT-rubl    <> ?
                                sym12 to-pay-rubl WHEN to-pay-rubl <> ?
                                sym13 v-inventory WHEN v-inventory <> ?
                                sym14 v-passport  WHEN v-passport  <> ?
                                sym15 v-order     WHEN v-order     <> ? sym16
    WITH FRAME {&FRAME-NAME}.
    ASSIGN total-qty1  = total-qty1  + ( IF v-quantity1 <> ? THEN v-quantity1 ELSE 0 )
           total-qty2  = total-qty2  + ( IF v-quantity2 <> ? THEN v-quantity2 ELSE 0 )
           total-noVAT = total-noVAT + ( IF no-VAT-rubl <> ? THEN no-VAT-rubl ELSE 0 )
           total-VAT   = total-VAT   + ( IF VAT-rubl    <> ? THEN VAT-rubl    ELSE 0 )
           total-topay = total-topay + ( IF to-pay-rubl <> ? THEN to-pay-rubl ELSE 0 )
           j-order#    = j-order#    + 1.
  END. /* FOR EACH buf_line */

  FIND ub.currency NO-LOCK WHERE ub.currency.curr-code = 0.
  ASSIGN word-sum = Word-Sum( total-topay ).
  ASSIGN word-ord = Word-Sum( DECIMAL( j-order# ) ).
  ASSIGN word-sum = ( IF total-topay < 0 THEN "- " ELSE "":U ) + TRIM( word-sum  ) + " ":U + ub.currency.curr-abbr + ". ":U +
                    SUBSTRING( STRING( ABS( total-topay ), "999999999999999.99" ), 17, 2 ) + " ":U + ub.currency.part-abbr + ".".
  ASSIGN word-VAT = ( IF total-VAT   < 0 THEN "- " ELSE "":U ) + ( IF VAT-rubl <> 0 THEN
                    LEFT-TRIM( SUBSTRING( STRING( ABS( total-VAT ), "999999999999999.99" ),  1, 15 ), "0" )
                                                                                    ELSE "0" )       + " ":U + ub.currency.curr-abbr + ". ":U +
                               SUBSTRING( STRING( ABS( total-VAT ), "999999999999999.99" ), 17,  2 ) + " ":U + ub.currency.part-abbr + ".".
  IF LENGTH( TRIM( word-ord ) ) < 100 THEN DO:
    ASSIGN word-ord = TRIM( word-ord ) + FILL( "_", 100 - LENGTH( TRIM( word-ord ) ) ).
  END.

  PUT STREAM PrnLibStream UNFORMATTED
  /*":  1  :     2    :                3               :        4       : 5 :    6   :     7    :     8    :     9    :         10        :        11         :         12        :  13  : 14  :    15    :" */
    ":-----:----------:--------------------------------:----------------:---:--------:----------:----------:----------:-------------------:-------------------:-------------------:------:-----:----------:" SKIP
    ":     :          :                     И Т О Г О  :                :   :        :" +
    STRING( STRING( total-qty1,  ">>,>>9.999":U          ), "x(10)":U ) +                      ":" +
    STRING( STRING( total-qty2,  ">>,>>9.999":U          ), "x(10)":U ) +                                 ":          :" +
    STRING( STRING( total-noVAT, "->>>,>>>,>>>,>>9.99":U ), "x(19)":U ) +                                                                ":" +
    STRING( STRING( total-VAT,   "->>>,>>>,>>>,>>9.99":U ), "x(19)":U ) +                                                                                    ":" +
    STRING( STRING( total-topay, "->>>,>>>,>>>,>>9.99":U ), "x(19)":U ) +                                                                                                        ":      :     :          :" SKIP
    "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" SKIP.

  PUT STREAM PrnLibStream UNFORMATTED
    "Всего отпущено: ___" +       STRING( word-ord, "x(100)":U )   + " наименований" SKIP
    "                   прописью"                                                    SKIP
    "На сумму: "          + TRIM( STRING( word-sum, "x(185)":U ) )                   SKIP
    "в том числе НДС: "   +       STRING( word-VAT, "x(160)":U )                     SKIP( 1 ).

  PUT STREAM PrnLibStream UNFORMATTED
    "Отпуск разрешил "   FILL( "_",  25 ) "     ":U FILL( "_",  25 ) "     ":U FILL( "_",  25 )
    "                    ":U
    "Главный бухгалтер " FILL( "_",  25 ) "     ":U FILL( "_",  25 )                                   SKIP
    "                должность                     подпись                       расшифровка подписи " SPACE( 10 )
                "                                  подпись                       расшифровка подписи " SKIP( 1 )
    "Отпустил "          FILL( "_",  25 ) "     ":U FILL( "_",  25 ) "     ":U STRING( v-store_man, "x(25)":U ) "       ":U
    "Получил "           FILL( "_",  25 ) "     ":U FILL( "_",  25 ) "     ":U FILL( "_",  25 )  SKIP
    "          должность                     подпись                       расшифровка подписи " SPACE( 10 )
    "          должность                     подпись                       расшифровка подписи " SKIP.

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
  DEFINE OUTPUT PARAMETER p-cost-rubl     AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-no-VAT-rubl   AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-VAT-rubl      AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-to-pay-rubl   AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-inventory     AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-passport      AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-order         AS CHARACTER NO-UNDO.

  DEFINE BUFFER buf-line FOR ub.doc-line.
  DEFINE BUFFER buf-gds  FOR ub.goods.
  DEFINE BUFFER buf-unit FOR ub.units.

  DO ON ERROR UNDO, RETURN :
    ASSIGN p-account   = "":U
           p-analytics = "":U.
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
    ASSIGN p-quantity-fact = {&fact_q-ty}
           p-cost-rubl     = {&price-rubl}
           p-no-VAT-rubl   = {&sum-no-VAT}
           p-VAT-rubl      = {&sum-VAT}
           p-to-pay-rubl   = {&sum-doc}
           p-inventory     = "":U
           p-passport      = "":U
           p-order         = "":U.
  END. /* ON ERROR */
END PROCEDURE. /* get-vars */
