&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE temp_fin-doc NO-UNDO LIKE ub.fin-doc
       field no-con-sum as decimal
       field is-plus as logical
       field ri as recid .


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Связка фин. обязательств с платежами - 1 ФО и много платежей

Автор: Чернова Светлана Александровна
Дата создания: 09/14/05
Author: Svetlana Chernova
Creation date: 09/14/05

*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
  define input  parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input  parameter p-host-code    as integer    no-undo . /* надо передавать фирму */
  define input  parameter p-ri           as  recid     no-undo . /* платеж */
  define input  parameter p-list         as  character no-undo . /* список recid обязат.*/
  define output parameter p-end          as logical initial no  no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Связка фин. обязательств с платежами - 1 ФО и много платежей".
{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }

  define variable g-log as logical   no-undo .
  define buffer b_fin-ob  for ub.fin-ob .
  define variable csum        as decimal   no-undo .
  define variable p-sys-time  as character no-undo .
  assign csum = 0 .
  define variable ii    as integer   no-undo .
  define variable msum as decimal initial 0  no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME Br-doc

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp_fin-doc

/* Definitions for BROWSE Br-doc                                        */
&Scoped-define FIELDS-IN-QUERY-Br-doc temp_fin-doc.prn-doc-code ~
temp_fin-doc.fin-doc-type temp_fin-doc.fin-doc-code temp_fin-doc.doc-date ~
temp_fin-doc.no-con-sum temp_fin-doc.con-sum-contr temp_fin-doc.sum-contr
&Scoped-define ENABLED-FIELDS-IN-QUERY-Br-doc
&Scoped-define QUERY-STRING-Br-doc FOR EACH temp_fin-doc WHERE TRUE /* Join to ub.fin-doc incomplete */ NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-Br-doc OPEN QUERY Br-doc FOR EACH temp_fin-doc WHERE TRUE /* Join to ub.fin-doc incomplete */ NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-Br-doc temp_fin-doc
&Scoped-define FIRST-TABLE-IN-QUERY-Br-doc temp_fin-doc


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-Br-doc}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS ub.fin-ob.prn-doc-code ub.fin-ob.doc-date ~
fin-ob.pay-date ub.fin-ob.sum-contract
&Scoped-define ENABLED-TABLES ub.fin-ob
&Scoped-define FIRST-ENABLED-TABLE ub.fin-ob
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-chg B-view-fo B-conn-fo ~
B-view-doc B-conn-doc b-help Br-doc FILL-IN_con-sum-contr current-sum ~
FILL-curr-contr
&Scoped-Define DISPLAYED-FIELDS ub.fin-ob.prn-doc-code ub.fin-ob.doc-date ~
fin-ob.pay-date ub.fin-ob.sum-contract
&Scoped-define DISPLAYED-TABLES ub.fin-ob
&Scoped-define FIRST-DISPLAYED-TABLE ub.fin-ob
&Scoped-Define DISPLAYED-OBJECTS FILL-IN_con-sum-contr current-sum ~
FILL-curr-contr

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-chg
     LABEL "&Изм.сумму"
     SIZE 10 BY 1.

DEFINE BUTTON B-conn-doc
     LABEL "Связи пл."
     SIZE 10 BY 1.

DEFINE BUTTON B-conn-fo
     LABEL "Связи ф-о"
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-view-doc
     LABEL "&Платеж"
     SIZE 10 BY 1.

DEFINE BUTTON B-view-fo
     LABEL "&Фин.обяз."
     SIZE 10 BY 1.

