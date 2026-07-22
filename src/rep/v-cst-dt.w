&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME v-suppl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS v-suppl
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сводный отчет(склад МБТ- МБТ)

Автор: Суслов Алексей Юрьевич
Дата создания: 09/19/05
Author: Alexey Suslov
Creation date: 09/19/05

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input parameter from-date    as date no-undo .
define input parameter to-date      as date no-undo .
DEFINE INPUT PARAMETER parcst-code  LIKE parts.cst-code NO-UNDO.
DEFINE INPUT PARAMETER parartic     LIKE goods.artic      NO-UNDO.

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Сводный отчет(склад МБТ- МБТ)    ".
{ cmp/vssrevis.i }
/* Local Variable Definitions ---                                       */
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/t-tnved.i }
{ rep/v-cst.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME v-suppl
&Scoped-define BROWSE-NAME br-parts-brutto

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES parts-brutto

/* Definitions for BROWSE br-parts-brutto                               */
&Scoped-define FIELDS-IN-QUERY-br-parts-brutto parts-brutto.part-type parts-brutto.fact-date parts-brutto.artic parts-brutto.gds-name parts-brutto.cst-code parts-brutto.unit parts-brutto.fact-qnty parts-brutto.fact-brutto parts-brutto.obj-type parts-brutto.obj-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-parts-brutto
&Scoped-define FIELD-PAIRS-IN-QUERY-br-parts-brutto
&Scoped-define SELF-NAME br-parts-brutto
&Scoped-define OPEN-QUERY-br-parts-brutto OPEN QUERY {&SELF-NAME} FOR EACH parts-brutto WHERE  parts-brutto.artic     = parartic AND  parts-brutto.cst-code  = parcst-code USE-INDEX fact-num.
&Scoped-define TABLES-IN-QUERY-br-parts-brutto parts-brutto
&Scoped-define FIRST-TABLE-IN-QUERY-br-parts-brutto parts-brutto


/* Definitions for DIALOG-BOX v-suppl                                   */
&Scoped-define OPEN-BROWSERS-IN-QUERY-v-suppl ~
    ~{&OPEN-QUERY-br-parts-brutto}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-help b-quit br-parts-brutto

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY DEFAULT
     LABEL "Вы&ход "
     size 10 by 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-parts-brutto FOR
      parts-brutto SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-parts-brutto
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-parts-brutto v-suppl _FREEFORM
  QUERY br-parts-brutto DISPLAY
      parts-brutto.part-type     COLUMN-LABEL "Тип"
parts-brutto.fact-date     COLUMN-LABEL "Дата"
parts-brutto.artic         COLUMN-LABEL "Артикул! "
parts-brutto.gds-name      COLUMN-LABEL "Название товара! "
parts-brutto.cst-code      COLUMN-LABEL "Номер ГТД"   FORMAT "X(31)"
parts-brutto.unit          COLUMN-LABEL "Ед.!Изм." FORMAT "X(5)"
parts-brutto.fact-qnty     COLUMN-LABEL "Количество" FORMAT "->,>>>,>>9.<<<"
parts-brutto.fact-brutto   COLUMN-LABEL "Вес брутто" FORMAT "->,>>>,>>9.<<<"
parts-brutto.obj-type      COLUMN-LABEL "Тип!объекта"
parts-brutto.obj-code      COLUMN-LABEL "Код!объекта"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96.13 BY 12.75.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME v-suppl
     b-help AT ROW 1.17 COL 12.63
     b-quit at row 1.17 col 2
     br-parts-brutto AT ROW 2.58 COL 2
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D
         size 98.88 by 15.79
         TITLE "".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX v-suppl
                                                                        */
/* BROWSE-TAB br-parts-brutto b-quit v-suppl */
ASSIGN
       FRAME v-suppl:SCROLLABLE       = FALSE
       FRAME v-suppl:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-parts-brutto
/* Query rebuild information for BROWSE br-parts-brutto
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH parts-brutto WHERE
           parts-brutto.artic     = parartic AND
           parts-brutto.cst-code  = parcst-code USE-INDEX fact-num.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-parts-brutto */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX v-suppl
/* Query rebuild information for DIALOG-BOX v-suppl
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX v-suppl */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME v-suppl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-suppl v-suppl
ON WINDOW-CLOSE OF FRAME v-suppl
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-parts-brutto
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK v-suppl

 { gbl/app_help.i }
/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  FRAME {&FRAME-NAME}:TITLE = string( "Сводный отчет(склад МБТ- МБТ): " + string(from-date,"99/99/9999") +
                                                                    " по: " + string(to-date,"99/99/9999")).
  apply "entry" to br-parts-brutto in frame {&frame-name}.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI v-suppl _DEFAULT-DISABLE
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
  HIDE FRAME v-suppl.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI v-suppl _DEFAULT-ENABLE
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
  ENABLE b-help b-quit br-parts-brutto
      WITH FRAME v-suppl.
  VIEW FRAME v-suppl.
  {&OPEN-BROWSERS-IN-QUERY-v-suppl}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME