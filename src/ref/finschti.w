&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_fin-schet FOR ub.fin-schet.
DEFINE TEMP-TABLE tt-fin-schet NO-UNDO LIKE ub.fin-schet.
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_clients-host FOR ub.clients.
DEFINE BUFFER X_currency FOR ub.currency.
DEFINE BUFFER X_fin-bank FOR ub.fin-bank.
DEFINE BUFFER X_schet-clients FOR ub.clients.
DEFINE BUFFER X_sysconf FOR ub.sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка редактирования банковского счета

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/24/03
Author: Bakhtadze Natalya
Creation date: 10/24/03

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
/*текущая фирма*/
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo.


define input parameter p-mode as character no-undo.
/*может быть {&add-def} {&update} {&lookup}*/

define input parameter p-host-code like ub.fin-schet.host-code no-undo.
define input parameter p-code-schet like ub.fin-schet.code-schet no-undo.
define input parameter p-code-bank like ub.fin-schet.code-bank no-undo .
define input parameter p-cli-type like ub.fin-schet.cli-type no-undo .
define input parameter p-cli-code like ub.fin-schet.cli-code no-undo .
define input parameter p-curr-code like ub.fin-schet.curr-code no-undo .


define input-output parameter p-doc-rec as recid no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка редактирования банковского счета".
{ cmp/vssrevis.i }

define variable v-db-num like ub.db.db-num no-undo.
define variable v-tab-order as character no-undo.
define buffer X_curr_sysconf for ub.sysconf.
{ cmp/trg-def.i }
{ cmp/showinf.i }
{ gbl/waitfram.i }

&scop tab-order   "B-exit,b-quit,b-print,b-hist,b-help,cli-type,cli-code,b-cli," +  ~
                  "code-bank,B-bank,r-schet,curr-code,B-currency,PS" ~

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-fin-schet X_schet-clients

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-fin-schet.host-code ~
tt-fin-schet.code-schet tt-fin-schet.cli-code tt-fin-schet.cli-type ~
tt-fin-schet.code-bank tt-fin-schet.c-schet tt-fin-schet.curr-code ~
tt-fin-schet.r-schet tt-fin-schet.dop1 tt-fin-schet.dop2 tt-fin-schet.PS 
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-fin-schet.cli-code ~
tt-fin-schet.cli-type tt-fin-schet.code-bank tt-fin-schet.curr-code ~
tt-fin-schet.r-schet tt-fin-schet.dop1 tt-fin-schet.dop2 tt-fin-schet.PS 
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-fin-schet
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-fin-schet
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-fin-schet SHARE-LOCK, ~
      EACH X_schet-clients WHERE TRUE /* Join to tt-fin-schet incomplete */ SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-fin-schet SHARE-LOCK, ~
      EACH X_schet-clients WHERE TRUE /* Join to tt-fin-schet incomplete */ SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-fin-schet X_schet-clients
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-fin-schet
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame X_schet-clients


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-fin-schet.cli-code tt-fin-schet.cli-type ~
tt-fin-schet.code-bank tt-fin-schet.curr-code tt-fin-schet.r-schet ~
tt-fin-schet.dop1 tt-fin-schet.dop2 tt-fin-schet.PS 
&Scoped-define ENABLED-TABLES tt-fin-schet
&Scoped-define FIRST-ENABLED-TABLE tt-fin-schet
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-print B-hist B-Help ~
f-cli-name B-cli B-bank B-currency f-curr-abbr 
&Scoped-Define DISPLAYED-FIELDS tt-fin-schet.host-code ~
tt-fin-schet.code-schet tt-fin-schet.cli-code tt-fin-schet.cli-type ~
tt-fin-schet.code-bank tt-fin-schet.c-schet tt-fin-schet.curr-code ~
tt-fin-schet.r-schet tt-fin-schet.dop1 tt-fin-schet.dop2 tt-fin-schet.PS 
&Scoped-define DISPLAYED-TABLES tt-fin-schet
&Scoped-define FIRST-DISPLAYED-TABLE tt-fin-schet
&Scoped-Define DISPLAYED-OBJECTS f-host-name f-cli-name f-bank-name f-bik ~
f-curr-abbr 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-bank 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1" 
     SIZE 3 BY 1.

DEFINE BUTTON B-cli 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1" 
     SIZE 3 BY 1.

DEFINE BUTTON B-currency 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1" 
     SIZE 3 BY 1.

DEFINE BUTTON B-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist 
     LABEL "Ис&тория" 
     SIZE 3 BY 1.

DEFINE BUTTON B-print 
     LABEL "Пе&чать" 
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-bank-name AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 68 BY 1 NO-UNDO.

DEFINE VARIABLE f-bik AS CHARACTER FORMAT "X(22)":U 
     LABEL "БИК" 
     VIEW-AS FILL-IN 
     SIZE 14.75 BY 1 NO-UNDO.

DEFINE VARIABLE f-cli-name AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 40 BY 1 NO-UNDO.

DEFINE VARIABLE f-curr-abbr AS CHARACTER FORMAT "X(3)":U 
     VIEW-AS FILL-IN 
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE f-host-name AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 40 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR 
      tt-fin-schet, 
      X_schet-clients SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-print AT ROW 1 COL 89
     B-hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     tt-fin-schet.host-code AT ROW 2.5 COL 13 COLON-ALIGNED
          LABEL "Фирма" FORMAT ">>>>>>>>9"
          VIEW-AS FILL-IN 
          SIZE 12 BY 1
     f-host-name AT ROW 2.5 COL 25.25 COLON-ALIGNED NO-LABEL
     tt-fin-schet.code-schet AT ROW 2.5 COL 78.5 COLON-ALIGNED
          LABEL "Код счета"
          VIEW-AS FILL-IN 
          SIZE 8 BY 1
     f-cli-name AT ROW 4 COL 46.13 COLON-ALIGNED NO-LABEL
     tt-fin-schet.cli-code AT ROW 4.04 COL 28.5 COLON-ALIGNED NO-LABEL FORMAT ">>>>>>>>9"
          VIEW-AS FILL-IN 
          SIZE 11 BY 1
     B-cli AT ROW 4.08 COL 44.38
     tt-fin-schet.cli-type AT ROW 4.13 COL 17.63 NO-LABEL
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS 
                    "Item 1", "1":U
          SIZE 12.25 BY .96
     tt-fin-schet.code-bank AT ROW 6.08 COL 13 COLON-ALIGNED
          LABEL "Банк"
          VIEW-AS FILL-IN 
          SIZE 9 BY 1
     B-bank AT ROW 6.08 COL 25.25
     f-bank-name AT ROW 6.08 COL 28 COLON-ALIGNED NO-LABEL
     f-bik AT ROW 7.33 COL 28 COLON-ALIGNED
     tt-fin-schet.c-schet AT ROW 9.54 COL 13 COLON-ALIGNED
          LABEL "Корр.счет"
          VIEW-AS FILL-IN 
          SIZE 23 BY 1
     tt-fin-schet.curr-code AT ROW 9.54 COL 53.13 COLON-ALIGNED
          LABEL "Код валюты"
          VIEW-AS FILL-IN 
          SIZE 4 BY 1
     B-currency AT ROW 9.54 COL 59.88
     f-curr-abbr AT ROW 9.54 COL 62.75 COLON-ALIGNED NO-LABEL
     tt-fin-schet.r-schet AT ROW 10.79 COL 13 COLON-ALIGNED
          LABEL "Расч. счет"
          VIEW-AS FILL-IN 
          SIZE 23 BY 1
     tt-fin-schet.dop1 AT ROW 12 COL 43.5 COLON-ALIGNED
          LABEL "Дополн. к названию держателя счета"
          VIEW-AS FILL-IN 
          SIZE 30 BY 1
     tt-fin-schet.dop2 AT ROW 13.25 COL 43.5 COLON-ALIGNED
          LABEL "Дополн. к названию банка"
          VIEW-AS FILL-IN 
          SIZE 30 BY 1
     tt-fin-schet.PS AT ROW 15 COL 13 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 63.5 BY 4
     "Держатель счета" VIEW-AS TEXT
          SIZE 15.13 BY .92 AT ROW 4.17 COL 1.75
     "Примечания" VIEW-AS TEXT
          SIZE 10.63 BY 1 AT ROW 15.13 COL 2
     SPACE(86.36) SKIP(3.57)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Банковский счет"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Add Fields to: Neither
   Temp-Tables and Buffers:
      TABLE: locked_fin-schet B "?" ? ub fin-schet
      TABLE: tt-fin-schet T "?" NO-UNDO ub fin-schet
      TABLE: X_clients B "?" ? ub clients
      TABLE: X_clients-host B "?" NO-UNDO ub clients
      TABLE: X_currency B "?" ? ub currency
      TABLE: X_fin-bank B "?" ? ub fin-bank
      TABLE: X_schet-clients B "?" NO-UNDO ub clients
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN tt-fin-schet.c-schet IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-fin-schet.cli-code IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-fin-schet.code-bank IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-schet.code-schet IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-fin-schet.curr-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-schet.dop1 IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-schet.dop2 IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN f-bank-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-bik IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-host-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-fin-schet.host-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-fin-schet.r-schet IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-fin-schet,Temp-Tables.X_schet-clients WHERE Temp-Tables.tt-fin-schet ..."
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Банковский счет */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-bank
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-bank Dialog-Frame
ON CHOOSE OF B-bank IN FRAME Dialog-Frame /* Btn 1 */
DO:
define variable v-rid-list as character no-undo.
define variable ref-rec as recid no-undo.
define variable v-status_ like ub.fin-bank.status_ no-undo init {&current-status}.
define buffer buf_fin-bank for ub.fin-bank.
{ gbl/stdbtn.i }
if available X_fin-bank then do:
    assign
     v-rid-list = string(recid(X_fin-bank))
     .
end.
run ref/finbanks.w (input parParentProc
              , input p-curr-host-code
              , input "b-sel":U
              , input {&company}
              , input p-host-code
              , input-output v-status_
              , input-output v-rid-list).

    if v-rid-list = "" then   do:
      return no-apply.
     end.
    ref-rec = integer( v-rid-list ).
    FIND FIRST buf_fin-bank WHERE
             recid (buf_fin-bank) = ref-rec NO-LOCK .
    if buf_fin-bank.status_ <> {&current-status} then do:
      message
      "Статус выбранного Вами банка" buf_fin-bank.status_ " - нельзя работать с таким банком"
      view-as alert-box error .
      return no-apply.
    end.
    FIND FIRST X_fin-bank WHERE recid (X_fin-bank) = ref-rec NO-LOCK .
    assign
    tt-fin-schet.code-bank =  X_fin-bank.code-bank
    tt-fin-schet.c-schet = X_fin-bank.cor-acc
    f-bank-name = X_fin-bank.bank-name
     f-bik = X_fin-bank.bik
    .
    display
      tt-fin-schet.code-bank
      f-bank-name
      f-bik
      tt-fin-schet.c-schet
    with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-cli Dialog-Frame
ON CHOOSE OF B-cli IN FRAME Dialog-Frame /* Btn 1 */
DO:
define variable ref-list as character no-undo.
define variable ref-rec as recid no-undo.
{ gbl/stdbtn.i }
  run ref/cli-all.w (  parParentProc
                  , "b-sel"
                  , tt-fin-schet.cli-type
                  , ?
                  , ?
                  , ?
                  , ?
                  , "without-obj":U
                  , output ref-list) .
    if ref-list = "" then   do:
      return no-apply.
     end.
    ref-rec = integer( ref-list ).
    FIND FIRST X_schet-clients WHERE recid (X_schet-clients) = ref-rec NO-LOCK .
    if NOT (X_schet-clients.obj-type = {&cmp}
            or
            X_schet-clients.obj-type = {&prs} ) then do:
      message
      "Выберите контрагента типа" {&cmp} "или" {&prs}
      view-as alert-box error .
      return no-apply.
    end.
    assign
    tt-fin-schet.cli-type =  X_schet-clients.obj-type
    tt-fin-schet.cli-code = X_schet-clients.obj-code
    f-cli-name            =  X_schet-clients.obj-name
    .
    display
      tt-fin-schet.cli-type
      tt-fin-schet.cli-code
      f-cli-name
    with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-currency
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-currency Dialog-Frame
ON CHOOSE OF B-currency IN FRAME Dialog-Frame /* Btn 1 */
DO:
define variable v-rid-list as character no-undo.
define variable ref-rec as recid no-undo.
{ gbl/stdbtn.i }
if available X_currency then ref-rec = recid(X_currency).
    run ref/currency.w (parparentproc, "b-sel", input-output ref-rec ).
    if ref-rec = ? then do:
        return no-apply.
    end.
    FIND FIRST X_currency WHERE recid (X_currency) = ref-rec NO-LOCK .
    assign
    tt-fin-schet.curr-code =  X_currency.curr-code
    f-curr-abbr = X_currency.curr-abbr
    .
    display
      tt-fin-schet.curr-code
      f-curr-abbr
    with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
{ gbl/stdbtn.i }
  run proc-save in this-procedure (yes) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
define variable v-rid-list as character no-undo.
{ gbl/stdbtn.i }
    run ref/fincscts.w
                (
                 input parParentProc
                ,input p-curr-host-code
                ,input "":U /*bttns*/
                ,input "one":U
                ,input locked_fin-schet.host-code
                ,input locked_fin-schet.cli-type
                ,input locked_fin-schet.cli-code
                ,input locked_fin-schet.curr-code
                ,input locked_fin-schet.code-bank
                ,input locked_fin-schet.code-schet
                ,input-output v-rid-list
                              )

 .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
define variable v-log as logical no-undo .
define variable v-cmp as character no-undo .
{ gbl/stdbtn.i }
run proc-save in this-procedure (no) no-error.
buffer-compare tt-fin-schet to locked_fin-schet
case-sensitive
save result in v-cmp .
if v-cmp <> "":U then do:
  message
  "Вы изменили БАНКОВСКИЙ СЧЕТ, но не сохранили его" skip
  "сохранить перед печатью?"
  view-as alert-box QUESTION buttons YES-NO update v-log.
end.
run proc-save in this-procedure (v-log) no-error.
    run ref/finschtp.p (
                 INPUT parParentProc
                 ,input locked_fin-schet.host-code
                 ,input locked_fin-schet.code-schet
              ) no-error.
if error-status:error then do:
  return no-apply.
end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-fin-schet.cli-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-fin-schet.cli-code Dialog-Frame
ON LEAVE OF tt-fin-schet.cli-code IN FRAME Dialog-Frame /* cli-code */
DO:
  if   input frame {&frame-name} tt-fin-schet.cli-code <> 0
  and input frame {&frame-name} tt-fin-schet.cli-code <> ?
  then do:
    run check-cli in this-procedure no-error.
    if error-status:error then do:
       return no-apply.
    end.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-fin-schet.cli-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-fin-schet.cli-type Dialog-Frame
ON VALUE-CHANGED OF tt-fin-schet.cli-type IN FRAME Dialog-Frame
DO:
  assign
  tt-fin-schet.cli-type.
  if   input frame {&frame-name} tt-fin-schet.cli-code <> 0
  and input frame {&frame-name} tt-fin-schet.cli-code <> ?
  then do:
    run check-cli in this-procedure no-error.
    if error-status:error then do:
       return no-apply.
    end.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-fin-schet.code-bank
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-fin-schet.code-bank Dialog-Frame
ON LEAVE OF tt-fin-schet.code-bank IN FRAME Dialog-Frame /* Банк */
DO:
{ gbl/stdbtn.i }
  if input frame {&frame-name} tt-fin-schet.code-bank <> ?
  AND input frame {&frame-name} tt-fin-schet.code-bank <> 0
  then do:
    find first X_fin-bank no-lock where
                          X_fin-bank.host-code = p-host-code
                  AND X_fin-bank.code-bank = input frame {&frame-name} tt-fin-schet.code-bank no-error.
      if not available X_fin-bank then do:
          display
          0 @ tt-fin-schet.code-bank
          ? @ f-bank-name
          "":U @ tt-fin-schet.c-schet
          with frame {&frame-name} .
          APPLY "CHOOSE" to b-bank.
          return no-apply.
      end.
      assign
      tt-fin-schet.code-bank = X_fin-bank.code-bank
      tt-fin-schet.c-schet = X_fin-bank.cor-acc
      f-bank-name =   X_fin-bank.bank-name
.
      display
      tt-fin-schet.code-bank
      tt-fin-schet.c-schet
      f-bank-name
      with frame {&frame-name}.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-fin-schet.curr-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-fin-schet.curr-code Dialog-Frame
ON LEAVE OF tt-fin-schet.curr-code IN FRAME Dialog-Frame /* Код валюты */
DO:
  if input frame {&frame-name} tt-fin-schet.curr-code <> ? then do:
    find first X_currency no-lock where
                    X_currency.curr-code = input frame {&frame-name} tt-fin-schet.curr-code no-error.
      if not available X_currency then do:
          display
          ? @ tt-fin-schet.curr-code
          {&question-mark} @ f-curr-abbr
          with frame {&frame-name}.
          APPLY "ENTRY" to tt-fin-schet.curr-code.
          return no-apply.
      end.
      assign
          tt-fin-schet.curr-code = X_currency.curr-code
          .
      display
        X_currency.curr-abbr @ f-curr-abbr
        tt-fin-schet.curr-code
        with frame {&frame-name}.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */
{ gbl/app_help.i }

{ ref/tabhndmv.i v-tab-order }

{ gbl/rethndmv.i v-tab-order underline-tb "APPLY 'CHOOSE' TO b-exit in frame {&frame-name}." }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 if p-mode  <> {&add-def}
 and p-mode <> {&update}
 and p-mode <> {&lookup}
 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"  p-mode
    view-as alert-box ERROR.
    undo, return error.
 end.
 { gbl/curdbnum.i v-db-num }
find first X_sysconf no-lock where
                X_sysconf.host-code = p-host-code.
find first X_curr_sysconf no-lock where
                X_curr_sysconf.host-code = p-curr-host-code.
 if p-mode <> {&lookup} then do:
    if X_curr_sysconf.host-code <> p-host-code
    or v-db-num <> X_sysconf.firm-db-num
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова p-mode и/или p-host-code и/или p-curr-host-code" p-mode p-host-code  p-curr-host-code
      view-as alert-box ERROR.
      undo, return error.
    end.
  end.
  for each tt-fin-schet:
        delete tt-fin-schet.
    end.
  if p-mode = {&update}
  or p-mode = {&lookup} then do:
    if p-mode = {&update} then do:
      find first locked_fin-schet EXclusive-lock where
                   recid(locked_fin-schet) = p-doc-rec no-wait no-error.
      if locked locked_fin-schet then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись БАНКОВСКОГО СЧЕТА занята"
        view-as alert-box error .
        undo, return error.
      end.
    end.
    else do:
      find first locked_fin-schet no-lock where
                       recid(locked_fin-schet) = p-doc-rec no-error .
      if not avail locked_fin-schet then do:
        find first locked_fin-schet no-lock where
                   locked_fin-schet.host-code = p-host-code
               AND locked_fin-schet.code-schet = p-code-schet no-error .
      end.
    end.
    if not available locked_fin-schet then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись БАНК"
      view-as alert-box error .
      undo, return error.
    end.
    create tt-fin-schet.
    buffer-copy locked_fin-schet to tt-fin-schet.
   end.
   else do:
          create tt-fin-schet.
          assign
          tt-fin-schet.host-code = p-host-code
          tt-fin-schet.cli-type = {&cmp}
          tt-fin-schet.code-bank = p-code-bank
          tt-fin-schet.cli-type = (if p-cli-type <> "":U
                                   then p-cli-type
                                   else {&cmp})
          tt-fin-schet.cli-code = (if p-cli-code <> 0
                                   then p-cli-code
                                   else 0)
          tt-fin-schet.curr-code = (if p-curr-code <> ?
                                    then p-curr-code
                                    else 0)
          .
   end.
  RUN MYEnable no-error .
  if error-status:error then do:
    undo, return error.
  end.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-cli Dialog-Frame 
PROCEDURE check-cli :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_clients for ub.clients.
  find first X_schet-clients no-lock where
            X_schet-clients.obj-type = tt-fin-schet.cli-type
        AND X_schet-clients.obj-code = input frame {&frame-name} tt-fin-schet.cli-code no-error.
    if not available X_schet-clients then do:
        display
        ? @ tt-fin-schet.cli-code
        {&question-mark} @ f-cli-name
        with frame {&frame-name}.
        apply "entry" to tt-fin-schet.cli-code in frame {&frame-name}.
        return error.
    end.
    assign
    tt-fin-schet.cli-code = X_schet-clients.obj-code
    .
    display
    X_schet-clients.obj-name @ f-cli-name
    tt-fin-schet.cli-code
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
  DISPLAY f-host-name f-cli-name f-bank-name f-bik f-curr-abbr 
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-fin-schet THEN 
    DISPLAY tt-fin-schet.host-code tt-fin-schet.code-schet tt-fin-schet.cli-code 
          tt-fin-schet.cli-type tt-fin-schet.code-bank tt-fin-schet.c-schet 
          tt-fin-schet.curr-code tt-fin-schet.r-schet tt-fin-schet.dop1 
          tt-fin-schet.dop2 tt-fin-schet.PS 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-print B-hist B-Help f-cli-name tt-fin-schet.cli-code 
         B-cli tt-fin-schet.cli-type tt-fin-schet.code-bank B-bank 
         tt-fin-schet.curr-code B-currency f-curr-abbr tt-fin-schet.r-schet 
         tt-fin-schet.dop1 tt-fin-schet.dop2 tt-fin-schet.PS 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
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
assign
tt-fin-schet.cli-type:radio-buttons in frame {&frame-name} = "Орг" + {&comma-char} + {&cmp} + {&comma-char} +
                                      "Чел" + {&comma-char} + {&prs}
v-tab-order = {&tab-order}
.
find first X_clients-host no-lock where
            X_clients-host.obj-type = {&cmp}
        AND X_clients-host.obj-code = p-host-code.
if p-mode <> {&add-def}
or not (p-cli-type = "":U and p-cli-code = 0)
then do:
  find first X_schet-clients no-lock where
              X_schet-clients.obj-type = tt-fin-schet.cli-type
          AND X_schet-clients.obj-code = tt-fin-schet.cli-code no-error .
  if not available X_schet-clients then do:
    message
    vss-workfile vss-revision vss-description skip
    "Не найден клиент для счета" p-cli-type p-cli-code
    view-as alert-box .
    return error .
  end.
end.
if p-mode <> {&add-def}
or not (p-code-bank = 0)
then do:
  find first X_fin-bank no-lock where
              X_fin-bank.host-code = tt-fin-schet.host-code
          AND X_fin-bank.code-bank = tt-fin-schet.code-bank no-error .
  if not available X_fin-bank then do:
    message
    vss-workfile vss-revision vss-description skip
    "Не найден банк для счета" p-code-bank "фирма" p-host-code
    view-as alert-box .
    return error .
  end.
end.
if p-mode <> {&add-def}
or not (p-curr-code = ?)
then do:
  find first X_currency no-lock where
              X_currency.curr-code = tt-fin-schet.curr-code no-error .
  if not available X_currency then do:
    message
    vss-workfile vss-revision vss-description skip
    "Не найдена валюта" p-curr-code p-curr-code
    view-as alert-box .
    return error .
  end.
end.

  DISPLAY
  X_clients-host.obj-name @  f-host-name
   WITH FRAME Dialog-Frame.