DEFINE VARIABLE current-sum AS DECIMAL FORMAT "->>>,>>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Тек. сумма "
     VIEW-AS FILL-IN
     SIZE 26 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-curr-contr AS CHARACTER FORMAT "X(256)":U
     LABEL "Вал."
      VIEW-AS TEXT
     SIZE 6 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-IN_con-sum-contr AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Свободно"
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Br-doc FOR
      temp_fin-doc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE Br-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS Br-doc Dialog-Frame _STRUCTURED
  QUERY Br-doc NO-LOCK DISPLAY
      temp_fin-doc.prn-doc-code FORMAT "X(16)":U
      temp_fin-doc.fin-doc-type FORMAT "X(3)":U
      temp_fin-doc.fin-doc-code COLUMN-LABEL "Вн.н." FORMAT "999999999":U
      temp_fin-doc.doc-date FORMAT "99/99/9999":U
      temp_fin-doc.no-con-sum COLUMN-LABEL "Связать " FORMAT "->>>>,>>>,>>>,>>9.99":U
      temp_fin-doc.con-sum-contr FORMAT "->>>>,>>>,>>>,>>9.99":U
      temp_fin-doc.sum-contr  COLUMN-LABEL "Сумма в вал. договора"  FORMAT "->>>>,>>>,>>>,>>9.99":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 17.33.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-chg AT ROW 1 COL 30
     B-view-fo AT ROW 1 COL 40
     B-conn-fo AT ROW 1 COL 50
     B-view-doc AT ROW 1 COL 60
     B-conn-doc AT ROW 1 COL 70
     b-help AT ROW 1 COL 88.5
     ub.fin-ob.prn-doc-code AT ROW 2.21 COL 10 COLON-ALIGNED
          LABEL "Фин.Об. №"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
     ub.fin-ob.doc-date AT ROW 2.21 COL 26.38 COLON-ALIGNED
          LABEL "от"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     ub.fin-ob.pay-date AT ROW 2.21 COL 45.75 COLON-ALIGNED
          LABEL "Платеж"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     ub.fin-ob.sum-contract AT ROW 2.21 COL 64.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 22.38 BY 1
     Br-doc AT ROW 3.42 COL 1.63
     FILL-IN_con-sum-contr AT ROW 20.96 COL 17.5 COLON-ALIGNED
     current-sum AT ROW 20.96 COL 69.5 COLON-ALIGNED
     FILL-curr-contr AT ROW 2.5 COL 93 COLON-ALIGNED
     SPACE(0.00) SKIP(18.82)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Связь фин. обязательств и платежей".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: temp_fin-doc T "?" NO-UNDO ub ub.fin-doc
      ADDITIONAL-FIELDS:
          field no-con-sum as decimal
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB Br-doc sum-contract Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN ub.fin-ob.doc-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       ub.fin-ob.doc-date:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       FILL-curr-contr:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       FILL-IN_con-sum-contr:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       current-sum:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN ub.fin-ob.pay-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.fin-ob.prn-doc-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       ub.fin-ob.prn-doc-code:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE Br-doc
/* Query rebuild information for BROWSE Br-doc
     _TblList          = "Temp-Tables.temp_fin-doc WHERE ub.fin-doc ..."
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   = Temp-Tables.temp_fin-doc.prn-doc-code
     _FldNameList[2]   > Temp-Tables.temp_fin-doc.fin-doc-type
"temp_fin-doc.fin-doc-type" ? "X(3)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[3]   > Temp-Tables.temp_fin-doc.fin-doc-code
"temp_fin-doc.fin-doc-code" "Вн.н." ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[4]   = Temp-Tables.temp_fin-doc.doc-date
     _FldNameList[5]   > Temp-Tables.temp_fin-doc.no-con-sum
"temp_fin-doc.no-con-sum" "Связать " ">,>>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[6]   > Temp-Tables.temp_fin-doc.con-sum-contr
"temp_fin-doc.con-sum-contr" ? ">,>>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[7]   = Temp-Tables.temp_fin-doc.sum-contr
     _Query            is OPENED
*/  /* BROWSE Br-doc */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Связь фин. обязательств и платежей */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изм.сумму */
DO:
  IF AVAIL temp_fin-doc THEN DO:
    define variable v-max as decimal   no-undo .
    define buffer b_temp_fin-doc for temp_fin-doc .

    assign msum = 0 .
    if ub.fin-ob.sum-contr > 0 then do:
      for each b_temp_fin-doc : if b_temp_fin-doc.no-con-sum < 0 then assign msum = msum - b_temp_fin-doc.no-con-sum . end.
      if (ub.fin-ob.sum-contr - ub.fin-ob.con-sum-contr) >= (temp_fin-doc.sum-contr - temp_fin-doc.con-sum-contr + msum) then assign v-max = temp_fin-doc.sum-contr - temp_fin-doc.con-sum-contr .
      else  assign v-max = ub.fin-ob.sum-contr - ub.fin-ob.con-sum-contr .
    end.
    else do:
      for each b_temp_fin-doc : if b_temp_fin-doc.no-con-sum > 0 then assign msum = msum + b_temp_fin-doc.no-con-sum . end.
      if ( - ub.fin-ob.sum-contr + ub.fin-ob.con-sum-contr) >= (temp_fin-doc.sum-contr - temp_fin-doc.con-sum-contr - msum) then assign v-max = temp_fin-doc.sum-contr - temp_fin-doc.con-sum-contr .
      else  assign v-max = - ub.fin-ob.sum-contr + ub.fin-ob.con-sum-contr .
    end.
    assign current-sum = current-sum - temp_fin-doc.no-con-sum .
    run str/fin-conp.w (input v-max,input-output temp_fin-doc.no-con-sum ) .

    assign current-sum = current-sum + temp_fin-doc.no-con-sum .
    br-doc:refresh() .
    DISPLAY current-sum WITH FRAME Dialog-Frame.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-conn-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-conn-doc Dialog-Frame
