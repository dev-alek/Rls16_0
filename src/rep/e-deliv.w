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

Отчет по доставке товара

Автор: Кабоев Валерий Асланович
Дата создания: 19/09/12
Author: Kaboev Valeriy
Creation date: 19/09/12

*/

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
define variable vss-description as character no-undo init "Отчет по доставке товара" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }
{ gbl/cur-time.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER FRAME

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rect-3 f-start-hour f-start-min f-end-hour ~
f-end-min 
&Scoped-Define DISPLAYED-OBJECTS f-start-hour f-start-min f-end-hour ~
f-end-min 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE f-end-hour AS INTEGER FORMAT "99":U INITIAL 23 
     VIEW-AS FILL-IN 
     SIZE 3 BY .95 NO-UNDO.

DEFINE VARIABLE f-end-min AS INTEGER FORMAT "99":U INITIAL 59 
     LABEL "" 
     VIEW-AS FILL-IN 
     SIZE 3 BY .95 NO-UNDO.

DEFINE VARIABLE f-start-hour AS INTEGER FORMAT "99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 3 BY .95 NO-UNDO.

DEFINE VARIABLE f-start-min AS INTEGER FORMAT "99":U INITIAL 0 
     LABEL "" 
     VIEW-AS FILL-IN 
     SIZE 3 BY .95 NO-UNDO.

DEFINE RECTANGLE rect-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 46 BY 3.38.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     f-start-hour AT ROW 2.91 COL 2 COLON-ALIGNED NO-LABEL WIDGET-ID 28
     f-start-min AT ROW 2.91 COL 6.6 COLON-ALIGNED WIDGET-ID 32
     f-end-hour AT ROW 2.91 COL 13 COLON-ALIGNED NO-LABEL WIDGET-ID 34
     f-end-min AT ROW 2.91 COL 17.6 COLON-ALIGNED WIDGET-ID 36
     "Время доставки" VIEW-AS TEXT
          SIZE 23.4 BY .81 AT ROW 1.43 COL 3.6
          FGCOLOR 4 
     "-" VIEW-AS TEXT
          SIZE .8 BY .62 AT ROW 3.1 COL 12.8 WIDGET-ID 38
     rect-3 AT ROW 1.19 COL 2.2
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 49.4 BY 4.24.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic,Browse,DB-Fields,Smart,Query
   Container Links: 
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW F-Frame-Win ASSIGN
         HEIGHT             = 4.33
         WIDTH              = 49.4.
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
   NOT-VISIBLE FRAME-NAME                                               */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = ""
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME f-end-hour
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-end-hour F-Frame-Win
ON LEAVE OF f-end-hour IN FRAME F-Main
DO:
  /* new trigger */  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-end-hour F-Frame-Win
ON VALUE-CHANGED OF f-end-hour IN FRAME F-Main
DO:

  assign f-end-hour.
  if f-end-hour > 23 then do:
    f-end-hour = 23. 
    f-end-hour:screen-value = "23".
  end. 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-end-min
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-end-min F-Frame-Win
ON LEAVE OF f-end-min IN FRAME F-Main
DO:
  /* new trigger */  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-end-min F-Frame-Win
ON VALUE-CHANGED OF f-end-min IN FRAME F-Main
DO:
  assign f-end-min.
  if f-end-min > 59 then do:
    f-end-min = 59.
    f-end-min:screen-value = "59".  
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&Scoped-define SELF-NAME f-start-hour
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-start-hour F-Frame-Win
ON VALUE-CHANGED OF f-start-hour IN FRAME F-Main
DO:
  assign f-start-hour.
  if f-start-hour > 23 then do:
    f-start-hour = 23.
    f-start-hour:screen-value = "23". 
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-start-min
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-start-min F-Frame-Win
ON VALUE-CHANGED OF f-start-min IN FRAME F-Main
DO:
  assign f-start-min.
  if f-start-min > 59 then do:
    f-start-min = 59. 
    f-start-min:screen-value = "59".
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK F-Frame-Win 


&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
   /* Now enable the interface  if in test mode - otherwise this happens when
      the object is explicitly initialized from its container. */
   run dispatch in this-procedure ('initialize':u).
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
  DISPLAY f-start-hour f-start-min f-end-hour f-end-min 
      WITH FRAME F-Main.
  ENABLE rect-3 f-start-hour f-start-min f-end-hour f-end-min 
      WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize F-Frame-Win 
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/
  /* Code placed here will execute PRIOR to standard behavior. */
  /* Dispatch standard ADM method.                             */
  run dispatch in this-procedure ( input 'initialize':u ) .
  /* Code placed here will execute AFTER standard behavior.    */
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-report F-Frame-Win 
PROCEDURE My-report :
RUN My-var.
/*my-handle*/

    if f-start-hour * 60 + f-start-min > f-end-hour * 60 + f-end-min then do:
    f-end-hour = 23.
    f-end-min = 59.
    f-end-hour:screen-value in frame F-Main = "23".
    f-end-min:screen-value in frame F-Main = "59".
    end.

    run rep/r-deliv.p (
                        input my-handle,
                        input f-start-hour,
                        input f-start-min,
                        input f-end-hour,
                        input f-end-min 
                        ).

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var F-Frame-Win 
PROCEDURE my-var :
Reportname = "Отчёт по доставке товара".
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed F-Frame-Win 
PROCEDURE state-changed :
define input parameter p-issuer-hdl as handle no-undo.
  define input parameter p-state as character no-undo.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

