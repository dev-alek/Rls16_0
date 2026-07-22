&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME pack-inf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS pack-inf
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Информация по пакету OPENXML

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/17/08
Author: Bakhtadze Natalya
Creation date: 02/17/08

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter p-esys-id           like ub.esys-pck-sent.esys-id    no-undo.
define input parameter p-db-num            like ub.esys-pck-sent.db-num    no-undo.
define input parameter p-esps-cr-db-num    like ub.esys-pck-sent.esps-cr-db-num    no-undo.
define input parameter p-esps-pack-num     like ub.esys-pck-sent.esps-pack-num no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Информация по пакету OPENXML".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME pack-inf

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.esys-pck-sent

/* Definitions for DIALOG-BOX pack-inf                                  */
&Scoped-define QUERY-STRING-pack-inf FOR EACH ub.esys-pck-sent SHARE-LOCK
&Scoped-define OPEN-QUERY-pack-inf OPEN QUERY pack-inf FOR EACH ub.esys-pck-sent SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-pack-inf ub.esys-pck-sent
&Scoped-define FIRST-TABLE-IN-QUERY-pack-inf ub.esys-pck-sent


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit RECT-1 RECT-2 RECT-3 b-help
&Scoped-Define DISPLAYED-OBJECTS f_db-num f_esys-id f-custom-pack-name ~
f_pack-num f_CreDate f_CreTime f_CreNum f_SendTxtDate f_SendTxtTime ~
f_RcvdDate f_RcvdTime

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-END-KEY DEFAULT
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-custom-pack-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Имя пакета в ВС"
     VIEW-AS FILL-IN
     SIZE 39 BY 1.07 NO-UNDO.

DEFINE VARIABLE f_CreDate AS DATE FORMAT "99/99/9999"
     LABEL "Дата создания"
     VIEW-AS FILL-IN
     SIZE 11 BY 1.

DEFINE VARIABLE f_CreNum AS INTEGER FORMAT "->,>>>,>>9" INITIAL 0
     LABEL "Кол-во формирований"
     VIEW-AS FILL-IN
     SIZE 11 BY 1.

DEFINE VARIABLE f_CreTime AS CHARACTER FORMAT "X(8)"
     LABEL "Время создания"
     VIEW-AS FILL-IN
     SIZE 9 BY 1.

DEFINE VARIABLE f_db-num AS INTEGER FORMAT ">>>>9" INITIAL ?
     LABEL "Номер БД"
     VIEW-AS FILL-IN
     SIZE 6 BY 1.

DEFINE VARIABLE f_esps-cr-db-num AS INTEGER FORMAT ">>>>9" INITIAL ?
     LABEL "Номер БД создания"
     VIEW-AS FILL-IN
     SIZE 6 BY 1.

DEFINE VARIABLE f_esys-id AS INTEGER FORMAT ">>>>9" INITIAL ?
     LABEL "Номер ВС"
     VIEW-AS FILL-IN
     SIZE 6 BY 1.

DEFINE VARIABLE f_pack-num AS INTEGER FORMAT ">>>>>>>>>9" INITIAL ?
     LABEL "Номер пакета"
     VIEW-AS FILL-IN
     SIZE 11 BY 1.

DEFINE VARIABLE f_RcvdDate AS DATE FORMAT "99/99/9999"
     LABEL "Дата"
     VIEW-AS FILL-IN
     SIZE 11 BY 1.

DEFINE VARIABLE f_RcvdTime AS CHARACTER FORMAT "X(8)"
     LABEL "Время"
     VIEW-AS FILL-IN
     SIZE 9 BY 1.

DEFINE VARIABLE f_SendTxtDate AS DATE FORMAT "99/99/9999"
     LABEL "Дата последнего"
     VIEW-AS FILL-IN
     SIZE 11 BY 1.

DEFINE VARIABLE f_SendTxtTime AS CHARACTER FORMAT "X(8)"
     LABEL "Время последнего"
     VIEW-AS FILL-IN
     SIZE 9 BY 1.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 61.6 BY 6.13.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 61.6 BY 4.5.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 61.6 BY 3.5.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY pack-inf FOR
      ub.esys-pck-sent SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME pack-inf
     b-exit AT ROW 1 COL 1
     b-help AT ROW 1 COL 40
     f_db-num AT ROW 2.67 COL 21.5 COLON-ALIGNED
     f_esys-id AT ROW 2.67 COL 21.5 COLON-ALIGNED WIDGET-ID 2
     f_esps-cr-db-num AT ROW 2.67 COL 22.5 COLON-ALIGNED WIDGET-ID 4
     f-custom-pack-name AT ROW 3.67 COL 21.5 COLON-ALIGNED WIDGET-ID 6
     f_pack-num AT ROW 4.67 COL 21.5 COLON-ALIGNED
     f_CreDate AT ROW 5.67 COL 21.5 COLON-ALIGNED
     f_CreTime AT ROW 6.67 COL 21.5 COLON-ALIGNED
     f_CreNum AT ROW 9.8 COL 21.5 COLON-ALIGNED
     f_SendTxtDate AT ROW 10.8 COL 21.5 COLON-ALIGNED
     f_SendTxtTime AT ROW 11.8 COL 21.5 COLON-ALIGNED
     f_RcvdDate AT ROW 14.3 COL 21.5 COLON-ALIGNED
     f_RcvdTime AT ROW 15.3 COL 21.5 COLON-ALIGNED
     "Получение подтверждения" VIEW-AS TEXT
          SIZE 25.1 BY .8 AT ROW 13.3 COL 3
     "Создание файла пакета" VIEW-AS TEXT
          SIZE 22.8 BY .7 AT ROW 8.8 COL 3
     RECT-1 AT ROW 2.37 COL 1.9
     RECT-2 AT ROW 8.5 COL 1.9
     RECT-3 AT ROW 13 COL 1.9
     SPACE(6.09) SKIP(0.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Дополнительная информация о пакете OpenXML"
         DEFAULT-BUTTON b-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX pack-inf
   FRAME-NAME                                                           */
ASSIGN
       FRAME pack-inf:SCROLLABLE       = FALSE
       FRAME pack-inf:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN f-custom-pack-name IN FRAME pack-inf
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f_CreDate IN FRAME pack-inf
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f_CreNum IN FRAME pack-inf
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f_CreTime IN FRAME pack-inf
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f_db-num IN FRAME pack-inf
   NO-ENABLE                                                            */
ASSIGN
       f_db-num:HIDDEN IN FRAME pack-inf           = TRUE.

/* SETTINGS FOR FILL-IN f_esps-cr-db-num IN FRAME pack-inf
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       f_esps-cr-db-num:HIDDEN IN FRAME pack-inf           = TRUE.

/* SETTINGS FOR FILL-IN f_esys-id IN FRAME pack-inf
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f_pack-num IN FRAME pack-inf
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f_RcvdDate IN FRAME pack-inf
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f_RcvdTime IN FRAME pack-inf
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f_SendTxtDate IN FRAME pack-inf
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f_SendTxtTime IN FRAME pack-inf
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX pack-inf
/* Query rebuild information for DIALOG-BOX pack-inf
     _TblList          = "ub.esys-pck-sent"
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX pack-inf */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME pack-inf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL pack-inf pack-inf
ON WINDOW-CLOSE OF FRAME pack-inf /* Дополнительная информация о пакете OpenXML */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK pack-inf


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

    define buffer buf_esys-pck-sent for ub.esys-pck-sent .

    find first buf_esys-pck-sent no-lock
      where buf_esys-pck-sent.esys-id   = p-esys-id
        and buf_esys-pck-sent.db-num   = p-db-num
        and buf_esys-pck-sent.esps-cr-db-num   = p-esps-cr-db-num
        and buf_esys-pck-sent.esps-pack-num = p-esps-pack-num
      no-error
    .
    if not available buf_esys-pck-sent then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Пакет N &1 для ВС &2 не найден.", p-esps-pack-num, p-esys-id )
        view-as alert-box error
      .
      return error .
    end.
    assign
      f_esys-id     = p-esys-id
      f_db-num      = p-db-num
      f_pack-num    = p-esps-pack-num
      f_CreDate     = buf_esys-pck-sent.esps-CreDate
      f_CreTime     = buf_esys-pck-sent.esps-CreTime
      f_CreNum      = buf_esys-pck-sent.esps-CreNum
      f_SendTxtDate = buf_esys-pck-sent.esps-SendTxtDate
      f_SendTxtTime = buf_esys-pck-sent.esps-SendTxtTime
      f_RcvdDate    = buf_esys-pck-sent.esps-rcvdDate
      f_RcvdTime    = buf_esys-pck-sent.esps-RcvdTime
      f-custom-pack-name = (if buf_esys-pck-sent.custom-pack-name = ''
                            then substitute("o&1.xml", string(p-esps-pack-num, "999999999"))
                            else buf_esys-pck-sent.custom-pack-name)
    .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI pack-inf  _DEFAULT-DISABLE
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
  HIDE FRAME pack-inf.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI pack-inf  _DEFAULT-ENABLE
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
  DISPLAY f_db-num f_esys-id f-custom-pack-name f_pack-num f_CreDate f_CreTime
          f_CreNum f_SendTxtDate f_SendTxtTime f_RcvdDate f_RcvdTime
      WITH FRAME pack-inf.
  ENABLE b-exit RECT-1 RECT-2 RECT-3 b-help
      WITH FRAME pack-inf.
  VIEW FRAME pack-inf.
  {&OPEN-BROWSERS-IN-QUERY-pack-inf}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
