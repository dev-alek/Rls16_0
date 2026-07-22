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

smart viewer для задания интервалов времени в стандартных отчетных формах

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

no_app_help.i
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
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Отчет о выручке" .
{ cmp/vssrevis.i }
{ cmp/showinf.i  }

DEFINE SHARED TEMP-TABLE times NO-UNDO
    FIELD time1 as integer
    FIELD time2 as integer
    FIELD times as char
    INDEX pi IS PRIMARY UNIQUE time1 time2
    INDEX ps times.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME F-mMain

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 F-hour1 F-min1 F-hour2 F-min2 B-add ~
SEL-time B-del
&Scoped-Define DISPLAYED-OBJECTS F-hour1 F-min1 F-hour2 F-min2 SEL-time

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
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE VARIABLE F-hour1 AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3.25 BY 1 NO-UNDO.

DEFINE VARIABLE F-hour2 AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3.25 BY 1 NO-UNDO.

DEFINE VARIABLE F-min1 AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3.25 BY 1 NO-UNDO.

DEFINE VARIABLE F-min2 AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3.25 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 23.25 BY 12.54.

DEFINE VARIABLE SEL-time AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE SORT SCROLLBAR-VERTICAL
     SIZE 17.88 BY 6.67 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-mMain
     F-hour1 AT ROW 3.13 COL 3.13 NO-LABEL
     F-min1 AT ROW 3.13 COL 7.88 NO-LABEL
     F-hour2 AT ROW 3.13 COL 15.13 NO-LABEL
     F-min2 AT ROW 3.13 COL 19.88 NO-LABEL
     B-add AT ROW 4.29 COL 8.25
     SEL-time AT ROW 5.46 COL 4.75 NO-LABEL
     B-del AT ROW 12.38 COL 7.63
     ":" VIEW-AS TEXT
          SIZE 1.5 BY 1 AT ROW 3.13 COL 18.38
          BGCOLOR 15
     ":" VIEW-AS TEXT
          SIZE 1.5 BY 1 AT ROW 3.13 COL 6.38
          BGCOLOR 15
     "временных интервалов" VIEW-AS TEXT
          SIZE 20.75 BY .71 AT ROW 2.17 COL 3.63
          FGCOLOR 4
     "Выбор" VIEW-AS TEXT
          SIZE 6.13 BY .71 AT ROW 1.38 COL 8.88
          FGCOLOR 4
     RECT-1 AT ROW 1.17 COL 1.88
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
         HEIGHT             = 12.92
         WIDTH              = 24.88.
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
/* SETTINGS FOR FRAME F-mMain
   NOT-VISIBLE Size-to-Fit                                              */
ASSIGN
       FRAME F-mMain:SCROLLABLE       = FALSE
       FRAME F-mMain:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN F-hour1 IN FRAME F-mMain
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN F-hour2 IN FRAME F-mMain
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN F-min1 IN FRAME F-mMain
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN F-min2 IN FRAME F-mMain
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-mMain
/* Query rebuild information for FRAME F-mMain
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-mMain */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add V-table-Win
ON CHOOSE OF B-add IN FRAME F-mMain /* Добавить */
DO:
  define variable for-times as char.

  assign
  F-hour1
  F-hour2
  F-min1
  F-min2
  .

  IF (F-hour1 * 3600 + F-min1 * 60) > (F-hour2 * 3600 + F-min2 * 60) then do:
    BELL.
    RETURN NO-APPLY.
  END.
  if can-find(first TIMES no-lock where
                    TIMES.TIME1 <= (F-hour1 * 3600 + F-min1 * 60) and
                    not
                    TIMES.TIME2 < (F-hour1 * 3600 + F-min1 * 60))
    or
     can-find(first TIMES no-lock where
                    TIMES.TIME1 >= (F-hour1 * 3600 + F-min1 * 60) and

                    TIMES.TIME1 <= (F-hour2 * 3600 + F-min2 * 60 + 59))
    OR
     can-find(first TIMES no-lock where
                    TIMES.TIME1 >= (F-hour1 * 3600 + F-min1 * 60) and

                    TIMES.TIME1 <= (F-hour2 * 3600 + F-min2 * 60 + 59))
                    THeN DO:
        MESSAGE "Нельзя вводить перекрывающиеся периоды времени"
        view-as alert-box ERROR.
        RETURN NO-APPLY.
  end.


  assign
  for-times = string(f-hour1, "99") + ":" + string(f-min1, "99") + " - " +
              string(f-hour2, "99") + ":" + string(f-min2, "99")
              .
  find first times where times.times = for-times no-lock no-error.
  if available times then do:
    bell.
    message "Этот период уже выбран" .
    apply "entry" to F-hour1.
    return.
  end.
  create times.
  assign
  times.time1 = F-hour1 * 3600 + F-min1 * 60
  times.time2 = F-hour2 * 3600 + F-min2 * 60 + 59
  times.times = for-times
  .
  SEL-time:ADD-LAST(for-times).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del V-table-Win
ON CHOOSE OF B-del IN FRAME F-mMain /* Удалить */
DO:
  define variable for-TIMES as character.
  APPLY "ENTRY" to sel-TIME.
  assign sel-TIME.
  for-TIMES = Sel-TIME.
  SEL-TIME:DELETE(for-TIMES).
  FIND FIRST TIMES where TIMES = FOR-TIMES NO-ERROR.
  IF AVAILABLE TIMES then delete TIMES.
  APPLY "ENTRY" to sel-TIME.
  APPLY "CURSOR-UP" to sel-TIME.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME F-hour1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL F-hour1 V-table-Win
ON LEAVE OF F-hour1 IN FRAME F-mMain
DO:
  IF INTEGER(F-HOUR1:screen-value) > 23 then DO:
    BELL.
    RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME F-hour2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL F-hour2 V-table-Win
ON LEAVE OF F-hour2 IN FRAME F-mMain
DO:
  IF INTEGER(F-HOUR2:screen-value) > 23 then DO:
    BELL.
    RETURN NO-APPLY.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME F-min1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL F-min1 V-table-Win
ON LEAVE OF F-min1 IN FRAME F-mMain
DO:
  IF INTEGER(F-MIN1:screen-value) > 59 then DO:
    BELL.
    RETURN NO-APPLY.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME F-min2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL F-min2 V-table-Win
ON LEAVE OF F-min2 IN FRAME F-mMain
DO:
  IF INTEGER(F-MIN2:screen-value) > 59 then DO:
    BELL.
    RETURN NO-APPLY.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

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
  HIDE FRAME F-mMain.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize V-table-Win
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
  /*
  assign
  sel-time:list-item-pairs
  in frame {&frame-name} = "":U
  .
  */
  display
  0 @ f-hour1
  23 @ f-hour2
  0 @ f-MIN1
  59 @ f-MIN2
  with frame {&frame-name}
  .

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
