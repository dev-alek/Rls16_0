&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_c-fin-doc FOR ub.c-fin-doc.
DEFINE BUFFER locked_fin-doc FOR ub.fin-doc.
DEFINE TEMP-TABLE tt-fin-doc-tax NO-UNDO LIKE ub.fin-doc-tax.
DEFINE TEMP-TABLE tt0-fin-doc-tax NO-UNDO LIKE ub.fin-doc-tax.
DEFINE BUFFER X_clients-host FOR ub.clients.
DEFINE BUFFER X_sysconf FOR ub.sysconf.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision: 520233f89800, 2104, rls $
$Author: SSlivenko $
$Date: Wed Dec 25 15:23:52 2019 +0300 $
$Workfile: fndocti.w $
$Archive: ref/fndocti.w $

Налоги для финансового документа также и для записи истории по фин доку

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/10/03
Author: Bakhtadze Natalya
Creation date: 11/10/03

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
/*текущая фирма*/
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo.

define input parameter p-mode as character no-undo.
/*может быть {&add-def} {&update} {&lookup} ({&lookup} + {&delim-par} + "history")*/

define input parameter p-host-code like ub.fin-doc.host-code no-undo.
define input parameter p-fin-doc-code like ub.fin-doc.fin-doc-code no-undo.
define input parameter p-fin-doc-type like ub.fin-doc.fin-doc-type no-undo.
define input parameter p-fin-ext-doc-type like ub.fin-doc.fin-ext-doc-type no-undo.
define input parameter p-cash-book-place as character no-undo .
define input parameter p-contract-code like ub.fin-doc.contract-code no-undo .
define input parameter p-sum-doc like ub.fin-doc.sum-doc no-undo .
define input parameter p-curr-code like ub.fin-doc.curr-code no-undo .
define input parameter p-base-rate like ub.fin-doc.base-rate no-undo .
define input parameter p-base-scale like ub.fin-doc.base-scale no-undo .
define input parameter p-exch-rate like ub.fin-doc.exch-rate no-undo .
define input parameter p-exch-scale like ub.fin-doc.exch-scale no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .


define INPUT-OUTPUT parameter table for tt0-fin-doc-tax.
define input parameter p-chip-num like ub.c-fin-doc.chip-num no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision: 520233f89800, 2104, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Wed Dec 25 15:23:52 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fndocti.w $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/fndocti.w $":U .
define variable vss-description as character no-undo init "Налоги для финансового документа".
{ cmp/vssrevis.i }

define variable v-db-num like ub.db.db-num no-undo.
define variable v-base-code like ub.sysconf.host-code no-undo.
define variable v-add-chg as character no-undo.
define variable v-fin-vat-pc like ub.sysconf.fin-vat-pc no-undo.
define variable v-fin-slt-pc like ub.sysconf.fin-slt-pc no-undo.
define variable v-rest-sum-doc like ub.fin-doc-tax.sum-line-doc no-undo.
define variable v-sum-tax like ub.fin-doc-tax.sum-line-doc no-undo.
define variable last-line like ub.fin-doc-tax.line-num no-undo.
define variable v-change-tab-order as character no-undo .
define variable v-updated-line-num like ub.fin-doc-tax.line-num no-undo .
define variable v-obj-db-num as integer no-undo init -1.
define buffer X_curr_sysconf for ub.sysconf.
define buffer X_currency for ub.currency.
define buffer X_contract for ub.contract.
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/waitfram.i }
{ cmp/showinf.i }
{ str/lib-farh.i }
define temp-table tt-fix no-undo
field line-num as integer
index pi is primary unique
line-num
.
&scop tab-order "b-add,b-chg,b-del," + v-change-tab-order + "b-quit,b-exit"
&scop change-tab-order "f-sum-doc,T-with-vat,T-vatpc,f-vat-pc,T-vatsum,f-sum-vat,T-with-slt,T-sltpc,f-slt-pc,T-sltsum,f-sum-slt,b-ok,b-not-ok,"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-fin-doc-tax

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-fin-doc-tax locked_fin-doc

/* Definitions for BROWSE BR-fin-doc-tax                                */
&Scoped-define FIELDS-IN-QUERY-BR-fin-doc-tax tt-fin-doc-tax.line-num ~
tt-fin-doc-tax.sum-line-doc tt-fin-doc-tax.with-vat tt-fin-doc-tax.vat-pc ~
tt-fin-doc-tax.sum-vat-line-doc tt-fin-doc-tax.with-slt ~
tt-fin-doc-tax.slt-pc tt-fin-doc-tax.sum-slt-line-doc
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-fin-doc-tax
&Scoped-define QUERY-STRING-BR-fin-doc-tax FOR EACH tt-fin-doc-tax NO-LOCK
&Scoped-define OPEN-QUERY-BR-fin-doc-tax OPEN QUERY BR-fin-doc-tax FOR EACH tt-fin-doc-tax NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-fin-doc-tax tt-fin-doc-tax
&Scoped-define FIRST-TABLE-IN-QUERY-BR-fin-doc-tax tt-fin-doc-tax


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH locked_fin-doc SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH locked_fin-doc SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame locked_fin-doc
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame locked_fin-doc


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-ok B-exit b-quit B-not-ok B-Help ~
F-curr-code BR-fin-doc-tax f-sum-doc f-vat-pc T-vatpc T-with-vat T-sltpc ~
f-slt-pc T-with-slt B-add B-chg B-del
&Scoped-Define DISPLAYED-OBJECTS f-all-sum-doc F-curr-code f-curr-abbr ~
f-sum-tax f-sum-doc f-sum-vat T-vatsum f-vat-pc T-vatpc T-with-vat T-sltsum ~
T-sltpc f-slt-pc f-sum-slt T-with-slt

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-not-ok
     LABEL "&Отмена"
     SIZE 10 BY 1.