case p-mode:
  when {&add-def} then do:
    DISPLAY
    p-host-code @ tt-fin-schet.host-code
    ? @ tt-fin-schet.code-schet
    tt-fin-schet.code-bank
    tt-fin-schet.cli-type
    tt-fin-schet.cli-code
    tt-fin-schet.curr-code
    tt-fin-schet.dop1
    tt-fin-schet.dop2
    (if avail X_schet-clients
    then X_schet-clients.obj-name
    else "":U)  @ f-cli-name
    (if available X_fin-bank
    then X_fin-bank.bank-name
    else "":U)  @ f-bank-name
    (if available X_fin-bank
    then X_fin-bank.bik
    else "":U) @ f-bik
    (if available X_currency
    then X_currency.curr-abbr
    else "":U) @ f-curr-abbr
    WITH FRAME Dialog-Frame.
  end.
  otherwise do:
    DISPLAY
    tt-fin-schet.host-code
    tt-fin-schet.code-schet
    tt-fin-schet.code-bank
    tt-fin-schet.cli-type
    tt-fin-schet.cli-code
    tt-fin-schet.dop1
    tt-fin-schet.dop2
    X_schet-clients.obj-name @ f-cli-name
    X_fin-bank.bank-name @ f-bank-name
    X_fin-bank.bik @ f-bik
    X_currency.curr-abbr @ f-curr-abbr
    tt-fin-schet.curr-code
    tt-fin-schet.c-schet
    tt-fin-schet.r-schet
    tt-fin-schet.PS
    WITH FRAME Dialog-Frame.
  end.
END CASE.
if p-mode = {&lookup} then do:
assign
b-quit:label = "&Выход"
.
hide
b-exit in frame {&frame-name}.
end.
ENABLE
b-quit
B-exit when p-mode <> {&lookup}
b-print when p-mode <> {&add-def}
b-hist when p-mode <> {&add-def}
b-cli when p-mode = {&add-def} and (p-cli-type = "":U and p-cli-code = 0)
b-currency when (p-mode = {&update}
                or
                 (p-mode = {&add-def} and p-curr-code = 0)
                 )
b-bank when (p-mode = {&update}
             or
            (p-mode = {&add-def} and p-code-bank = 0)
            )
B-Help
tt-fin-schet.cli-code when p-mode = {&add-def} and (p-cli-type = "":U and p-cli-code = 0)
tt-fin-schet.cli-type when p-mode = {&add-def} and (p-cli-type = "":U and p-cli-code = 0)
tt-fin-schet.curr-code when (p-mode = {&update}
                            or
                            (p-mode = {&add-def} and p-curr-code = 0)
                            )
tt-fin-schet.r-schet when p-mode <> {&lookup}
tt-fin-schet.PS when p-mode <> {&lookup}
tt-fin-schet.code-bank when p-mode <> {&lookup}
tt-fin-schet.dop1  when p-mode <> {&lookup}
tt-fin-schet.dop2  when p-mode <> {&lookup}
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.

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
define input parameter p-save as logical no-undo .
if p-mode = {&lookup} then do:
    return error.
end.

if not available tt-fin-schet then do:
    create tt-fin-schet.
end.
if not available X_schet-clients then do:
    message
    "Вы не выбрали держателя счета"
    view-as alert-box error.
    return error.
end.
if not available X_fin-bank then do:
    message
    "Вы не выбрали банк"
    view-as alert-box error.
    return error.
end.
if not available X_currency then do:
    message
    "Вы не выбрали валюту счета"
    view-as alert-box error.
    return error.
end.
assign
tt-fin-schet.c-schet frame {&frame-name}
tt-fin-schet.cli-type
tt-fin-schet.cli-code
tt-fin-schet.code-bank
tt-fin-schet.curr-code
tt-fin-schet.dop1
tt-fin-schet.dop2
tt-fin-schet.r-schet
tt-fin-schet.PS
.
if not p-save then return.
 run ref/finscht1.p (
input-output p-doc-rec
,input p-mode
,input no
,input "r-schet"
,input p-host-code
,input p-code-schet
,input tt-fin-schet.c-schet
,input tt-fin-schet.cli-type
,input tt-fin-schet.cli-code
,input tt-fin-schet.code-bank
,input tt-fin-schet.curr-code
,INPUT tt-fin-schet.dop1
,INPUT tt-fin-schet.dop2
,input tt-fin-schet.r-schet
,input tt-fin-schet.PS
)
no-error.


if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

