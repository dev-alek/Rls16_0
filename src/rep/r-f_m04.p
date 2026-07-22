block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-f_m04.p $
$Archive: rep/r-f_m04.p $

Печать приходного ордера (форма М-4)

Автор: Булгаков Андрей Николаевич
Дата создания: 09/08/05
Author: Andrew Bulgakoff
Creation date: 09/08/05

*/

/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-rec-id      AS RECID         NO-UNDO.
define input parameter p-yukos       as logical       no-undo.
define input parameter p-form-num     as integer       no-undo.  /* для цен продажи */

/* VSS Variables Definitions */
DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INITIAL "$Revision: aea5316774be, 0, rls $":U.
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INITIAL "$Author: expertek $":U.
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INITIAL "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INITIAL "$Workfile: r-f_m04.p $":U.
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INITIAL "$Archive: rep/r-f_m04.p $":U.
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INITIAL "печать приходного ордера (форма М-4)":U.

/* Local Variable Definitions ---                                       */
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ gbl/prn-lib.i  }
{ gbl/waitfram.i }
{ str/clcprtsl.i }
{ gbl/word-sum.i }
{ str/trdcalib.i }
{ str/lib-trn.i  }
{ gbl/std-func.i  }
{ cmp/str-glbl.i }
{ rep/fmtcli.i   }
{ rep/torgconf.i   }

define variable g#report-num          as integer   no-undo .
run get-report-num  in parparentproc (output g#report-num ).
define variable g#quest-print         as logical   no-undo .
run get-quest-print in parparentproc (output g#quest-print ).

/* Print Variable Definitions ---                                       */
DEFINE VARIABLE v-host-name AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-obj-name  AS CHARACTER NO-UNDO.

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

DEFINE VARIABLE v-gds-name  AS CHARACTER NO-UNDO FORMAT "x(30)":U.
DEFINE VARIABLE v-article   AS CHARACTER NO-UNDO FORMAT "x(16)":U.
DEFINE VARIABLE v-unit-code AS CHARACTER NO-UNDO FORMAT "x(3)":U.
DEFINE VARIABLE v-unit-name AS CHARACTER NO-UNDO FORMAT "x(13)":U.
DEFINE VARIABLE v-quantity1 AS DECIMAL   NO-UNDO FORMAT ">>,>>9.999":U.
DEFINE VARIABLE v-quantity2 AS DECIMAL   NO-UNDO FORMAT ">>,>>9.999":U.
DEFINE VARIABLE cost-rubl   AS DECIMAL   NO-UNDO FORMAT ">>>,>>>,>>>,>>9.99":U.
DEFINE VARIABLE no-VAT-rubl AS DECIMAL   NO-UNDO FORMAT "->>>,>>>,>>>,>>9.99":U.
DEFINE VARIABLE VAT-rubl    AS DECIMAL   NO-UNDO FORMAT "->>>,>>>,>>>,>>9.99":U.
DEFINE VARIABLE to-pay-rubl AS DECIMAL   NO-UNDO FORMAT "->,>>>,>>>,>>>,>>9.99":U.
DEFINE VARIABLE v-sale      AS DECIMAL   NO-UNDO FORMAT ">>>>>,>>>,>>9.99":U.
DEFINE VARIABLE v-prc       AS DECIMAL   NO-UNDO FORMAT "->>>>>9.99":U.
DEFINE VARIABLE v-passport  AS CHARACTER NO-UNDO FORMAT "x(16)":U.
DEFINE VARIABLE v-bar-code  AS CHARACTER NO-UNDO FORMAT "x(10)":U.
DEFINE VARIABLE v-store_man AS CHARACTER NO-UNDO.
DEFINE VARIABLE total-qty2  AS DECIMAL   NO-UNDO FORMAT ">>,>>9.999":U.
DEFINE VARIABLE total-noVAT AS DECIMAL   NO-UNDO FORMAT "->>>,>>>,>>>,>>9.99":U.
DEFINE VARIABLE total-VAT   AS DECIMAL   NO-UNDO FORMAT "->>>,>>>,>>>,>>9.99":U.
DEFINE VARIABLE total-topay AS DECIMAL   NO-UNDO FORMAT "->,>>>,>>>,>>>,>>9.99":U.
DEFINE VARIABLE j-order#    AS INTEGER   NO-UNDO.
DEFINE VARIABLE word-ord    AS CHARACTER NO-UNDO.
DEFINE VARIABLE word-sum    AS CHARACTER NO-UNDO.
DEFINE VARIABLE word-VAT    AS CHARACTER NO-UNDO.
DEFINE VARIABLE word-cost   AS CHARACTER NO-UNDO.
define variable month       as integer   no-undo .
DEFINE VARIABLE v-torgconf-post   AS CHARACTER NO-UNDO.
define variable g#log as logical   no-undo .

DEFINE BUFFER buf_trn-doc  FOR ub.trn-doc.
DEFINE BUFFER buf_doc-line FOR ub.doc-line.
DEFINE BUFFER buf_cli  FOR ub.clients.
DEFINE BUFFER buf_obj  FOR ub.clients.
DEFINE BUFFER buf_own  FOR ub.clients.
DEFINE BUFFER buf_wrkr FOR ub.clients.
define buffer buf_firm for ub.firm.

/* ************************  Frame Definitions  *********************** */
DEFINE FRAME fr-prn-fm11
  sym1  SPACE( 0 ) v-gds-name  SPACE( 0 )
  sym2  SPACE( 0 ) v-article   SPACE( 0 )
  sym3  SPACE( 0 ) v-unit-code SPACE( 0 )
  sym4  SPACE( 0 ) v-unit-name SPACE( 0 )
  sym5  SPACE( 0 ) v-quantity1 SPACE( 0 )
  sym6  SPACE( 0 ) v-quantity2 SPACE( 0 )
  sym7  SPACE( 0 ) cost-rubl   SPACE( 0 )
  sym8  SPACE( 0 ) no-VAT-rubl SPACE( 0 )
  sym9  SPACE( 0 ) VAT-rubl    SPACE( 0 )
  sym10 SPACE( 0 ) to-pay-rubl SPACE( 0 )
  sym11 SPACE( 0 ) v-passport  SPACE( 0 )
  sym12 SPACE( 0 ) v-bar-code  SPACE( 0 )
  sym13 SPACE( 0 )
HEADER
/* ....+....1....+....2....+....3....+....4....+....5....+....6....+....7....+....8....+....9....+....C....+....1....+....2....+....3....+....4....+....5....+....6....+....7....+....8....+....9....+....С....+....1.. */
  "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" SKIP
  ":             Материальные ценности             :Единица измерения:     Количество      :       Цена,      :     Сумма без     :       Сумма       :       Всего с       :      Номер     :Порядковый:" SKIP
  ":-----------------------------------------------:-----------------:---------------------: {&abbr_rub}.        {&abbr_kop}. :     учета НДС,    :        НДС,       :     учетом НДС,     :    паспорта    : номер по :" SKIP
  ":         Наименование,        : Номенклатурный :Код: Наименование: по доку- :  принято :                  : {&abbr_rub}.         {&abbr_kop}. : {&abbr_rub}.         {&abbr_kop}. : {&abbr_rub}.           {&abbr_kop}. :                : складской:" SKIP
  ":      сорт, размер, марка     :      номер     :   :             :  менту   :          :                  :                   :                   :                     :                : картотеке:" SKIP
  ":------------------------------:----------------:---:-------------:----------:----------:------------------:-------------------:-------------------:---------------------:----------------:----------:" SKIP
  ":               1              :        2       : 3 :      4      :     5    :     6    :         7        :         8         :         9         :          10         :       11       :    12    :" SKIP
/*                30                      16         3       13           10         10             18                 19                  19                    19                 16            10    */
WITH WIDTH 198 DOWN USE-TEXT STREAM-IO NO-BOX NO-LABELS.

DEFINE FRAME fr-prn-fm12
  sym1  SPACE( 0 ) v-gds-name  SPACE( 0 )
  sym2  SPACE( 0 ) v-article   SPACE( 0 )
  sym3  SPACE( 0 ) v-unit-code SPACE( 0 )
  sym4  SPACE( 0 ) v-unit-name SPACE( 0 )
  sym5  SPACE( 0 ) v-quantity1 SPACE( 0 )
  sym6  SPACE( 0 ) v-quantity2 SPACE( 0 )
  sym7  SPACE( 0 ) cost-rubl   SPACE( 0 )
  sym8  SPACE( 0 ) no-VAT-rubl SPACE( 0 )
  sym9  SPACE( 0 ) VAT-rubl    SPACE( 0 )
  sym10 SPACE( 0 ) to-pay-rubl SPACE( 0 )
  sym11 SPACE( 0 ) v-sale      SPACE( 0 )
  sym12 SPACE( 0 ) v-prc       SPACE( 0 )
  sym13 SPACE( 0 )
HEADER
/* ....+....1....+....2....+....3....+....4....+....5....+....6....+....7....+....8....+....9....+....C....+....1....+....2....+....3....+....4....+....5....+....6....+....7....+....8....+....9....+....С....+....1.. */
  "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" SKIP
  ":             Материальные ценности             :Единица измерения:     Количество      :       Цена,      :     Сумма без     :       Сумма       :       Всего с       :      Цена      :  Процент :" SKIP
  ":-----------------------------------------------:-----------------:---------------------: {&abbr_rub}.        {&abbr_kop}. :     учета НДС,    :        НДС,       :     учетом НДС,     :   реализации   :  наценки :" SKIP
  ":         Наименование,        : Номенклатурный :Код: Наименование: по доку- :  принято :                  : {&abbr_rub}.         {&abbr_kop}. : {&abbr_rub}.         {&abbr_kop}. : {&abbr_rub}.           {&abbr_kop}. :  без учета НДС :          :" SKIP
  ":      сорт, размер, марка     :      номер     :   :             :  менту   :          :                  :                   :                   :                     :   {&abbr_rub}.   {&abbr_kop}.  :          :" SKIP
  ":------------------------------:----------------:---:-------------:----------:----------:------------------:-------------------:-------------------:---------------------:----------------:----------:" SKIP
  ":               1              :        2       : 3 :      4      :     5    :     6    :         7        :         8         :         9         :          10         :       11       :    12    :" SKIP
/*                30                      16         3       13           10         10             18                 19                  19                    19                 16            10    */
WITH WIDTH 198 DOWN USE-TEXT STREAM-IO NO-BOX NO-LABELS.

DEFINE FRAME fr-prn-fm13
  sym1  SPACE( 0 ) v-gds-name  SPACE( 0 )
  sym2  SPACE( 0 ) v-article   SPACE( 0 )
  sym3  SPACE( 0 ) v-unit-code SPACE( 0 )
  sym4  SPACE( 0 ) v-unit-name SPACE( 0 )
  sym5  SPACE( 0 ) v-quantity1 SPACE( 0 )
  sym6  SPACE( 0 ) v-quantity2 SPACE( 0 )
  sym7  SPACE( 0 ) cost-rubl   SPACE( 0 )
  sym8  SPACE( 0 ) no-VAT-rubl SPACE( 0 )
  sym9  SPACE( 0 ) VAT-rubl    SPACE( 0 )
  sym10 SPACE( 0 ) to-pay-rubl SPACE( 0 )
  sym11 SPACE( 0 ) v-sale      SPACE( 0 )
  sym12 SPACE( 0 ) v-prc       SPACE( 0 )
  sym13 SPACE( 0 )
HEADER
/* ....+....1....+....2....+....3....+....4....+....5....+....6....+....7....+....8....+....9....+....C....+....1....+....2....+....3....+....4....+....5....+....6....+....7....+....8....+....9....+....С....+....1.. */
  "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" SKIP
  ":             Материальные ценности             :Единица измерения:     Количество      :       Цена,    :    Сумма без    :      Сумма       :      Всего с     :      Цена      :      Сумма       :" SKIP
  ":-----------------------------------------------:-----------------:---------------------: {&abbr_rub}.      {&abbr_kop}. :    учета НДС,   :        НДС,      :    учетом НДС,   :     продажи    :     продажи      :" SKIP
  ":         Наименование,        : Номенклатурный :Код: Наименование: по доку- :  принято :                : {&abbr_rub}.       {&abbr_kop}. :  {&abbr_rub}.       {&abbr_kop}. : {&abbr_rub}.        {&abbr_kop}. :  с учетом НДС  :  с учетом НДС    :" SKIP
  ":      сорт, размер, марка     :      номер     :   :             :  менту   :          :                :                 :                  :                  :   {&abbr_rub}.   {&abbr_kop}.  : {&abbr_rub}.      {&abbr_kop}.   :" SKIP
  ":------------------------------:----------------:---:-------------:----------:----------:----------------:-----------------:------------------:------------------:----------------:------------------:" SKIP
  ":               1              :        2       : 3 :      4      :     5    :     6    :        7       :        8        :         9        :         10       :       11       :         12       :" SKIP
/*                30                      16         3       13           10         10            16                18                18                  18                16                 18    */
WITH WIDTH 198 DOWN USE-TEXT STREAM-IO NO-BOX NO-LABELS.                                  /*1234567890123456 12345678901345678 123456789012345678 123456789012345678 1234567890123456 123456789012345678*/

/* ***************************  Main Block  *************************** */
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
Main-Block:
DO ON ERROR   UNDO Main-Block, LEAVE Main-Block
   ON END-KEY UNDO Main-Block, LEAVE Main-Block :
  FIND buf_trn-doc NO-LOCK WHERE RECID( buf_trn-doc ) = p-rec-id NO-ERROR.
  IF NOT AVAILABLE buf_trn-doc THEN DO:
    MESSAGE "Накладная не найдена!" VIEW-AS ALERT-BOX ERROR.
    UNDO Main-Block, LEAVE Main-Block.
  END.
  RUN WaitFram-Show IN THIS-PROCEDURE ( INPUT "Ждите..." ).
  IF SESSION :SET-WAIT-STATE( "COMPILER" ) THEN DO: END.

  RUN prn-lib-open-stream IN THIS-PROCEDURE ( INPUT parparentproc, INPUT {&LS_PS_A4}, INPUT YES, INPUT NO ).

  FIND buf_own NO-LOCK WHERE
       buf_own.obj-type = {&cmp}            AND
       buf_own.obj-code = buf_trn-doc.host-code NO-ERROR.
  FIND buf_obj NO-LOCK WHERE
       buf_obj.obj-type = buf_trn-doc.obj-type AND
       buf_obj.obj-code = buf_trn-doc.obj-code NO-ERROR.
  FIND buf_cli NO-LOCK WHERE
       buf_cli.obj-type = buf_trn-doc.cli-type AND
       buf_cli.obj-code = buf_trn-doc.cli-code NO-ERROR.
  FIND buf_wrkr NO-LOCK WHERE
       buf_wrkr.obj-type = {&prs}       AND
       buf_wrkr.obj-code = buf_trn-doc.wrkr NO-ERROR.
  run torgconf-get-storekeeper in this-procedure(
       input  buf_trn-doc.wrkr
     , output v-store_man
     , output v-torgconf-post
  ).
  run torgconf-get-warrant in this-procedure(
       input buf_trn-doc.doc-code
  ).
  if trim(v-store_man) = ""
  then do:
      v-store_man = FILL("_", 25).
  end.
  if trim(v-torgconf-post) = ""
  then do:
      v-torgconf-post = FILL("_", 25).
  end.
  if trim(p-torgconf-t_pass-fname) = ""
  then do:
      p-torgconf-t_pass-fname = FILL("_", 25).
  end.
  if trim(p-torgconf-t_pass-position) = ""
  then do:
      p-torgconf-t_pass-position = FILL("_", 25).
  end.


  find first buf_firm no-lock where buf_firm.firm-code = buf_trn-doc.host-code .

  define variable v-attr-value  as character no-undo .
  define variable v-attr-type   as character no-undo .
  define variable v-pn       as character initial "" no-undo .
  define variable v-sf       as character initial "" no-undo .
  { str/tdat-val.i  buf_trn-doc.doc-code    {&trdcattr-nids}   v-attr-value   v-attr-type  }
  assign v-pn = v-attr-value .
  { str/tdat-val.i  buf_trn-doc.doc-code    {&trdcattr-nsf}   v-attr-value   v-attr-type  }
  assign v-sf = v-attr-value .

  ASSIGN v-host-name =
    ( IF AVAILABLE buf_own THEN ( TRIM( buf_own.obj-name ) + FILL( "_", 155 - LENGTH( TRIM( buf_own.obj-name ) ) ) )
                           ELSE                              FILL( "_", 155 ) )
         v-obj-name  =
    ( IF AVAILABLE buf_obj THEN ( TRIM( buf_obj.obj-name ) + FILL( "_", 155 - LENGTH( TRIM( buf_obj.obj-name ) ) ) )
                           ELSE                              FILL( "_", 155 ) ).

  define variable v-obj as character no-undo .
  define variable v-okpo as character no-undo .
  if p-yukos = yes then do:
    assign
      v-obj  = string( v-obj-name, "X(9)")
      v-okpo = "   " + buf_firm.okpo
    .
  end.
  else do:
    assign
      v-obj = STRING( buf_obj.obj-code, ">>>>>>>>9":U )
      v-okpo = "  " + buf_firm.okpo
    .
  end.

  month =  MONTH ( buf_trn-doc.doc-date ).

  PUT STREAM PrnLibStream UNFORMATTED "Типовая межотраслевая форма № М-4"             AT 150 SKIP
                                      "Утверждена постановлением Госкомстата России"  AT 150 SKIP
                                      "от 30.10.97 № 71а"                             AT 150 SKIP.
  PUT STREAM PrnLibStream UNFORMATTED "П Р И Х О Д Н Ы Й   О Р Д Е Р   № "            AT  68.
  PUT STREAM PrnLibStream UNFORMATTED buf_trn-doc.doc-code  " от "DAY(buf_trn-doc.doc-date)" "MonthNameRusGen(month)" " YEAR(buf_trn-doc.doc-date)" г."     SKIP.
  PUT STREAM PrnLibStream UNFORMATTED               "+-------------+" AT 181 SKIP
                                                    "|     Коды    |" AT 181 SKIP
                                                    "+-------------+" AT 181 SKIP
                                      "Форма по ОКУД |   0315003   |" AT 167 SKIP
                                                    "+-------------+" AT 181 SKIP
            "Организация ___" + v-host-name
                                            "по ОКПО |" AT 173  v-okpo format "x(13)"  "|" SKIP
                                                    "+-------------+" AT 181 SKIP
            "Структурное подразделение ___" + v-obj-name                     SKIP.
/*   ....+....1....+....2....+....3....+....4....+....5....+....6....+....7....+....8....+....9....+....C....+....1....+....2....+....3....+....4....+....5....+....6....+....7....+....8....+....9....+.... */
  PUT STREAM PrnLibStream UNFORMATTED
    "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" SKIP
    ":    Дата   :Код вида:  Склад  :                Поставщик               :           Страховая          :  Корреспондирующий  :      Номер документа      :                              :" SKIP
    ":составления:операции:         :                                        :           компания           :        счет         :                           :                              :" SKIP
    ":           :        :         :----------------------------------------:                              :---------------------:---------------------------:                              :" SKIP
    ":           :        :         :         Наименование         :   Код   :                              : счет, :код аналити- :  сопроводи- :  платежного :                              :" SKIP
    ":           :        :         :                              :         :                              :субсчет:ческого учета:   тельного  :             :                              :" SKIP
    ":-----------:--------:---------:------------------------------:---------:------------------------------:-------:-------------:-------------:-------------:------------------------------:" SKIP
    ":     1     :    2   :    3    :               4              :    5    :               6              :   7   :      8      :      9      :      10     :              12              :" SKIP
    "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" SKIP.
/*        11          8        9                   30                   9                   30                  7         13            13             13                    30              */

  PUT STREAM PrnLibStream UNFORMATTED
    ": " + STRING( buf_trn-doc.doc-date, "99.99.9999":U ) +
                ":  " + STRING( buf_trn-doc.pay-code, "99999":U ) +
                        " :" +  v-obj +
                                   ":" + STRING( buf_cli.obj-name, "x(30)":U ) +
                                                                  ":" + STRING( buf_cli.obj-code, ">>>>>>>>9":U ) +
                                                                            ":                              :       :             :" + string(v-pn,"x(13)") + ":" + string(v-sf,"x(13)") +
                                                                                                                                                             ":                              :" SKIP.
  PUT STREAM PrnLibStream UNFORMATTED
    "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" SKIP.

  ASSIGN total-qty2  = 0
         total-noVAT = 0
         total-VAT   = 0
         total-topay = 0
         j-order#    = 0.
  FOR EACH buf_doc-line NO-LOCK WHERE
           buf_doc-line.doc-code = buf_trn-doc.doc-code
  BREAK BY buf_doc-line.artic
        BY buf_doc-line.prod-type
        BY buf_doc-line.prod-code :
    RUN get-vars IN THIS-PROCEDURE (  INPUT RECID( buf_doc-line ),
                                      INPUT p-form-num,
                                     OUTPUT v-gds-name,
                                     OUTPUT v-article,
                                     OUTPUT v-unit-code,
                                     OUTPUT v-unit-name,
                                     OUTPUT v-quantity1,
                                     OUTPUT v-quantity2,
                                     OUTPUT cost-rubl,
                                     OUTPUT no-VAT-rubl,
                                     OUTPUT VAT-rubl,
                                     OUTPUT to-pay-rubl,
                                     OUTPUT v-passport,
                                     OUTPUT v-bar-code,
                                     OUTPUT v-sale,
                                     OUTPUT v-prc
                                     ) NO-ERROR.
    IF ERROR-STATUS :ERROR THEN DO: UNDO Main-Block, LEAVE Main-Block. END.

    IF LAST( buf_doc-line.artic ) THEN DO:
      IF LINE-COUNTER( PrnLibStream ) + 9 > PAGE-SIZE( PrnLibStream ) THEN DO: PAGE STREAM PrnLibStream. END.
    END.

    CASE p-form-num :
    WHEN 11
    THEN DO:
      DISPLAY STREAM PrnLibStream sym1  v-gds-name  WHEN v-gds-name  <> ?
                         sym2  v-article   WHEN v-article   <> ?
                         sym3  v-unit-code WHEN v-unit-code <> ?
                         sym4  v-unit-name WHEN v-unit-name <> ?
                         sym5  v-quantity1 WHEN v-quantity1 <> ?
                         sym6  v-quantity2 WHEN v-quantity2 <> ?
                         sym7  cost-rubl   WHEN cost-rubl   <> ?
                         sym8  no-VAT-rubl WHEN no-VAT-rubl <> ?
                         sym9  VAT-rubl    WHEN VAT-rubl    <> ?
                         sym10 to-pay-rubl WHEN to-pay-rubl <> ?
                                sym11 v-passport  WHEN v-passport  <> ?
                                sym12 v-bar-code  WHEN v-bar-code  <> ? sym13
      WITH FRAME fr-prn-fm11.
    END.
    WHEN 12
    then DO:
      DISPLAY STREAM PrnLibStream sym1  v-gds-name  WHEN v-gds-name  <> ?
                                sym2  v-article   WHEN v-article   <> ?
                                sym3  v-unit-code WHEN v-unit-code <> ?
                                sym4  v-unit-name WHEN v-unit-name <> ?
                                sym5  v-quantity1 WHEN v-quantity1 <> ?
                                sym6  v-quantity2 WHEN v-quantity2 <> ?
                                sym7  cost-rubl   WHEN cost-rubl   <> ?
                                sym8  no-VAT-rubl WHEN no-VAT-rubl <> ?
                                sym9  VAT-rubl    WHEN VAT-rubl    <> ?
                                sym10 to-pay-rubl WHEN to-pay-rubl <> ?
                         sym11 v-sale
                         sym12 v-prc   sym13
      WITH FRAME fr-prn-fm12 .
    END.
    WHEN 13
    then DO:
      DISPLAY STREAM PrnLibStream sym1  v-gds-name  WHEN v-gds-name  <> ?
                         sym2  v-article   WHEN v-article   <> ?
                         sym3  v-unit-code WHEN v-unit-code <> ?
                         sym4  v-unit-name WHEN v-unit-name <> ?
                         sym5  v-quantity1 WHEN v-quantity1 <> ?
                         sym6  v-quantity2 WHEN v-quantity2 <> ?
                         sym7  cost-rubl   WHEN cost-rubl   <> ? FORMAT ">,>>>,>>>,>>9.99":U
                         sym8  no-VAT-rubl WHEN no-VAT-rubl <> ? FORMAT "->,>>>,>>>,>>9.99":U
                         sym9  VAT-rubl    WHEN VAT-rubl    <> ? FORMAT "->>,>>>,>>>,>>9.99":U
                         sym10 to-pay-rubl WHEN to-pay-rubl <> ? FORMAT "->>,>>>,>>>,>>9.99":U
                         sym11 v-sale      WHEN v-sale      <> ? FORMAT ">,>>>,>>>,>>9.99":U
                         sym12 v-prc       WHEN v-prc       <> ? FORMAT "->>,>>>,>>>,>>9.99":U
                         sym13
      WITH FRAME fr-prn-fm13 .
    END.
    OTHERWISE DO:
    END.
    END CASE.

    ASSIGN total-qty2  = total-qty2  + ( IF v-quantity2 <> ? THEN v-quantity2 ELSE 0 )
           total-noVAT = total-noVAT + ( IF no-VAT-rubl <> ? THEN no-VAT-rubl ELSE 0 )
           total-VAT   = total-VAT   + ( IF VAT-rubl    <> ? THEN VAT-rubl    ELSE 0 )
           total-topay = total-topay + ( IF to-pay-rubl <> ? THEN to-pay-rubl ELSE 0 )
           j-order#    = j-order#    + 1.
  END. /* FOR EACH buf_doc-line */

  FIND ub.currency NO-LOCK WHERE ub.currency.curr-code = 0.
  ASSIGN word-sum = Word-Sum( total-topay ).
  ASSIGN word-VAT = Word-Sum( total-VAT   ).
  ASSIGN word-ord = Word-Sum( DECIMAL( j-order# ) ).
  ASSIGN word-sum = ( IF total-topay < 0 THEN "- " ELSE "":U ) + TRIM( word-sum  ) + " ":U + ub.currency.curr-abbr + ". ":U +
                    SUBSTRING( STRING( ABS( total-topay ), "999999999999999.99" ), 17, 2 ) + " ":U + ub.currency.part-abbr + ".".
  ASSIGN word-VAT = ( IF total-VAT   < 0 THEN "- " ELSE "":U ) + TRIM( word-VAT  ) + " ":U + ub.currency.curr-abbr + ". ":U +
                    SUBSTRING( STRING( ABS( total-VAT   ), "999999999999999.99" ), 17, 2 ) + " ":U + ub.currency.part-abbr + ".".

  IF p-form-num = 13
  THEN
  PUT STREAM PrnLibStream UNFORMATTED
    ":------------------------------:----------------:---:-------------:----------:----------:----------------:-----------------:------------------:------------------:----------------:------------------:" SKIP
    "                                                                      ИТОГО  :" +
    STRING( STRING( total-qty2,  ">>,>>9.999":U           ), "x(10)":U ) +                 ":                :" +
    STRING( STRING( total-noVAT, "->,>>>,>>>,>>9.99":U    ), "x(17)":U ) +  ":" +
    STRING( STRING( total-VAT,   "->>,>>>,>>>,>>9.99":U   ), "x(18)":U ) + ":" +
    STRING( STRING( total-topay, "->>,>>>,>>>,>>9.99":U   ), "x(18)":U ) + ":"                             SKIP
    "                                                                             :-----------------------------------------------------------------------------------:"                             SKIP( 1 ).
  ELSE
  PUT STREAM PrnLibStream UNFORMATTED
    ":------------------------------:----------------:---:-------------:----------:----------:------------------:-------------------:-------------------:---------------------:----------------:----------:" SKIP
    "                                                                      ИТОГО  :" +
    STRING( STRING( total-qty2,  ">>,>>9.999":U            ), "x(10)":U ) +                 ":                  :" +
    STRING( STRING( total-noVAT, "->>>,>>>,>>>,>>9.99":U   ), "x(19)":U ) +                                                        ":" +
    STRING( STRING( total-VAT,   "->>>,>>>,>>>,>>9.99":U   ), "x(19)":U ) +                                                                            ":" +
    STRING( STRING( total-topay, "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U ) +                                                                                                  ":"                             SKIP
    "                                                                             :-------------------------------------------------------------------------------------------:"                             SKIP( 1 ).

  PUT STREAM PrnLibStream UNFORMATTED
    "ВСЕГО наименований: "               +       STRING( word-ord, "x(175)":U )         SKIP
    "Сумма цен по документу составила: " + TRIM( STRING( word-sum, "x(160)":U ) ) + "," SKIP
    "в том числе НДС: "                  +       STRING( word-VAT, "x(160)":U )         SKIP.
  PUT STREAM PrnLibStream UNFORMATTED
    "Принял " STRING(v-torgconf-post, "x(25)")            "     ":U FILL( "_",  25 ) "     ":U STRING( v-store_man, "x(25)":U ) "       ":U
    "Сдал "   string(p-torgconf-t_pass-position, "x(25)") "     ":U FILL( "_",  25 ) "     ":U string( p-torgconf-t_pass-fname, "x(25)")   SKIP
    "          должность                     подпись                       расшифровка подписи " SPACE( 10 )
    "          должность                     подпись                       расшифровка подписи " SKIP.

  OUTPUT STREAM PrnLibStream CLOSE.
  IF SESSION :SET-WAIT-STATE( "":U       ) THEN DO: END.
  RUN WaitFram-Hide IN THIS-PROCEDURE.

  { rep/q-print.i 8 }

END. /* Main-Block */
RUN WaitFram-Hide IN THIS-PROCEDURE.

/* **********************  Internal Procedures  *********************** */
PROCEDURE get-vars :
  DEFINE  INPUT PARAMETER p-line-rec_id AS RECID     NO-UNDO.
  define  input parameter p-form        as integer   no-undo.
  DEFINE OUTPUT PARAMETER p-gds-name    AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-article     AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-unit-code   AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-unit-name   AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-quantity1   AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-quantity2   AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-cost-rubl   AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-no-VAT-rubl AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-VAT-rubl    AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-to-pay-rubl AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-passport    AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-bar-code    AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-sale        AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-prc         AS DECIMAL   NO-UNDO.

  DEFINE VARIABLE v_b-code LIKE ub.bar-code.b-code NO-UNDO.

  DEFINE BUFFER buf1_doc-line FOR ub.doc-line.
  DEFINE BUFFER buf_goods  FOR ub.goods.
  DEFINE BUFFER buf_unit FOR ub.units.

  DO ON ERROR UNDO, RETURN :
    FIND buf1_doc-line NO-LOCK WHERE RECID( buf1_doc-line ) = p-line-rec_id NO-ERROR.
    IF NOT AVAILABLE buf1_doc-line THEN DO: UNDO, RETURN ERROR. END.

    FIND buf_goods NO-LOCK WHERE
         buf_goods.artic     = buf1_doc-line.artic     AND
         buf_goods.prod-type = buf1_doc-line.prod-type AND
         buf_goods.prod-code = buf1_doc-line.prod-code NO-ERROR.
    IF AVAILABLE buf_goods THEN DO:
      { gbl/gdsbcode.i buf_goods.gds-code ? v_b-code }
      ASSIGN
        p-bar-code = STRING( v_b-code, "9999999999":U )
        p-gds-name = buf_goods.gds-name
      .
    END.

    FIND buf_unit NO-LOCK WHERE buf_unit.unit-name = buf1_doc-line.unit-cli NO-ERROR.
    IF AVAILABLE buf_unit THEN do:
      assign
        p-unit-code = string(buf_unit.OKEI)
        p-unit-name = buf_unit.long-name
      .
    end.
    RUN clcprtsl_calc-line IN THIS-PROCEDURE ( input p-line-rec_id ) NO-ERROR.
    find first tt-allsum-line WHERE tt-allsum-line.sum-type = {&sum-general} NO-ERROR.

    define variable is-petrol as logical no-undo .
    define variable is-pieces as logical no-undo .
    { str/is-petrl.i    buf_goods.artic   buf_goods.prod-type   buf_goods.prod-code    is-petrol   is-pieces   no-error  }
    if error-status :error  then   assign    is-petrol = ?     is-pieces = ?   .
    if is-petrol = yes and is-pieces = no  then do:  /* надо в кг */
      define buffer buf_inv-line for inv-line.
      find first buf_inv-line no-lock
        where buf_inv-line.doc-code  = buf1_doc-line.doc-code
          and buf_inv-line.artic     = buf1_doc-line.artic
          and buf_inv-line.prod-type = buf1_doc-line.prod-type
          and buf_inv-line.prod-code = buf1_doc-line.prod-code
      no-error .
      if available buf_inv-line then do:
        ASSIGN
          p-quantity1   = buf1_doc-line.doc-qnty * buf1_doc-line.doc-density
          p-quantity2   = buf_inv-line.wast-cli-qnty
        .
      end.
    end.
    else do:
      ASSIGN
        p-quantity1   = buf1_doc-line.doc-qnty
        p-quantity2   = tt-allsum-line.fact-qnty
      .
    end.
    if p-yukos = yes then assign p-to-pay-rubl = tt-allsum-line.sum-dsc-rubl-acc - tt-allsum-line.transport-rubl-acc .
    else                  assign p-to-pay-rubl = tt-allsum-line.sum-dsc-rubl-acc .

    ASSIGN
      p-no-VAT-rubl = p-to-pay-rubl - tt-allsum-line.vat-rubl-acc
      p-cost-rubl   = p-no-VAT-rubl / p-quantity2
      p-VAT-rubl    = tt-allsum-line.vat-rubl-acc
      p-article     = buf1_doc-line.artic
      p-passport    = "":U
      p-sale        = IF p-form = 13 THEN (tt-allsum-line.sum-dsc-rubl-cur) / p-quantity2
                                     ELSE (tt-allsum-line.sum-dsc-rubl-cur - tt-allsum-line.vat-rubl-cur) / p-quantity2
      p-prc         = IF p-form = 13 THEN tt-allsum-line.sum-dsc-rubl-cur
                                     ELSE (p-sale - p-cost-rubl) * 100 / p-cost-rubl
    .
  END. /* ON ERROR */
END PROCEDURE. /* get-vars */