ON CHOOSE OF B-conn-doc IN FRAME Dialog-Frame /* Связи пл. */
DO:
  if available temp_fin-doc then do:
    run str/finconn.w ( input parParentProc, input p-host-code, input {&income}, input "fin-doc", input string(temp_fin-doc.fin-doc-code)) .
    br-doc:refresh() .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-conn-fo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-conn-fo Dialog-Frame
ON CHOOSE OF B-conn-fo IN FRAME Dialog-Frame /* Связи ф-о */
DO:
  if available ub.fin-ob then do:
    run str/finconn.w ( input parParentProc, input p-host-code, input {&income}, input "fin-ob", input ub.fin-ob.doc-code) .
    br-doc:refresh() .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  assign p-end = yes .
  run CreateProc no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отмена */
DO:
  message "Вы действительно хотите отменить создание связи?" view-as alert-box QUESTION BUTTONS YES-NO UPDATE g-log .
  if g-log = no then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-view-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-view-doc Dialog-Frame
ON CHOOSE OF B-view-doc IN FRAME Dialog-Frame /* Платеж */
DO:
  if not available temp_fin-doc then return.
  run ref/showfind.p (
                       input parParentProc
                      ,input p-host-code /*текущая фирма*/
                      ,input temp_fin-doc.host-code
                      ,input ub.fin-doc.fin-doc-code
                      ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-view-fo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-view-fo Dialog-Frame
ON CHOOSE OF B-view-fo IN FRAME Dialog-Frame /* Фин.обяз. */
DO:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-liability_lookup':U
    {&cntxt-firm}
    p-host-code
    '':U
    0
    0
    0
    0
    true
    g-log
  }
  if not g-log then  return .
  define variable rr as recid no-undo .
  if not available ub.fin-ob then return.
  run str/sh-finob.p ( input parParentProc, input p-host-code, input recid( ub.fin-ob)).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME Br-doc
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
{ gbl/app_help.i }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }

  run StartProc in this-procedure .

  assign FILL-IN_con-sum-contr = ub.fin-ob.sum-contr - ub.fin-ob.con-sum-contr .

  find ub.currency where ub.currency.curr-code = ub.fin-ob.contract-curr no-lock.
  assign FILL-curr-contr = ub.currency.curr-abbr .

  RUN enable_UI.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CreateProc Dialog-Frame
PROCEDURE CreateProc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define variable all-sum-contr as decimal   no-undo .
  define variable all-sum-base as decimal   no-undo .
  define variable all-sum-rubl as decimal   no-undo .
  define variable all-sum-doc as decimal   no-undo .

  for each temp_fin-doc :
    if temp_fin-doc.no-con-sum = 0 then next.
    create ub.fin-connect .
    assign
      ub.fin-connect.connect-code   = next-value( s-fin-connect, {&db-name_schema} )
      ub.fin-connect.host-code      = p-host-code
      ub.fin-connect.fin-doc-code   = temp_fin-doc.fin-doc-code
      ub.fin-connect.fin-ob-code    = ub.fin-ob.doc-code
      ub.fin-connect.contract-code  = ub.fin-ob.contract-code
      ub.fin-connect.curr-code      = ub.fin-ob.curr-code
      ub.fin-connect.base-rate      = ub.fin-ob.base-rate
      ub.fin-connect.base-scale     = ub.fin-ob.base-scale
      ub.fin-connect.contract-curr  = ub.fin-ob.contract-curr
      ub.fin-connect.contract-rate  = ub.fin-ob.contract-rate
      ub.fin-connect.contract-scale = ub.fin-ob.contract-scale
      ub.fin-connect.exch-rate      = ub.fin-ob.exch-rate
      ub.fin-connect.exch-scale     = ub.fin-ob.exch-scale
      ub.fin-connect.status_        = {&current-status}
      ub.fin-connect.sum-contr      = temp_fin-doc.no-con-sum
      ub.fin-connect.sum-rubl       = round(ub.fin-connect.sum-contr * ub.fin-connect.contract-rate / ub.fin-connect.contract-scale,2)
      ub.fin-connect.sum-base       = ub.fin-connect.sum-rubl * ub.fin-connect.base-scale / ub.fin-connect.base-rate
      ub.fin-connect.sum-doc        = ub.fin-connect.sum-rubl * ub.fin-connect.exch-scale / ub.fin-connect.exch-rate
      ub.fin-connect.sum-contr-ob   = ub.fin-connect.sum-contr
      ub.fin-connect.sum-rubl-ob    = ub.fin-connect.sum-rubl
      ub.fin-connect.sum-base-ob    = ub.fin-connect.sum-base
    .
    { gbl/curdburt.i  ub.fin-connect.user-db-num  ub.fin-connect.user-name  ub.fin-connect.fact-date  p-sys-time  ub.fin-connect.fact-time }
    find first ub.fin-doc exclusive-lock where ub.fin-doc.host-code = p-host-code and ub.fin-doc.fin-doc-code = temp_fin-doc.fin-doc-code .
    if ub.fin-connect.sum-contr > 0 then
      assign
        ub.fin-doc.con-sum-contr = ub.fin-doc.con-sum-contr + ub.fin-connect.sum-contr
        ub.fin-doc.con-sum-base  = ub.fin-doc.con-sum-base  + ub.fin-connect.sum-base
        ub.fin-doc.con-sum-rubl  = ub.fin-doc.con-sum-rubl  + ub.fin-connect.sum-rubl
        ub.fin-doc.con-sum-doc   = ub.fin-doc.con-sum-doc   + ub.fin-connect.sum-doc
      .
    else
      assign
        ub.fin-doc.con-sum-contr = ub.fin-doc.con-sum-contr - ub.fin-connect.sum-contr
        ub.fin-doc.con-sum-base  = ub.fin-doc.con-sum-base  - ub.fin-connect.sum-base
        ub.fin-doc.con-sum-rubl  = ub.fin-doc.con-sum-rubl  - ub.fin-connect.sum-rubl
        ub.fin-doc.con-sum-doc   = ub.fin-doc.con-sum-doc   - ub.fin-connect.sum-doc
      .
    assign
      all-sum-contr       = all-sum-contr + ub.fin-connect.sum-contr
      all-sum-base        = all-sum-base  + ub.fin-connect.sum-base
      all-sum-rubl         = all-sum-rubl  + ub.fin-connect.sum-rubl
      all-sum-doc          = all-sum-doc   + ub.fin-connect.sum-doc
    .
    if ub.fin-doc.sum-contr > ub.fin-doc.con-sum-contr then assign ub.fin-doc.con-stat = 1 .
    else                                            assign ub.fin-doc.con-stat = 2 .
  end.
  if all-sum-contr <> 0 then do:
    find current ub.fin-ob exclusive-lock .
    assign
      ub.fin-ob.con-sum-contr = ub.fin-ob.con-sum-contr + all-sum-contr
      ub.fin-ob.con-sum-base  = ub.fin-ob.con-sum-base  + all-sum-base
      ub.fin-ob.con-sum-rubl  = ub.fin-ob.con-sum-rubl  + all-sum-rubl
      ub.fin-ob.con-sum-doc   = ub.fin-ob.con-sum-doc   + all-sum-doc
    .
    if ub.fin-ob.sum-contr > 0 then do:
      if ub.fin-ob.sum-contr > ub.fin-ob.con-sum-contr then assign ub.fin-ob.con-stat = 1 .
      else                                          assign ub.fin-ob.con-stat = 2 .
    end.
    else do:
      if ub.fin-ob.sum-contr < ub.fin-ob.con-sum-contr then assign ub.fin-ob.con-stat = 1 .
      else                                          assign ub.fin-ob.con-stat = 2 .
    end.
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
  DISPLAY FILL-IN_con-sum-contr current-sum FILL-curr-contr
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.fin-ob THEN
    DISPLAY ub.fin-ob.prn-doc-code ub.fin-ob.doc-date ub.fin-ob.pay-date
          ub.fin-ob.sum-contract
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-chg B-view-fo B-conn-fo B-view-doc B-conn-doc b-help
         ub.fin-ob.prn-doc-code ub.fin-ob.doc-date ub.fin-ob.pay-date
         ub.fin-ob.sum-contract Br-doc FILL-IN_con-sum-contr current-sum
         FILL-curr-contr
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE StartProc Dialog-Frame
PROCEDURE StartProc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  find first ub.fin-ob no-lock where recid(ub.fin-ob) = p-ri .
  assign csum = ub.fin-ob.sum-contr - ub.fin-ob.con-sum-contr .
  for each temp_fin-doc : delete temp_fin-doc . end.

  DO ii = 1 TO NUM-ENTRIES(p-list) :
    find first ub.fin-doc NO-LOCK WHERE RECID( ub.fin-doc ) = INT ( ENTRY( ii, p-list) ) .
    CREATE temp_fin-doc .
    BUFFER-COPY ub.fin-doc TO temp_fin-doc .
    assign temp_fin-doc.ri = RECID( ub.fin-doc ) .

    find first ub.contract no-lock where ub.contract.host-code = ub.fin-doc.host-code and ub.contract.contract-code = ub.fin-doc.contract-code .
    if ub.contract.doc-type = {&income} then do:
      if   ub.fin-doc.fin-doc-type = {&income-cashless} or ub.fin-doc.fin-doc-type = {&income-cash} or ub.fin-doc.fin-doc-type = {&income-payoff} then
        assign
          temp_fin-doc.is-plus      = no
          temp_fin-doc.sum-contr     = - temp_fin-doc.sum-contr
          temp_fin-doc.con-sum-contr = - temp_fin-doc.con-sum-contr
        .
      else assign temp_fin-doc.is-plus = yes .
    end.
    else do:
      if   ub.fin-doc.fin-doc-type = {&expense-cashless} or ub.fin-doc.fin-doc-type = {&expense-cash} or ub.fin-doc.fin-doc-type = {&expense-payoff} then
        assign
          temp_fin-doc.is-plus      = no
          temp_fin-doc.sum-contr     = - temp_fin-doc.sum-contr
          temp_fin-doc.con-sum-contr = - temp_fin-doc.con-sum-contr
        .
      else assign temp_fin-doc.is-plus = yes .
    end.

    if csum > 0 then do:
      if csum > temp_fin-doc.sum-contr - temp_fin-doc.con-sum-contr then do:
        assign
          temp_fin-doc.no-con-sum = temp_fin-doc.sum-contr - temp_fin-doc.con-sum-contr
          csum = csum - temp_fin-doc.no-con-sum
        .
      end.
      else do:
        assign
          temp_fin-doc.no-con-sum = csum
          csum = 0
        .
      end.
      assign current-sum = current-sum + temp_fin-doc.no-con-sum .
    END.
    else if csum < 0 then do:
      if csum < temp_fin-doc.sum-contr - temp_fin-doc.con-sum-contr then do:
        assign
          temp_fin-doc.no-con-sum = - temp_fin-doc.sum-contr + temp_fin-doc.con-sum-contr
          csum = csum + temp_fin-doc.no-con-sum
        .
      end.
      else do:
        assign
          temp_fin-doc.no-con-sum = csum
          csum = 0
        .
      end.
      assign current-sum = current-sum + temp_fin-doc.no-con-sum .
    END.
  END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME