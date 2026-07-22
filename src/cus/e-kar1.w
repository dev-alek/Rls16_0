&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS F-Frame-Win
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

СПисок чеков с одной товарной строкой

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/18/05
Author: Bakhtadze Natalya
Creation date: 10/18/05


*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список чеков с одной товарной строкой".
{ cmp/vssrevis.i }


{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/r-pril.i new }
{ cmp/r-page1.i }
{ gbl/waitfram.i }


&global-define  no-benefits    "Не было никакой выручки  ~
в течение заданного Вами периода времени."

define variable     NotInc          as  log     no-undo.

define var cas-num as integer no-undo.
def SHARED var cas-shft as logical no-undo init no.
def buffer for-gds for ub.chk-gds.
def stream PrnLibStream .
define variable found as logical init yes no-undo.
{ rep/e-nobenq.i }


{ cmp/operlist.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER FRAME

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RS-method
&Scoped-Define DISPLAYED-OBJECTS RS-method

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE RS-method AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Включенные в отчет о продаже", 1,
"Не включенные в отчет о продаже", 2,
"Все чеки", 3
     SIZE 34.5 BY 2.79 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     RS-method AT ROW 2.38 COL 4.88 NO-LABEL
     "Чеки" VIEW-AS TEXT
          SIZE 16.38 BY .88 AT ROW 1.38 COL 5.38
          FGCOLOR 4
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 43 BY 9.46.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic,Browse,DB-Fields,Smart,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW F-Frame-Win ASSIGN
         HEIGHT             = 9.46
         WIDTH              = 43.13.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB F-Frame-Win
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW F-Frame-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE                                                          */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = ""
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK F-Frame-Win


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
   /* Now enable the interface  if in test mode - otherwise this happens when
      the object is explicitly initialized from its container. */
   RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects F-Frame-Win  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available F-Frame-Win  _ADM-ROW-AVAILABLE
PROCEDURE adm-row-available :
/*------------------------------------------------------------------------------
  Purpose:     Dispatched to this procedure when the Record-
               Source has a new row available.  This procedure
               tries to get the new row (or foriegn keys) from
               the Record-Source and process it.
  Parameters:  <none>
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.             */
  {src/adm/template/row-head.i}

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI F-Frame-Win  _DEFAULT-DISABLE
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
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI F-Frame-Win  _DEFAULT-ENABLE
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
  DISPLAY RS-method
      WITH FRAME F-Main.
  ENABLE RS-method
      WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-report F-Frame-Win
PROCEDURE My-report :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_goods for ub.goods.
define buffer buf_bar-code for ub.bar-code.
run my-var.
run waitfram-show in this-procedure ("Ждите...").

run no-benq(OUTPUT found).

if not found then do:
    message {&no-benefits} view-as alert-box.
    run waitfram-hide in this-procedure .
    return.
end.
define variable g#log  as logical no-undo .
{ cmp/open-exp.i stream PrnLibStream}
put stream PrnLibStream unformatted
ReportName skip
str1 skip
str4 skip
REPORTHeader skip
"N чека" {&tabulation}
"Дата чека" {&tabulation} {&Article} format "X(16)" {&tabulation}
"Произ-ль" {&tabulation} {&name} skip.

FOR EACH obj-list No-LOCK:
_chk-gds:
  FOR EACH buf_chk-doc No-LOCK WHERE
           buf_chk-doc.obj-type = obj-list.obj-type AND
           buf_chk-doc.obj-code = obj-list.obj-code AND
           buf_chk-doc.chk-date >= X-date-start AND
           buf_chk-doc.chk-date <= X-date-end:
    if lookup(string(buf_chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-gds.
    ACCUMULATE buf_chk-doc.doc-code (COUNT).
    IF (ACCUM COUNT buf_chk-doc.doc-code) MODULO 50 = 0 then
    run waitfram-show in this-procedure ("Ждите..." + "Обработано " +
                   string(ACCUM COUNT buf_chk-doc.doc-code) + " чеков").

    IF RS-method = 1 and buf_chk-doc.out-code = ? then NEXT _chk-gds.
    IF RS-method = 2 and buf_chk-doc.out-code <> ? then NEXT _chk-gds.

    find first buf_chk-gds where buf_chk-gds.doc-code = buf_chk-doc.doc-code no-lock no-error.
    if can-find (FIRST for-gds where
                       for-gds.doc-code = buf_chk-doc.doc-code AND
                       recid(for-gds) <> recid(buf_chk-gds) AND
                       for-gds.b-code <> buf_chk-gds.b-code No-LOCK) then next.
    find first buf_bar-code where
               buf_bar-code.b-code = buf_chk-gds.b-code no-lock no-error.
    find first buf_goods where
               buf_goods.gds-code = buf_bar-code .gds-code NO-ERROR.
    put stream PrnLibStream unformatted
    buf_chk-doc.doc-code {&tabulation}
    buf_chk-doc.chk-date {&tabulation}
    buf_goods.artic format "x(16)" {&tabulation}
    buf_goods.prod-code {&tabulation}
    buf_goods.gds-name skip.

  END.  /*FOR EACH CHK-DOC*/
END. /*FOR EACH OBJ-LIST*/

{ cmp/cls-exp.i stream PrnLibStream}
/*
assign
g#rep-tblname = ""
g#rep-tblrid = -131
g#rep-updflds = "Список по чеков с одной товарной строкой|" + str1
.
*/
run waitfram-hide in this-procedure .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-var F-Frame-Win
PROCEDURE My-var :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
ASSIGN  frame {&frame-name}
RS-METHOD
.
assign
Reportname = "СПИСОК ЧЕКОВ С ОДНОЙ ТОВАРНОЙ СТРОКОЙ"
ReportHeader = radio-label(string(RS-method), RS-method:radio-buttons)
               .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records F-Frame-Win  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* SEND-RECORDS does nothing because there are no External
     Tables specified for this SmartObject, and there are no
     tables specified in any contained Browse, Query, or Frame. */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed F-Frame-Win
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME