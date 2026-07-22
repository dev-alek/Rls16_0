&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Детализация по номиналам для документов обмена МЦ

Автор: Гридчина Полина Дмитриевна
Дата создания: 10/04/07
Author: Polina Gridchina
Creation date: 10/04/07

*/


/*------------------------------------------------------------------------

  File:

  Description:

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author:

  Created:
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE TEMP-TABLE tt-par-dtl NO-UNDO LIKE ub.wth-par
       { str/ttpardt0.i }.

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code  like ub.clients.obj-code no-undo .
DEFINE INPUT PARAMETER par-mode as character no-undo .
define input parameter parline-rec as recid no-undo.
define input parameter pardoc-code like ub.wth-line.doc-code no-undo .
define input parameter parwth-code like ub.wth-line.wth-code no-undo .
define input parameter parw-p-code like ub.wth-line.w-p-code no-undo .
define input parameter pardoc-sum like ub.wth-line.doc-sum no-undo .
define input parameter parfact-sum like ub.wth-line.fact-sum no-undo .
define input parameter parbef-sum like ub.wth-line.bef-sum no-undo .
define input parameter paraft-sum like ub.wth-line.aft-sum no-undo .
DEFINE INPUT PARAMETER pardoc-type like ub.wth-doc.doc-type no-undo .
define input parameter parext-type like ub.wth-doc.ext-doc-type no-undo.
define input-output parameter table for tt-par-dtl.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Детализация по номиналам для документов обмена МЦ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }

DEFINE TEMP-TABLE tt-dtl-income NO-UNDO LIKE ub.wth-par
       { str/ttpardt0.i }.
DEFINE TEMP-TABLE tt-dtl-expense NO-UNDO LIKE ub.wth-par
       { str/ttpardt0.i }.
DEFine VARiable d_doc-sum LIKE ub.wth-doc.doc-sum NO-UNDO.
DEFine VARiable d_fact-sum LIKE ub.wth-doc.doc-sum NO-UNDO.
DEFINE VARIABLE vardoc-status_ like ub.wth-doc.status_ no-undo .
define buffer buf_wth-par   for ub.wth-par.
define buffer buf_wth-doc   for ub.wth-doc.
define buffer buf_wth-parts for ub.wth-parts.
define buffer buf_wth-line    for ub.wth-line.
define buffer buf_wealth      for ub.wealth.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-exp

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-dtl-expense tt-dtl-income

/* Definitions for BROWSE BR-exp                                        */
&Scoped-define FIELDS-IN-QUERY-BR-exp tt-dtl-expense.par-val tt-dtl-expense.par-unit tt-dtl-expense.q-ty-doc tt-dtl-expense.doc-sum tt-dtl-expense.q-ty-fact tt-dtl-expense.fact-sum tt-dtl-expense.sum-gds-rubl tt-dtl-expense.sum-gds-base tt-dtl-expense.price-rubl tt-dtl-expense.price-base tt-dtl-expense.gds-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-exp
&Scoped-define SELF-NAME BR-exp
&Scoped-define QUERY-STRING-BR-exp FOR EACH tt-dtl-expense
&Scoped-define OPEN-QUERY-BR-exp OPEN QUERY {&SELF-NAME} FOR EACH tt-dtl-expense.
&Scoped-define TABLES-IN-QUERY-BR-exp tt-dtl-expense
&Scoped-define FIRST-TABLE-IN-QUERY-BR-exp tt-dtl-expense


/* Definitions for BROWSE BR-inc                                        */
&Scoped-define FIELDS-IN-QUERY-BR-inc tt-dtl-income.par-val tt-dtl-income.par-unit tt-dtl-income.q-ty-doc tt-dtl-income.doc-sum tt-dtl-income.q-ty-fact tt-dtl-income.fact-sum tt-dtl-income.sum-gds-rubl tt-dtl-income.sum-gds-base tt-dtl-income.price-rubl tt-dtl-income.price-base tt-dtl-income.gds-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-inc
&Scoped-define SELF-NAME BR-inc
&Scoped-define QUERY-STRING-BR-inc FOR EACH tt-dtl-income
&Scoped-define OPEN-QUERY-BR-inc OPEN QUERY {&SELF-NAME} FOR EACH tt-dtl-income.
&Scoped-define TABLES-IN-QUERY-BR-inc tt-dtl-income
&Scoped-define FIRST-TABLE-IN-QUERY-BR-inc tt-dtl-income


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-exp}~
    ~{&OPEN-QUERY-BR-inc}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help BR-inc BR-exp ~
tot-qty-inc tot-dtl-inc tot-sum-inc tot-qty-exp tot-dtl-exp tot-sum-exp
&Scoped-Define DISPLAYED-OBJECTS tot-qty-inc tot-dtl-inc tot-sum-inc ~
tot-qty-exp tot-dtl-exp tot-sum-exp

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-partsExp
     LABEL "&ПартВыдано"
     SIZE 11 BY 1.

DEFINE BUTTON B-partsInc
     LABEL "&ПартПрин"
     SIZE 11 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "Отменить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE tot-dtl-exp AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0
     LABEL "По товарам:   кол-во"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE tot-dtl-inc AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0
     LABEL "По товарам:   кол-во"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE tot-qty-exp AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0
     LABEL "Кол-во МЦ"
      VIEW-AS TEXT
     SIZE 11 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE tot-qty-inc AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "Кол-во МЦ"
      VIEW-AS TEXT
     SIZE 11 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE tot-sum-exp AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0
     LABEL "сумма"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE tot-sum-inc AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0
     LABEL "сумма"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-exp FOR
      tt-dtl-expense SCROLLING.

DEFINE QUERY BR-inc FOR
      tt-dtl-income SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-exp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-exp Dialog-Frame _FREEFORM
  QUERY BR-exp DISPLAY
      tt-dtl-expense.par-val
tt-dtl-expense.par-unit
tt-dtl-expense.q-ty-doc
tt-dtl-expense.doc-sum
tt-dtl-expense.q-ty-fact
tt-dtl-expense.fact-sum
tt-dtl-expense.sum-gds-rubl
tt-dtl-expense.sum-gds-base
tt-dtl-expense.price-rubl
tt-dtl-expense.price-base
tt-dtl-expense.gds-code
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 101.5 BY 6.5
         TITLE "Выдано" FIT-LAST-COLUMN.

DEFINE BROWSE BR-inc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-inc Dialog-Frame _FREEFORM
  QUERY BR-inc DISPLAY
      tt-dtl-income.par-val
tt-dtl-income.par-unit
tt-dtl-income.q-ty-doc
tt-dtl-income.doc-sum
tt-dtl-income.q-ty-fact
tt-dtl-income.fact-sum
tt-dtl-income.sum-gds-rubl
tt-dtl-income.sum-gds-base
tt-dtl-income.price-rubl
tt-dtl-income.price-base
tt-dtl-income.gds-code
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 101.5 BY 6.25
         TITLE "Принято" FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.13 WIDGET-ID 6
     b-quit AT ROW 1 COL 11.13 WIDGET-ID 12
     B-partsInc AT ROW 1 COL 36 WIDGET-ID 14
     B-partsExp AT ROW 1 COL 47 WIDGET-ID 4
     B-Help AT ROW 1 COL 92.5 WIDGET-ID 8
     BR-inc AT ROW 3.25 COL 1 WIDGET-ID 300
     BR-exp AT ROW 11.75 COL 1 WIDGET-ID 200
     tot-qty-inc AT ROW 10 COL 26.5 COLON-ALIGNED WIDGET-ID 22
     tot-dtl-inc AT ROW 10 COL 62 COLON-ALIGNED WIDGET-ID 30
     tot-sum-inc AT ROW 10 COL 85.5 COLON-ALIGNED WIDGET-ID 24
     tot-qty-exp AT ROW 18.75 COL 26.5 COLON-ALIGNED WIDGET-ID 18
     tot-dtl-exp AT ROW 18.75 COL 62 COLON-ALIGNED WIDGET-ID 28
     tot-sum-exp AT ROW 18.75 COL 85 COLON-ALIGNED WIDGET-ID 20
     "ИТОГО принято:" VIEW-AS TEXT
          SIZE 14.5 BY .67 AT ROW 10 COL 2 WIDGET-ID 26
          FGCOLOR 4
     "ИТОГО выдано:" VIEW-AS TEXT
          SIZE 13 BY .67 AT ROW 18.75 COL 3 WIDGET-ID 16
          FGCOLOR 4
     SPACE(86.50) SKIP(0.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Детализация по номиналам при обмене" WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-inc B-Help Dialog-Frame */
/* BROWSE-TAB BR-exp BR-inc Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-partsExp IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON B-partsInc IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-exp
/* Query rebuild information for BROWSE BR-exp
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-dtl-expense.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-exp */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-inc
/* Query rebuild information for BROWSE BR-inc
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-dtl-income.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-inc */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Детализация по номиналам при обмене */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:

  IF par-mode = {&lookup} THEN DO:
    RETURN NO-APPLY.
  END.
  run proc-save no-error.
  if error-status:error then return.

  { gbl/stdbtn.i }
/*   DO TRANSACTION on error undo, return NO-apply                                                                */
/*                                 on stop undo, return no-apply:                                                 */
/*   case vardoc-status_:                                                                                         */
/*     when {&wayb} then do:                                                                                      */
/*       FOR EACH tt-par-dtl:                                                                                     */
/*         IF tt-par-dtl.doc-sum  = 0 AND tt-par-dtl.q-ty-doc  = 0 THEN DO:                                       */
/*           NEXT.                                                                                                */
/*         END.                                                                                                   */
/*         IF tt-par-dtl.doc-sum  = 0 AND tt-par-dtl.q-ty-doc <> 0 OR                                             */
/*           tt-par-dtl.doc-sum <> 0 AND tt-par-dtl.q-ty-doc  = 0                                                 */
/*         THEN DO:                                                                                               */
/*           IF tt-par-dtl.doc-sum  = 0 AND tt-par-dtl.q-ty-doc <> 0 THEN DO:                                     */
/*             ASSIGN                                                                                             */
/*             tt-par-dtl.doc-sum = tt-par-dtl.q-ty-doc * tt-par-dtl.par-val * tt-par-dtl.par-rate.               */
/*           END.                                                                                                 */
/*           IF tt-par-dtl.doc-sum <> 0 AND tt-par-dtl.q-ty-doc  = 0 THEN DO:                                     */
/*             ASSIGN tt-par-dtl.q-ty-doc    = tt-par-dtl.doc-sum / ( tt-par-dtl.par-val * tt-par-dtl.par-rate ). */
/*           END.                                                                                                 */
/*         END.                                                                                                   */
/*       END.                                                                                                     */
/*     end.                                                                                                       */
/*     when {&permitted} then do:                                                                                 */
/*       FOR EACH tt-par-dtl:                                                                                     */
/*         IF tt-par-dtl.fact-sum  = 0 AND tt-par-dtl.q-ty-fact  = 0 THEN DO:                                     */
/*           NEXT.                                                                                                */
/*         END.                                                                                                   */
/*         IF tt-par-dtl.fact-sum  = 0 AND tt-par-dtl.q-ty-fact <> 0 OR                                           */
/*            tt-par-dtl.fact-sum <> 0 AND tt-par-dtl.q-ty-fact  = 0                                              */
/*         THEN DO:                                                                                               */
/*           IF tt-par-dtl.fact-sum  = 0 AND tt-par-dtl.q-ty-fact <> 0 THEN DO:                                   */
/*             ASSIGN                                                                                             */
/*             tt-par-dtl.fact-sum = tt-par-dtl.q-ty-fact * tt-par-dtl.par-val * tt-par-dtl.par-rate.             */
/*           END.                                                                                                 */
/*           IF tt-par-dtl.fact-sum <> 0 AND tt-par-dtl.q-ty-fact  = 0 THEN DO:                                   */
/*             ASSIGN tt-par-dtl.q-ty-fact = tt-par-dtl.fact-sum / ( tt-par-dtl.par-val * tt-par-dtl.par-rate ).  */
/*           END.                                                                                                 */
/*         END.                                                                                                   */
/*       END.                                                                                                     */
/*     end.                                                                                                       */
/*     END CASE.                                                                                                  */
/*   END. /*transaction*/                                                                                         */
  APPLY "GO":U TO FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-partsExp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-partsExp Dialog-Frame
ON CHOOSE OF B-partsExp IN FRAME Dialog-Frame /* ПартВыдано */
DO:
apply 'entry':U to br-exp.
if not available tt-dtl-expense then return.
run str/wthparts.w (
                 input parparentproc
                ,input p-curr-host-code
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input 'document':U
                ,input (if par-mode = {&lookup} then {&lookup} else {&update})
                ,input parwth-code
                ,input tt-dtl-expense.par-code
                ,INPUT 0
                ,input 0
                ,INPUT buf_wth-doc.doc-code
                ,INPUT parw-p-code
                ,INPUT buf_wth-doc.cli-type
                ,INPUT buf_wth-doc.cli-code
                ,input {&expense} ) no-error.
if error-status:error then do:
  message return-value error-status:get-message(1) view-as alert-box error title 'Ошибка при запуске wthparts.w'.
  return no-apply.
end.
if par-mode <> {&lookup} then do:
  { str/dtlexsum.i tt-dtl-expense buf_wth-parts {&expense} }
    DISPLAY
    tt-dtl-expense.q-ty-doc
    tt-dtl-expense.doc-sum
    tt-dtl-expense.q-ty-fact
    tt-dtl-expense.fact-sum
    tt-dtl-expense.sum-gds-rubl
    tt-dtl-expense.sum-gds-base
    tt-dtl-expense.price-rubl
    tt-dtl-expense.price-base
    WITH BROWSE br-exp.
  run calc-tot('exp':U).
 end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-partsInc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-partsInc Dialog-Frame
ON CHOOSE OF B-partsInc IN FRAME Dialog-Frame /* ПартПрин */
DO:
if not available tt-dtl-income then return.
run str/wthparts.w (
                 input parparentproc
                ,input p-curr-host-code
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input 'document':U
                ,input (if par-mode = {&lookup} then {&lookup} else {&update})
                ,input parwth-code
                ,input tt-dtl-income.par-code
                ,INPUT 0
                ,input 0
                ,INPUT buf_wth-doc.doc-code
                ,INPUT parw-p-code
                ,INPUT buf_wth-doc.cli-type
                ,INPUT buf_wth-doc.cli-code
                ,input {&income} ) no-error.
if error-status:error then do:
  message return-value error-status:get-message(1) view-as alert-box error title 'Ошибка при запуске wthparts.w'.
  return no-apply.
end.
if par-mode <> {&lookup} then do:
{ str/dtlexsum.i tt-dtl-income buf_wth-parts  {&income}}
    DISPLAY
    tt-dtl-income.q-ty-doc
    tt-dtl-income.doc-sum
    tt-dtl-income.q-ty-fact
    tt-dtl-income.fact-sum
    tt-dtl-income.sum-gds-rubl
    tt-dtl-income.sum-gds-base
    tt-dtl-income.price-rubl
    tt-dtl-income.price-base
    WITH BROWSE br-inc.
    run calc-tot('inc':U).
 end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-exp
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  if par-mode <> {&update} and par-mode <> {&add-def} and par-mode <> {&lookup} then do:
      message vss-workfile vss-revision vss-description skip
                  "Неверный параметр вызова par-mode"
      view-as alert-box ERROR.
      return error.
  end.
  if par-mode = {&lookup} then do:
        FIND FIRST buf_wth-line No-LOCK WHERE
                   recid(buf_wth-line) = parline-rec No-ERROR.
  end.
  if par-mode = {&update} then do:
        FIND FIRST buf_wth-line EXCLUSIVE-LOCK WHERE
                   recid(buf_wth-line) = parline-rec NO-WAIT No-ERROR.
      IF LOCKED buf_wth-line then do:
        message
        vss-workfile vss-revision vss-description skip
        "Занята запись строки документа движения МЦ"
        view-as alert-box.
        return error.
      end.
      IF NOT avail buf_wth-line then do:
        message
        vss-workfile vss-revision vss-description skip
        "Не найдена строка документа движения МЦ"
        view-as alert-box.
        return error.
      end.
  assign
  pardoc-code = buf_wth-line.doc-code
  parwth-code = buf_wth-line.wth-code
  .
  end.
  FIND FIRST buf_wth-doc No-LOCK WHERE
             buf_wth-doc.doc-code = pardoc-code No-ERROR.
  IF NOT AVAIL buf_wth-doc THEN DO:
    MESSAGE  "Не найден документ движения МЦ"
    VIEW-AS ALERT-BOX ERROR.
    RETURN error.
  END.
  if par-mode = {&update} and buf_wth-doc.status_ = {&fact} then do:
       message "Документ движения МЦ с N" buf_wth-doc.doc-code  "имеет статус" buf_wth-doc.status_ SKIP
                      "Изменения не допускаются"
        view-as alert-box error.
        return error.
  end.
  if LOOKUP(buf_wth-doc.ext-doc-type, {&WDEDT_list}) = 0 then do:
    MESSAGE
    vss-workfile vss-revision vss-description skip
    "Неверный вызов - документ МЦ имеет тип" buf_wth-doc.doc-type
    VIEW-AS ALERT-BOX ERROR.
    RETURN error.
  end.
  vardoc-status_ = buf_wth-doc.status_.
  FIND FIRST buf_wealth No-LOCK WHERE
              buf_wealth.wth-code = parwth-code NO-ERROR.
  IF NOT AVAIL buf_wealth THEN DO:
      MESSAGE
        "Не найдена материальная ценность в справочнике!"
      VIEW-AS ALERT-BOX ERROR.
      RETURN error.
  END.
  run fill-tables in this-Procedure no-error.
  if error-status:error then return error.
  RUN calc-tot("":U).
  RUN Myenable.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-tot Dialog-Frame
PROCEDURE calc-tot :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER p-calc AS CHAR.
if p-calc = '':U or p-calc = 'inc':U then do:
  assign tot-qty-inc = 0
         tot-sum-inc = 0
         tot-dtl-inc = 0
  .
  for each tt-dtl-income no-lock:
    tot-qty-inc = tot-qty-inc + tt-dtl-income.fact-sum.
    tot-sum-inc = tot-sum-inc + tt-dtl-income.sum-gds-rubl.
    tot-dtl-inc = tot-dtl-inc + tt-dtl-income.fact-sum * tt-dtl-income.par-val.
  end.
  disp tot-qty-inc
       tot-sum-inc
       tot-dtl-inc
  with frame {&FRAME-NAME}.
end.
if p-calc = '':U or p-calc = 'exp':U then do:
  assign tot-qty-exp = 0
         tot-sum-exp = 0
         tot-dtl-exp = 0
  .
  for each tt-dtl-expense no-lock:
    tot-qty-exp = tot-qty-exp + tt-dtl-expense.fact-sum.
    tot-sum-exp = tot-sum-exp + tt-dtl-expense.sum-gds-rubl.
    tot-dtl-exp = tot-dtl-exp + tt-dtl-expense.fact-sum * tt-dtl-expense.par-val.
  end.
  disp tot-qty-exp
       tot-sum-exp
       tot-dtl-exp
  with frame {&FRAME-NAME}.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  HIDE FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  DISPLAY tot-qty-inc tot-dtl-inc tot-sum-inc tot-qty-exp tot-dtl-exp
          tot-sum-exp
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help BR-inc BR-exp tot-qty-inc tot-dtl-inc tot-sum-inc
         tot-qty-exp tot-dtl-exp tot-sum-exp
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Fill-tables Dialog-Frame
PROCEDURE Fill-tables :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
/*две ветки*/
/* в форму вошли в первый раз для данной строки*/
empty temp-table tt-dtl-income.
empty temp-table tt-dtl-expense.
if not can-find(first tt-par-dtl) then do:
    FOR EACH ub.wth-par NO-LOCK WHERE
             ub.wth-par.wth-code = buf_wealth.wth-code :
      FIND FIRST tt-par-dtl WHERE
                 tt-par-dtl.par-code = ub.wth-par.par-code NO-ERROR.
      IF NOT AVAIL tt-par-dtl THEN DO:
        CREATE tt-par-dtl.
        ASSIGN
          tt-par-dtl.wth-code = ub.wth-par.wth-code
          tt-par-dtl.w-p-code = parw-p-code
          tt-par-dtl.doc-code = pardoc-code
          tt-par-dtl.par-code = ub.wth-par.par-code
          tt-par-dtl.par-val  = ub.wth-par.par-val
          tt-par-dtl.par-unit = ub.wth-par.par-unit
          tt-par-dtl.par-feat = ub.wth-par.par-feat
          tt-par-dtl.par-rate = ub.wth-par.par-rate
          tt-par-dtl.q-ty-doc = 0
          tt-par-dtl.doc-sum  = 0
          tt-par-dtl.q-ty-fact = 0
          tt-par-dtl.fact-sum  = 0
       .
      END.
    END.

    FOR EACH ub.wth-dtl NO-LOCK WHERE
            ub.wth-dtl.doc-code = pardoc-code AND
            ub.wth-dtl.wth-code = parwth-code AND
            ub.wth-dtl.w-p-code = parw-p-code
    BY
    ub.wth-dtl.par-code :
      FIND FIRST tt-par-dtl WHERE
                 tt-par-dtl.par-code = ub.wth-dtl.par-code NO-ERROR.
      IF NOT AVAIL tt-par-dtl THEN DO:
        NEXT.
      END.
      buffer-copy ub.wth-dtl using doc-sum fact-sum sum-gds-rubl sum-gds-base price-rubl price-base gds-code to tt-par-dtl.

     /*       ASSIGN                                                                                              */
/*       tt-par-dtl.q-ty-doc = tt-par-dtl.doc-sum * tt-par-dtl.par-rate       /* / (tt-par-dtl.par-val */    */
/*       tt-par-dtl.q-ty-fact = tt-par-dtl.fact-sum * tt-par-dtl.par-rate     /*  / (tt-par-dtl.par-val   */ */
/*       d_doc-sum    = d_doc-sum   + tt-par-dtl.doc-sum                                                     */
/*       d_fact-sum   = d_fact-sum   + tt-par-dtl.fact-sum                                                   */
/*       .                                                                                                   */
    END.
end.
for each tt-par-dtl no-lock:
    create tt-dtl-income.
    buffer-copy tt-par-dtl using wth-code
                                 w-p-code
                                 doc-code
                                 par-code
                                 par-val
                                 par-unit
                                 par-feat
                                 par-rate
             to tt-dtl-income.
  { str/dtlexsum.i tt-dtl-income buf_wth-parts {&income}}
    create tt-dtl-expense.
    buffer-copy tt-par-dtl using wth-code
                                 w-p-code
                                 doc-code
                                 par-code
                                 par-val
                                 par-unit
                                 par-feat
                                 par-rate
             to tt-dtl-expense.
  { str/dtlexsum.i tt-dtl-expense buf_wth-parts {&expense}}

  /*Может быть на целостность чего проверить.*/
  if tt-par-dtl.doc-sum <> tt-dtl-income.doc-sum - tt-dtl-expense.doc-sum then do:
  end.

/*      ASSIGN
      d_doc-sum   = d_doc-sum      + tt-par-dtl.doc-sum
      d_fact-sum   = d_fact-sum      + tt-par-dtl.fact-sum
      . */
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
 ASSIGN FRAME {&FRAME-NAME}:TITLE = 'Детализация по номиналам. МЦ ' + CAPS( buf_wealth.wth-name ).
  DISPLAY
/*   d_doc-sum @ for-d_doc-sum   */
/*   d_fact-sum @ for-d_fact-sum */
  WITH FRAME {&FRAME-NAME}.
/*   DISPLAY                         */
/*   pardoc-sum @ wth-line.doc-sum   */
/*   parfact-sum @ wth-line.fact-sum */
/*   WITH FRAME {&FRAME-NAME}.       */
  ENABLE
  b-quit
  b-help
  b-partsexp
  b-partsinc
  br-inc
  br-exp
  WITH FRAME {&FRAME-NAME}.
  IF par-mode <> {&lookup} THEN DO:
    ENABLE
    b-exit
    WITH FRAME {&FRAME-NAME}.
  END.
{&OPEN-QUERY-br-inc}
{&OPEN-QUERY-br-exp}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
 run calc-tot('':U).
 if tot-sum-inc <> tot-sum-exp then do:
    message 'Сумма по связанным товарам выданных и принятых МЦ не совпадают.' skip
            'Выдано  ' tot-sum-exp  skip
            'Принято ' tot-sum-inc
    view-as alert-box error.
    return error.
 end.
 if tot-dtl-inc <> tot-dtl-exp then do:
    message 'Количества по номиналам выданных и принятых МЦ не совпадают.' skip
            'Выдано  ' tot-dtl-exp  skip
            'Принято ' tot-dtl-inc
    view-as alert-box error.
    return error.
 end.
 for each tt-par-dtl:
  assign tt-par-dtl.doc-sum = 0
         tt-par-dtl.fact-sum = 0
         tt-par-dtl.sum-gds-base = 0
         tt-par-dtl.sum-gds-rubl = 0.
  for each tt-dtl-income where tt-par-dtl.wth-code = tt-dtl-income.wth-code
                          and  tt-par-dtl.par-code = tt-dtl-income.par-code:
    assign
         tt-par-dtl.doc-sum      = tt-par-dtl.doc-sum     +  tt-dtl-income.doc-sum
         tt-par-dtl.fact-sum     = tt-par-dtl.fact-sum    +  tt-dtl-income.fact-sum
         tt-par-dtl.sum-gds-base = tt-par-dtl.sum-gds-base + tt-dtl-income.sum-gds-base
         tt-par-dtl.sum-gds-rubl = tt-par-dtl.sum-gds-rubl + tt-dtl-income.sum-gds-rubl
     .
  end.
  for each tt-dtl-expense where tt-par-dtl.wth-code = tt-dtl-expense.wth-code
                           and  tt-par-dtl.par-code = tt-dtl-expense.par-code:
    assign
         tt-par-dtl.doc-sum      = tt-par-dtl.doc-sum     -  tt-dtl-expense.doc-sum
         tt-par-dtl.fact-sum     = tt-par-dtl.fact-sum    -  tt-dtl-expense.fact-sum
         tt-par-dtl.sum-gds-base = tt-par-dtl.sum-gds-base - tt-dtl-expense.sum-gds-base
         tt-par-dtl.sum-gds-rubl = tt-par-dtl.sum-gds-rubl - tt-dtl-expense.sum-gds-rubl
     .
  end.
  tt-par-dtl.q-ty-doc    = tt-par-dtl.doc-sum / tt-par-dtl.par-rate .
 end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