DEFINE BUTTON B-ok
     LABEL "Ввод"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-all-sum-doc AS DECIMAL FORMAT ">,>>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма по документу"
     VIEW-AS FILL-IN
     SIZE 22 BY 1
     FGCOLOR 4 .

DEFINE VARIABLE f-curr-abbr AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE F-curr-code AS INTEGER FORMAT ">>9" INITIAL 0
     LABEL "Валюта"
     VIEW-AS FILL-IN
     SIZE 4 BY 1.

DEFINE VARIABLE f-slt-pc AS DECIMAL FORMAT ">9.99":U INITIAL 0
     LABEL "%НП"
     VIEW-AS FILL-IN
     SIZE 7.25 BY 1 NO-UNDO.

DEFINE VARIABLE f-sum-doc AS DECIMAL FORMAT ">,>>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма (в т.ч. налоги)"
     VIEW-AS FILL-IN
     SIZE 16 BY 1
     FGCOLOR 4 .

DEFINE VARIABLE f-sum-slt AS DECIMAL FORMAT ">,>>>,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "Сумма НП"
     VIEW-AS FILL-IN
     SIZE 22.88 BY 1.04
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-sum-tax AS DECIMAL FORMAT ">,>>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма налогов"
     VIEW-AS FILL-IN
     SIZE 22 BY 1
     FGCOLOR 4 .

DEFINE VARIABLE f-sum-vat AS DECIMAL FORMAT ">,>>>,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "Сумма НДС"
     VIEW-AS FILL-IN
     SIZE 22.88 BY 1.04
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-vat-pc AS DECIMAL FORMAT "->9.99":U INITIAL 0
     LABEL "%НДС"
     VIEW-AS FILL-IN
     SIZE 6.63 BY 1 NO-UNDO.

DEFINE VARIABLE T-sltpc AS LOGICAL INITIAL yes
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE T-sltsum AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE T-vatpc AS LOGICAL INITIAL yes
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE T-vatsum AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE T-with-slt AS LOGICAL INITIAL yes
     LABEL "С НП"
     VIEW-AS TOGGLE-BOX
     SIZE 10.38 BY 1 NO-UNDO.

DEFINE VARIABLE T-with-vat AS LOGICAL INITIAL yes
     LABEL "С НДС"
     VIEW-AS TOGGLE-BOX
     SIZE 10.38 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-fin-doc-tax FOR
      tt-fin-doc-tax SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      locked_fin-doc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-fin-doc-tax
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-fin-doc-tax Dialog-Frame _STRUCTURED
  QUERY BR-fin-doc-tax DISPLAY
      tt-fin-doc-tax.line-num COLUMN-LABEL "N строки!по налогу" FORMAT "99999":U
      tt-fin-doc-tax.sum-line-doc COLUMN-LABEL "Сумма (в т.ч. налоги)" FORMAT ">,>>>,>>>,>>>,>>9.99":U
      tt-fin-doc-tax.with-vat COLUMN-LABEL "С!НДС" FORMAT "да/нет":U
      tt-fin-doc-tax.vat-pc COLUMN-LABEL "%!НДС" FORMAT "->9.99":U
            WIDTH 7
      tt-fin-doc-tax.sum-vat-line-doc COLUMN-LABEL "Сумма НДС" FORMAT ">,>>>,>>>,>>>,>>9.99":U
      tt-fin-doc-tax.with-slt COLUMN-LABEL "С!НП" FORMAT "да/нет":U
      tt-fin-doc-tax.slt-pc COLUMN-LABEL "%!НП" FORMAT ">9.99":U
            WIDTH 7
      tt-fin-doc-tax.sum-slt-line-doc COLUMN-LABEL "Сумма НП" FORMAT ">,>>>,>>>,>>>,>>9.99":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 6.54.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-ok AT ROW 1 COL 1
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-not-ok AT ROW 1 COL 11
     B-Help AT ROW 1 COL 89
     f-all-sum-doc AT ROW 2.25 COL 20.5 COLON-ALIGNED
     F-curr-code AT ROW 2.25 COL 50.25 COLON-ALIGNED
     f-curr-abbr AT ROW 2.25 COL 55.25 COLON-ALIGNED NO-LABEL
     f-sum-tax AT ROW 2.25 COL 74.5 COLON-ALIGNED
     BR-fin-doc-tax AT ROW 3.46 COL 1
     f-sum-doc AT ROW 4.08 COL 23.25 COLON-ALIGNED
     f-sum-vat AT ROW 5.17 COL 74.25 COLON-ALIGNED
     T-vatsum AT ROW 5.21 COL 61.75
     f-vat-pc AT ROW 5.25 COL 45.63 COLON-ALIGNED
     T-vatpc AT ROW 5.33 COL 38.25
     T-with-vat AT ROW 5.38 COL 26
     T-sltsum AT ROW 6.54 COL 61.75
     T-sltpc AT ROW 6.67 COL 38.25
     f-slt-pc AT ROW 6.71 COL 45.5 COLON-ALIGNED
     f-sum-slt AT ROW 6.71 COL 74.25 COLON-ALIGNED
     T-with-slt AT ROW 6.79 COL 25.88
     B-add AT ROW 10.25 COL 1
     B-chg AT ROW 10.25 COL 11
     B-del AT ROW 10.25 COL 21
     SPACE(68.24) SKIP(0.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Налоги"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_c-fin-doc B "?" ? ub c-fin-doc
      TABLE: locked_fin-doc B "?" ? ub fin-doc
      TABLE: tt-fin-doc-tax T "?" NO-UNDO ub fin-doc-tax
      TABLE: tt0-fin-doc-tax T "?" NO-UNDO ub fin-doc-tax
      TABLE: X_clients-host B "?" ? ub clients
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BR-fin-doc-tax f-sum-tax Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN f-all-sum-doc IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-curr-abbr IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-sum-slt IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-sum-tax IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-sum-vat IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX T-sltsum IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX T-vatsum IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-fin-doc-tax
/* Query rebuild information for BROWSE BR-fin-doc-tax
     _TblList          = "Temp-Tables.tt-fin-doc-tax"
     _FldNameList[1]   > Temp-Tables.tt-fin-doc-tax.line-num
"tt-fin-doc-tax.line-num" "N строки!по налогу" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[2]   > Temp-Tables.tt-fin-doc-tax.sum-line-doc
"tt-fin-doc-tax.sum-line-doc" "Сумма (в т.ч. налоги)" ? "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[3]   > Temp-Tables.tt-fin-doc-tax.with-vat
"tt-fin-doc-tax.with-vat" "С!НДС" "да/нет" "logical" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[4]   > Temp-Tables.tt-fin-doc-tax.vat-pc
"tt-fin-doc-tax.vat-pc" "%!НДС" ">9.99" "decimal" ? ? ? ? ? ? no ? no no "7" yes no no "U" "" ""
     _FldNameList[5]   > Temp-Tables.tt-fin-doc-tax.sum-vat-line-doc
"tt-fin-doc-tax.sum-vat-line-doc" "Сумма НДС" ? "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[6]   > Temp-Tables.tt-fin-doc-tax.with-slt
"tt-fin-doc-tax.with-slt" "С!НП" "да/нет" "logical" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[7]   > Temp-Tables.tt-fin-doc-tax.slt-pc
"tt-fin-doc-tax.slt-pc" "%!НП" ">9.99" "decimal" ? ? ? ? ? ? no ? no no "7" yes no no "U" "" ""
     _FldNameList[8]   > Temp-Tables.tt-fin-doc-tax.sum-slt-line-doc
"tt-fin-doc-tax.sum-slt-line-doc" "Сумма НП" ? "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _Query            is NOT OPENED
*/  /* BROWSE BR-fin-doc-tax */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.locked_fin-doc"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Налоги */
DO:
  run check-sums in this-procedure no-error.
  if error-status:error then return no-apply.
  run proc-save in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Налоги */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
{ gbl/stdbtn.i }
assign
v-add-chg = {&add-def}.
run proc-b-add-chg in this-procedure (input {&add-def}) no-error.

if error-status:error then do:
    assign
    v-add-chg = "":U.
    return no-apply.
end.
run openbr in this-procedure.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
{ gbl/stdbtn.i }
if not available tt-fin-doc-tax then return no-apply.
assign
v-add-chg = {&update}.
run proc-b-add-chg in this-procedure (input {&update}) no-error.
if error-status:error then do:
    assign
    v-add-chg = "":U.
    return no-apply.
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
{ gbl/stdbtn.i }

define variable v-line-num like ub.fin-doc-tax.line-num no-undo.

DEFINE BUFFER buf_tt-fin-doc-tax for tt-fin-doc-tax.
    IF AVAIL tt-fin-doc-tax then do:
    do
on error undo, return no-apply
:
        FIND FIRST buf_tt-fin-doc-tax WHERE
                         recid(buf_tt-fin-doc-tax) = RECID(tt-fin-doc-tax) NO-ERROR.
        if avail buf_tt-fin-doc-tax then do:
            assign
            v-line-num = buf_tt-fin-doc-tax.line-num
            .
            delete buf_tt-fin-doc-tax.
            find first tt-fix where
            tt-fix.line-num = v-line-num no-error.
            if available tt-fix then delete tt-fix.
        end.
        for each buf_tt-fin-doc-tax where
                    buf_tt-fin-doc-tax.host-code = p-host-code
               AND buf_tt-fin-doc-tax.fin-doc-code = p-fin-doc-code
               AND buf_tt-fin-doc-tax.line-num > v-line-num
               by buf_tt-fin-doc-tax.line-num:
            assign
            buf_tt-fin-doc-tax.line-num = buf_tt-fin-doc-tax.line-num - 1
            .
        end.
         for each tt-fix where
          tt-fix.line-num > v-line-num
               by tt-fix.line-num:
            assign
            tt-fix.line-num = tt-fix.line-num - 1
            .
        end.

end. /*doe*/
      run openbr in this-procedure.
      RUN get-rest-sum in this-procedure(output v-rest-sum-doc, output v-sum-tax).
      display
      v-sum-tax @ f-sum-tax
      with frame {&frame-name}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  { gbl/stdbtn.i }

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-not-ok
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-not-ok Dialog-Frame
ON CHOOSE OF B-not-ok IN FRAME Dialog-Frame /* Отмена */
DO:
run proc-b-not-ok in this-procedure no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-ok
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-ok Dialog-Frame
ON CHOOSE OF B-ok IN FRAME Dialog-Frame /* Ввод */
DO:
run proc-b-ok in this-procedure(input v-updated-line-num) no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отказ */
DO:
  for each tt-fix:
  delete tt-fix.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-slt-pc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-slt-pc Dialog-Frame
ON LEAVE OF f-slt-pc IN FRAME Dialog-Frame /* %НП */
DO:
  { gbl/stdbtn.i }
  assign
  f-slt-pc.
  run recalc-sums in this-procedure("slt-pc":U) no-error .
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-sum-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-sum-doc Dialog-Frame
ON LEAVE OF f-sum-doc IN FRAME Dialog-Frame /* Сумма (в т.ч. налоги) */
DO:
{ gbl/stdbtn.i }
  assign
  f-sum-doc.
  run recalc-sums in this-procedure("sum-doc":U) no-error .
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-sum-slt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-sum-slt Dialog-Frame
ON LEAVE OF f-sum-slt IN FRAME Dialog-Frame /* Сумма НП */
DO:
{ gbl/stdbtn.i }
  assign
  f-sum-slt.
  run recalc-sums in this-procedure("sum-slt":U) no-error .
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-sum-vat
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-sum-vat Dialog-Frame
ON LEAVE OF f-sum-vat IN FRAME Dialog-Frame /* Сумма НДС */
DO:
{ gbl/stdbtn.i }
  assign
  f-sum-vat.
  run recalc-sums in this-procedure("sum-vat":U) no-error .
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-vat-pc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-vat-pc Dialog-Frame
ON LEAVE OF f-vat-pc IN FRAME Dialog-Frame /* %НДС */
DO:
{ gbl/stdbtn.i }
    assign
  f-vat-pc.
  run recalc-sums in this-procedure("vat-pc":U) no-error .
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-sltpc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-sltpc Dialog-Frame
ON VALUE-CHANGED OF T-sltpc IN FRAME Dialog-Frame
DO:
    { gbl/stdbtn.i }
  assign
  t-sltpc.
  run disable-enable in this-procedure("slt-pc":U).


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-sltsum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-sltsum Dialog-Frame
ON VALUE-CHANGED OF T-sltsum IN FRAME Dialog-Frame
DO:
    { gbl/stdbtn.i }
  assign
  t-sltsum.
  run disable-enable in this-procedure("slt-sum":U).


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-vatpc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-vatpc Dialog-Frame
ON VALUE-CHANGED OF T-vatpc IN FRAME Dialog-Frame
DO:
  { gbl/stdbtn.i }
  assign
  t-vatpc.
  run disable-enable in this-procedure("vat-pc":U).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-vatsum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-vatsum Dialog-Frame
ON VALUE-CHANGED OF T-vatsum IN FRAME Dialog-Frame
DO:
    { gbl/stdbtn.i }
  assign
  t-vatsum.
  run disable-enable in this-procedure("vat-sum":U).


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-with-slt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-with-slt Dialog-Frame
ON VALUE-CHANGED OF T-with-slt IN FRAME Dialog-Frame /* С НП */
DO:
  assign
  t-with-slt.
  run with-without in this-procedure ("slt":U, t-with-slt, yes).
  run with-without in this-procedure ("VAT":U, t-with-vat, no).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-with-vat
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-with-vat Dialog-Frame
ON VALUE-CHANGED OF T-with-vat IN FRAME Dialog-Frame /* С НДС */
DO:
  assign
  t-with-vat.
  run with-without in this-procedure ("vat":U, t-with-vat, yes).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-fin-doc-tax
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
{ gbl/app_help.i }
{ ref/tabhndmv.i ~{&tab-order~} "underline-tb" }
{ gbl/brwrepos.i
&line-num=5
}

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if p-mode <> {&update}
  and p-mode <> {&lookup}
  and p-mode <> {&add-def}
  and p-mode <> ({&lookup} + {&delim-par} + "history":U)
  then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"  p-mode
    view-as alert-box ERROR.
    undo, return error.
  end.
  { gbl/curdbnum.i v-db-num }
  { gbl/basecode.i p-host-code v-base-code }
    find first X_curr_sysconf no-lock where
                    X_curr_sysconf.host-code = p-curr-host-code.
    find first X_sysconf no-lock where
                  X_sysconf.host-code = p-host-code.
   assign
   v-fin-vat-pc = X_sysconf.fin-vat-pc
    v-fin-slt-pc = X_sysconf.fin-slt-pc
    .

    find first X_clients-host no-lock where
              X_clients-host.obj-type = {&cmp}
          AND X_clients-host.obj-code = p-host-code.
  if p-mode = {&update}
  or p-mode = {&lookup} then do:
    if p-mode = {&update} then do:
      find first locked_fin-doc EXclusive-lock where
                 locked_fin-doc.host-code  = p-host-code
             AND locked_fin-doc.fin-doc-code  = p-fin-doc-code
                   no-wait no-error.
      if locked locked_fin-doc then do:
        message
        vss-workfile vss-revision vss-description skip
        "Запись Платежа занята"
        "фирма" p-host-code
        "внутр. № документа" p-fin-doc-code
        view-as alert-box error .
        undo, return error.
      end.
    end.
    else do:
      find first locked_fin-doc no-lock where
                 locked_fin-doc.host-code  = p-host-code
             AND locked_fin-doc.fin-doc-code  = p-fin-doc-code no-error .
    end.
    if not available locked_fin-doc
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись ПЛАТЕЖА"
      view-as alert-box error .
      undo, return error.
    end.
  end.
/*  if LOOKUP({&lookup} , p-mode, {&delim-par}) = 0  then do:*/
/*    define variable v-ok as logical no-undo .              */
/*    define variable v-mess as character no-undo .          */
/*    { str/finchkdb.i                                       */
/*      p-host-code                                          */
/*      p-fin-doc-code                                       */
/*      p-obj-type                                           */
/*      p-obj-code                                           */
/*      p-fin-ext-doc-type                                   */
/*      p-cash-book-place                                    */
/*      ?                                                    */
/*      v-ok                                                 */
/*      v-mess                                               */
/*    no-error }                                             */
/*    if not v-ok then do:                                   */
/*      message v-mess                                       */
/*      view-as alert-box error .                            */
/*      undo main-block, return error .                      */
/*    end.                                                   */
/*  end.                                                     */

  if p-mode = ({&lookup} + {&delim-par} + "history":U)
  then do:
    find first locked_c-fin-doc no-lock where
                locked_c-fin-doc.host-code  = p-host-code
            AND locked_c-fin-doc.fin-doc-code  = p-fin-doc-code no-error .
    if not available locked_c-fin-doc
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись истории ПЛАТЕЖА"
      view-as alert-box error .
      undo, return error.
    end.
  end.
  find first X_currency no-lock where
               X_currency.curr-code = p-curr-code.
  run fill-tables in this-procedure.
  RUN Myenable.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-sums Dialog-Frame
PROCEDURE check-sums :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable acc as decimal no-undo.
define buffer buf_tt-fin-doc-tax for tt-fin-doc-tax.
for each buf_tt-fin-doc-tax:
    assign
    acc = acc + buf_tt-fin-doc-tax.sum-line-doc
    .
end.
if acc <> p-sum-doc then do:
message
substitute("Общая сумма платежа &1, а сумма всех компонент, по которым исчислялся налог - &2", p-sum-doc, acc)
view-as alert-box ERROR.
return error.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable-enable Dialog-Frame
PROCEDURE disable-enable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-main-widget as character no-undo.
/*сначала все позадизайблим*/
CASE p-main-widget:
  when "vat-sum" then do:
    assign
        T-vatpc = no.
        enable
                t-vatpc
                f-sum-vat
                with frame {&frame-name}.
        disable
        t-vatsum
        f-vat-pc
        with frame {&frame-name}.
  end.
    when "slt-sum" then do:
      assign
        T-sltpc = no.
        enable
                t-sltpc
                f-sum-slt
                with frame {&frame-name}.

        disable
        t-sltsum
        f-slt-pc
        with frame {&frame-name}.

  end.
  when "vat-pc" then do:
    assign
        T-vatsum = no.
            enable
                t-vatsum
                f-vat-pc
                with frame {&frame-name}.
        disable
        t-vatpc
        f-sum-vat
        with frame {&frame-name}.
  end.
  when "slt-pc" then do:
      assign
        T-sltsum = no.
                enable
                t-sltsum
                f-slt-pc
                with frame {&frame-name}.

        disable
        t-sltpc
        f-sum-slt
        with frame {&frame-name}.
  end.

END CASE.
display
T-sltpc
T-sltsum
T-vatpc
T-vatsum
with frame {&frame-name}.
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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY f-all-sum-doc F-curr-code f-curr-abbr f-sum-tax f-sum-doc f-sum-vat
          T-vatsum f-vat-pc T-vatpc T-with-vat T-sltsum T-sltpc f-slt-pc
          f-sum-slt T-with-slt
      WITH FRAME Dialog-Frame.
  ENABLE B-ok B-exit b-quit B-not-ok B-Help F-curr-code BR-fin-doc-tax
         f-sum-doc f-vat-pc T-vatpc T-with-vat T-sltpc f-slt-pc T-with-slt
         B-add B-chg B-del
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tables Dialog-Frame
PROCEDURE fill-tables :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_fin-doc-tax for ub.fin-doc-tax.
define buffer buf_c-fin-doc-tax for ub.c-fin-doc-tax.
define buffer buf_tt-fin-doc-tax for tt-fin-doc-tax.
do on error undo, return error:
  if p-mode = {&lookup} + {&delim-par} + "History":U then do:
    for each buf_c-fin-doc-tax no-lock where
                buf_c-fin-doc-tax.host-code = p-host-code
          AND buf_c-fin-doc-tax.fin-doc-code = p-fin-doc-code
          AND buf_c-fin-doc-tax.chip-num = p-chip-num
          :
      create buf_tt-fin-doc-tax.
      buffer-copy buf_c-fin-doc-tax to buf_tt-fin-doc-tax.
    END.
  end.
  else do:
    find first tt0-fin-doc-tax no-lock no-error.
    if available tt0-fin-doc-tax then do:
      for each tt0-fin-doc-tax no-lock where
                  tt0-fin-doc-tax.host-code = p-host-code
            AND tt0-fin-doc-tax.fin-doc-code = p-fin-doc-code:
        create buf_tt-fin-doc-tax.
        buffer-copy tt0-fin-doc-tax to buf_tt-fin-doc-tax.
      END.
    end.
    else do:
      for each buf_fin-doc-tax no-lock where
                  buf_fin-doc-tax.host-code = p-host-code
            AND buf_fin-doc-tax.fin-doc-code = p-fin-doc-code:
        create buf_tt-fin-doc-tax.
        buffer-copy buf_fin-doc-tax to buf_tt-fin-doc-tax.
      END.
    end.
  end.
  RUN get-rest-sum in this-procedure(output v-rest-sum-doc, output v-sum-tax).
end.
if p-contract-code <> 0 then do:
  find first X_contract no-lock where
  x_contract.host-code = p-host-code
  AND x_contract.contract-code = p-contract-code.
        assign
  v-fin-vat-pc = X_contract.fin-vat-pc
  v-fin-slt-pc = X_contract.fin-slt-pc
  .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-rest-sum Dialog-Frame
PROCEDURE get-rest-sum :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-rest-sum like ub.fin-doc-tax.sum-line-doc no-undo.
define output parameter p-sum-tax  like ub.fin-doc-tax.sum-line-doc no-undo .
define buffer buf_tt-fin-doc-tax for tt-fin-doc-tax.
for each buf_tt-fin-doc-tax no-lock:
    assign
    p-rest-sum = p-rest-sum + buf_tt-fin-doc-tax.sum-line-doc
    p-sum-tax = p-sum-tax +  buf_tt-fin-doc-tax.sum-vat-line-doc + buf_tt-fin-doc-tax.sum-slt-line-doc
    .
end.
assign
p-rest-sum = p-sum-doc - p-rest-sum
.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Myenable Dialog-Frame
PROCEDURE Myenable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign
frame {&frame-name}:title = frame {&frame-name}:title + {&space-char} + x_clients-host.obj-name
b-quit:label = (if lookup({&lookup}, p-mode, {&delim-par}) > 0 then "&Выход" else b-quit:label)

t-with-slt = yes
t-with-vat = yes
t-sltpc = yes
t-vatpc = yes
t-sltsum = no
t-vatsum = no
.
DISPLAY
p-sum-doc @ f-all-sum-doc
p-curr-code @ f-curr-code
v-sum-tax @ f-sum-tax
X_currency.curr-abbr @ f-curr-abbr
WITH FRAME Dialog-Frame.
ENABLE
b-quit
B-exit when lookup({&lookup}, p-mode, {&delim-par}) = 0
B-add  when lookup({&lookup}, p-mode, {&delim-par}) = 0
B-chg  when lookup({&lookup}, p-mode, {&delim-par}) = 0
B-del  when lookup({&lookup}, p-mode, {&delim-par}) = 0
B-Help
BR-fin-doc-tax
WITH FRAME Dialog-Frame.
if lookup({&lookup}, p-mode, {&delim-par}) > 0 then do:
  hide
  b-exit
  in frame {&frame-name} .
  b-quit:column = 1.
end.
hide
f-slt-pc
f-sum-doc
f-sum-vat
f-sum-slt
f-vat-pc
T-sltpc
T-sltsum
T-vatpc
T-vatsum
T-with-slt
T-with-vat
b-ok
b-not-ok
in frame {&frame-name}.
VIEW FRAME Dialog-Frame.
run openbr in this-procedure .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
Open query br-fin-doc-tax
for each tt-fin-doc-tax no-lock where
            tt-fin-doc-tax.fin-doc-code = p-fin-doc-code
        AND tt-fin-doc-tax.host-code = p-host-code.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add-chg Dialog-Frame
PROCEDURE proc-b-add-chg :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-mode as character no-undo.
if p-mode = {&update} then do:
    assign
    f-slt-pc     = tt-fin-doc-tax.slt-pc
    f-sum-doc    = tt-fin-doc-tax.sum-line-doc
    f-sum-vat    = tt-fin-doc-tax.sum-vat-line-doc
    f-sum-slt    =  tt-fin-doc-tax.sum-slt-line-doc
    f-vat-pc     =  tt-fin-doc-tax.vat-pc
    T-with-slt   =  tt-fin-doc-tax.with-slt
    T-with-vat   =  tt-fin-doc-tax.with-vat
    v-updated-line-num = tt-fin-doc-tax.line-num
    .
end.

if p-mode = {&add-def} then do:
    assign
    f-slt-pc     = v-fin-slt-pc * (If T-with-slt then 1 else 0)
    f-sum-doc    = (if v-rest-sum-doc > 0 then v-rest-sum-doc else 0)
    f-sum-tax    = v-sum-tax
    f-vat-pc     = v-fin-vat-pc * (If T-with-vat then 1 else 0)
    T-with-slt   = yes
    T-with-vat    = yes
    f-sum-slt    = f-sum-doc * f-slt-pc / ( 100  + f-slt-pc )
    f-sum-vat    = (f-sum-doc - f-sum-slt ) * f-vat-pc / (100 + f-vat-pc )
    .
end.
assign
t-sltpc = yes
t-vatpc = yes
t-sltsum = no
t-vatsum = no
.
display
f-slt-pc
f-sum-doc
f-sum-vat
f-sum-slt
f-vat-pc
T-sltpc
T-sltsum
T-vatpc
T-vatsum
T-with-slt
T-with-vat
b-ok
b-not-ok
with frame {&frame-name}.
disable
b-exit
b-add
b-chg
b-del
t-sltpc
t-vatpc
f-sum-vat
f-sum-slt
with frame {&frame-name}.
hide
b-exit
b-add
b-chg
b-del
/*t-sltpc
t-vatpc
f-sum-vat
f-sum-slt*/
BR-fin-doc-tax
IN frame {&frame-name}.

enable
f-sum-doc
f-vat-pc when t-with-vat
f-slt-pc when t-with-slt
T-vatsum  when t-with-vat
T-sltsum when t-with-slt
T-with-slt
T-with-vat
b-ok
b-not-ok
with frame {&frame-name}.
assign
v-change-tab-order = {&change-tab-order}.
APPLY "ENTRY" to f-sum-doc.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-not-ok Dialog-Frame
PROCEDURE proc-b-not-ok :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign
v-add-chg = "":U
v-change-tab-order = "":U
.

if p-mode = {&add-def} then do:
    assign
    f-slt-pc         = 0
    f-sum-doc    =   0
    f-sum-vat     =  0
    f-sum-slt      = 0
    f-vat-pc        = 0
    T-with-slt      =  yes
    T-with-vat    =      Yes
    .
end.
hide
f-slt-pc in frame {&frame-name}
f-sum-doc
f-sum-vat
f-sum-slt
f-vat-pc
T-sltpc
T-sltsum
T-vatpc
T-vatsum
T-with-slt
T-with-vat
b-ok
b-not-ok
in frame {&frame-name}.
DISPLAY BR-fin-doc-tax WITH FRAME {&FRAME-NAME} .
enable
b-exit
b-add
b-chg
b-del
with frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-ok Dialog-Frame
PROCEDURE proc-b-ok :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-line-num like tt-fin-doc-tax.line-num no-undo .
define buffer buf_tt-fin-doc-tax for tt-fin-doc-tax.
assign
frame {&frame-name}
f-slt-pc
f-sum-doc
f-sum-vat
f-sum-slt
f-vat-pc
T-with-slt
T-with-vat
.
if f-sum-vat + f-sum-slt >= f-sum-doc
then do:
  message
  "Сумма налогов больше налогооблагаемой суммы!"
  view-as alert-box error .
  return error.
end.

CASE v-add-chg:
  when {&add-def} then do:
    find last buf_tt-fin-doc-tax no-lock where
    buf_tt-fin-doc-tax.host-code = p-host-code
    AND buf_tt-fin-doc-tax.fin-doc-code = p-fin-doc-code
    use-index pi
    no-error.
    if available buf_tt-fin-doc-tax then
    assign
    last-line = buf_tt-fin-doc-tax.line-num
    .
    create
    buf_tt-fin-doc-tax.
    assign
    buf_tt-fin-doc-tax.host-code = p-host-code
    buf_tt-fin-doc-tax.fin-doc-code = p-fin-doc-code
    buf_tt-fin-doc-tax.line-num = last-line + 1
    buf_tt-fin-doc-tax.sum-line-doc  = f-sum-doc
    buf_tt-fin-doc-tax.sum-slt-line-doc = f-sum-slt
    buf_tt-fin-doc-tax.sum-vat-line-doc  = f-sum-vat
    buf_tt-fin-doc-tax.vat-pc  = f-vat-pc
    buf_tt-fin-doc-tax.with-slt = t-with-slt
    buf_tt-fin-doc-tax.with-vat = t-with-vat
    buf_tt-fin-doc-tax.slt-pc = f-slt-pc
    .
  end.
  when {&update} then do:
    find first buf_tt-fin-doc-tax where
                buf_tt-fin-doc-tax.line-num = p-line-num.
    assign
    buf_tt-fin-doc-tax.sum-line-doc  = f-sum-doc
    buf_tt-fin-doc-tax.sum-slt-line-doc = f-sum-slt
    buf_tt-fin-doc-tax.sum-vat-line-doc  = f-sum-vat
    buf_tt-fin-doc-tax.vat-pc  = f-vat-pc
    buf_tt-fin-doc-tax.with-slt = t-with-slt
    buf_tt-fin-doc-tax.with-vat = t-with-vat
    buf_tt-fin-doc-tax.slt-pc = f-slt-pc
    .
  end.
END CASE.
assign
v-add-chg = "":U
v-change-tab-order = "":U
.
RUN get-rest-sum in this-procedure(output v-rest-sum-doc, output v-sum-tax).
hide
f-slt-pc
f-sum-doc
f-sum-vat
f-sum-slt
f-vat-pc
T-sltpc
T-sltsum
T-vatpc
T-vatsum
T-with-slt
T-with-vat
b-ok
b-not-ok
in frame {&frame-name}.
DISPLAY BR-fin-doc-tax WITH FRAME {&FRAME-NAME} .
run openbr in this-procedure.
find first buf_tt-fin-doc-tax no-lock where
           buf_tt-fin-doc-tax.line-num = (if v-add-chg = {&add-def}
                                          then (last-line + 1)
                                          else v-updated-line-num) no-error .
if available buf_tt-fin-doc-tax then do:
  reposition BR-fin-doc-tax to recid recid(buf_tt-fin-doc-tax) no-error .
end.
enable
b-exit
b-add
b-chg
b-del
with frame {&frame-name}.
display
v-sum-tax @ f-sum-tax
with frame {&frame-name}.
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
do on error undo, return error:
  for each tt0-fin-doc-tax where
          tt0-fin-doc-tax.host-code = p-host-code
       AND tt0-fin-doc-tax.fin-doc-code = p-fin-doc-code:
    find first tt-fin-doc-tax no-lock where
               tt-fin-doc-tax.host-code = p-host-code
           AND tt-fin-doc-tax.fin-doc-code = p-fin-doc-code
           AND tt-fin-doc-tax.line-num = tt0-fin-doc-tax.line-num no-error .
    if not available tt-fin-doc-tax then do:
      delete tt0-fin-doc-tax.
    end.
  end.
 for each tt-fin-doc-tax :
    find first tt0-fin-doc-tax where
               tt0-fin-doc-tax.host-code = p-host-code
           AND tt0-fin-doc-tax.fin-doc-code = p-fin-doc-code
           AND tt0-fin-doc-tax.line-num   = tt-fin-doc-tax.line-num
           no-error .
    if not available tt0-fin-doc-tax then do:
      create tt0-fin-doc-tax.
      assign
      tt0-fin-doc-tax.host-code = p-host-code
      tt0-fin-doc-tax.fin-doc-code = p-fin-doc-code
      tt0-fin-doc-tax.line-num = tt-fin-doc-tax.line-num
      .
    end.
    buffer-copy tt-fin-doc-tax except host-code fin-doc-code line-num
    to tt0-fin-doc-tax.
  end.
end.
  for each tt0-fin-doc-tax where
          tt0-fin-doc-tax.host-code = p-host-code
       AND tt0-fin-doc-tax.fin-doc-code = p-fin-doc-code:
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE recalc-sums Dialog-Frame
PROCEDURE recalc-sums :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-main-widget as character no-undo.
define variable v-line-num like ub.fin-doc-tax.line-num no-undo.
define buffer buf_tt-fin-doc-tax for tt-fin-doc-tax.
case v-add-chg:
  when {&update} then do:
    assign
    v-line-num = tt-fin-doc-tax.line-num
    .
  end.
  when {&add-def} then do:
    assign
    v-line-num = last-line
    .
  end.
 END CASE.
 if f-vat-pc <> -1 then do:
CASE p-main-widget :
    when "sum-doc":U then do:
      assign
      f-sum-slt = f-sum-doc * f-slt-pc / ( 100  + f-slt-pc )
      f-sum-vat =  (f-sum-doc - f-sum-slt ) * f-vat-pc / (100 + f-vat-pc )
      .
    end.
    when "slt-pc":U then do:
      assign
      f-sum-slt = f-sum-doc * f-slt-pc / ( 100  + f-slt-pc )
      f-sum-vat = (f-sum-doc - f-sum-slt ) * f-vat-pc / (100 + f-vat-pc )
      .
    end.
    when "vat-pc":U then do:
      assign
      f-sum-vat = (f-sum-doc - f-sum-slt ) * f-vat-pc / (100 + f-vat-pc )
      .
    end.
    when "sum-slt":U then do:
      assign
      f-slt-pc = f-sum-slt / (f-sum-doc - f-sum-slt ) * 100
      f-sum-vat =  (f-sum-doc - f-sum-slt ) * f-vat-pc / (100 + f-vat-pc )
      .
    end.
    when "sum-vat":U then do:
      assign
      f-vat-pc = f-sum-vat / (f-sum-doc - f-sum-slt - f-sum-vat ) * 100
      .
    end.
END CASE.
end.
if
not (f-sum-vat = 0
and f-sum-slt = 0
and f-sum-doc = 0)
and
f-sum-vat + f-sum-slt >= f-sum-doc  then do:
  message
  "Сумма налогов больше налогооблагаемой суммы + налоги!"
  view-as alert-box error .
  return error.
end.
display
f-slt-pc
f-sum-doc
f-sum-vat
f-sum-slt
f-vat-pc
with frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE with-without Dialog-Frame
PROCEDURE with-without :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-widget as character no-undo.
define input parameter p-on as logical no-undo.
define input parameter p-rewrite-tax as logical no-undo .
CASE p-widget:
  when "slt":U then do:
    CASE p-on:
      when yes then do:
        assign
        f-slt-pc     = v-fin-slt-pc
        T-with-slt   = yes
        f-sum-slt    = f-sum-doc * f-slt-pc / ( 100  + f-slt-pc )
        f-sum-vat    = (f-sum-doc - f-sum-slt ) * f-vat-pc / (100 + f-vat-pc )
        .
        display
        f-slt-pc
        f-sum-slt
        t-with-slt
        with frame {&frame-name}.
        enable
        f-slt-pc
        T-sltsum
        with frame {&frame-name}.
        disable
        f-sum-slt
        t-sltpc
        with frame {&frame-name}.
      end.
      when no then do:
        assign
        f-slt-pc = 0
        .
        display
        f-slt-pc
        with frame {&frame-name}.
        apply "LEAVE" to f-slt-pc.
        disable
        f-slt-pc
        f-sum-slt
        T-sltpc
        T-sltsum
        with frame {&frame-name}.
      end.
    END CASE.
  end.
  when "vat":U then do:
    CASE p-on:
      when yes then do:
        if p-rewrite-tax then do:
          if f-vat-pc <> -1 then
        assign
        f-vat-pc     = v-fin-vat-pc
        .
        end.
        if f-vat-pc <> -1 then do:
        assign
        T-with-vat   = yes
        f-sum-vat    = (f-sum-doc - f-sum-slt ) * f-vat-pc / (100 + f-vat-pc )
        .
        end.
        display
        f-vat-pc
        f-sum-vat
        t-with-vat
        with frame {&frame-name}.
        enable
        f-vat-pc
        T-vatsum
        with frame {&frame-name}.
        disable
        f-sum-vat
        t-vatpc
        with frame {&frame-name}.
      end.
      when no then do:
        assign
        f-vat-pc = 0
        .
        display
        f-vat-pc
        with frame {&frame-name}.
        apply "LEAVE" to f-vat-pc.
        disable
        f-vat-pc
        f-sum-vat
        T-vatpc
        T-vatsum
        with frame {&frame-name}.
      end.
    END CASE.
  end.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME