block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-wthm11.p $
$Archive: rep/r-wthm11.p $

Печать требования-накладной (М-11)

Автор: Гридчина Полина Дмитриевна
Дата создания: 11/26/07
Author: Polina Gridchina
Creation date: 11/26/07

Input:

Output:

*/


/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER p-parent-proc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-doc-code    AS character     NO-UNDO.

/* VSS Variables Definitions */
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-wthm11.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-wthm11.p $":U .
define variable vss-description as character no-undo init "Печать требования-накладной (М-11)".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ cmp/r-pril.i   }
define variable g#report-num    as integer      no-undo.
{ gbl/prn-lib.i  }
{ gbl/waitfram.i }
{ gbl/word-sum.i }
{ rep/fmtcli.i      }
{ rep/torgconf.i   }

define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.

{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get " " p-parent-proc }
run get-report-num in p-parent-proc ( output g#report-num ).
run get-quest-print in p-parent-proc ( output g#quest-print ).

/* ********************  Preprocessor Definitions  ******************** */
&SCOP FRAME-NAME fr-prn-fm11
&SCOP run-proc   RUN clcprtsl_calc-line IN THIS-PROCEDURE ( ~{~&~params~} ) NO-ERROR. ~
                 IF ERROR-STATUS :ERROR THEN DO: UNDO, RETURN. END.
&SCOP temp-table tt-allsum-line
&SCOP suffix     acc
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

DEFINE VARIABLE v-account   AS CHARACTER NO-UNDO FORMAT "x(7)":U .
DEFINE VARIABLE v-analytics AS CHARACTER NO-UNDO FORMAT "x(6)":U.
DEFINE VARIABLE wealth-name AS CHARACTER NO-UNDO FORMAT "x(27)":U.
DEFINE VARIABLE v-article   AS CHARACTER NO-UNDO FORMAT "x(7)":U.
DEFINE VARIABLE v-unit-code AS CHARACTER NO-UNDO FORMAT "x(4)":U.
DEFINE VARIABLE v-unit-name AS CHARACTER NO-UNDO FORMAT "x(12)":U.
DEFINE VARIABLE v-quantity1 AS DECIMAL   NO-UNDO FORMAT "->,>>>,>>9.99":U.
DEFINE VARIABLE v-quantity2 AS DECIMAL   NO-UNDO FORMAT "->>,>>>,>>9.99":U.
DEFINE VARIABLE cost-rubl   AS DECIMAL   NO-UNDO FORMAT "->>>>,>>9.99":U.
DEFINE VARIABLE no-VAT-rubl AS DECIMAL   NO-UNDO FORMAT "->>>>,>>9.99":U.
DEFINE VARIABLE VAT-rubl    AS DECIMAL   NO-UNDO FORMAT "->>>,>>9.99":U.
DEFINE VARIABLE v-order     AS CHARACTER NO-UNDO FORMAT "x(10)":U.
DEFINE VARIABLE v-deliver_man  AS CHARACTER NO-UNDO FORMAT "x(24)":U.
DEFINE VARIABLE v-deliver_pos  AS CHARACTER NO-UNDO FORMAT "x(24)":U.
DEFINE VARIABLE v-receiver_man AS CHARACTER NO-UNDO FORMAT "x(24)":U.
DEFINE VARIABLE v-receiver_pos AS CHARACTER NO-UNDO FORMAT "x(55)":U.
DEFINE VARIABLE v-main-boss  AS CHARACTER NO-UNDO.
DEFINE VARIABLE total-qty1  AS DECIMAL   NO-UNDO FORMAT ">,>>>,>>9.99":U.
DEFINE VARIABLE total-qty2  AS DECIMAL   NO-UNDO FORMAT ">,>>>,>>9.99":U.
DEFINE VARIABLE total-noVAT AS DECIMAL   NO-UNDO FORMAT ">>>,>>>,>>9.99":U.
DEFINE VARIABLE j-order#    AS INTEGER   NO-UNDO FORMAT ">>9":U.
DEFINE VARIABLE word-ord    AS CHARACTER NO-UNDO.
DEFINE VARIABLE word-sum    AS CHARACTER NO-UNDO.
DEFINE VARIABLE word-VAT    AS CHARACTER NO-UNDO.

DEFINE BUFFER buf_doc  FOR ub.wth-doc.
DEFINE BUFFER buf_line FOR ub.wth-line.
DEFINE BUFFER buf_cli  FOR ub.clients.
DEFINE BUFFER buf_obj  FOR ub.clients.
DEFINE BUFFER buf_own  FOR ub.clients.
DEFINE BUFFER buf_psn  FOR ub.clients.
define buffer buf_person    for ub.person.
define buffer buf_clients   for ub.clients.
define buffer buf_firm      for ub.firm.
DEFINE BUFFER buf_wth-dtl FOR ub.wth-dtl.

/* ************************  Frame Definitions  *********************** */
DEFINE FRAME fr-prn-fm12
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
  sym11 SPACE( 0 ) v-order     SPACE( 0 )
  sym12 SPACE( 0 )
HEADER
/* ....+....1....+....2....+....3....+....4....+....5....+....6....+....7....+....8....+....9....+....C....+....1....+....2....+....3....+....4....+....5....+....6....+....7....+....8....+....9....+.... */
  ":--------------------------------------------------------------------------------------------------------------------------------------:" SKIP
  ":Корресп. счет :   Материальные ценности           :Единица измерения:        Количество          :    Цена,   : Сумма без  :Порядковый:" SKIP
  ":--------------:-----------------------------------:-----------------:----------------------------:{&abbr_rub}. {&abbr_kop}.   :  учета НДС,: номер по :" SKIP
  ": счет, : код  :       наименование        :номен- :код :наименование: затребовано :   отпущено   :            :{&abbr_rub}. {&abbr_kop}.   :складской :" SKIP
  ":субсчет:анали-:                           :клатур-:    :            :             :              :            :            :картотеке :"
  ":       :тичес-:                           : ный   :    :            :             :              :            :            :          :" SKIP
  ":       : кого :                           : номер :    :            :             :              :            :            :          :"
  ":       :учета :                           :       :    :            :             :              :            :            :          :" SKIP
  ":-------:------:---------------------------:-------:----:------------:-------------:--------------:------------:------------:----------:" SKIP
  ":   1   :  2   :           3               :   4   : 5  :     6      :     7       :      8       :      9     :     10     :    11    :" SKIP
/*     7       6              19          8     3      35                   13            13                20                    21              10           */
/*  "--------------------------------------------------------------------------------------------------------------------------------------" SKIP*/
WITH WIDTH 136 DOWN USE-TEXT STREAM-IO NO-BOX NO-LABELS.

  DEFINE FRAME fr-prn-fm11
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
  sym11 SPACE( 0 ) v-order     SPACE( 0 )
  sym12 SPACE( 0 )
HEADER
/* ....+....1....+....2....+....3....+....4....+....5....+....6....+....7....+....8....+....9....+....C....+....1....+....2....+....3....+....4....+....5....+....6....+....7....+....8....+....9....+.... */
  ":--------------------------------------------------------------------------------------------------------------------------------------:" SKIP
  ":Корресп. счет :   Материальные ценности           :Единица измерения:        Количество          :    Цена,   : Сумма без  :Порядковый:" SKIP
  ":--------------:-----------------------------------:-----------------:----------------------------:{&abbr_rub}. {&abbr_kop}.   :  учета НДС,: номер по :" SKIP
  ": счет, : код  :       наименование        :номен- :код :наименование: затребовано :   отпущено   :            :{&abbr_rub}. {&abbr_kop}.   :складской :" SKIP
  ":субсчет:анали-:                           :клатур-:    :            :             :              :            :            :картотеке :"
  ":       :тичес-:                           : ный   :    :            :             :              :            :            :          :" SKIP
  ":       : кого :                           : номер :    :            :             :              :            :            :          :"
  ":       :учета :                           :       :    :            :             :              :            :            :          :" SKIP
  ":-------:------:---------------------------:-------:----:------------:-------------:--------------:------------:------------:----------:" SKIP
  ":   1   :  2   :           3               :   4   : 5  :     6      :     7       :      8       :      9     :     10     :    11    :" SKIP
/*     7       6              19          8     3      35                   13            13                20                    21              10           */

WITH WIDTH 136 DOWN USE-TEXT STREAM-IO NO-BOX NO-LABELS.

/* ***************************  Main Block  *************************** */
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
Main-Block:
DO ON ERROR   UNDO Main-Block, LEAVE Main-Block
   ON END-KEY UNDO Main-Block, LEAVE Main-Block :
  FIND buf_doc NO-LOCK WHERE  buf_doc.doc-code = p-doc-code NO-ERROR.
  IF NOT AVAILABLE buf_doc THEN DO:
    MESSAGE "Документ не найден!" VIEW-AS ALERT-BOX ERROR.
    UNDO Main-Block, LEAVE Main-Block.
  END.
  RUN WaitFram-Show IN THIS-PROCEDURE ( INPUT "Ждите..." ).
  { cmp/open-out.i stream PrnLibStream " " {&CS_PS} }

/*   RUN prn-lib-open-stream IN THIS-PROCEDURE ( INPUT p-parent-proc, INPUT {&LS_PS_A4}, INPUT YES, INPUT NO ). */
 { gbl/working.i }
 run  torgconf-read ('wthm11',buf_doc.host-code,buf_doc.obj-type,buf_doc.obj-code) no-error.
 if error-status :error
then do:
    message
    vss-workfile vss-revision vss-description
    skip "Ошибка чтения параметров печати формы."
    skip "Форма будет напечатана с параметрами по умолчанию."
    skip return-value
    skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
    view-as alert-box error.
end.

 run torgconf-get-self-param in this-procedure (
      input buf_doc.obj-type
    , input buf_doc.obj-code
    , input 0
) no-error.
if error-status :error
then do:
    message
    vss-workfile vss-revision vss-description
    skip "Ошибка чтения параметров объекта документа."
    skip return-value
    skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
    view-as alert-box warning.
end.
run torgconf-get-cli-param in this-procedure (
      input buf_doc.host-code
    , input buf_doc.cli-type
    , input buf_doc.cli-code
    , input 0
) no-error.
if error-status :error
then do:
    message
    vss-workfile vss-revision vss-description
    skip "Ошибка чтения параметров объекта клиента документа."
    skip return-value
    skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
    view-as alert-box warning.
end.
run torgconf-get-outogr-param in this-procedure (
      'wthm11'
    , input buf_doc.host-code
    , input buf_doc.cli-type
    , input buf_doc.cli-code
    , input buf_doc.doc-code
) no-error.
if error-status :error
then do:
    message
    vss-workfile vss-revision vss-description
    skip "Ошибка чтения параметров 'Отпуск разрешил'."
    skip return-value
    skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
    view-as alert-box warning.
end.


  if buf_doc.deliver <> ? then do:
    FIND buf_psn NO-LOCK WHERE
        buf_psn.obj-type = {&prs}       AND
        buf_psn.obj-code = buf_doc.deliver NO-ERROR.
    v-deliver_man =  ( IF AVAILABLE buf_psn THEN TRIM( buf_psn.obj-name ) ELSE '' ).
    find first buf_person no-lock where
        buf_person.psn-code = buf_doc.deliver no-error.
    v-deliver_pos =  ( IF AVAILABLE buf_person THEN TRIM( buf_person.position ) ELSE '' ).
  end.
  if buf_doc.receiver <> ? then do:
    FIND buf_psn NO-LOCK WHERE
        buf_psn.obj-type = {&prs}       AND
        buf_psn.obj-code = buf_doc.receiver NO-ERROR.
    v-receiver_man =  ( IF AVAILABLE buf_psn THEN TRIM( buf_psn.obj-name) ELSE '' ).
    find first buf_person no-lock where
        buf_person.psn-code = buf_doc.receiver no-error.
    v-receiver_pos =  ( IF AVAILABLE buf_person THEN TRIM( buf_person.position) ELSE '' ).
  end.




  PUT STREAM PrnLibStream UNFORMATTED "Типовая межотраслевая форма № М-11"            AT 90 SKIP
                                      "Утверждена постановлением Госкомстата России"  AT 90 SKIP
                                      "от 30.10.97 № 71а"                             AT 90 SKIP.
  PUT STREAM PrnLibStream UNFORMATTED "Т Р Е Б О В А Н И Е - Н А К Л А Д Н А Я   №  " AT  10.
  PUT STREAM PrnLibStream UNFORMATTED buf_doc.doc-code                                       SKIP.
  PUT STREAM PrnLibStream UNFORMATTED               "+-------------+" AT 121 SKIP
                                                    "|     Коды    |" AT 121 SKIP
                                                    "+-------------+" AT 121 SKIP
                                      "Форма по ОКУД |   0315006   |" AT 107 SKIP
                                                    "+-------------+" AT 121 SKIP
     /*"Организация    " + */ v-torgconf-self-host-name
                                            "по ОКПО |             |" AT 113 SKIP
                                                    "+-------------+" AT 121 SKIP.
/*   ....+....1....+....2....+....3....+....4....+....5....+....6....+....7....+....8....+....9....+....C....+....1....+....2....+....3....+....4....+....5....+....6....+....7....+....8....+....9....+.... */
  PUT STREAM PrnLibStream UNFORMATTED
    ":-------------------------------------------------------------------------------------------------------------------------------------:" AT 1 SKIP
    ":    Дата   :  Код вида :            Отправитель           :            Получатель            :   Корреспондирующий  :     Учетная    :" AT 1 SKIP
    ":составления:  операции :                                  :                                  :         счет         :     единица    :" AT 1 SKIP
    ":           :           :---------------------:------------:---------------------:------------:----------------------:     выпуска    :" AT 1 SKIP
    ":           :           :     структурное     :     вид    :     структурное     :     вид    : счет, : код аналити- :    продукции   :" AT 1 SKIP
    ":           :           :    подразделение    :деятельности:    подразделение    :деятельности:субсчет: ческого учета: (работ, услуг) :" AT 1 SKIP
    ":-----------:-----------:---------------------:------------:---------------------:------------:-------:--------------:----------------:" AT 1 SKIP
    ":     1     :     2     :          3          :      4     :          5          :      6     :   7   :       8      :        9       :" AT 1 SKIP
    "---------------------------------------------------------------------------------------------------------------------------------------" AT 1 SKIP.

  PUT STREAM PrnLibStream UNFORMATTED
    ": " + STRING( buf_doc.doc-date, "99.99.9999":U ) +
                ":" +  "           ":U  +
           /*     ":" + (if buf_doc.doc-type = {&expense} then STRING( buf_obj.obj-name, "x(21)":U) else string(buf_cli.obj-name, "x(21)":U) ) + */
            ":" + STRING( v-torgconf-self-obj-name, "x(21)":U)  +
                ":            :" +
                (if buf_doc.doc-type = {&expense} then STRING(  v-torgconf-cli-name, "x(21)":U) else STRING( v-torgconf-self-obj-name, "x(21)":U) ) +
                                                                                     ":            :       :              :                :" AT 1 SKIP.
  PUT STREAM PrnLibStream UNFORMATTED
    "---------------------------------------------------------------------------------------------------------------------------------------" AT 1 SKIP.
  PUT STREAM PrnLibStream UNFORMATTED
    "Через кого " if v-receiver_man > '' then v-receiver_man else  FILL( "_", 124 ) SKIP
    "Затребовал " if v-receiver_man > '' then v-receiver_man else FILL( "_",  55 ) SPACE( 5 )
    "Разрешил "   if v-torgconf-ogr-name > ''    then v-torgconf-ogr-name else FILL( "_",  55 ) SKIP.

  ASSIGN total-qty1  = 0
         total-qty2  = 0
         total-noVAT = 0
         VAT-rubl    = 0
         j-order#    = 0.
  FOR EACH buf_line NO-LOCK WHERE
           buf_line.doc-code = buf_doc.doc-code
  BREAK BY buf_line.wth-code:

      if can-find (first buf_wth-dtl where buf_wth-dtl.doc-code = buf_doc.doc-code
                                     and buf_wth-dtl.wth-code = buf_line.wth-code
                                     and buf_wth-dtl.wth-code = buf_line.wth-code
                                     no-lock )
      then
      for each buf_wth-dtl no-lock where buf_wth-dtl.doc-code = buf_doc.doc-code
                                     and buf_wth-dtl.wth-code = buf_line.wth-code
                                     and buf_wth-dtl.w-p-code = buf_line.w-p-code:
          RUN get-dtl-vars IN THIS-PROCEDURE (  INPUT RECID( buf_wth-dtl ),
                                          OUTPUT wealth-name,
                                          OUTPUT v-unit-code,
                                          OUTPUT v-unit-name,
                                          OUTPUT v-quantity1,
                                          OUTPUT v-quantity2,
                                          OUTPUT cost-rubl,
                                          OUTPUT no-VAT-rubl,
                                          OUTPUT v-order            ) NO-ERROR.
          IF ERROR-STATUS :ERROR THEN DO: UNDO Main-Block, LEAVE Main-Block. END.

          DISPLAY STREAM PrnLibStream sym1
                                      sym2
                                      sym3  wealth-name WHEN wealth-name <> ?
                                      sym4
                                      sym5  v-unit-code WHEN v-unit-code <> ?
                                      sym6  v-unit-name WHEN v-unit-name <> ?
                                      sym7  v-quantity1 WHEN v-quantity1 <> ? AND v-quantity1 <> 0
                                      sym8  v-quantity2 WHEN v-quantity2 <> ? AND v-quantity2 <> 0
                                      sym9  cost-rubl   WHEN cost-rubl   <> ? AND cost-rubl   <> 0
                                      sym10 no-VAT-rubl WHEN no-VAT-rubl <> ? AND no-VAT-rubl <> 0
                                      sym11 v-order     WHEN v-order     <> ?
                                      sym12
          WITH FRAME fr-prn-fm11.

            ASSIGN total-qty1  = total-qty1  + ( IF v-quantity1 <> ? THEN v-quantity1 ELSE 0 )
          total-qty2  = total-qty2  + ( IF v-quantity2 <> ? THEN v-quantity2 ELSE 0 )
          total-noVAT = total-noVAT + ( IF no-VAT-rubl <> ? THEN no-VAT-rubl ELSE 0 )
          j-order#    = j-order#    + 1.


      end.  /*is dtl*/
      else do:
          RUN get-vars IN THIS-PROCEDURE (  INPUT RECID( buf_line ),
                                          OUTPUT wealth-name,
                                          OUTPUT v-unit-code,
                                          OUTPUT v-unit-name,
                                          OUTPUT v-quantity1,
                                          OUTPUT v-quantity2,
                                          OUTPUT cost-rubl,
                                          OUTPUT no-VAT-rubl,
                                          OUTPUT v-order            ) NO-ERROR.
          IF ERROR-STATUS :ERROR THEN DO: UNDO Main-Block, LEAVE Main-Block. END.

      /*    IF LAST( buf_line.artic ) THEN DO:
            IF LINE-COUNTER( PrnLibStream ) + 9 > PAGE-SIZE( PrnLibStream ) THEN DO: PAGE STREAM PrnLibStream. END.
          END. */

          DISPLAY STREAM PrnLibStream sym1
                                      sym2
                                      sym3  wealth-name WHEN wealth-name <> ?
                                      sym4
                                      sym5  v-unit-code WHEN v-unit-code <> ?
                                      sym6  v-unit-name WHEN v-unit-name <> ?
                                      sym7  v-quantity1 WHEN v-quantity1 <> ? AND v-quantity1 <> 0
                                      sym8  v-quantity2 WHEN v-quantity2 <> ? AND v-quantity2 <> 0
                                      sym9  cost-rubl   WHEN cost-rubl   <> ? AND cost-rubl   <> 0
                                      sym10 no-VAT-rubl WHEN no-VAT-rubl <> ? AND no-VAT-rubl <> 0
                                      sym11 v-order     WHEN v-order     <> ?
                                      sym12
          WITH FRAME fr-prn-fm12.
          ASSIGN total-qty1  = total-qty1  + ( IF v-quantity1 <> ? THEN v-quantity1 ELSE 0 )
                total-qty2  = total-qty2  + ( IF v-quantity2 <> ? THEN v-quantity2 ELSE 0 )
                total-noVAT = total-noVAT + ( IF no-VAT-rubl <> ? THEN no-VAT-rubl ELSE 0 )
                j-order#    = j-order#    + 1.
      end.   /*no dtl*/
  END. /* FOR EACH buf_line */

/*  FIND ub.currency NO-LOCK WHERE ub.currency.curr-code = 0.
  ASSIGN word-sum = Word-Sum( total-noVAT ).
  ASSIGN word-ord = Word-Sum( DECIMAL( j-order# ) ).
  ASSIGN word-sum = ( IF total-noVAT < 0 THEN "- " ELSE "":U ) + TRIM( word-sum  ) + " ":U + ub.currency.curr-abbr + ". ":U +
                    SUBSTRING( STRING( ABS( total-noVAT ), "999999999999999.99" ), 17, 2 ) + " ":U + ub.currency.part-abbr + ".".
  ASSIGN word-VAT = ( IF VAT-rubl < 0 THEN "- " ELSE "":U ) + ( IF VAT-rubl <> 0 THEN
                    LEFT-TRIM( SUBSTRING( STRING( ABS( VAT-rubl ), "999999999999999.99" ),  1, 15 ), "0" )
                                                                                 ELSE "0" )         + " ":U + ub.currency.curr-abbr + ". ":U +
                               SUBSTRING( STRING( ABS( VAT-rubl ), "999999999999999.99" ), 17,  2 ) + " ":U + ub.currency.part-abbr + ".".
  IF LENGTH( TRIM( word-ord ) ) < 100 THEN DO:
    ASSIGN word-ord = TRIM( word-ord ) + FILL( "_", 100 - LENGTH( TRIM( word-ord ) ) ).
  END.    */

  PUT STREAM PrnLibStream UNFORMATTED
    ":-------:------:---------------------------:-------:----:------------:-------------:--------------:-----------:-------------:----------:" SKIP
    ":       :      : ИТОГО                     :       :    :            :" +
     STRING( total-qty1,  "->,>>>,>>9.99":U         ) +
                                                                                                                                  ":" +
     STRING( total-qty2,  "->>,>>>,>>9.99":U         ) +
                                                                                                                                                ":            :" +
     (if total-noVAT <> 0 then STRING( total-noVAT, "->>>>,>>9.99":U ) else '             ' ) +
                                                                                                                                             ":          :" SKIP
    "---------------------------------------------------------------------------------------------------------------------------------------" SKIP.
/*  PUT STREAM PrnLibStream UNFORMATTED
    "Всего отпущено: ___" + STRING( word-ord, "x(100)":U ) + " наименований" SKIP
    "На сумму: "          + STRING( word-sum, "x(185)":U )                   SKIP
    "В том числе НДС: "   + STRING( word-VAT, "x(18)":U  )                   SKIP. */
  PUT STREAM PrnLibStream UNFORMATTED
    "Отпустил " (if v-deliver_pos > '' then string(v-deliver_pos,"X(26)") else FILL( "_",  25 )) "     ":U FILL( "_",  25 ) "     ":U (if v-deliver_man > '' then v-deliver_man else  FILL( "_",  25 ))   skip
    "               должность                      подпись                    расшифровка подписи "      skip(2)
    "Получил "  (if v-receiver_pos > '' then string(v-receiver_pos,"X(26)")  else FILL( "_",  26 )) "     ":U FILL( "_",  25 ) "     ":U ( if v-receiver_man > '' then v-receiver_man else FILL ("_",  25 ))           SKIP
    "               должность                      подпись                    расшифровка подписи " SKIP.

  OUTPUT STREAM PrnLibStream CLOSE.
  RUN WaitFram-Hide IN THIS-PROCEDURE.

  /*RUN prn-lib-prn-file IN THIS-PROCEDURE ( INPUT p-parent-proc, INPUT 8 ).     */
     /* hide stream PrnLibStream frame BottomFrame . */
        { gbl/stopwork.i }

    { rep/q-print.i 4}

END. /* Main-Block */
RUN WaitFram-Hide IN THIS-PROCEDURE.

/* **********************  Internal Procedures  *********************** */
PROCEDURE get-vars :
  DEFINE  INPUT PARAMETER p-line-rec_id   AS RECID     NO-UNDO.
  DEFINE OUTPUT PARAMETER p-wealth-name   AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-unit-code     AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-unit-name     AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-quantity-doc  AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-quantity-fact AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-cost-rubl     AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-no-VAT-rubl   AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-order         AS CHARACTER NO-UNDO.

  DEFINE BUFFER buf-line    FOR ub.wth-line.
  DEFINE BUFFER buf-wealth  FOR ub.wealth.
  DEFINE BUFFER buf-unit    FOR ub.units.

  DO ON ERROR UNDO, RETURN :
    FIND buf-line NO-LOCK WHERE RECID( buf-line ) = p-line-rec_id NO-ERROR.
    IF NOT AVAILABLE buf-line THEN DO: UNDO, RETURN ERROR. END.
    ASSIGN p-quantity-doc  = buf-line.doc-sum
           p-quantity-fact = buf-line.fact-sum.
    FIND first buf-wealth NO-LOCK WHERE
         buf-wealth.wth-code     = buf-line.wth-code NO-ERROR.
    ASSIGN p-wealth-name   = ( IF AVAILABLE buf-wealth  THEN buf-wealth.wth-name   ELSE "":U ).
    if buf-wealth.unit-base > "":U then do:
      FIND buf-unit NO-LOCK WHERE buf-unit.unit-name = buf-wealth.unit-base NO-ERROR.
      ASSIGN p-unit-name     = ( IF AVAILABLE buf-unit THEN buf-unit.long-name ELSE "":U ).
    end.
    /* ASSIGN VAT-rubl        = VAT-rubl + {&sum-VAT}.  */
  END. /* ON ERROR */
END PROCEDURE. /* get-vars */
PROCEDURE get-dtl-vars :
  DEFINE  INPUT PARAMETER p-rec_id   AS RECID     NO-UNDO.
  DEFINE OUTPUT PARAMETER p-wealth-name   AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-unit-code     AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-unit-name     AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-quantity-doc  AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-quantity-fact AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-cost-rubl     AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-no-VAT-rubl   AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-order         AS CHARACTER NO-UNDO.

  DEFINE BUFFER buf-dtl    FOR ub.wth-dtl.
  DEFINE BUFFER buf_wth-par    FOR ub.wth-par.
  DEFINE BUFFER buf-wealth  FOR ub.wealth.
  DEFINE BUFFER buf_unit    FOR ub.units.

  DO ON ERROR UNDO, RETURN :
    FIND buf-dtl NO-LOCK WHERE RECID( buf-dtl ) = p-rec_id NO-ERROR.
    IF NOT AVAILABLE buf-dtl THEN DO: UNDO, RETURN ERROR. END.
    ASSIGN p-quantity-doc  = buf-dtl.doc-sum
           p-quantity-fact = buf-dtl.fact-sum.
    FIND first buf-wealth NO-LOCK WHERE
         buf-wealth.wth-code     = buf-dtl.wth-code NO-ERROR.
    ASSIGN p-wealth-name   = ( IF AVAILABLE buf-wealth  THEN buf-wealth.wth-name   ELSE "":U ).

    if not buf-wealth.is-money then do: /*дял денег нет ед.измерения*/
      FIND first buf_unit NO-LOCK WHERE buf_unit.unit-name = buf-wealth.unit-base NO-ERROR.
      IF AVAILABLE buf_unit THEN do:
        assign
          p-unit-name = buf_unit.long-name
        .
      end.
    end.
/*    if buf-wealth.unit-base > "":U then do:*/
/*      FIND buf-unit NO-LOCK WHERE buf-unit.unit-name = buf-wealth.unit-base NO-ERROR.*/
/*      ASSIGN p-unit-name     = ( IF AVAILABLE buf-unit THEN buf-unit.long-name ELSE "":U ).*/
/*    end.*/
    find first buf_wth-par no-lock where buf_wth-par.wth-code = buf-dtl.wth-code
                                    and  buf_wth-par.par-code = buf-dtl.par-code no-error.
    if available buf_wth-par then do:
        p-wealth-name = p-wealth-name + substitute(" &1&2",buf_wth-par.par-val, buf_wth-par.par-unit).
        p-quantity-doc =  p-quantity-doc / buf_wth-par.par-rate.
        p-quantity-fact =  p-quantity-fact / buf_wth-par.par-rate.

    end.

    /* ASSIGN VAT-rubl        = VAT-rubl + {&sum-VAT}.  */
  END. /* ON ERROR */
END PROCEDURE. /* get-dtl-vars */