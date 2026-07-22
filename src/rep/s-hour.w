&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS V-table-Win
/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Форма для ввода часов в почасовых отчетах

Автор: Чернова Светлана Александровна
Дата создания: 03/06/06
Author: Svetlana Chernova
Creation date: 03/06/06

Created: 16/10/00
no_app_help.i
*/

/*
  Input Parameters:
      <none>

  Output Parameters:
      <none>

------------------------------------------------------------------------*/
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
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Форма ввода часов для почасовых отчетов" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ rep/s-hour.i   }
{ cmp/showinf.i  }
define variable kk     as integer NO-UNDO.
define variable State-source as WIDGET-HANDLE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-10 H-0 H-1 H-2 H-3 H-4 H-5 H-6 H-7 H-8 ~
H-9 H-10 H-11 H-12 H-13 H-14 H-15 H-16 H-17 H-18 H-19 H-20 H-21 H-22 H-23 ~
XL
&Scoped-Define DISPLAYED-OBJECTS H-0 H-1 H-2 H-3 H-4 H-5 H-6 H-7 H-8 H-9 ~
H-10 H-11 H-12 H-13 H-14 H-15 H-16 H-17 H-18 H-19 H-20 H-21 H-22 H-23 XL

/* Custom List Definitions                                              */
/* ADM-CREATE-FIELDS,ADM-ASSIGN-FIELDS,List-3,List-4,List-5,List-6      */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Foreign Keys" V-table-Win _INLINE
/* Actions: ? adm/support/keyedit.w ? ? ? */
/* STRUCTURED-DATA
<KEY-OBJECT>
THIS-PROCEDURE
</KEY-OBJECT>
<FOREIGN-KEYS>
</FOREIGN-KEYS>
<EXECUTING-CODE>
**************************
* Set attributes related to FOREIGN KEYS
*/
RUN set-attribute-list (
    'Keys-Accepted = "",
     Keys-Supplied = ""':U).
/**************************
</EXECUTING-CODE> */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 46 BY 9.58.

DEFINE VARIABLE H-0 AS LOGICAL INITIAL no
     LABEL "00:00-00:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE H-1 AS LOGICAL INITIAL no
     LABEL "01:00-01:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE H-10 AS LOGICAL INITIAL no
     LABEL "10:00-10:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE H-11 AS LOGICAL INITIAL no
     LABEL "11:00-11:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE H-12 AS LOGICAL INITIAL no
     LABEL "12:00-12:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE H-13 AS LOGICAL INITIAL no
     LABEL "13:00-13:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE H-14 AS LOGICAL INITIAL no
     LABEL "14:00-14:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE H-15 AS LOGICAL INITIAL no
     LABEL "15:00-15:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE H-16 AS LOGICAL INITIAL no
     LABEL "16:00-16:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE H-17 AS LOGICAL INITIAL no
     LABEL "17:00-17:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE H-18 AS LOGICAL INITIAL no
     LABEL "18:00-18:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE H-19 AS LOGICAL INITIAL no
     LABEL "19:00-19:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE H-2 AS LOGICAL INITIAL no
     LABEL "02:00-02:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE H-20 AS LOGICAL INITIAL no
     LABEL "20:00-20:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE H-21 AS LOGICAL INITIAL no
     LABEL "21:00-21:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE H-22 AS LOGICAL INITIAL no
     LABEL "22:00-22:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE H-23 AS LOGICAL INITIAL no
     LABEL "23:00-23:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE H-3 AS LOGICAL INITIAL no
     LABEL "03:00-03:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE H-4 AS LOGICAL INITIAL no
     LABEL "04:00-04:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE H-5 AS LOGICAL INITIAL no
     LABEL "05:00-05:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE H-6 AS LOGICAL INITIAL no
     LABEL "06:00-06:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE H-7 AS LOGICAL INITIAL no
     LABEL "07:00-07:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE H-8 AS LOGICAL INITIAL no
     LABEL "08:00-08:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE H-9 AS LOGICAL INITIAL no
     LABEL "09:00-09:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE XL AS LOGICAL INITIAL no
     LABEL "Вывод с разделителем (для импорта в EXCEL)"
     VIEW-AS TOGGLE-BOX
     SIZE 44 BY .96 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     H-0 AT ROW 3.04 COL 3
     H-1 AT ROW 3.04 COL 13.75
     H-2 AT ROW 3.04 COL 25
     H-3 AT ROW 3.04 COL 36.75
     H-4 AT ROW 4.33 COL 3
     H-5 AT ROW 4.33 COL 13.75
     H-6 AT ROW 4.33 COL 25
     H-7 AT ROW 4.33 COL 36.75
     H-8 AT ROW 5.71 COL 3
     H-9 AT ROW 5.71 COL 13.75
     H-10 AT ROW 5.71 COL 25
     H-11 AT ROW 5.71 COL 36.75
     H-12 AT ROW 7.04 COL 3
     H-13 AT ROW 7.04 COL 13.75
     H-14 AT ROW 7.04 COL 25
     H-15 AT ROW 7.04 COL 36.75
     H-16 AT ROW 8.33 COL 3
     H-17 AT ROW 8.33 COL 13.75
     H-18 AT ROW 8.33 COL 25
     H-19 AT ROW 8.33 COL 36.75
     H-20 AT ROW 9.42 COL 3
     H-21 AT ROW 9.42 COL 13.75
     H-22 AT ROW 9.42 COL 25
     H-23 AT ROW 9.42 COL 36.75
     XL AT ROW 11.21 COL 4.63
     "Показать следующие часы работы магазина:" VIEW-AS TEXT
          SIZE 40 BY 1 AT ROW 1.71 COL 5.13
          FGCOLOR 4
     RECT-10 AT ROW 1.38 COL 1.88
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1 SCROLLABLE .


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic,DB-Fields
   Frames: 1
   Add Fields to: External-Tables
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW V-table-Win ASSIGN
         HEIGHT             = 11.71
         WIDTH              = 46.88.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB V-table-Win
/* ************************* Included-Libraries *********************** */

{src/adm/method/viewer.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW V-table-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE Size-to-Fit                                              */
ASSIGN
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK V-table-Win


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
  &IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
    RUN dispatch IN THIS-PROCEDURE ('initialize':U).
  &ENDIF

  /************************ INTERNAL PROCEDURES ********************/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available V-table-Win  _ADM-ROW-AVAILABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Assign-Frame V-table-Win
PROCEDURE Assign-Frame :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
ASSIGN frame {&FRAME-NAME}
H-0 H-1 H-2 H-3 H-4 H-5 H-6 H-7 H-8 H-9 H-10
H-11 H-12 H-13 H-14 H-15 H-16 H-17 H-18 H-19
H-20 H-21 H-22 H-23 XL
.
ASSIGN
vH-0 = H-0
vH-1 = H-1
vH-2 = H-2
vH-3 = H-3
vH-4 = H-4
vH-5 = H-5
vH-6 = H-6
vH-7 = H-7
vH-8 = H-8
vH-9 = H-9
vH-10 = H-10
vH-11 = H-11
vH-12 = H-12
vH-13 = H-13
vH-14 = H-14
vH-15 = H-15
vH-16 = H-16
vH-17 = H-17
vH-18 = H-18
vH-19 = H-19
vH-20 = H-20
vH-21 = H-21
vH-22 = H-22
vH-23 = H-23
vXL   = XL
.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI V-table-Win  _DEFAULT-DISABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Display_ V-table-Win
PROCEDURE Display_ :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
ASSIGN XL = vXL.
DISPLAY XL WITH FRAME {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ini-from-selobj V-table-Win
PROCEDURE ini-from-selobj :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
{ rep/hours.i }
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records V-table-Win  _ADM-SEND-RECORDS
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed V-table-Win
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.
  CASE p-state:
      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
      {src/adm/template/vstates.i}
  END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME